setwd("~/dev/CatchDat/MSMCity/")
source("./R/SynPop.R")
source("./R/Geography.R")
source("./R/AppUsers.R")

# turn on to enable consistency checks
debug = 0

# if you have one, put your nomisweb API key in .Renviron

if (!exists("regions")) {
  cat("ERROR: regions is not defined.\nPlease define the variable 'regions' for the simulation (as a character vector)\n")
  cat("e.g.:\n")
  cat("> regions = \"Newcastle upon Tyne\"\n")
  cat("or\n")
  cat("> regions=c(\"Newcastle upon Tyne\", \"North Tyneside\", \"Gateshead\", \"South Tyneside\", \"Sunderland\")\n")
  stop()
}

library(dplyr)

#regions=c("Newcastle upon Tyne", "North Tyneside", "Gateshead", "South Tyneside",
#          "Sunderland")
#regions=c("Barking and Dagenham")
#regions=allEnglandAndWales()
#regions=c("Bradford 002")

synPop = data.frame()

# nationwide queries are too long for nomisweb, need to break down into chunks
for (i in 1:length(regions)) {
  region=regions[i]
  print(paste("Region: ", region))

  # Get synthetic population
  # TODO add mode of transport
  print("Synthesising population")
  synPop = rbind(synPop, getSynPop(region))
}

# Assign (random) OD locations within MSOAs to entire population
print("Assigning ODs")
synPop = assignODRandom(synPop)

# Assign app users to synthetic population (overwrites random ODs)
print("Overlaying app users")
synPop = assignAppUsers(synPop)

# Save

print("Saving data")
write.csv(synPop, "data/synPop.csv");

# Assign routes

#map = assignRoute(synPop)
mapO = plotOrigins(synPop)
mapD = plotDests(synPop)

# appUsers = getAppUsers()
# synPop = assignAppUsers(synPop)

