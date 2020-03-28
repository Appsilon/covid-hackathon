library(igraph)

graph <- graph_from_edgelist(edges, directed = TRUE)

pr <- page_rank(graph, algo = "prpack", directed = FALSE, damping = 0.99)
          # weights = NULL)

pagerank.out <- tibble(
  node = names(pr$vector),
  score = pr$vector
)
