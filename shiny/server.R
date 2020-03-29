server <- function(input, output, session) {
  #pageranks <- list( "12-01" = pagerank_for_dataset("12-01") )
  #risky_loc <- list( "12-01" = get_risky_locations(pageranks$`12-01`) )
  data_selected <- reactive({
    if(input$date == "2020-03-26")
      list(lng = 174.768, lat = -36.852)
    else if(input$date == "2020-03-25")
      list(lng = 173.768, lat = -37.852)
  })
  
  output$risk_map <- renderLeaflet({
    #plot_risky_locations(risky_loc$`12-01`)
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircles(lng = 174.768, lat = -36.852, radius = 3900) %>% 
      addEasyButton(easyButton(icon="fa-globe", title="Check your risk!",
        onClick=JS("function(btn, map){ map.setZoom(1); }"))) %>%
      setView(lng = 174.768, lat = -36.852, zoom = 8)
  }) 
  
  observe({
    leafletProxy("risk_map") %>% 
      clearShapes() %>% 
      addCircles(lng = data_selected()$lng, lat = data_selected()$lat, radius = 3900)
  })
}