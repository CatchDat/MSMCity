# Economic Category
# =================
#"Economically active: In employment: Employee: Part-time (including full-time students)"), "econ_cat"] <- 0
#"Economically active: In employment: Employee: Full-time (including full-time students)"), "econ_cat"] <- 1
#"Economically active: In employment: Self-employed: Part-time (including full-time students)"), "econ_cat"] <- 2
#"Economically active: In employment: Self-employed: Full-time (including full-time students)"), "econ_cat"] <- 3
#"Economically active: Unemployed (including full-time students)"), "econ_cat"] <- 4
#"Economically inactive: Retired"), "econ_cat"] <- 5
#"Economically inactive: Student (including full-time students)"), "econ_cat"] <- 6
#"Economically inactive: Looking after home or family"), "econ_cat"] <- 7
#"Economically inactive: Long-term sick or disabled"), "econ_cat"] <- 8
#"Economically inactive: Other"), "econ_cat"] <- 9
#
# Sex
# ===
# F 0
# M 1
#sexLabels <- c("F", "M")

# Age Band
# ========
# 16-24: 1
# 25-34: 2
# 35-44: 3
# 45-54: 4
# 55-64: 5
#  >=65: 6
ageBandSexLabels <- c("F16-24", "F25-34", "F35-44", "F45-54", "F55-64", "F65+",
                      "M16-24", "M25-34", "M35-44", "M45-54", "M55-64", "M65+")

# assumes running from root of MSMCity
pop <- read.csv("data/pop_E02001708.csv")
od <- read.csv("data/od_E02001708.csv")

# filter out non-working population
pop <- pop[pop$econ_cat<4,]
print("MSOA=E02001708")
print(paste("Working population (pop)", sum(pop$freq)))
print(paste("Working population (od)", sum(od$value)))

# I'm sure there are better ways of extracting the category totals...
sex <- c(sum(pop[pop$sex==0,]$freq), sum(pop[pop$sex==1,]$freq))
age <- c(sum(pop[pop$age_band==1,]$freq), sum(pop[pop$age_band==2,]$freq), sum(pop[pop$age_band==3,]$freq),
         sum(pop[pop$age_band==4,]$freq), sum(pop[pop$age_band==5,]$freq), sum(pop[pop$age_band==6,]$freq))

ageSexIndex <- c(pop$sex*6+pop$age_band)
ageSex <- c(pop$freq)

destLabels <-od[od$value>0,"destination"]
dests <- od[od$value>0, "value"]

msim <- humanleague::synthPop(list(dests, ageSex), 100)
print(paste("Conv ", msim$conv, " after", msim$attempts, "attempts"))
if (!msim$conv) {
  print("humanleague::synthPop not converged, falling back to ipfp with synthPop result as seed")
  msim<-mipfp::Ipfp(msim$x.hat,list(1,2),list(dests, ageSex))
  print(paste("IPFP conv ", msim$conv))
  stopifnot(sum(msim$x.hat) == sum(dests))
  stopifnot(abs(sum(colSums(msim$x.hat)-ageSex)) < 1e-8 )
  stopifnot(abs(sum(rowSums(msim$x.hat)-dests)) < 1e-8 )
}

#synPop<-data.frame(Dest=character(), Sex=character(), AgeBand=character(), NumPeople=double())

indices<-which(msim$x.hat > 1e-8, arr.ind=T)
values<-msim$x.hat[indices]

synPop<-data.frame(Dest=destLabels[indices[,1]], AgeSex=ageBandSexLabels[ageSexIndex[indices[,2]]], NumPeople=values)

write.csv(synPop, "msim_E02001708.csv");
