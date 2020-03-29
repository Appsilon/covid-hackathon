# pagerank.out <- read.table("../pagerank/cpp/out2.txt", sep = "=", stringsAsFactors = F) %>% as_tibble
# names(pagerank.out) <- c("node", "score")

get_risky_by_predicate <- function(pagerank, predicate, n = 2000) {
  pagerank.locations <- pagerank %>%
    filter(predicate(node)) %>%
    arrange(-coeff)
  
  pagerank.locations[1:n,]
}

get_risky_locations <- function(pagerank) {
  risky_spots <- get_risky_by_predicate(pagerank, function(node) nchar(node) < 60)
  risky_locations <- gh_decode(trimws(risky_spots$node))
  risky_spots %>%
    select(-node) %>%
    mutate(lat = risky_locations$latitude,
           lon = risky_locations$longitude)
}

get_risky_folks <- function(pagerank) {
  get_risky_by_predicate(pagerank, function(node) nchar(node) > 60)
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



# dates_of_interest <- c("12-01", "03-01", "03-22")
# datasets <- list("12-01" = read_full_data("veraset-12-01"))
# pageranks <- list( "12-01" = pagerank_for_dataset("12-01") )
# risky_loc <- list( "12-01" = get_risky_locations(pageranks$`12-01`) )
# risky_folks <- list( "12-01" = get_risky_folks(pageranks$`12-01`) )
# plot_risky_locations(risky$`12-01`)

# <- dates_of_interest %>%
#   map(pagerank_for_dataset) %>%
#   map(get_risky_locations)

  # plot_risky_locations()

# hist(pagerank.locations$coeff, breaks= 200)
# head(pagerank.locations)
