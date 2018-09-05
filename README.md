### Team Airtraffic is creating insightful visualizations of air traffic from / to Zurich Airport and predicting delays

So far, we have:
- conducted __exploratory data analysis__ and produced many descriptive visualizations to get to know the data and get a first understanding of which aspects of it might be relevant and interesting
- experimented with a broad variety of modelling approaches (linear approaches, binary logistic regressions, ridge regression...) __to predict delays__

__Next steps :__

1. Try further prediction-approaches (baynesian, random forest e.g.) 
2. Create some further insightful visualizations
2. Discuss what the model could be used for (flight delay prediction app? ) 

### Flight data for ML-prediction challenge at the TWIST2018-Hackdays

This repository contains data of planed and effective flight arrival and departure-times from / to the airport of Zurich for the entire year 2017. 

The R-Script **data_enrichment.R** contains the code used to add the airport coordinates, calculate approximative flight-distances, time-differences between scheduled and effective flight-times as well as information on weather-conditions around the airport provided by meteoswiss. The dataset does not yet contain information on general weather and atmospheric conditions other than those at the local scale. 

The RDS-file **twist_zrh.RDS** contains the resulting R-dataframe. For those relying on other tools than r, a csv-version of the dataset is also available: **twist_zrh.csv**

metadata.txt contains a detailed description of the variables contained in the file. 

Further sources for weather data at global scale or atmospheric conditions:

- meteorogical conditions on the ground via NASApower: https://adamhsparks.github.io/nasapower/

- atmospheric conditions via: http://www.wmo.int/pages/prog/www/GOS/ABO/data/ABO_Data_Access.html#gts
