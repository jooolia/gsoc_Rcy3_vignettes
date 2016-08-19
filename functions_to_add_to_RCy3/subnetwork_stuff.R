

selectEdgesConnectedBySelectedNodes <- function(c_w) {
  selectedNodes = getSelectedNodes(c_w)
  if (length (selectedNodes) == 1 && is.na (selectedNodes))
    return ()
  graphEdges <- getAllEdges(c_w)  
  selectedEdges <- unlist(mapply(function(x) return(graphEdges [grep(x, graphEdges)]), selectedNodes)) 
  if (length (selectedEdges) > 0)
    selectEdges(c_w, selectedEdges)
}
# END selectEdgesConnectedBySelectedNodes	


## function to create a subnetwork from selected nodes
subnetwork_from_selected <- function(obj,
                                     copy.graph.to.R = TRUE) {
  ## get selected nodes
  resource.uri <- paste(obj@uri,
                        pluginVersion(obj),
                        "networks",
                        obj@window.id,
                        "nodes?column=selected&query=true",
                        sep = "/")
  request.res <- GET(url = resource.uri)
  
  selected.node.SUIDs <- fromJSON(rawToChar(request.res$content))
  
  selected_node_SUIDs.json <- toJSON(selected.node.SUIDs)
  
  ## create new network from the selected nodes
  resource.uri <- paste(obj@uri,
                        pluginVersion(obj),
                        "networks",
                        obj@window.id,
                        sep = "/")
  request.res <- POST(resource.uri,
                      body = selected_node_SUIDs.json,
                      encode = "json")
  
  ## connect to this new network
  resource.uri <- paste(cy@uri,
                        pluginVersion(cy),
                        "networks",
                        sep = "/")
  request.res <- GET(resource.uri)
  # SUIDs list of the existing Cytoscape networks	
  cy.networks.SUIDs <- fromJSON(rawToChar(request.res$content))
  # most recently made will have the highest SUID
  cy.networks.SUIDs.last <- max(cy.networks.SUIDs)
  
  res.uri.last <- paste(cy@uri,
                        pluginVersion(cy),
                        "networks",
                        as.character(cy.networks.SUIDs.last),
                        sep = "/")
  result <- GET(res.uri.last)
  net.name <- fromJSON(rawToChar(result$content))$data$name
  
  if (copy.graph.to.R){
    subnetwork_from_selected <- existing.CytoscapeWindow(net.name,
                                                         copy.graph.from.cytoscape.to.R = TRUE)
    
    print(paste("Cytoscape window",
                net.name,
                "successfully connected to R session and graph copied to R."))
  } 
  else {
    subnetwork_from_selected <- existing.CytoscapeWindow(net.name,
                                                         copy.graph.from.cytoscape.to.R = FALSE) 
    print(paste0("Cytoscape window ",
                 net.name,
                 " successfully connected to R session."))
  }
  
  invisible(request.res)
  return(subnetwork_from_selected)    
  
}