# # This is output from Charlotte's AppUsers.R
# appUsers <- read.csv("./data/appUsers.csv");
#
# # rename some values for consistency
# appUsers$age_band[appUsers$age_band == 1] <- "16-24"
# appUsers$age_band[appUsers$age_band == 2] <- "25-34"
# appUsers$age_band[appUsers$age_band == 3] <- "35-44"
# appUsers$age_band[appUsers$age_band == 4] <- "45-54"
# appUsers$age_band[appUsers$age_band == 5] <- "55-64"
# appUsers$age_band[appUsers$age_band == 6] <- "65+"
# appUsers$gender <- as.character(appUsers$gender)
# appUsers$gender[appUsers$gender == "female"] <- "F"
# appUsers$gender[appUsers$gender == "male"] <- "M"
#
# # TODO need to match both home and work...first get appUsers who live in Newcastle
# #regionalAppUsers <- appUsers[appUsers$HomeMSOA %in% unique(allod$CURRENTLY_RESIDING_IN_CODE),]
#
# # temporary create concatenated OD column
# allSynPop$tmp<-paste(allSynPop$Origin, allSynPop$Dest, allSynPop$AgeSexEcon)
# #regionalAppUsers$tmp<-paste(regionalAppUsers$HomeMSOA, regionalAppUsers$WorkMSOA, regionalAppUsers$gender, regionalAppUsers$age_band)
#
# #Read in home and work locations
# homeLocs <- read.csv("./data/HomeLocations_minReqObsvs10.csv")
# workLocs <- read.csv("./data/WorkLocations_minReqObsvs10.csv")
#
# # # Append home/work lat/lon
# # regionalAppUsers$HomeLat <- NA
# # regionalAppUsers$HomeLon <- NA
# # regionalAppUsers$WorkLat <- NA
# # regionalAppUsers$WorkLon <- NA
# #
# # for (i in 1:nrow(regionalAppUsers)) {
# #   agentId = regionalAppUsers[i,]$agentID
# #   regionalAppUsers[i,]$HomeLat = homeLocs[homeLocs$agentID == agentId,]$popLocY
# #   regionalAppUsers[i,]$HomeLon = homeLocs[homeLocs$agentID == agentId,]$popLocX
# #   regionalAppUsers[i,]$WorkLat = workLocs[workLocs$agentID == agentId,]$popLocY
# #   regionalAppUsers[i,]$WorkLon = workLocs[workLocs$agentID == agentId,]$popLocX
# # }
#
# allSynPop$Agent<-0
#
# # for (i in 1:nrow(regionalAppUsers)) {
# #   matches<-grep(regionalAppUsers[i,"tmp"], allSynPop$tmp)
# #   print(matches)
# #   if (length(matches) > 0 ) {
# #     #print(regionalAppUsers[i,"tmp"])
# #     #print(matches)
# #     # just assign to first match for now
# #     if (!is.na(matches[1]))
# #       # TODO can store multiple agents in a list, or expand out the population into individuals, or something else...
# #       allSynPop[matches[1], "Agent"] <- regionalAppUsers$agentID[i]
# #   } else {
# #     #warning(paste("Failed to match agent", regionalAppUsers[i, "tmp"], "to synthetic population"))
# #   }
# # }
#
# allSynPop$tmp <- NULL
# #regionalAppUsers$tmp<- NULL
#
# synPopAgents<-allSynPop[allSynPop$Agent != 0,]
#
# #
# #Define coordinates
# #homeCoords = cbind(Longitude = regionalAppUsers$HomeLon, Latitude = regionalAppUsers$HomeLat)
# #workCoords = cbind(Longitude = regionalAppUsers$WorkLon, Latitude = regionalAppUsers$WorkLat)
#
# library(sf)
# library(sp)
# library(stplanr)
#
#
#
# #Define OD lines
# # lineList = c() #vector("list", nrow(regionalAppUsers))
# # for (i in 1:nrow(regionalAppUsers)) {
# #   m <- matrix(c(regionalAppUsers$HomeLon[i], regionalAppUsers$WorkLon[i], regionalAppUsers$HomeLat[i], regionalAppUsers$WorkLat[i]), ncol=2)
# #   ln <- Line(m)
# #   #ln = st_linestring(m, dim="XY")
# #   #print(ln)
# #   lineList <- append(lineList,ln)
# # }
#
# # as_lines = vector(mode = "list", length = length(lineList))
# # i = 1
# # for(i in 1:length(lineList)){
# #   as_lines[[i]] = Lines(slinelist = list(lineList[[i]]), ID = i) # now Lines (not Line)
# # }
# # odSet = SpatialLines(LinesList = as_lines)
# # # #plot(l)
# # ldf = SpatialLinesDataFrame(sl = odSet, data = data.frame(id = 1:length(as_lines)))
#
# #Set up variables for the different projection systems
# latlong <- "+init=epsg:4326"
#
#
#
# # #Make spatial data frame
# # homePts <- SpatialPointsDataFrame(homeCoords, regionalAppUsers, proj4string = CRS(latlong))
# # workPts <- SpatialPointsDataFrame(workCoords, regionalAppUsers, proj4string = CRS(latlong))
#
# #Read in MSOA shape file (unzip to directory and specify directory name for dsn)
# library(rgdal)
# #OA <- readOGR(dsn = ".", layer = "england_oa_2011")
# #MSOA <- readOGR(dsn = "./data", layer = "england_msoa_2011")
# MSOA <- st_read("./data/england_msoa_2011.shp")
# #Convert MSOA bng polygons to latitude and longitude
# MSOA <- st_transform(MSOA, latlong)
#
# #Point in polygon
# #homePtInPoly <- over(homePts, MSOA, returnList = FALSE, fn = NULL)
# #workPtInPoly <- over(workPts, MSOA, returnList = FALSE, fn = NULL)
#
# msoaRegion=MSOA[grepl(region, MSOA$name),]
#
# sp_msoa = as(MSOA, "Spatial")
# sp_msoaRegion = as(msoaRegion, "Spatial")
#
# # OD for a single MSOA (the last one from the loop above for now)
#
# msoapop = sum(pop$OBS_VALUE)
#
# # no. of households per MSOA
# msoaRegionHh = getMSOAHouseholds(origins)
# msoaHouseholds = msoaRegionHh[msoaRegionHh$GEOGRAPHY_CODE==msoa,2]
# sp_randHomes = spsample(sp_msoaRegion[sp_msoaRegion$code==msoa,],msoaHouseholds,"random")
# randHomes = st_sfc(st_my_poly_sample(msoaRegion[sp_msoaRegion$code==msoa,],msoaHouseholds))
#
# # TODO work out how to get one per MSOA
# # TODO extend to national
# # one workplace per msoa for now
# randWorks = st_my_poly_sample(msoaRegion, 1) # fix
# sp_randWorks = spsample(sp_msoaRegion,1,"random")
#
# # # visualise results
# # library(leaflet)
# # leaflet() %>%
# #   setView(-1.6, 53.0, 6) %>%
# #   addProviderTiles("Stamen.Toner") %>%
# #   addPolylines(data = sp_msoaRegion, color ="yellow", weight = 2) %>%
# #   addPolylines(data = odSet, color ="green", weight = 2) %>%
# #   addCircleMarkers(data = homePts, color="blue") %>%
# #   addCircleMarkers(data = workPts, color="red") %>%
# #   addCircleMarkers(data = workPts, color="red") %>%
# #   addCircleMarkers(data = sp_randHomes, color="black") %>%
# #   addCircleMarkers(data = sp_randWorks, color="green")
#
# # Filter out destinations outside the region
# odRegion = allod[allod$PLACE_OF_WORK_CODE %in% allod$CURRENTLY_RESIDING_IN_CODE,]
# net=od2line(flow = odRegion, zones = sp_msoaRegion)
# #w=odRegion$OBS_VALUE/max(odRegion$OBS_VALUE)*10.0
# #plot(net,lwd=w)
#
# # remove null routes
# net=net[net$CURRENTLY_RESIDING_IN_CODE != net$PLACE_OF_WORK_CODE,]
# rdsfile=paste0("./data/routes_",region,".Rds")
# # used cached routes if available
# if (file.exists(rdsfile)) {
#   routes = readRDS(rdsfile)
# } else {
#   # compute then save
#   routes=line2route(net, route_fun="route_graphhopper")
#   saveRDS(routes, file=rdsfile)
# }
#
# library(leaflet)
#
# #map = leaflet() %>% addTiles() %>% addPolylines(data = routes, opacity = 0.05) %>% addPolylines(data=sp_msoaRegion, weight=2, color="green")
#
# #library(tmap)
#
# # remove users with work location undefined
# #regionalAppUsers = regionalAppUsers[!is.na(regionalAppUsers$WorkMSOA),]
#
# # superimpose app users
# # for (i in 1:length(regionalAppUsers)) {
# #   trip=route_graphhopper(from=c(regionalAppUsers$HomeLon[i],regionalAppUsers$HomeLat[i]),to=c(regionalAppUsers$WorkLon[i],regionalAppUsers$WorkLat[i]))
# #   cat(i)
# #   map = map %>% addPolylines(data = trip, color="#F00")
# # }
# #
# # map
#
# # pick a home region
#
# #singleMsoa = "E02002184" # Ilkley
# singleMsoa = "E02001718"
#
# oMsoa = allod[allod$CURRENTLY_RESIDING_IN_CODE == singleMsoa,]
# # filter out non-geographic msoas
# oMsoa = oMsoa[grepl("^E", oMsoa$PLACE_OF_WORK_CODE),]
#
# map2 = leaflet() %>% addTiles() %>% addPolylines(data=sp_msoaRegion[sp_msoaRegion$code==singleMsoa,], weight=2, color="green")
#
# # TODO all *destination* MSOAs, not just those in Newcastle
# for (i in 1:nrow(oMsoa)) {
# #for (i in 1:1) {
#   for (j in 1:oMsoa$OBS_VALUE[i]) {
#     print(paste(i,j,oMsoa$CURRENTLY_RESIDING_IN_CODE[i], oMsoa$PLACE_OF_WORK_CODE[i]))
#     oRand = spsample(sp_msoaRegion[sp_msoaRegion$code==oMsoa$CURRENTLY_RESIDING_IN_CODE[i],],1,"random", iter=10)
#     dRand = spsample(sp_msoa[sp_msoa$code==oMsoa$PLACE_OF_WORK_CODE[i],],1,"random", iter=10)
#     #oRand = st_my_poly_sample(msoaRegion[oMsoa$CURRENTLY_RESIDING_IN_CODE[i],], 1)
#     #dRand = st_my_poly_sample(msoaRegion[oMsoa$PLACE_OF_WORK_CODE[i],], 1)
#
#     #print(unname(as(oRand, "Spatial")@coords))
#     #print(unname(as(dRand, "Spatial")@coords))
#     #trip=route_graphhopper(from=as(oRand, "Spatial"),to=as(dRand, "Spatial"))
#     tryCatch({
#       trip = route_graphhopper(from=oRand@coords,to=dRand@coords, vehicle = "car")
#       map2 = map2 %>% addPolylines(data = trip, weight = 2, opacity = 0.05)
#     })
#     # TODO deal with graphhopper errors...
#   }
# }
#
# #inds = sum(allSynPop[allSynPop$Origin==singleMsoa,]$NumPeople)
# #randHomes = st_poly_sample(msoaRegion[msoaRegion$code==singleMsoa,], inds)
# #for (i in 1:length(randHomes)) {
# #  trip=route_graphhopper(from=c(regionalAppUsers$HomeLon[i],regionalAppUsers$HomeLat[i]),to=c(regionalAppUsers$WorkLon[i],regionalAppUsers$WorkLat[i]))
# #  cat(i)
# #  map = map %>% addPolylines(data = trip, color="#F00")
# #}


