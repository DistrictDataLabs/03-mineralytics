library(xlsx)
library(stringr)
library(dplyr)
library(leaflet)

#reading in dataset from UPenn
ddl_geo_data <- read.csv("ddl_geo_data.csv", header =TRUE)
#transforming all variables to char
ddl_geo_data[]<-lapply(ddl_geo_data, as.character)
#renaming 'Not available' to NA
ddl_geo_data[ddl_geo_data == "Not Available"] <- NA

##removing duplicates
#reference: http://www.cookbook-r.com/Manipulating_data/Finding_and_removing_duplicate_records/
ddl_geo_data <- ddl_geo_data[!duplicated(ddl_geo_data$DEPOSIT.NAME),]

#extracting REE elements from all rows of column 'REEs'
new_list <- (strsplit(as.character(ddl_geo_data$REEs),',', fixed=FALSE))
new_list2 <- unlist (new_list)
#removing whitespace
new_list3 <- str_replace_all(new_list2, fixed(" "), "")
#checking which elements are unique
new_list4 <- unique(new_list3)
#removing by hand strings that contain misspellings 
new_list5 <-new_list4[-c(1,17,18,19,20)]
##this generates a list of all the different elements found in the different mines

#generating dataframes that indicate the presence or absence of an element in every mine
q <- data.frame()

for (i in new_list5) {
  for (j in 1:nrow(ddl_geo_data)) {
    if (grepl(i, ddl_geo_data$REEs[j]) == TRUE) {
      q <- rbind(q,as.data.frame(cbind(ddl_geo_data$DEPOSIT.NAME[j],ddl_geo_data$LATITUDE[j],ddl_geo_data$LONGITUDE[j],(as.character(i)), as.numeric(1))))
    }
  }
}

mines_present_elements <- q

q<-select(q,V1:V4)

colnames(q) <- c("Mines", "lat", "lon", "Element")
#http://stackoverflow.com/questions/3418128/how-to-convert-a-factor-to-an-integer-numeric-without-a-loss-of-information
q$lat<-as.numeric(levels(q$lat))[q$lat] 
q$lon<-as.numeric(levels(q$lon))[q$lon] 

q<-ungroup(q)
#adjust coordinates by 50m (could try more)
#https://gist.github.com/avioing/873142
q2<-mutate(q, lat= lat+(runif(nrow(q))-0.5)/750, lon = lon+(runif(nrow(q))-0.5)/750)
q3<-arrange(q2,Mines)

