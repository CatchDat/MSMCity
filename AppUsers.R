#Set workspace
setwd("//ds.leeds.ac.uk/staff/staff7/geoces/LIDA internship/Catch project/MicroSim")

#Read in app users file
appData <- read.csv("Aug14-16_Summary.csv")
appData <- appData[-which(is.na(appData$agentID)),]

#Read in app users demographic file
userData <- read.csv("users.csv")

#Merge app user files
appUsers <- merge(appData, userData, by.x = "deviceID", by.y = "device_id")

#Remove unwanted columns

#Create gender code
appUsers$num_gender[appUsers$gender == "male"] <- 1
appUsers$num_gender[appUsers$gender == "female"] <- 0
#Calculate age
appUsers$age <- 2016 - appUsers$yob
#Create age band
appUsers$age_band <- findInterval(appUsers$age, c(16,25,35,45,55,65))

#Set up variables for the different projection systems
latlong <- "+init=epsg:4326"
bng <- "+init=epsg:27700"

#Read in home and work locations
homeLocs <- read.csv("HomeLocations_minReqObsvs10.csv")
workLocs <- read.csv("WorkLocations_minReqObsvs10.csv")

#Define coordinates
homeCoords = cbind(Longitude = homeLocs$popLocX, Latitude = homeLocs$popLocY)
workCoords = cbind(Longitude = workLocs$popLocX, Latitude = workLocs$popLocY)

#Load spatial library
library(sp)

#Make spatial data frame
homePts <- SpatialPointsDataFrame(homeCoords, homeLocs, proj4string = CRS(latlong))
workPts <- SpatialPointsDataFrame(workCoords, workLocs, proj4string = CRS(latlong))

#Read in MSOA shape file
library(rgdal)
#OA <- readOGR(dsn = ".", layer = "england_oa_2011")
MSOA <- readOGR(dsn = ".", layer = "england_msoa_2011")
#Convert MSOA bng polygons to latitude and longitude 
MSOA <- spTransform(MSOA, CRS(latlong))

#Point in polygon
homePointInPoly <- over(homePts, MSOA, returnList = FALSE, fn = NULL)
workPointInPoly <- over(workPts, MSOA, returnList = FALSE, fn = NULL)
#Join MSOA code to app users with home and work locations
homeLocs<-cbind(homeLocs,homePointInPoly$code)
workLocs<-cbind(workLocs,workPointInPoly$code)
#Rename column
names(homeLocs)[names(homeLocs) == "homePointInPoly$code"] <- "HomeMSOA"
names(workLocs)[names(workLocs) == "workPointInPoly$code"] <- "WorkMSOA"

#Join home and work locations to app users data frame
appUsers <- merge(workLocs[, c("agentID", "WorkMSOA")], appUsers, by.x = "agentID", by.y = "agentID", all = TRUE)
appUsers <- merge(homeLocs[, c("agentID", "HomeMSOA")], appUsers, by.x = "agentID", by.y = "agentID", all = TRUE)