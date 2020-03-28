library(arrow)
library(purrr)
library(lubridate)

dataDir <- "veraset"
dataPaths <- purrr::keep(dir(dataDir), ~ grepl(".*snappy.parquet$", .))
data <- map(dataPaths, ~ read_parquet(paste0("veraset/", .), as_tibble = TRUE))

uid <- map(data, ~ unique(.$caid)) %>% unlist %>% unique
rm(uid)

as.Date(as.POSIXct(value, origin="1970-01-01"))
dates <- map(data, ~ unique(date(as.Date(as.POSIXct(as.numeric(.$utc_timestamp), origin="1970-01-01"))))) %>%
  unlist %>%
  unique
