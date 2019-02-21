
# process hos data
# add two columns Plus and Minus to include area where the specific hospital is above the national average and below the national average

new_hos = hos
new_hos$Plus = ""
new_hos$Plus_Number = 0
new_hos$Minus = ""
new_hos$Minus_Number = 0

cn = colnames(new_hos)
cn[33] = "Patient Experience"
cn[36] = "Medical Imaging Effiency"

#plus & minus
for (i in 1:dim(new_hos)[1]){
  for (k in 30:36){
    if (new_hos[i,k] == "Above the national average"){
      new_hos[i,40] = paste(new_hos[i,40],",",cn[k])
      new_hos[i,41] = new_hos[i,41]+1
    }
    else if (new_hos[i,k] == "Below the national average"){
      new_hos[i,42] = paste(new_hos[i,42],",",cn[k])
      new_hos[i,43] = new_hos[i,43]+1
    }
  }
}   

for (i in 1:dim(new_hos)[1]){
  for (k in c(40,42)){
    new_hos[i,k] = substring(new_hos[i,k],4)
  }
}

hos = new_hos

#new_pay
# get quantile of payments
print(quantile(hos$payment, na.rm = TRUE))

payswitch <- function(payment){
  if(is.na(payment)) {return("Not Avaliable")}
  else {if(payment<=1.667) {return("$")}
    else{if(payment<=2) {return("$$")}
      else{if(payment<=2.25) {return("$$$")}
        else{return("$$$$")}}}}
}
hos$new_pay = apply(data.frame(hos$payment),1,payswitch)

hos$Points = NA
hos$Points_A_Cost = NA
for (i in 1:dim(new_hos)[1]){
  hos[i,45] = hos[i,41] - hos[i,43]*1/2
  hos[i,46] = hos[i,41] - hos[i,43]*1/3 - hos[i,29]*1/2
}


save(hos, file = "C:/Users/zengy/Documents/GitHub/Spring2018-Project2-Group8/app/hos.RData")

