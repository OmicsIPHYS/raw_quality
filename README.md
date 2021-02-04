In order to use it, open the app.R, and press RUN.

After selecting the files, wait to UPLOADED complete before press genarate report.


to download libraries:

pkgs <- c('dplyr', 'hexbin', 'protViz', 'RSQLite', 'scales', 'tidyr', 'tidyverse', 'shiny')
pkgs <- pkgs[(!pkgs %in% unique(installed.packages()[,'Package']))]
if(length(pkgs) > 0){install.packages(pkgs)}


install.packages('http://fgcz-ms.uzh.ch/~cpanse/rawDiag_0.0.38.tar.gz', repo=NULL)



install.packages('http://fgcz-ms.uzh.ch/~cpanse/rawrr_0.2.1.tar.gz', repo=NULL)
