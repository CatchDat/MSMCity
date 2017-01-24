#Set workspace
setwd("//ds.leeds.ac.uk/staff/staff7/geoces/LIDA internship/Catch project/MicroSim")

#Read in population by gender, age and economic status file
econ_act <- readr::read_tsv("555525193_data.tsv")

#Rename column to remove space
colnames(econ_act)[7] <- "EconomicActivity"
#Rename geography column
colnames(econ_act)[6] <- "MSOA"

#Remove unwanted columns
econ_act$Date <- NULL
econ_act$flag <- NULL
econ_act$Units <- NULL
econ_act$Population <- NULL
econ_act <- econ_act[,-which(colnames(econ_act)=="value type")]

#Remove records containing totals
econ_act <- econ_act[-which(econ_act$Age=="All categories: Age 16 and over"), ]
econ_act <- econ_act[-which(econ_act$Sex=="All persons"), ]
econ_act <- econ_act[-which(econ_act$EconomicActivity=="All categories: Economic activity"), ]
econ_act <- econ_act[-which(econ_act$EconomicActivity=="Economically active: Total"), ]
econ_act <- econ_act[-which(econ_act$EconomicActivity=="Economically inactive: Total"), ]
econ_act <- econ_act[-which(econ_act$EconomicActivity=="Economically active: In employment: Total"), ]
econ_act <- econ_act[-which(econ_act$EconomicActivity=="Economically active: In employment: Employee: Total"), ]
econ_act <- econ_act[-which(econ_act$EconomicActivity=="Economically active: In employment: Self-employed: Total"), ]

#Create an additional column to contain age bands
econ_act$age_band <- NA
econ_act[which(econ_act$Age == "Age 16 to 19"|econ_act$Age == "Age 20 to 21"|econ_act$Age == "Age 22 to 24"), "age_band"] <- 1
econ_act[which(econ_act$Age == "Age 25 to 29"|econ_act$Age == "Age 30 to 34"), "age_band"] <- 2
econ_act[which(econ_act$Age == "Age 35 to 39"|econ_act$Age == "Age 40 to 44"), "age_band"] <- 3
econ_act[which(econ_act$Age == "Age 45 to 49"|econ_act$Age == "Age 50 to 54"), "age_band"] <- 4
econ_act[which(econ_act$Age == "Age 55 to 59"|econ_act$Age == "Age 60 to 64"), "age_band"] <- 5
econ_act[which(econ_act$Age == "Age 65 and over"), "age_band"] <- 6

#Create an additional column to contain a gender code
econ_act$num_sex <- NA
econ_act[which(econ_act$Sex == "Males"), "num_sex"] <- 1
econ_act[which(econ_act$Sex == "Females"), "num_sex"] <- 0

#Create an additional column to contain economic activity category
econ_act$econ_cat <- NA
econ_act[which(econ_act$EconomicActivity == "Economically active: In employment: Employee: Part-time (including full-time students)"), "econ_cat"] <- 0
econ_act[which(econ_act$EconomicActivity == "Economically active: In employment: Employee: Full-time (including full-time students)"), "econ_cat"] <- 1
econ_act[which(econ_act$EconomicActivity == "Economically active: In employment: Self-employed: Part-time (including full-time students)"), "econ_cat"] <- 2
econ_act[which(econ_act$EconomicActivity == "Economically active: In employment: Self-employed: Full-time (including full-time students)"), "econ_cat"] <- 3
econ_act[which(econ_act$EconomicActivity == "Economically active: Unemployed (including full-time students)"), "econ_cat"] <- 4
econ_act[which(econ_act$EconomicActivity == "Economically inactive: Retired"), "econ_cat"] <- 5
econ_act[which(econ_act$EconomicActivity == "Economically inactive: Student (including full-time students)"), "econ_cat"] <- 6
econ_act[which(econ_act$EconomicActivity == "Economically inactive: Looking after home or family"), "econ_cat"] <- 7
econ_act[which(econ_act$EconomicActivity == "Economically inactive: Long-term sick or disabled"), "econ_cat"] <- 8
econ_act[which(econ_act$EconomicActivity == "Economically inactive: Other"), "econ_cat"] <- 9

#Summarise data by msoa, gender and age band
library(dplyr) #Import dplyr libary
sum_econ_act <- summarize(group_by(econ_act, MSOA, num_sex, age_band, econ_cat, EconomicActivity), sum(value))

#Rename frequency column
colnames(sum_econ_act)[6] <- "freq"

#Crosstab area, age and sex by economic activity category
library(reshape)
econ_act_crosstab <- cast(sum_econ_act, MSOA + num_sex + age_band ~ econ_cat)

#Calculate percentage of people economically active
econ_act_crosstab$active_perc <- NA
econ_act_crosstab$active_perc <- (rowSums(econ_act_crosstab[4:8])/rowSums(econ_act_crosstab[4:13]))

#Calculate percentage of people in employment
econ_act_crosstab$employed_perc <- NA
econ_act_crosstab$employed_perc <- (rowSums(econ_act_crosstab[4:7])/rowSums(econ_act_crosstab[4:13]))