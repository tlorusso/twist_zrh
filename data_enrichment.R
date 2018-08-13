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
                        #calculate distance to Zurich Airport (long, lat )
  mutate(distance_km=as.numeric(st_distance(geometry,st_geometry(st_point(c(8.54917,47.464699))) %>% 
                                                      st_set_crs(st_crs("+proj=longlat +datum=WGS84"))))/1000)
       
# library(geosphere)
# # alternative to st_distance
# distm(c(sf::st_coordinates(flight_sf$geometry[79])), c(8.551364,47.465318), fun = distHaversine) 
                
# saveRDS(flights_sf,"flight_sf.RDS")


# TODO : Join meteoswiss-weatherdata to flights

library(lubridate)

#read in hourly weatherdata
weather <- read.table("weatherstations_hourly.txt",sep=";", header=T)

#convert datetime-string to POSIXct-date format
weather <-weather %>%  mutate(datetime=as.POSIXct(strptime(weather$time, "%Y%m%d%H"))) 

#round planed time to full hours to be able to join hourly weather data to it (filter for station at KLOTEN)
flights_sf <- flights_sf %>% mutate(planed_hour =round_date(planed_time,unit="1 hour")) %>% 
              left_join(weather %>% filter(stn=="KLO"), by=c("planed_hour"="datetime"))


# drop, reorder and rename columns
flights_sf2<-flights_sf %>% 
  select(date, effective_time, planed_time, diff_in_secs=diff,
         airline_code, airline_name, flightnr = Flugnummer, start_landing, airplane_type,
         origin_destination_code=origin_destination, origin_destination_name = name, airport_type=type, 
         distance_km, iso_country,iso_region,municipality,continent= continent.y, schengen= Schengen,
         #weather variables
        lightnings_hour_n=brecloh0, lightnings_hour_f=brefarh0,
        winddir_h=dkl010h0, windspeed_avg_h=fu3010h0,windspeed_peak_h=fu3010h1,
        global_rad_avg_h=gre000h0 ,airpres=pp0qnhh0 ,precip=rre150h0 ,sunshine_dur_min=sre000h0 ,
        tde200h0 ,temp_avg=tre200h0  ,
        temp_min=tre200hn ,temp_max=tre200hx, rel_humid=ure200h0)

#save!

saveRDS(flights_sf2,"twist_zrh.RDS")

write.csv(flights_sf2,"twist_zrh.csv")


# library('corrplot') #package corrplot
# corrplot(, method = "circle") #plot matrix
