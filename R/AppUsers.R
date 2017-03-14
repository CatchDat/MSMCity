

assignAppUsers = function(synPop) {

  # This is output from Charlotte's AppUsers.R
  appUsers = read.csv("./data/appUsers.csv");

  # rename some values for consistency
  appUsers$age_band[appUsers$age_band == 1] = "16-24"
  appUsers$age_band[appUsers$age_band == 2] = "25-34"
  appUsers$age_band[appUsers$age_band == 3] = "35-44"
  appUsers$age_band[appUsers$age_band == 4] = "45-54"
  appUsers$age_band[appUsers$age_band == 5] = "55-64"
  appUsers$age_band[appUsers$age_band == 6] = "65+"
  appUsers$gender = as.character(appUsers$gender)
  appUsers$gender[appUsers$gender == "female"] = "F"
  appUsers$gender[appUsers$gender == "male"] = "M"

  # first filter on appUsers who live in region
  regionalAppUsers = appUsers[appUsers$HomeMSOA %in% unique(synPop$Origin),]
  # remove any where work location is undefined
  regionalAppUsers = regionalAppUsers[!is.na(regionalAppUsers$WorkMSOA),]

  synPop$AppUser = rep(0, nrow(synPop))

  # give up if no app users in this region
  if (nrow(regionalAppUsers) == 0) {
    return(synPop)
  }

  #Read in home and work locations
  homeLocs = read.csv("./data/HomeLocations_minReqObsvs10.csv")
  workLocs = read.csv("./data/WorkLocations_minReqObsvs10.csv")

  regionalAppUsers$HomeLat <- NA
  regionalAppUsers$HomeLon <- NA
  regionalAppUsers$WorkLat <- NA
  regionalAppUsers$WorkLon <- NA

  for (i in 1:nrow(regionalAppUsers)) {
    agentId = regionalAppUsers$agentID[i]
    regionalAppUsers[i,]$HomeLat = homeLocs[homeLocs$agentID == agentId,]$popLocY
    regionalAppUsers[i,]$HomeLon = homeLocs[homeLocs$agentID == agentId,]$popLocX
    regionalAppUsers[i,]$WorkLat = workLocs[workLocs$agentID == agentId,]$popLocY
    regionalAppUsers[i,]$WorkLon = workLocs[workLocs$agentID == agentId,]$popLocX

    matches = which(synPop$Origin == regionalAppUsers$HomeMSOA[i]
         & synPop$Dest == regionalAppUsers$WorkMSOA[i]
         & synPop$Sex == regionalAppUsers$gender[i]
         & synPop$Age == regionalAppUsers$age_band[i])

    #cat(matches)

    # If we cant fit this app user to an existing member of the population, just add them
    if(length(matches) > 0) {
      synPop[matches[1],"AppUser"] = agentId
      synPop[matches[1],"OLon"] = regionalAppUsers$HomeLon[i]
      synPop[matches[1],"OLat"] = regionalAppUsers$HomeLat[i]
      synPop[matches[1],"DLon"] = regionalAppUsers$WorkLon[i]
      synPop[matches[1],"DLat"] = regionalAppUsers$WorkLat[i]
    } else {
      synPop = rbind(synPop, c(as.character(regionalAppUsers$HomeMSOA[i]),
                               as.character(regionalAppUsers$WorkMSOA[i]),
                               regionalAppUsers$age_band[i],
                               regionalAppUsers$gender[i],
                               "E FT", # default as have no info
                               NA,
                               regionalAppUsers$HomeLon[i],
                               regionalAppUsers$HomeLat[i],
                               regionalAppUsers$WorkLon[i],
                               regionalAppUsers$WorkLat[i],
                               agentId))
    }
  }
  return(synPop)
}
