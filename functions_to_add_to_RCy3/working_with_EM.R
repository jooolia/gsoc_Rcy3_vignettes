## Functions for creating enrichment maps in Cytoscape via R. 


#' Gets a list of commands available in Enrichment Map 
#'
#' @param object Cytoscape network where Enrichment Map is run via RCy3 
#' @param command.name build or gseabuild
#' 
#' @return command.property.names list of available commands in EnrichmentMap 
#'
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric
setGeneric ('getEnrichmentMapCommandsNames',	
            signature='obj', function(obj,
                                      command.name) standardGeneric ('getEnrichmentMapCommandsNames'))

setMethod('getEnrichmentMapCommandsNames',
          'CytoscapeConnectionClass', 
          function(obj,
                   command.name) {
            request.uri <- paste(obj@uri,
                                 pluginVersion(obj),
                                 "commands/enrichmentmap",
                                 as.character(command.name),
                                 sep="/")
            request.res <- GET(url=request.uri)
            
            command.property.names <-unlist(strsplit(rawToChar(request.res$content),
                                                     split = "\n\\s*"))
            ## how to remove "Available commands ..."?
            ## not happy with this
            command.property.names <- command.property.names[-1]
            
            return(command.property.names)
            
          })## END getEnrichmentMapCommandsNames


#' Runs Enrichment Map with a list of parameters and creates a connection to the Enrichment Map so that it can be further manipulated from R. 
#'
#' @param object Cytoscape network where Enrichment Map is run via RCy3 
#' @param command.name build or gseabuild
#' @param properties.list Parameters (e.g. files, p-values, etc) to be used to run Enrichment Map
#' @param copy.graph.to.R If true this copies the graph information to R. This step can be quite slow. Default is false. 
#' 
#' @return Creates Enrichment Map in Cytoscape and creates a connection to the Enrichment Map so that it can be further manipulated from R 
#'
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric
setGeneric('setEnrichmentMapProperties', 
           signature='obj',
           function(obj,
                    command.name,
                    properties.list, 
                    copy.graph.to.R = FALSE) standardGeneric('setEnrichmentMapProperties')
)

setMethod('setEnrichmentMapProperties',
          'CytoscapeConnectionClass', 
          function(obj,
                   command.name,
                   properties.list, 
                   copy.graph.to.R = FALSE) {
            all.possible.props <- getEnrichmentMapCommandsNames(obj,
                                                                command.name)
            if (all(names(properties.list) %in% all.possible.props) == FALSE) {
              print('You have included a name which is not in the commands')
              stderr ()
            } else {
              request.uri <- paste(obj@uri,
                                   pluginVersion(obj),
                                   "commands/enrichmentmap",
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
                  connect_EM_to_R_session <- existing.CytoscapeWindow(net.name,
                                                                      copy.graph.from.cytoscape.to.R = TRUE)
                  print(paste0("Cytoscape window",
                               net.name,
                               " successfully connected to R session and graph copied to R."))
                } 
                else {
                  connect_EM_to_R_session <- existing.CytoscapeWindow(net.name,
                                                                      copy.graph.from.cytoscape.to.R = FALSE) 
                  print(paste0("Cytoscape window ",
                               net.name,
                               " successfully connected to R session."))
                }
                
                
              } else {
                print("Something went wrong. Unable to build EnrichmentMap")
                stderr ()
              }
              invisible(request.res)
            }
            return(connect_EM_to_R_session)
          }) 