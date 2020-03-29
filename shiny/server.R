server <- function(input, output, session) {
  pageranks <- list( "12-01" = pagerank_for_dataset("12-01") )
  risky_loc <- list( "12-01" = get_risky_locations(pageranks$`12-01`) )
  output$risk_map <- renderLeaflet({
    plot_risky_locations(risky_loc$`12-01`)
  }) 
}