
# Functions to assign geographic locations to OD data

# Requires:
# - MSOA shape file
# - API key for graphhopper

library(sf)
library(leaflet)
library(stplanr)

assignODRandom = function(synPop) {

  # Add or reset columns
  synPop$OLon = NA
  synPop$OLat = NA
  synPop$DLon = NA
  synPop$DLat = NA

  #Set up variables for the different projection systems
  latlong <- "+init=epsg:4326"

  # Read in as simple features (for futureproofing)
  # Read in MSOA shape file (unzip to directory and specify directory name for dsn)
  library(rgdal)
  #MSOA <- readOGR(dsn = "./data", layer = "england_msoa_2011")
  MSOA <- st_read("./data/england_msoa_2011.shp")
  #Convert MSOA bng polygons to latitude and longitude
  MSOA <- st_transform(MSOA, latlong)

  # Convert to spatial for graphhopper API
  spMSOA = as(MSOA, "Spatial")

  for (i in 1:nrow(synPop)) {
    oRand = spsample(spMSOA[spMSOA$code==synPop$Origin[i],],1,"random", iter=10)
    # if non-geographic/non England & Wales destinations assume no travel
    if (grepl("^E",synPop$Dest[i])) {
      dRand = spsample(spMSOA[spMSOA$code==synPop$Dest[i],],1,"random", iter=10)
    } else {
      dRand = oRand
    }

    synPop$OLon[i] = oRand@coords[1]
    synPop$OLat[i] = oRand@coords[2]
    synPop$DLon[i] = dRand@coords[1]
    synPop$DLat[i] = dRand@coords[2]
  }
  return(synPop)
}

# TODO how do I create a collection of (or append routes to) a SLDF?
assignRoute = function(synPop) {

  # TODO mode of transport
  map = leaflet() %>% addTiles()

  for (i in 1:nrow(synPop)) {
#  for (i in 1:30) {
    o = c(synPop$OLon[i], synPop$OLat[i])
    d = c(synPop$DLon[i], synPop$DLat[i])
    print(i)
    if (o[1] != d[1] | o[2] != d[2]) {
      e = tryCatch({
          map = map %>% addPolylines(data = route_graphhopper(from=o, to=d, vehicle = "car"), weight = 2, opacity = 0.2)
        }, error = function(e){print(e)})
    }
  }
  return(map)
}

# TODO heat map
plotOrigins = function(synPop) {
  mapO = leaflet() %>% addTiles()
  mapO = mapO %>% addCircles(mapO, lat=synPop$OLat, lng=synPop$OLon, radius =1)
  return(mapO)
}

# TODO heat map
plotDests = function(synPop) {
  mapD = leaflet() %>% addTiles()
  mapD = mapD %>% addCircles(mapD, lat=synPop$DLat, lng=synPop$DLon, radius =1)
  return(mapD)
}

library(KernSmooth)
heatMap = function(lon, lat) {
  kde2d=bkde2D(cbind(lon,lat), bandwidth=c(1, 1),gridsize=c(1001,1001))
  x=kde2d$x1
  y=kde2d$x2
  z=kde2d$fhat
  cl=contourLines(x , y , z)
  hm = leaflet() %>% addTiles() %>% addPolygons(cl[[5]]$x,cl[[5]]$y)
  return(hm)
}
