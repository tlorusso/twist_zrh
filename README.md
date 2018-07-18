# Flight data for ML-prediction challenge at the TWIST2018-Hackdays

This repository contains data of planed and effective flight arrival and departure-times from / to the airport of Zurich for the entire year 2017. 

The R-Script **data_enrichment.R** contains the code used to add the airport coordinates, calculate approximative flight-distances as well as time-differences between scheduled and effective flight-times.

The RDS-file **flight_sf.RDS** contains the resulting R-dataframe.
