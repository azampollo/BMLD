############### CODE TO EXTRACT MAX CHL-A ################
# This code works with high-resolution (1m) profiles of Chl-a.
# The function maxChla() return a dataframe with three columns:
# - value of max chl-a (MAX_chla)
# - depth of max chl-a (z_maxChla)
# - ID identifying for the profile (variable)

#LOAD CHLA PROFILES 
# The dataset is structured to have three columns: depth, chl-a values and 
# and ID identifyinf for each single profile in the dataset
# arguments: 
# - col_pressure --> column in data (data.frame) with depths
# - col_value --> column in data (data.frame) with Chl-a values
# - col_variable --> column in data (data.frame) identifying for the profiles ID
# profiles are stacked one above the other
# - combinations --> vector of characters listing all the profiles that are going
# to be processed

setwd("C:/Users/")
dataset <- read.table("Chla_profiles.txt", sep = ',', header = T)

head(dataset)
# pressure     profile    value
# 5         id1483_2003 0.18442910
# 6         id1483_2003 0.15961620
# 7         id1483_2003 0.13900230
# 8         id1483_2003 0.14476380
# 9         id1483_2003 0.16267720
# 10        id1483_2003 0.16853030

combinations <- as.character(levels(as.factor(dataset$profile)))
dataset$profile <- as.character(dataset$profile)

# Load function
source('maxChla.R')

# run the function maxChla
output <- maxChla(col_pressure = pressure,
                  col_value = value,
                  col_variable = profile,
                  data = dataset, combinations)
