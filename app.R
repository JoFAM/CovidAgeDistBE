#----------------------------------------------------
# Covid age distribution for Belgium
# Shiny app as illustration for introduction to Shiny
# author: Joris Meys
#----------------------------------------------------

source("checkPackages.R")
if(!exists("cases")){
    source("processData.R")
}
agegroups <- sort(unique(cases$AGEGROUP))

library(shiny)
library(shinydashboard)

#---------------------------------------------------
# USER INTERFACE
# The ui is the part you see and where the user can interact.

# Create a dashboard header
header <- dashboardHeader(title = "COVID Age distribution")

# Create the dashboard sidebar
side <- dashboardSidebar(
    selectInput("region", label = h3("Select region"),
                choices = c("Flanders","Brussels","Wallonia")),
    selectInput("gender",label = h3("Select gender"),
                choices = c("Male","Female","All")),
    actionButton("closed","CLOSE")
)

# Create the body of the dashboard
body <- dashboardBody(
    fluidRow(
        column(12,h3(textOutput("thetitle"), align = "center"))
    ),
    fluidRow(
        column(6,plotOutput("ageplot")),
        column(6,plotOutput("caseplot"))
        
    ), # END fluidRow ageplot
    fluidRow(
        column(6, align = "center",
               sliderInput("daterange","Select a date range",
                           min = as.Date("2020-03-15"),
                           max = as.Date(Sys.Date()),
                           value = as.Date(c("2020-03-15","2020-05-15")),
                           timeFormat = "%b %d"
                           ) 
               ), # END column slider
        column(6, align = "center",
               checkboxGroupInput("agecats",
                                  "Select age categories",
                                  choices = agegroups,
                                  selected = agegroups,
                                  inline = TRUE)
               ) #END column checkboxGroupInput
    ) ,# END fluidRow slider
    fluidRow(
        column(width = 2),
        column(width = 8,
               p(paste(readLines("Explanation.txt"),collapse="\n"),
                 style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px")),
        column(width = 2)
    )
) # END dashboardBody

# Combine into a page
ui <- dashboardPage(
    header,
    side,
    body)

#--------------------------------------------
# SERVER
# The server side does the actual calculations etc.
server <- function(input, output) {
    
    # Data selection for the plot
    agedata <- reactive({
        tmp <- cases[c("DATE","AGEGROUP")]
        tmp[["counts"]] <- cases[[input$gender]]
        
        # select the values we need: drop 0 because we use a log scale!
        id <- cases[["REGION"]] == input$region & 
            cases[["AGEGROUP"]] %in% input$agecats
        tmp[id,]
    })
    
    # Make title: dependent on input changes
    output$thetitle <- renderText({
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
            scale_fill_gradient(low="white", high = "darkred") +
            theme_minimal() +
            labs(x = "Date", y ="Age group",
                 fill = "") +
            # Format the X axis for dates
            scale_x_date(date_labels = "%b %d") +
            # Use this to avoid replacing values outside range with NA!
            coord_cartesian(xlim = input$daterange)
    })
    
    # create the other plot
    output$caseplot <- renderPlot({
        ggplot(agedata(), aes(x = DATE, y = counts, fill = AGEGROUP)) +
            geom_col(position = position_stack(reverse = TRUE),
                     width = 1) +
            labs(x = "Date", y = "Number of cases",
                 fill = "Age group") +
            # Format the X axis for dates
            scale_x_date(date_labels = "%b %d") +
            # Use this to avoid replacing values outside range with NA!
            coord_cartesian(xlim = input$daterange)
    })
    
    observeEvent(input$closed,{
        stopApp()
    })
}

#----------------------------------
# Run the application 

shinyApp(ui = ui, server = server)
