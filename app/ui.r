packages.used=c("shiny", "plotly", "shinydashboard", "leaflet")

# check packages that need to be installed.
packages.needed=setdiff(packages.used, 
                        intersect(installed.packages()[,1], 
                                  packages.used))
# install additional packages
if(length(packages.needed)>0){
  install.packages(packages.needed, dependencies = TRUE)
}


library(shiny)
library(plotly)
library(leaflet)
library(shinydashboard)

shinyUI(
dashboardPage(
  dashboardHeader(title = "Medic",
                  titleWidth = 260),
  skin = "blue",
  dashboardSidebar(
    width = 260,
    sidebarMenu(
      id = "tabs",
      menuItem("Welcome", tabName = "Welcome1", icon = icon("book")),
      menuItem(
        "Introduction",
        icon = icon("file-text-o"),
        menuSubItem("Read Me", tabName = "ReadMe", icon = icon("angle-right")),
        menuSubItem(
          "Criterion Measurement",
          tabName = "CM",
          icon = icon("angle-right")
        ),
        menuSubItem(
          "About Team",
          tabName = "AboutTeam",
          icon = icon("angle-right")
        )
      ),
      menuItem(
        "Summary Statistics",
        tabName = "SummaryStat",
        icon = icon("area-chart")
      ),
      menuItem(
        "Hospital Recommendation",
        tabName = "HospitalRecommend",
        icon = icon("table")
      )
    ),
    
    hr()
    
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "Welcome1",
              mainPanel(
                img(
                  src = "logo.png",
                  height = 800,
                  width = 1000
                )
              )),
      
      tabItem(tabName = "SummaryStat",
              fluidRow(
                tabBox(
                  width = 12,
                  tabPanel(
                    title = "Rating VS Payment",
                    width = 12,
                    plotlyOutput("Rating.Payment", height = 570)
                  ),
                  
                  tabPanel(title = "7 Measurements",
                           fluidRow(
                             column(width = 3,
                                    br(),
                                    selectInput("State", label = "State", selected = "NY", 
                                                choices = as.character(unique(hos$State)))),
                             
                             column(width = 9,
                                    plotOutput("measurements", height = 570))
                           )    
                  ),
                  
                  tabPanel(title = "Number of Hospitals by State\n", plotlyOutput("NHS", height = 570)),
                  
                  tabPanel(
                    title = "Hospital Quality by State\n",
                    width = 12,
                    plotlyOutput("HQS", height = 570)
                  )
                )
              )),
      
      tabItem(tabName = "HospitalRecommend",
              
              fluidRow(
                
                  width = 12,
                    column(width = 2,
                      #select state
                      selectInput("state", label = "State", selected = "Select", choices = append("Select",as.character(unique(hos$State)))),
                      #select hospital type
                      selectInput("type", label = "Type", selected = "Select", choices = c("Select","Acute Care Hospitals","Critical Access Hospitals","Childrens")),
                      textInput("user_zip", label = "Zipcode", value = "10025", width = NULL, placeholder = "Please type your 5-digit zip code here"),
                      radioButtons("dst", label = "Hospitals Within", choices = list("5 Miles"=5,"20 Miles"=20,"50 Miles"=50,"NA"=100000),selected = 100000,inline = T),
                      radioButtons("money", label = "Cost", choices = list("$"=1,"$$"=2,"$$$"=3,"$$$$"=4,"NA"=0),selected = 0,inline = T),
                      radioButtons("emg",label = "Emergency Services",choices = list("Yes" = 1,"No" = 2,"NA" = 0),selected = 0,inline = T),
                      br(),
                      submitButton("Submit", width = "70%")      
                    ),
                    column(width = 10, height=1,
                           strong('Current Location:'),
                           h5(textOutput("u_city_state"))),
                    tabBox(
                      width = 10,
                      tabPanel(
                        title = "Map",
                        width = 10,
                        solidHeader = T,
                        leafletOutput("map")
                      )
                    ),
                    column(width = 10, offset=2,
                      tabPanel('Search Results', dataTableOutput("tableinfo"), tags$style(type = "text/css", '#myTable tfoot {display:none;}'))
                    )
              )),
      
      tabItem(
        tabName = "ReadMe",
        mainPanel(
          h2(textOutput("read0")),
          textOutput("read1"),
          hr(),
          h3(textOutput("read2")),
          textOutput("read3"),
          textOutput("read4"),
          textOutput("read5"),
          textOutput("read6"),
          hr(),
          h3(textOutput("read7")),
          textOutput("read8"),
          a("Here", href = "https://www.medicare.gov/hospitalcompare/search.html")
        )
      ),
      tabItem(
        tabName = "CM",
        mainPanel(
          h3(textOutput("read9")),
          textOutput("read10"),
          textOutput("read11"),
          textOutput("read12"),
          textOutput("read13"),
          textOutput("read14"),
          textOutput("read15"),
          textOutput("read16"),
          hr(),
          textOutput("read17"),
          a("Here", href = "https://www.medicare.gov/hospitalcompare/Data/Measure-groups.html")
        )
      ),
      tabItem(
        tabName = "AboutTeam",
        mainPanel(
          h3(textOutput("team0")),
          textOutput("team1"),
          textOutput("team2"),
          textOutput("team3"),
          textOutput("team4"),
          textOutput("team5"),
          textOutput("team6"),
          hr(),
          textOutput("team7")
        )
      )
      
    )
  )
,
tags$head(
  tags$link(rel = "stylesheet", type = "text/css", href = "links.css")
))
)
