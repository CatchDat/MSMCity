setwd("~/dev/CatchDat/MSMCity/")
source("api/NomiswebApi.R")

# put your nomisweb API key in this file if you have one
# e.g.
# apiKey <- "0x0123456789abcdef0123456789abcdef01234567"
if (file.exists("api/ApiKey.R")) source("api/ApiKey.R")

library(dplyr)

# Newcastle
origins <- "1245709951...1245709978,1245715039"

# All
destinations <- paste0("1103101953,1103101955,1103101954,1103101956,2092957702,2092957701,1245710776...1245710790,1245712478...1245712543,1245710706...1245710716,1245715055,1245710717...1245710734,1245714957,1245713863...1245713902,1245710735...1245710751,1245714958,1245715056,1245710752...1245710775,1245709926...1245709950,1245714987,1245714988,1245709951...1245709978,1245715039,1245709979...1245710067,1245710832...1245710868,1245712005...1245712034,1245712047...1245712067,1245711988...1245712004,1245712035...1245712046,1245712068...1245712085,1245710791...1245710831,1245712159...1245712222,1245709240...1245709350,1245715048,1245715058...1245715063,1245709351...1245709382,1245715006,1245709383...1245709577,1245713352...1245713362,1245715027,1245713363...1245713411,1245715017,1245713412...1245713456,1245715030,1245713457...1245713502,1245709578...1245709655,1245715077...1245715079,1245709679...1245709716,1245709656...1245709678,1245709717...1245709758,1245710900...1245710939,1245714960,1245715037,1245715038,1245710869...1245710899,1245714959,1245710940...1245711009,1245713903...1245713953,1245715016,1245713954...1245713977,1245709759...1245709925,1245714949,1245714989,1245714990,1245715014,1245715015,1245710411...1245710660,1245714998,1245715007,1245715021,1245715022,1245710661...1245710705,1245711010...1245711072,1245714961,1245714963,1245714965,1245714996,1245714997,1245711078...1245711112,1245714980,1245715050,1245715051,1245711073...1245711077,1245712223...1245712237,1245714973,1245712238...1245712284,1245714974,1245712285...1245712294,1245715018,1245712295...1245712306,1245714950,1245712307...1245712316,1245715065,1245715066,1245713503...1245713513,1245714966,1245713514...1245713544,1245714962,1245713545...1245713581,1245714964,1245715057,1245713582...1245713587,1245715010,1245715011,1245713588...1245713627,1245715012,1245715013,1245713628...1245713665,1245713774...1245713779,1245715008,1245715009,1245713780...1245713862,1245713978...1245714006,1245715049,1245714007...1245714019,1245715052,1245714020...1245714033,1245714981,1245714034...1245714074,1245711113...1245711135,1245714160...1245714198,1245711159...1245711192,1245711136...1245711158,1245714270...1245714378,1245714616...1245714638,1245714952,1245714639...1245714680,1245710068...1245710190,1245714953,1245714955,1245715041...1245715047,1245710191...1245710231,1245714951,1245710232...1245710311,1245714956,1245710312...1245710339,1245714954,1245710340...1245710410,1245715040,1245714843...1245714927,1245711814...1245711833,1245711797...1245711813,1245711834...1245711849,1245711458...1245711478,1245711438...1245711457,1245715023,1245715024,1245711479...1245711512,1245715005,1245715071,1245711915...1245711936,1245714971,1245711937...1245711987,1245715019,1245715020,1245712611...1245712711,1245715068,1245712712...1245712784,1245713023...1245713175,1245713666...1245713758,1245715053,1245715054,1245713759...1245713773,1245714379...1245714395,1245714972,",
                       "1245714396...1245714467,1245708449...1245708476,1245708289,1245708620...1245708645,1245715064,1245715067,1245708646...1245708705,1245714941,1245708822...1245708865,1245708886...1245708919,1245714947,1245708920...1245708952,1245714930,1245714931,1245714944,1245708978...1245709014,1245709066...1245709097,1245714948,1245709121...1245709150,1245714999,1245715000,1245709179...1245709239,1245708290...1245708310,1245714945,1245708311...1245708378,1245714932,1245708379...1245708448,1245714929,1245714934,1245714936,1245708477...1245708519,1245714935,1245708520...1245708557,1245714938,1245708558...1245708592,1245714940,1245708593...1245708619,1245714933,1245715072...1245715076,1245708706...1245708733,1245714942,1245715028,1245708734...1245708794,1245714943,1245708795...1245708821,1245714939,1245708866...1245708885,1245708953...1245708977,1245709015...1245709042,1245714946,1245715069,1245715070,1245709043...1245709065,1245709098...1245709120,1245714982,1245709151...1245709178,1245711551...1245711565,1245711690...1245711722,1245711779...1245711796,1245711513...1245711550,1245711658...1245711689,1245711723...1245711746,1245714967,1245711588...1245711619,1245711747...1245711778,1245711566...1245711587,1245711620...1245711657,1245711850...1245711884,1245714969,1245711885...1245711914,1245714970,1245712544...1245712554,1245715003,1245715004,1245712555...1245712610,1245712860...1245712894,1245714975,1245714984,1245712895...1245712958,1245714968,1245714976,1245714977,1245712959...1245713022,1245713176...1245713206,1245715001,1245715002,1245713207...1245713279,1245714978,1245713280...1245713291,1245715025,1245715026,1245713292...1245713337,1245714979,1245713338...1245713351,1245714075...1245714144,1245715032,1245714145...1245714159,1245714468...1245714493,1245714983,1245714494...1245714587,1245714937,1245714588...1245714603,1245714985,1245714604...1245714615,1245714681...1245714780,1245711193...1245711219,1245711375...1245711395,1245715029,1245715031,1245711220...1245711270,1245715033...1245715036,1245712086...1245712158,1245714928,1245711271...1245711294,1245714991,1245714992,1245711327...1245711358,1245711396...1245711413,1245711295...1245711326,1245711414...1245711437,1245714993...1245714995,1245711359...1245711374,1245714986,1245714781...1245714842,1245712317...1245712477,1245712785...1245712859,1245714199...1245714269,1245715080...1245715134,1245715485,1245715135...1245715171,1245715486,1245715172...1245715188,1245715480,1245715482,1245715189...1245715196,1245715487,1245715197...1245715236,1245715484,1245715237...1245715285,1245715483,1245715286...1245715319,1245715434...1245715479,1245715488,1245715489,1245715320...1245715356,1245715481,1245715357...1245715433")
