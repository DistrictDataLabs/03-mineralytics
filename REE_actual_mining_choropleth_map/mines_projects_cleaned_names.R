library(ggmap)
library(plyr)
library(dplyr)
library(stringr)

mines <- read.csv("mines.csv", header =TRUE)

#mines[]<-lapply(mines, as.character)

myfunction <- function(test_word){
  test_word1 <- str_split(test_word," ")
  if (is.na(test_word1[[1]][2]) == TRUE || test_word1[[1]][2] == "(JV)" ) {
    test_word2<- paste(as.character(test_word1[[1]][1]))
  } else 
  test_word2<- paste(as.character(test_word1[[1]][1]), as.character(test_word1[[1]][2]), sep = " ")
  return(unlist(test_word2))
}

mines$Project <-unlist(lapply(mines$Project, myfunction))

codes <- geocode(mines$Project,
                 output = c("latlon", "latlona", "more", "all"),
                 messaging = FALSE, sensor = FALSE,
                 override_limit = FALSE)

mines_codes <-cbind(mines,codes)
my_mines_codes<-mines_codes[complete.cases(mines_codes),]
#13 NAs, use this! Some codes are wrong!

#try pasting the country name into mines$Project
mines2<-mines
mines2$Project <-paste(mines2$Project,",", mines2$Country)
codes2 <- geocode(mines2$Project,
                 output = c("latlon", "latlona", "more", "all"),
                 messaging = FALSE, sensor = FALSE,
                 override_limit = FALSE)

mines_codes2 <-cbind(mines,codes,codes2)
colnames(mines_codes2)[13] <- "lon1"
colnames(mines_codes2)[14] <- "lat1"


