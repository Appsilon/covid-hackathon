library(arrow)
library(purrr)
library(lubridate)
library(dplyr)
library(geohashTools)
library(leaflet)
library(glue)

read_full_data <- function(dataDir = "veraset-03-22") {
  print(glue("Reading {dataDir}..."))
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