library(jsonlite)

gdata <- read_json("private/history.json")

picked <- map(gdata$locations, ~
  list(lat = .$latitudeE7, lon = .$longitudeE7, timestamp = .$timestampMs))
frame_raw <- bind_rows(picked)
frame <- frame_raw %>%
  mutate(lat = lat / 10000000, lon = lon / 10000000)
rm(frame_raw, picked, gdata)

frame$date <- as.Date(as.POSIXct(as.numeric(frame$timestamp)/1000, origin = "1970-01-01"))
one_day <- filter(frame, date == "2012-11-29")
leaflet(one_day) %>%
  addTiles() %>%
  addMarkers(~ lon, ~lat)

library(geosphere)
points <- as.matrix(cbind(one_day$lon, one_day$lat))
distance <- distm(points, fun = distHaversine)

hashes <- gh_encode(frame$lat, frame$lon, precision = 10)
uhash <- unique(hashes)
uhash[1:100]
