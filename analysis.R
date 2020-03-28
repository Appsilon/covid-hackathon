library(arrow)
library(purrr)
library(lubridate)
library(dplyr)
library(geohashTools)
library(leaflet)
library(sp)
#remotes::install_github("rstudio/leaflet.mapboxgl")
library(leaflet.mapboxgl)

read_full_data <- function() {
  dataDir <- "veraset"
  dataPaths <- purrr::keep(dir(dataDir), ~ grepl(".*snappy.parquet$", .))
  data_raw <- map(dataPaths, ~ read_parquet(paste0("veraset/", .), as_tibble = TRUE))
  bind_rows(data_raw)
}

data <- read_full_data()

# Look at the unique ids:
uid <- unique(data$caid)
# rm(uid)

as.Date(as.POSIXct(value, origin="1970-01-01"))
dates <- map(data, ~ unique(date(as.Date(as.POSIXct(as.numeric(.$utc_timestamp), origin="1970-01-01")))))

single_person <- function(data, id) {
  data %>% dplyr::filter(caid == id)
}

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
