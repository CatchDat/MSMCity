#Set workspace
setwd("//ds.leeds.ac.uk/staff/staff7/geoces/LIDA internship/Catch project/MicroSim")

#Read in population by age and gender file
people <- readr::read_tsv("1964726853_data.tsv")

#Convert field type to numeric
people$Date <- as.numeric(people$Date)
people$value <- as.numeric(people$value)

#Remove unwanted columns
people$Date <- NULL
people$flag <- NULL
people$Units <- NULL
people$Population <- NULL
people <- people[,-which(colnames(people)=="value type")]

#Remove records containing totals
people <- people[-which(people$Age=="All categories: Age"), ]
people <- people[-which(people$Sex=="All persons"), ]

#Create a new empty column to contain the numerical age
people$num_age <- NA
#Assign a value of 0 to records in which age is under 1
people[which(people$Age == "Age under 1"), "num_age"] <- 0
#Assign a value of 85 to records in which age is 85 or over
people[which(people$Age == "Age 85 and over"), "num_age"] <- 85
#Extract age value from remaining records
people[which(is.na(people$num_age)), "num_age"] <- substr(people[which(is.na(people$num_age)),]$Age, 5, 7)
#Convert field type to numeric
people$num_age <- as.numeric(people$num_age)

#Create an additional column to contain age bands
people$age_band <- NA
#Aggregate numeric age field to age band
people$age_band <- findInterval(people$num_age, c(16,25,35,45,55,65))

#Create an additional column to contain a gender code
people$num_sex <- NA
people[which(people$Sex == "Males"), "num_sex"] <- 1
people[which(people$Sex == "Females"), "num_sex"] <- 0

#Create an additional column containing the MSOA code
people$MSOA <- NA
people$MSOA <- substr(people$"2011 super output area - middle layer", 0, 9)

#Summarise data by msoa, gender and age band
library(dplyr) #Import dplyr libary
sum_people <- summarize(group_by(people, MSOA, num_sex, age_band), sum(value))

#Rename frequency column
colnames(sum_people)[4] <- "freq"
#Calculate cumulative frequency
sum_people$cumul_freq <- cumsum(sum_people$freq)