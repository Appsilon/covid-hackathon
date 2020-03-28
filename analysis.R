library(arrow)
library(purrr)
library(lubridate)
library(dplyr)
library(geohashTools)
library(leaflet)
library(sp)
# remotes::install_github("rstudio/leaflet.mapboxgl")
library(leaflet.mapboxgl)

options(mapbox.accessToken = "pk.eyJ1IjoibWR1YmVsIiwiYSI6ImNrNTgweTlwOTAweDczbXBneTJtNTA2Y2UifQ.kIHidFuI7ooK0KU5yigvqg")

source("read_data.R")
source("prep_for_coronarank.R")

pagerank_for_dataset <- function(mmdd = "12-01") {
  data <- read_full_data(paste0("veraset-", mmdd))
  edges <- data %>%
    parse_raw_data %>%
    select(geohash, id) %>%
    distinct() %>%
    bidirect_edges()
  graph <- graph_from_edgelist(edges, directed = TRUE)
  pr <- page_rank(graph, algo = "prpack", directed = FALSE, damping = 0.99) # weights = NULL)

  pagerank.out <- tibble(
    node = names(pr$vector),
    score = pr$vector
  ) %>%
    mutate(coeff = pagerank.out$score*100000)
}

select_folks <- function(data, id) {
  filter(data, caid %in% c(id))
}

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

# Person with highest CoronaRank for 1st Dec.
single_data <- single_person(datasets$`12-01`, "53e32cc945f2b12df9a613aa5cd7328c61a6fd3d2465104ed410a07e1d98b789") %>% data_decoded()

leaflet(single_data) %>% 
  addMapboxGL(style = "mapbox://styles/mdubel/ck8bl3juq0zvd1iq3h9f1xo70") %>% 
  addMarkers()
