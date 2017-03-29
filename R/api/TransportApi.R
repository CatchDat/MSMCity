
# Transport API query builder
appId = "817c6039" # Catch!
apiKey = Sys.getenv("TRANSPORT_API")

transportApiUrl = "http://transportapi.com/v3/uk/"

transportApiJourneyQuery = function(oLonLat, dLonLat, mode) {

  path = paste0("v3/uk/", mode, "/journey/from/lonlat:", oLonLat[1], ",", oLonLat[2],
               "/to/lonlat:", dLonLat[1], ",", dLonLat[2], ".json")

  # region field can be either "southeast" or "tfl" but appears not to serve any useful purpose
  query = list(region = "southeast", app_id = appId, app_key = apiKey)

  request = httr::GET(url=transportApiUrl, path = path, query = query)
  print(request$request$url)

  if (grepl("application/json", request$headers$`content-type`) == FALSE
    & grepl("js", request$headers$`content-type`) == FALSE) {
    stop("Error: Transportapi did not return a valid result")
  }

  txt = httr::content(request, as = "text", encoding = "UTF-8")
  if (txt == "") {
    stop("Error: Transportapi did not return a valid result")
  }
  obj = jsonlite::fromJSON(txt)

  coords = obj$routes$coordinates
  coords = do.call(rbind, coords)
  route = sp::SpatialLines(list(sp::Lines(list(sp::Line(coords)), ID = 1)))
  proj4string(route) = CRS("+init=epsg:4326")

  return (route)
}


#https://transportapi.com/v3/uk/car/journey/from/lonlat:-0.134649,51.529258/to/lonlat:-0.134649,51.529258.json?app_id=03bf8009&app_key=d9307fd91b0247c607e098d5effedc97
#http://transportapi.com/car/journey/from/lonlat:-1.8,53.8/to/lonlat:-0.1,51.5.json?region=southeast&app_id=817c6039&app_key=62b21bb7056ea45a1bcadc3cf8c09f77
