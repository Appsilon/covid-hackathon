server <- function(input, output, session) {
  pageranks <- list()
  feather_files <- list.files("./data", pattern = "*.feather")
  for(file in feather_files) {
    name <- gsub(".feather", "", file)
    pageranks[[name]] <- arrow::read_feather(glue::glue("./data/{file}"))
  }

  data_selected <- reactive({
    feather_date <- substr(input$date, 6, 10)
    pageranks[[feather_date]]
  })
  
  output$risk_map <- renderLeaflet({
    # "viridis", "magma", "inferno", or "plasma".
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addEasyButton(easyButton(icon="fa-globe", title="Check your risk!",
        onClick=JS("function(btn, map){ map.setZoom(3); }"))) %>%
      setView(lng = -73.8, lat = 40.7, zoom = 12)
  }) 
  
  observe({
    lngShift <- .0
    latShift <- .0
    palett <- colorNumeric("viridis", domain = NULL)
    leafletProxy("risk_map", data = data_selected()) %>% 
      clearShapes() %>%
      addCircles(
        lng = ~ lon + lngShift,
        lat = ~ lat + latShift,
        radius = 300,
        fillColor = ~palett(-log(score)),
        fillOpacity = 0.75,
        color = "transparent"
      )
  })
}