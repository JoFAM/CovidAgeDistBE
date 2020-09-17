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

if(!dir.exists("Data")) dir.create("Data")

casefile <- tail(dir("Data",pattern = "cases.+\\.csv"),1)
allcasefile <- tail(dir("Data",pattern = "allcases.+\\.csv"),1)
hospitfile <- tail(dir("Data",pattern = "hospit.+\\.csv"),1)

if(!length(casefile) | !length(allcasefile)){
  source("processData.R")
} else {
  thedate <- gsub(".*cases(.+)\\.csv","\\1",allcasefile)
  if(as.Date(thedate) < Sys.Date()){
    source("processData.R")
  }
}

# Check data


if(!exists("cases")){
  cases <- read.csv(file.path("Data",casefile))
}
if(!exists("allcases")){
  allcases <- read.csv(file.path("Data",allcasefile))
}
if(!exists("hospit")){
  hospit <- read.csv(file.path("Data",hospitfile))
}

caption <- labs(caption = paste("data downloaded from https://epistat.wiv-isp.be/Covid/ on",thedate),
                tag = "@JorisMeys") 

agegroups <- sort(unique(cases$AGEGROUP))
