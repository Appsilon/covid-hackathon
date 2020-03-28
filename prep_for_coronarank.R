library(assertthat)

parse_raw_data <- function(data) {
  data %>%
    mutate(geohash = geo_hash, id = caid) %>%
    mutate(timestamp = date(as.Date(as.POSIXct(as.numeric(utc_timestamp), origin="1970-01-01"))))
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
    select(id, time, geohash)
}

estimate_graph_nodes <- function(data) {
  assert_that(all(c("geohash", "timestamp", "id") %in% names(data)))
  length(c(unique(data$geohash), unique(data$id)))
}

bidirect_edges <- function(frame) {
  rbind(frame, setNames(cbind(frame[2], frame[1]), names(frame))) %>% as.matrix
}

# estimate_graph_nodes(parse_raw_data(data))
edges <- data %>%
  parse_raw_data %>%
  select(geohash, id) %>%
  distinct() %>%
  bidirect_edges()

write.table(edges, file = "graph0322.txt", quote = F, sep = " ", row.names = F, col.names = F)

small_data <- data[1:100000,]
x <- small_data %>%
  mutate(geohash = geo_hash, id = caid) %>%
  mutate(timestamp = date(as.Date(as.POSIXct(as.numeric(utc_timestamp), origin="1970-01-01")))) %>%
  prepare_data() %>%
  group_by(geohash) %>%
  summarize(unique_folks = length(unique(id)))
table(x$unique_folks)
