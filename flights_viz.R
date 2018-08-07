library(tidyverse)
library(sf)
library(lwgeom)

flight_sf <- readRDS("~/git/twist_zrh/flight_sf.RDS") %>% select(-distance)

vizdata <- flight_sf %>% filter(date=="01.01.2017")

# flight_sf$zrhcoord <-  st_as_sfc("POINT(47 8)",crs = "+proj=longlat +datum=WGS84")

vizdata$flightline <- sf::st_union(vizdata$geometry, st_as_sfc("POINT(8 47)",crs=st_crs("+proj=longlat +datum=WGS84 +no_defs"))) %>% 
  st_cast("LINESTRING")

ggplot(vizdata)+
  geom_sf(aes(geometry=flightline))+
  geom_sf(data=world1)

flights <-vizdata %>% select(flightline) %>% st_set_geometry("flightline")
st_geometry(vizdata) = "flightline"


#sferic
library(maps)
library(maptools)
library(rgeos)

world1 <- sf::st_as_sf(map('world', plot = FALSE, fill = TRUE))


world2 <- sf::st_transform(
  world1,
  "+proj=laea +y_0=0 +lon_0=8 +lat_0=47 +ellps=WGS84 +no_defs"
)

flights2 <- sf::st_transform(
 vizdata,
 "+proj=laea +y_0=0 +lon_0=8 +lat_0=47 +ellps=WGS84 +no_defs"
)

library(viridisLite)

ggplot() + 
  geom_sf(data=world2)+
  geom_sf(data=flights2, aes(color=as.numeric(diff)*runif(1)))+
  theme_void()+
  scale_color_viridis_c()


