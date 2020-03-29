library(ggplot2)
library(rgdal)
library(maptools)
library(sp)
library(sf)
library(rgeos)
library(raster)
library(dplyr)

fixcountyname <- function(x) {
  ifelse(x == "New York City", "New York", x)  
}

get_ny_cases <- function() {
  read.csv("data/us-counties.csv", stringsAsFactors = F) %>%
    as_tibble() %>%
    filter(state == "New York") %>%
    mutate(date = ymd(date)) %>%
    mutate(county = fixcountyname(county))
}

get_ny_state_counties <- function() {
  nycounties <- read_sf("data/new-york-counties.json") %>% dplyr::select(geometry, NAME)
  nyc <- c("Richmond", "Kings", "Queens", "Bronx", "New York")
  merged_ny_counties <- st_sf(geometry = st_union(nycounties[nycounties$NAME %in% nyc,]), NAME = "New York")
  rbind(nycounties[!nycounties$NAME %in% nyc,], merged_ny_counties)
}

get_counties_profile <- function(risk_profile) {
  ny_state <- get_ny_state_counties()
  assertthat::assert_that(all(risk_profile$county %in% ny_state$NAME))
  ny_state$risk_profile <- risk_profile[match(ny_state$NAME, risk_profile$county),]$weight
  ny_state$risk_profile <- ifelse(is.na(ny_state$risk_profile), 0, ny_state$risk_profile)
  ny_state
}

risk_profile <- function(cases, selected_date) {
  day <- cases %>% filter(date == selected_date)
  day$weight <- day$cases/sum(day$cases)
  dplyr::select(day, county, weight)
}

only_nyc <- function(x = arrow::read_feather("locationsRank/03-22.feather")) {
  ny_state <- get_ny_state_counties() 
  nyc <- ny_state[ny_state$NAME == "New York",]
  loc <- data.frame(lon=x$lon, lat=x$lat) %>%
    st_as_sf(coords = c("lon", "lat"))
  
  ids_of_counties <- !is.na(as.numeric(st_intersects(loc, nyc)))
  x[ids_of_counties, ]
}

build_ny_counties_risk_profile <- function(date = "2020-03-26") {
  ny_cases <- get_ny_cases()
  rp <- risk_profile(ny_cases, ymd(date))
  ny_counties <- get_counties_profile(rp)
}

risk_for_locations <- function(risk_profile, geohash) {
  loc <- gh_decode(geohash) %>%
   as.data.frame() %>%
   st_as_sf(coords = c("longitude", "latitude"))
  
  ids_of_counties <- as.numeric(st_intersects(loc, risk_profile))
  risk_profile[ids_of_counties, ]$risk_profile
}

visualize_risk_profile <- function(county) {
  pal <- colorNumeric("viridis", NULL)
  leaflet(county) %>%
    addTiles() %>%
    addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                fillColor = ~pal(risk_profile),
                label = ~paste0(NAME, ": ", formatC(risk_profile, big.mark = ","))) %>%
    addLegend(pal = pal, values = ~risk_profile, opacity = 1.0,
              labFormat = labelFormat(transform = function(x) round(10^x)))
}


linechart_cases_by_county <- function(county) {
  last_day <- county[county$date == max(county$date), ] %>%
    filter(cases > 10)
  
  county %>%
    filter(county %in% last_day$county) %>%
    ggplot(aes(x=date, y=cases, color = county)) + 
    geom_line()
}
