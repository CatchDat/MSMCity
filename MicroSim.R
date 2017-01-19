#Create an empty data frame
noEntries <- max(sum_people$cumul_freq)
individuals <- data.frame(ID=seq(1,noEntries), MSOA=rep(NA,noEntries), num_sex=rep(999,noEntries), age_band=rep(999,noEntries))

#Loop through the aggregated population table
for (i in 1:nrow(sum_people)) {
  #Define the start and end row for each age gender category
  startRow <- ((sum_people[i,]$cumul_freq-sum_people[i,]$freq)+1)
  #print(startRow)
  endRow <- (sum_people[i,"cumul_freq"])
  #print(endRow)
  noPeople <- (sum_people[i,"freq"])
  #print(noPeople)
  
  #Fill the table of individuals with attributes from the aggregated population table
  individuals[startRow:endRow,]$MSOA <- rep(sum_people[i,]$MSOA,noPeople)
  individuals[startRow:endRow,]$num_sex <- rep(sum_people[i,]$num_sex,noPeople)
  individuals[startRow:endRow,]$age_band <- rep(sum_people[i,]$age_band,noPeople)
}

#Merge economic activity data table with individuals data table
individuals2 <- merge(econ_act_crosstab[, c("MSOA", "num_sex", "age_band", "active_perc", "employed_perc")], individuals, by = c("MSOA", "num_sex", "age_band"), all=TRUE)

#Assign an economic activity percentage and employed percentage of zero to people aged under 16
individuals2[which(individuals$age_band == 0), "active_perc"] <- 0
individuals2[which(individuals$age_band == 0), "employed_perc"] <- 0

#Generate a random number for each row
individuals2$rand <- runif(noEntries, 0, 1)

#Create field with economically active flag
individuals2[which(individuals2$rand < individuals2$active_perc), "econ_active"] <- 1
individuals2[which(individuals2$rand >= individuals2$active_perc), "econ_active"] <- 0

#Create field with in employment flag
individuals2[which(individuals2$rand < individuals2$employed_perc), "in_employment"] <- 1
individuals2[which(individuals2$rand >= individuals2$employed_perc), "in_employment"] <- 0

individuals2$rand <- NULL

#Remove rows with value of zero from workplaces table
tempWorkplaces <- workplaces[which(workplaces$value>0),]

#Assign workplace
individuals2$work_MSOA <- NA
for(i in 1:length(unique(individuals2$MSOA))){
  randNum <- runif(length(which(individuals2$MSOA==unique(individuals2$MSOA)[i]&individuals2$in_employment==1)),0,1)
  workLookup <- spatstat::lut(tempWorkplaces[which(tempWorkplaces$origin==unique(individuals2$MSOA)[i]),]$destination,
                            breaks=c(0,unique(tempWorkplaces[which(tempWorkplaces$origin==unique(individuals2$MSOA)[i]),]$cumul_perc)))
  individuals2[which(individuals2$MSOA==unique(individuals2$MSOA)[i]&individuals2$in_employment==1),]$work_MSOA<-workLookup(randNum)
}
individuals2[which(individuals2$age_band == 0), "work_MSOA"] <- "NA"
individuals2[which(individuals2$in_employment==0 & individuals2$age_band > 0), "work_MSOA"] <- "UNEMP"

#Check
individuals2$flag <- 1
check <- summarize(group_by(individuals2, MSOA, work_MSOA), sum(flag))

#Remove rows with value of zero from area type table
tempoacGroup <- oacGroup[which(oacGroup$Freq>0),]
tempoacGroup$Var2 <- as.character(tempoacGroup$Var2)

#Assign area type of home location
individuals2$area_type <- NA
for(i in 1:length(unique(individuals2$MSOA))){
  randNum <- runif(length(which(individuals2$MSOA==unique(individuals2$MSOA)[i])),0,1)
  areaLookup <- spatstat::lut(tempoacGroup[which(tempoacGroup$Var1==unique(individuals2$MSOA)[i]),]$Var2,
                              breaks=c(0,unique(tempoacGroup[which(tempoacGroup$Var1==unique(individuals2$MSOA)[i]),]$cumul_perc)))
  individuals2[which(individuals2$MSOA==unique(individuals2$MSOA)[i]),]$area_type <- areaLookup(randNum)
}

#Assign agent
individuals2$agent <- NA
#Assign an app user to eah individual in the synthetic population based on age and gender
# nrow(unique(individuals2[,c("MSOA","num_sex","age_band","work_MSOA")]))
for(i in 1:nrow(unique(individuals2[,c("num_sex","age_band")]))){
  print(paste("working on numeric gender ",unique(individuals2[,c("num_sex","age_band")])$num_sex[i],", age band ",unique(individuals2[,c("num_sex","age_band")])$age_band[i],sep=""))
  if(length(which(appUsers$age_band==unique(individuals2[,c("num_sex","age_band")])$age_band[i]&
                  appUsers$num_gender==unique(individuals2[,c("num_sex","age_band")])$num_sex[i]))>0){
    randNum<-runif(length(which(individuals2$num_sex==unique(individuals2[,c("num_sex","age_band")])$num_sex[i]&
                                  individuals2$age_band==unique(individuals2[,c("num_sex","age_band")])$age_band[i])),0,1)
    #Create a lookup table containing the agentIDs of the appUsers in the same gender and age band as the individual in the synthetic population
    agentLookup <- spatstat::lut(appUsers[which(appUsers$age_band==unique(individuals2[,c("num_sex","age_band")])$age_band[i]&
                                                  appUsers$num_gender==unique(individuals2[,c("num_sex","age_band")])$num_sex[i]),]$agentID,
                                 breaks=c(0,seq(1:length(which(appUsers$age_band==unique(individuals2[,c("num_sex","age_band")])$age_band[i]&
                                                                        appUsers$num_gender==unique(individuals2[,c("num_sex","age_band")])$num_sex[i])))/
                                            length(which(appUsers$age_band==unique(individuals2[,c("num_sex","age_band")])$age_band[i]&
                                                           appUsers$num_gender==unique(individuals2[,c("num_sex","age_band")])$num_sex[i])))
                                 )
    individuals2[which(individuals2$num_sex==unique(individuals2[,c("num_sex","age_band")])$num_sex[i]&
                         individuals2$age_band==unique(individuals2[,c("num_sex","age_band")])$age_band[i]),]$agent<-agentLookup(randNum)
  }  
}

write.csv(individuals2, "output.csv", row.names = FALSE)