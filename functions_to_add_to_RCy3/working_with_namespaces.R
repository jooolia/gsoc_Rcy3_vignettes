library(RCy3)
library(httr)

## create functions to get command names for available plugins from Cytoscape


#' Gets commands available from within cytoscape from 
#' functions within cytoscape and from installed plugins.
#'
#' @param object Cytoscape network where commands are fetched via RCy3 
#' @param 
#' @return Vector of available commands from all namespaces (e.g. functions and plugins) 
#'
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric
setGeneric('getCommandNames', 
            signature='obj',
            function(obj) standardGeneric ('getCommandNames'))

setMethod('getCommandNames',
          'CytoscapeConnectionClass',
          function(obj) { 
            request.uri <- paste(obj@uri,
                                 pluginVersion(obj),
                                 "commands",
                                 sep="/")
            request.res <- GET(url=request.uri)
            
            available.commands <- unlist(strsplit(rawToChar(request.res$content),
                                                  split="\n\\s*"))
            ## to remove "Available namespaces" title
            ## remove the first value
            available.commands <- available.commands[-1]
            return(available.commands) 
          })



#' Gets commands available from within a namespace in Cytoscape from 
#' functions within cytoscape and from installed plugins.
#'
#' @param object Cytoscape network where commands are fetched via RCy3 
#' @param namespace Cytoscape function (e.g. layout or network settings) or Cytoscape plugin function
#' 
#' @return Vector of available commands from a specific plugin or Cytoscape function (e.g. namespace)
#'
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric
setGeneric('getCommandsWithinNamespace', 
            signature = 'obj',
            function(obj,
                     namespace) standardGeneric('getCommandsWithinNamespace'))

setMethod('getCommandsWithinNamespace',
          'CytoscapeConnectionClass',
          function(obj,
                   namespace) { 
            request.uri <- paste(obj@uri,
                                 pluginVersion(obj),
                                 "commands",
                                 namespace,
                                 sep = "/")
            request.res <- GET(url = request.uri)
            
            available.commands <- unlist(strsplit(rawToChar(request.res$content),
                                                  split = "\n\\s*"))
            ## remove "Available commands" title
            available.commands <- available.commands[-1]
            return(available.commands) })


## testing out

#' Runs a Cytoscape command (for example from a plugin) with a list of parameters and creates a connection to the network (if a new one is created) so that it can be further manipulated from R. 
#'
#' @param object Cytoscape network where command is run via RCy3 
#' @param command.name Need more info here - how to specify..
#' @param properties.list Parameters (e.g. files, p-values, etc) to be used to set to run the command
#' @param copy.graph.to.R If true this copies the graph information to R. This step can be quite slow. Default is false. 
#' 
#' @return Runs in Cytoscape and creates a connection to the Cytoscape window so that it can be further manipulated from R 
#' 
#' @examples 
#' cw <- CytoscapeWindow('new.demo', new('graphNEL'))
#' selectAllNodes(cw)
#'
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric
setGeneric('setCommandProperties', 
           signature = 'obj',
           function(obj,
                    command.name,
                    properties.list, 
                    copy.graph.to.R = FALSE) standardGeneric('setCommandProperties')
)

setMethod('setCommandProperties',
          'CytoscapeConnectionClass', 
          function(obj,
                   command.name,
                   properties.list, 
                   copy.graph.to.R = FALSE) {
            all.possible.props <- getCommandsWithinNamespace(obj,
                                                                command.name)
            if (all(names(properties.list) %in% all.possible.props) == FALSE) {
              print('You have included a name which is not in the commands')
              stderr ()
            } else {
              request.uri <- paste(obj@uri,
                                   pluginVersion(obj),
                                   "commands",
                                   as.character(command.name),
                                   sep = "/")
              
              request.res <- GET(url = request.uri,
                                 query = properties.list)
              if (request.res$status == 200){
                print("Successfully built the EnrichmentMap.")
                stdout ()
                resource.uri <- paste(cy@uri,
                                      pluginVersion(cy),
                                      "networks",
                                      sep = "/")
                request.res <- GET(resource.uri)
                # SUIDs list of the existing Cytoscape networks	
                cy.networks.SUIDs <- fromJSON(rawToChar(request.res$content))
                # most recently made enrichment map will have the highest SUID
                cy.networks.SUIDs.last <- max(cy.networks.SUIDs)
                
                res.uri.last <- paste(cy@uri,
                                      pluginVersion(cy),
                                      "networks",
                                      as.character(cy.networks.SUIDs.last),
                                      sep = "/")
                result <- GET(res.uri.last)
                net.name <- fromJSON(rawToChar(result$content))$data$name
                
                if (copy.graph.to.R){
                  connect_window_to_R_session <- existing.CytoscapeWindow(net.name,
                                                                      copy.graph.from.cytoscape.to.R = TRUE)
                  print(paste0("Cytoscape window",
                               net.name,
                               " successfully connected to R session and graph copied to R."))
                } 
                else {
                  connect_window_to_R_session <- existing.CytoscapeWindow(net.name,
                                                                      copy.graph.from.cytoscape.to.R = FALSE) 
                  print(paste0("Cytoscape window ",
                               net.name,
                               " successfully connected to R session."))
                }
                
                
              } else {
                print("Something went wrong. Unable to run command.")
                stderr ()
              }
              invisible(request.res)
            }
            return(connect_window_to_R_session)
          }) 

