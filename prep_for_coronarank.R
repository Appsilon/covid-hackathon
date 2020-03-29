library(assertthat)

parse_raw_data <- function(data) {
  data %>%
    mutate(geohash = geo_hash, id = caid) %>%
    mutate(timestamp = date(as.Date(as.POSIXct(as.numeric(utc_timestamp), origin="1970-01-01")))) %>%
    dplyr::select(-geo_hash, -caid, -utc_timestamp)
}

slice_geohash <- function(geohash, meters) {
  decode <- gh_decode(geohash)
  encode <- gh_encode(decode$latitude, decode$longitude, precision = 6)
  encode
}

prepare_data <- function(frame) {
  assert_that(all(c("geohash", "timestamp", "id") %in% names(frame)))
  
  frame %>%
    mutate(clean_geohash = slice_geohash(geohash, 1000)) %>%
    mutate(time_window = date(timestamp)) %>%
    mutate(geohash = clean_geohash,
           time = time_window) %>%
    dplyr::select(id, time, geohash)
}

estimate_graph_nodes <- function(data) {
  assert_that(all(c("geohash", "timestamp", "id") %in% names(data)))
  length(c(unique(data$geohash), unique(data$id)))
}

bidirect_edges <- function(frame) {
  rbind(frame, setNames(cbind(frame[2], frame[1]), names(frame))) %>% as.matrix
}
