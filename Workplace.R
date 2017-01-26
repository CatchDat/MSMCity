#Set workspace
setwd("//ds.leeds.ac.uk/staff/staff7/geoces/LIDA internship/Catch project/MicroSim")

#Read in origin-destination flows
workplaces <- readr::read_tsv("963712085_data.tsv")

#Rename current residence column
colnames(workplaces)[colnames(workplaces)=="currently residing in : 2011 super output area - middle layer"] <- "origin"
#Rename place of work column
colnames(workplaces)[colnames(workplaces)=="place of work"] <- "destination"

#Remove unwanted columns
workplaces$Population <- NULL
workplaces$Units <- NULL
workplaces$Date <- NULL
workplaces$flag <- NULL
workplaces$`value type` <- NULL

#Trim origin field
workplaces$origin <- substr(workplaces$origin, 1, 9)

#Rename fields
workplaces$destination <- substr(workplaces$destination, 16, 50)
workplaces[which(workplaces$destination == "Northern Ireland"), "destination"] <- "NI"
workplaces[which(workplaces$destination == "Mainly work at or from home"), "destination"] <- "WFH"
workplaces[which(workplaces$destination == "Offshore installation"), "destination"] <- "OFF"
workplaces[which(workplaces$destination == "No fixed place"), "destination"] <- "NON"
workplaces[which(workplaces$destination == "Outside UK"), "destination"] <- "OUT"

#Trim destination field
workplaces$destination <- substr(workplaces$destination, 1, 9)

#Sort data by origins column
workplaces <- workplaces[order(workplaces$origin),]

#Add origin totals to data frame
originSums <- tapply(workplaces$value, workplaces$origin, sum)
originSums <- as.data.frame(originSums)
originSums$MSOA <- row.names(originSums)
workplaces <- merge(workplaces, originSums, by.x = "origin", by.y = "MSOA", all.x = TRUE )

#Calculate percentage of people commuting to each workplace
workplaces$perc <- workplaces$value / workplaces$originSums

#Calculate cumulative percentage
workplaces$cumul_perc <- ave(workplaces$perc, workplaces$origin, FUN=cumsum)