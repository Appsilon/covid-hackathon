ui <- fluidPage(title = "Community Shield",
  tags$head(
    tags$link(rel = "manifest", href = "manifest.json"),
    tags$link(rel="icon", type="image/png", href="32.png"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")
  ),
  dateInput("date", label = NULL, value = "2020-03-22"),
  gaugeOutput("gauge"),
  leafletOutput("risk_map", width = '100%', height = '100vh'),
  actionButton("showPopup", "Check your risk")
)