library(RCy3)
library(httr)

## create function to get command names for available plugins from Cytoscape
setGeneric ('getCommandNames', 
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



## make function to get commands from Enrichment map
setGeneric ('getCommandsWithinNamespace', 
            signature = 'obj',
            function(obj,
                     namespace) standardGeneric ('getCommandsWithinNamespace'))



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
