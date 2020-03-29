library(arrow)

server <- function(input, output, session) {
  pageranks <- list()
  feather_files <- list.files("./data", pattern = "*.feather")
  hard_min <- 8.989015e-08
  hard_max <- 0.01252892
  for(file in feather_files) {
    name <- gsub(".feather", "", file)
    pageranks[[name]] <- arrow::read_feather(glue::glue("./data/{file}")) %>%
      only_nyc() %>% 
      mutate(score_norm = (score - hard_min) / (hard_max - hard_min))
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
    p("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin nibh augue, suscipit a, scelerisque sed, lacinia in, mi. interdum, dui ligula ultricies purus, sed posuere libero dui id orci."),
    p("Something about Google takeout?"),
    div(style = "padding:0 2em",
      navlistPanel(
        tabPanel("Low Risk", "explanation"), 
        tabPanel("Medium Risk", "etc etc ontents"),
        tabPanel("High Risk", "other contents")
      )
    )
  )
  
  observeEvent(input$showPopup, {
    showModal(modalDialog(
      title = "Important message",
      modalContent,
      footer = tagList(
        modalButton("Maybe later"),
        actionButton("startUpload", "Check my data")
      )
    ))
  })
  
  observeEvent(input$startUpload, {
    print("starting upload")
  })
}