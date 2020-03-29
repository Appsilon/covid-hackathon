library(arrow)

server <- function(input, output, session) {
  pageranks <- list()
  feather_files <- list.files("./data", pattern = ".*-.*.feather")
  hard_min <- 8.989015e-08
  hard_max <- 0.01252892
  for(file in feather_files) {
    name <- gsub(".feather", "", file)
    pageranks[[name]] <- arrow::read_feather(glue::glue("./data/{file}")) %>%
      mutate(score_norm = (score - hard_min) / (hard_max - hard_min))
  }
  data_selected <- reactive({
    feather_date <- substr(input$date, 6, 10)
    pageranks[[feather_date]]
  })
  
  baseMap <- function() {
    leaflet() %>%
      addMapboxGL(style = "mapbox://styles/mdubel/ck8de7zi32rax1iql63j5b70g") %>%
      addEasyButton(easyButton(icon="fa-globe", title="Check your risk!",
                               onClick=JS("function(btn, map){ map.setZoom(3); }"))) %>%
      setView(lng = -73.8, lat = 40.7, zoom = 11)
  }
  
  output$risk_map <- renderLeaflet({
    baseMap()
  }) 
  
  mapCoronaRank <- function(map, data) {
    palett <- colorNumeric("plasma", domain = c(-17, -4))
    # "viridis", "magma", "inferno", or "plasma".
    latDist <- 0.005493164
    lonDist <- 0.01098633
    map %>%
      addRectangles(
        data = data,
        lng1 = ~ lon - lonDist/2,
        lng2 = ~ lon + lonDist/2,
        lat1 = ~ lat - latDist/2,
        lat2 = ~ lat + latDist/2,
        fillColor = 'rgb(54, 92, 134)', #~palett(log(score)), 
        fillOpacity = ~ (score_norm*8 ),#0.6,
        color = "transparent"
      )
  }
  
  baseMap() %>% mapCoronaRank(pageranks$`03-22`)
  
  observe({
    leafletProxy("risk_map") %>% 
      clearShapes() %>%
      mapCoronaRank(data = data_selected())
  })
  
  modalContent <- tagList(
    p("Choose one of the following three movement patterns that best describes your activity outside of your house over the last two weeks. We will tell you how likely it is that you might have caught the virus and became contagious – your CoronaRank."),
    a(href = "https://takeout.google.com/settings/takeout", img(src="google.png", style = "border: 1px solid gray")),
    a(href = "https://privacy.apple.com/", img(src="apple.png", style = "border: 1px solid gray")),
    div(style = "padding:0 2em",
      navlistPanel(id = "selectedProfile", widths = c(12, 12),
        tabPanel(title = "Low", value = "low", "Time outside limited to basic necessities"), 
        tabPanel(title = "Medium", value = "medium", "Moderate daily activities, no social interactions in public spaces"),
        tabPanel(title = "High", value = "high", "You got out of the house a lot, used public transport, visited cafes, restaurants, etc.")
      )
    )
  )
  
  observeEvent(input$showPopup, {
    showModal(modalDialog(
      title = "Check your CoronaRank",
      modalContent,
      footer = tagList(
        modalButton("Maybe later"),
        actionButton("startUpload", "Check me"),
        br(),
        p(style = "text-align: left; font-size: 0.8em;", "Your data including the CoronaRank is private and will not be shared with anyone.")
      )
    ))
  })
  
  output$gauge = renderGauge({
    gauge(risk_score(), 
          min = 0, 
          max = 1, 
          sectors = gaugeSectors(success = c(0.0, 0.2), 
                                 warning = c(0.21, 0.7),
                                 danger = c(0.71, 0.9),
                                 colors = c('rgba(54, 92, 134, 0.1)', 'rgba(54, 92, 134, 0.5)', 'rgba(54, 92, 134, 1)')))
  })
  
  riskProfiles <- list(
    low = arrow::read_feather(glue::glue("./data/low.feather")),
    medium = arrow::read_feather(glue::glue("./data/medium.feather")),
    high = arrow::read_feather(glue::glue("./data/high.feather"))
  )
  
  risk_score <- reactive({
    if(input$selectedProfile == "low")
      0.1
    else if(input$selectedProfile == "medium")
      0.4
    else if(input$selectedProfile == "high")
      0.9
  })
  
  observeEvent(input$startUpload, {
    removeModal()
    shinyjs::runjs("$('#gauge').addClass('show-gauge');")
    profile <- riskProfiles[[input$selectedProfile]]
    leafletProxy("risk_map", data = profile) %>% 
      addMarkers(
        lng = ~lon,
        lat = ~lat
      )
  })
}
