setwd("C:/Users/39340/Desktop/MySweetQuarantene/FoF/Final_dataset")
new <- read.table("Final_Profiles_clusters_ED_TMD_MAX&ZChla_SR_auc_autocorr.txt", sep = ",")

#from kelvin to celsius
new$daily_sst <- new$daily_sst - 273.15

#VPGM ---> WONRG!
#http://sites.science.oregonstate.edu/ocean.productivity/
PBT = -00000003.27*new$daily_sst[1]^7 +
  000003.4132*new$daily_sst[1]^6 -
  0001.348 *new$daily_sst[1]^5 +
  002.462 * new$daily_sst[1]^4 -
  0.0205 *new$daily_sst[1]^3 +
  0.0617 *new$daily_sst[1]^2 + 
  0.2749*new$daily_sst[1] +
  1.2956

PP = 0.66125 * PBT*(new$sol_rad_watt_hour[1]/(new$sol_rad_watt_hour[1]+4.1))*new$Z_euph[1]*new$sat_chla[1]*5

setwd("C:/Users/39340/Desktop/MySweetQuarantene/FoF/Final_dataset/Sat_chla/Daily_sat_profiles_shape/Chla_fit")
dt <- read.table("gam_fit_80perc_checked_final_2.txt", sep = ',')
dt$variable <- gsub("X","", dt$variable)

test <- dt[dt$variable == as.character(new$cruise_profile[1]),]
test <- na.omit(test)
insitupp= sum(test$value)

# integrated area under the curve auc for in situ chla
INSITUPP= DescTools::AUC(test$pressure, test$value, from = min(test$pressure, na.rm = T), to=max(test$pressure, na.rm = T), 
                         method = "spline", subdivisions = 200, absolutearea = T)
