library(shiny)
library(shinythemes)
library(dplyr)
library(tidyr)
library(tibble)
library(ggplot2)
library(DT)

`%||%` <- function(a, b) if (is.null(a)) b else a

# =============================================================================
# PART 1 - Individual progress monitoring (systematic instruction strategies)
# =============================================================================

prompt_choices <- c(
  "", "Verbal(V)", "Visual(VS)", "Gesture(G)", "Model(M)",
  "Partial Physical(PP)", "Full Physical(FP)"
)

# Fields rendered as a prompt drop-down instead of a text box
prompt_fields <- c(
  "First Prompt", "Second Prompt", "Third Prompt", "Response Prompt",
  "Back-up Prompt", "Simultaneous Prompt", "Corrective Prompt"
)

td_items <- as.vector(outer(1:5, 1:5, function(i, t) sprintf("Item %d (Trial %d)", i, t)))

# One entry per strategy. `fields` are the rows of the data sheet (the "Key"
# column of the CSV), in order. To add a strategy, add an entry here.
strategy_defs <- list(
  "Task Analysis" = list(
    id = "TA",
    fields = c("Objective", "Task Demand", "First Prompt", "Second Prompt",
               "Third Prompt", "Latency", paste("Step", 1:20)),
    defaults = list("Task Demand" = "S, make a PB sandwich", "Latency" = "3 sec")
  ),
  "Time Delay" = list(
    id = "TD",
    fields = c("Objective", "Task Demand", "Delay", "Response Prompt",
               "Time Delay Schedule", "Back-up Prompt", "Latency", td_items),
    defaults = c(
      list("Task Demand" = "S, point to the [ ] picture"),
      setNames(as.list(rep(c("pen", "book", "desk"), 3)),
               as.vector(outer(1:3, 1:3, function(i, t) sprintf("Item %d (Trial %d)", i, t))))
    )
  ),
  "Errorless Learning" = list(
    id = "EL",
    fields = c("Objective", "Task Demand", "First Prompt", "Second Prompt",
               "Third Prompt", "Latency", paste("Step", 1:20)),
    defaults = list("Task Demand" = "S, make a PB sandwich")
  ),
  "Simultaneous Prompting" = list(
    id = "SP",
    fields = c("Objective", "Task Demand", "Simultaneous Prompt",
               "Corrective Prompt", "Latency",
               paste("Prompt Trial", 1:10), paste("Test Probe Trial", 1:5)),
    defaults = list("Task Demand" = "Turn on TV with a remote control")
  ),
  "Customized (50 max)" = list(
    id = "CU",
    fields = paste("Input", 1:50),
    defaults = list()
  )
)

field_id <- function(strategy, key) {
  paste0("f_", strategy_defs[[strategy]]$id, "_", gsub("[^A-Za-z0-9]", "_", key))
}

# Rows that describe the programme rather than a scored response. Prompt trials
# in Simultaneous Prompting are excluded: only the test probes are scored.
setup_keys <- c(
  "Strategy", "Objective", "Task Demand", "Delay", "Latency",
  "Time Delay Schedule", prompt_fields,
  paste("Prompt", 1:10), paste("Prompt Trial", 1:10)
)

strategy_panel <- function(name) {
  def <- strategy_defs[[name]]
  conditionalPanel(
    condition = sprintf("input.Strategy == '%s'", name),
    lapply(def$fields, function(k) {
      id <- field_id(name, k)
      if (k %in% prompt_fields) {
        selectInput(id, k, choices = prompt_choices)
      } else {
        textInput(id, k, value = def$defaults[[k]] %||% "")
      }
    })
  )
}

# =============================================================================
# PART 2 - Class screening for ANY assessment
# Nothing here is tied to one screener. The measures, the number of levels and
# the level names all come from the cut-score file the user uploads.
# =============================================================================

NO_BM <- "No level"

