library(shiny)
library(leaflet)
library(leaflet.mapboxgl)
library(dplyr)
library(arrow)
library(flexdashboard)
library(shinyjs)

# library(shinyWidgets)# new feature loaders not using
# library(shinycssloaders)# new feature loaders

library(waiter) # package to show loader when loading map


options(mapbox.accessToken = "pk.eyJ1IjoibWR1YmVsIiwiYSI6ImNrNTgweTlwOTAweDczbXBneTJtNTA2Y2UifQ.kIHidFuI7ooK0KU5yigvqg")
