library(arrow)
library(purrr)
library(lubridate)
library(dplyr)
library(geohashTools)
library(leaflet)
library(sp)
#remotes::install_github("rstudio/leaflet.mapboxgl")
library(leaflet.mapboxgl)

read_full_data <- function(dataDir = "veraset-03-22") {
  dataPaths <- purrr::keep(dir(dataDir), ~ grepl(".*snappy.parquet$", .))
  data_raw <- map(dataPaths, ~ read_parquet(paste0(dataDir, "/", .), as_tibble = TRUE))
  bind_rows(data_raw)
}

decode_geohash <- function(frame) {
  decoded <- gh_decode(frame$geo_hash)
  frame$lat <- decoded$latitude
  frame$lon <- decoded$longitude
  frame
}

data <- read_full_data("veraset-03-22")

# Look at the unique ids:
ids <- unique(data$caid)

select_folks <- function(data, id) {
  filter(data, caid %in% c(id))
}

small_folks_data <- select_folks(data, ids[1:100]) %>%
  decode_geohash()

quick_markers <- function(data) {
  leaflet(data) %>% addMarkers(lng = ~lon, lat = ~lat) %>% addTiles()

single_person <- function(data, id) {
  data %>% dplyr::filter(caid == id)
}

quick_markers(small_folks_data[1:1000,])

decode_geohash(single_data)

single_locations <- data$geo_hash %>% unique() %>% gh_decode() %>% as.data.frame()
write.csv2(single_locations, "loc.csv")

# as.Date(as.POSIXct(value, origin="1970-01-01"))
# dates <- map(data, ~ unique(date(as.Date(as.POSIXct(as.numeric(.$utc_timestamp), origin="1970-01-01")))))

data_decoded <- function(dataset) {
  geo_decode <- geohashTools::gh_decode(dataset$geo_hash)
  dataset$latitude <- geo_decode$latitude
  dataset$longitude <- geo_decode$longitude
  dataset$utc_timestamp <- as.POSIXct(as.numeric(dataset$utc_timestamp), origin="1970-01-01")
  coordinates(dataset) <- ~longitude+latitude
  dataset$geo_hash <- NULL
  dataset
}

single_data <- single_person(data, uid[500]) %>% data_decoded()
#data_decoded <- data %>% data_decoded()

options(mapbox.accessToken = "pk.eyJ1IjoibWR1YmVsIiwiYSI6ImNrNTgweTlwOTAweDczbXBneTJtNTA2Y2UifQ.kIHidFuI7ooK0KU5yigvqg")

leaflet(single_data) %>% addMapboxGL(style = "mapbox://styles/mdubel/ck8bl3juq0zvd1iq3h9f1xo70") %>% addMarkers() %>% addTiles()
