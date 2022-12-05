# Zampollo et al. "The mixed layer depth below the pycnocline (BMLD) as an ecological indicator of subsurface chlorophyll-a", 
# https://doi.org/10.5194/egusphere-2022-140, 2022.
# 22 July 2022
# Arianna Zampollo
# email: zampolloarianna@gmail.com 


# This code run abmld.R function to get MLD and BMLD from vertical profiles of density 
# at a high vertical resolution (1 m).
# MLD and BMLD identifyied for trofiles having a pycnocline with less than 4 points should be checked.

##### Load dataset with 12 profiles of denisty at 1 m depth vertical resolution #####
setwd("./")
dataset <- read.table("profiles_example.txt", sep = ',', header = T)
head(dataset)
# pressure     profile    value
# 5         id1483_2003 1026.300
# 6         id1483_2003 1026.315
# 7         id1483_2003 1026.325

# the dataset is structured with depths values in column "pressure"
# the id identifying for each profile in "profile"
# the density value in "value"

## the function works with IDs identifying profiles specifyied as character
dataset$profile <- as.character(dataset$profile)

## get vector of identifying names for each profile #####
profileID <- as.character(levels(as.factor(dataset$profile)))

##### GET MLD and BMLD ####
## download abmld.R and load it
setwd("./")
source("abmld.R")

## extract MLD and BMLD
# Arguments to give:

# - dataset: is a dataframe having 3 columns named as: 
#   pressure: column with depths at each observation (row) (numeric)
#   value: column with density at each depth (row) (numeric)
#   profile: ID identifying the profiles of each observations (row) (character)
# - profileID: vector of ID (as character) identifying all the input profile.

# The code deletes the rows with NAs.
# The function is constrained to identify MLD up to 30 m depth
# You can claculate both parameters, MLD and BMLD, specyifing "both = TRUE", 
# or  you can get only BMLD specifying "both=FALSE".

# The function returns a dataframe with:
# - profileID: the ID identifying for the profile
# - MLD
# - BMLD
# - n: number of observations between MLD and BMLD


out1 <- abmld(dataset, profileID, both=TRUE)

##### PLOT results #####
id=1 # choose the profile to plot
test <- dataset[dataset$profile == out1$profileID[id],] 
plot(test$value, -test$pressure, type = 'o', pch=20, xlab = "p", ylab = "Depth")
abline(h=-(out1$MLD[id]), col="red")
abline(h=-(out1$BMLD[id]), col="blue")

legend("bottomleft", legend=c("MLD", "BMLD"),
       col=c("red", "blue"), lty=1:2, cex=0.8)

