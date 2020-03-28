library(arrow)
library(purrr)
library(lubridate)
library(dplyr)
library(geohashTools)
library(leaflet)

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
}
quick_markers(small_folks_data[1:1000,])

decode_geohash(single_data)

single_locations <- data$geo_hash %>% unique() %>% gh_decode() %>% as.data.frame()
write.csv2(single_locations, "loc.csv")

# as.Date(as.POSIXct(value, origin="1970-01-01"))
# dates <- map(data, ~ unique(date(as.Date(as.POSIXct(as.numeric(.$utc_timestamp), origin="1970-01-01")))))