# Key used to match measure names between files ("Letter Sounds" == "letter-sounds")
mkey <- function(x) toupper(gsub("[^A-Za-z0-9]", "", as.character(x)))

# Which level counts as "on track"? Guess from the name, otherwise the top
# level (2-3 levels) or the second-highest (4+ levels). The user can override.
default_target <- function(lv) {
  if (length(lv) == 0) return(NULL)
  hit <- grep("^at benchmark|^at grade|^at level|^at expect|^at or|^at$|on.?track|^meet|proficient|^benchmark|low risk|^core",
              tolower(lv))
  if (length(hit)) return(lv[hit[1]])
  if (length(lv) >= 4) lv[length(lv) - 1] else lv[length(lv)]
}

# Colours and point shapes for a set of levels (ordered lowest -> highest).
# Levels below the on-track level are warm (red -> yellow), the on-track level
# is green, levels above it are blue. Charts never rely on colour alone: they
# also carry labels, a legend and distinct point shapes.
level_style <- function(lv, target) {
  ramp <- function(pal, k) {
    if (k == 0) character(0)
    else if (k == 1) pal[1]
    else if (k == 2) pal[c(1, length(pal))]
    else colorRampPalette(pal)(k)
  }
  n <- length(lv)
  t <- if (n == 0) 0 else match(target, lv)
  nb <- max(t - 1, 0)
  na <- max(n - t, 0)
  mid <- if (n == 0) character(0) else "#3FA34D"
  mid_f <- if (n == 0) character(0) else "#B4E0B0"
  list(
    cols = setNames(c(ramp(c("#D9534F", "#E8853A", "#E0A800"), nb), mid,
                      ramp(c("#3B8BD4", "#3A2E8C"), na), "#B8B8B8"), c(lv, NO_BM)),
    fill = setNames(c(ramp(c("#F6B6B1", "#F9CDA6", "#FBE38E"), nb), mid_f,
                      ramp(c("#A9D0F2", "#B9B2E6"), na), "#EDEDED"), c(lv, NO_BM)),
    shapes = setNames(c(if (nb > 0) c(25, rep(24, nb - 1)), if (n > 0) 21,
                        rep(23, na), 22), c(lv, NO_BM))
  )
}

# ---- Teaching order for "Primary focus" ---------------------------------------
# Each row links a measure name to the skill it indicates. ROW ORDER is the
# teaching order, most foundational skill first: a student's primary focus is
# the earliest skill in this list on which they are below the on-track level.
# Users can replace this by uploading their own skill-order CSV in the app.
default_rules <- tribble(
  ~Measure,  ~Skill,
  "LNF",     "Letter Naming Fluency",
  "LSF",     "Letter Sound Fluency",
  "FSF",     "First Sound Fluency",
  "PSF",     "Phoneme Segmentation Fluency",
  "NWF",     "Nonsense Word Fluency",
  "WRF",     "Word Reading Fluency",
  "ORF-ACC", "Oral Reading Fluency - Accuracy",
  "ORF",     "Oral Reading Fluency",
  "MAZE",    "Maze (Comprehension)"
)

# ---- Normalising uploaded data ----------------------------------------------

norm_grade <- function(x) {
  x <- toupper(trimws(as.character(x)))
  out <- ifelse(grepl("^K", x) | x == "0", "K", gsub("\\D", "", x))
  ifelse(is.na(x) | out == "", NA_character_, out)
}

norm_period <- function(x) {
  x <- trimws(as.character(x))
  l <- tolower(x)
  case_when(
    grepl("^(boy|beg|fall)", l) ~ "BOY",
    grepl("^(moy|mid|winter)", l) ~ "MOY",
    grepl("^(eoy|end|spring)", l) ~ "EOY",
    TRUE ~ x
  )
}

period_levels <- function(x) {
  x <- unique(as.character(x))
  c(intersect(c("BOY", "MOY", "EOY"), x), setdiff(x, c("BOY", "MOY", "EOY")))
}

