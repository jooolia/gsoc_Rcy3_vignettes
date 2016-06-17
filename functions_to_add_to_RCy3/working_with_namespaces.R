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
