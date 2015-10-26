library(rgdal)
library(leaflet)
library(plyr)
library(dplyr)
library(countrycode)

## code adapted from http://adolfoalvarez.cl/code/users.html
## using rare_earths dataframe from script "of02-189_wrangled copy-2.R" saved as rare_earths.csv
## set working directory to folder "ne_50m_admin_0_countries"

rare_earths <- read.csv("rare_earths.csv", header = TRUE)

# We download the data for the map from naturalearthdata.com
url <- "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_countries.zip"
folder <- getwd() #set a folder where to download and extract the data
file <- basename(url) 
#download.file(url, file)
#unzip(file, exdir = folder)

#And read it with rgdal library
#change working directory to directory that contains ne_50m_admin_0_countries
world <- readOGR(dsn = folder, 
                 layer = "ne_50m_admin_0_countries",
                 #encoding = "latin1", #you may need to use a different encoding
                 verbose = FALSE)

#select useful columns from rare_earths
rare_earths_country<-select(rare_earths, Deposit_or_district_name, Country, STATUS)

#convert the country name to a country code
rare_earths_country$Code <- countrycode(rare_earths_country$Country, "country.name", "iso3c")

#Group by country and count the number of Projects per country
rare_earths_country2 <- ddply(rare_earths_country, .(Code), summarize, projects = length(Code)) 

#We need to reconvert to data.frame to merge it with the SpatialPolygons data frame "world"
rare_earths_country3  <- data.frame(rare_earths_country2) 
names(rare_earths_country3) = c("country", "projects")
world <- sp::merge(world, rare_earths_country3,
                   by.x = "iso_a3",
                   by.y = "country",
                   sort = FALSE)

#Tiles coming from stamen.com
tiles <- "http://{s}.tile.stamen.com/toner-lite/{z}/{x}/{y}.png" 
attribution <- 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Map data by <a href="http://www.naturalearthdata.com/">Natural Earth</a>.' 

##################################################################################################################