find_col <- function(df, alts) {
  i <- match(TRUE, tolower(names(df)) %in% alts)
  if (is.na(i)) NULL else names(df)[i]
}

read_upload <- function(path) {
  df <- read.csv(path, header = TRUE, stringsAsFactors = FALSE,
                 check.names = FALSE, fileEncoding = "UTF-8-BOM")
  names(df) <- trimws(names(df))
  df
}

# Scores. Accepts either layout and returns one row per student x period x measure:
#   wide: Student, Grade, Class, Period, then one column per measure (any names)
#   long: Student, Grade, Class, Period, Measure, Score [, Status]
standardise_screening <- function(df) {
  c_student <- find_col(df, c("student", "student name", "name", "student id", "id"))
  c_period  <- find_col(df, c("period", "time", "benchmark period", "season", "assessment period"))
  c_grade   <- find_col(df, c("grade", "grade level"))
  c_class   <- find_col(df, c("class", "teacher", "classroom", "division", "homeroom"))
  c_measure <- find_col(df, c("measure", "subtest", "skill"))
  c_score   <- find_col(df, c("score", "raw score", "result"))
  c_status  <- find_col(df, c("status", "benchmark status", "level", "risk"))

  if (is.null(c_student)) stop("The scores file needs a 'Student' column.")
  if (is.null(c_period)) stop("The scores file needs a 'Period' column (e.g., BOY, MOY, EOY).")

  base <- tibble(
    Student = trimws(as.character(df[[c_student]])),
    Class   = if (is.null(c_class)) "All" else trimws(as.character(df[[c_class]])),
    Grade   = if (is.null(c_grade)) NA_character_ else norm_grade(df[[c_grade]]),
    Period  = norm_period(df[[c_period]])
  )

  if (!is.null(c_measure) && !is.null(c_score)) {
    out <- base |>
      mutate(
        Measure = trimws(as.character(df[[c_measure]])),
        Score = suppressWarnings(as.numeric(as.character(df[[c_score]]))),
        GivenStatus = if (is.null(c_status)) NA_character_ else na_if(trimws(as.character(df[[c_status]])), "")
      )
  } else {
    id_cols <- c(c_student, c_period, c_grade, c_class, c_status,
                 find_col(df, c("school")), find_col(df, c("date")))
    mcols <- setdiff(names(df), id_cols)
    nums <- lapply(df[mcols], function(v) suppressWarnings(as.numeric(as.character(v))))
    nums <- nums[vapply(nums, function(v) any(!is.na(v)), logical(1))]
    if (length(nums) == 0) stop("No numeric score columns were found in the scores file.")
    out <- bind_cols(base, as_tibble(nums)) |>
      pivot_longer(all_of(names(nums)), names_to = "Measure", values_to = "Score") |>
      mutate(GivenStatus = NA_character_)
  }

  out |>
    filter(!is.na(Student), Student != "", !is.na(Period), Period != "",
           !is.na(Score) | !is.na(GivenStatus)) |>
    distinct(Student, Class, Grade, Period, Measure, .keep_all = TRUE)
}

