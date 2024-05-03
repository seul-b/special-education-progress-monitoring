library(dplyr)
library(tidyr)
library(tibble)
library(ggplot2)
library(rlang)

shinyServer(function(input, output, session) {
  AllInputs <- reactiveVal(tibble())
  Filtered <- reactiveVal(tibble())
  values <- reactiveValues(currentStrategy = NULL, loaded = FALSE)
  
  getStrategyColumns <- function(strategy) {
    if (strategy == "Task Analysis") {
      return(
        c(
          "Objective",
          "Task Demand",
          "First Prompt",
          "Second Prompt",
          "Third Prompt",
          "Latency",
          "Step 1",
          "Step 2",
          "Step 3",
          "Step 4",
          "Step 5",
          "Step 6",
          "Step 7",
          "Step 8",
          "Step 9",
          "Step 10",
          "Step 11",
          "Step 12",
          "Step 13",
          "Step 14",
          "Step 15",
          "Step 16",
          "Step 17",
          "Step 18",
          "Step 19",
          "Step 20"
        )
      )
    } else if (strategy == "Time Delay") {
      return(
        c(
          "Objective",
          "Task Demand",
          "Delay",
          "Response Prompt",
          "Time Delay Schedule",
          "Back-up Prompt",
          "Latency",
          "Item 1 (Trial 1)",
          "Item 2 (Trial 1)",
          "Item 3 (Trial 1)",
          "Item 4 (Trial 1)",
          "Item 5 (Trial 1)",
          "Item 1 (Trial 2)",
          "Item 2 (Trial 2)",
          "Item 3 (Trial 2)",
          "Item 4 (Trial 2)",
          "Item 5 (Trial 2)",
          "Item 1 (Trial 3)",
          "Item 2 (Trial 3)",
          "Item 3 (Trial 3)",
          "Item 4 (Trial 3)",
          "Item 5 (Trial 3)",
          "Item 1 (Trial 4)",
          "Item 2 (Trial 4)",
          "Item 3 (Trial 4)",
          "Item 4 (Trial 4)",
          "Item 5 (Trial 4)",
          "Item 1 (Trial 5)",
          "Item 2 (Trial 5)",
          "Item 3 (Trial 5)",
          "Item 4 (Trial 5)",
          "Item 5 (Trial 5)"
        )
      )
    } else if (strategy == "Least-to-Most/Most-to-Least Prompt") {
      return(
        c(
          "Objective",
          "Task Demand",
          "First Prompt",
          "Second Prompt",
          "Third Prompt",
          "Latency",
          "Step 1",
          "Step 2",
          "Step 3",
          "Step 4",
          "Step 5",
          "Step 6",
          "Step 7",
          "Step 8",
          "Step 9",
          "Step 10",
          "Step 11",
          "Step 12",
          "Step 13",
          "Step 14",
          "Step 15",
          "Step 16",
          "Step 17",
          "Step 18",
          "Step 19",
          "Step 20"
        )
      )
    } else if (strategy == "Simultaneous Prompting") {
      return(
        c(
          "Objective",
          "Task Demand",
          "Simultaneous Prompt",
          "Latency",
          "Prompt 1",
          "Prompt 2",
          "Prompt 3",
          "Prompt 4",
          "Prompt 5",
          "Prompt 6",
          "Prompt 7",
          "Prompt 8",
          "Prompt 9",
          "Prompt 10",
          "Probe 1",
          "Probe 2",
          "Probe 3",
          "Probe 4",
          "Probe 5"
        )
      )
    } else if (strategy == "Customized (50 max)") {
      return(
        c(
          "Input 1",
          "Input 2",
          "Input 3",
          "Input 4",
          "Input 5",
          "Input 6",
          "Input 7",
          "Input 8",
          "Input 9",
          "Input 10",
          "Input 11",
          "Input 12",
          "Input 13",
          "Input 14",
          "Input 15",
          "Input 16",
          "Input 17",
          "Input 18",
          "Input 19",
          "Input 20",
          "Input 21",
          "Input 22",
          "Input 23",
          "Input 24",
          "Input 25",
          "Input 26",
          "Input 27",
          "Input 28",
          "Input 29",
          "Input 30",
          "Input 31",
          "Input 32",
          "Input 33",
          "Input 34",
          "Input 35",
          "Input 36",
          "Input 37",
          "Input 38",
          "Input 39",
          "Input 40",
          "Input 41",
          "Input 42",
          "Input 43",
          "Input 44",
          "Input 45",
          "Input 46",
          "Input 47",
          "Input 48",
          "Input 49",
          "Input 50"
        )
      )
    }
  }
  
  observeEvent(input$importData, {
    req(input$importData)
    infile <- input$importData
    
    importedData <- reactive({
      read.csv(infile$datapath,
               header = TRUE,
               stringsAsFactors = FALSE)
    })
    
    AllInputs(importedData())
    
  })
  

  observe({
    if (!is.null(values$currentStrategy) &&
        input$Strategy != "" && input$Strategy != "Select" &&
        input$Strategy != values$currentStrategy && values$loaded) {
      showModal(
        modalDialog(
          title = "Warning",
          "If you modify the strategy, all inputted data will be lost. Please download your data from the 'Data' tab before reloading the page.",
          easyClose = TRUE,
          footer = tagList(
            modalButton("Cancel"),
            actionButton("confirmReload", "Reload", class = "btn btn-primary")
          )
        )
      )
      values$currentStrategy <- input$Strategy
    } else if (is.null(values$currentStrategy)) {
      if (input$Strategy != "" && input$Strategy != "Select") {
        values$currentStrategy <- input$Strategy
      }
    }
    values$loaded <- TRUE
  })
  
  observeEvent(input$Generate, {
    inputData <- reactive({
      if (input$Strategy == "Task Analysis") {
        tibble(
          'Objective' = input$'Objective.TA',
          'Task Demand' = input$'Task Demand.TA',
          'First Prompt' = input$'First Prompt.TA',
          'Second Prompt' = input$'Second Prompt.TA',
          'Third Prompt' = input$'Third Prompt.TA',
          'Latency' = input$'Latency.TA',
          'Step 1' = input$'Step 1.TA',
          'Step 2' = input$'Step 2.TA',
          'Step 3' = input$'Step 3.TA',
          'Step 4' = input$'Step 4.TA',
          'Step 5' = input$'Step 5.TA',
          'Step 6' = input$'Step 6.TA',
          'Step 7' = input$'Step 7.TA',
          'Step 8' = input$'Step 8.TA',
          'Step 9' = input$'Step 9.TA',
          'Step 10' = input$'Step 10.TA',
          'Step 11' = input$'Step 11.TA',
          'Step 12' = input$'Step 12.TA',
          'Step 13' = input$'Step 13.TA',
          'Step 14' = input$'Step 14.TA',
          'Step 15' = input$'Step 15.TA',
          'Step 16' = input$'Step 16.TA',
          'Step 17' = input$'Step 17.TA',
          'Step 18' = input$'Step 18.TA',
          'Step 19' = input$'Step 19.TA',
          'Step 20' = input$'Step 20.TA'
        )
      } else if (input$Strategy == "Time Delay") {
        tibble(
          'Objective' = input$'Objective.TD',
          'Task Demand' = input$'Task Demand.TD',
          'Delay' = input$'Delay.TD',
          'Response Prompt' = input$'Response Prompt.TD',
          'Time Delay Schedule' = input$'Time Delay Schedule.TD',
          'Back-up Prompt' = input$'Back-up Prompt.TD',
          'Latency' = input$'Latency.TD',
          'Item 1 (Trial 1)' = input$'Item 1 (Trial 1)',
          'Item 2 (Trial 1)' = input$'Item 2 (Trial 1)',
          'Item 3 (Trial 1)' = input$'Item 3 (Trial 1)',
          'Item 4 (Trial 1)' = input$'Item 4 (Trial 1)',
          'Item 5 (Trial 1)' = input$'Item 5 (Trial 1)',
          'Item 1 (Trial 2)' = input$'Item 1 (Trial 2)',
          'Item 2 (Trial 2)' = input$'Item 2 (Trial 2)',
          'Item 3 (Trial 2)' = input$'Item 3 (Trial 2)',
          'Item 4 (Trial 2)' = input$'Item 4 (Trial 2)',
          'Item 5 (Trial 2)' = input$'Item 5 (Trial 2)',
          'Item 1 (Trial 3)' = input$'Item 1 (Trial 3)',
          'Item 2 (Trial 3)' = input$'Item 2 (Trial 3)',
          'Item 3 (Trial 3)' = input$'Item 3 (Trial 3)',
          'Item 4 (Trial 3)' = input$'Item 4 (Trial 3)',
          'Item 5 (Trial 3)' = input$'Item 5 (Trial 3)',
          'Item 1 (Trial 4)' = input$'Item 1 (Trial 4)',
          'Item 2 (Trial 4)' = input$'Item 2 (Trial 4)',
          'Item 3 (Trial 4)' = input$'Item 3 (Trial 4)',
          'Item 4 (Trial 4)' = input$'Item 4 (Trial 4)',
          'Item 5 (Trial 4)' = input$'Item 5 (Trial 4)',
          'Item 1 (Trial 5)' = input$'Item 1 (Trial 5)',
          'Item 2 (Trial 5)' = input$'Item 2 (Trial 5)',
          'Item 3 (Trial 5)' = input$'Item 3 (Trial 5)',
          'Item 4 (Trial 5)' = input$'Item 4 (Trial 5)',
          'Item 5 (Trial 5)' = input$'Item 5 (Trial 5)'
        )
      } else if (input$Strategy == "Least-to-Most/Most-to-Least Prompt") {
        tibble(
          'Objective' = input$'Objective.EL',
          'Task Demand' = input$'Task Demand.EL',
          'First Prompt' = input$'First Prompt.EL',
          'Second Prompt' = input$'Second Prompt.EL',
          'Third Prompt' = input$'Third Prompt.EL',
          'Latency' = input$'Latency.EL',
          'Step 1' = input$'Step 1.EL',
          'Step 2' = input$'Step 2.EL',
          'Step 3' = input$'Step 3.EL',
          'Step 4' = input$'Step 4.EL',
          'Step 5' = input$'Step 5.EL',
          'Step 6' = input$'Step 6.EL',
          'Step 7' = input$'Step 7.EL',
          'Step 8' = input$'Step 8.EL',
          'Step 9' = input$'Step 9.EL',
          'Step 10' = input$'Step 10.EL',
          'Step 11' = input$'Step 11.EL',
          'Step 12' = input$'Step 12.EL',
          'Step 13' = input$'Step 13.EL',
          'Step 14' = input$'Step 14.EL',
          'Step 15' = input$'Step 15.EL',
          'Step 16' = input$'Step 16.EL',
          'Step 17' = input$'Step 17.EL',
          'Step 18' = input$'Step 18.EL',
          'Step 19' = input$'Step 19.EL',
          'Step 20' = input$'Step 20.EL'
        )
      } else if (input$Strategy == "Simultaneous Prompting") {
        tibble(
          'Objective' = input$'Objective.SP',
          'Task Demand' = input$'Task Demand.SP',
          'Simultaneous Prompt' = input$'Simultaneous Prompt.SP',
          'Latency' = input$'Latency.SP',
          'Prompt Trial 1' = input$'Prompt 1',
          'Prompt Trial 2' = input$'Prompt 2',
          'Prompt Trial 3' = input$'Prompt 3',
          'Prompt Trial 4' = input$'Prompt 4',
          'Prompt Trial 5' = input$'Prompt 5',
          'Prompt Trial 6' = input$'Prompt 6',
          'Prompt Trial 7' = input$'Prompt 7',
          'Prompt Trial 8' = input$'Prompt 8',
          'Prompt Trial 9' = input$'Prompt 9',
          'Prompt Trial 10' = input$'Prompt 10',
          'Test Probe Trial 1' = input$'Probe 1',
          'Test Probe Trial 2' = input$'Probe 2',
          'Test Probe Trial 3' = input$'Probe 3',
          'Test Probe Trial 4' = input$'Probe 4',
          'Test Probe Trial 5' = input$'Probe 5'
        )
      } else if (input$Strategy == "Customized (50 max)") {
        tibble(
          'Objective' = input$'Objective.C',
          'Task Demand' = input$'Task Demand.C',
          'Input 1' = input$'Input 1',
          'Input 2' = input$'Input 2',
          'Input 3' = input$'Input 3',
          'Input 4' = input$'Input 4',
          'Input 5' = input$'Input 5',
          'Input 6' = input$'Input 6',
          'Input 7' = input$'Input 7',
          'Input 8' = input$'Input 8',
          'Input 9' = input$'Input 9',
          'Input 10' = input$'Input 10',
          'Input 11' = input$'Input 11',
          'Input 12' = input$'Input 12',
          'Input 13' = input$'Input 13',
          'Input 14' = input$'Input 14',
          'Input 15' = input$'Input 15',
          'Input 16' = input$'Input 16',
          'Input 17' = input$'Input 17',
          'Input 18' = input$'Input 18',
          'Input 19' = input$'Input 19',
          'Input 20' = input$'Input 20',
          'Input 21' = input$'Input 21',
          'Input 22' = input$'Input 22',
          'Input 23' = input$'Input 23',
          'Input 24' = input$'Input 24',
          'Input 25' = input$'Input 25',
          'Input 26' = input$'Input 26',
          'Input 27' = input$'Input 27',
          'Input 28' = input$'Input 28',
          'Input 29' = input$'Input 29',
          'Input 30' = input$'Input 30',
          'Input 31' = input$'Input 31',
          'Input 32' = input$'Input 32',
          'Input 33' = input$'Input 33',
          'Input 34' = input$'Input 34',
          'Input 35' = input$'Input 35',
          'Input 36' = input$'Input 36',
          'Input 37' = input$'Input 37',
          'Input 38' = input$'Input 38',
          'Input 39' = input$'Input 39',
          'Input 40' = input$'Input 40',
          'Input 41' = input$'Input 41',
          'Input 42' = input$'Input 42',
          'Input 43' = input$'Input 43',
          'Input 44' = input$'Input 44',
          'Input 45' = input$'Input 45',
          'Input 46' = input$'Input 46',
          'Input 47' = input$'Input 47',
          'Input 48' = input$'Input 48',
          'Input 49' = input$'Input 49',
          'Input 50' = input$'Input 50'
        )
      }
    })
    
    currentInputs <- inputData()
    
    newData <- tibble(
      Key = names(currentInputs),
      Value = unlist(currentInputs, use.names = FALSE)
    )
    if (ncol(AllInputs()) == 0) {
      AllInputs(newData)
    } else {
      newData <- tibble(Value = unlist(currentInputs, use.names = FALSE))
      colIndex <- ncol(AllInputs()) - 1
      colName <- paste0('Date.', colIndex)
      newData <- newData |>
        rename_at(vars(Value), ~ colName)
      AllInputs(bind_cols(AllInputs(), newData))
    }
    values$currentStrategy <- input$Strategy
  })
  
  observeEvent(input$confirmReload, {
    session$reload()
  })
  
  observe({
    if (input$mainTabset == "Graph") {
      correct_response_symbol <-
        ifelse(input$Strategy == "Time Delay", "CA", "+")
      
      categories <- list(
        Strategy = "Strategy",
        Objective = "Objective",
        TaskDemand = "Task Demand",
        Delay = "Delay",
        Latency = "Latency",
        Prompt = c(
          "First Prompt",
          "Second Prompt",
          "Third Prompt",
          "Response Prompt",
          "Time Delay Schedule",
          "Back-up Prompt",
          "Simultaneous Prompt",
          paste("Prompt", 1:10)
        )
      )
      
      combined.props.vector <- unlist(categories)
      
      filteredData <- AllInputs()
      
      filteredData <- filteredData |>
        filter(!(Key %in% combined.props.vector)) |>
        mutate(across(where(is.character), ~ na_if(.x, "")))
      
      NumCorrect <- filteredData |>
        summarise(across(-Key, ~ sum(
          . == correct_response_symbol, na.rm = TRUE
        ))) |>
        mutate(Key = "NumCorrect")  |>
        select(Key, everything()) |>
        mutate(across(-Key, as.character))
      
      PercentCorrect <- filteredData |>
        summarise(across(-Key, ~ {
          correct_counts <- sum(. == correct_response_symbol, na.rm = TRUE)
          total_non_na <- sum(!is.na(.))
          if (total_non_na > 0) {
            (correct_counts / total_non_na) * 100
          } else {
            NA
          }
        })) |>
        mutate(Key = "PercentCorrect") |>
        select(Key, everything()) |>
        mutate(across(-Key, as.character))
      
      filteredData <-
        bind_rows(filteredData, NumCorrect, PercentCorrect)
      
      Filtered(filteredData)
    }
  })
  
  observeEvent(input$acknowledge, {
    removeModal()
  })
  
  output$show_inputs <- renderTable({
    AllInputs()
  })
  
  output$result <- renderPlot({
    plotData <- Filtered() |>
      slice(n()) |>
      select(-c(1, 2))
    
    longPlotData <- plotData |>
      pivot_longer(cols = everything(),
                   names_to = "Date",
                   values_to = "Percentage") |>
      mutate(Date = factor(Date, levels = sort(unique(Date)))) |>
      mutate(Percentage = as.numeric(as.character(Percentage)))
    
    ggplot(longPlotData, aes(x = Date, y = Percentage)) +
      geom_bar(stat = "identity", fill = "orange") +
      geom_hline(
        aes(yintercept = input$goalPercentage),
        color = "black",
        linetype = "solid"
      ) +
      geom_text(
        aes(
          x = Inf,
          y = input$goalPercentage,
          label = "Goal!",
          vjust = -0.5,
          family = "Ubuntu"
        ),
        hjust = 1.05,
        color = "black"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(
          hjust = 1,
          size = 14,
          family = "Ubuntu"
        ),
        axis.text.y = element_text(size = 14, family = "Ubuntu"),
        axis.title.x = element_text(size = 14, family = "Ubuntu"),
        axis.title.y = element_text(size = 14, family = "Ubuntu"),
        plot.title = element_text(
          size = 16,
          hjust = 0.5,
          family = "Ubuntu"
        )
      ) +
      labs(x = "Date", y = "Independent/Correct Response", title = "Student's Progress Monitoring") +
      scale_x_discrete(
        labels = function(x)
          gsub(".*?(\\d+).*", "\\1", x)
      ) +
      scale_y_continuous(limits = c(0, 100),
                         breaks = c(20, 40, 60, 80, 100))
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("progress-monitoring-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      allInputs <- AllInputs()
      write.csv(allInputs, file, row.names = FALSE)
    }
  )
})#