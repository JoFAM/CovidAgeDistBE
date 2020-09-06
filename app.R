#----------------------------------------------------
# Covid age distribution for Belgium
# Shiny app as illustration for introduction to Shiny
# author: Joris Meys
#----------------------------------------------------

source("checkPackages.R")

library(shiny)
library(shinydashboard)

#---------------------------------------------------
# USER INTERFACE
# The ui is the part you see and where the user can interact.
ui <- dashboardPage(
    dashboardHeader(title = "COVID Age distribution"),
    
    dashboardSidebar(
        selectInput("region", label = h3("Select region"),
                    choices = c("Flanders","Brussels","Wallonia")),
        selectInput("gender",label = h3("Select gender"),
                    choices = c("Male","Female","All"))
    ), # END dashboardSidebar
    
    dashboardBody(
        fluidRow(
            plotOutput("ageplot")
        ), # END fluidRow ageplot
        fluidRow(
            column(12, align = "center",
                   sliderInput("daterange","Select a date range",
                               min = as.Date("2020-03-15"),
                               max = as.Date(Sys.Date()),
                               value = as.Date(c("2020-03-15","2020-05-15"))
                               ) 
                   ) # END column slider
        )# END fluidRow slider
    ) # END dashboardBody
) # END shinydashboard

#--------------------------------------------
# SERVER
# The server side does the actual calculations etc.
server <- function(input, output) {
    
    # Data selection for the plot
    agedata <- reactive({
        tmp <- cases[c("DATE","AGEGROUP")]
        tmp[["counts"]] <- cases[[input$gender]]
        
        # select the values we need: drop 0 because we use a log scale!
        id <- cases[["REGION"]] == input$region & tmp[["counts"]] != 0
        tmp[id,]
    })
    
    # Make title: dependent on input changes
    thetitle <- reactive({
        paste("Number of cases by age group for",
              switch(input$gender,
                     Male = "males",
                     Female = "females",
                     All = "all genders"),
              "in",
              input$region)
    })

    # Create the plot
    output$ageplot <- renderPlot({
        ggplot(agedata(), mapping = aes(x=DATE,y=AGEGROUP, fill = counts)) +
            geom_tile() +
            scale_fill_gradient(low="white", high = "darkred",
                                trans = "log",
                                breaks = c(1,10,30,100,300,1000,3000)) +
            theme_minimal() +
            labs(x = "Date", y ="Age group",
                 fill = "", title = thetitle()) +
            # Format the X axis for dates
            scale_x_date(date_labels = "%b %d") +
            # Use this to avoid replacing values outside range with NA!
            coord_cartesian(xlim = input$daterange)
    })
}

#----------------------------------
# Run the application 

shinyApp(ui = ui, server = server)
