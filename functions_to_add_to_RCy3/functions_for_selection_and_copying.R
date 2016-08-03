
#' Select all nodes
#'
#' Selects all nodes in a Cytoscape Network 
#'
#' @param object Cytoscape network  
#' 
#' @return Selects all nodes in a specified network. 
#'
#' @author Julia Gustavsen, \email{j.gustavsen@@gmail.com}
#' @seealso \code{\link{selectNodes}}
#'
#' @concept RCy3
#' @export
#' 
#' @examples 
#' cw <- CytoscapeWindow('new.demo', new('graphNEL'))
#' selectAllNodes(cw)
#' 
#' @importFrom methods setGeneric
setGeneric('selectAllNodes',	
           signature = 'obj',
           function(obj) standardGeneric('selectAllNodes'))

setMethod('selectAllNodes',
          'CytoscapeWindowClass', 
          function(obj) {
            
            resource.uri <- paste(obj@uri,
                                  pluginVersion(obj),
                                  "networks",
                                  obj@window.id,
                                  "nodes",
                                  sep = "/")
            
            request.res <- GET(resource.uri) # returns all of the node SUIDs
            all_node_SUIDs <- fromJSON(rawToChar(request.res$content))
            SUID.value.pairs <- lapply(all_node_SUIDs,
                                       function(s) {list('SUID' = s, 'value' = TRUE)})
            SUID.value.pairs.JSON <- toJSON(SUID.value.pairs)
            
            resource.uri <- paste(obj@uri,
                                  pluginVersion(obj),
                                  "networks",
                                  obj@window.id,
                                  "tables/defaultnode/columns/selected",
                                  sep = "/")
            request.res <- PUT(url = resource.uri,
                               body = SUID.value.pairs.JSON,
                               encode = "json")
            invisible(request.res)
          })

#' Select all edges 
#'
#' Selects all edges in a Cytoscape Network 
#'
#' @param object Cytoscape network  
#' 
#' @return Selects all edges in a specified network. 
#'
#' @author Julia Gustavsen, \email{j.gustavsen@@gmail.com}
#' @seealso \code{\link{selectEdges}}
#'
#' @concept RCy3
#' @export
#' 
#' @examples 
#' cw <- CytoscapeWindow('new.demo', new('graphNEL'))
#' selectAllEdges(cw)
#' 
#' @importFrom methods setGeneric
setGeneric('selectAllEdges',	
           signature = 'obj',
           function(obj) standardGeneric('selectAllEdges'))

setMethod('selectAllEdges',
          'CytoscapeWindowClass', 
          function(obj) {
            
            resource.uri <- paste(obj@uri,
                                  pluginVersion(obj),
                                  "networks",
                                  obj@window.id,
                                  "edges",
                                  sep = "/")
            
            request.res_edges <- GET(resource.uri) ## returns all of the edge suids
            all_edge_SUIDs <- fromJSON(rawToChar(request.res_edges$content))
            SUID.value.pairs <- lapply(all_edge_SUIDs,
                                       function(s) {list('SUID' = s, 'value' = TRUE)})
            SUID.value.pairs.JSON <- toJSON(SUID.value.pairs)
            
            resource.uri <- paste(obj@uri,
                                  pluginVersion(obj),
                                  "networks",
                                  obj@window.id,
                                  "tables/defaultedge/columns/selected",
                                  sep = "/")
            request.res <- PUT(url = resource.uri,
                               body = SUID.value.pairs.JSON,
                               encode = "json")
            invisible(request.res)
          })

#' Copy a Cytoscape Network 
#'
#' Makes a copy of a Cytoscape Network with all of its edges and nodes 
#'
#' @param object Cytoscape network 
#' @param new_title New name for the copy
#' @param copy.graph.to.R Logical whether to copy the graph to a new object in R 
#' 
#' @return Connection to new copy of network. 
#'
#' @examples 
#' cw <- CytoscapeWindow('new.demo', new('graphNEL'))
#' copy_of_your_net <- copyCytoscapeNetwork(cw, "new_copy")
#'
#' @author Julia Gustavsen, \email{j.gustavsen@@gmail.com}
#' @seealso \code{\link{createWindowFromSelection}}, \code{\link{existing.CytoscapeWindow}}, \code{\link{renameCytoscapeNetwork}}
#' 
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric
setGeneric('copyCytoscapeNetwork',	
           signature = 'obj',
           function(obj,
                    new_title,
                    copy.graph.to.R = FALSE) standardGeneric('copyCytoscapeNetwork'))

setMethod('copyCytoscapeNetwork',
          'CytoscapeWindowClass', 
          function(obj,
                   new_title,
                   copy.graph.to.R = FALSE) {
            if (obj@title == new_title){
              print("Copy not made. The titles of the original window and its copy are the same. Please pick a new name for the copy.")
              stderr()
            }
            else{
              selectAllNodes(obj)
              selectAllEdges(obj)
              request.uri <- paste(obj@uri,
                                   pluginVersion(obj),
                                   "networks",
                                   obj@window.id,
                                   sep = "/")
              
              request.res <- POST(url = request.uri,
                                  query = list(title = new_title))
              
              invisible(request.res)
              
              if (copy.graph.to.R){
                connect_window <- existing.CytoscapeWindow(new_title,
                                                           copy.graph.from.cytoscape.to.R = TRUE)
                print(paste("Cytoscape window",
                            obj@title,
                            "successfully copied to",
                            connect_window@title,
                            "and the graph was copied to R."))
              } 
              else {
                connect_window <- existing.CytoscapeWindow(new_title,
                                                           copy.graph.from.cytoscape.to.R = FALSE) 
                print(paste("Cytoscape window",
                            obj@title,
                            "successfully copied to",
                            connect_window@title,
                            "and the graph was not copied to the R session."))
              }
              
              return(connect_window)
            }
            
          })

#' Rename a network 
#'
#' Renames a Cytoscape Network. 
#'
#' @param object Cytoscape network 
#' @param new_title New name for the copy
#' @param copy.graph.to.R Logical whether to copy the graph to a new object in R 
#' 
#' @return Connection to the renamed network. 
#'
#' @author Julia Gustavsen, \email{j.gustavsen@@gmail.com}
#' @seealso \code{\link{createWindowFromSelection}}, \code{\link{existing.CytoscapeWindow}}, \code{\link{copyCytoscapeNetwork}}
#'
#' @examples 
#' cw <- CytoscapeWindow('new.demo', new('graphNEL'))
#' renamed_net <- renameCytoscapeNetwork(cw, "renamed_network")
#'
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric
setGeneric('renameCytoscapeNetwork',	
           signature = 'obj',
           function(obj,
                    new_title,
                    copy.graph.to.R = FALSE) standardGeneric('renameCytoscapeNetwork'))

setMethod('renameCytoscapeNetwork',
          'CytoscapeWindowClass', 
          function(obj,
                   new_title,
                   copy.graph.to.R = FALSE) {
              new_net <- copyCytoscapeNetwork(obj,
                                              new_title)  
              deleteWindow(obj,
                           obj@title)
              return(new_net)
            })