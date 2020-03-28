pagerank.out <- read.table("../pagerank/cpp/out2.txt", sep = "=", stringsAsFactors = F) %>% as_tibble
names(pagerank.out) <- c("node", "score")

pagerank.full <- pagerank.out %>%
  mutate(coeff = pagerank.out$score*100000)

pagerank.locations <- pagerank.full %>%
  filter(nchar(node) < 60) %>%
  arrange(-coeff)

risky_spots <- pagerank.locations[1:1000,]
risky_locations <- gh_decode(trimws(risky_spots$node))
# quick_markers(data.frame(lat = risky_locations$latitude, lon = risky_locations$longitude))

leaflet(risky_locations) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>%
  # addGraticule(interval = 0.05, group = "Graticule") %>%
  addCircles(lng = ~longitude, lat = ~latitude, weight = 1,
           radius = ~sqrt(risky_spots$coeff)*200,
           color = risky_spots$coeff
  )

# hist(pagerank.locations$coeff, breaks= 200)
# head(pagerank.locations)
