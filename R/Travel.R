
# Travel - filtering functions for synthetic population based on mode of transport

#  [1] "Work mainly at or from home"          "Underground, metro, light rail, tram"
#  [3] "Train"                                "Bus, minibus or coach"
#  [5] "Taxi"                                 "Motorcycle, scooter or moped"
#  [7] "Driving a car or van"                 "Passenger in a car or van"
#  [9] "Bicycle"                              "On foot"
# [11] "Other method of travel to work"       "UNKNOWN"

# Working from home, other and unknown are discounted from any query

# TransportApi supports car/public/cycle journey types
censusToTransportApiMode = function(censusModeString)
{
  if (censusModeString == "Taxi" |
      censusModeString == "Motorcycle, scooter or moped" |
      censusModeString == "Driving a car or van" |
      censusModeString == "Passenger in a car or van")
    return("car")
  else if (censusModeString == "Bus, minibus or coach" |
           censusModeString == "Underground, metro, light rail, tram" |
           censusModeString == "Train")
    return("public")
  else if (censusModeString == "Bicycle" |
           censusModeString == "On foot")
    return("cycle")
  # "Work mainly at or from home"/"Other method of travel to work"/"UNKNOWN"
  else return(NA)
}



roadOnly = function(synPop) {
  filteredPop = synPop[synPop$Travel == "Bus, minibus or coach" |
                       synPop$Travel == "Taxi" |
                       synPop$Travel == "Motorcycle, scooter or moped" |
                       synPop$Travel == "Driving a car or van" |
                       synPop$Travel == "Passenger in a car or van" |
                       synPop$Travel == "Bicycle" |
                       synPop$Travel == "On foot",]
  return(filteredPop)
}

nonroadOnly = function(synPop) {
  filteredPop = synPop[synPop$Travel == "Underground, metro, light rail, tram" |
                       synPop$Travel == "Train",]
  return(filteredPop)
}

privateOnly = function(synPop) {
  filteredPop = synPop[synPop$Travel == "Motorcycle, scooter or moped" |
                       synPop$Travel == "Driving a car or van" |
                       synPop$Travel == "Passenger in a car or van" |
                       synPop$Travel == "Bicycle" |
                       synPop$Travel == "On foot",]
  return(filteredPop)
}

publicOnly = function(synPop) {
  filteredPop = synPop[synPop$Travel == "Bus, minibus or coach" |
                       synPop$Travel == "Taxi" |
                       synPop$Travel == "Underground, metro, light rail, tram" |
                       synPop$Travel == "Train",]
  return(filteredPop)
}

ownSteamOnly = function(synPop) {
  filteredPop = synPop[synPop$Travel == "Bicycle" |
                       synPop$Travel == "On foot",]
  return(filteredPop)
}
