# https://xgboost.readthedocs.io/en/latest/R-package/xgboostPresentation.html
# http://topepo.github.io/caret/data-splitting.html
# https://github.com/rachar1/DataAnalysis/blob/master/xgboost_Classification.R

library(tidyverse)
library(caret)
library(xgboost)
library(lubridate)

setwd("~/github/twist_zrh")

twist_zrh_cleaned <- readRDS("~/github/twist_zrh/twist_zrh_cleaned.RDS") %>% select(-geometry,-airport_type,
                                                                                    -iso_country,-flightnr,-iso_region,
                                                                                    -origin_destination_name,
                                                                                    -municipality)

flightdata <- twist_zrh_cleaned %>%
  mutate(delayed = ifelse(abs(as.numeric(diff_in_secs)) > 1800, 1, 0)) %>% 
  mutate(month = month(date),
         hour = hour(planed_time),
         continent = as.character(continent)) %>%
  mutate(month = as.factor(month),
         hour = as.factor(hour),
         continent = as.factor(continent)) %>% 
  select(-date, -effective_time,-planed_time,-airline_code)

# flightdata_landing <- flightdata %>%
#   filter(start_landing == "L")

flightdata_starting <- flightdata %>%
  filter(start_landing == "S")


# data(agaricus.train, package='xgboost')
# data(agaricus.test, package='xgboost')

set.seed(3456)
# split into training and test datasets
trainIndex <- createDataPartition(flightdata_starting$airline_name, p = .8, 
                                  list = FALSE, 
                                  times = 1)


flighttrain <- flightdata_starting[ trainIndex,][c(5:24)]
flighttest  <- flightdata_starting[-trainIndex,][c(5:24)]

predictors = colnames(flighttrain[-ncol(flighttrain)])
#xgboost works only if the labels are numeric. Hence, convert the labels (Species) to numeric.

label = as.numeric(flighttrain[,ncol(flighttrain)])
print(table (label))

#work in progress
 x.train <- model.matrix(delayed~.,data=flighttrain)
 
 
 bst = xgboost(
   data =x.train,
   label = label,
   nrounds=200,
   objective = "binary:logistic")
 
 
# #Alas, xgboost works only if the numeric labels start from 0. Hence, subtract 1 from the label.
# label = as.numeric(flighttrain[,ncol(flighttrain)])-1
# print(table (label))

#########################################################################################################
# Step 1: Run a Cross-Validation to identify the round with the minimum loss or error.
#         Note: xgboost expects the data in the form of a numeric matrix.

# # cv.nround = 200;  # Number of rounds. This can be set to a lower or higher value, if you wish, example: 150 or 250 or 300  
# bst.cv = xgboost(
#   data = as.matrix(flighttrain[,predictors]),
#   label = label,
#   nfold = 3,
#   nrounds=300,
#   prediction=T,
#   objective="binary:logistic")
# # 
# # 
# # #Find where the minimum logloss occurred
# min.loss.idx = which.min(bst.cv$dt[, test.mlogloss.mean])
# # 
# cat ("Minimum logloss occurred in round : ", min.loss.idx, "\n")
# # 
# # # Minimum logloss
# print(bst.cv$dt[min.loss.idx,])


##############################################################################################################################
# Step 2: Train the xgboost model using min.loss.idx found above.
#         Note, we have to stop at the round where we get the minumum error.

set.seed(100)

bst = xgboost(
  data =as.matrix(flighttrain[,predictors]),
  label = label,
  nrounds=200,
  objective = "binary:logistic")

# Make prediction on the testing data.
flighttest$prediction = predict(bst, as.matrix(flighttest[,predictors]))

# binary
flighttest$prediction01 <- as.numeric(flighttest$prediction > 0.5)

mean(flighttest$prediction01 != flighttest$delayed)

#anteil verspätete -> 0.98
delayfreq<-flightdata %>% 
  group_by(delayed) %>% 
  summarize(n=n()) %>% 
  mutate(n=n/sum(n))





