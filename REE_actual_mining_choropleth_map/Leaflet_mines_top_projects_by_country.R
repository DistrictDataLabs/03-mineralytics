library(rgdal)
library(leaflet)
library(plyr)
library(dplyr)

## code adapted from http://adolfoalvarez.cl/code/users.html
##use the mines dataframe from script "Parsing_mining_data.R"

# We download the data for the map from naturalearthdata.com
url <- "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_countries.zip"
folder <- getwd() #set a folder where to download and extract the data
file <- basename(url) 
# download.file(url, file)
# unzip(file, exdir = folder)

#And read it with rgdal library
#change working directory to directory that contains ne_50m_admin_0_countries
world <- readOGR(dsn = folder, 
                 layer = "ne_50m_admin_0_countries",
                 #encoding = "latin1", #you may need to use a different encoding
                 verbose = FALSE)

#renaming column 5
colnames(mines)[5] <- "MT_metric_tons"

#selecting relevant columns
mines2<-select(mines, Project, Country, MT_metric_tons)
mines2$MT_metric_tons <-as.numeric(mines2$MT_metric_tons)

#This function will extract the top 5 groups and return them as text to be included in the map
myfun <- function(x,y){
  a <- data.frame(x,y) %>%
    arrange(-y) %>%
    slice(1:5)
  return(paste0(a$x, ": ", a$y, collapse="<br>"))
}

#Now we group by country and apply the function
mines4 <- mines2 %>%
  group_by(Country) %>%
  summarise(top5=myfun(Project, MT_metric_tons),
            MT_metric_tons = sum(MT_metric_tons, na.rm=T)              
  ) %>%
  ungroup() %>%
  mutate(Country=toupper(Country))


#We need to reconvert to data.frame to merge it with the SpatialPolygons data frame "world"
mines5 <- data.frame(mines4) 
names(mines5) = c("country", "top5", "MT_metric_tons")
world <- sp::merge(world, mines5,
                   by.x = "iso_a3",
                   by.y = "country",
                   sort = FALSE)
                   
#Tiles coming from stamen.com
tiles <- "http://{s}.tile.stamen.com/toner-lite/{z}/{x}/{y}.png"
attribution <- 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Map data by <a href="http://www.naturalearthdata.com/">Natural Earth</a>.'


#######################################################################################################################
