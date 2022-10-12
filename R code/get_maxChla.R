############### CODE TO EXTRACT MAX CHL-A ################
# This code works with high-resolution (1m) profiles of Chl-a.
# The function maxChla() return a dataframe with three columns:
# - value of max chl-a (MAX_chla)
# - depth of max chl-a (z_maxChla)
# - id code identifying for the profile (variable)

#LOAD CHLA PROFILES
# arguments: 
# - depth --> column name "pressure"
# - Chl-a values --> column name "value"
# - id code identifying each profile --> column name "variable"
# profiles are stacked one above the other
setwd("C:/Users/")
dataset <- read.table("Chla_profiles.txt")

combinations <- as.character(levels(as.factor(dataset$variable)))
dataset$variable <- as.character(dataset$variable)

# Load function
maxChla <- function(pressure, value, combinations) { 
  # ASSIGN VALUES 
  dt <- as.data.frame(matrix(data=NA, nrow = length(combinations))) # dataset having one row for each profile
  dt$MAX_chla <- NA #values of Max Chl-a
  dt$z_maxChla <- NA #depth of Max Chl-a
  dt$variable <- combinations #id of the profiles
  dt <- dt[,2:4]
  
  for (n in 1:length(combinations)){  
      test <- dataset[dataset$variable == combinations[n],]
      dd <- na.omit(test)
      dd$prev <- NA
      dd$grad_dif <- NA
      dd$grad1 <-NA
      
      #standardize Chl-a and pressure from 0 to 1
      dd$pressure_st <- (dd$pressure-min(dd$pressure, na.rm = T))/abs(max(dd$pressure, na.rm = T)-min(dd$pressure, na.rm = T))
      dd$value_st <- (dd$value-min(dd$value, na.rm = T))/abs(max(dd$value, na.rm = T)-min(dd$value, na.rm = T))
      
      
      for (g in 1:nrow(dd)){
        dd$grad1[g] <- as.numeric(round(abs(dd$value[g+1]-dd$value[g]), digits = 5))
      }
      
      for (g in 2:nrow(dd)){
        dd$prev[g] <- dd$grad1[(g-1)]
      }
      
      
      st <- as.numeric(3:(nrow(dd)-6))
      for (value in st) {
        vct3 <- (value-2):value 
        A1 <- lm(dd$value_st[vct3] ~ dd$pressure_st[vct3])
        
        vct4 <- value:(value+5)            
        A2 <- lm(dd$value_st[vct4] ~ dd$pressure_st[vct4])
        
        
        # define angles used to measure phi
        alpha <- atan(abs(A1$coefficients[2])) #A1
        alpha_1 <- abs(pi/2 - alpha)
        gamma <- atan(abs(A2$coefficients[2])) #A2
        gamma_1 <- abs(pi/2 -gamma)
        
        # check
        # dev.new()
        # plot(d$value_st ~ d$pressure_st)
        # abline(A1)
        # abline(A2, col="red")
        
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
        
        # if (A1$coefficients[2]<0 && A1$coefficients[2] < A2$coefficients[2]) { #----POSSIBLE ERROR
        #   dd$grad_dif_sp2[value] <- 0
        # }
      }
      
      d <- dd[order(-dd$grad_dif),]
      max <- round(max(d$value, na.rm = T), digits = 3)
      d$max_dif <- abs(d$value - max)
      some <- d[1:5,] #consider only max 4 angle
      
      find01 <- some[order(some$max_dif),]
      
      pos <- match(find01$pressure[1], dd$pressure)
      
      # Condition checking for peaks 
      if (mean(dd$value[1:pos-1], na.rm = T)+0.01 > dd$value[pos] && mean(dd$value[pos+1:nrow(dd)], na.rm = T) < dd$value[pos]) {
        pos <- match(as.numeric(max), round(dd$value, digits = 3))
      }
      
      dt$MAX_chla[n] <- dd$value[pos]
      dt$z_maxChla[n] <- dd$pressure[pos]
      
  } 
  return(dt)
}

# run the function maxChla

output <- maxChla(dataset$pressure, dataset$value, combinations)