# Cut scores. Columns: [Grade], [Period], Measure, then ONE COLUMN PER LEVEL,
# ordered lowest -> highest. The header is the level name and each cell is the
# LOWEST score that earns that level (so the first level is usually 0).
# Grade and Period are optional: leave a column out if the cuts don't vary by it.
# Returns list(levels, cuts) where cuts has .cut1 ... .cutN.
standardise_screening <- function(df) {
  c_student <- find_col(df, c("student", "student name", "name", "student id", "id"))
  c_period  <- find_col(df, c("period", "time", "benchmark period", "season", "assessment period"))
  c_grade   <- find_col(df, c("grade", "grade level"))
  c_class   <- find_col(df, c("class", "teacher", "classroom", "division", "homeroom"))
  c_measure <- find_col(df, c("measure", "subtest", "skill"))
  c_score   <- find_col(df, c("score", "raw score", "result"))
  c_status  <- find_col(df, c("status", "benchmark status", "level", "risk"))
  
  if (is.null(c_student)) stop("The scores file needs a 'Student' column.")
  if (is.null(c_period)) stop("The scores file needs a 'Period' column (e.g., BOY, MOY, EOY).")
  
  base <- tibble(
    Student = trimws(as.character(df[[c_student]])),
    Class   = if (is.null(c_class)) "All" else trimws(as.character(df[[c_class]])),
    Grade   = if (is.null(c_grade)) NA_character_ else norm_grade(df[[c_grade]]),
    Period  = norm_period(df[[c_period]])
  )
  
  if (!is.null(c_measure) && !is.null(c_score)) {
    out <- base |>
      mutate(
        Measure = trimws(as.character(df[[c_measure]])),
        Score = suppressWarnings(as.numeric(as.character(df[[c_score]]))),
        GivenStatus = if (is.null(c_status)) NA_character_ else na_if(trimws(as.character(df[[c_status]])), "")
      )
  } else {
    id_cols <- c(c_student, c_period, c_grade, c_class, c_status,
                 find_col(df, c("school")), find_col(df, c("date")))
    mcols <- setdiff(names(df), id_cols)
    nums <- lapply(df[mcols], function(v) suppressWarnings(as.numeric(as.character(v))))
    nums <- nums[vapply(nums, function(v) any(!is.na(v)), logical(1))]
    if (length(nums) == 0) stop("No numeric score columns were found in the scores file.")
    out <- bind_cols(base, as_tibble(nums)) |>
      pivot_longer(all_of(names(nums)), names_to = "Measure", values_to = "Score") |>
      mutate(GivenStatus = NA_character_)
  }
  
  measure_order <- default_rules$Measure
  
  out |>
    filter(!is.na(Student), Student != "", !is.na(Period), Period != "",
           !is.na(Score) | !is.na(GivenStatus)) |>
    distinct(Student, Class, Grade, Period, Measure, .keep_all = TRUE) |>
    mutate(
      Measure = factor(Measure, levels = unique(c(measure_order, unique(Measure))))
    )
}

# Skill order file: Measure, Skill. Row order = teaching order (most foundational skill first). Any other columns are ignored.
standardise_rules <- function(df) {
  c_measure <- find_col(df, c("measure", "subtest"))
  if (is.null(c_measure)) stop("The skill-order file needs a 'Measure' column.")
  c_skill <- find_col(df, c("skill", "skill area", "area"))
  tibble(
    Measure = trimws(as.character(df[[c_measure]])),
    Skill = if (is.null(c_skill)) Measure else trimws(as.character(df[[c_skill]]))
  ) |> filter(Measure != "")
}

# When there is no cut-score file but the scores file has a Status column, use
# those statuses as the levels, ordered from lowest- to highest-scoring.
given_levels <- function(d) {
  g <- filter(d, !is.na(GivenStatus))
  if (nrow(g) == 0) return(character(0))
  g |>
    group_by(Measure) |>
    mutate(r = percent_rank(Score)) |>
    group_by(GivenStatus) |>
    summarise(r = mean(r, na.rm = TRUE), .groups = "drop") |>
    arrange(r) |>
    pull(GivenStatus)
}

