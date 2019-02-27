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
        "About",
        icon = icon("file-text-o"),
        menuSubItem(
          "Meet the Team",
          tabName = "AboutTeam",
          icon = icon("angle-right")
        ),
        menuSubItem("Data", tabName = "Data", icon = icon("angle-right"))
      ),
      menuItem(
        "Key Statistics",
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
              fluidPage(
                fluidRow(
                  column(12, align="center",
                         h1(textOutput("welcome1")),
                         tags$style(type = "text/css", '#welcome1{
                                                        font-size: 40px;
                                                        margin-bottom: 30px;
                                                        }'),
                         div(style="display: inline-block; width: 100%;", img(src = "find_hospital.png", width=800))),
                  column(12,
                         textOutput("welcome2"),
                         tags$style(type="text/css", "#welcome2{
                                                      font-size:20px;
                                                      margin-top: 30px;")),
                  column(12,
                         textOutput("welcome3"),
                         tags$style(type="text/css", "#welcome3{
                                                      font-size:20px;
                                                      margin-top:20px;")),
                  column(6,
                         strong(textOutput("welcome4")),
                         tags$style(type="text/css", "#welcome4{
                                                      font-size:20px;
                                                      margin-top:10px;")),
                  column(6,
                         strong(textOutput("welcome5")),
                         tags$style(type="text/css", "#welcome5{
                                                      font-size:20px;
                                                      margin-top:10px;")),
                  column(6,
                         uiOutput("welcome6"),
                         tags$style(type="text/css", "#welcome6{
                                                      font-size:20px;
                                                      margin-top:10px;
                                                      padding:5px;}")),
                  column(6,
                         textOutput("welcome7"),
                         uiOutput("welcome8"),
                         tags$style(type="text/css", "#welcome7{
                                    font-size:20px;
                                    margin-top:10px;
                                    padding:5px;}"),
                         tags$style(type="text/css", "#welcome8{
                                    font-size:20px;
                                    margin-top:10px;
                                    padding:5px;}"))
                )
              )
              ),
      
      tabItem(tabName = "SummaryStat",
              fluidRow(
                tabBox(
                  width = 12,
                  
                  tabPanel(title = "Hospital Heatmaps",
                           fluidRow(
                             column(width = 3,
                                    br(),
                                    selectInput("MapType", label = "Type of Map", selected = "Number of Hospitals", 
                                                choices = c("Number of Hospitals", "Hospital Quality",
                                                            "Medicare Coverage Percentage")),
                                    submitButton("Submit", width = "70%")),
                             column(width = 9,plotlyOutput("heatmaps", height = 570)))),
                  
                  tabPanel(title = "7 Measurements",
                           fluidRow(
                             column(width = 3,
                                    br(),
                                    selectInput("measurement_state", label = "State", selected = "NY", 
                                    choices = as.character(unique(hos$State))[c(0:51,53)]),
                                    submitButton("Submit", width = "70%")),
                             column(width = 9,plotOutput("measurements", height = 570)))),
                  
                  tabPanel(title = "Rating VS Payment",width = 12,plotlyOutput("Rating.Payment", height = 570))
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
        tabName = "AboutTeam",
        fluidPage(
          h3(textOutput("teampage1")),
          uiOutput("teampage2"),
          tags$link(rel = "stylesheet", type="text/css", href="team.css")
        )
      ),
      
      tabItem(
        tabName = "Data",
        mainPanel(
          h3(textOutput("datapage1")),
          textOutput("datapage2"),
          a("Inpatient Prospective Payment System (IPPS)", href = "https://data.cms.gov/Medicare-Inpatient/Inpatient-Prospective-Payment-System-IPPS-Provider/97k6-zzx3"),
          br(),
          a("Hospital General Information", href = "https://data.medicare.gov/Hospital-Compare/Hospital-General-Information/xubh-q36u"),
          h3(textOutput("datapage3")),
          uiOutput("datapage4"),
          textOutput("datapage5"),
          a("Medicare Data Definitions", href = "https://www.medicare.gov/hospitalcompare/Data/Measure-groups.html")
          
        )
      )
      
    )
  )
,
tags$head(
  tags$link(rel = "stylesheet", type = "text/css", href = "links.css")
))
)
