library(arrow)
library(purrr)
library(lubridate)
library(dplyr)
library(geohashTools)
library(leaflet)

read_full_data <- function() {
  dataDir <- "veraset"
  dataPaths <- purrr::keep(dir(dataDir), ~ grepl(".*snappy.parquet$", .))
  data_raw <- map(dataPaths, ~ read_parquet(paste0("veraset/", .), as_tibble = TRUE))
  bind_rows(data_raw)
}

decode_geohash <- function(frame) {
  decoded <- gh_decode(frame$geo_hash)
  frame$lat <- decoded$latitude
  frame$lon <- decoded$longitude
  frame
}

data <- read_full_data()

# Look at the unique ids:
uid <- unique(data$caid)
# rm(uid)

as.Date(as.POSIXct(value, origin="1970-01-01"))
dates <- map(data, ~ unique(date(as.Date(as.POSIXct(as.numeric(.$utc_timestamp), origin="1970-01-01")))))

single_person <- function(data, id) {
  filter(data, caid == id)
}

single_data <- single_person(data, uid[1])

decode_geohash(single_data)

single_locations <- data$geo_hash %>% unique() %>% gh_decode() %>% as.data.frame()
write.csv2(single_locations, "loc.csv")
