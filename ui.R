#---------------------------------------------------
# USER INTERFACE
# The ui is the part you see and where the user can interact.

# Create a dashboard header
header <- dashboardHeader(title = "COVID Age distribution")

menu <- sidebarMenu(
  menuItem("Age distribution",tabName = "age", 
           icon = icon("chart-bar")),
  menuItem("Testing", tabName = "test",
           icon = icon("chart-line"))
)

# Create the dashboard sidebar
side <- dashboardSidebar(
  menu,
  selectInput("region", label = h3("Select region"),
              choices = c("Belgium","Flanders","Brussels","Wallonia"),
              selected = "Belgium"),
  selectInput("gender",label = h3("Select gender"),
              choices = c("Male" = "M","Female" = "F","All"),
              selected = "All"),
  sliderInput("daterange","Select a date range",
              min = as.Date("2020-03-15"),
              max = as.Date(Sys.Date() - 4),
              value = c(as.Date("2020-03-15"),Sys.Date() - 4),
              timeFormat = "%b %d"),
  checkboxGroupInput("agecats",
                     "Select age categories",
                     choices = agegroups,
                     selected = agegroups,
                     inline = TRUE),
  actionButton("closed","CLOSE")
)

# Create the body of the dashboard

agetab <- tabItem(
  tabName = "age",
  fluidRow(
    column(12,h3(textOutput("thetitle"), align = "center"))
  ),
  fluidRow(
    column(6,plotOutput("ageplot")),
    column(6,plotOutput("caseplot"))
  ),# END PLOTS
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
    plotOutput("testplot")
  )
)


body <- dashboardBody(
  tabItems(
    agetab,
    testtab
  )
) # END dashboardBody

# Combine into a page
dashboardPage(
  header,
  side,
  body)
