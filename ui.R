library(shiny)
library(shinythemes)
shinyUI(fluidPage(
  theme = shinytheme("united"),
  tags$head(tags$style(
    HTML(
      "
      .header-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px;
      }
      .header-right {
        display: flex;
        align-items: center;
        margin-left: auto;
      }
      .header-title {
        font-size: 24px;
        font-weight: bold;
        margin-right: 20px;
      }
      #reload {
        margin-left: 10px;
      }
      .github-icon {
        margin-left: 10px;
        color: #808080;
        text-decoration: none;
        background-color: transparent;
      }
      .github-icon:hover {
        color: #A9A9A9;
      }
      .fa-github {
        font-size: 20px;
      }
    "
    )
  ),
  tags$script(
    HTML(
      "
      $(document).on('click', '#reload', function() {
        window.location.reload();
      });
    "
    )
  )),
  
  div(
    class = "header-container",
    span(class = "header-title", "Shiny Special Education Progress Monitoring Tool"),
    div(
      class = "header-right",
      actionButton("reload", "Reload", class = "btn btn-primary"),
      a(
        href = "https://github.com/yourUsername/yourRepository",
        target = "_blank",
        class = "github-icon",
        tags$i(class = "fa fa-github"),
        title = "Visit my GitHub Repository"
      )
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      a(
        "Systematic Instructional Procedures Guide",
        href = "https://docs.google.com/document/d/1l6PnyDNlEFu797-Pu4r7wb6dKg-t9pwwRaO-L7_1Cv0/edit?usp=sharing",
        target = "_blank",
        style = "font-size: 16px; margin-bottom: 25px;"
      ),
      
      fileInput("importData", "Upload CSV File", accept = c(".csv")),
      selectInput(
        "Strategy",
        "Choose a Strategy",
        choices = c(
          "Select",
          "Task Analysis",
          "Time Delay",
          "Errorless Learning",
          "Simultaneous Prompting",
          "Customized (50 max)"
        )
      ),
      
      div(
        actionButton(
          "Generate",
          "Generate Template",
          class = "btn-primary",
          style = "margin-bottom: 15px;"
        ),
      ),
      
      # Conditional Panel for Task Analysis
      conditionalPanel(condition = "input.Strategy == 'Task Analysis'",
                       fluidRow(
                         column(
                           width = 12,
                           textInput('Objective.TA', 'Objective', ""),
                           textInput('Task Demand.TA', 'Task Demand', "S, make a PB sandwich"),
                           selectInput(
                             "First Prompt.TA",
                             "First Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           selectInput(
                             "Second Prompt.TA",
                             "Second Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           selectInput(
                             "Third Prompt.TA",
                             "Third Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           textInput('Latency.TA', 'Latency', "3 sec"),
                           textInput('Step 1.TA', 'Step 1', ""),
                           textInput('Step 2.TA', 'Step 2', ""),
                           textInput('Step 3.TA', 'Step 3', ""),
                           textInput('Step 4.TA', 'Step 4', ""),
                           textInput('Step 5.TA', 'Step 5', ""),
                           textInput('Step 6.TA', 'Step 6', ""),
                           textInput('Step 7.TA', 'Step 7', ""),
                           textInput('Step 8.TA', 'Step 8', ""),
                           textInput('Step 9.TA', 'Step 9', ""),
                           textInput('Step 10.TA', 'Step 10', ""),
                           textInput('Step 11.TA', 'Step 11', ""),
                           textInput('Step 12.TA', 'Step 12', ""),
                           textInput('Step 13.TA', 'Step 13', ""),
                           textInput('Step 14.TA', 'Step 14', ""),
                           textInput('Step 15.TA', 'Step 15', ""),
                           textInput('Step 16.TA', 'Step 16', ""),
                           textInput('Step 17.TA', 'Step 17', ""),
                           textInput('Step 18.TA', 'Step 18', ""),
                           textInput('Step 19.TA', 'Step 19', ""),
                           textInput('Step 20.TA', 'Step 20', "")
                         ),
                       )),
      
      # Conditional Panel for Time Delay
      conditionalPanel(condition = "input.Strategy == 'Time Delay'",
                       fluidRow(
                         column(
                           width = 12,
                           textInput('Objective.TD', 'Objective', ""),
                           textInput('Task Demand.TD', 'Task Demand', "S, point to the [ ] picture"),
                           textInput('Delay.TD', 'Delay', ""),
                           selectInput(
                             "Response Prompt.TD",
                             "Response Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           textInput('Time Delay Schedule.TD', 'Time Delay Schedule', ""),
                           selectInput(
                             "Back-up Prompt.TD",
                             "Back-up Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           textInput('Latency.TD', 'Latency', ""),
                           textInput("Item 1 (Trial 1)", "Item 1 (Trial 1)", value = "pen"),
                           textInput("Item 2 (Trial 1)", "Item 2 (Trial 1)", value = "book"),
                           textInput("Item 3 (Trial 1)", "Item 3 (Trial 1)", value = "desk"),
                           textInput("Item 4 (Trial 1)", "Item 4 (Trial 1)", value = ""),
                           textInput("Item 5 (Trial 1)", "Item 5 (Trial 1)", value = ""),
                           textInput("Item 1 (Trial 2)", "Item 1 (Trial 2)", value = "pen"),
                           textInput("Item 2 (Trial 2)", "Item 2 (Trial 2)", value = "book"),
                           textInput("Item 3 (Trial 2)", "Item 3 (Trial 2)", value = "desk"),
                           textInput("Item 4 (Trial 2)", "Item 4 (Trial 2)", value = ""),
                           textInput("Item 5 (Trial 2)", "Item 5 (Trial 2)", value = ""),
                           textInput("Item 1 (Trial 3)", "Item 1 (Trial 3)", value = "pen"),
                           textInput("Item 2 (Trial 3)", "Item 2 (Trial 3)", value = "book"),
                           textInput("Item 3 (Trial 3)", "Item 3 (Trial 3)", value = "desk"),
                           textInput("Item 4 (Trial 3)", "Item 4 (Trial 3)", value = ""),
                           textInput("Item 5 (Trial 3)", "Item 5 (Trial 3)", value = ""),
                           textInput("Item 1 (Trial 4)", "Item 1 (Trial 4)", value = ""),
                           textInput("Item 2 (Trial 4)", "Item 2 (Trial 4)", value = ""),
                           textInput("Item 3 (Trial 4)", "Item 3 (Trial 4)", value = ""),
                           textInput("Item 4 (Trial 4)", "Item 4 (Trial 4)", value = ""),
                           textInput("Item 5 (Trial 4)", "Item 5 (Trial 4)", value = ""),
                           textInput("Item 1 (Trial 5)", "Item 1 (Trial 5)", value = ""),
                           textInput("Item 2 (Trial 5)", "Item 2 (Trial 5)", value = ""),
                           textInput("Item 3 (Trial 5)", "Item 3 (Trial 5)", value = ""),
                           textInput("Item 4 (Trial 5)", "Item 4 (Trial 5)", value = ""),
                           textInput("Item 5 (Trial 5)", "Item 5 (Trial 5)", value = ""),
                         ),
                       )),
      
      # Conditional Panel for Errorless Learning
      conditionalPanel(condition = "input.Strategy == 'Errorless Learning'",
                       fluidRow(
                         column(
                           width = 12,
                           textInput('Objective.EL', 'Objective', ""),
                           textInput('Task Demand.EL', 'Task Demand', "S, make a PB sandwich"),
                           selectInput(
                             "First Prompt.EL",
                             "First Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           selectInput(
                             "Second Prompt.EL",
                             "Second Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           selectInput(
                             "Third Prompt.EL",
                             "Third Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           textInput('Latency.EL', 'Latency', ""),
                           textInput('Step 1.EL', 'Step 1', ""),
                           textInput('Step 2.EL', 'Step 2', ""),
                           textInput('Step 3.EL', 'Step 3', ""),
                           textInput('Step 4.EL', 'Step 4', ""),
                           textInput('Step 5.EL', 'Step 5', ""),
                           textInput('Step 6.EL', 'Step 6', ""),
                           textInput('Step 7.EL', 'Step 7', ""),
                           textInput('Step 8.EL', 'Step 8', ""),
                           textInput('Step 9.EL', 'Step 9', ""),
                           textInput('Step 10.EL', 'Step 10', ""),
                           textInput('Step 11.EL', 'Step 11', ""),
                           textInput('Step 12.EL', 'Step 12', ""),
                           textInput('Step 13.EL', 'Step 13', ""),
                           textInput('Step 14.EL', 'Step 14', ""),
                           textInput('Step 15.EL', 'Step 15', ""),
                           textInput('Step 16.EL', 'Step 16', ""),
                           textInput('Step 17.EL', 'Step 17', ""),
                           textInput('Step 18.EL', 'Step 18', ""),
                           textInput('Step 19.EL', 'Step 19', ""),
                           textInput('Step 20.EL', 'Step 20', "")
                         ),
                       )),
      
      # Conditional Panel for Simultaneous Prompting
      conditionalPanel(condition = "input.Strategy == 'Simultaneous Prompting'",
                       fluidRow(
                         column(
                           width = 12,
                           textInput('Objective.SP', 'Objective', ""),
                           textInput('Task Demand.SP', 'Task Demand', "Turn on TV with a remote control"),
                           selectInput(
                             "Simultaneous Prompt.SP",
                             "Simultaneous Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           selectInput(
                             "Corrective Prompt.SP",
                             "Corrective Prompt",
                             choices = c(
                               "",
                               "Verbal(V)",
                               "Visual(VS)",
                               "Gesture(G)",
                               "Model(M)",
                               "Partial Physical(PP)",
                               "Full Physical(FP)"
                             )
                           ),
                           textInput('Latency.SP', 'Latency', ""),
                           textInput("Prompt 1", "Prompt Trial 1", value = ""),
                           textInput("Prompt 2", "Prompt Trial 2", value = ""),
                           textInput("Prompt 3", "Prompt Trial 3", value = ""),
                           textInput("Prompt 4", "Prompt Trial 4", value = ""),
                           textInput("Prompt 5", "Prompt Trial 5", value = ""),
                           textInput("Prompt 6", "Prompt Trial 6", value = ""),
                           textInput("Prompt 7", "Prompt Trial 7", value = ""),
                           textInput("Prompt 8", "Prompt Trial 8", value = ""),
                           textInput("Prompt 9", "Prompt Trial 9", value = ""),
                           textInput("Prompt 10", "Prompt Trial 10", value = ""),
                           textInput("Probe 1", "Test Probe Trial 1", value = ""),
                           textInput("Probe 2", "Test Probe Trial 2", value = ""),
                           textInput("Probe 3", "Test Probe Trial 3", value = ""),
                           textInput("Probe 4", "Test Probe Trial 4", value = ""),
                           textInput("Probe 5", "Test Probe Trial 5", value = "")
                         ),
                       )),
      
      # Conditional Panel for Customized
      conditionalPanel(condition = "input.Strategy == 'Customized (50 max)'",
                       fluidRow(
                         column(
                           width = 12,
                           textInput('Input 1', 'Input 1', ""),
                           textInput('Input 2', 'Input 2', ""),
                           textInput('Input 3', 'Input 3', ""),
                           textInput('Input 4', 'Input 4', ""),
                           textInput('Input 5', 'Input 5', ""),
                           textInput('Input 6', 'Input 6', ""),
                           textInput('Input 7', 'Input 7', ""),
                           textInput('Input 8', 'Input 8', ""),
                           textInput('Input 9', 'Input 9', ""),
                           textInput('Input 10', 'Input 10', ""),
                           textInput('Input 11', 'Input 11', ""),
                           textInput('Input 12', 'Input 12', ""),
                           textInput('Input 13', 'Input 13', ""),
                           textInput('Input 14', 'Input 14', ""),
                           textInput('Input 15', 'Input 15', ""),
                           textInput('Input 16', 'Input 16', ""),
                           textInput('Input 17', 'Input 17', ""),
                           textInput('Input 18', 'Input 18', ""),
                           textInput('Input 19', 'Input 19', ""),
                           textInput('Input 20', 'Input 20', ""),
                           textInput('Input 21', 'Input 21', ""),
                           textInput('Input 22', 'Input 22', ""),
                           textInput('Input 23', 'Input 23', ""),
                           textInput('Input 24', 'Input 24', ""),
                           textInput('Input 25', 'Input 25', ""),
                           textInput('Input 26', 'Input 26', ""),
                           textInput('Input 27', 'Input 27', ""),
                           textInput('Input 28', 'Input 28', ""),
                           textInput('Input 29', 'Input 29', ""),
                           textInput('Input 30', 'Input 30', ""),
                           textInput('Input 31', 'Input 31', ""),
                           textInput('Input 32', 'Input 32', ""),
                           textInput('Input 33', 'Input 33', ""),
                           textInput('Input 34', 'Input 34', ""),
                           textInput('Input 35', 'Input 35', ""),
                           textInput('Input 36', 'Input 36', ""),
                           textInput('Input 37', 'Input 37', ""),
                           textInput('Input 38', 'Input 38', ""),
                           textInput('Input 39', 'Input 39', ""),
                           textInput('Input 40', 'Input 40', ""),
                           textInput('Input 41', 'Input 41', ""),
                           textInput('Input 42', 'Input 42', ""),
                           textInput('Input 43', 'Input 43', ""),
                           textInput('Input 44', 'Input 44', ""),
                           textInput('Input 45', 'Input 45', ""),
                           textInput('Input 46', 'Input 46', ""),
                           textInput('Input 47', 'Input 47', ""),
                           textInput('Input 48', 'Input 48', ""),
                           textInput('Input 49', 'Input 49', ""),
                           textInput('Input 50', 'Input 50', "")
                         ),
                       )),
    ),
    
    mainPanel(tabsetPanel(
      id = "mainTabset",
      tabPanel(
        "Data",
        downloadButton('downloadData', 'Download Data'),
        tableOutput('show_inputs')
      ),
      tabPanel(
        "Graph",
        numericInput(
          "goalPercentage",
          "Goal Percentage:",
          60,
          min = 0,
          max = 100
        ),
        plotOutput("result")
      )
    ))
  )
))