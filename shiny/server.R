library(arrow)

server <- function(input, output, session) {
  pageranks <- list()
  feather_files <- list.files("./data", pattern = "*.feather")
  for(file in feather_files) {
    name <- gsub(".feather", "", file)
    pageranks[[name]] <- arrow::read_feather(glue::glue("./data/{file}")) %>%
      only_nyc() %>% 
      mutate(score_norm = (score - min(.$score)) / (max(.$score) - min(.$score)))
  }

  data_selected <- reactive({
    feather_date <- substr(input$date, 6, 10)
    pageranks[[feather_date]]
  })
  
  output$risk_map <- renderLeaflet({
    # "viridis", "magma", "inferno", or "plasma".
    leaflet() %>%
      addMapboxGL(style = "mapbox://styles/mdubel/ck8de7zi32rax1iql63j5b70g") %>%
      addEasyButton(easyButton(icon="fa-globe", title="Check your risk!",
        onClick=JS("function(btn, map){ map.setZoom(3); }"))) %>%
      setView(lng = -73.8, lat = 40.7, zoom = 11)
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
        radius = 500,
        fillColor = "#365c86",#~palett(-log(score)),
        fillOpacity = ~ score_norm,
        color = "transparent"
      )
  })
  
  modalContent <- tagList(
    p("Choose one of the following three movement patterns that best describes your activity outside of your house over the last two weeks. We will tell you how likely it is that you might have caught the virus and became contagious – your CoronaRank."),
    a(href = "https://takeout.google.com/settings/takeout", img(src="google.png", style = "border: 1px solid gray")),
    a(href = "https://privacy.apple.com/", img(src="apple.png", style = "border: 1px solid gray")),
    div(style = "padding:0 2em",
      navlistPanel(id = "selectedProfile",
        tabPanel(value = "low", "Low – time outside limited to basic necessities"), 
        tabPanel(value = "medium", "Medium – moderate daily activities, no social interactions in public spaces"),
        tabPanel(value = "high", "High – you got out of the house a lot, used public transport, visited cafes, restaurants, etc.")
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
  
  riskProfiles <- list(
    # low = arrow::read_feather(glue::glue("./data/low.feather")),
    # medium = arrow::read_feather(glue::glue("./data/medium.feather")),
    # high = arrow::read_feather(glue::glue("./data/high.feather"))
  )
  
  observeEvent(input$startUpload, {
    removeModal()
    profile <- riskProfiles[[input$selectedProfile]]
    leafletProxy("risk_map", data = profile) %>% 
      addMarkers(
        lng = ~lon,
        lat = ~lat
      )
  })
}