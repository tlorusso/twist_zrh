#Visualization of flihgts from / to ZRH for a single date


if (!require("pacman")) install.packages("pacman")

pacman::p_load(dplyr,sf,lwgeom,ggplot2,maps,maptools,rgeos)

#read in flight data
flight_sf <- readRDS("~/git/twist_zrh/flight_sf.RDS")
#filter flights for a single date
vizdata <- flight_sf %>% filter(date=="01.01.2017")

#create a new geometry : lines connecting Zurich Airport and the destination/origin of the flight
vizdata$flightline <- sf::st_union(vizdata$geometry, st_as_sfc("POINT(8 47)",crs=st_crs("+proj=longlat +datum=WGS84 +no_defs"))) %>% 
  st_cast("LINESTRING")

#get worldmap
world1 <- sf::st_as_sf(maps::map('world', plot = FALSE, fill = TRUE))

#plot on top (new ggplot2 2.3.0 version needed!)
ggplot(vizdata)+
  geom_sf(aes(geometry=flightline))+
  geom_sf(data=world1)

#we can now set the "flightline"-geometry as the main geometry in our dataset
st_geometry(vizdata) = "flightline"

#transform worldmap and flights into spheric projection
world2 <- sf::st_transform(
  world1,
  "+proj=laea +y_0=0 +lon_0=8 +lat_0=47 +ellps=WGS84 +no_defs"
)

flights2 <- sf::st_transform(
 vizdata,
 "+proj=laea +y_0=0 +lon_0=8 +lat_0=47 +ellps=WGS84 +no_defs"
)

#Plot!
ggplot() + 
  geom_sf(data=world2, color="white",size=0.2)+
  geom_sf(data=flights2, aes(color=distance_km, alpha=0.8),size=0.2,show.legend = "line")+
  theme_void()+
 scale_color_viridis_c(name="")+
  guides(alpha=F)+
  coord_sf(ndiscr=1000)+
  theme(plot.background = element_rect(fill="#f5f5f2"))


ggsave("flights.png")

  

  
