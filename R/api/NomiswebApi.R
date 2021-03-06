# nomisweb.co.uk RESTful API interface

# TODO query builder?
# TODO geographic (MSOA) builder?
# TODO output column builder?
# TODO single data extraction function using query and result builders above?

# see https://www.nomisweb.co.uk/api/v01/dataset/def.htm?search=*DC1117EW* -> NM_792_1
# then e.g. https://www.nomisweb.co.uk/api/v01/dataset/NM_792_1/c_age.def.htm
#           https://www.nomisweb.co.uk/api/v01/dataset/NM_792_1/geography.def.htm
#

library(digest)
library(rjson)

nomisUrl <- "https://www.nomisweb.co.uk/"

# Store your api key in .Renviron
nomisApiKey = Sys.getenv("NOMIS_API_KEY")

getMetadata <- function(tableName) {
  # hard code measures (not sure what it defines)

  query <- list(search = paste0("*", tableName, "*"))

  queryUrl <- httr::modify_url(nomisUrl, path = "api/v01/dataset/def.sdmx.json", query = query)
  result <- fromJSON(file=queryUrl)
  table <- result$structure$keyfamilies$keyfamily[[1]]$id
  #return(result$structure$keyfamilies$keyfamily[[1]])
  print(paste("Table: ", table))
  print(paste("Description: ", result$structure$keyfamilies$keyfamily[[1]]$name$value))

  # Get fields
  # e.g. https://www.nomisweb.co.uk/api/v01/dataset/NM_792_1.def.sdmx.json
  queryUrl <- httr::modify_url(nomisUrl, path = paste0("api/v01/dataset/", table, ".def.sdmx.json"))
  #print(queryUrl)
  result <- fromJSON(file=queryUrl)
  print("Fields:")
  fields <- result$structure$keyfamilies$keyfamily[[1]]$components$dimension
  for (i in 1:length(fields)) {
    field <- fields[[i]]$conceptref
    print(paste0("  ", field))
    # Get values
    # e.g. https://www.nomisweb.co.uk/api/v01/dataset/NM_792_1/C_AGE.def.sdmx.json
    queryUrl <- httr::modify_url(nomisUrl, path = paste0("api/v01/dataset/", table, "/", field, ".def.sdmx.json"))
    result <- fromJSON(file=queryUrl)
    values <- result$structure$codelists$codelist[[1]]$code
    for (j in 1:length(values)) {
      print(paste0("    ", values[[j]]$value, ": ", values[[j]]$description$value))
    }
  }
  return(fields);
}




# Get list of MSOA geog codes from a query string e.g. "City of Lon*"
# MSOA names have a number so almost certainly need to terminate the query string with a wildcard "*"
getMSOAs <- function(queryString) {
  return(getOAs(queryString, 297))
}

getLSOAs = function(queryString) {
  return(getOAs(queryString, 298))
}

getLAs = function(queryString) {
  return(getOAs(queryString, 293))
}

getOAs = function(queryString, code = 299) {
  query <- list(search = queryString)

  if (nomisApiKey == "") {
    warning("Warning, no API key specified. Download will be limited to 25000 rows. Register at https://www.nomisweb.co.uk to get an API key and add NOMIS_API_KEY=<key> to your .Renviron")
  }
  # England: 2092957699 
  # E&W: 2092957703
  # GB: 2092957698
  # UK: 2092957697
  queryUrl <- httr::modify_url(nomisUrl, path = paste0("/api/v01/dataset/NM_1_1/geography/2092957703TYPE", code,".def.sdmx.json"), query = query)

  #print(queryUrl)

  result <- fromJSON(file=paste0(queryUrl))
  nResults = length(result$structure$codelists$codelist[[1]]$code)
  #print(paste(nResults, "results"))
  geogString = ""
  if (nResults > 0) {
    geogString = paste(geogString, result$structure$codelists$codelist[[1]]$code[[1]]$value)
    #print(paste(result$structure$codelists$codelist[[1]]$code[[1]]$annotations$annotation[[3]]$annotationtext,
    #            result$structure$codelists$codelist[[1]]$code[[1]]$description[1]$value))
    if (nResults > 1) {
      for (i in 2:length(result$structure$codelists$codelist[[1]]$code)) {
        #print(paste(result$structure$codelists$codelist[[1]]$code[[i]]$annotations$annotation[[3]]$annotationtext,
        #            result$structure$codelists$codelist[[1]]$code[[i]]$description[1]$value))
        geogString = paste(geogString, result$structure$codelists$codelist[[1]]$code[[i]]$value, sep= ",")
      }
    }
  }

  return(geogString)
}


