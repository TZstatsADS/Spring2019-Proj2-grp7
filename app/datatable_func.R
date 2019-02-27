# Embed hyperlink to the keyword/search item
createLink <- function(search) {
  search.link <- sprintf('<a href="https://health.usnews.com/best-hospitals/search?hospital_name=%s">%s</a>', search, search)
  return(search.link)
}
#target="_blank" class="btn btn-primary"

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