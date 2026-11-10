shinyUI(navbarPage(
  title = "Special Education Progress Monitoring Tool",
  id = "topNav",
  theme = shinytheme("united"),
  footer = contact_footer(),
  header = tagList(tags$head(
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "stylesheet",
              href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"),
    tags$style(HTML("
    /* Clean, neutral typeface (falls back to the system font when offline) */
    body, h1, h2, h3, h4, h5, h6, .navbar, .btn, input, select, textarea, button,
    .selectize-input, .selectize-dropdown, table {
      font-family: 'Inter', 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; }
    body { font-size: 14px; color: #2B2B2B; }
    h3 { font-size: 20px; font-weight: 600; margin-top: 26px; }
    h4 { font-size: 16px; font-weight: 600; }
    .app-footer { margin: 30px 0 0 0; padding: 14px 20px; border-top: 1px solid #DDD;
                  background: #FAFAFA; color: #555; font-size: 13px; text-align: center; }
    .app-footer a { margin: 0 10px; font-weight: 600; }
    .legend-chip { display: inline-block; padding: 2px 10px; margin: 0 6px 6px 0;
                   border-radius: 3px; font-size: 13px; color: #222; }
    .note { color: #666; font-size: 13px; }
    .banner { padding: 8px 12px; margin-bottom: 12px; border-radius: 4px;
              background: #FFF3CD; border: 1px solid #E0A800; color: #5C4500; }
    .well .btn { margin-bottom: 8px; }

    /* Top bar: white, with the sections shown as clearly separate tabs */
    .navbar-default { background: #fff; border: 0; border-bottom: 3px solid #E95420; margin-bottom: 14px; }
    .navbar-default .navbar-brand, .navbar-default .navbar-brand:hover,
    .navbar-default .navbar-brand:focus { color: #333; font-weight: 600; background: transparent; }
    .navbar-default .navbar-nav > li > a {
      color: #444; background: #F1F1F1; font-weight: 600;
      margin: 8px 6px 0 0; padding: 11px 18px;
      border: 1px solid #D5D5D5; border-bottom: 0; border-radius: 7px 7px 0 0; }
    .navbar-default .navbar-nav > li > a:hover,
    .navbar-default .navbar-nav > li > a:focus { background: #FBE3DA; color: #222; }
    .navbar-default .navbar-nav > .active > a, .navbar-default .navbar-nav > .active > a:hover,
    .navbar-default .navbar-nav > .active > a:focus { background: #E95420; color: #fff; border-color: #E95420; }

    /* Tabs inside a section */
    .nav-tabs { border-bottom: 2px solid #E95420; margin-bottom: 10px; }
    .nav-tabs > li > a { background: #F4F4F4; border: 1px solid #D5D5D5; border-bottom: 0;
                         color: #444; font-weight: 600; margin-right: 4px; }
    .nav-tabs > li > a:hover { background: #FBE3DA; border-color: #D5D5D5; color: #222; }
    .nav-tabs > li.active > a, .nav-tabs > li.active > a:hover, .nav-tabs > li.active > a:focus {
      background: #fff; color: #C7431A; border: 2px solid #E95420; border-bottom-color: #fff; }

    .print-bar { text-align: right; margin: -6px 0 8px 0; }
    .pick-links { margin: -8px 0 10px 0; font-size: 13px; }
    .dt-buttons { margin-bottom: 8px; }

    @media print {
      .navbar, .app-footer, .nav-tabs, .btn, .shiny-download-link, .dt-buttons, .print-bar,
      .dataTables_filter, .dataTables_length, .dataTables_paginate, .banner,
      div[class*='col-sm-']:has(> form.well) { display: none !important; }
      .col-sm-8, .col-sm-9 { width: 100% !important; }
      a[href]:after { content: none !important; }
    }
  "))),
    div(class = "container-fluid print-bar",
        tags$button(class = "btn btn-default btn-sm", onclick = "window.print()",
                    icon("print"), " Print this page"))),
  
  # ===========================================================================
  # Individual progress monitoring
  # ===========================================================================
  tabPanel(
    "Individual Progress Monitoring", icon = icon("user"),
    sidebarLayout(
      sidebarPanel(
        a("Systematic Instructional Procedures Guide",
          href = "https://docs.google.com/document/d/1-B1BgzkaWoBts5u45IOPyoRAwyer9uqY/edit?usp=sharing&ouid=115341977432165124158&rtpof=true&sd=true",
          target = "_blank", style = "font-size: 16px;"),
        br(), br(),
        fileInput("importData", "Open a saved data sheet (CSV)", accept = ".csv"),
        actionButton("indDemo", "Try it with demo data", class = "btn-default"),
        tags$hr(),
        selectInput("Strategy", "Choose a Strategy",
                    choices = c("Select", names(strategy_defs))),
        actionButton("Generate", "Create data sheet / Add a session", class = "btn-primary"),
        actionButton("clearData", "Start over"),
        p(class = "note", "The first click creates the data sheet from the boxes below. Each later click adds what is typed in the boxes as a new session."),
        lapply(names(strategy_defs), strategy_panel)
      ),
      mainPanel(uiOutput("indBanner"), tabsetPanel(
        id = "mainTabset",
        tabPanel(
          "Data",
          br(),
          downloadButton("downloadData", "Download Data"),
          tableOutput("show_inputs")
        ),
        tabPanel(
          "Graph",
          br(),
          fluidRow(
            column(4, selectInput("indGraph", "Graph type", choices = c(
              "Bar graph" = "bar", "Line graph" = "line", "Shaded line graph" = "area", "Dot graph" = "lollipop",
              "Number correct each session" = "stack",
              "Every step, every session" = "grid"
            ))),
            column(3, numericInput("goalPercentage", "Goal (%)", 60, min = 0, max = 100)),
            column(5, textInput("correctCodes", "Marks that count as correct (independent)", "+, UC"))
          ),
          fluidRow(
            column(4, checkboxInput("showGoal", "Show goal line", TRUE)),
            column(4, checkboxInput("showTrend", "Show the overall trend", FALSE)),
            column(4, checkboxInput("showLabels", "Show numbers on the graph", TRUE))
          ),
          plotOutput("result", height = "450px"),
          downloadButton("dlIndPlot", "Download graph (PNG)"),
          tableOutput("sessionTable"),
          downloadButton("dlSessions", "Download session summary")
        )
      ))
    )
  ),
  
  # ===========================================================================
  # Class screening
  # ===========================================================================
  tabPanel(
    "Class Screening", icon = icon("users"),
    sidebarLayout(
      sidebarPanel(
        width = 3,
        h4("1. Scores"),
        fileInput("scrFile", "Upload your students' scores (CSV)", accept = ".csv"),
        downloadLink("scrTemplate", "Download a blank scores template"),
        tags$hr(),
        h4("2. Cut scores (score ranges for each level)"),
        fileInput("benchFile", "Upload the cut scores (CSV)", accept = ".csv"),
        p(class = "note", "One column per level, lowest level first. The column headers become the level names; each cell is the lowest score for that level. Any assessment, any number of levels."),
        selectInput("tplKind", "Template to start from", choices = c(
          "Blank (any assessment)" = "blank",
          "BC-ELST (British Columbia)" = "elst"
        )),
        conditionalPanel(
          "input.tplKind == 'elst'",
          div(class = "banner", "This template is only for the BC-ELST, the measure used in British Columbia, Canada. If you are using a different measure, please start from the blank cut-score template. Cutscores for BC-ELST are currently not available.")
        ),
        downloadLink("benchTemplate", "Download this cut-score template"),
        tags$hr(),
        p(strong("Demos"), span(class = "note", " (made-up students, illustrative cut scores)")),
        actionButton("demo3", "Try it with demo data", class = "btn-default"),
        tags$hr(),
        h4("3. View"),
        selectInput("targetLevel", "On-track level", choices = NULL),
        p(class = "note", "Students below this level are flagged."),
        selectInput("scrClass", "Class / teacher", choices = NULL, multiple = TRUE),
        selectInput("scrGrade", "Grade", choices = NULL, multiple = TRUE),
        selectInput("scrPeriod", "Time of year", choices = NULL),
        selectizeInput("scrStudent", "Students", choices = NULL, multiple = TRUE,
                       options = list(plugins = list("remove_button"), placeholder = "Everyone")),
        div(class = "pick-links", actionLink("stuAll", "Select all"), " | ", actionLink("stuNone", "Clear (show everyone)")),
        p(class = "note", "Leave Class, Grade or Students empty to include everyone. Pick one student, or pick several and remove names with the x.")
      ),
      mainPanel(
        width = 9,
        uiOutput("scrBanner"),
        uiOutput("scrLegend"),
        tabsetPanel(
          id = "scrTabs",
          tabPanel(
            "Class overview",
            br(),
            p(class = "note", "One row per student for the selected period. Click a column header to sort (e.g., by 'skills needing support' or by any measure)."),
            tableOutput("scrSummary"),
            downloadLink("dlSummary", "Download this summary"),
            br(), br(),
            DTOutput("scrOverview"),
            downloadButton("dlOverview", "Download this table")
          ),
          tabPanel(
            "Who needs support?",
            br(),
            fluidRow(
              column(5, selectInput("grpMeasure", "Skill", choices = NULL, multiple = TRUE)),
              column(7, checkboxGroupInput("grpStatus", "Level", choices = NO_BM, inline = TRUE))
            ),
            textOutput("grpCount"),
            DTOutput("grpTable"),
            downloadButton("dlGroup", "Download this list")
          ),
          tabPanel(
            "Growth",
            br(),
            fluidRow(
              column(4, selectInput("prMeasure", "Skill", choices = NULL)),
              column(3, selectInput("prFrom", "From", choices = NULL)),
              column(3, selectInput("prTo", "To", choices = NULL))
            ),
            tableOutput("prSummary"),
            DTOutput("prTable"),
            downloadButton("dlProgress", "Download this table")
          ),
          tabPanel(
            "Graphs",
            br(),
            fluidRow(
              column(5, selectInput("scrGraph", "Graph type", choices = c(
                "How many students are at each level" = "status",
                "Whole-class colour chart" = "heat",
                "Class levels across the year" = "time",
                "Each student's growth" = "growth",
                "Spread of class scores" = "dist",
                "First score vs. latest score" = "dumbbell",
                "One student's report" = "profile"
              ))),
              column(3, conditionalPanel(
                "['growth','dist','dumbbell'].indexOf(input.scrGraph) >= 0",
                selectInput("grMeasure", "Skill", choices = NULL)
              ), conditionalPanel(
                "input.scrGraph == 'profile'",
                selectInput("grStudent", "Student", choices = NULL)
              )),
              column(4, conditionalPanel(
                "['status','time'].indexOf(input.scrGraph) >= 0",
                checkboxInput("grPct", "Show as % of students", FALSE)
              ), conditionalPanel(
                "input.scrGraph == 'growth'",
                checkboxInput("grNames", "Label students", FALSE)
              ))
            ),
            plotOutput("scrPlot", height = "auto"),
            downloadButton("dlScrPlot", "Download graph (PNG)")
          ),
          tabPanel(
            "Next steps",
            br(),
            p(class = "note", "Suggested groups for the selected time of year. A student's primary focus is the earliest skill in the teaching order on which they are below the on-track level. See the About tab for exactly how this is worked out. It is a starting point for the conversation among teachers and professionals, not a diagnosis."),
            uiOutput("recOrder"),
            fluidRow(
              column(6, fileInput("recFile", "Use your own teaching order (CSV, optional)", accept = ".csv")),
              column(6, br(), downloadLink("recTemplate", "Download the current teaching order to edit"))
            ),
            h4("Suggested groups"),
            DTOutput("recGroups"),
            h4("By student"),
            DTOutput("recStudents"),
            downloadButton("dlRec", "Download next steps")
          )
        )
      )
    )
  ),
  
  # ===========================================================================
  # About
  # ===========================================================================
  tabPanel(
    "About", icon = icon("info-circle"),
    fluidRow(column(
      8, offset = 1,
      h3("Overview"),
      tags$ul(
        tags$li("Individual Progress Monitoring: Create systematic instruction data sheets and visualize individual student session progress over time."),
        tags$li("Classroom Screening & Grouping: Upload screening scores from any assessment (e.g., BC-ELST, district screeners, DIBELS) alongside corresponding cut scores to generate a color-coded whole-class dashboard, identify students needing support, track benchmark progression (BOY/MOY/EOY), and receive data-informed instructional grouping recommendations.")
      ),
      
      h3("File Format Requirements"),
      p("Student Scores File: Includes one row per student per assessment period. Required identifier columns are Student, Grade, Class, Period, followed by measure-specific columns (e.g., LNF, LSF, FSF, PSF, NWF, WRF, ORF). A long format (Student, Grade, Class, Period, Measure, Score, and optionally Status) is also supported. Valid assessment periods include BOY, MOY, EOY (or Fall, Winter, Spring)."),
      
      p("Cut Scores File: Structured with Grade, Period, Measure, followed by benchmark levels ordered from lowest to highest. Column headers represent level names, and each cell indicates the minimum score required to reach that level (e.g., the lowest risk level starts at 0)."),
      
      p("Example: Grade, Period, Measure, At Risk, Some Risk, On Track with values 1, BOY, PSF, 0, 21, 30. You can define as many risk levels as your assessment framework requires. If cut scores do not vary by Grade or Period, those columns may be omitted. Measure names are matched automatically, ignoring case, spaces, and punctuation."),
      
      p("The app automatically identifies which level indicates On Track based on column names. You can adjust this using the On-track level dropdown menu. Levels below benchmark are displayed in red-to-yellow, benchmark levels in green, and advanced levels in blue."),
      
      h3("Data Privacy & Security"),
      p("This application operates entirely in-memory—no student data is stored on external servers. All uploaded information is cleared immediately when the browser tab is closed. Multiple stakeholders (classroom teachers, resource educators, administrators) can safely view identical reports by uploading the local file. Please adhere to your district's privacy protocols regarding student identifiers; student initials or ID numbers are recommended."),
      
      h3("How the Primary Focus is Determined"),
      p("The Next Steps tab assigns each student a single Primary Focus based on benchmark levels using a five-step logic:"),
      
      tags$ol(
        tags$li("Target Assessment Period: Only scores from the selected time of year (e.g., MOY) and filtered cohorts (Class, Grade, Student selection) are evaluated."),
        tags$li("Identify Areas Needing Support: Any skill where a student performs below the designated On-track level is flagged for intervention. (For instance, in an At Risk < Some Risk < On Track framework, both At Risk and Some Risk trigger a flag)."),
        tags$li(
          "Apply Evidence-Based Scope & Sequence: Flagged skills are aligned from foundational to advanced. The default instructional sequence prioritizes auditory phonological processing prior to print-based decoding:",
          tags$div(
            style = "background-color: #f8f9fa; border-left: 4px solid #e95420; padding: 12px 16px; margin: 10px 0; border-radius: 4px; line-height: 1.6;",
            tags$div(style = "margin-bottom: 6px;", tags$span(style = "color: #555;", "Auditory / Oral: "), "Initial Sound Awareness (FSF) → Phonemic Awareness (PSF)"),
            tags$div(style = "margin-bottom: 6px;", tags$span(style = "color: #555;", "Print / Decoding: "), "Letter Names (LNF) → Letter Sounds (LSF) → Letter-Sound Correspondence / Decoding (NWF) → Word Reading (WRF)"),
            tags$div(tags$span(style = "color: #555;", "Text-Level Reading: "), "Reading Accuracy (ORF-ACC) → Reading Fluency (ORF) → Reading Comprehension (MAZE)")
          )
        ),
        tags$li("Prioritize the Earliest Skill Gap: The primary focus is assigned to the most foundational (earliest) skill requiring support. This is intentionally based on skill progression rather than the numerical distance from cut scores, adhering to the principle that foundational gaps must be remediated before higher-level skills can develop."),
        tags$li("Generate Instructional Groups: Students sharing the same primary focus and performance level are grouped together. Suggested groups are displayed in instructional sequence order, prioritizing higher-need levels first.")
      ),
      
      p(strong("Special Statuses: "), "Students meeting benchmark across all measures will display None Flagged. Unmatched scores without corresponding cut score data will show Unknown. Unlisted measures (e.g., composite scores or custom screeners) are evaluated only if no core sequence skills require support."),
      
      p(strong("Disclaimer: "), "This tool provides data-driven decision support as a baseline for collaborative teacher consultation—it does not replace professional diagnostic judgment."),
      
      h3("Contact"),
      p("Questions, feedback, or a bug to report? Get in touch:"),
      contact_links()
    ))
  )
))