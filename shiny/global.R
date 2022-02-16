library(shiny)
library(leaflet)
library(leaflet.mapboxgl) #devtools::install_github("rstudio/leaflet.mapboxgl")
library(dplyr)
library(arrow) #install.packages("arrow", repos = "https://packagemanager.rstudio.com/all/__linux__/focal/latest")
library(flexdashboard)
library(shinyjs)

library(waiter)

options(mapbox.accessToken = "pk.eyJ1IjoibWR1YmVsIiwiYSI6ImNrNTgweTlwOTAweDczbXBneTJtNTA2Y2UifQ.kIHidFuI7ooK0KU5yigvqg")