columns <- "currently_residing_in_code,place_of_work_code,obs_value"

# Get OD data
allod <- getODData("NM_1228_1", origins, destinations, columns, apiKey = apiKey)

sexes <- "1, 2"
ages <- "1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12"
economic_activity <- "4, 5, 7, 8"
columns <- "geography_code,c_sex_name,c_age_name,economic_activity_name,obs_value"

# Get pop - age by sex by econ ca=t
allpop <- getEconData("NM_750_1", origins, sexes, ages, economic_activity, columns, apiKey = apiKey)

# broaden age ranges
allpop$C_AGE_NAME[allpop$C_AGE_NAME == "Age 16 to 19"
                | allpop$C_AGE_NAME == "Age 20 to 21"
                | allpop$C_AGE_NAME == "Age 22 to 24" ] <- "16-24"
allpop$C_AGE_NAME[allpop$C_AGE_NAME == "Age 25 to 29"
                | allpop$C_AGE_NAME == "Age 30 to 34" ] <- "25-34"
allpop$C_AGE_NAME[allpop$C_AGE_NAME == "Age 35 to 39"
                | allpop$C_AGE_NAME == "Age 40 to 44" ] <- "35-44"
allpop$C_AGE_NAME[allpop$C_AGE_NAME == "Age 45 to 49"
                | allpop$C_AGE_NAME == "Age 50 to 54" ] <- "45-54"
allpop$C_AGE_NAME[allpop$C_AGE_NAME == "Age 55 to 59"
                | allpop$C_AGE_NAME == "Age 60 to 64" ] <- "55-64"
allpop$C_AGE_NAME[allpop$C_AGE_NAME == "Age 65 and over" ] <- "65+"

# shorten sex names
allpop$C_SEX_NAME[allpop$C_SEX_NAME == "Females"] <- "F"
allpop$C_SEX_NAME[allpop$C_SEX_NAME == "Males"] <- "M"


# shorten econ act names
allpop$ECONOMIC_ACTIVITY_NAME[allpop$ECONOMIC_ACTIVITY_NAME == "Economically active: In employment: Employee: Full-time (including full-time students)"] <- "E FT"
allpop$ECONOMIC_ACTIVITY_NAME[allpop$ECONOMIC_ACTIVITY_NAME == "Economically active: In employment: Employee: Part-time (including full-time students)"] <- "E PT"
allpop$ECONOMIC_ACTIVITY_NAME[allpop$ECONOMIC_ACTIVITY_NAME == "Economically active: In employment: Self-employed: Full-time (including full-time students)"] <- "S FT"
allpop$ECONOMIC_ACTIVITY_NAME[allpop$ECONOMIC_ACTIVITY_NAME == "Economically active: In employment: Self-employed: Part-time (including full-time students)"] <- "S PT"

