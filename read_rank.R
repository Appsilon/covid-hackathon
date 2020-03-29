# pagerank.out <- read.table("../pagerank/cpp/out2.txt", sep = "=", stringsAsFactors = F) %>% as_tibble
# names(pagerank.out) <- c("node", "score")
source("analysis.R")

get_risky_by_predicate <- function(pagerank, predicate, n = 2000) {
  pagerank.locations <- pagerank %>%
    filter(predicate(node)) %>%
    arrange(-coeff)
  
  if (n>0) {
    pagerank.locations[1:n,]
  } else {
    pagerank.locations
  }
}

get_risky_locations <- function(pagerank, ...) {
  risky_spots <- get_risky_by_predicate(pagerank, function(node) nchar(node) < 60, ...)
  risky_locations <- gh_decode(trimws(risky_spots$node))
  risky_spots %>%
    dplyr::select(-node) %>%
    mutate(lat = risky_locations$latitude,
           lon = risky_locations$longitude)
}

get_risky_folks <- function(pagerank, ...) {
  get_risky_by_predicate(pagerank, function(node) nchar(node) > 60, ...)
}

plot_risky_locations <- function(risky_locations) {
  lngShift <- .0
  latShift <- .0
  # "viridis", "magma", "inferno", or "plasma".
  pallet <- colorNumeric("viridis", domain = NULL)
  leaflet(risky_locations) %>% 
    addProviderTiles(providers$CartoDB.Positron) %>%
    addCircles(
      lng = ~ lon + lngShift, lat = ~ lat + latShift,
      radius = 300,
      # lng2 = ~ lon - lngShift, lat2 = ~ lat - latShift,
      fillColor = ~pallet(coeff),
      fillOpacity = 0.75,
      color = "transparent"
    ) %>%
    addLegend(pal = pallet, 
              values = ~coeff,
              title = "CoronaRank",
              opacity = 1
    ) %>%
    setView(median(risky_locations$lon), median(risky_locations$lat), zoom = 8)
}

dates_of_interest <- c("03-01", "03-05", "03-10", "03-16", "03-22")
mmdd <- dates_of_interest[3]
coronaRank <- pagerank_for_dataset(mmdd)
locationRank <- get_risky_locations(coronaRank, n = -1) %>% # Get all
  dplyr::select(-coeff)

folksRank <- get_risky_folks(coronaRank, n = -1)

write_feather(locationRank, glue("locationsRank/{mmdd}.feather"))

# datasets <- list("12-01" = read_full_data("veraset-12-01"))
# pageranks <- list( "12-01" = pagerank_for_dataset("12-01") )
# risky_loc <- list( "12-01" = get_risky_locations(pagerank.out))
# risky_folks <- list( "12-01" = get_risky_folks(pagerank.out))
# plot_risky_locations(risky_loc$`12-01`)

# <- dates_of_interest %>%
#   map(pagerank_for_dataset) %>%
#   map(get_risky_locations)

  # plot_risky_locations()

# hist(pagerank.locations$coeff, breaks= 200)
# head(pagerank.locations)
