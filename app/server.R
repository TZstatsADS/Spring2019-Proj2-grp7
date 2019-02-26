packages.used=c("dplyr", "plotly", "shiny", "leaflet", "scales", 
                "lattice", "htmltools", "maps", "data.table", 
                "dtplyr", "mapproj", "randomForest", "ggplot2", "rpart", "zipcode", "geosphere")

# check packages that need to be installed.
packages.needed=setdiff(packages.used, 
                        intersect(installed.packages()[,1], 
                                  packages.used))
# install additional packages
if(length(packages.needed)>0){
  install.packages(packages.needed, dependencies = TRUE)
}

library(shiny)
library(leaflet)
library(scales)
library(lattice)
library(dplyr)
library(htmltools)
library(maps)
library(plotly)
library(data.table)
library(dtplyr)
library(mapproj)
library(randomForest)
library(ggplot2)
library(rpart)
library(zipcode)
library(geosphere)
library(fmsb)

# Import function from scripts in lib
source("../lib/datatable_func.R")

# Import the data for the third part of general statistics section
data_general3 = read.csv("../output/Hospital_count_by_state.csv", header = FALSE)
colnames(data_general3) = c("state.abb","hospital.number")

shinyServer(function(input, output){
  #read data
  load("./hos.RData")
  load("./importance.RData")
  load("./df.RData")
  load("./hospital_ratings.RData")
  data(zipcode)
  
  data <- hos

  #Inputs
  
  state<- reactive({state <- input$state})
  type <- reactive({type <- input$type})
  user_zip <- reactive({user_zip <- input$user_zip})
  dst <- reactive({dst <- input$dst})
  money <- reactive({money <- input$money})
  emg <- reactive({input$emg})
  
  v1<-reactive({
    if (state() == "Select") {v1 <- hos} 
    else {v1<- hos %>% filter(State == state())}
  })  
  
  v2 <- reactive({
    if (type() == "Select") {v2 <- v1()}
    else{v2 <- v1() %>% filter(Hospital.Type == type())}
  })
  
  v2_dis <- reactive(apply(data.frame(v2()), 1, calDis, 
                           u_long = zipcode[(zipcode$zip == user_zip()),][,5], u_lat = zipcode[(zipcode$zip == user_zip()),][,4]))
  
  v3 <- reactive({v3 <- cbind(data.frame(v2()), Distance = v2_dis())})
  
  v4 <- reactive({v4 <- v3() %>% filter(Distance <= as.numeric(dst()))})
  
  v5 <- reactive({
    if (money() == 0) {v5 <- v4()}
    else{if(money() == 1) {
    v5 <- v4() %>% filter(new_pay == "$")}
      else{if(money() == 2) {
      v5 <- v4() %>% filter(new_pay == "$$")}
        else{if(money() == 3) {
        v5 <- v4() %>% filter(new_pay == "$$$")}
          else{if(money() == 4) {
          v5 <- v4() %>% filter(new_pay == "$$$$")}
  }}}}})
  
  v6 <- reactive({
    if (emg() == 0) {v6 <- v5()}
    else{if(emg() == 1) {
    v6 <- v5() %>% filter(Emergency.Services == "Yes")}
      else{if(emg() == 2) {
      v6 <- v5() %>% filter(Emergency.Services == "No")}
 }}})
  
  v7 <- reactive({
    v7_temp = v6()
    if (money() == 0){v7 <- v7_temp[order(-v7_temp$Points_A_Cost),]}
    else{v7 <- v7_temp[order(-v7_temp$Points),]}
  })
  
  # Outputs
  output$u_city_state = renderText(
    paste(zipcode[(zipcode$zip == user_zip()),][,2], " ", zipcode[(zipcode$zip == user_zip()),][,3]) #city & state
  )
  
  output$tableinfo = renderDataTable(
      {
        data1 <- v7()
        infotable <- data1[, c(2, 3, 4, 5, 9, 11, 40, 42, 44, 47, 13)]
        infotable$Hospital.overall.rating <- apply(data.frame(as.numeric(data1$Hospital.overall.rating)),1,orswitch)
       colnames(infotable) <- c("Hospital Name","Address","City","State", "Type", "Emergency Services", "Strength", "Weakness", "Cost", "Distance in Miles", "Overall Rating")
       infotable[,'Hospital Name'] <- createLink(infotable[,'Hospital Name'])
        infotable

    },
    options = list(orderClasses = TRUE, iDisplayLength = 5, lengthMenu = c(5, 10, 15, 20),
                   columnDefs = list(list(targets = c(0:10), searchable = FALSE)),
                   autoWidth = FALSE, columnDefs = list(list(width = '250px', targets = "_all"))
                   ),
    escape = FALSE
  )
  
  hospIcons <- iconList(emergency = makeIcon("emergency_icon.png", iconWidth = 25, iconHeight =30),
                        critical = makeIcon("critical_icon.png", iconWidth = 25, iconHeight =30),
                        children = makeIcon("children_icon.png", iconWidth = 20, iconHeight =30))
  
  
  
  output$map <- renderLeaflet({
    content <- paste(sep = "<br/>",
                     paste("<font size=1.8>","<font color=green>","<b>",v7()$Hospital.Name,"</b>"),
                     paste("<font size=1>","<font color=black>",v7()$Address),
                     paste(v7()$City, v7()$State, v7()$ZIP.Code, sep = " "),  
                     paste("(",substr(v7()[ ,"Phone.Number"],1,3),") ",substr(v7()[ ,"Phone.Number"],4,6),"-",substr(v7()[ ,"Phone.Number"],7,10),sep = ""), 
                     paste("<b>","Hospital Type: ","</b>",as.character(v7()$Hospital.Type)),  
                     paste("<b>","Provides Emergency Services: ","</b>",as.character(v7()[ ,"Emergency.Services"])),
                     paste("<b>","Overall Rating: ","</b>", as.character(v7()[ ,"Hospital.overall.rating"])))
    
    
    mapStates = map("state", fill = TRUE, plot = FALSE)
    leaflet(data = mapStates) %>% addTiles() %>%
      addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE) %>%
      addMarkers(v7()$lon, v7()$lat, popup = content, icon = hospIcons[v7()$TF], clusterOptions = markerClusterOptions())
  })
  
  output$welcome1 <- renderText({"Find your perfect hospital"})
  output$welcome2 <- renderText({"The United States has one of the most complicated and expensive healthcare systems in the world. However, healthcare is a basic necessity that everyone deserves and, regardless of your insurance, you should be able to find the best hospital for you."})
  output$welcome3 <- renderText({"Medic provides two key features to solving this healthcare mystery: "})
  output$welcome4 <- renderText({"1. Key Statistics"})
  output$welcome5 <- renderText({"2. Hospital Recommendations"})
  output$welcome6 <- renderUI(HTML("Explore and investigate hospitals nationwide: 
                                     <ul><li>Hospital assessments using 7 criteria: Mortality, Safety, Readmission, Patient Experience, Effectiveness, Timeliness, and Medical Image Effectiveness</li>
                                         <li>Insurance coverage vs. Patient payment ratio and amounts</li>
                                         <li>Number of hospitals in each state </li></ul>"))
  output$welcome7 <- renderText({"Search and find the best hospital nearby you."})
  #output$welcome8 <- renderText({"Use an interactive map and table to filter the hospitals based on these key features:"})
  output$welcome8 <- renderUI(HTML("Interact with the map, table, and filters to find your perfet hospital:
                                     <ul><li> State, type, zipcode, distance, cost, and availability of emergency services</li>
                                         <li> Click on hospitals to see further reports on the hospital by US News</li>
                                         </ul>"))
  
  output$datapage1 <- renderText({"Data Source"})
  output$datapage2<- renderText({"The data was provided/imported from the US Government Open Data website:"})
  output$datapage3 <- renderText({"Data Definitions"})
  output$datapage4 <- renderUI(HTML("<ul><li><b>Mortality</b>: Death rate of patients </li>
                                   <li><b>Safety</b>: Rate of infection and complication after surgery</li>
                                   <li><b>Readmission</b>: Rate of unplanned readmission after surgery and its return days </li>
                                   <li><b>Patient Experience</b>: Patients' reports about communication, pain control, help, sanitation, and overall care </li>
                                   <li><b>Effectiveness</b>: Percentage of patients who were effectively given treatment or conducted follow-up screening/scanning upon arrival </li>
                                   <li><b>Timeliness</b>: Average time patients spent at hospital before admittance, transfer, or diagnosis from a doctor</li>
                                   <li><b>Medical Image EFfective</b>: Effectiveness in using MRI, CT, and other medical imaging technology for outpatients</li>
                                   <li><b>Strengths</b>: Criteria that the respective hospitals were assessed to be above the national average</li>
                                   <li><b>Weaknesses</b>: Criteria that the respective hospitals were assessed to be below the national average</li>

                                   </ul>"))
  output$datapage5 <- renderText({"For further details: "})
  
  
  output$team0<- renderText({"About Team"})
  output$team1<- renderText({"This app is developed in Spring 2018 by: "})
  output$team2<- renderText({"-> Guo, Xiaoxiao (email: xg2282@columbia.edu)"})
  output$team3<- renderText({"-> He, Shan (email: sh3667@columbia.edu)"})
  output$team4<- renderText({"-> Utomo, Michael (email: mu2251@columbia.edu)"})
  output$team5<- renderText({"-> Wen, Lan (email: lw2773@columbia.edu)"})
  output$team6<- renderText({"-> Yao, Jingtian (email: jy2867@columbia.edu)"})
  output$team7<- renderText({"We are a group of Columbia University M.A. in Statistics students eager to make the world an easier place to live in, and we are taking a tiny step here by developing this app to help you find the best and most fitted hospitals. Good luck!"})
  
  
  
  output$Rating.Payment <- renderPlotly({
    
    region <- data.frame(state.abb, state.region)
    region$state.abb <- as.character(region$state.abb)
    hos$State <- as.character(hos$State)
    
    hosnew <- hos %>% 
      group_by(State) %>% 
      summarise(AvgRating = round(mean(as.numeric(Hospital.overall.rating), na.rm = T),2),
                AvgPayment = round(mean(payment, na.rm = T),2),
                count = n()) %>% 
      inner_join(region, by = c("State" = "state.abb")) 
    
    p <- list()
    i = 1
    for(r in unique(hosnew$state.region)){
      df <- filter(hosnew, hosnew$state.region == r)
      p[i] <- plot_ly(df, x = ~AvgPayment, y = ~AvgRating, type = "scatter", mode = "markers",
                      color = ~state.region, size = ~count,
                      text = ~paste(State, "<br>Payment: ", AvgPayment, "<br>Rating: ", AvgRating)) 
      i = i+1
    }
    subplot(p1,p2,p3,p4,nrows = 2, shareX = T, shareY = T)
     
  }
  
  )
  
  output$measurements <- renderPlot({
    
    measurements = hos %>%
      filter(State == input$measurement_state) %>% 
      summarise(Mortality = mean(as.numeric(Mortality.national.comparison), na.rm = T),
                Safety = mean(as.numeric(Safety.of.care.national.comparison), na.rm = T),
                Readmission = mean(as.numeric(Readmission.national.comparison), na.rm = T),
                PatientExperience = mean(as.numeric(Patient.experience.national.comparison), na.rm = T),
                Effectiveness = mean(as.numeric(Effectiveness.of.care.national.comparison), na.rm = T),
                Timeliness = mean(as.numeric(Timeliness.of.care.national.comparison), na.rm = T),
                MedicalImageEffectiveness = mean(as.numeric(Efficient.use.of.medical.imaging.national.comparison), na.rm = T)) %>% 
      na.omit()
    
    
    df <- rbind(rep(3,7), rep(1,7), measurements)
    radarchart(df, axistype=1 , seg = 2, 
               cglcol="grey", axislabcol="grey",
               pcol=rgb(0.4,0.6,0.8,0.8), pfcol=rgb(0.4,0.6,0.8,0.5), plwd=2,
               caxislabels=c("below","average","above"), calcex = 1,
               vlcex=1)
    
  }
  
  )
  output$NHS <- renderPlotly({
    # specify some map projection/options
    g <- list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      lakecolor = toRGB('white')
    )
    plot_ly(z = data_general3$hospital.number, text = data_general3$state.abb, locations = data_general3$state.abb,
            type = 'choropleth', locationmode = 'USA-states') %>%
      layout(geo = g)
  })
  
  
  output$HQS <- renderPlotly({
    
    d <- ggplot(hospital_ratings.df, aes(x=State, y=HospitalRating))+
      geom_bar(stat="identity", alpha = 0.7, fill = "#009E73") +
      labs(title="Hospital Quality by State", x="State", y="Quality - OverallRating (1-5)")+
      theme_classic()+
      theme(axis.text.x=element_text(angle=90, hjust=1, size = 8))+
      theme(plot.title=element_text(hjust=0.5))+
      ylim(0,5)+
      theme(plot.margin = unit(c(1,1,1,1), "cm"))
    ggplotly(d) %>% layout(height = 550, width = 950)
    
  }
  
  )

 })