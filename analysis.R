library(arrow)
library(purrr)
library(lubridate)
library(dplyr)

read_full_data <- function() {
  dataDir <- "veraset"
  dataPaths <- purrr::keep(dir(dataDir), ~ grepl(".*snappy.parquet$", .))
  data_raw <- map(dataPaths, ~ read_parquet(paste0("veraset/", .), as_tibble = TRUE))
  bind_rows(data_raw)
}

data <- read_full_data()

# Look at the unique ids:
uid <- unique(data$caid)
# rm(uid)

as.Date(as.POSIXct(value, origin="1970-01-01"))
dates <- map(data, ~ unique(date(as.Date(as.POSIXct(as.numeric(.$utc_timestamp), origin="1970-01-01")))))

single_person <- function(data, id) {
  map(data, function(set) {
    set$caid <- set$caid %>% filter(. == id)
    set
  })
}

single_data <- single_person(data[[1]], uid[1])
