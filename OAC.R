#Set workspace
setwd("//ds.leeds.ac.uk/staff/staff7/geoces/LIDA internship/Catch project/MicroSim")

#Read in output area classification
oac <- readr::read_csv("2011 OAC Clusters and Names.csv")
oac$X12 <- NULL

#Filter data to Newcastle-upon-Tyne Local Authority area
oac <- oac[which(oac$`Local Authority Code`=="E08000021"), ]

#Read in lookup table
lookup <- readr::read_csv("OA11_LSOA11_MSOA11_LAD11_EW_LUv2.csv")

#Append MSOA to OA data
oac <- merge(oac, lookup[, c("OA11CD", "MSOA11CD", "MSOA11NM")], by.x = "Output Area Code", by.y = "OA11CD")

oacGroup <- data.frame(table(oac$MSOA11CD, oac$`Group Code`))
oacGroup <- oacGroup[order(oacGroup$Var1),]

oacGroupSums <- tapply(oacGroup$Freq, oacGroup$Var1, sum)
oacGroupSums <- as.data.frame(oacGroupSums)
oacGroupSums$MSOA <- row.names(oacGroupSums)
oacGroup <- merge(oacGroup, oacGroupSums, by.x = "Var1", by.y = "MSOA", all.x = TRUE)

oacGroup$perc <- oacGroup$Freq / oacGroup$oacGroupSums
oacGroup$cumul_perc <- ave(oacGroup$perc, oacGroup$Var1, FUN=cumsum)