library(rawDiag)
library(rmarkdown)
library(shiny)
library(kableExtra)
library(knitr)


library(protViz)
library(parallel)
library(rawrr)

library(dplyr)


shinyApp(
  ui = fluidPage(
    fileInput(inputId = 'rawfiles',label = 'Insert the raw file,', multiple = TRUE),
    checkboxInput(inputId = 'irt_check', label = 'Check for iRT peptides', value = FALSE),
    downloadButton("report", "Generate report")
  ),
  server = function(input, output) {
    options(shiny.maxRequestSize=100*1024^5)
    upload = list()

    RAW <- reactive({
      
      rawFileNames <- list()

      
      for (i in 1:length(input$rawfiles[,1])){
        rawFileNames[[i]] <- read.raw(input$rawfiles[[i, 'datapath']])

      }
      
      RAW <- plyr::rbind.fill(rawFileNames)

      return(RAW)

    })


    
    
    
    table_names <- reactive({


      raw_name = input$rawfiles$name


      file_name = c()
      rawFileNames <- list()
      
      for (i in 1:length(input$rawfiles[,1])){
        rawFileNames[[i]] <- read.raw(input$rawfiles[[i, 'datapath']])
        file_name <- append(file_name, rawFileNames[[i]]$filename) 
      }
      
      
      file_name <- unique(file_name)
      
      table_all <-  data.frame(raw_name,file_name)
      return(table_all)

    })
    
    
    
    ###irt peptides check and plot
    
    
    RAW_irt <- reactive({
      file <- input$rawfiles
      
      return(file$datapath)
      
    })
    
    #def function to get instrument model
    .getInstrumentInformation <- function(x){data.frame(model=x$`Instrument model`,
                                                        serialNumber=x$`Serial number`,
                                                        #method=x$`Instrument method`,
                                                        softwareVersion=x$`Software version`,
                                                        nMS=x$`Number of scans`,
                                                        nMS2=x$`Number of ms2 scans`)
    }
    
    
    #def function to plot both the chromatogram and the irt score
    .plotChromatogramAndFit <- function(x, i){
      par(mfrow=c(2,1))
      
      plot(x); legend("topright", legend=i, title='Instrument Model', bty = "n", cex=0.75)
      
      rt <- sapply(x, function(x) x$times[which.max(x$intensities)[1]])
      if (length(rt) == length(iRT.score)){
        fit <- lm(rt ~ iRT.score)
        plot(rt ~ iRT.score, ylab = 'Retention time [min]',
             xlab = "iRT score", pch=16, frame.plot = FALSE)
        abline(fit, col = 'grey')
        abline(v = 0, col = "grey", lty = 2)
        legend("topleft",
               legend = paste("Regression line: ", "rt =",
                              format(coef(fit)[1], digits = 4), " + ",
                              format(coef(fit)[2], digits = 2), "score", "\nR2: ",
                              format(summary(fit)$r.squared, digits = 2)),
               bty = "n", cex = 0.75)
        text(iRT.score, rt,  iRT.mZ,pos=1,cex=0.5)
      }
    }
    
    
    

    
    
    
    

    
 
    
    
    # if (input$irt_check ) {
    #   
    # 
    #   
    # 
    #   
    #   
    # 
    #   
    #   
    #   
    # }
    
    
    
    
    

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
        params <- list(RAW = RAW(), 
                       table_names=table_names(),
                       RAW_irt=RAW_irt()
                       # iRT.mZ =iRT.mZ ,
                       # iRT.score=iRT.score#,
                       # H=H(),
                       # instrumentInformation=instrumentInformation()
                       )
        
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
