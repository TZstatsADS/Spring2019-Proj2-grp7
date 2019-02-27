# Project 2: Open Data App - an RShiny app development project

## Project Title: Medic -- Find your perfect hospital
Term: Spring 2019

### **Group 7**
+ Team Members:
	+ team member: Han, Seungwook (email: sh3264@columbia.edu)
	+ team member: Liu, Siwei (email:sl4224@columbia.edu)
	+ team member: Lu, Shuang (email:sl4397@columbia.edu)
	+ team member: Xia, Mengran (email:mx2205@columbia.edu)
	+ team member: Zeng, Yiyang (email:yizeng19@gsb.columbia.edu)
  + presenter: Han, Seungwook
  
### **Project summary**: 

<<<<<<< HEAD
=======
In a digital era where information is easy to access and more transparent than ever, people can be overwhelmed from the superfulous options and finidng it hard to make an efficient and smart choice. This can be especially when it comes 

As a result, people are paying more attention to improve their quality of life as much as possible. Then, they realize how important keeping healthy is to maximize their happiness. Visiting a hospital is one of the most useful ways to ensure the health of a person. As a consequence, selecting the most appropriate one efficiently and effectively becomes really necessary and avoids unwanted troubles.

If you are thinking of finding hispitals you can go, you can just save your time and look at our app. Our group has created an app helping you to find the best hospitals around you based on your preferences on 7 aspects of hospitals including mortality, safety of care, readmission rate, patient experience, effectiveness of care, timeliness of care and efficient use of medical imaging. With your choice, it will be so easy to find the one fits you the best.
>>>>>>> 1f42cbffa00b55aa53741b05005c4134a7021a54

##### Find The Hospital that Fits Your Need the Most within Just One Click: https://spring-2018-project2-group8.shinyapps.io/group8/


### **App description:** ###
#### Welcome ####
The welcome page of the app briefly gives an overview of the key features of the app in finding the perfect hospital for you: key statistics and hospital recommendations.

#### About ####
##### About Team #####
This page introduces team members of Group 7 along with their photos and contact information.

##### Data #####
This page lists the two data sources from which the key insights and hospital recommendations are based on. Moreover, it defines the data columns or keywords for clarity into what each indicates.

#### Key Statistics ####

#### Hospital Recommendation ####
This is the page where users can use our app to search for spcific hospitals. The search criteria on the left enables users to narrow the search results down by location, cost, emergency services or distance. Additionally, if one enters a zipcode, the website locates the user by the zipcode and calculate the distance between all hospitals to the given zipcode. Once given all the search criteria, the website automatically ranks the results to decide which results come on top of the list, based on an algorithem that takes strength, weakness and cost into accounts.  

### **Contribution statement**: 

All team members were active and participated throughout the different stages of the project.

__Seungwook Han:__
* Brainstormed and proposed ideas for improvement in the features of the app (changing the general UI for the welcome page, combining two data tables into one, and changing the filters for more appropriate ones that are relevant in searching for hospitals)
* Designed and coded the 'Welcome' page
* Designed the coded the 'Meet the Team' and 'Data' pages under 'About'
* Re-structured the layout of the datatable and map in the 'Hospital Recommendation' page
* Embedded hyperlinks into the hospital name column of the datatable so that it links to the US News hospital search with the respective name
* Partook in writing the readme files

__Siwei Liu:__

__Shuang Lu:__

__Mengran Xia:__

__Yiyang Zeng:__ 
* Made some changes to the hospital recommendation/search page
* Mainly reorganized the two data table into one that contains more information than before and changed the logic of ranking the search results
* Wrote the function to let user enter a zipcode and uses the zipcode to get the user's location and distance from hospitals
* Contributed to the key statistics page and the read me file


### **Reference**:
1. Basic design was inspired by the project 2 of Spring Semester 2018 Group 8. Author: Xiaxiao Guo, Shan He, Michael Utomo, Lan Wen, and Jingtian Yao.
2. https://www.w3schools.com/howto/howto_css_team.asp



Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── app/
├── lib/
├── data/
├── doc/
└── output/
```
  
Please see each subfolder for a README file.

