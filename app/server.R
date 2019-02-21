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

# switch payment to dollar signs
payswitch <- function(payment){
  if(is.na(payment)) {return("Not Avaliable")}
  else {if(payment<=1.667) {return("$")}
    else{if(payment<=2) {return("$$")}
      else{if(payment<=2.25) {return("$$$")}
        else{return("$$$$")}}}}
}

# switch overall rating
orswitch <- function(rating){
  if(is.na(rating)){return("Not Available")}
  else {return(as.numeric(rating))}
}

#calculate geo distance
calDis <- function(row, u_long, u_lat){
  distance = abs(distHaversine(c(as.numeric(row[38]),as.numeric(row[37])), c(u_long,u_lat), r=3963.190592))
  return(distance)
}

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
        infotable

    },
    options = list(orderClasses = TRUE, iDisplayLength = 5, lengthMenu = c(5, 10, 15, 20),
                   columnDefs = list(list(targets = c(0:10), searchable = FALSE)),
                   autoWidth = FALSE, columnDefs = list(list(width = '250px', targets = "_all"))
                   )
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
  
  output$read0<- renderText({"Introduction"})
  output$read1<- renderText({"Greetings! If you are thinking of finding a hospital you can go, you can just save your time and look at our app. Our group has created an app helping you to find the best hospitals around you based on your preference on 7 aspects of hospitals including mortality, safety of care, readmission rate, patient experience, effectiveness of care, timeliness of care and efficient use of medical imaging. With your choice, it will be so easy to find the one fits you the best."})
  output$read2<- renderText({"User Manual"})
  output$read3<- renderText({"-> Step 1: Choose the State you live in or you need to go to. Simultaneously, you can also specify the type of hospital you may go to."})
  output$read4<- renderText({"-> Step 2: Choose how much do your care about on the each of the seven aspects of a hospital."})
  output$read5<- renderText({"-> Step 3: Check the Medicare Assessment table for the basic information of all hospitals, and the most importantly check the Personalized Ranking table to see which are the best ones for you."})
  output$read6<- renderText({"-> Step 4: Click on the map to see the exact location of the hospital and gogogo!"})
  output$read7<- renderText({"Data Source"})
  output$read8<- renderText({"The data is provided by Medicare government website, for more information, click the link below:"})
  output$read9<- renderText({"Criterion Measurement"})
  output$read10<- renderText({"1. Mortality measures the death rate of patients."})
  output$read11<- renderText({"2. Safety of care measures the rate of certain complications and infections."})
  output$read12<- renderText({"3. Readmission measures the rate of unplanned readmission after treatment."})
  output$read13<- renderText({"4. Patient experience measures how well patients feel during treatment, surgery and hospitalization."})
  output$read14<- renderText({"5. Effectiveness of care measures how appropriately patients are treated."})
  output$read15<- renderText({"6. Timeliness of care measures the time patients waiting."})
  output$read16<- renderText({"7. Efficient use of medical imaging measures how efficiently the hospitals using medical imaging such as MRI and CT scans."})
  output$read17<- renderText({"For more information, click the link below:"})
  
  
  output$team0<- renderText({"About Team"})
  output$team1<- renderText({"This app is developed in Spring 2018 by: "})
  output$team2<- renderText({"-> Guo, Xiaoxiao (email: xg2282@columbia.edu)"})
  output$team3<- renderText({"-> He, Shan (email: sh3667@columbia.edu)"})
  output$team4<- renderText({"-> Utomo, Michael (email: mu2251@columbia.edu)"})
  output$team5<- renderText({"-> Wen, Lan (email: lw2773@columbia.edu)"})
  output$team6<- renderText({"-> Yao, Jingtian (email: jy2867@columbia.edu)"})
  output$team7<- renderText({"We are a group of Columbia University M.A. in Statistics students eager to make the world an easier place to live in, and we are taking a tiny step here by developing this app to help you find the best and most fitted hospitals. Good luck!"})
  
  
  
  output$VI <- renderPlotly({
    
    b <- ggplot(importance.df, aes(x=Variables, y=MeanDecreaseGini)) +   
         geom_point(size = importance.df$MeanDecreaseGini/12,  
                    color = c("#999999", "#E69F00", "#56B4E9", "#009E73",  
                              "#F0E442", "#0072B2", "#D55E00"),  
                    alpha = 0.6) +
         theme(axis.text.x = element_text(angle = 40))+
         ggtitle('Variable Importance')+
         ylab("Mean Drop Gini")+
         theme(plot.title=element_text(hjust=0.5))
    
    ggplotly(b) %>% layout(height = 700, width = 1000)
    
  }
  
  )
  
  output$NHS <- renderPlotly({
  
    c <- ggplot(df, aes(x=State, y = Freq))+
      geom_bar(stat="identity", aes(fill = df$Freq))+
      labs(title= "Number of Hospitals by State", x="State", y=NULL)+
      theme_classic()+
      theme(axis.text.x = element_text(angle=90, size = 8))+
      theme(plot.title= element_text(hjust=0.5, vjust=1))+
      scale_y_continuous(expand = c(0,0))+
      theme(plot.margin = unit(c(1,1,1,1), "cm"))
    ggplotly(c) %>% layout(height = 700, width = 1000)
    
      c + scale_fill_continuous(name="Frequency")
  }
  
  )
  
  output$HQS <- renderPlotly({
    
    d <- ggplot(hospital_ratings.df, aes(x=State, y=HospitalRating))+
      geom_bar(stat="identity", alpha = 0.7, fill = "#009E73") +
      labs(title="Hospital Quality by State", x="State", y="Quality - OverallRating (1-5)")+
      theme_classic()+
      theme(axis.text.x=element_text(angle=90, hjust=1, size = 8))+
      theme(plot.title=element_text(hjust=0.5))+
      ylim(0,5)+
      theme(plot.margin = unit(c(1,1,1,1), "cm"))
    ggplotly(d) %>% layout(height = 700, width = 1000)
    
  }
  
  )

 })