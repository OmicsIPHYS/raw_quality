library(rawDiag)
library(readr)


shinyApp(
  ui = fluidPage(
    fileInput(inputId = 'rawfile',label = 'Insert the raw file,'),
    downloadButton("report", "Generate report")
  ),
  server = function(input, output) {
    options(shiny.maxRequestSize=100*1024^5)
    
    RAW <- reactive({
      
      
      inFile <- input$rawfile
      
      if (is.null(inFile))
        return(NULL)
      
      tb1 <- read.raw(inFile$datapath)
      

      
      return(tb1)
      
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
        params <- list(file1 = RAW())
        
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        rmarkdown::render(tempReport, output_file = file,
                          params = params,
                          envir = new.env(parent = globalenv())
        )
      }
    )
  }
)