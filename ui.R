#---------------------------------------------------
# USER INTERFACE
# The ui is the part you see and where the user can interact.

# Create a dashboard header
header <- dashboardHeader(title = "COVID Age distribution")

menu <- sidebarMenu(
  menuItem("Age distribution",tabName = "age", 
           icon = icon("chart-bar")),
  menuItem("Testing", tabName = "test",
            icon = icon("chart-line"))#,
  # menuItem("Hospitalisations", tabName = "hospit",
  #           icon = icon("procedures"))
)

# Create the dashboard sidebar
side <- dashboardSidebar(
  menu,
  sliderInput("daterange","Select a date range",
              min = as.Date("2020-03-15"),
              max = as.Date(Sys.Date() - 4),
              value = c(Sys.Date()-64,Sys.Date() - 4),
              timeFormat = "%b %d"),
  actionButton("closed","CLOSE")
)

# Create the body of the dashboard

agetab <- tabItem(
  tabName = "age",
  fluidRow(
    column(12,h3(textOutput("thetitle"), align = "center"))
  ),
  fluidRow(
    column(6,plotOutput("ageplot"),
           downloadButton("downloadheatmap")),
    column(6,plotOutput("caseplot"),
           downloadButton("downloadagebar"))
  ),# END PLOTS
  fluidRow(
    column(2,align = "center",
    selectInput("region", label = "Select region",
                choices = c("Belgium","Flanders","Brussels","Wallonia"),
                selected = "Belgium")),
    column(2,align = "center",
    selectInput("gender",label = "Select gender",
                choices = c("Male" = "M","Female" = "F","All"),
                selected = "All")),
    column(2,
           awesomeRadio(inputId = "relativeage",
                           label = "Select variable for heatmap",
                           choices = c("Absolute cases" = "abs",
                                       "cases per 100k" = "rel",
                                       "Change cases" = "change",
                                       "Change cases per 100k" = "relchange",
                                       "% change" = "perchange"),
                           status = "primary",
                        checkbox = TRUE)),
    column(4, offset = 1, align = "center",
          checkboxGroupButtons("agecats",
                             "Select age categories",
                             choices = agegroups,
                             selected = agegroups,
                             justified = FALSE,
                             individual = TRUE,
                             status = "primary",
                             checkIcon = list(yes = icon("ok", 
                                                         lib = "glyphicon"), 
                                              no = icon("remove", 
                                                        lib = "glyphicon"))))
  ),
  fluidRow(
    column(width = 2),
    column(width = 8,
           p(paste(readLines("Explanation.txt"),collapse="\n"),
             style="text-align:justify;color:black;background-color:lavender;padding:15px;border-radius:10px")),
    column(width = 2)
  )
)

testtab <- tabItem(
  tabName = "test",
  fluidRow(
    column(6,
           plotOutput("testplot"),
           downloadButton("downloadtest")
           )
    
  )
)

# hospittab <- tabItem(
#   tabName = "hospit",
#   fluidRow(
#     column(6,plotOutput("hospitplot"),
#            downloadButton("downloadhospit"))
#   )
# )
# 

body <- dashboardBody(
  tabItems(
    agetab,
    testtab#,
    #hospittab
  )
) # END dashboardBody

# Combine into a page
dashboardPage(
  header,
  side,
  body)
