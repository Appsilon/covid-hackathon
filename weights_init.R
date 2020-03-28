library(ggplot2)
library(rgdal)
library(maptools)

fixcountyname <- function(x) {
  ifelse(x == "New York City", "New York", x)  
}

county <- read.csv("data/us-counties.csv", stringsAsFactors = F) %>%
  as_tibble() %>%
  filter(state == "New York") %>%
  mutate(date = ymd(date)) %>%
  mutate(county = fixcountyname(county))

risk_profile <- function(selected_date) {
  day <- county %>% filter(date == selected_date)
  day$weight <- day$cases/sum(day$cases)
  select(day, county, weight)
}

rp <- risk_profile(ymd("2020-03-26"))

nycounties <- readOGR("data/new-york-counties.json", stringsAsFactors = FALSE)
nyc <- c("Richmond", "Kings", "Queens", "Bronx", "New York")
nyccounties <- nycounties[nycounties$NAME %in% nyc,]
othercounties <- nycounties[!nycounties$NAME %in% nyc,]
# Strange hack:
if (!require(gpclib)) install.packages("gpclib", type="source")
gpclibPermit()
nycCountySP <- unionSpatialPolygons(nyccounties, rep(1, length(nyccounties)))
nycData <- nyccounties@data[nyccounties$NAME=="New York",]
rownames(nycData) <- 1
nycCounty <- SpatialPolygonsDataFrame(nycCountySP, nycData )

allNyc <- rbind(othercounties, nycCounty)

assert_that(all(rp$county %in% allNyc$NAME))
allNyc@data$risk_profile <- rp[match(allNyc@data$NAME, rp$county),]$weight
pal <- colorNumeric("viridis", NULL)
leaflet(allNyc) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
              fillColor = ~pal(risk_profile),
              label = ~paste0(NAME, ": ", formatC(risk_profile, big.mark = ","))) %>%
  addLegend(pal = pal, values = ~risk_profile, opacity = 1.0,
            labFormat = labelFormat(transform = function(x) round(10^x)))



visualize_counties <- function(county) {
  last_day <- county[county$date == max(county$date), ] %>%
    filter(cases > 10)
  
  county %>%
    filter(county %in% last_day$county) %>%
    ggplot(aes(x=date, y=cases, color = county)) + 
    geom_line()
}