# Adds Status (level), Goal (cut score of the on-track level), Gap and Flag
# (TRUE when the student is below the on-track level).
apply_benchmarks <- function(d, b, lv, target) {
  d$MKey <- mkey(d$Measure)
  t <- if (is.null(target)) NA_integer_ else match(target, lv)
  if (!is.null(b)) {
    by <- intersect(c("Grade", "Period", "MKey"), names(b$cuts))
    labels <- distinct(b$cuts, MKey, .keep_all = TRUE) |> select(MKey, BMeasure = Measure)
    d <- d |>
      left_join(select(b$cuts, -Measure), by = by) |>
      left_join(labels, by = "MKey") |>
      mutate(Measure = coalesce(BMeasure, Measure)) |>
      select(-BMeasure)
    cut_cols <- paste0(".cut", seq_along(lv))
    cm <- as.matrix(d[cut_cols])
    has_cut <- rowSums(!is.na(cm)) > 0
    ok <- !is.na(cm) & !is.na(d$Score) & d$Score >= cm
    idx <- apply(ok, 1, function(r) if (any(r)) max(which(r)) else 1L)
    idx[!has_cut | is.na(d$Score)] <- NA
    d$Status <- ifelse(is.na(idx), NO_BM, lv[idx])
    d$Goal <- if (is.na(t)) NA_real_ else unname(cm[, t])
    d <- d[setdiff(names(d), cut_cols)]
  } else {
    idx <- match(d$GivenStatus, lv)
    d$Status <- ifelse(is.na(idx), NO_BM, d$GivenStatus)
    d$Goal <- NA_real_
  }
  
  measure_order <- c("LNF", "LSF", "FSF", "PSF", "NWF", "WRF", "ORF-ACC", "ORF", "MAZE")
  
  d |>
    mutate(
      Measure = factor(Measure, levels = unique(c(measure_order, unique(as.character(Measure))))),
      Flag = !is.na(idx) & !is.na(t) & idx < t,
      Gap = Score - Goal,
      Status = factor(Status, levels = c(lv, NO_BM)),
      Period = factor(Period, levels = period_levels(Period))
    ) |>
    select(-MKey)
}

# ---- Templates and demo data --------------------------------------------------

screening_template <- function() {
  tibble(
    Student = c("Example Student A", "Example Student A", "Example Student B"),
    Grade = c("1", "1", "1"),
    Class = c("Div 3", "Div 3", "Div 3"),
    Period = c("BOY", "MOY", "BOY"),
    LNF = c(38, 47, 52), PSF = c(22, 35, 41), NWF = c(18, 40, 45),
    WRF = c(4, 12, 15), ORF = c(NA, 14, NA)
  )
}

# Blank cut-score templates. Values are deliberately empty: fill them in from
# the publisher's / ministry's official document for your assessment.
benchmark_template <- function(kind = "blank") {
  grid <- function(measures, grades) {
    bind_rows(lapply(names(measures), function(m) {
      expand.grid(Period = c("BOY", "MOY", "EOY"), Grade = measures[[m]],
                  stringsAsFactors = FALSE) |> mutate(Measure = m)
    })) |>
      mutate(Grade = factor(Grade, levels = grades)) |>
      arrange(Grade, Measure) |>
      transmute(Grade = as.character(Grade), Period, Measure)
  }
  if (kind == "elst") {
    g <- c("K", "1", "2", "3")
    ms <- c("LNF", "LSF", "FSF", "PSF", "NWF", "WRF", "ORF")
    out <- grid(setNames(rep(list(g), length(ms)), ms), g)
    lv <- c("Level 1 - rename (lowest)", "Level 2 - rename", "Level 3 - rename (highest)")
  } else {
    out <- tibble(Grade = c("1", "1"), Period = c("BOY", "BOY"),
                  Measure = c("Measure A", "Measure B"))
    lv <- c("Level 1 - rename (lowest)", "Level 2 - rename", "Level 3 - rename (highest)")
  }
  for (i in seq_along(lv)) out[[lv[i]]] <- if (i == 1) 0 else NA_real_
  out
}

