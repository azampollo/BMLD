## Arianna Zampollo 
# update 26-01-2024
# The function needs the following attributes:
# - pressure: depth or pressure [vector]
# - value: chlorophyll value [vector]
# - variable: id identifying for each profile [character]
# - combinations: id identifying the profiles you want to process [character]


maxChla <- function(col_pressure, col_value, col_variable, combinations, data) { 
  # ASSIGN VALUES 
  dt <- as.data.frame(matrix(data=NA, nrow = length(combinations))) # dataset having one row for each profile
  dt$MAX_chla <- NA #values of Max Chl-a
  dt$z_maxChla <- NA #depth of Max Chl-a
  dt$variable <- combinations #id of the profiles
  dt <- dt[,2:4]
  
  col_pressure <- substitute(col_pressure)
  if(is.symbol(col_pressure)) col_pressure <- deparse(col_pressure)
  col_value <- substitute(col_value)
  if(is.symbol(col_value)) col_value <- deparse(col_value)
  col_variable <- substitute(col_variable)
  if(is.symbol(col_variable)) col_variable <- deparse(col_variable)
  
  # dataset <- as.data.frame(col_pressure)
  # colnames(dataset) <- 'pressure'
  # dataset$value <- col_value
  # dataset$variable <- col_variable
  
  for (n in 1:length(combinations)){  
    #test <- dataset[dataset$variable == combinations[n],]
    test <- data[data[[col_variable]] == combinations[n],]
    test <- test[!is.na(test[[col_value]]),]
    test$prev <- NA
    test$grad_dif <- NA
    test$grad1 <-NA
    
    #standardize Chl-a and pressure from 0 to 1
    # test$pressure_st <- (test$pressure-min(test$pressure, na.rm = T))/abs(max(test$pressure, na.rm = T)-min(test$pressure, na.rm = T))
    # test$value_st <- (test$value-min(test$value, na.rm = T))/abs(max(test$value, na.rm = T)-min(test$value, na.rm = T))
    # 
    test$pressure_st <- (test[[col_pressure]]-min(test[[col_pressure]], na.rm = T))/abs(max(test[[col_pressure]], na.rm = T)-min(test[[col_pressure]], na.rm = T))
    test$value_st <- (test[[col_value]]-min(test[[col_value]], na.rm = T))/abs(max(test[[col_value]], na.rm = T)-min(test[[col_value]], na.rm = T))
    
    
    for (g in 1:nrow(test)){
      test$grad1[g] <- as.numeric(round(abs(test[[col_value]][g+1]-test[[col_value]][g]), digits = 5))
    }
    
    for (g in 2:nrow(test)){
      test$prev[g] <- test$grad1[(g-1)]
    }
    
    
    st <- as.numeric(3:(nrow(test)-6))
    for (value in st) {
      vct3 <- (value-2):value 
      A1 <- lm(test$value_st[vct3] ~ test$pressure_st[vct3])
      
      vct4 <- value:(value+5)            
      A2 <- lm(test$value_st[vct4] ~ test$pressure_st[vct4])
      
      
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
      test$grad_dif[value] <- phi
      
      # if (A1$coefficients[2]<0 && A1$coefficients[2] < A2$coefficients[2]) { #----POSSIBLE ERROR
      #   test$grad_dif_sp2[value] <- 0
      # }
    }
    
    d <- test[order(-test$grad_dif),]
    max <- round(max(d[[col_value]], na.rm = T), digits = 3)
    d$max_dif <- abs(d[[col_value]] - max)
    some <- d[1:5,] #consider only max 4 angle
    
    find01 <- some[order(some$max_dif),]
    
    pos <- match(find01$pressure[1], test$pressure)
    
    # Condition checking for peaks 
    if (mean(test[[col_value]][1:pos-1], na.rm = T)+0.01 > test[[col_value]][pos] && mean(test[[col_value]][pos+1:nrow(test)], na.rm = T) < test[[col_value]][pos]) {
      pos <- match(as.numeric(max), round(test[[col_value]], digits = 3))
    }
    
    dt$MAX_chla[n] <- test[[col_value]][pos]
    dt$z_maxChla[n] <- test[[col_pressure]][pos]
    
  } 
  return(dt)
}
