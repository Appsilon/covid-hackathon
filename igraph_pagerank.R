
graph <- graph_from_edgelist(el, directed = TRUE)

page_rank(graph, algo = c("prpack", "arpack", "power"),
          vids = V(graph), directed = TRUE, damping = 0.85,
          personalized = NULL, weights = NULL, options = NULL)