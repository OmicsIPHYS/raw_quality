library(rawDiag)
library(readr)


shinyApp(
  ui = fluidPage(
    fileInput(inputId = 'rawfiles',label = 'Insert the raw file,', multiple = TRUE),
    downloadButton("report", "Generate report")
  ),
  server = function(input, output) {
    options(shiny.maxRequestSize=100*1024^5)
    
    RAW <- reactive({
      #req(input$files)
      upload = list()
      #inFile <- input$rawfile
      
      #if (is.null(inFile))
       # return(NULL)
      
      for(i in 1:length(input$rawfiles[,1])){
        upload[[i]] <- read.raw(input$rawfiles[[i, 'datapath']])
      }
      
      
      #tb1 <- read.raw(inFile$datapath)
      

      
      return(upload)
      
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
        params <- list(file1 = RAW())
        
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
