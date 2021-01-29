library(rawDiag)
library(rmarkdown)
library(shiny)
library(kableExtra)
library(knitr)
shinyApp(
  ui = fluidPage(
    fileInput(inputId = 'rawfiles',label = 'Insert the raw file,', multiple = TRUE),
    #textInput(inputId = 'pattern', label = 'Insert pattern to remove:',value = ''),
    downloadButton("report", "Generate report")
  ),
  server = function(input, output) {
    options(shiny.maxRequestSize=100*1024^5)
    upload = list()

    RAW <- reactive({
      
      rawFileNames <- list()

      
      for (i in 1:length(input$rawfiles[,1])){
        rawFileNames[[i]] <- read.raw(input$rawfiles[[i, 'datapath']])
        # #create a list with the raw names of the file
        # file_name<- c(file_name,input$rawfiles[[i]])
        # 
        # raw_name <- c(raw_name, rawFileNames[[i]]$filename)
      }
      
      RAW <- plyr::rbind.fill(rawFileNames)

      return(RAW)

    })


    table_names <- reactive({


#################

      raw_name = input$rawfiles$name
#####################
      
      file_name = c()
      rawFileNames <- list()
      
      for (i in 1:length(input$rawfiles[,1])){
        rawFileNames[[i]] <- read.raw(input$rawfiles[[i, 'datapath']])
        file_name <- append(file_name, rawFileNames[[i]]$filename) 
      }
      
      
      file_name <- unique(file_name)
      # for (i in 1:length(input$rawfiles[,1])){
      #   rawFileNames[[i]] <- read.raw(input$rawfiles[[i, 'datapath']])
      #   #create a list with the raw names of the file
      #   file_name<- append(file_name,input$rawfiles[[i]])
      # 
      #   raw_name <- append(raw_name, rawFileNames[[i]]$filename)
      # 
      # }
      #table_all <- data.frame(file_name, raw_name)
      # vec1 <- 1:10
      # vec2 <- letters[1:10]
      #
      table_all <-  data.frame(raw_name,file_name)
      return(table_all)

    })

    output$report <- downloadHandler(
      
      # For PDF output, change this to "report.pdf"
      filename = "report.pdf",
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed).
        tempReport <- file.path(tempdir(), "report.Rmd")
        file.copy("report.Rmd", tempReport, overwrite = TRUE)
        
        # Set up parameters to pass to Rmd document
        ##params <- list(file1 = RAW()[[1]])
        params <- list(file1 = RAW(), 
                       file2=table_names())
        
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the documenta
        # from the code in this app).
        rmarkdown::render(tempReport, output_file = file,
                          params = params,
                          envir = new.env(parent = globalenv())
        )
      }
    )
  }
)
