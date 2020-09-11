#----------------------------------------------------
# Covid age distribution for Belgium
# Shiny app as illustration for introduction to Shiny
# author: Joris Meys
#----------------------------------------------------

source("checkPackages.R")


library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(tidyr)

if(!exists("cases")){
  source("processData.R")
}

agegroups <- sort(unique(cases$AGEGROUP))
