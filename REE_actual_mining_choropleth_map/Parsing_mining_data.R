#This script downloads the rare earth minerals tables from
#the following website and parse it and put it in data.frame

library(XML)
url <- "http://www.techmetalsresearch.com/metrics-indices/tmr-advanced-rare-earth-projects-index/"
html <-htmlTreeParse(url, useInternalNodes=T)

mines.table <- readHTMLTable(html,stringsAsFactors = FALSE)
mines <- mines.table$`tablepress-1`
grades <- mines.table$`tablepress-2`
distribution <- mines.table$`tablepress-3`

