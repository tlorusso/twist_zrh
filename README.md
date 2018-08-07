# Flight data for ML-prediction challenge at the TWIST2018-Hackdays

This repository contains data of planed and effective flight arrival and departure-times from / to the airport of Zurich for the entire year 2017. 

The R-Script **data_enrichment.R** contains the code used to add the airport coordinates, calculate approximative flight-distances as well as time-differences between scheduled and effective flight-times.

The RDS-file **flight_sf.RDS** contains the resulting R-dataframe.

## TODO : enrich dataset with weather-condition variables

Define in what form weather-condition variables can be used as predictors and where to find relevant data.

Meteoswiss provides us with the following indicators related to the weatherconditions around the airport of Zurich:

- Windspeeds (hourly max.)
- Precipitation (hourly quantities)
- Number of lightnings strikes in airport-proximity (hourly)

Further sources for weather data at global scale or atmospheric conditions:

- meteorogical conditions on the ground via NASApower: https://adamhsparks.github.io/nasapower/

- atmospheric conditions via: http://www.wmo.int/pages/prog/www/GOS/ABO/data/ABO_Data_Access.html#gts
