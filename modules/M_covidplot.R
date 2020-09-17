# This module generates a plot with tag and download information,
# with a download button underneath.
library(shiny)

covidplotUI <- function(id){
  ns <- NS(id)
  
  tagList(
    plotOutput(ns("theplot")),
    downloadButton(ns("plotdownload"),
                   label = "Download")
  )
}

plotserver <- function(input, output, session, theplot){
  
  fullplot <- reactive({
    theplot() + 
      caption +
      theme(plot.tag.position = "bottomright")
  })
  
  
}