getODData <- function(table, origins, destinations, columns, removeZeroObs = TRUE, format = "tsv") {
  #nomisUrl <- "https://www.nomisweb.co.uk/"
  # hard code measures (not sure what it defines)

  query <- list(date = "latest",
               currently_residing_in = origins,
               place_of_work = destinations,
               measures = "20100",
               select = columns,
               uid = nomisApiKey)
  # if (nomisApiKey == "") {
  #   warning("Warning, no API key specified. Download will be limited to 25000 rows. Register at https://www.nomisweb.co.uk to get an API key")
  # }
  #
  # queryUrl <- httr::modify_url(nomisUrl, path = paste0("api/v01/dataset/", table, ".data.", format), query = query)
  #
  # filename <- paste0("./data/", digest(queryUrl, "md5"), ".", format)
  # # used cached data if available, otherwise download. md5sum should ensure data file exactly matches query
  # if (!file.exists(filename)) {
  #   curl::curl_download(queryUrl, filename)
  # } else {
  #   print(paste("using cached data:", filename))
  # }
  #result <- read.csv(filename, sep="\t", stringsAsFactors = FALSE)
  result = cachedApiCall(table, query, format)
  # would be far more efficient if we could tell the API not to send zero value rows...
  if (removeZeroObs) {
    result <- result[result$OBS_VALUE != 0,]
  }
  return (result)
}

getEconData <- function(table, geography, sexes, ages, econ, columns, removeZeroObs = TRUE, format = "tsv") {
  #nomisUrl <- "https://www.nomisweb.co.uk/"

  # hard code measures (not sure what it defines)

  #"https://www.nomisweb.co.uk/api/v01/dataset/NM_750_1.data.tsv
  #?date=latest
  #&geography=1245709951...1245709978,1245715039
  #&c_sex=1,2
  #&c_age=1...12
  #&economic_activity=4,5,7,8
  #&measures=20100
  #&select=geography_code,c_sex_name,c_age_name,economic_activity_name,obs_value"

  query <- list(date = "latest",
                geography = geography,
                c_sex = sexes,
                c_age = ages,
                economic_activity = econ,
                measures = "20100",
                select = columns,
                uid = nomisApiKey)

  # would be far more efficient if we could tell the API not to send zero value rows...
  result = cachedApiCall(table, query, format)
  if (removeZeroObs) {
    result <- result[result$OBS_VALUE != 0,]
  }

  return (result)
}

getMSOAHouseholds <- function(geography) {
  table = "NM_513_1" #=QS113EW
  query <- list(date = "latest",
                geography = origins,
                measures = "20100",
                rural_urban = "0",
                c_hhchuk11 = "0",
                select = "GEOGRAPHY_CODE,OBS_VALUE",
                uid = nomisApiKey)

  #       data: 'date=latest&geography=1245714681...1245714688&rural_urban=0&c_hhchuk11=0&measures=20100&select=geography_code,obs_value',
  # https://www.nomisweb.co.uk/api/v01/dataset/NM_513_1.data.tsv?date=latest&geography=1245714681...1245714688&rural_urban=0&c_hhchuk11=0&measures=20100&select=geography_code,obs_value
  result = cachedApiCall(table, query, "tsv")
  return (result)
}

