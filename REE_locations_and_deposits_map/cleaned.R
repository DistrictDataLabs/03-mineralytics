library(xlsx)
library(plyr)
library(dplyr)
library(stringr)
library(zoo)

#reading file
rare_earths <- read.csv("of02-189.csv", header = TRUE)
#change variables from factor to character
rare_earths[]<-lapply(rare_earths, as.character)

#row 2 contains the relevant column names, adding Deposit_Type and transferring some names from row 1
rare_earths[2,1]<- "Deposit_Type"

#selecting relevant columns
rare_earths[2,'X15'] <- rare_earths[1,'X15']
rare_earths[2,'X16'] <- rare_earths[1,'X16']
rare_earths[2,'X17'] <- rare_earths[1,'X17']
rare_earths[2,'X18'] <- rare_earths[1,'X18']
##note: could refactor this using apply or dplyr package

#replacing blanks with NA in column X1
rare_earths[13,'X1'] <- NA
rare_earths[76,'X1'] <- NA
##note: could refactor as well to make it more general

#replacing NAs by the last non-NA value that came before
rare_earths$X1 <-na.locf(rare_earths$X1)
##source: http://stackoverflow.com/questions/20416046/filling-data-frame-with-previous-row-value

table(is.na(rare_earths$X1))
#column 1 does not have any NA anymore

##remove first row
rare_earths<-rare_earths[-1,]

#refactor to remove all rows that are all NA, omitting the first column
#based on http://stackoverflow.com/questions/6471689/remove-rows-in-r-matrix-where-all-data-is-na
rare_earths <-rare_earths[rowSums(is.na(rare_earths)) != (ncol(rare_earths)-1),]

#get names from first row and make them row names, remove used row
rare_earth_names <- as.character(rare_earths[1,])
colnames(rare_earths) <- rare_earth_names

#tidying up colnames 
whitespace <- " "
rare_earth_names <-lapply(rare_earth_names, function(x) {str_replace_all(x, pattern=whitespace, replacement = "_")})
colnames(rare_earths) <- rare_earth_names

#removing first row
rare_earths<-rare_earths[-1,]

### use this cleaned dataframe for the Leaflet scripts

write.csv(rare_earths, file = "rare_earths.csv", row.names = FALSE)