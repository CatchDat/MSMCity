
# Functions to assign geographic locations to OD data

# Requires:
# - MSOA shape file
# - API key for graphhopper/transportAPI

source("./R/Travel.R")
source("./R/api/TransportApi.R")

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
#
# # TODO how do I create a collection of (or append routes to) a SLDF?
# assignRoute = function(synPop) {
#
#   # TODO mode of transport
#   map = leaflet() %>% addTiles()
#
#   for (i in 1:nrow(synPop)) {
# #    Sys.sleep(1)
# #  for (i in 1:30) {
#     o = c(synPop$OLon[i], synPop$OLat[i])
#     d = c(synPop$DLon[i], synPop$DLat[i])
#     print(i)
#     if (road & (o[1] != d[1] | o[2] != d[2])) {
#       e = tryCatch({
#           map = map %>% addPolylines(data = route_graphhopper(from=o, to=d, vehicle = "car"), weight = 2, opacity = 0.2)
#         }, error = function(e){print(e)})
#     }
#   }
#   return(map)
# }


assignRoute = function(synPop, stride) {

  map = leaflet() %>% addTiles()

  for (i in seq(from=1, to=nrow(synPop), by=stride)) {
#  for (i in 1:10) {
    o = c(synPop$OLon[i], synPop$OLat[i])
    d = c(synPop$DLon[i], synPop$DLat[i])
    m = censusToTransportApiMode(synPop$Travel[i])
    colour = "green" # Green for cycle

    if (m == "car") {
      colour = "red" # Red for car
    } else if (m == "public") {
      colour = "blue"
    }

    print(i)
    if ((o[1] != d[1] | o[2] != d[2])) {
      e = tryCatch({
          map = map %>% addPolylines(data = transportApiJourneyQuery(o, d, m), weight = 2, opacity = 1.0, color=colour)
        }, error = function(e){print(e)})
    }
  }
  return(map)
}

library(htmlwidgets)