# Cut scores. Columns: [Grade], [Period], Measure, then ONE COLUMN PER LEVEL,
# ordered lowest -> highest. The header is the level name and each cell is the
# LOWEST score that earns that level (so the first level is usually 0).
# Grade and Period are optional: leave a column out if the cuts don't vary by it.
# Returns list(levels, cuts) where cuts has .cut1 ... .cutN.
standardise_benchmarks <- function(df) {
  c_measure <- find_col(df, c("measure", "subtest", "skill"))
  if (is.null(c_measure)) stop("The cut-score file needs a 'Measure' column.")
  c_grade <- find_col(df, c("grade", "grade level"))
  c_period <- find_col(df, c("period", "time", "season", "benchmark period", "assessment period"))
  ignore <- c(find_col(df, c("assessment", "screener", "test")),
              find_col(df, c("notes", "note", "comment", "comments")))
  lcols <- setdiff(names(df), c(c_measure, c_grade, c_period, ignore))
  nums <- lapply(df[lcols], function(v) suppressWarnings(as.numeric(as.character(v))))
  nums <- nums[vapply(nums, function(v) any(!is.na(v)), logical(1))]
  if (length(nums) < 2) {
    stop("The cut-score file needs at least two level columns containing numbers (one column per level, lowest level first).")
  }
  lv <- names(nums)
  cuts <- tibble(Measure = trimws(as.character(df[[c_measure]])))
  if (!is.null(c_grade)) cuts$Grade <- norm_grade(df[[c_grade]])
  if (!is.null(c_period)) cuts$Period <- norm_period(df[[c_period]])
  cuts$MKey <- mkey(cuts$Measure)
  cuts <- bind_cols(cuts, setNames(as_tibble(nums), paste0(".cut", seq_along(lv))))
  cuts <- cuts[rowSums(!is.na(as.matrix(cuts[paste0(".cut", seq_along(lv))]))) >= 2, ]
  if (nrow(cuts) == 0) stop("No rows in the cut-score file have cut scores filled in yet.")
  cuts <- distinct(cuts, across(any_of(c("Grade", "Period", "MKey"))), .keep_all = TRUE)
  list(levels = lv, cuts = cuts)
}

# ILLUSTRATIVE cut scores for the two demos - NOT official values for any assessment.
demo_cuts <- function(kind = "three") {
  if (kind == "three") {
    df <- data.frame(
      Grade = "1",
      Period = rep(c("BOY", "MOY", "EOY"), times = 7),
      Measure = rep(c("LNF", "LSF", "FSF", "PSF", "NWF", "WRF", "ORF"), each = 3),
      `At Risk` = 0,
      `Some Risk` = c(
        28, 36, 45, # LNF
        18, 23, 28, # LSF
        14, 18, 22, # FSF
        21, 27, 34, # PSF
        21, 27, 34, # NWF
        7,  9,  11, # WRF
        7,  9,  11  # ORF
      ),
      `On Track` = c(
        40, 52, 64, # LNF
        25, 33, 40, # LSF
        20, 26, 32, # FSF
        30, 39, 48, # PSF
        30, 39, 48, # NWF
        10, 13, 16, # WRF
        10, 13, 16  # ORF
      ),
      check.names = FALSE
    )
  } else {
    df <- data.frame()
  }
  
  standardise_benchmarks(as.data.frame(df, check.names = FALSE))
}

demo_screening <- function(b) {
  set.seed(42)
  n <- 24
  kids <- tibble(
    Student = sprintf("Student %02d", 1:n),
    Class = rep(c("Demo 1A", "Demo 1B"), each = n / 2),
    ability = rnorm(n, 0.2, 0.8), growth = rnorm(n, 0.12, 0.25)
  )
  t_col <- paste0(".cut", match(default_target(b$levels), b$levels))
  goals <- b$cuts |> transmute(Grade, Period, Measure, At = .data[[t_col]])
  tidyr::crossing(kids, goals) |>
    mutate(
      t = match(Period, c("BOY", "MOY", "EOY")) - 1,
      Score = round(pmax(0, At + (ability + growth * t) * (0.25 * At + 3) +
                           rnorm(n(), 0, 0.08 * At + 1))),
      GivenStatus = NA_character_
    ) |>
    select(Student, Class, Grade, Period, Measure, Score, GivenStatus)
}

# ---- Tables used by the server ------------------------------------------------