cachedApiCall <- function(table, query, format) {
  if (nomisApiKey == "") {
    warning("Warning, no API key specified. Download will be limited to 25000 rows. Register at https://www.nomisweb.co.uk to get an API key and add NOMIS_API_KEY=<key> to your .Renviron")
  }

  queryUrl <- httr::modify_url(nomisUrl, path = paste0("api/v01/dataset/", table, ".data.", format), query = query)

  #print(queryUrl)

  filename <- paste0("./data/", digest(queryUrl, "md5"), ".", format)
  # used cached data if available, otherwise download. md5sum should ensure data file exactly matches query
  if (!file.exists(filename)) {
    curl::curl_download(queryUrl, filename)
  } else {
    print(paste("using cached data:", filename))
  }
  result <- read.csv(filename, sep="\t", stringsAsFactors = FALSE)
  return (result)
}


getWorkTravelModes <- function(geography) {
  table = "NM_568_1"
  query <- list(date = "latest",
                geography = geography,
                measures = "20100",
                rural_urban = "0",
                cell = "1...11",
                select = "GEOGRAPHY_CODE,CELL_NAME,CELL_CODE,OBS_VALUE",
                uid = nomisApiKey)

  # e.g. https://www.nomisweb.co.uk/api/v01/dataset/NM_568_1.data.tsv?date=latest&geography=1245714681...1245714688&rural_urban=0&cell=1...11&measures=20100&uid=0xc14c302649583b1151acd1a5d318ae767d4c8e8f

  result = cachedApiCall(table, query, "tsv")
  return (result)
}

