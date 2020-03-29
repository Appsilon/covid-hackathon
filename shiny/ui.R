ui <- fluidPage(
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")),
  leafletOutput("risk_map", width = '100%', height = '100vh')
)