allpop$C_AGE_NAME <- as.factor(allpop$C_AGE_NAME)

# collapse age groups
allpop<-summarise(group_by(allpop, GEOGRAPHY_CODE , C_SEX_NAME, C_AGE_NAME, ECONOMIC_ACTIVITY_NAME), sum(OBS_VALUE))

# get list of unique origins...
originMsoas = unique(allpop$GEOGRAPHY_CODE)

# define table
allSynPop<-data.frame(Origin=character(), Dest=character(), AgeSexEcon=character(), NumPeople=numeric(), stringsAsFactors = FALSE)

# loop over origins
for (msoa in originMsoas) {
  print(msoa)
  pop<-allpop[allpop$GEOGRAPHY_CODE==msoa,]
  od<-allod[allod$CURRENTLY_RESIDING_IN_CODE==msoa,]
  print(paste("Working population (pop)", sum(pop$`sum(OBS_VALUE)`)))
  print(paste("Working population (od)", sum(od$OBS_VALUE)))
  stopifnot(sum(pop$`sum(OBS_VALUE)`) == sum(od$OBS_VALUE))

  # I'm sure there are better ways of extracting the category totals...
  #sex <- c(sum(pop[pop$sex==0,]$freq), sum(pop[pop$sex==1,]$freq))
  #age <- c(sum(pop[pop$age_band==1,]$freq), sum(pop[pop$age_band==2,]$freq), sum(pop[pop$age_band==3,]$freq),
  #         sum(pop[pop$age_band==4,]$freq), sum(pop[pop$age_band==5,]$freq), sum(pop[pop$age_band==6,]$freq))
  #econ <- c(sum(pop[pop$econ_cat==0,]$freq), sum(pop[pop$econ_cat==1,]$freq), sum(pop[pop$econ_cat==2,]$freq), sum(pop[pop$econ_cat==3,]$freq))

  #ageSexIndex <- c(pop$ECONOMIC_ACTIVITY_NAME*12+pop$sex*6+pop$age_band)
  ageSexEcon <- pop$`sum(OBS_VALUE)`

  #destLabels <-od[od$>0,"destination"]
  # all zero entries of dests already removed
  dests <- od$OBS_VALUE

  msim <- humanleague::synthPop(list(dests, ageSexEcon))
  #print(paste("Conv ", msim$conv))
  if (!msim$conv) {
    print("humanleague::synthPop not converged!")
    #msim<-mipfp::Ipfp(msim$x.hat*0+1,list(1,2),list(dests, ageSexEcon), tol=1e-8)
    #print(paste("IPFP conv ", msim$conv))
    #stopifnot(sum(msim$x.hat) == sum(dests))
    #stopifnot(abs(sum(colSums(msim$x.hat)-ageSexEcon)) < 1e-8 )
    #stopifnot(abs(sum(rowSums(msim$x.hat)-dests)) < 1e-8 )
  }

  #synPop<-data.frame(Dest=character(), Sex=character(), AgeBand=character(), NumPeople=double())

  indices<-which(msim$x.hat > 1e-2, arr.ind=T)
  values<-msim$x.hat[indices]

  sexAgeEconLabels = paste(pop$C_SEX_NAME, pop$C_AGE_NAME, pop$ECONOMIC_ACTIVITY_NAME)

  synPop<-data.frame(Origin=rep(msoa, length(values)), Dest=od$PLACE_OF_WORK_CODE[indices[,1]], AgeSexEcon=sexAgeEconLabels[indices[,2]], NumPeople=values, stringsAsFactors = FALSE)
  allSynPop<-rbind(allSynPop, synPop)
}
write.csv(allSynPop, "data/msim.csv");

# This is output from Charlotte's AppUsers.R
appUsers <- read.csv("./data/appUsers.csv");

# rename some values for consistency
appUsers$age_band[appUsers$age_band == 1] <- "16-24"
appUsers$age_band[appUsers$age_band == 2] <- "25-34"
appUsers$age_band[appUsers$age_band == 3] <- "35-44"
appUsers$age_band[appUsers$age_band == 4] <- "45-54"
appUsers$age_band[appUsers$age_band == 5] <- "55-64"
appUsers$age_band[appUsers$age_band == 6] <- "65+"
appUsers$gender <- as.character(appUsers$gender)
appUsers$gender[appUsers$gender == "female"] <- "F"
appUsers$gender[appUsers$gender == "male"] <- "M"

# TODO need to match both home and work...first get appUsers who live in Newcastle
neAppUsers <- appUsers[appUsers$HomeMSOA %in% unique(allod$CURRENTLY_RESIDING_IN_CODE),]

