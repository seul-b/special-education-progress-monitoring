base_theme <- theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom", legend.title = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(colour = "grey40")
  )

accent <- "#E95420"

shinyServer(function(input, output, session) {

  notify_error <- function(e) {
    showNotification(conditionMessage(e), type = "error", duration = 12)
  }

  # Table with Copy / Excel / Print buttons; "All" shows every row on one page
  dt <- function(data, opts = list()) {
    vis <- list(columns = ":visible")
    datatable(
      data, rownames = FALSE, extensions = "Buttons",
      options = modifyList(list(
        pageLength = 50, lengthMenu = list(c(25, 50, 100, -1), c("25", "50", "100", "All")),
        dom = "Blfrtip",
        buttons = list(list(extend = "copy", exportOptions = vis),
                       list(extend = "excel", exportOptions = vis),
                       list(extend = "print", exportOptions = vis))
      ), opts)
    )
  }

  # ===========================================================================
  # CLASS SCREENING (assessment-agnostic: everything follows the cut-score file)
  # ===========================================================================
  scr <- reactiveVal(NULL)        # standardised long scores
  bench <- reactiveVal(NULL)      # list(levels, cuts) from the cut-score file
  benchName <- reactiveVal("")
  demoOn <- reactiveVal(FALSE)
  rules <- reactiveVal(default_rules)

  observeEvent(input$scrFile, {
    tryCatch({
      scr(standardise_screening(read_upload(input$scrFile$datapath)))
      if (demoOn()) {
        bench(NULL)
        benchName("")
        demoOn(FALSE)
      }
    }, error = notify_error)
  })

  observeEvent(input$benchFile, {
    tryCatch({
      bench(standardise_benchmarks(read_upload(input$benchFile$datapath)))
      benchName(input$benchFile$name)
      if (demoOn()) {
        scr(NULL)
        demoOn(FALSE)
      }
    }, error = notify_error)
  })

  observeEvent(input$recFile, {
    tryCatch(rules(standardise_rules(read_upload(input$recFile$datapath))), error = notify_error)
  })

  load_demo <- function(kind, label) {
    b <- demo_cuts(kind)
    bench(b)
    scr(demo_screening(b))
    benchName(label)
    demoOn(TRUE)
  }
  observeEvent(input$demo3, load_demo("three", "Demo: 3 levels"))

  output$scrTemplate <- downloadHandler(
    filename = "screening-scores-template.csv",
    content = function(file) write.csv(screening_template(), file, row.names = FALSE, na = "")
  )
  output$benchTemplate <- downloadHandler(
    filename = function() paste0("cut-scores-template-", input$tplKind, ".csv"),
    content = function(file) write.csv(benchmark_template(input$tplKind), file, row.names = FALSE, na = "")
  )
  output$recTemplate <- downloadHandler(
    filename = "skill-order.csv",
    content = function(file) write.csv(select(rules(), Measure, Skill), file, row.names = FALSE, na = "")
  )

  # ---- Levels, on-track level and colours -------------------------------------
  levelsR <- reactive({
    if (!is.null(bench())) bench()$levels
    else if (!is.null(scr())) given_levels(scr())
    else character(0)
  })

  observeEvent(levelsR(), {
    lv <- levelsR()
    updateSelectInput(session, "targetLevel", choices = lv, selected = default_target(lv))
  })

  targetR <- reactive({
    lv <- levelsR()
    if (length(lv) == 0) return(NULL)
    t <- input$targetLevel
    if (!is.null(t) && t %in% lv) t else default_target(lv)
  })

  belowR <- reactive({
    t <- targetR()
    if (is.null(t)) character(0) else levelsR()[seq_len(match(t, levelsR()) - 1)]
  })
  atOrAboveR <- reactive(setdiff(levelsR(), belowR()))

  sty <- reactive(level_style(levelsR(), targetR()))
  status_style <- reactive(styleEqual(names(sty()$fill), unname(sty()$fill)))
  status_scales <- function() {
    list(scale_fill_manual(values = sty()$cols), scale_shape_manual(values = sty()$shapes))
  }

  observe({
    updateCheckboxGroupInput(session, "grpStatus", choices = c(levelsR(), NO_BM),
                             selected = belowR(), inline = TRUE)
  })

  output$scrLegend <- renderUI({
    f <- sty()$fill
    if (length(levelsR()) == 0) return(NULL)
    div(
      lapply(names(f), function(s) {
        span(class = "legend-chip", style = paste0("background:", f[[s]]), s)
      })
    )
  })

  # ---- Scored data ------------------------------------------------------------
  scored <- reactive({
    req(scr())
    apply_benchmarks(scr(), bench(), levelsR(), targetR())
  })

  # Measures in cut-score-file order, then any others in scores-file order
  measure_order <- function(m) {
    u <- unique(as.character(m))
    known <- if (is.null(bench())) character(0) else unique(bench()$cuts$Measure)
    c(intersect(known, u), setdiff(u, known))
  }

  observeEvent(scored(), {
    d <- scored()
    periods <- levels(d$Period)
    ms <- measure_order(d$Measure)
    keep <- function(old, choices, default) {
      if (!is.null(old) && length(old) && all(old %in% choices)) old else default
    }
    updateSelectInput(session, "scrClass", choices = sort(unique(d$Class)),
                      selected = keep(input$scrClass, unique(d$Class), character(0)))
    updateSelectInput(session, "scrGrade", choices = sort(unique(na.omit(d$Grade))),
                      selected = keep(input$scrGrade, unique(d$Grade), character(0)))
    updateSelectInput(session, "scrPeriod", choices = periods,
                      selected = keep(input$scrPeriod, periods, tail(periods, 1)))
    updateSelectInput(session, "grpMeasure", choices = ms,
                      selected = keep(input$grpMeasure, ms, character(0)))
    updateSelectInput(session, "prMeasure", choices = ms, selected = keep(input$prMeasure, ms, ms[1]))
    updateSelectInput(session, "grMeasure", choices = ms, selected = keep(input$grMeasure, ms, ms[1]))
    updateSelectInput(session, "prFrom", choices = periods, selected = keep(input$prFrom, periods, periods[1]))
    updateSelectInput(session, "prTo", choices = periods, selected = keep(input$prTo, periods, tail(periods, 1)))
  })

  # Scores after the Class / Grade filters (all periods)
  preStudent <- reactive({
    d <- scored()
    if (length(input$scrClass)) d <- filter(d, Class %in% input$scrClass)
    if (length(input$scrGrade)) d <- filter(d, Grade %in% input$scrGrade)
    d
  })

  # Student picker: empty means everyone
  observeEvent(preStudent(), {
    st <- sort(unique(preStudent()$Student))
    updateSelectizeInput(session, "scrStudent", choices = st,
                         selected = intersect(isolate(input$scrStudent), st))
  })
  observeEvent(input$stuAll, {
    updateSelectizeInput(session, "scrStudent", selected = sort(unique(preStudent()$Student)))
  })
  observeEvent(input$stuNone, {
    updateSelectizeInput(session, "scrStudent", selected = character(0))
  })

  filt <- reactive({
    d <- preStudent()
    if (length(input$scrStudent)) d <- filter(d, Student %in% input$scrStudent)
    d
  })

  observeEvent(filt(), {
    st <- sort(unique(filt()$Student))
    old <- isolate(input$grStudent)
    updateSelectInput(session, "grStudent", choices = st,
                      selected = if (!is.null(old) && old %in% st) old else st[1])
  })

  # ... and for the selected period only
  cur <- reactive({
    req(input$scrPeriod)
    filter(filt(), Period == input$scrPeriod)
  })

  output$scrBanner <- renderUI({
    if (is.null(scr())) {
      msg <- if (is.null(bench())) {
        "Upload a scores file and the cut scores for your assessment to begin, or try one of the demos."
      } else {
        sprintf("Cut scores loaded (%d levels: %s). Now upload a scores file.",
                length(levelsR()), paste(levelsR(), collapse = " < "))
      }
      return(div(class = "banner", msg))
    }
    d <- scored()
    nb <- sum(d$Status == NO_BM)
    if (demoOn()) {
      div(class = "banner", strong("Demo mode. "), "The students are made up and the cut scores are illustrative only - they are not the official values for any assessment.")
    } else if (nb == nrow(d)) {
      div(class = "banner", "No levels yet: upload the cut-score file for your assessment (step 2) so scores can be colour-coded. If one is loaded, check that Grade, Period and Measure names match your scores file.")
    } else if (nb > 0) {
      miss <- d |> filter(Status == NO_BM) |> distinct(Measure) |> pull(Measure)
      div(class = "banner", sprintf("%d of %d scores have no matching cut score and are shown in grey (measures affected: %s). Check Grade / Period / Measure in the cut-score file.",
                                    nb, nrow(d), paste(head(miss, 8), collapse = ", ")))
    }
  })

  # ---- Class overview ---------------------------------------------------------
  summaryData <- reactive({
    d <- cur()
    req(nrow(d) > 0)
    d <- mutate(d, Measure = factor(Measure, levels = measure_order(Measure)))
    cnt <- d |>
      count(Measure, Status, .drop = FALSE) |>
      pivot_wider(names_from = Status, values_from = n, values_fill = 0)
    if (NO_BM %in% names(cnt) && all(cnt[[NO_BM]] == 0)) cnt[[NO_BM]] <- NULL
    ok <- atOrAboveR()
    extra <- d |>
      group_by(Measure) |>
      summarise(
        Students = n(),
        pct = {
          known <- sum(Status != NO_BM)
          if (known > 0) sprintf("%.0f%%", 100 * sum(Status %in% ok) / known) else "-"
        },
        `Median score` = median(Score, na.rm = TRUE),
        .groups = "drop"
      )
    out <- left_join(select(extra, Measure, Students), cnt, by = "Measure") |>
      left_join(select(extra, Measure, pct, `Median score`), by = "Measure")
    names(out)[names(out) == "pct"] <- if (length(ok)) paste0("% ", ok[1], " or higher") else "%"
    
    r <- tryCatch(rules(), error = function(e) default_rules)
    r <- r |> mutate(MKey = mkey(Measure))
    out$MKey <- mkey(out$Measure)
    
    out <- out |>
      left_join(select(r, MKey, FullSkill = Skill), by = "MKey") |>
      mutate(Skill = coalesce(FullSkill, as.character(Measure))) |>
      select(-MKey, -FullSkill, -Measure) |>
      select(Skill, everything())
    
    out
  })
  
  output$scrSummary <- renderTable(summaryData(), digits = 0)
  output$dlSummary <- downloadHandler(
    filename = function() paste0("class-summary-", input$scrPeriod, "-", Sys.Date(), ".csv"),
    content = function(file) write.csv(summaryData(), file, row.names = FALSE, na = "")
  )

  overviewData <- reactive({
    d <- cur()
    validate(need(nrow(d) > 0, "No scores for this selection."))
    ms <- measure_order(d$Measure)
    w <- overview_table(d)
    w[, c("Student", "Class", "Grade", "Skills needing support", ms, paste0(ms, "__status"))] |>
      arrange(desc(`Skills needing support`), Student)
  })

  output$scrOverview <- renderDT({
    w <- overviewData()
    st_cols <- grep("__status$", names(w), value = TRUE)
    ms <- sub("__status$", "", st_cols)
    dt(
      w,
      opts = list(
        columnDefs = list(list(visible = FALSE, targets = match(st_cols, names(w)) - 1))
      )
    ) |>
      formatStyle(ms, valueColumns = st_cols, backgroundColor = status_style())
  }, server = FALSE)

  output$dlOverview <- downloadHandler(
    filename = function() paste0("class-overview-", input$scrPeriod, "-", Sys.Date(), ".csv"),
    content = function(file) {
      w <- overviewData()
      names(w) <- sub("__status$", " level", names(w))
      write.csv(w, file, row.names = FALSE, na = "")
    }
  )

  # ---- Find students ----------------------------------------------------------
  grp <- reactive({
    d <- cur()
    if (length(input$grpMeasure)) d <- filter(d, Measure %in% input$grpMeasure)
    d |>
      filter(Status %in% input$grpStatus) |>
      mutate(Measure = factor(Measure, levels = measure_order(Measure))) |>
      arrange(Measure, Score) |>
      transmute(Student, Class, Grade, Skill = as.character(Measure), Score,
                Level = as.character(Status), `On-track score` = Goal, `Points from on-track` = Gap)
  })

  output$grpCount <- renderText({
    g <- grp()
    sprintf("%d result(s) for %d student(s) in %s.", nrow(g), n_distinct(g$Student), input$scrPeriod)
  })

  output$grpTable <- renderDT({
    dt(grp()) |>
      formatStyle("Level", backgroundColor = status_style())
  }, server = FALSE)

  output$dlGroup <- downloadHandler(
    filename = function() paste0("student-list-", input$scrPeriod, "-", Sys.Date(), ".csv"),
    content = function(file) write.csv(grp(), file, row.names = FALSE, na = "")
  )

  # ---- Progress ---------------------------------------------------------------
  prog <- reactive({
    req(input$prMeasure, input$prFrom, input$prTo)
    lv <- levelsR()
    d <- filter(filt(), Measure == input$prMeasure)
    keys <- c("Student", "Class", "Grade")
    a <- d |> filter(Period == input$prFrom) |>
      transmute(across(all_of(keys)), From = Score, FromStatus = as.character(Status))
    b <- d |> filter(Period == input$prTo) |>
      transmute(across(all_of(keys)), To = Score, ToStatus = as.character(Status))
    full_join(a, b, by = keys) |>
      mutate(
        Change = To - From,
        step = match(ToStatus, lv) - match(FromStatus, lv),
        Movement = case_when(is.na(step) ~ "-", step > 0 ~ "Moved up",
                             step < 0 ~ "Moved down", TRUE ~ "Same level")
      ) |>
      select(-step) |>
      arrange(Change)
  })

  progNamed <- reactive({
    p <- prog()
    names(p)[names(p) == "From"] <- paste(input$prFrom, "score")
    names(p)[names(p) == "FromStatus"] <- paste(input$prFrom, "level")
    names(p)[names(p) == "To"] <- paste(input$prTo, "score")
    names(p)[names(p) == "ToStatus"] <- paste(input$prTo, "level")
    p
  })

  output$prSummary <- renderTable({
    p <- prog()
    req(nrow(p) > 0)
    ok <- atOrAboveR()
    pct <- function(s) {
      s <- s[!is.na(s) & s != NO_BM]
      if (length(s)) sprintf("%.0f%%", 100 * mean(s %in% ok)) else "-"
    }
    tibble(
      `Students with both scores` = sum(!is.na(p$Change)),
      `Average change` = sprintf("%+.1f", mean(p$Change, na.rm = TRUE)),
      `Moved up a level` = sum(p$Movement == "Moved up"),
      `Same level` = sum(p$Movement == "Same level"),
      `Moved down a level` = sum(p$Movement == "Moved down"),
      `% on track (from)` = pct(p$FromStatus),
      `% on track (to)` = pct(p$ToStatus)
    )
  })

  output$prTable <- renderDT({
    p <- progNamed()
    dt(p) |>
      formatStyle(unique(grep(" level$", names(p), value = TRUE)), backgroundColor = status_style()) |>
      formatStyle("Movement", fontWeight = styleEqual(c("Moved up", "Moved down"), c("bold", "bold")))
  }, server = FALSE)

  output$dlProgress <- downloadHandler(
    filename = function() paste0("progress-", input$prMeasure, "-", Sys.Date(), ".csv"),
    content = function(file) write.csv(progNamed(), file, row.names = FALSE, na = "")
  )

  # ---- Recommendations --------------------------------------------------------
  recStudents <- reactive({
    d <- cur()
    validate(need(nrow(d) > 0, "No scores for this selection."))
    lv <- levelsR()
    keys <- c("Student", "Class", "Grade")
    flagged <- student_needs(d, rules()) |>
      group_by(across(all_of(keys))) |>
      summarise(
        `Primary focus` = first(Skill), `Level on that skill` = first(Tier),
        Order = first(Order),
        `All skills below on-track` = paste(sprintf("%s (%s)", Measure, Score), collapse = ", "),
        .groups = "drop"
      )
    others <- d |>
      group_by(across(all_of(keys))) |>
      summarise(known = any(Status != NO_BM), .groups = "drop") |>
      anti_join(flagged, by = keys) |>
      transmute(
        across(all_of(keys)),
        `Primary focus` = ifelse(known, "None flagged", "Unknown"),
        `Level on that skill` = ifelse(known, "On track", "-"), Order = 999L,
        `All skills below on-track` = ""
      )
    bind_rows(flagged, others) |>
      arrange(Order, match(`Level on that skill`, c(lv, "On track", "-")), Student)
  })

  recGroups <- reactive({
    lv <- levelsR()
    recStudents() |>
      filter(Order < 999) |>
      group_by(Order, `Primary focus`, `Level on that skill`) |>
      summarise(`# students` = n(), Students = paste(Student, collapse = ", "), .groups = "drop") |>
      arrange(Order, match(`Level on that skill`, lv)) |>
      select(`Primary focus`, `Level on that skill`, `# students`, Students)
  })

  tier_style <- reactive({
    f <- sty()$fill
    t <- targetR()
    styleEqual(c(names(f), "On track"), c(unname(f), if (is.null(t)) "#EDEDED" else f[[t]]))
  })

  output$recGroups <- renderDT({
    g <- recGroups()
    validate(need(nrow(g) > 0, "No students are below the on-track level for this selection."))
    dt(g, opts = list(dom = "Bt", pageLength = 100, ordering = FALSE)) |>
      formatStyle("Level on that skill", backgroundColor = tier_style())
  }, server = FALSE)

  output$recStudents <- renderDT({
    dt(select(recStudents(), -Order)) |>
      formatStyle("Level on that skill", backgroundColor = tier_style())
  }, server = FALSE)

  # The teaching order currently in use, shown above the tables
  output$recOrder <- renderUI({
    div(
      class = "note",
      style = "background-color: #f8f9fa; border: 1px solid #e9ecef; padding: 10px 14px; border-radius: 4px; margin-bottom: 12px;",
      strong("Teaching order in use:"),
      tags$ul(
        style = "margin-bottom: 0; padding-left: 20px;",
        tags$li(strong("Auditory / Oral: "), "Initial sound awareness → Phonemic awareness"),
        tags$li(strong("Print / Decoding: "), "Letter names → Letter sounds → Letter-sound correspondence and decoding → Word reading"),
        tags$li(strong("Text-Level Reading: "), "Reading accuracy → Reading fluency → Reading comprehension")
      )
    )
  })

  output$dlRec <- downloadHandler(
    filename = function() paste0("recommendations-", input$scrPeriod, "-", Sys.Date(), ".csv"),
    content = function(file) write.csv(select(recStudents(), -Order), file, row.names = FALSE, na = "")
  )

  # ---- Graphs -----------------------------------------------------------------
  goal_marks <- function(d) {
    bm <- d |> filter(is.finite(Goal)) |> distinct(Grade, Period, Measure, Goal)
    if (nrow(bm) == 0) return(NULL)
    geom_errorbar(data = bm, aes(x = Period, ymin = Goal, ymax = Goal), inherit.aes = FALSE,
                  width = 0.55, linetype = "dashed", linewidth = 0.8, colour = "grey20")
  }
  goal_note <- function() {
    t <- targetR()
    if (is.null(t)) "" else sprintf("Dashed line = lowest \"%s\" score.", t)
  }
  grade_facet <- function(d) {
    if (n_distinct(d$Grade) > 1) facet_wrap(~Grade, labeller = label_both) else NULL
  }
  status_points <- function(size = 3.2, ...) {
    geom_point(aes(fill = Status, shape = Status), size = size, colour = "grey20", stroke = 0.4, ...)
  }

  scrPlotObj <- reactive({
    validate(need(!is.null(scr()), "Upload a scores file or load a demo to see graphs."))
    type <- input$scrGraph
    pct <- isTRUE(input$grPct)
    stack_pos <- function(vjust = 1) {
      if (pct) position_fill(vjust = vjust, reverse = TRUE) else position_stack(vjust = vjust, reverse = TRUE)
    }
    y_scale <- if (pct) {
      scale_y_continuous("Share of students", labels = function(x) paste0(round(100 * x), "%"))
    } else {
      scale_y_continuous("Number of students", breaks = function(l) unique(round(pretty(l))))
    }

    if (type == "status") {
      d <- cur() |> count(Measure, Status) |>
        mutate(Measure = factor(Measure, levels = measure_order(Measure)))
      validate(need(nrow(d) > 0, "No scores for this selection."))
      ggplot(d, aes(Measure, n, fill = Status)) +
        geom_col(position = stack_pos(), colour = "white", linewidth = 0.8, width = 0.7) +
        geom_text(aes(label = n), position = stack_pos(0.5), size = 4.5, colour = "grey10") +
        scale_fill_manual(values = sty()$cols) + y_scale +
        labs(title = paste("Students at each level -", input$scrPeriod), x = NULL) +
        base_theme

    } else if (type == "heat") {
      d <- cur()
      validate(need(nrow(d) > 0, "No scores for this selection."))
      ord <- d |> group_by(Student) |>
        summarise(f = sum(Flag), .groups = "drop") |>
        arrange(f, desc(Student))
      d <- d |> mutate(Student = factor(Student, levels = ord$Student),
                       Measure = factor(Measure, levels = measure_order(Measure)))
      ggplot(d, aes(Measure, Student, fill = Status)) +
        geom_tile(colour = "white", linewidth = 1.2) +
        geom_text(aes(label = Score), size = 4, colour = "grey10") +
        scale_fill_manual(values = sty()$fill) +
        scale_x_discrete(position = "top") +
        labs(title = paste("Whole-class colour chart -", input$scrPeriod), x = NULL, y = NULL,
             caption = "Students with the most skills below the on-track level are at the top.") +
        base_theme + theme(panel.grid = element_blank())

    } else if (type == "time") {
      d <- filt() |> count(Measure, Period, Status) |>
        mutate(Measure = factor(Measure, levels = measure_order(Measure)))
      validate(need(nrow(d) > 0, "No scores for this selection."))
      ggplot(d, aes(Period, n, fill = Status)) +
        geom_col(position = stack_pos(), colour = "white", linewidth = 0.8, width = 0.7) +
        geom_text(aes(label = n), position = stack_pos(0.5), size = 4, colour = "grey10") +
        facet_wrap(~Measure) +
        scale_fill_manual(values = sty()$cols) + y_scale +
        labs(title = "Class levels across the year", x = NULL) +
        base_theme

    } else if (type %in% c("growth", "dist", "dumbbell")) {
      req(input$grMeasure)
      d <- filt() |> filter(Measure == input$grMeasure, !is.na(Score)) |>
        mutate(Period = droplevels(Period))
      validate(need(nrow(d) > 0, "No scores for this measure."))

      if (type == "growth") {
        p <- ggplot(d, aes(Period, Score, group = Student)) +
          geom_line(colour = "grey55", alpha = 0.7, linewidth = 0.7) +
          goal_marks(d) + status_points()
        if (isTRUE(input$grNames)) {
          last <- d |> group_by(Student) |> slice_max(as.integer(Period), n = 1) |> ungroup()
          p <- p + geom_text(data = last, aes(label = Student), hjust = -0.15, size = 3.3,
                             colour = "grey25", check_overlap = TRUE) +
            scale_x_discrete(expand = expansion(mult = c(0.1, 0.35)))
        }
        p + status_scales() + grade_facet(d) +
          labs(title = paste("Student growth -", input$grMeasure), x = NULL,
               caption = paste("Each line is one student.", goal_note())) +
          base_theme

      } else if (type == "dist") {
        ggplot(d, aes(Period, Score)) +
          geom_boxplot(outlier.shape = NA, fill = "grey95", colour = "grey55", width = 0.5) +
          goal_marks(d) +
          status_points(position = position_jitter(width = 0.13, height = 0, seed = 1)) +
          status_scales() + grade_facet(d) +
          labs(title = paste("Spread of class scores -", input$grMeasure), x = NULL,
               caption = paste("Each point is one student.", goal_note())) +
          base_theme

      } else {
        pl <- levels(d$Period)
        validate(need(length(pl) >= 2, "This graph needs scores from at least two periods."))
        first <- pl[1]
        last <- pl[length(pl)]
        a <- d |> filter(Period == first) |> select(Student, From = Score)
        b <- d |> filter(Period == last) |> select(Student, Grade, To = Score, Status, Goal)
        w <- inner_join(a, b, by = "Student") |> arrange(To)
        validate(need(nrow(w) > 0, "No students have scores in both periods."))
        w$Student <- factor(w$Student, levels = unique(w$Student))
        goal <- unique(w$Goal[is.finite(w$Goal)])
        ggplot(w, aes(y = Student)) +
          (if (length(goal) == 1) geom_vline(xintercept = goal, linetype = "dashed", colour = "grey20")) +
          geom_segment(aes(x = From, xend = To, yend = Student), colour = "grey50", linewidth = 0.9,
                       arrow = arrow(length = unit(0.16, "cm"), type = "closed")) +
          geom_point(aes(x = From), size = 2.4, colour = "grey50") +
          geom_point(aes(x = To, fill = Status, shape = Status), size = 3.6, colour = "grey20", stroke = 0.4) +
          status_scales() +
          labs(title = sprintf("%s: %s to %s", input$grMeasure, first, last), x = "Score", y = NULL,
               caption = sprintf("Grey dot = %s score; coloured marker = %s score and level. %s", first, last,
                                 if (length(goal) == 1) goal_note() else "")) +
          base_theme
      }

    } else {
      req(input$grStudent)
      d <- filt() |> filter(Student == input$grStudent, !is.na(Score)) |>
        mutate(Measure = factor(Measure, levels = measure_order(Measure)))
      validate(need(nrow(d) > 0, "No scores for this student."))
      ggplot(d, aes(Period, Score, group = 1)) +
        geom_line(colour = "grey55", linewidth = 0.8) +
        goal_marks(d) + status_points(size = 4) +
        geom_text(aes(label = Score), vjust = -1.3, size = 4, colour = "grey10") +
        facet_wrap(~Measure, scales = "free_y") +
        scale_y_continuous(expand = expansion(mult = c(0.2, 0.3))) +
        scale_x_discrete(drop = FALSE) +
        status_scales() +
        labs(title = paste("Student report -", input$grStudent), x = NULL, caption = goal_note()) +
        base_theme
    }
  })

  scrPlotHeight <- reactive({
    if (is.null(scr())) return(300)
    n <- n_distinct(filt()$Student)
    if (input$scrGraph %in% c("heat", "dumbbell")) max(420, 26 * n + 140) else 540
  })

  output$scrPlot <- renderPlot(scrPlotObj(), height = function() scrPlotHeight())

  output$dlScrPlot <- downloadHandler(
    filename = function() paste0("screening-", input$scrGraph, "-", Sys.Date(), ".png"),
    content = function(file) {
      ggsave(file, scrPlotObj(), width = 11, height = scrPlotHeight() / 75, dpi = 150, bg = "white")
    }
  )

  # ===========================================================================
  # INDIVIDUAL PROGRESS MONITORING
  # ===========================================================================
  AllInputs <- reactiveVal(tibble())
  indDemoOn <- reactiveVal(FALSE)

  observeEvent(input$indDemo, {
    AllInputs(demo_individual())
    values$currentStrategy <- "Task Analysis"
    indDemoOn(TRUE)
    updateSelectInput(session, "Strategy", selected = "Task Analysis")
    updateTabsetPanel(session, "mainTabset", selected = "Graph")
  })

  output$indBanner <- renderUI({
    if (indDemoOn()) {
      div(class = "banner", strong("Demo mode. "), "A made-up student learning to wash hands (Task Analysis, 8 steps, 8 sessions). Try the graph types, then click 'Start over' to begin your own data sheet.")
    }
  })
  values <- reactiveValues(currentStrategy = NULL)

  observeEvent(input$importData, {
    tryCatch({
      d <- as_tibble(read_upload(input$importData$datapath))
      if (!"Key" %in% names(d)) stop("This file has no 'Key' column - upload a file downloaded from the Data tab.")
      AllInputs(d)
      values$currentStrategy <- NULL
      indDemoOn(FALSE)
    }, error = notify_error)
  })

  observeEvent(input$Strategy, {
    if (input$Strategy == "Select") return()
    if (!is.null(values$currentStrategy) && input$Strategy != values$currentStrategy &&
        ncol(AllInputs()) > 0) {
      showModal(modalDialog(
        title = "Warning",
        "Switching strategy clears the current data sheet. Download your data from the 'Data' tab first if you need it.",
        footer = tagList(
          actionButton("cancelSwitch", "Cancel"),
          actionButton("confirmSwitch", "Clear and switch", class = "btn btn-primary")
        )
      ))
    }
  }, ignoreInit = TRUE)

  observeEvent(input$cancelSwitch, {
    updateSelectInput(session, "Strategy", selected = values$currentStrategy)
    removeModal()
  })
  observeEvent(input$confirmSwitch, {
    AllInputs(tibble())
    indDemoOn(FALSE)
    values$currentStrategy <- NULL
    removeModal()
  })
  observeEvent(input$clearData, {
    AllInputs(tibble())
    indDemoOn(FALSE)
    values$currentStrategy <- NULL
  })

  observeEvent(input$Generate, {
    if (input$Strategy == "Select") {
      showNotification("Choose a strategy first.", type = "warning")
      return()
    }
    fields <- strategy_defs[[input$Strategy]]$fields
    vals <- vapply(fields, function(k) {
      as.character(input[[field_id(input$Strategy, k)]] %||% "")
    }, character(1), USE.NAMES = FALSE)
    cur_data <- AllInputs()
    if (ncol(cur_data) == 0) {
      AllInputs(tibble(Key = fields, Value = vals))
    } else if (nrow(cur_data) != length(vals)) {
      showNotification("The current data sheet belongs to a different strategy. Clear it or choose the matching strategy.",
                       type = "error", duration = 10)
      return()
    } else {
      cur_data[[paste0("Date.", ncol(cur_data) - 1)]] <- vals
      AllInputs(cur_data)
    }
    values$currentStrategy <- input$Strategy
  })

  output$show_inputs <- renderTable(AllInputs(), na = "")

  output$downloadData <- downloadHandler(
    filename = function() paste0("progress-monitoring-", Sys.Date(), ".csv"),
    content = function(file) write.csv(AllInputs(), file, row.names = FALSE, na = "")
  )

  correct_codes <- reactive({
    codes <- trimws(strsplit(input$correctCodes %||% "", ",")[[1]])
    codes[codes != ""]
  })

  # Scored response rows in long form: one row per step/trial x session
  responses <- reactive({
    d <- AllInputs()
    validate(need(ncol(d) > 2, "No session data yet. Add a session column (or upload a file that has them) to see a graph."))
    sess <- names(d)[-(1:2)]
    d[!(d$Key %in% setup_keys), c("Key", sess), drop = FALSE] |>
      mutate(across(all_of(sess), as.character)) |>
      pivot_longer(all_of(sess), names_to = "Session", values_to = "Response") |>
      mutate(
        Response = trimws(Response),
        Session = factor(Session, levels = sess),
        Key = factor(Key, levels = rev(unique(d$Key)))
      ) |>
      filter(!is.na(Response), Response != "") |>
      mutate(Result = ifelse(Response %in% correct_codes(), "Independent/correct", "Other response"))
  })

  sessionScores <- reactive({
    responses() |>
      group_by(Session, .drop = FALSE) |>
      summarise(Correct = sum(Result == "Independent/correct"), Total = n(), .groups = "drop") |>
      mutate(Percent = ifelse(Total > 0, 100 * Correct / Total, NA_real_))
  })

  session_label <- function(x) sub("^Date\\.", "", x)
  result_cols <- c("Independent/correct" = "#3FA34D", "Other response" = "#B8B8B8")

  indPlotObj <- reactive({
    s <- sessionScores()
    type <- input$indGraph
    title <- "Student's Progress Monitoring"

    if (type == "grid") {
      r <- droplevels(responses())
      validate(need(nrow(r) > 0, "No responses recorded yet."))
      return(
        ggplot(r, aes(Session, Key, fill = Result)) +
          geom_tile(colour = "white", linewidth = 1.2) +
          geom_text(aes(label = Response), size = 4, colour = "grey10") +
          scale_fill_manual(values = c("Independent/correct" = "#B4E0B0", "Other response" = "#EDEDED")) +
          scale_x_discrete(labels = session_label, position = "top", drop = FALSE) +
          labs(title = title, x = "Session", y = NULL) +
          base_theme + theme(panel.grid = element_blank())
      )
    }

    if (type == "stack") {
      long <- s |>
        transmute(Session, `Independent/correct` = Correct, `Other response` = Total - Correct) |>
        pivot_longer(-Session, names_to = "Result", values_to = "n") |>
        mutate(Result = factor(Result, levels = names(result_cols)))
      return(
        ggplot(long, aes(Session, n, fill = Result)) +
          geom_col(position = position_stack(reverse = TRUE), colour = "white", linewidth = 0.8, width = 0.6) +
          (if (isTRUE(input$showLabels)) geom_text(
            data = filter(long, n > 0), aes(label = n),
            position = position_stack(vjust = 0.5, reverse = TRUE), size = 4.5, colour = "grey10")) +
          scale_fill_manual(values = result_cols) +
          scale_x_discrete(labels = session_label) +
          scale_y_continuous(breaks = function(l) unique(round(pretty(l)))) +
          labs(title = title, x = "Session", y = "Number of responses") +
          base_theme
      )
    }

    p <- ggplot(s, aes(Session, Percent, group = 1)) +
      switch(type,
        bar = list(geom_col(fill = accent, width = 0.6)),
        line = list(geom_line(colour = accent, linewidth = 1, na.rm = TRUE),
                    geom_point(colour = accent, size = 3.5, na.rm = TRUE)),
        area = list(geom_area(fill = accent, alpha = 0.3, na.rm = TRUE),
                    geom_line(colour = accent, linewidth = 1, na.rm = TRUE),
                    geom_point(colour = accent, size = 3, na.rm = TRUE)),
        lollipop = list(geom_segment(aes(xend = Session, y = 0, yend = Percent),
                                     colour = accent, linewidth = 1, na.rm = TRUE),
                        geom_point(colour = accent, size = 5, na.rm = TRUE))
      )
    if (isTRUE(input$showTrend) && sum(!is.na(s$Percent)) >= 3) {
      p <- p + geom_smooth(method = "lm", formula = y ~ x, se = FALSE, na.rm = TRUE,
                           colour = "grey25", linetype = "dotted", linewidth = 0.9)
    }
    if (isTRUE(input$showGoal) && isTruthy(input$goalPercentage)) {
      p <- p +
        geom_hline(yintercept = input$goalPercentage, colour = "black") +
        annotate("text", x = Inf, y = input$goalPercentage, label = "Goal",
                 hjust = 1.1, vjust = -0.5, size = 4.5)
    }
    if (isTRUE(input$showLabels)) {
      p <- p + geom_text(data = filter(s, !is.na(Percent)),
                         aes(label = paste0(round(Percent), "%")),
                         vjust = -0.9, size = 4.2, colour = "grey10")
    }
    p +
      scale_x_discrete(labels = session_label) +
      scale_y_continuous(breaks = seq(0, 100, 20)) +
      coord_cartesian(ylim = c(0, 108)) +
      labs(title = title, x = "Session", y = "Independent/Correct Response (%)") +
      base_theme
  })

  output$result <- renderPlot(indPlotObj())

  output$dlIndPlot <- downloadHandler(
    filename = function() paste0("progress-graph-", Sys.Date(), ".png"),
    content = function(file) ggsave(file, indPlotObj(), width = 10, height = 6, dpi = 150, bg = "white")
  )

  sessionSummary <- reactive({
    sessionScores() |>
      transmute(Session = session_label(as.character(Session)),
                `Correct (independent)` = Correct, `Steps recorded` = Total,
                `% correct` = round(Percent))
  })
  output$sessionTable <- renderTable(sessionSummary(), digits = 0)
  output$dlSessions <- downloadHandler(
    filename = function() paste0("session-summary-", Sys.Date(), ".csv"),
    content = function(file) write.csv(sessionSummary(), file, row.names = FALSE, na = "")
  )
})
