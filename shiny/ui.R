ui <- fluidPage(
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")),
  dateInput("date", label = NULL, value = "2020-03-22"),
  leafletOutput("risk_map", width = '100%', height = '100vh')
)