# temporary create concatenated OD column
allSynPop$tmp<-paste(allSynPop$Origin, allSynPop$Dest, allSynPop$AgeSexEcon)
neAppUsers$tmp<-paste(neAppUsers$HomeMSOA, neAppUsers$WorkMSOA, neAppUsers$gender, neAppUsers$age_band)

#Read in home and work locations
homeLocs <- read.csv("./data/HomeLocations_minReqObsvs10.csv")
workLocs <- read.csv("./data/WorkLocations_minReqObsvs10.csv")

# Append home/work lat/lon
neAppUsers$HomeLat <- NA
neAppUsers$HomeLon <- NA
neAppUsers$WorkLat <- NA
neAppUsers$WorkLon <- NA

for (i in 1:nrow(neAppUsers)) {
  agentId = neAppUsers[i,]$agentID
  neAppUsers[i,]$HomeLat = homeLocs[homeLocs$agentID == agentId,]$popLocY
  neAppUsers[i,]$HomeLon = homeLocs[homeLocs$agentID == agentId,]$popLocX
  neAppUsers[i,]$WorkLat = workLocs[workLocs$agentID == agentId,]$popLocY
  neAppUsers[i,]$WorkLon = workLocs[workLocs$agentID == agentId,]$popLocX
}

allSynPop$Agent<-0

for (i in 1:nrow(neAppUsers)) {
  matches<-grep(neAppUsers[i,"tmp"], allSynPop$tmp)
  print(matches)
  if (length(matches) > 0 ) {
    #print(neAppUsers[i,"tmp"])
    #print(matches)
    # just assign to first match for now
    if (!is.na(matches[1]))
      # TODO can store multiple agents in a list, or expand out the population into individuals, or something else...
      allSynPop[matches[1], "Agent"] <- neAppUsers$agentID[i]
  } else {
    #warning(paste("Failed to match agent", neAppUsers[i, "tmp"], "to synthetic population"))
  }
}

allSynPop$tmp <- NULL
neAppUsers$tmp<- NULL

synPopAgents<-allSynPop[allSynPop$Agent != 0,]

#
#Define coordinates
homeCoords = cbind(Longitude = neAppUsers$HomeLon, Latitude = neAppUsers$HomeLat)
workCoords = cbind(Longitude = neAppUsers$WorkLon, Latitude = neAppUsers$WorkLat)

#Define OD lines
lineList = c() #vector("list", nrow(neAppUsers))
for (i in 1:nrow(neAppUsers)) {
  m <- matrix(c(neAppUsers$HomeLon[i], neAppUsers$WorkLon[i], neAppUsers$HomeLat[i], neAppUsers$WorkLat[i]), ncol=2)
  ln <- Line(m)
  lineList <- append(lineList,ln)

}

as_lines = vector(mode = "list", length = length(lineList))
i = 1
for(i in 1:length(lineList)){
  as_lines[[i]] = Lines(slinelist = list(lineList[[i]]), ID = i) # now Lines (not Line)
}
odSet = SpatialLines(LinesList = as_lines)
#plot(l)
ldf = SpatialLinesDataFrame(sl = odSet, data = data.frame(id = 1:length(as_lines)))
#Load spatial library
library(sp)

#Set up variables for the different projection systems
latlong <- "+init=epsg:4326"


#Make spatial data frame
homePts <- SpatialPointsDataFrame(homeCoords, neAppUsers, proj4string = CRS(latlong))
workPts <- SpatialPointsDataFrame(workCoords, neAppUsers, proj4string = CRS(latlong))

#Read in MSOA shape file (unzip to directory and specify directory name for dsn)
library(rgdal)
#OA <- readOGR(dsn = ".", layer = "england_oa_2011")
MSOA <- readOGR(dsn = "./data", layer = "england_msoa_2011")
#Convert MSOA bng polygons to latitude and longitude
MSOA <- spTransform(MSOA, CRS(latlong))

#Point in polygon
homePtInPoly <- over(homePts, MSOA, returnList = FALSE, fn = NULL)
workPtInPoly <- over(workPts, MSOA, returnList = FALSE, fn = NULL)

msoaNcle=MSOA[grepl("Newcastle upon Tyne", MSOA$name),]

# visualise results
library(leaflet)
leaflet() %>%
  setView(-1.6, 55.0, 11) %>%
  addProviderTiles("Stamen.Toner") %>%
  addPolylines(data = msoaNcle, color ="yellow", weight = 2) %>%
  addPolylines(data = odSet, color ="green", weight = 2) %>%
  addCircleMarkers(data = homePts, color="blue") %>%
  addCircleMarkers(data = workPts, color="red")


