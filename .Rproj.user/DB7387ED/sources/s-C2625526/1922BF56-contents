#enrichtment of the flight-data for the TWIST-Hackdays

library(tidyverse)

flights <- read.table("flightdata_zrh.csv",sep=";",header=TRUE) %>% 
          mutate(rowid=row_number())

# airport coordinates & timedifferences planed vs effective  ------------------

#airport database : http://ourairports.com/ -> open aiport data http://ourairports.com/data/
airports <- read.csv("airports.csv") %>% 
  #filter small airports : one small airports has the same iatacode as CDG (paris), others were closed and replaced by new airports (e.g. Hongkong) and are redundant
  filter(!type %in% c("small_airport","closed")) %>% 
  #filter airports with missing geocoordinates
  filter(latitude_deg!=0 & longitude_deg!=0) %>% 
  #filter duplicate OR Tambo International Airport
  filter(id!=31055)

flights_airports <- flights %>% 
                   # join airport geocoordinates to flights: airport data for 71 flights not available
                    left_join(airports, by=c("origin_destination"="iata_code")) %>% 
                    #convert effective / planed time to hms format
                    mutate_at(vars(planed_time,effective_time),
                              funs(lubridate::parse_date_time(paste0(date," ",.),
                                                      'dmy HMS'))) %>% 
                    #calculate planed vs effective time difference
                    mutate(diff=effective_time-planed_time) %>% 
                    #coordinates to numeric
                    mutate_at(vars(longitude_deg,latitude_deg),funs(as.numeric(as.character(.)))) %>% 
                    #filter the 71 flights without airport coordinates
                    filter(!is.na(longitude_deg))

# calculate distances -------------

library(sf)
library(lwgeom)

flights_sf <- st_as_sf(flights_airports,  
                        coords = c("longitude_deg","latitude_deg"),
                        crs = "+proj=longlat +datum=WGS84") %>% 
                        #calculate distance to Zurich Airport (lat long )
                        mutate(distance=st_distance(geometry,st_geometry(st_point(c(47.464699, 8.54917))) %>% 
                                                      st_set_crs(st_crs("+proj=longlat +datum=WGS84"))))

saveRDS(flights_sf,"flight_sf.RDS")




