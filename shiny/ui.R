ui <- fluidPage(title = "Community Shield",
  tags$head(
    tags$link(rel = "manifest", href = "manifest.json"),
    tags$link(rel="icon", type="image/png", href="32.png"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")
  ),
  useShinyjs(),
  useWaiter(),
  dateInput("date", label = NULL, value = "2020-03-22",
            min = "2020-03-01", max = "2020-03-31", datesdisabled = paste0("2020-03-", c(1:9, 11:15, 17:21, 23:31))),
  gaugeOutput("gauge"),
  leafletOutput("risk_map", width = '100%', height = '100vh'),
  actionButton("showPopup", "Check your risk")
)