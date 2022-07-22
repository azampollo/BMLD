# Zampollo et al. "A proxy of subsurface Chlorophyll-a in shelf waters: use of density profiles 
# and the below mixed layer depth (BMLD)", https://doi.org/10.5194/egusphere-2022-140, 2022.
# 22 July 2022
# Arianna Zampollo
# email: zampolloarianna@gmail.com 

# Arguments to give:
# - dataset: is a dataframe having 3 columns named as: 
#   pressure: column with depths at each observation (row) (numeric)
#   value: column with density at each depth (row) (numeric)
#   profile: ID identifying the profiles of each observations (row) (character)
# - profileID: vector of ID (as character) identifying all the input profile.
# - both: logical (T/F) to specify the indetification of both AMLD and BMLD (both=TRUE), 
#   or the identification of BMLD (both=FALSE)

# The code deletes the rows with NAs.
# The function is constrained to identify AMLD up to 30 m depth
# You can claculate both parameters, AMLD and BMLD, specyifing "both = TRUE", 
# or  you can get only BMLD specifying "both=FALSE".

# The function returns a dataframe with:
# - profileID: the ID identifying for the profile
# - AMLD
# - BMLD
# - n: number of observations between AMLD and BMLD

abmld <- function(dataset, profileID, both = TRUE) {          
  out <- as.data.frame(matrix(data = NA, nrow = length(profileID), ncol = 4))
  colnames(out) <- c('profileID', 'AMLD', 'BMLD', 'n')
  out$profileID <- profileID
  
  
  for (n in 1:nrow(out)){  
    test <- dataset[dataset$profile == out$profileID[n],] 
    
    if (nrow(test) < 1) {
      stop("Check if the ID of your profiles in dataset and profileID are characters")
    } else {
    
    dd <- test[!is.na(test$value),] #delete rows with NA in DENSITY (issues with MLDs calcualtion)
    dd$value <- dd$value 
    
    dd$grad1 <-NA
    dd$grad_dif <-NA
    dd$prev <- NA
    
    dd$pressure_st <- (dd$pressure-min(dd$pressure, na.rm = T))/abs(max(dd$pressure, na.rm = T)-min(dd$pressure, na.rm = T))
    dd$value_st <- (dd$value-min(dd$value, na.rm = T))/abs(max(dd$value, na.rm = T)-min(dd$value, na.rm = T))
    
    for (g in 1:nrow(dd)){
      dd$grad1[g] <- as.numeric(round(abs(dd$value[g+1]-dd$value[g]), digits = 5))

    }
    for (g in 2:nrow(dd)){
      dd$prev[g] <- dd$grad1[(g-1)]
    }
    
    # plot(dd$value_st, -dd$pressure_st)
    # plot(dd$value, -dd$pressure)
    
    # CALCUALTE PHI
    st <- as.numeric(3:(nrow(dd)-4))
    for (value in st) {
      vct3 <- (value-2):value 
      A1 <- lm(dd$value_st[vct3] ~ dd$pressure_st[vct3])
      
      vct4 <- value:(value+3)   # 4 POINTS TO DRAW LM - BECAUSE HIGHER RESOLUTION OF DATA DUE TO DEEPER PROFILE - HOWEVER, THE NUMBER OF POINT SHOULD BE DECIDED AFTER HAVE SEEN HOW MANY POINTS THERE ARE WHERE THE MLD IS PRESENT. IF IT IS REPRESENTED BY 4 POINTS, NO MORE UNNECESSARY POINTS SHOULD BE CHOSEN
      A2 <- lm(dd$value_st[vct4] ~ dd$pressure_st[vct4])
      
      #OPZ.3
      alpha <- atan(abs(A1$coefficients[2])) #A1
      alpha_1 <- abs(pi/2 - alpha)
      gamma <- atan(abs(A2$coefficients[2])) #A2
      gamma_1 <- abs(pi/2 -gamma)
      
      #   # check
      #   # dev.new()
      #   # plot(d$value_st ~ d$pressure_st)
      #   # abline(A1)
      #   # abline(A2, col="red")
      
      if (A1$coefficients[2]<0 & A2$coefficients[2]<0) { #when both have negative slopes
        phi <- abs(gamma_1 - alpha_1)
      } else if (A1$coefficients[2]>0 & A2$coefficients[2]>0){ #when both have positive slopes
        phi <- abs(gamma - alpha)
      } else if (A1$coefficients[2]<0 & A2$coefficients[2]>0) { #A1 negativa e A2 positiva
        phi <- abs(gamma + alpha)
        
      } else { #A1 positiva e A2 negativa: A1$coefficients[2]>0 & A2$coefficients[2]<0
        
        phi <- abs(alpha + gamma)
        
      }
      dd$grad_dif[value] <- phi
    }
    
    
    
    ##### BMLD #####

    ## CHANGES IN 27/04/21 
    per15 <- nrow(dd)-round((dd$pressure[nrow(dd)]*10)/100)
    d <- dd[1:per15,]
    
    min <- round(min(d$value, na.rm = T), digits = 3)
    max <- round(max(d$value, na.rm = T), digits = 3)
    d$value <- round(d$value, digits = 3)
    
    
    ## PROFILES with DENSITY ABOVE PYCNOCLINE HIGHER THAN BELOW IT
    if (d$pressure[match(min, d$value)] > d$pressure[match(max, d$value)]) {
      
      # find depth with mean
      mean <- max-((max-min)/2)
      d$findmean <- abs(d$value - mean)

      or0 <- d[d$pressure <= 40,]
      or<- or0[order(or0$findmean),]
      brek <- min(or$pressure[1:2]) #take shallowest point between the closest two
      d <- d[order(d$pressure),]
      pos0 <- match(brek, d$pressure)
      
      
      pos_sp2_1 <- pos0-1 # 2 points above the mean 
      if (pos_sp2_1 < 1){ # if the pos0 is close to the surface take from the first point if there are not 6 points above the pos0
        pos_sp2_1 <- 1
      }
      split2_1 <- d[pos_sp2_1:nrow(d),] # Part with the maximum value - PART ON THE RIGHT
      
    } else {
      
      ## PROFILES with DENSITY ABOVE PYCNOCLINE LOWER THAN BELOW IT
      
      mean <- ((max-min)/2) + min
      d$findmean <- abs(d$value - mean)

      or0 <- d[d$pressure <= 40,]
      or<- or0[order(or0$findmean),] # select shallower value close to the mean 
      brek <- min(or$pressure[1:2]) #take shallower point between the closest two
      d <- d[order(d$pressure),]
      pos0 <- match(brek, d$pressure)
      
      pos_sp2_1 <- pos0-1
      if (pos_sp2_1 < 1){ # if the pos0 is close to the surface take from the first point if there are not 6 points above the pos0
        pos_sp2_1 <- 1
      }
      split2_1 <- d[pos_sp2_1:nrow(d),] # Part with the maximum value - PART ON THE RIGHT
      
    }
    
    
    if (nrow(split2_1) > 3) {
      # KMEANS
      km <-kmeans(na.omit(split2_1$grad1), 3, algorithm = "Lloyd")
      km <- as.data.frame(km$cluster)
      split2_1$cluster[which(!is.na(split2_1$grad1))] <- km[,1]
      split2_1$cc <- NA
      
      
      for (i in 2:(nrow(split2_1)-1)){
        p2 <- i-1
        if (split2_1$cluster[i] == split2_1$cluster[i+1]  && split2_1$cluster[i] != split2_1$cluster[p2]) { #if two points before my main point are equal, and the sucessive point is equal to the main, and the main and the previous one are different, put TRUE = which means it's a breaking point between two two consecutive points that are appartengono at one cluster and two other points to another cluster
          split2_1$cc[i] <- TRUE
        } else {
          split2_1$cc[i] <- FALSE
        }
        
      }
      
      split2 <- split2_1[!is.na(split2_1$cc),] 
      
      find_max_s2 <- split2[order(-split2$grad_dif),] #take max
      ff_s2 <- find_max_s2[1:5,] #take and test 5 max PHI 
      find_s2 <- ff_s2[!is.na(ff_s2$cc),] #delete those with NA in cc (at the end or at the beginning of the split 2), it needs to be done because it is a condition after and it cannot be NA
      
      filterT <- find_s2[find_s2$cc ==T,]
      
      if (any(find_s2$cc) == FALSE) { # cehck if all the logical value in cc all FALSE? 
        for (i in 1:nrow(find_s2)) {
          
          if (find_s2$grad1[i] < find_s2$prev[i]){ 
            find0 <- find_s2[i,]
            break 
            
          } else  {next}
          
        }
        if (exists("find0") ==F){
          find_s2$grad_prevdif <- abs(find_s2$prev - find_s2$grad1)
          find0 <- find_s2[order(-find_s2$grad_prevdif),]
        }
        pos <- match(find0$pressure[1], d$pressure)
      } else if (all(filterT$grad1 > filterT$prev) == T) { # ARE THERE IN FIND_2 ROWS WITH TRUE VALUES IN CC AND GRAD1 < PREV
        for (i in 1:nrow(find_s2)) {
          
          if (find_s2$grad1[i] < find_s2$prev[i]){ 
            find0 <- find_s2[i,]
            break 
            
          } else  {next}
          
        } 
        if (exists("find0") ==F){
          find_s2$grad_prevdif <- abs(find_s2$prev - find_s2$grad1)
          find0 <- find_s2[order(-find_s2$grad_prevdif),]
        }
        pos <- match(find0$pressure[1], d$pressure)
      } else { # IT HAPPENS IF THERE ARE ROWS WITH TRUE VALUES IN CC AND GRAD1 < PREV
        
         
        for (i in 1:nrow(find_s2)) {
          if ((find_s2$cc[i] == T && find_s2$grad1[i] < find_s2$prev[i]) == T){ 
            find0 <- find_s2[i,]
            break 
            
          } else  {next}
        }
        pos <- match(find0$pressure[1], d$pressure) # ROW position
      }
      
      if (abs(find0$pressure[1] - find_s2$pressure[1]) ==1) { 
        pos <- match(find_s2$pressure[1], d$pressure)
      }
      
      out$BMLD[n] <- d$pressure[pos] # PUT n BECAUSE THE LOOP IS IN THE SEQUENCE OF DATASET
      
      options(warn=-1)
      rm(d, brek, find0, filterT, find_s2, split2, split2_1) # NOT DELETE POS, used in AMLD 
      options(warn=0)
      
    } else {
      warning(paste(profileID[n], "has not enaugh points to calculate BMLD and AMLD", sep = " "))
      out$BMLD[n] <- NA
      out$AMLD[n] <- NA
    }
    
    
    ##### AMLD ######
    if (both == TRUE) {
    if (is.na(out$BMLD[n]) == T) {
      next
    } else {
      
      split1_1 <- dd[1:(pos-2),] # from 2 points above BMLD to surface

      if (nrow(split1_1) >=3) {
        km1 <-kmeans(na.omit(split1_1$grad1), 2, algorithm = "Lloyd")
        km1 <- as.data.frame(km1$cluster)
        split1_1$cluster[which(!is.na(split1_1$grad1))] <- km1[,1]
        split1_1$cc <- NA
        
        
        for (i in 3:(nrow(split1_1))){
          p1 <- i-2 # 
          p2 <- i-1
          if (split1_1$cluster[p1] == split1_1$cluster[p2] && split1_1$cluster[i] != split1_1$cluster[p1]) { #if two points before my main point are equal, and the sucessive point is equal to the main, and the main and the previous one are different, put TRUE = which means it's a breaking point between two two consecutive points that are belonging to one cluster and two other points to another cluster
            split1_1$cc[i] <- TRUE
          } else {
            split1_1$cc[i] <- FALSE
          }
          
        }
        
        split1_1$cc[2] <- ifelse(split1_1$cluster[1]!= split1_1$cluster[2], TRUE, FALSE) #for the second row comparison of just the first two rows
        
        split1 <- split1_1[!is.na(split1_1$cc),] #it deletes 2 points on the surface minimum and it includes only 3 points before the middle point (pos0)
        
        #SELECT FROM BMLD THE LAST TRUE
        find_max_s1 <- split1[order(-split1$grad_dif),] #take max
        ff_1 <- find_max_s1[1:3,] ##CHANGED FROM 4 TO 3
        find_s1 <- ff_1[!is.na(ff_1$cc),] 
        find_s1 <- ff_1[!is.na(ff_1$grad_dif),] 
        
        #IF THERE ARE NOT TRUE VALUES WITHIN ff_1 (max 4 PHI angles)
        if (any(find_s1$cc) == FALSE) { # all the logical value in cc all FALSE? 
          for (i in 1:nrow(find_s1)) {
            
            #HAD TO ADD LIMIT OF AMLD TO 30 M WITH THIS CONDITION OF ALL FALSE BECAUSE IT CATCHES DEEP POINTS
            if ((find_s1$grad1[i] > find_s1$prev[i] && find_s1$pressure[i] <=30) ==T){ # choose the first layer with highest PHI but above 30 m depth and with the gradient larger than the gradient of the point before
              find01 <- find_s1[i,]
              break 
              
            } else  {next}
            
          }
          if (exists("find01") ==F){ # if all the cluster are the same, then take 1st depth because they are all in the pycnocline
            f1 <- split1_1[order(split1_1$pressure),]
            find01 <- f1[order(f1$pressure),]
          } else if (find01$grad_dif < 0.65){
            f1 <- split1_1[order(split1_1$pressure),]
            find01 <- f1[order(f1$pressure),]
          } 
          pos_s1 <- match(find01$pressure[1], dd$pressure)
          
          
          # IF THERE ARE TRUE VALUES WITHIN ff_1 (max 4 PHI angles)
        } else if (any(find_s1$cc) == TRUE) { #IF THERE ARE TRUE VALUES WITHIN HIGH ANGLES, IT MEANS THAT THE SURFACE MLD IS MORE STABLE, CONDITIONS:
          
          filterT_1 <- find_s1[find_s1$cc ==T,]
          
          if (all(filterT_1$grad1 < filterT_1$prev) == T) { # if all true values have grad1 < prev, take first position
            for (p in 1:nrow(split1_1)){
              if (split1_1$grad1[p] > 0.021) {
                find01 <- split1_1[p,]
                break
              } else {next}
            }

            
          } else { # if there is a true value with grad1 > prev, take the first one in order of biggest angle
            
            for (i in 1:nrow(filterT_1)) {
              
              if (filterT_1$grad1[i] > filterT_1$prev[i] && filterT_1$grad_dif[i] >=0.65){ 
                find01 <- filterT_1[i,]
                break 
                
              } else  {next}
              
            }
            if (exists("find01") ==F) { # if there is not any find01, then use threshold
              for (p in 1:nrow(split1_1)){
                if (split1_1$grad1[p] > 0.021) {
                  find01 <- split1_1[p,]
                  break
                } else {next}
              }
            }
            
          }
          pos_s1 <- match(find01$pressure[1], dd$pressure)
        }
        
        #CHECK OF THE LOOP ABOVE: IF ALL THE CLUSTERS ABOVE the candidate for AMLD ARE ARE THE SAME, THEN TAKE THIS MLD, OTHERWISE USE THRESHOLD -- it avoids steps in the middle of the pycnocline
        pos_s <- as.numeric(pos_s1-1)
        if ((length(unique(na.omit(split1_1$cc[1:pos_s])))==1)==F){ #if ANY of the values from pos_s1 and the surface is true, then ignore pos_s1 and select by threshold. If all the values above AMLD are the not the same of the first one, use threshold
          for (p in 1:nrow(split1_1)){
            if (split1_1$grad1[p] > 0.021) {
              find01 <- split1_1[p,]
              break
            } else {next}
            
          }
          pos_s1 <- match(find01$pressure[1], dd$pressure)
          
        } 
        
        # IF SPLIT 1 WITH < 3 VALUES
      } else {
        for (p in 1:nrow(split1_1)){
          if (split1_1$grad1[p] > 0.021) {
            find01 <- split1_1[p,]
            break
          } else {next}
          
        }
        if (exists("find01") ==F){ # 
          
          find01 <- split1_1[order(split1_1$pressure),]
        }
        pos_s1 <- match(find01$pressure[1], dd$pressure) # if there are no grad dif values, it takes the first row
      } 
      
      
      out$AMLD[n] <- dd$pressure[pos_s1]
      out$n[n] <- pos-pos_s1
      
      options(warn=-1)
      rm(pos, pos_s, pos_s1, find01, filterT_1, find_s1, split1, split1_1)
      options(warn=0)
    }
    } else {next}
    }
  }

  return(out)                    # Return output
}