saveMap = function(map, filename) {
  # TODO check for overwrite...
  saveWidget(map, filename)
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

allEnglandAndWales = function() {
  return(c(
    "City of London",
    "Barking and Dagenham",
    "Barnet",
    "Bexley",
    "Brent",
    "Bromley",
    "Camden",
    "Croydon",
    "Ealing",
    "Enfield",
    "Greenwich",
    "Hackney",
    "Hammersmith and Fulham",
    "Haringey",
    "Harrow",
    "Havering",
    "Hillingdon",
    "Hounslow",
    "Islington",
    "Kensington and Chelsea",
    "Kingston upon Thames",
    "Lambeth",
    "Lewisham",
    "Merton",
    "Newham",
    "Redbridge",
    "Richmond upon Thames",
    "Southwark",
    "Sutton",
    "Tower Hamlets",
    "Waltham Forest",
    "Wandsworth",
    "Westminster",
    "Bolton",
    "Bury",
    "Manchester",
    "Oldham",
    "Rochdale",
    "Salford",
    "Stockport",
    "Tameside",
    "Trafford",
    "Wigan",
    "Knowsley",
    "Liverpool",
    "St. Helens",
    "Sefton",
    "Wirral",
    "Barnsley",
    "Doncaster",
    "Rotherham",
    "Sheffield",
    "Gateshead",
    "Newcastle upon Tyne",
    "North Tyneside",
    "South Tyneside",
    "Sunderland",
    "Birmingham",
    "Coventry",
    "Dudley",
    "Sandwell",
    "Solihull",
    "Walsall",
    "Wolverhampton",
    "Bradford",
    "Calderdale",
    "Kirklees",
    "Leeds",
    "Wakefield",
    "Hartlepool",
    "Middlesbrough",
    "Redcar and Cleveland",
    "Stockton-on-Tees",
    "Darlington",
    "Halton",
    "Warrington",
    "Blackburn with Darwen",
    "Blackpool",
    "City of Kingston upon Hull",
    "East Riding of Yorkshire",
    "North East Lincolnshire",
    "North Lincolnshire",
    "York",
    "Derby",
    "Leicester",
    "Rutland",
    "Nottingham",
    "County of Herefordshire",
    "Telford and Wrekin",
    "Stoke-on-Trent",
    "Bath and North East Somerset",
    "City of Bristol",
    "North Somerset",
    "South Gloucestershire",
    "Plymouth",
    "Torbay",
    "Bournemouth",
    "Poole",
    "Swindon",
    "Peterborough",
    "Luton",
    "Southend-on-Sea",
    "Thurrock",
    "Medway",
    "Bracknell Forest",
    "West Berkshire",
    "Reading",
    "Slough",
    "Windsor and Maidenhead",
    "Wokingham",
    "Milton Keynes",
    "Brighton and Hove",
    "Portsmouth",
    "Southampton",
    "Isle of Wight",
    "Isle of Anglesey",
    "Gwynedd",
    "Conwy",
    "Denbighshire",
    "Flintshire",
    "Wrexham",
    "Powys",
    "Ceredigion",
    "Pembrokeshire",
    "Carmarthenshire",
    "Swansea",
    "Neath Port Talbot",
    "Bridgend",
    "The Vale of Glamorgan",
    "Rhondda,Cynon,Taff",
    "Merthyr Tydfil",
    "Caerphilly",
    "Blaenau Gwent",
    "Torfaen",
    "Monmouthshire",
    "Newport",
    "Cardiff",
    "Mid Bedfordshire",
    "Bedford",
    "South Bedfordshire",
    "Aylesbury Vale",
    "Chiltern",
    "South Bucks",
    "Wycombe",
    "Cambridge",
    "East Cambridgeshire",
    "Fenland",
    "Huntingdonshire",
    "South Cambridgeshire",
    "Chester",
    "Congleton",
    "Crewe and Nantwich",
    "Ellesmere Port and Neston",
    "Macclesfield",
    "Vale Royal",
    "Caradon",
    "Carrick",
    "Kerrier",
    "North Cornwall",
    "Penwith",
    "Restormel",
    "Scilly, Isles of",
    "Allerdale",
    "Barrow-in-Furness",
    "Carlisle",
    "Copeland",
    "Eden",
    "South Lakeland",
    "Amber Valley",
    "Bolsover",
    "Chesterfield",
    "Derbyshire Dales",
    "Erewash",
    "High Peak",
    "North East Derbyshire",
    "South Derbyshire",
    "East Devon",
    "Exeter",
    "Mid Devon",
    "North Devon",
    "South Hams",
    "Teignbridge",
    "Torridge",
    "West Devon",
    "Christchurch",
    "East Dorset",
    "North Dorset",
    "Purbeck",
    "West Dorset",
    "Weymouth and Portland",
    "Chester-le-Street",
    "Derwentside",
    "Durham",
    "Easington",
    "Sedgefield",
    "Teesdale",
    "WearValley",
    "Eastbourne",
    "Hastings",
    "Lewes",
    "Rother",
    "Wealden",
    "Basildon",
    "Braintree",
    "Brentwood",
    "Castle Point",
    "Chelmsford",
    "Colchester",
    "Epping Forest",
    "Harlow",
    "Maldon",
    "Rochford",
    "Tendring",
    "Uttlesford",
    "Cheltenham",
    "Cotswold",
    "Forest of Dean",
    "Gloucester",
    "Stroud",
    "Tewkesbury",
    "Basingstoke and Deane",
    "East Hampshire",
    "Eastleigh",
    "Fareham",
    "Gosport",
    "Hart",
    "Havant",
    "New Forest",
    "Rushmoor",
    "Test Valley",
    "Winchester",
    "Broxbourne",
    "Dacorum",
    "East Hertfordshire",
    "Hertsmere",
    "North Hertfordshire",
    "St Albans",
    "Stevenage",
    "Three Rivers",
    "Watford",
    "Welwyn Hatfield",
    "Ashford",
    "Canterbury",
    "Dartford",
    "Dover",
    "Gravesham",
    "Maidstone",
    "Sevenoaks",
    "Shepway",
    "Swale",
    "Thanet",
    "Tonbridge and Malling",
    "Tunbridge Wells",
    "Burnley",
    "Chorley",
    "Fylde",
    "Hyndburn",
    "Lancaster",
    "Pendle",
    "Preston",
    "Ribble Valley",
    "Rossendale",
    "South Ribble",
    "West Lancashire",
    "Wyre",
    "Blaby",
    "Charnwood",
    "Harborough",
    "Hinckley and Bosworth",
    "Melton",
    "North West Leicestershire",
    "Oadby and Wigston",
    "Boston",
    "East Lindsey",
    "Lincoln",
    "North Kesteven",
    "South Holland",
    "South Kesteven",
    "West Lindsey",
    "Breckland",
    "Broadland",
    "Great Yarmouth",
    "King’s Lynn and West Norfolk",
    "North Norfolk",
    "Norwich",
    "South Norfolk",
    "Corby",
    "Daventry",
    "East Northamptonshire",
    "Kettering",
    "Northampton",
    "South Northamptonshire",
    "Wellingborough",
    "Alnwick",
    "Berwick-upon-Tweed",
    "Blyth Valley",
    "Castle Morpeth",
    "Tynedale",
    "Wansbeck",
    "Craven",
    "Hambleton",
    "Harrogate",
    "Richmondshire",
    "Ryedale",
    "Scarborough",
    "Selby",
    "Ashfield",
    "Bassetlaw",
    "Broxtowe",
    "Gedling",
    "Mansfield",
    "Newark and Sherwood",
    "Rushcliffe",
    "Cherwell",
    "Oxford",
    "South Oxfordshire",
    "Vale of White Horse",
    "West Oxfordshire",
    "Bridgnorth",
    "North Shropshire",
    "Oswestry",
    "Shrewsbury and Atcham",
    "South Shropshire",
    "Mendip",
    "Sedgemoor",
    "South Somerset",
    "Taunton Deane",
    "West Somerset",
    "Cannock Chase",
    "East Staffordshire",
    "Lichfield",
    "Newcastle-under-Lyme",
    "South Staffordshire",
    "Stafford",
    "Staffordshire Moorlands",
    "Tamworth",
    "Babergh",
    "Forest Heath",
    "Ipswich",
    "Mid Suffolk",
    "St Edmundsbury",
    "Suffolk Coastal",
    "Waveney",
    "Elmbridge",
    "Epsom and Ewell",
    "Guildford",
    "Mole Valley",
    "Reigate and Banstead",
    "Runnymede",
    "Spelthorne",
    "Surrey Heath",
    "Tandridge",
    "Waverley",
    "Woking",
    "North Warwickshire",
    "Nuneaton and Bedworth",
    "Rugby",
    "Stratford-on-Avon",
    "Warwick",
    "Adur",
    "Arun",
    "Chichester",
    "Crawley",
    "Horsham",
    "Mid Sussex",
    "Worthing",
    "Kennet",
    "North Wiltshire",
    "Salisbury",
    "West Wiltshire",
    "Bromsgrove",
    "Malvern Hills",
    "Redditch",
    "Worcester",
    "Wychavon",
    "Wyre Forest"))
}