#url <- "http://www.nomisweb.co.uk/api/v01/dataset/NM_1228_1.data.tsv?date=latest&currently_residing_in=1245709951...1245709978,1245715039&place_of_work=1103101953,1103101955,1103101954,1103101956,2092957702,2092957701,1245710776...1245710790,1245712478...1245712543,1245710706...1245710716,1245715055,1245710717...1245710734,1245714957,1245713863...1245713902,1245710735...1245710751,1245714958,1245715056,1245710752...1245710775,1245709926...1245709950,1245714987,1245714988,1245709951...1245709978,1245715039,1245709979...1245710067,1245710832...1245710868,1245712005...1245712034,1245712047...1245712067,1245711988...1245712004,1245712035...1245712046,1245712068...1245712085,1245710791...1245710831,1245712159...1245712222,1245709240...1245709350,1245715048,1245715058...1245715063,1245709351...1245709382,1245715006,1245709383...1245709577,1245713352...1245713362,1245715027,1245713363...1245713411,1245715017,1245713412...1245713456,1245715030,1245713457...1245713502,1245709578...1245709655,1245715077...1245715079,1245709679...1245709716,1245709656...1245709678,1245709717...1245709758,1245710900...1245710939,1245714960,1245715037,1245715038,1245710869...1245710899,1245714959,1245710940...1245711009,1245713903...1245713953,1245715016,1245713954...1245713977,1245709759...1245709925,1245714949,1245714989,1245714990,1245715014,1245715015,1245710411...1245710660,1245714998,1245715007,1245715021,1245715022,1245710661...1245710705,1245711010...1245711072,1245714961,1245714963,1245714965,1245714996,1245714997,1245711078...1245711112,1245714980,1245715050,1245715051,1245711073...1245711077,1245712223...1245712237,1245714973,1245712238...1245712284,1245714974,1245712285...1245712294,1245715018,1245712295...1245712306,1245714950,1245712307...1245712316,1245715065,1245715066,1245713503...1245713513,1245714966,1245713514...1245713544,1245714962,1245713545...1245713581,1245714964,1245715057,1245713582...1245713587,1245715010,1245715011,1245713588...1245713627,1245715012,1245715013,1245713628...1245713665,1245713774...1245713779,1245715008,1245715009,1245713780...1245713862,1245713978...1245714006,1245715049,1245714007...1245714019,1245715052,1245714020...1245714033,1245714981,1245714034...1245714074,1245711113...1245711135,1245714160...1245714198,1245711159...1245711192,1245711136...1245711158,1245714270...1245714378,1245714616...1245714638,1245714952,1245714639...1245714680,1245710068...1245710190,1245714953,1245714955,1245715041...1245715047,1245710191...1245710231,1245714951,1245710232...1245710311,1245714956,1245710312...1245710339,1245714954,1245710340...1245710410,1245715040,1245714843...1245714927,1245711814...1245711833,1245711797...1245711813,1245711834...1245711849,1245711458...1245711478,1245711438...1245711457,1245715023,1245715024,1245711479...1245711512,1245715005,1245715071,1245711915...1245711936,1245714971,1245711937...1245711987,1245715019,1245715020,1245712611...1245712711,1245715068,1245712712...1245712784,1245713023...1245713175,1245713666...1245713758,1245715053,1245715054,1245713759...1245713773,1245714379...1245714395,1245714972,1245714396...1245714467,1245708449...1245708476,1245708289,1245708620...1245708645,1245715064,1245715067,1245708646...1245708705,1245714941,1245708822...1245708865,1245708886...1245708919,1245714947,1245708920...1245708952,1245714930,1245714931,1245714944,1245708978...1245709014,1245709066...1245709097,1245714948,1245709121...1245709150,1245714999,1245715000,1245709179...1245709239,1245708290...1245708310,1245714945,1245708311...1245708378,1245714932,1245708379...1245708448,1245714929,1245714934,1245714936,1245708477...1245708519,1245714935,1245708520...1245708557,1245714938,1245708558...1245708592,1245714940,1245708593...1245708619,1245714933,1245715072...1245715076,1245708706...1245708733,1245714942,1245715028,1245708734...1245708794,1245714943,1245708795...1245708821,1245714939,1245708866...1245708885,1245708953...1245708977,1245709015...1245709042,1245714946,1245715069,1245715070,1245709043...1245709065,1245709098...1245709120,1245714982,1245709151...1245709178,1245711551...1245711565,1245711690...1245711722,1245711779...1245711796,1245711513...1245711550,1245711658...1245711689,1245711723...1245711746,1245714967,1245711588...1245711619,1245711747...1245711778,1245711566...1245711587,1245711620...1245711657,1245711850...1245711884,1245714969,1245711885...1245711914,1245714970,1245712544...1245712554,1245715003,1245715004,1245712555...1245712610,1245712860...1245712894,1245714975,1245714984,1245712895...1245712958,1245714968,1245714976,1245714977,1245712959...1245713022,1245713176...1245713206,1245715001,1245715002,1245713207...1245713279,1245714978,1245713280...1245713291,1245715025,1245715026,1245713292...1245713337,1245714979,1245713338...1245713351,1245714075...1245714144,1245715032,1245714145...1245714159,1245714468...1245714493,1245714983,1245714494...1245714587,1245714937,1245714588...1245714603,1245714985,1245714604...1245714615,1245714681...1245714780,1245711193...1245711219,1245711375...1245711395,1245715029,1245715031,1245711220...1245711270,1245715033...1245715036,1245712086...1245712158,1245714928,1245711271...1245711294,1245714991,1245714992,1245711327...1245711358,1245711396...1245711413,1245711295...1245711326,1245711414...1245711437,1245714993...1245714995,1245711359...1245711374,1245714986,1245714781...1245714842,1245712317...1245712477,1245712785...1245712859,1245714199...1245714269,1245715080...1245715134,1245715485,1245715135...1245715171,1245715486,1245715172...1245715188,1245715480,1245715482,1245715189...1245715196,1245715487,1245715197...1245715236,1245715484,1245715237...1245715285,1245715483,1245715286...1245715319,1245715434...1245715479,1245715488,1245715489,1245715320...1245715356,1245715481,1245715357...1245715433&measures=20100&select=currently_residing_in_code,place_of_work_code,obs_value"
# age/sex/econAct by MSOA
#url <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_750_1.data.tsv?date=latest&geography=1245709951...1245709978,1245715039&c_sex=1,2&c_age=1...12&economic_activity=4,5,7,8&measures=20100&select=geography_code,c_sex_name,c_age_name,economic_activity_name,obs_value"

