library(leaflet)
library(shiny)
library(RColorBrewer)
library(rgdal)
library(plyr)
library(dplyr)
library(countrycode)

shinyUI(bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%")
 
  )
)
