
setGeneric ('selectEdgesConnectedBySelectedNodes', 
            signature='obj', function(obj, window.title=NA) standardGeneric ('selectEdgesConnectedBySelectedNodes'))
#' Select the edges connecting selected nodes in Cytoscape Network 
#'
#' Selects edges in a Cytoscape Network connecting the selected nodes 
#'
#' @param object Cytoscape network 
#' @param new_title New name for the copy
#' @param copy.graph.to.R Logical whether to copy the graph to a new object in R 
#' 
#' @return Connection to new copy of network. 
#'
#' @examples \dontrun{
#' cw <- CytoscapeWindow('vignette select edges', graph = RCy3::makeSimpleGraph(), overwrite = TRUE)
#' displayGraph(cw)
#' selectNodes(cw,"A") # selects specific nodes
#' getSelectedNodes(cw)
#' getSelectedEdges(cw)
#' selectFirstNeighborsOfSelectedNodes(cw)
#' ## This has only selected the nodes, but not the edges in Cytoscape, so we will need to select all of the edges before we make the new subnetwork.
#' selectEdgesConnectedBySelectedNodes(cw)
#' getSelectedNodes(cw)
#' getSelectedEdges(cw)
#' }
#'
#' @author Julia Gustavsen, \email{j.gustavsen@@gmail.com}
#' @seealso \code{\link{createWindowFromSelection}}, \code{\link{selectEdgesConnectedBySelectedNodes}}, \code{\link{renameCytoscapeNetwork}}
#' 
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric
selectEdgesConnectedBySelectedNodes <- function(cw) {
  selectedNodes = getSelectedNodes(cw)
  if (length (selectedNodes) == 1 && is.na (selectedNodes))
    return ()
  graphEdges <- getAllEdges(cw)  
  selectedEdges <- unlist(mapply(function(x) return(graphEdges [grep(x, graphEdges)]), selectedNodes)) 
  if (length (selectedEdges) > 0)
    selectEdges(cw, selectedEdges)
}
# END selectEdgesConnectedBySelectedNodes	



setGeneric ('subnetwork_from_selected', 
            signature='obj', function(obj,
                                      copy.graph.to.R = TRUE) standardGeneric ('subnetwork_from_selected'))

#' Create a subnetwork from selected nodes in Cytoscape Network 
#'
#' Creates a new network from selected nodes of a Cytoscape Network. New network includes all edges connecting the selected nodes. 
#'
#' @param object Cytoscape network 
#' @param copy.graph.to.R Logical whether to copy the graph to a new object in R 
#' 
#' @return Connection to new subnetwork. 
#'
#' @examples \dontrun{
#' cw <- CytoscapeWindow('vignette subnetwork', graph = RCy3::makeSimpleGraph(), overwrite = TRUE)
#' displayGraph(cw)
#' selectNodes(cw,c("A","B")) # selects specific nodes
#' getSelectedNodes(cw)
#' getSelectedEdges(cw)
#' newnet <- subnetwork_from_selected(cw)
#' }
#'
#' @author Julia Gustavsen, \email{j.gustavsen@@gmail.com}
#' @seealso \code{\link{createWindowFromSelection}}, \code{\link{selectEdgesConnectedBySelectedNodes}}, \code{\link{renameCytoscapeNetwork}}
#' 
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric
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
# END subnetwork_from_selected