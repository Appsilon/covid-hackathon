library(arrow)
library(purrr)
library(lubridate)
library(geohashTools)
library(leaflet)
library(sp)
library(igraph)
# remotes::install_github("rstudio/leaflet.mapboxgl")
library(leaflet.mapboxgl)

options(mapbox.accessToken = "pk.eyJ1IjoibWR1YmVsIiwiYSI6ImNrNTgweTlwOTAweDczbXBneTJtNTA2Y2UifQ.kIHidFuI7ooK0KU5yigvqg")

source("read_data.R")
source("prep_for_coronarank.R")
source("weights_init.R")
library(dplyr)

pagerank_for_dataset <- function(mmdd = "12-01") {
  data <- read_full_data(paste0("veraset-", mmdd)) %>%
    parse_raw_data()
  print("calculating edges...")
  edges <- data %>%
    dplyr::select(geohash, id) %>%
    distinct() 
  print("calculating weights...")
  risk_profile <- build_ny_counties_risk_profile()
  weights_edges <- risk_for_locations(risk_profile, edges$geohash)
  # TODO: markers at the edges get NA - I'm removing them from data
  skip <- is.na(weights_edges)
  
  # TODO: check use of bidirect_edges()
  graph <- graph_from_edgelist(as.matrix(edges[!skip, ]), directed = FALSE)
  
  print("calculating coronarank...")
  pr <- page_rank(graph, algo = "prpack", directed = FALSE, 
                  damping = 0.99, weights = weights_edges[!skip])

  pagerank.out <- tibble(
    node = names(pr$vector),
    score = pr$vector
  ) %>%
    mutate(coeff = score*100000)
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
# uid <- "52cdc97c2ed5b8915426a1aad3d184b27b0639ac4da564c4ebb790944916f595"
# uid <- "7bce66e8d1d08582631622d4a15b4ac1f0702464f241a90c2850bbc6a65ae0dc"
# single_data <- data[data$id == uid, ]

# %>% data_decoded()
# loc <- gh_decode(single_data$geohash)
# leaflet() %>% 
#   addMapboxGL(style = "mapbox://styles/mdubel/ck8bl3juq0zvd1iq3h9f1xo70") %>% 
#   addMarkers(lng = loc$longitude, lat = loc$latitude)
