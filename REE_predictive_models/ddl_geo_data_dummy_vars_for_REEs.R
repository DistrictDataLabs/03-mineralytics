library(xlsx)
library(stringr)
library(dplyr)
#reading in dataset from UPenn
ddl_geo_data <- read.csv("ddl_geo_data.csv",  header =TRUE)
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
p <- data.frame()
for (i in new_list5) {
  for (j in 1:nrow(ddl_geo_data)) {
    if (grepl(i, ddl_geo_data$REEs[j]) == TRUE) {
      q <- rbind(q,as.data.frame(cbind(ddl_geo_data$DEPOSIT.NAME[j],(as.character(i)), as.numeric(1))))
    }
  }
}

for (i in new_list5) {
  for (j in 1:nrow(ddl_geo_data)) {
    
    if (grepl(i, ddl_geo_data$REEs[j]) == FALSE) {
      p <- rbind(p,as.data.frame(cbind(ddl_geo_data$DEPOSIT.NAME[j],(as.character(i)), as.numeric(0))))
      
    }
  }
}



#combining the two dataframes
mines_elements <- rbind(p,q)

#splitting by element (column V2) and generating a list of dataframes. Each dataframe now contains information on the
#presence or absence of a specific element in a location
df_list <- split(mines_elements, as.factor(mines_elements$V2))

#extracting and renaming the dataframes corresponding to the 15 elements

#accessing columns of dataframes via df_list[[i]][[1]] for column 1
for (i in 1:15) {
  df_list[[i]] <- arrange(df_list[[i]],as.character(df_list[[i]][[1]]))
}

#remove column 2 in all the dataframes
#http://stackoverflow.com/questions/17054344/manipulate-data-frame-inside-a-list
#order columns using an index
#http://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-columns
for (i in 1:15) {
  df_list[[i]] <- data.frame(df_list[i])[,-(1:2)]
  
}

df <- data.frame(matrix(NA,nrow=690, ncol =1))
for (i in 1:15) {
  df <- cbind(df,df_list[[i]])
  
}

df<-df[,-1]
colnames(df) <- new_list5

df2<-cbind(ddl_geo_data,df)

df3<-select(df2,DEPOSIT.NAME,LATITUDE,LONGITUDE,REEs,Ce:Ho)

write.csv(df3, file ="ddl_geo_data_dummy_variables.csv", row.names = FALSE)