# Generate LA name/ons code <-> nomis code and store in csv. Only needs to be run once
getLAMapping = function(filename) {
  engWalesLAstart = 1946157057
  engWalesLAend = 1946157404
  laLookup = data.table(name=rep("",engWalesLAend - engWalesLAstart + 1),
                        onsCode=rep("",engWalesLAend - engWalesLAstart + 1),
                        nomiscode=engWalesLAstart:engWalesLAend)
  for (i in engWalesLAstart:engWalesLAend) {
    # query LA from LA code and get name
    #url = "https://www.nomisweb.co.uk/api/v01/dataset/NM_1_1/geography/"+i+"TYPE293.def.sdmx.json";
    queryUrl = httr::modify_url(nomisUrl, path = paste0("api/v01/dataset/NM_1_1/geography/", i, "TYPE293.def.sdmx.json"))
    result = fromJSON(file=queryUrl)
    laLookup[nomiscode==i]$name = result$structure$codelists$codelist[[1]]$code[[1]]$description$value
    laLookup[nomiscode==i]$onsCode = result$structure$codelists$codelist[[1]]$code[[1]]$annotations$annotation[[3]]$annotationtext
    #print(paste(i, result$structure$codelists$codelist[[1]]$code[[1]]$annotations$annotation[[3]]$annotationtext)
    #print(result$structure$codelists$codelist[[1]]$code[[1]]$description$value)
  }
  write.csv(laLookup, filename)
}


# Code to get list of OA codes in a single LA
# TODO extend to list of LAs?
getOAsInLA = function(laName, laMapping) {
  nomisCode = laMapping[name == laName]$nomiscode
  
  queryUrl = httr::modify_url(nomisUrl, path = paste0("api/v01/dataset/NM_1_1/geography/", nomisCode, "TYPE299.def.sdmx.json"))
  print(queryUrl)
  result = fromJSON(file=queryUrl)
  nResults = length(result$structure$codelists$codelist[[1]]$code)
  
  geogString = ""
  if (nResults > 0) {
    geogString = paste(geogString, result$structure$codelists$codelist[[1]]$code[[1]]$value)
    if (nResults > 1) {
      for (i in 2:length(result$structure$codelists$codelist[[1]]$code)) {
        geogString = paste(geogString, result$structure$codelists$codelist[[1]]$code[[i]]$value, sep= ",")
      }
    }
  }
  
  # use the code below to shorten the string
  return(shortenCodeList(geogString))
}

# Add list of nomis OA codes to the LA lookup
# laLookup$nomisoacodes=rep("",nrow(laLookup))
# for (i in 1:nrow(laLookup)) {
#   laLookup[i,]$nomisoacodes = getOAsInLA(laLookup[i,]$name, laLookup)
# }

# this code orders and shinks the code lists (need to be aware of http header length restrictions)
shortenCodeList = function(codeList) {
  slist = sort(as.integer(unlist(strsplit(codeList,","))))
  index1=1
  string = ""
  for (index2 in 2:length(slist)) {
    # check for a break
    if (slist[index2] != slist[index2-1] + 1)
    {
      if (index1 == index2) {
        string = paste0(string, as.character(slist[index1]), ",")
      }
      else {
        string = paste0(string, as.character(slist[index1]), "...", as.character(slist[index2-1]), ",")
      }
      index1 = index2
    }
  }
  if (index1 == index2) {
    string = paste0(string, as.character(slist[index1]))
  } else {
    string = paste0(string, as.character(slist[index1]), "...", as.character(slist[index2]))
  }
  laLookup[i,]$nomisoacodes=string
}