# One row per student, one column per measure, plus hidden "<measure>__status"
# columns used for cell colouring.
overview_table <- function(d) {
  keys <- c("Student", "Class", "Grade")
  
  if (is.factor(d$Measure)) {
    d <- d |> arrange(Measure)
  }
  
  flags <- d |>
    group_by(across(all_of(keys))) |>
    summarise(`Skills needing support` = sum(Flag), .groups = "drop")
  
  sc <- d |>
    select(all_of(keys), Measure, Score) |>
    pivot_wider(names_from = Measure, values_from = Score)
  
  st <- d |>
    transmute(across(all_of(keys)), Measure = paste0(Measure, "__status"),
              Status = as.character(Status)) |>
    pivot_wider(names_from = Measure, values_from = Status)
  
  flags |> left_join(sc, by = keys) |> left_join(st, by = keys)
}

# Per-student needs for one period: every measure on which the student is below
# the on-track level, sorted into the teaching order given by `rules`.
# Measures that are not in `rules` come last and keep their own name.
student_needs <- function(d, rules) {
  rules <- rules |>
    transmute(MKey = mkey(Measure), Skill, Order = row_number()) |>
    distinct(MKey, .keep_all = TRUE)
  d |>
    filter(Flag) |>
    mutate(MKey = mkey(Measure)) |>
    left_join(rules, by = "MKey") |>
    mutate(
      Tier = as.character(Status),
      Order = coalesce(Order, 500L),
      Skill = coalesce(Skill, Measure)
    ) |>
    arrange(Student, Order)
}

# ---- Demo for Individual Progress Monitoring ----------------------------------
# A made-up Task Analysis data sheet (hand washing, 8 steps, 8 sessions) in the
# same Key / Value / Date.N layout the app creates and downloads.
demo_individual <- function() {
  set.seed(7)
  keys <- strategy_defs[["Task Analysis"]]$fields
  steps <- c("Turn on the tap", "Wet hands", "Get soap", "Rub hands for 20 seconds",
             "Rinse hands", "Turn off the tap", "Get a paper towel", "Dry hands and throw towel away")
  setup <- c("Objective" = "Wash hands independently (8 of 8 steps)",
             "Task Demand" = "S, wash your hands",
             "First Prompt" = "Verbal(V)", "Second Prompt" = "Gesture(G)",
             "Third Prompt" = "Partial Physical(PP)", "Latency" = "3 sec")
  value <- setNames(rep("", length(keys)), keys)
  value[names(setup)] <- setup
  value[paste("Step", seq_along(steps))] <- steps
  out <- tibble(Key = keys, Value = unname(value))
  difficulty <- c(0.5, 0.3, 1.2, 2.6, 1.0, 1.6, 0.8, 2.0)   # harder steps are learned later
  for (s in 1:8) {
    correct <- runif(length(steps)) < plogis(1.1 * (s - 1) - 2.2 * difficulty + 1)
    resp <- ifelse(correct, "+", sample(c("V", "V", "G", "PP"), length(steps), replace = TRUE))
    col <- setNames(rep("", length(keys)), keys)
    col[paste("Step", seq_along(steps))] <- resp
    out[[paste0("Date.", s)]] <- unname(col)
  }
  out
}

# ---- Contact details shown in the footer and on the About tab -------------------
CONTACT_EMAIL  <- "seulbi.lee@uwaterloo.ca"   # set to "" to hide the email link
CONTACT_REPO   <- "https://github.com/seul-b/special-education-progress-monitoring"

contact_links <- function() {
  tagList(
    if (nzchar(CONTACT_EMAIL)) {
      a(href = paste0("mailto:", CONTACT_EMAIL, "?subject=Progress%20Monitoring%20Tool"),
        icon("envelope"), " Email me")
    },
    a(href = CONTACT_REPO, target = "_blank", icon("code"), " Source code")
  )
}

contact_footer <- function() {
  div(class = "app-footer", "Questions or feedback?", contact_links())
}
