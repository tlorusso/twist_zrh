---
output: html_document
runtime: shiny
---

rm(list = ls())
library(shiny)
library(tidyverse)
library(lubridate)

flights <- read_csv("twist_zrh.csv")
flights <- flights %>%
  na.omit() %>% 
  mutate(date = as.Date(date, "%d.%m.%Y"),
         delayed = ifelse(abs(as.numeric(diff_in_secs)) > 1800, 1, 0),
         start_landing = ifelse(start_landing == "S", "Starting", "Landing"),
         diff_in_minutes = diff_in_secs/60) %>% 
  mutate(hour = hour(planed_time),
         month = month(date)) %>% 
  mutate_at(vars(airline_code, airline_name, flightnr, start_landing,airplane_type,
                 origin_destination_code, origin_destination_name, airport_type, delayed,
                 iso_country, iso_region, municipality, continent, schengen, hour, month),
            as.factor) %>% 
  select(-tde200h0, -X1, -geometry)


ui <- fluidPage(
  titlePanel("Visualization of airtraffic dataset"),
  
  sidebarLayout(
    sidebarPanel(
           sliderInput(
             inputId = "absolute_diff",
             label = "Only look at differences between expected and actual arrival / departure measured in minutes which is smaller than..",
             min = 0,
             max = 1000,
             value = 40),
   
           selectInput(
             inputId = "variable",
             label = "Variable",
             choices = c("Flight distance (km)" = "distance_km", 
                         "Wind direction, hourly average" = "winddir_h",
                         "Windspeed (km/h), hourly average" = "windspeed_avg_h",
                         "Windspeed (km/h), hourly peak" = "windspeed_peak_h", 
                         "Global radiation (W/m2), hourly average" = "global_rad_avg_h",
                         "Airpressure (hPa)" = "airpres", 
                         "Precipitation (mm)" = "precip", 
                         "Sunshine duration per hour (min)" = "sunshine_dur_min", 
                         "Temperature, hourly average (°C)" = "temp_avg", 
                         "Temperature, hourly maximum (°C)" = "temp_max",
                         "Temperature, hourly minimum (°C)" = "temp_min",
                         "Number of lightnings in airport-proximity (<3km) per hour" = "lightnings_hour_n", 
                         "Number of lightnings in airport-proximity (3-30km) per hour" =  "lightnings_hour_f", 
                         "Relative humidity, hourly average (%)" = "rel_humid", 
                         "Hour of the day" = "hour", 
                         "Month of the year" = "month",
                         "Continent" = "continent", 
                         "Schengen / Non-Schengen" = "schengen",
                         "Airport type" = "airport_type",
                         "Airline name" = "airline_name", 
                         "Airplane type" = "airplane_type",
                         "Origin / Destination name" = "origin_destination_name"),
             selected = c("Hour of the day" = "hour")
           ),
           width = 3
    ),
  
  mainPanel(
      plotOutput("Plot", width = "100%", height = 600)
    )
  )
)


server <- function(input, output){

  output$Plot <- renderPlot({
    
    # quantitative variables 
    if (any(input$variable == 
            c("distance_km", "winddir_h", "windspeed_avg_h",
              "windspeed_peak_h", "global_rad_avg_h", "temp_min",
              "airpres", "precip", "sunshine_dur_min", "temp_avg", "temp_max",
              "lightnings_hour_n", "lightnings_hour_f", "rel_humid")) == TRUE){
      flights %>% 
        filter(abs(diff_in_minutes) < input$absolute_diff) %>% 
        ggplot(aes_string(x = input$variable, y = "diff_in_minutes")) +
        geom_jitter(alpha = 0.5) +
        geom_smooth(method = "gam", se = FALSE, aes(col = "gam")) + 
        labs(y = "Difference in minutes") +
        facet_wrap(~ start_landing)  +
        theme(legend.position="bottom") +
        guides(color = guide_legend(""))
    }
    
    # qualitative variables
    else{
      
      # many categories
      if (any(input$variable == 
              c("airline_name", "airplane_type", "origin_destination_name")) == TRUE){
        flights %>% 
          arrange_(input$variable) %>%
          filter(abs(diff_in_minutes) < input$absolute_diff) %>% 
          group_by_(input$variable) %>% 
          filter(n() > 1000) %>% 
          ggplot(aes_string(x = input$variable, y = "diff_in_minutes", group = input$variable)) +
          geom_boxplot(alpha = 0.5) +
          labs(y = "Difference in minutes", subtitle = "Only looking at > 1000 flights per year") +
          facet_wrap(~ start_landing) + 
          coord_flip()
      }
      # not many categories
      else{
        flights %>% 
          filter(abs(diff_in_minutes) < input$absolute_diff) %>% 
          ggplot(aes_string(x = input$variable, y = "diff_in_minutes")) +
          geom_boxplot(alpha = 0.5) +
          labs(y = "Difference in minutes") +
          facet_wrap(~ start_landing)
      }
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
