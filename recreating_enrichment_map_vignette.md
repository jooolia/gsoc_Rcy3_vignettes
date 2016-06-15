# recreating_enrichment_map_tut_with_RCy3
Julia Gustavsen  
May 24, 2016  

# Recreating tutorials from Bader lab (link) using Rcy3 and cytoscape. 

```r
library(RCy3)
```

```
## Loading required package: graph
```

```r
library(httr)
library(RJSONIO)
## how to check that I am connected to Cytoscape?
```

* Make sure cytoscape is open!

## Reference for the API

found this page which is helpful for the api:

http://idekerlab.github.io/cyREST/#1637304040

## Finding command names available in Cytoscape using R

Finally found: 

http://localhost:1234/v1/commands

Which gives the same as when you type `help` in the Command Line Dialog in cytoscape


```r
## create function to get command names from Cytoscape
setGeneric ('getCommandNames', 
            signature='obj',
            function(obj) standardGeneric ('getCommandNames'))
```

```
## [1] "getCommandNames"
```

```r
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
            ## how to remove "Available namespaces"?
            ## will remove the first value,
            ## but feels a bit hacky
            ## not happy with this
            available.commands <- available.commands[-1]
            return(available.commands) })
```

```
## [1] "getCommandNames"
```

Test out the function to see the available commands in Cytoscape

```r
cy <- CytoscapeConnection ()
getCommandNames(cy)
```

```
##  [1] "cluster"       "clusterviz"    "command"       "edge"         
##  [5] "enrichmentmap" "group"         "layout"        "network"      
##  [9] "node"          "session"       "table"         "view"         
## [13] "vizmap"
```

### Can I easily access the commands within Enrichment map?


```r
port.number = 1234
base.url = paste("http://localhost:",
                 toString(port.number),
                 "/v1", sep="")
base.url
```

```
## [1] "http://localhost:1234/v1"
```

```r
commands_enrichment_map.uri <- paste(base.url, "commands/enrichmentmap", sep="/")
request.res <- GET(url = commands_enrichment_map.uri )
request.res
```

```
## Response [http://localhost:1234/v1/commands/enrichmentmap]
##   Date: 2016-06-15 08:30
##   Status: 200
##   Content-Type: text/plain
##   Size: 60 B
```

```
## No encoding supplied: defaulting to UTF-8.
```

```
## Available commands for 'enrichmentmap':
##   build
##   gseabuild
```

Now try to extend this to find commands from a specific plugin?
Does it make sense to make a specifc class for S4 for these things? I need to keep learning about this.


```r
## make function to get commands from Enrichment map
setGeneric ('getCommandNamesEnrichmentMap', 
            signature = 'obj', function(obj) standardGeneric ('getCommandNamesEnrichmentMap'))
```

```
## [1] "getCommandNamesEnrichmentMap"
```

```r
setMethod('getCommandNamesEnrichmentMap',
          'CytoscapeConnectionClass',
          function(obj) { 
            request.uri <- paste(obj@uri,
                                 pluginVersion(obj),
                                 "commands/enrichmentmap",
                                 sep = "/")
            request.res <- GET(url = request.uri)
            
            available.commands <- unlist(strsplit(rawToChar(request.res$content),
                                                  split = "\n\\s*"))
            ## how to remove "Available commands ..."?
            ## not happy with this
            available.commands <- available.commands[-1]
            return(available.commands) })
```

```
## [1] "getCommandNamesEnrichmentMap"
```

```r
cy <- CytoscapeConnection ()
str(getCommandNamesEnrichmentMap(cy))
```

```
##  chr [1:2] "build" "gseabuild"
```

Could try to find names within a specific namespace...make a function to do that?



```r
## make function to get commands from Enrichment map
setGeneric ('getCommandsWithinNamespace', 
            signature = 'obj',
            function(obj,
                     namespace) standardGeneric ('getCommandsWithinNamespace'))
```

```
## [1] "getCommandsWithinNamespace"
```

```r
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
            ## how to remove "Available commands ..."?
            ## not happy with this
            available.commands <- available.commands[-1]
            return(available.commands) })
```

```
## [1] "getCommandsWithinNamespace"
```

Test out using different namespaces

```r
cy <- CytoscapeConnection ()
str(getCommandsWithinNamespace(cy, "enrichmentmap"))
```

```
##  chr [1:2] "build" "gseabuild"
```

```r
getCommandsWithinNamespace(cy, "layout")
```

```
##  [1] "allegro-edge-repulsive-fruchterman-reingold"
##  [2] "allegro-edge-repulsive-spring-electric"     
##  [3] "allegro-edge-repulsive-strong-clustering"   
##  [4] "allegro-edge-repulsive-weak-clustering"     
##  [5] "allegro-fruchterman-reingold"               
##  [6] "allegro-spring-electric"                    
##  [7] "allegro-strong-clustering"                  
##  [8] "allegro-weak-clustering"                    
##  [9] "apply preferred"                            
## [10] "attribute-circle"                           
## [11] "attributes-layout"                          
## [12] "circular"                                   
## [13] "degree-circle"                              
## [14] "force-directed"                             
## [15] "fruchterman-rheingold"                      
## [16] "get preferred"                              
## [17] "grid"                                       
## [18] "hierarchical"                               
## [19] "isom"                                       
## [20] "kamada-kawai"                               
## [21] "set preferred"                              
## [22] "stacked-node-layout"
```

```r
getCommandsWithinNamespace(cy, "cluster")
```

```
##  [1] "ap"                  "attribute"           "autosome_heatmap"   
##  [4] "autosome_network"    "bestneighbor"        "cheng&church"       
##  [7] "connectedcomponents" "cuttingedge"         "dbscan"             
## [10] "density"             "fcml"                "featurevector"      
## [13] "fft"                 "filter"              "fuzzifier"          
## [16] "getcluster"          "getnetworkcluster"   "glay"               
## [19] "haircut"             "hascluster"          "hierarchical"       
## [22] "hopach"              "kmeans"              "kmedoid"            
## [25] "mcl"                 "mcode"               "network"            
## [28] "pam"                 "scps"                "transclust"
```

```r
getCommandsWithinNamespace(cy, "network")
```

```
##  [1] "add"              "add edge"         "add node"        
##  [4] "clone"            "create"           "create attribute"
##  [7] "create empty"     "delete"           "deselect"        
## [10] "destroy"          "export"           "get"             
## [13] "get attribute"    "get properties"   "hide"            
## [16] "import file"      "import url"       "list"            
## [19] "list attributes"  "list properties"  "load file"       
## [22] "load url"         "rename"           "select"          
## [25] "set attribute"    "set current"      "set properties"  
## [28] "show"
```


## Enrichment map stuff

### help enrichmentmap build
enrichmentmap build arguments:
analysisType=<ListSingleSelection GSEA|generic|DAVID/BiNGO/Great)>: Analysis Type
classDataset1=<File>: Classes
classDataset2=<File>: Classes
coeffecients=<ListSingleSelection (OVERLAP|JACCARD|COMBINED)>: Similarity Coeffecient
enrichments2Dataset1=<File>: Enrichments 2
enrichments2Dataset2=<File>: Enrichments 2
enrichmentsDataset1=<File>: Enrichments
enrichmentsDataset2=<File>: Enrichments
expressionDataset1=<File>: Expression
expressionDataset2=<File>: Expression
gmtFile=<File>: GMT
phenotype1Dataset1=<String>: Phenotype1
phenotype1Dataset2=<String>: Phenotype1
phenotype2Dataset1=<String>: Phenotype2
phenotype2Dataset2=<String>: Phenotype2
pvalue=<Double>: P-value Cutoff
qvalue=<Double>: FDR Q-value Cutoff
ranksDataset1=<File>: Ranks
ranksDataset2=<File>: Ranks
similaritycutoff=<Double>: Similarity Cutoff

### help enrichmentmap gseabuild
enrichmentmap gseabuild arguments:
combinedconstant=<Double>: combinedconstant
edbdir=<String>: edbdir
edbdir2=<String>: edbdir2
expressionfile=<String>: expressionfile
expressionfile2=<String>: expressionfile2
overlap=<Double>: overlap
pvalue=<Double>: P-value Cutoff
qvalue=<Double>: FDR Q-value Cutoff
similaritymetric=<ListSingleSelection (OVERLAP|JACCARD|COMBINED)>: similaritymetric


```r
setGeneric ('getEnrichmentMapCommands', 
	signature='obj', function(obj) standardGeneric ('getEnrichmentMapCommands'))
```

```
## [1] "getEnrichmentMapCommands"
```

```r
setGeneric ('getEnrichmentMapNameMapping',	
	signature='obj', function(obj) standardGeneric ('getEnrichmentMapNameMapping'))
```

```
## [1] "getEnrichmentMapNameMapping"
```

```r
setGeneric ('getEnrichmentMapCommandsNames',	
	signature='obj', function(obj, layout.name) standardGeneric ('getEnrichmentMapCommandsNames'))
```

```
## [1] "getEnrichmentMapCommandsNames"
```

```r
getCommandNamesEnrichmentMap(cy)
```

```
## [1] "build"     "gseabuild"
```

```r
layout.names <- getCommandNamesEnrichmentMap(cy)
layout.full.names <- c()


# get the English/full name of a layout
for (layout.name in layout.names){
  request.uri <- paste(cy@uri,
                       pluginVersion(cy),
                       "commands/enrichmentmap",
                       as.character(layout.name),
                       sep="/")
  request.res <- GET(url=request.uri)

   layout.property.names <- unlist(strsplit(rawToChar(request.res$content),
                                                  split = "\n\\s*"))
            ## how to remove "Available commands ..."?
            ## not happy with this
            layout.property.names <- layout.property.names[-1]

return(layout.property.names)
}
```

```
##  [1] "analysisType"         "classDataset1"        "classDataset2"       
##  [4] "coeffecients"         "enrichments2Dataset1" "enrichments2Dataset2"
##  [7] "enrichmentsDataset1"  "enrichmentsDataset2"  "expressionDataset1"  
## [10] "expressionDataset2"   "gmtFile"              "phenotype1Dataset1"  
## [13] "phenotype1Dataset2"   "phenotype2Dataset1"   "phenotype2Dataset2"  
## [16] "pvalue"               "qvalue"               "ranksDataset1"       
## [19] "ranksDataset2"        "similaritycutoff"
```


```r
## need to specify which one would be most useful here? build or gseabuild or just make stuff for both?
setMethod('getEnrichmentMapNameMapping', 'CytoscapeConnectionClass', 
    function(obj) {
        layout.names <- getCommandNamesEnrichmentMap(obj)
        layout.full.names <- c()
        
        # get the English/full name of a layout
        for (layout.name in layout.names){
            request.uri <- paste(obj@uri,
                                 pluginVersion(obj),
                                 "commands/enrichmentmap",
                                 as.character(layout.name),
                                 sep="/")
            request.res <- GET(url=request.uri)
            
   layout.property.names <- unlist(strsplit(rawToChar(request.res$content),
                                                  split = "\n\\s*"))
            ## how to remove "Available commands ..."?
            ## not happy with this
            layout.property.names <- layout.property.names[-1]
        }

return(layout.property.names)
})
```

```
## [1] "getEnrichmentMapNameMapping"
```

```r
## END getLayoutNameMapping

getEnrichmentMapNameMapping(cy)            
```

```
## [1] "combinedconstant" "edbdir"           "edbdir2"         
## [4] "expressionfile"   "expressionfile2"  "overlap"         
## [7] "pvalue"           "qvalue"           "similaritymetric"
```

```r
#http://localhost:1234/v1/commands/enrichmentmap/build/

setMethod('getEnrichmentMapCommandsNames',
          'CytoscapeConnectionClass', 
          function(obj,
                   layout.name) {
            request.uri <- paste(obj@uri,
                                 pluginVersion(obj),
                                 "commands/enrichmentmap",
                                 as.character(layout.name),
                                 sep="/")
            request.res <- GET(url=request.uri)
            
            layout.property.names <-unlist(strsplit(rawToChar(request.res$content),
                                                    split = "\n\\s*"))
            ## how to remove "Available commands ..."?
            ## not happy with this
            layout.property.names <- layout.property.names[-1]
            
            return(layout.property.names)
            
          })## END getEnrichmentMapCommandsNames
```

```
## [1] "getEnrichmentMapCommandsNames"
```

```r
getEnrichmentMapCommandsNames(cy, "build")
```

```
##  [1] "analysisType"         "classDataset1"        "classDataset2"       
##  [4] "coeffecients"         "enrichments2Dataset1" "enrichments2Dataset2"
##  [7] "enrichmentsDataset1"  "enrichmentsDataset2"  "expressionDataset1"  
## [10] "expressionDataset2"   "gmtFile"              "phenotype1Dataset1"  
## [13] "phenotype1Dataset2"   "phenotype2Dataset1"   "phenotype2Dataset2"  
## [16] "pvalue"               "qvalue"               "ranksDataset1"       
## [19] "ranksDataset2"        "similaritycutoff"
```

```r
getEnrichmentMapCommandsNames(cy, "gseabuild")
```

```
## [1] "combinedconstant" "edbdir"           "edbdir2"         
## [4] "expressionfile"   "expressionfile2"  "overlap"         
## [7] "pvalue"           "qvalue"           "similaritymetric"
```

Trying to figure out how to send data to the cytoscape network



```r
request.uri <- paste(cy@uri,
                     pluginVersion(cy),
                     "commands/enrichmentmap",
                     as.character(layout.name),
                     sep = "/")

## with this one you need to use a GET request and it should be in the form of a query, not a json list. 
# request.res <- PUT(url = request.uri,
#                    body = new.property.value.list.JSON,
#                    encode = "json")
# request.res    
## gives 405 response...which means not allowed. 
```



```r
getEnrichmentMapCommandsNames(cy,"build")
```

```
##  [1] "analysisType"         "classDataset1"        "classDataset2"       
##  [4] "coeffecients"         "enrichments2Dataset1" "enrichments2Dataset2"
##  [7] "enrichmentsDataset1"  "enrichmentsDataset2"  "expressionDataset1"  
## [10] "expressionDataset2"   "gmtFile"              "phenotype1Dataset1"  
## [13] "phenotype1Dataset2"   "phenotype2Dataset1"   "phenotype2Dataset2"  
## [16] "pvalue"               "qvalue"               "ranksDataset1"       
## [19] "ranksDataset2"        "similaritycutoff"
```


```r
enrichmentmap.url <- paste(base.url,
                           "commands",
                           "enrichmentmap",
                           "build",
                           sep="/") 

## something to deal with is that you cannot use relative paths in this, it needs to be absolute path
path_to_file="/home/julia_g/windows_school/gsoc/EM-tutorials-docker/notebooks/data/"

enr_file = paste(path_to_file,
                 "gprofiler_results_mesenonly_ordered_computedinR.txt",
                 sep="")
```


```r
#' Runs Enrichment Map with a list of parameters.
#'
#' @param object Cytoscape network where Enrichment Map is run via RCy3 
#' @param 
#' @return An enrichmentMap 
#'
#' @concept RCy3
#' @export
#' 
#' @importFrom methods setGeneric

setGeneric('setEnrichmentMapProperties', 
            signature='obj',
            function(obj,
                     layout.name,
                     properties.list, 
                     copy.graph.to.R = FALSE) standardGeneric('setEnrichmentMapProperties')
           )
```

```
## [1] "setEnrichmentMapProperties"
```

```r
setMethod('setEnrichmentMapProperties',
          'CytoscapeConnectionClass', 
          function(obj,
                   layout.name,
                   properties.list, 
                   copy.graph.to.R = FALSE) {
            all.possible.props <- getEnrichmentMapCommandsNames(obj,
                                                                layout.name)
            if (all(names(properties.list) %in% all.possible.props) == FALSE) {
              print('You have included a name which is not in the commands')
              stderr ()
            } else {
              request.uri <- paste(obj@uri,
                                   pluginVersion(obj),
                                   "commands/enrichmentmap",
                                   as.character(layout.name),
                                   sep = "/")
              
              request.res <- GET(url = request.uri,
                                 query = properties.list)
              if (request.res$status == 200){
                print("Successfully built the EnrichmentMap.")
                stdout ()
                resource.uri <- paste(cy@uri,
                                      pluginVersion(cy),
                                      "networks",
                                      sep="/")
                request.res <- GET(resource.uri)
                # SUIDs list of the existing Cytoscape networks	
                cy.networks.SUIDs <- fromJSON(rawToChar(request.res$content))
                # most recently made enrichment map will have the highest SUID
                cy.networks.SUIDs.last <- max(cy.networks.SUIDs)
                
                res.uri.last <- paste(cy@uri,
                                      pluginVersion(cy),
                                      "networks",
                                      as.character(cy.networks.SUIDs.last),
                                      sep="/")
                result <- GET(res.uri.last)
                net.name <- fromJSON(rawToChar(result$content))$data$name
              
                if (copy.graph.to.R){
                  connect_EM_to_R_session <- existing.CytoscapeWindow (net.name,
                                                  copy.graph.from.cytoscape.to.R=TRUE)
                                 print(paste0("Cytoscape window",
                            net.name,
                            " successfully connected to R session and graph copied to R."))
                } 
                else{
               connect_EM_to_R_session <- existing.CytoscapeWindow (net.name,
                                                  copy.graph.from.cytoscape.to.R=FALSE) 
               print(paste0("Cytoscape window",
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
```

```
## [1] "setEnrichmentMapProperties"
```

```r
em_params <- list(analysisType = "generic",
                  enrichmentsDataset1 = enr_file,
                  pvalue = "1.0",
                  qvalue = "0.00001",
                  #expressionDataset1 = exp_file, 
                  similaritycutoff = "0.25",
                  coeffecients = "JACCARD")
## so no graph is returned, just the connection to the graph
new <- setEnrichmentMapProperties(cy, "build", em_params)
```

```
## [1] "Successfully built the EnrichmentMap."
## [1] "Cytoscape windowEM1_Enrichment Map successfully connected to R session."
```

```r
saveImage(new,
          "test_EM_new",
          "png",
          scale=4)
print(noa.names(getGraph(new)))
```

```
## NULL
```

```r
 layoutNetwork(new,
                  'grid')
saveNetwork(new, "test_EM")    
new@graph
```

```
## A graphNEL graph with directed edges
## Number of Nodes = 0 
## Number of Edges = 0
```

```r
## so almost here like you need to get the window returned here. 
## need a function to determine the suid of the network made. 
## how to get the name of the graph made??
## how can I then manipulate it?

new2 <- setEnrichmentMapProperties(cy,
                                   "build",
                                   em_params,
                                   copy.graph.to.R = TRUE)
```

```
## [1] "Successfully built the EnrichmentMap."
## [1] "Cytoscape windowEM2_Enrichment Map successfully connected to R session and graph copied to R."
```

```r
print(noa.names(getGraph(new2)))
```

```
##  [1] "name"                    "EM2_GS_DESCR"           
##  [3] "EM2_Formatted_name"      "EM2_Name"               
##  [5] "EM2_GS_Source"           "EM2_GS_Type"            
##  [7] "EM2_pvalue_dataset1"     "EM2_Colouring_dataset1" 
##  [9] "EM2_fdr_qvalue_dataset1" "EM2_gs_size_dataset1"
```

```r
nodeData(new2@graph)
```

```
## $`REAC:5173214`
## $`REAC:5173214`$name
## [1] "REAC:5173214"
## 
## $`REAC:5173214`$EM2_GS_DESCR
## [1] "O-GLYCOSYLATION OF TSR DOMAIN-CONTAINING PROTEINS"
## 
## $`REAC:5173214`$EM2_Formatted_name
## [1] "REAC:5173214\n"
## 
## $`REAC:5173214`$EM2_Name
## [1] "REAC:5173214"
## 
## $`REAC:5173214`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:5173214`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:5173214`$EM2_pvalue_dataset1
## [1] 2.21e-12
## 
## $`REAC:5173214`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:5173214`$EM2_fdr_qvalue_dataset1
## [1] 2.21e-12
## 
## $`REAC:5173214`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0010720`
## $`GO:0010720`$name
## [1] "GO:0010720"
## 
## $`GO:0010720`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF CELL DEVELOPMENT"
## 
## $`GO:0010720`$EM2_Formatted_name
## [1] "GO:0010720\n"
## 
## $`GO:0010720`$EM2_Name
## [1] "GO:0010720"
## 
## $`GO:0010720`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010720`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010720`$EM2_pvalue_dataset1
## [1] 3.52e-07
## 
## $`GO:0010720`$EM2_Colouring_dataset1
## [1] 0.9999996
## 
## $`GO:0010720`$EM2_fdr_qvalue_dataset1
## [1] 3.52e-07
## 
## $`GO:0010720`$EM2_gs_size_dataset1
## [1] 34
## 
## 
## $`GO:0010721`
## $`GO:0010721`$name
## [1] "GO:0010721"
## 
## $`GO:0010721`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELL DEVELOPMENT"
## 
## $`GO:0010721`$EM2_Formatted_name
## [1] "GO:0010721\n"
## 
## $`GO:0010721`$EM2_Name
## [1] "GO:0010721"
## 
## $`GO:0010721`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010721`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010721`$EM2_pvalue_dataset1
## [1] 2.38e-06
## 
## $`GO:0010721`$EM2_Colouring_dataset1
## [1] 0.9999976
## 
## $`GO:0010721`$EM2_fdr_qvalue_dataset1
## [1] 2.38e-06
## 
## $`GO:0010721`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0044273`
## $`GO:0044273`$name
## [1] "GO:0044273"
## 
## $`GO:0044273`$EM2_GS_DESCR
## [1] "SULFUR COMPOUND CATABOLIC PROCESS"
## 
## $`GO:0044273`$EM2_Formatted_name
## [1] "GO:0044273\n"
## 
## $`GO:0044273`$EM2_Name
## [1] "GO:0044273"
## 
## $`GO:0044273`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0044273`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0044273`$EM2_pvalue_dataset1
## [1] 2.64e-06
## 
## $`GO:0044273`$EM2_Colouring_dataset1
## [1] 0.9999974
## 
## $`GO:0044273`$EM2_fdr_qvalue_dataset1
## [1] 2.64e-06
## 
## $`GO:0044273`$EM2_gs_size_dataset1
## [1] 8
## 
## 
## $`GO:0043062`
## $`GO:0043062`$name
## [1] "GO:0043062"
## 
## $`GO:0043062`$EM2_GS_DESCR
## [1] "EXTRACELLULAR STRUCTURE ORGANIZATION"
## 
## $`GO:0043062`$EM2_Formatted_name
## [1] "GO:0043062\n"
## 
## $`GO:0043062`$EM2_Name
## [1] "GO:0043062"
## 
## $`GO:0043062`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0043062`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0043062`$EM2_pvalue_dataset1
## [1] 9.28e-63
## 
## $`GO:0043062`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0043062`$EM2_fdr_qvalue_dataset1
## [1] 9.28e-63
## 
## $`GO:0043062`$EM2_gs_size_dataset1
## [1] 100
## 
## 
## $`GO:0048864`
## $`GO:0048864`$name
## [1] "GO:0048864"
## 
## $`GO:0048864`$EM2_GS_DESCR
## [1] "STEM CELL DEVELOPMENT"
## 
## $`GO:0048864`$EM2_Formatted_name
## [1] "GO:0048864\n"
## 
## $`GO:0048864`$EM2_Name
## [1] "GO:0048864"
## 
## $`GO:0048864`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048864`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048864`$EM2_pvalue_dataset1
## [1] 6.74e-13
## 
## $`GO:0048864`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0048864`$EM2_fdr_qvalue_dataset1
## [1] 6.74e-13
## 
## $`GO:0048864`$EM2_gs_size_dataset1
## [1] 32
## 
## 
## $`GO:0060173`
## $`GO:0060173`$name
## [1] "GO:0060173"
## 
## $`GO:0060173`$EM2_GS_DESCR
## [1] "LIMB DEVELOPMENT"
## 
## $`GO:0060173`$EM2_Formatted_name
## [1] "GO:0060173\n"
## 
## $`GO:0060173`$EM2_Name
## [1] "GO:0060173"
## 
## $`GO:0060173`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060173`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060173`$EM2_pvalue_dataset1
## [1] 4.34e-06
## 
## $`GO:0060173`$EM2_Colouring_dataset1
## [1] 0.9999957
## 
## $`GO:0060173`$EM2_fdr_qvalue_dataset1
## [1] 4.34e-06
## 
## $`GO:0060173`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`REAC:1638091`
## $`REAC:1638091`$name
## [1] "REAC:1638091"
## 
## $`REAC:1638091`$EM2_GS_DESCR
## [1] "HEPARAN SULFATE/HEPARIN (HS-GAG) METABOLISM"
## 
## $`REAC:1638091`$EM2_Formatted_name
## [1] "REAC:1638091\n"
## 
## $`REAC:1638091`$EM2_Name
## [1] "REAC:1638091"
## 
## $`REAC:1638091`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1638091`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1638091`$EM2_pvalue_dataset1
## [1] 2.34e-06
## 
## $`REAC:1638091`$EM2_Colouring_dataset1
## [1] 0.9999977
## 
## $`REAC:1638091`$EM2_fdr_qvalue_dataset1
## [1] 2.34e-06
## 
## $`REAC:1638091`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0030203`
## $`GO:0030203`$name
## [1] "GO:0030203"
## 
## $`GO:0030203`$EM2_GS_DESCR
## [1] "GLYCOSAMINOGLYCAN METABOLIC PROCESS"
## 
## $`GO:0030203`$EM2_Formatted_name
## [1] "GO:0030203\n"
## 
## $`GO:0030203`$EM2_Name
## [1] "GO:0030203"
## 
## $`GO:0030203`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030203`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030203`$EM2_pvalue_dataset1
## [1] 4.58e-12
## 
## $`GO:0030203`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030203`$EM2_fdr_qvalue_dataset1
## [1] 4.58e-12
## 
## $`GO:0030203`$EM2_gs_size_dataset1
## [1] 31
## 
## 
## $`GO:0030204`
## $`GO:0030204`$name
## [1] "GO:0030204"
## 
## $`GO:0030204`$EM2_GS_DESCR
## [1] "CHONDROITIN SULFATE METABOLIC PROCESS"
## 
## $`GO:0030204`$EM2_Formatted_name
## [1] "GO:0030204\n"
## 
## $`GO:0030204`$EM2_Name
## [1] "GO:0030204"
## 
## $`GO:0030204`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030204`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030204`$EM2_pvalue_dataset1
## [1] 9.62e-11
## 
## $`GO:0030204`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030204`$EM2_fdr_qvalue_dataset1
## [1] 9.62e-11
## 
## $`GO:0030204`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0018212`
## $`GO:0018212`$name
## [1] "GO:0018212"
## 
## $`GO:0018212`$EM2_GS_DESCR
## [1] "PEPTIDYL-TYROSINE MODIFICATION"
## 
## $`GO:0018212`$EM2_Formatted_name
## [1] "GO:0018212\n"
## 
## $`GO:0018212`$EM2_Name
## [1] "GO:0018212"
## 
## $`GO:0018212`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0018212`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0018212`$EM2_pvalue_dataset1
## [1] 2.92e-09
## 
## $`GO:0018212`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0018212`$EM2_fdr_qvalue_dataset1
## [1] 2.92e-09
## 
## $`GO:0018212`$EM2_gs_size_dataset1
## [1] 34
## 
## 
## $`REAC:216083`
## $`REAC:216083`$name
## [1] "REAC:216083"
## 
## $`REAC:216083`$EM2_GS_DESCR
## [1] "INTEGRIN CELL SURFACE INTERACTIONS"
## 
## $`REAC:216083`$EM2_Formatted_name
## [1] "REAC:216083\n"
## 
## $`REAC:216083`$EM2_Name
## [1] "REAC:216083"
## 
## $`REAC:216083`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:216083`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:216083`$EM2_pvalue_dataset1
## [1] 1.69e-10
## 
## $`REAC:216083`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:216083`$EM2_fdr_qvalue_dataset1
## [1] 1.69e-10
## 
## $`REAC:216083`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0060070`
## $`GO:0060070`$name
## [1] "GO:0060070"
## 
## $`GO:0060070`$EM2_GS_DESCR
## [1] "CANONICAL WNT SIGNALING PATHWAY"
## 
## $`GO:0060070`$EM2_Formatted_name
## [1] "GO:0060070\n"
## 
## $`GO:0060070`$EM2_Name
## [1] "GO:0060070"
## 
## $`GO:0060070`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060070`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060070`$EM2_pvalue_dataset1
## [1] 1.03e-08
## 
## $`GO:0060070`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0060070`$EM2_fdr_qvalue_dataset1
## [1] 1.03e-08
## 
## $`GO:0060070`$EM2_gs_size_dataset1
## [1] 29
## 
## 
## $`GO:0045596`
## $`GO:0045596`$name
## [1] "GO:0045596"
## 
## $`GO:0045596`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELL DIFFERENTIATION"
## 
## $`GO:0045596`$EM2_Formatted_name
## [1] "GO:0045596\n"
## 
## $`GO:0045596`$EM2_Name
## [1] "GO:0045596"
## 
## $`GO:0045596`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045596`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045596`$EM2_pvalue_dataset1
## [1] 9.13e-12
## 
## $`GO:0045596`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0045596`$EM2_fdr_qvalue_dataset1
## [1] 9.13e-12
## 
## $`GO:0045596`$EM2_gs_size_dataset1
## [1] 44
## 
## 
## $`GO:0001568`
## $`GO:0001568`$name
## [1] "GO:0001568"
## 
## $`GO:0001568`$EM2_GS_DESCR
## [1] "BLOOD VESSEL DEVELOPMENT"
## 
## $`GO:0001568`$EM2_Formatted_name
## [1] "GO:0001568\n"
## 
## $`GO:0001568`$EM2_Name
## [1] "GO:0001568"
## 
## $`GO:0001568`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001568`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001568`$EM2_pvalue_dataset1
## [1] 9.21e-24
## 
## $`GO:0001568`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001568`$EM2_fdr_qvalue_dataset1
## [1] 9.21e-24
## 
## $`GO:0001568`$EM2_gs_size_dataset1
## [1] 64
## 
## 
## $`GO:0048863`
## $`GO:0048863`$name
## [1] "GO:0048863"
## 
## $`GO:0048863`$EM2_GS_DESCR
## [1] "STEM CELL DIFFERENTIATION"
## 
## $`GO:0048863`$EM2_Formatted_name
## [1] "GO:0048863\n"
## 
## $`GO:0048863`$EM2_Name
## [1] "GO:0048863"
## 
## $`GO:0048863`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048863`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048863`$EM2_pvalue_dataset1
## [1] 1.43e-12
## 
## $`GO:0048863`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0048863`$EM2_fdr_qvalue_dataset1
## [1] 1.43e-12
## 
## $`GO:0048863`$EM2_gs_size_dataset1
## [1] 37
## 
## 
## $`GO:0072163`
## $`GO:0072163`$name
## [1] "GO:0072163"
## 
## $`GO:0072163`$EM2_GS_DESCR
## [1] "MESONEPHRIC EPITHELIUM DEVELOPMENT"
## 
## $`GO:0072163`$EM2_Formatted_name
## [1] "GO:0072163\n"
## 
## $`GO:0072163`$EM2_Name
## [1] "GO:0072163"
## 
## $`GO:0072163`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072163`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072163`$EM2_pvalue_dataset1
## [1] 3.86e-08
## 
## $`GO:0072163`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0072163`$EM2_fdr_qvalue_dataset1
## [1] 3.86e-08
## 
## $`GO:0072163`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0010717`
## $`GO:0010717`$name
## [1] "GO:0010717"
## 
## $`GO:0010717`$EM2_GS_DESCR
## [1] "REGULATION OF EPITHELIAL TO MESENCHYMAL TRANSITION"
## 
## $`GO:0010717`$EM2_Formatted_name
## [1] "GO:0010717\n"
## 
## $`GO:0010717`$EM2_Name
## [1] "GO:0010717"
## 
## $`GO:0010717`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010717`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010717`$EM2_pvalue_dataset1
## [1] 5.15e-07
## 
## $`GO:0010717`$EM2_Colouring_dataset1
## [1] 0.9999995
## 
## $`GO:0010717`$EM2_fdr_qvalue_dataset1
## [1] 5.15e-07
## 
## $`GO:0010717`$EM2_gs_size_dataset1
## [1] 15
## 
## 
## $`GO:0072164`
## $`GO:0072164`$name
## [1] "GO:0072164"
## 
## $`GO:0072164`$EM2_GS_DESCR
## [1] "MESONEPHRIC TUBULE DEVELOPMENT"
## 
## $`GO:0072164`$EM2_Formatted_name
## [1] "GO:0072164\n"
## 
## $`GO:0072164`$EM2_Name
## [1] "GO:0072164"
## 
## $`GO:0072164`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072164`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072164`$EM2_pvalue_dataset1
## [1] 3.86e-08
## 
## $`GO:0072164`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0072164`$EM2_fdr_qvalue_dataset1
## [1] 3.86e-08
## 
## $`GO:0072164`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0030206`
## $`GO:0030206`$name
## [1] "GO:0030206"
## 
## $`GO:0030206`$EM2_GS_DESCR
## [1] "CHONDROITIN SULFATE BIOSYNTHETIC PROCESS"
## 
## $`GO:0030206`$EM2_Formatted_name
## [1] "GO:0030206\n"
## 
## $`GO:0030206`$EM2_Name
## [1] "GO:0030206"
## 
## $`GO:0030206`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030206`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030206`$EM2_pvalue_dataset1
## [1] 7.08e-08
## 
## $`GO:0030206`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0030206`$EM2_fdr_qvalue_dataset1
## [1] 7.08e-08
## 
## $`GO:0030206`$EM2_gs_size_dataset1
## [1] 7
## 
## 
## $`GO:0048736`
## $`GO:0048736`$name
## [1] "GO:0048736"
## 
## $`GO:0048736`$EM2_GS_DESCR
## [1] "APPENDAGE DEVELOPMENT"
## 
## $`GO:0048736`$EM2_Formatted_name
## [1] "GO:0048736\n"
## 
## $`GO:0048736`$EM2_Name
## [1] "GO:0048736"
## 
## $`GO:0048736`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048736`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048736`$EM2_pvalue_dataset1
## [1] 4.34e-06
## 
## $`GO:0048736`$EM2_Colouring_dataset1
## [1] 0.9999957
## 
## $`GO:0048736`$EM2_fdr_qvalue_dataset1
## [1] 4.34e-06
## 
## $`GO:0048736`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0044259`
## $`GO:0044259`$name
## [1] "GO:0044259"
## 
## $`GO:0044259`$EM2_GS_DESCR
## [1] "MULTICELLULAR ORGANISMAL MACROMOLECULE METABOLIC PROCESS"
## 
## $`GO:0044259`$EM2_Formatted_name
## [1] "GO:0044259\n"
## 
## $`GO:0044259`$EM2_Name
## [1] "GO:0044259"
## 
## $`GO:0044259`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0044259`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0044259`$EM2_pvalue_dataset1
## [1] 4.98e-24
## 
## $`GO:0044259`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0044259`$EM2_fdr_qvalue_dataset1
## [1] 4.98e-24
## 
## $`GO:0044259`$EM2_gs_size_dataset1
## [1] 35
## 
## 
## $`GO:0072171`
## $`GO:0072171`$name
## [1] "GO:0072171"
## 
## $`GO:0072171`$EM2_GS_DESCR
## [1] "MESONEPHRIC TUBULE MORPHOGENESIS"
## 
## $`GO:0072171`$EM2_Formatted_name
## [1] "GO:0072171\n"
## 
## $`GO:0072171`$EM2_Name
## [1] "GO:0072171"
## 
## $`GO:0072171`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072171`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072171`$EM2_pvalue_dataset1
## [1] 2.49e-06
## 
## $`GO:0072171`$EM2_Colouring_dataset1
## [1] 0.9999975
## 
## $`GO:0072171`$EM2_fdr_qvalue_dataset1
## [1] 2.49e-06
## 
## $`GO:0072171`$EM2_gs_size_dataset1
## [1] 10
## 
## 
## $`GO:0003197`
## $`GO:0003197`$name
## [1] "GO:0003197"
## 
## $`GO:0003197`$EM2_GS_DESCR
## [1] "ENDOCARDIAL CUSHION DEVELOPMENT"
## 
## $`GO:0003197`$EM2_Formatted_name
## [1] "GO:0003197\n"
## 
## $`GO:0003197`$EM2_Name
## [1] "GO:0003197"
## 
## $`GO:0003197`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0003197`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0003197`$EM2_pvalue_dataset1
## [1] 3.62e-07
## 
## $`GO:0003197`$EM2_Colouring_dataset1
## [1] 0.9999996
## 
## $`GO:0003197`$EM2_fdr_qvalue_dataset1
## [1] 3.62e-07
## 
## $`GO:0003197`$EM2_gs_size_dataset1
## [1] 7
## 
## 
## $`GO:0090596`
## $`GO:0090596`$name
## [1] "GO:0090596"
## 
## $`GO:0090596`$EM2_GS_DESCR
## [1] "SENSORY ORGAN MORPHOGENESIS"
## 
## $`GO:0090596`$EM2_Formatted_name
## [1] "GO:0090596\n"
## 
## $`GO:0090596`$EM2_Name
## [1] "GO:0090596"
## 
## $`GO:0090596`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0090596`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0090596`$EM2_pvalue_dataset1
## [1] 9.85e-06
## 
## $`GO:0090596`$EM2_Colouring_dataset1
## [1] 0.9999902
## 
## $`GO:0090596`$EM2_fdr_qvalue_dataset1
## [1] 9.85e-06
## 
## $`GO:0090596`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0050819`
## $`GO:0050819`$name
## [1] "GO:0050819"
## 
## $`GO:0050819`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF COAGULATION"
## 
## $`GO:0050819`$EM2_Formatted_name
## [1] "GO:0050819\n"
## 
## $`GO:0050819`$EM2_Name
## [1] "GO:0050819"
## 
## $`GO:0050819`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050819`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050819`$EM2_pvalue_dataset1
## [1] 5.09e-06
## 
## $`GO:0050819`$EM2_Colouring_dataset1
## [1] 0.9999949
## 
## $`GO:0050819`$EM2_fdr_qvalue_dataset1
## [1] 5.09e-06
## 
## $`GO:0050819`$EM2_gs_size_dataset1
## [1] 8
## 
## 
## $`GO:0050818`
## $`GO:0050818`$name
## [1] "GO:0050818"
## 
## $`GO:0050818`$EM2_GS_DESCR
## [1] "REGULATION OF COAGULATION"
## 
## $`GO:0050818`$EM2_Formatted_name
## [1] "GO:0050818\n"
## 
## $`GO:0050818`$EM2_Name
## [1] "GO:0050818"
## 
## $`GO:0050818`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050818`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050818`$EM2_pvalue_dataset1
## [1] 2.56e-06
## 
## $`GO:0050818`$EM2_Colouring_dataset1
## [1] 0.9999974
## 
## $`GO:0050818`$EM2_fdr_qvalue_dataset1
## [1] 2.56e-06
## 
## $`GO:0050818`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0061037`
## $`GO:0061037`$name
## [1] "GO:0061037"
## 
## $`GO:0061037`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CARTILAGE DEVELOPMENT"
## 
## $`GO:0061037`$EM2_Formatted_name
## [1] "GO:0061037\n"
## 
## $`GO:0061037`$EM2_Name
## [1] "GO:0061037"
## 
## $`GO:0061037`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061037`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061037`$EM2_pvalue_dataset1
## [1] 3.01e-07
## 
## $`GO:0061037`$EM2_Colouring_dataset1
## [1] 0.9999997
## 
## $`GO:0061037`$EM2_fdr_qvalue_dataset1
## [1] 3.01e-07
## 
## $`GO:0061037`$EM2_gs_size_dataset1
## [1] 7
## 
## 
## $`GO:0061035`
## $`GO:0061035`$name
## [1] "GO:0061035"
## 
## $`GO:0061035`$EM2_GS_DESCR
## [1] "REGULATION OF CARTILAGE DEVELOPMENT"
## 
## $`GO:0061035`$EM2_Formatted_name
## [1] "GO:0061035\n"
## 
## $`GO:0061035`$EM2_Name
## [1] "GO:0061035"
## 
## $`GO:0061035`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061035`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061035`$EM2_pvalue_dataset1
## [1] 3.52e-09
## 
## $`GO:0061035`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0061035`$EM2_fdr_qvalue_dataset1
## [1] 3.52e-09
## 
## $`GO:0061035`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0030335`
## $`GO:0030335`$name
## [1] "GO:0030335"
## 
## $`GO:0030335`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF CELL MIGRATION"
## 
## $`GO:0030335`$EM2_Formatted_name
## [1] "GO:0030335\n"
## 
## $`GO:0030335`$EM2_Name
## [1] "GO:0030335"
## 
## $`GO:0030335`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030335`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030335`$EM2_pvalue_dataset1
## [1] 8.77e-16
## 
## $`GO:0030335`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030335`$EM2_fdr_qvalue_dataset1
## [1] 8.77e-16
## 
## $`GO:0030335`$EM2_gs_size_dataset1
## [1] 50
## 
## 
## $`GO:0051216`
## $`GO:0051216`$name
## [1] "GO:0051216"
## 
## $`GO:0051216`$EM2_GS_DESCR
## [1] "CARTILAGE DEVELOPMENT"
## 
## $`GO:0051216`$EM2_Formatted_name
## [1] "GO:0051216\n"
## 
## $`GO:0051216`$EM2_Name
## [1] "GO:0051216"
## 
## $`GO:0051216`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0051216`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0051216`$EM2_pvalue_dataset1
## [1] 2.55e-09
## 
## $`GO:0051216`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0051216`$EM2_fdr_qvalue_dataset1
## [1] 2.55e-09
## 
## $`GO:0051216`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:0030336`
## $`GO:0030336`$name
## [1] "GO:0030336"
## 
## $`GO:0030336`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELL MIGRATION"
## 
## $`GO:0030336`$EM2_Formatted_name
## [1] "GO:0030336\n"
## 
## $`GO:0030336`$EM2_Name
## [1] "GO:0030336"
## 
## $`GO:0030336`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030336`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030336`$EM2_pvalue_dataset1
## [1] 2.27e-08
## 
## $`GO:0030336`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030336`$EM2_fdr_qvalue_dataset1
## [1] 2.27e-08
## 
## $`GO:0030336`$EM2_gs_size_dataset1
## [1] 25
## 
## 
## $`GO:0050920`
## $`GO:0050920`$name
## [1] "GO:0050920"
## 
## $`GO:0050920`$EM2_GS_DESCR
## [1] "REGULATION OF CHEMOTAXIS"
## 
## $`GO:0050920`$EM2_Formatted_name
## [1] "GO:0050920\n"
## 
## $`GO:0050920`$EM2_Name
## [1] "GO:0050920"
## 
## $`GO:0050920`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050920`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050920`$EM2_pvalue_dataset1
## [1] 1.19e-07
## 
## $`GO:0050920`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0050920`$EM2_fdr_qvalue_dataset1
## [1] 1.19e-07
## 
## $`GO:0050920`$EM2_gs_size_dataset1
## [1] 23
## 
## 
## $`GO:0030334`
## $`GO:0030334`$name
## [1] "GO:0030334"
## 
## $`GO:0030334`$EM2_GS_DESCR
## [1] "REGULATION OF CELL MIGRATION"
## 
## $`GO:0030334`$EM2_Formatted_name
## [1] "GO:0030334\n"
## 
## $`GO:0030334`$EM2_Name
## [1] "GO:0030334"
## 
## $`GO:0030334`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030334`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030334`$EM2_pvalue_dataset1
## [1] 2.32e-22
## 
## $`GO:0030334`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030334`$EM2_fdr_qvalue_dataset1
## [1] 2.32e-22
## 
## $`GO:0030334`$EM2_gs_size_dataset1
## [1] 77
## 
## 
## $`GO:0050922`
## $`GO:0050922`$name
## [1] "GO:0050922"
## 
## $`GO:0050922`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CHEMOTAXIS"
## 
## $`GO:0050922`$EM2_Formatted_name
## [1] "GO:0050922\n"
## 
## $`GO:0050922`$EM2_Name
## [1] "GO:0050922"
## 
## $`GO:0050922`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050922`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050922`$EM2_pvalue_dataset1
## [1] 4.87e-06
## 
## $`GO:0050922`$EM2_Colouring_dataset1
## [1] 0.9999951
## 
## $`GO:0050922`$EM2_fdr_qvalue_dataset1
## [1] 4.87e-06
## 
## $`GO:0050922`$EM2_gs_size_dataset1
## [1] 10
## 
## 
## $`GO:0030574`
## $`GO:0030574`$name
## [1] "GO:0030574"
## 
## $`GO:0030574`$EM2_GS_DESCR
## [1] "COLLAGEN CATABOLIC PROCESS"
## 
## $`GO:0030574`$EM2_Formatted_name
## [1] "GO:0030574\n"
## 
## $`GO:0030574`$EM2_Name
## [1] "GO:0030574"
## 
## $`GO:0030574`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030574`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030574`$EM2_pvalue_dataset1
## [1] 1.52e-23
## 
## $`GO:0030574`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030574`$EM2_fdr_qvalue_dataset1
## [1] 1.52e-23
## 
## $`GO:0030574`$EM2_gs_size_dataset1
## [1] 30
## 
## 
## $`REAC:2022870`
## $`REAC:2022870`$name
## [1] "REAC:2022870"
## 
## $`REAC:2022870`$EM2_GS_DESCR
## [1] "CHONDROITIN SULFATE BIOSYNTHESIS"
## 
## $`REAC:2022870`$EM2_Formatted_name
## [1] "REAC:2022870\n"
## 
## $`REAC:2022870`$EM2_Name
## [1] "REAC:2022870"
## 
## $`REAC:2022870`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:2022870`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:2022870`$EM2_pvalue_dataset1
## [1] 1.25e-07
## 
## $`REAC:2022870`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`REAC:2022870`$EM2_fdr_qvalue_dataset1
## [1] 1.25e-07
## 
## $`REAC:2022870`$EM2_gs_size_dataset1
## [1] 8
## 
## 
## $`GO:0072012`
## $`GO:0072012`$name
## [1] "GO:0072012"
## 
## $`GO:0072012`$EM2_GS_DESCR
## [1] "GLOMERULUS VASCULATURE DEVELOPMENT"
## 
## $`GO:0072012`$EM2_Formatted_name
## [1] "GO:0072012\n"
## 
## $`GO:0072012`$EM2_Name
## [1] "GO:0072012"
## 
## $`GO:0072012`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072012`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072012`$EM2_pvalue_dataset1
## [1] 6.25e-07
## 
## $`GO:0072012`$EM2_Colouring_dataset1
## [1] 0.9999994
## 
## $`GO:0072012`$EM2_fdr_qvalue_dataset1
## [1] 6.25e-07
## 
## $`GO:0072012`$EM2_gs_size_dataset1
## [1] 5
## 
## 
## $`GO:0097696`
## $`GO:0097696`$name
## [1] "GO:0097696"
## 
## $`GO:0097696`$EM2_GS_DESCR
## [1] "STAT CASCADE"
## 
## $`GO:0097696`$EM2_Formatted_name
## [1] "GO:0097696\n"
## 
## $`GO:0097696`$EM2_Name
## [1] "GO:0097696"
## 
## $`GO:0097696`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0097696`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0097696`$EM2_pvalue_dataset1
## [1] 9.17e-06
## 
## $`GO:0097696`$EM2_Colouring_dataset1
## [1] 0.9999908
## 
## $`GO:0097696`$EM2_fdr_qvalue_dataset1
## [1] 9.17e-06
## 
## $`GO:0097696`$EM2_gs_size_dataset1
## [1] 21
## 
## 
## $`GO:0072132`
## $`GO:0072132`$name
## [1] "GO:0072132"
## 
## $`GO:0072132`$EM2_GS_DESCR
## [1] "MESENCHYME MORPHOGENESIS"
## 
## $`GO:0072132`$EM2_Formatted_name
## [1] "GO:0072132\n"
## 
## $`GO:0072132`$EM2_Name
## [1] "GO:0072132"
## 
## $`GO:0072132`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072132`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072132`$EM2_pvalue_dataset1
## [1] 8.05e-07
## 
## $`GO:0072132`$EM2_Colouring_dataset1
## [1] 0.9999992
## 
## $`GO:0072132`$EM2_fdr_qvalue_dataset1
## [1] 8.05e-07
## 
## $`GO:0072132`$EM2_gs_size_dataset1
## [1] 7
## 
## 
## $`GO:0009887`
## $`GO:0009887`$name
## [1] "GO:0009887"
## 
## $`GO:0009887`$EM2_GS_DESCR
## [1] "ORGAN MORPHOGENESIS"
## 
## $`GO:0009887`$EM2_Formatted_name
## [1] "GO:0009887\n"
## 
## $`GO:0009887`$EM2_Name
## [1] "GO:0009887"
## 
## $`GO:0009887`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0009887`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0009887`$EM2_pvalue_dataset1
## [1] 6.16e-24
## 
## $`GO:0009887`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0009887`$EM2_fdr_qvalue_dataset1
## [1] 6.16e-24
## 
## $`GO:0009887`$EM2_gs_size_dataset1
## [1] 71
## 
## 
## $`GO:0045216`
## $`GO:0045216`$name
## [1] "GO:0045216"
## 
## $`GO:0045216`$EM2_GS_DESCR
## [1] "CELL-CELL JUNCTION ORGANIZATION"
## 
## $`GO:0045216`$EM2_Formatted_name
## [1] "GO:0045216\n"
## 
## $`GO:0045216`$EM2_Name
## [1] "GO:0045216"
## 
## $`GO:0045216`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045216`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045216`$EM2_pvalue_dataset1
## [1] 1.92e-09
## 
## $`GO:0045216`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0045216`$EM2_fdr_qvalue_dataset1
## [1] 1.92e-09
## 
## $`GO:0045216`$EM2_gs_size_dataset1
## [1] 33
## 
## 
## $`REAC:1474290`
## $`REAC:1474290`$name
## [1] "REAC:1474290"
## 
## $`REAC:1474290`$EM2_GS_DESCR
## [1] "COLLAGEN FORMATION"
## 
## $`REAC:1474290`$EM2_Formatted_name
## [1] "REAC:1474290\n"
## 
## $`REAC:1474290`$EM2_Name
## [1] "REAC:1474290"
## 
## $`REAC:1474290`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1474290`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1474290`$EM2_pvalue_dataset1
## [1] 1.54e-24
## 
## $`REAC:1474290`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:1474290`$EM2_fdr_qvalue_dataset1
## [1] 1.54e-24
## 
## $`REAC:1474290`$EM2_gs_size_dataset1
## [1] 34
## 
## 
## $`GO:0046426`
## $`GO:0046426`$name
## [1] "GO:0046426"
## 
## $`GO:0046426`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF JAK-STAT CASCADE"
## 
## $`GO:0046426`$EM2_Formatted_name
## [1] "GO:0046426\n"
## 
## $`GO:0046426`$EM2_Name
## [1] "GO:0046426"
## 
## $`GO:0046426`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0046426`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0046426`$EM2_pvalue_dataset1
## [1] 6.92e-07
## 
## $`GO:0046426`$EM2_Colouring_dataset1
## [1] 0.9999993
## 
## $`GO:0046426`$EM2_fdr_qvalue_dataset1
## [1] 6.92e-07
## 
## $`GO:0046426`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0046425`
## $`GO:0046425`$name
## [1] "GO:0046425"
## 
## $`GO:0046425`$EM2_GS_DESCR
## [1] "REGULATION OF JAK-STAT CASCADE"
## 
## $`GO:0046425`$EM2_Formatted_name
## [1] "GO:0046425\n"
## 
## $`GO:0046425`$EM2_Name
## [1] "GO:0046425"
## 
## $`GO:0046425`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0046425`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0046425`$EM2_pvalue_dataset1
## [1] 3.79e-06
## 
## $`GO:0046425`$EM2_Colouring_dataset1
## [1] 0.9999962
## 
## $`GO:0046425`$EM2_fdr_qvalue_dataset1
## [1] 3.79e-06
## 
## $`GO:0046425`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0048844`
## $`GO:0048844`$name
## [1] "GO:0048844"
## 
## $`GO:0048844`$EM2_GS_DESCR
## [1] "ARTERY MORPHOGENESIS"
## 
## $`GO:0048844`$EM2_Formatted_name
## [1] "GO:0048844\n"
## 
## $`GO:0048844`$EM2_Name
## [1] "GO:0048844"
## 
## $`GO:0048844`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048844`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048844`$EM2_pvalue_dataset1
## [1] 6.76e-06
## 
## $`GO:0048844`$EM2_Colouring_dataset1
## [1] 0.9999932
## 
## $`GO:0048844`$EM2_fdr_qvalue_dataset1
## [1] 6.76e-06
## 
## $`GO:0048844`$EM2_gs_size_dataset1
## [1] 7
## 
## 
## $`GO:0048729`
## $`GO:0048729`$name
## [1] "GO:0048729"
## 
## $`GO:0048729`$EM2_GS_DESCR
## [1] "TISSUE MORPHOGENESIS"
## 
## $`GO:0048729`$EM2_Formatted_name
## [1] "GO:0048729\n"
## 
## $`GO:0048729`$EM2_Name
## [1] "GO:0048729"
## 
## $`GO:0048729`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048729`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048729`$EM2_pvalue_dataset1
## [1] 1.93e-17
## 
## $`GO:0048729`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0048729`$EM2_fdr_qvalue_dataset1
## [1] 1.93e-17
## 
## $`GO:0048729`$EM2_gs_size_dataset1
## [1] 53
## 
## 
## $`GO:0048041`
## $`GO:0048041`$name
## [1] "GO:0048041"
## 
## $`GO:0048041`$EM2_GS_DESCR
## [1] "FOCAL ADHESION ASSEMBLY"
## 
## $`GO:0048041`$EM2_Formatted_name
## [1] "GO:0048041\n"
## 
## $`GO:0048041`$EM2_Name
## [1] "GO:0048041"
## 
## $`GO:0048041`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048041`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048041`$EM2_pvalue_dataset1
## [1] 1.29e-06
## 
## $`GO:0048041`$EM2_Colouring_dataset1
## [1] 0.9999987
## 
## $`GO:0048041`$EM2_fdr_qvalue_dataset1
## [1] 1.29e-06
## 
## $`GO:0048041`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`GO:0072028`
## $`GO:0072028`$name
## [1] "GO:0072028"
## 
## $`GO:0072028`$EM2_GS_DESCR
## [1] "NEPHRON MORPHOGENESIS"
## 
## $`GO:0072028`$EM2_Formatted_name
## [1] "GO:0072028\n"
## 
## $`GO:0072028`$EM2_Name
## [1] "GO:0072028"
## 
## $`GO:0072028`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072028`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072028`$EM2_pvalue_dataset1
## [1] 1.54e-06
## 
## $`GO:0072028`$EM2_Colouring_dataset1
## [1] 0.9999985
## 
## $`GO:0072028`$EM2_fdr_qvalue_dataset1
## [1] 1.54e-06
## 
## $`GO:0072028`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0016055`
## $`GO:0016055`$name
## [1] "GO:0016055"
## 
## $`GO:0016055`$EM2_GS_DESCR
## [1] "WNT SIGNALING PATHWAY"
## 
## $`GO:0016055`$EM2_Formatted_name
## [1] "GO:0016055\n"
## 
## $`GO:0016055`$EM2_Name
## [1] "GO:0016055"
## 
## $`GO:0016055`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0016055`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0016055`$EM2_pvalue_dataset1
## [1] 1.17e-09
## 
## $`GO:0016055`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0016055`$EM2_fdr_qvalue_dataset1
## [1] 1.17e-09
## 
## $`GO:0016055`$EM2_gs_size_dataset1
## [1] 44
## 
## 
## $`GO:0035239`
## $`GO:0035239`$name
## [1] "GO:0035239"
## 
## $`GO:0035239`$EM2_GS_DESCR
## [1] "TUBE MORPHOGENESIS"
## 
## $`GO:0035239`$EM2_Formatted_name
## [1] "GO:0035239\n"
## 
## $`GO:0035239`$EM2_Name
## [1] "GO:0035239"
## 
## $`GO:0035239`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0035239`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0035239`$EM2_pvalue_dataset1
## [1] 7.01e-11
## 
## $`GO:0035239`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0035239`$EM2_fdr_qvalue_dataset1
## [1] 7.01e-11
## 
## $`GO:0035239`$EM2_gs_size_dataset1
## [1] 30
## 
## 
## $`REAC:3781865`
## $`REAC:3781865`$name
## [1] "REAC:3781865"
## 
## $`REAC:3781865`$EM2_GS_DESCR
## [1] "DISEASES OF GLYCOSYLATION"
## 
## $`REAC:3781865`$EM2_Formatted_name
## [1] "REAC:3781865\n"
## 
## $`REAC:3781865`$EM2_Name
## [1] "REAC:3781865"
## 
## $`REAC:3781865`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:3781865`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:3781865`$EM2_pvalue_dataset1
## [1] 8.25e-12
## 
## $`REAC:3781865`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:3781865`$EM2_fdr_qvalue_dataset1
## [1] 8.25e-12
## 
## $`REAC:3781865`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`GO:0044243`
## $`GO:0044243`$name
## [1] "GO:0044243"
## 
## $`GO:0044243`$EM2_GS_DESCR
## [1] "MULTICELLULAR ORGANISMAL CATABOLIC PROCESS"
## 
## $`GO:0044243`$EM2_Formatted_name
## [1] "GO:0044243\n"
## 
## $`GO:0044243`$EM2_Name
## [1] "GO:0044243"
## 
## $`GO:0044243`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0044243`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0044243`$EM2_pvalue_dataset1
## [1] 2.59e-22
## 
## $`GO:0044243`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0044243`$EM2_fdr_qvalue_dataset1
## [1] 2.59e-22
## 
## $`GO:0044243`$EM2_gs_size_dataset1
## [1] 29
## 
## 
## $`REAC:3000480`
## $`REAC:3000480`$name
## [1] "REAC:3000480"
## 
## $`REAC:3000480`$EM2_GS_DESCR
## [1] "SCAVENGING BY CLASS A RECEPTORS"
## 
## $`REAC:3000480`$EM2_Formatted_name
## [1] "REAC:3000480\n"
## 
## $`REAC:3000480`$EM2_Name
## [1] "REAC:3000480"
## 
## $`REAC:3000480`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:3000480`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:3000480`$EM2_pvalue_dataset1
## [1] 2.31e-06
## 
## $`REAC:3000480`$EM2_Colouring_dataset1
## [1] 0.9999977
## 
## $`REAC:3000480`$EM2_fdr_qvalue_dataset1
## [1] 2.31e-06
## 
## $`REAC:3000480`$EM2_gs_size_dataset1
## [1] 4
## 
## 
## $`GO:0010977`
## $`GO:0010977`$name
## [1] "GO:0010977"
## 
## $`GO:0010977`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF NEURON PROJECTION DEVELOPMENT"
## 
## $`GO:0010977`$EM2_Formatted_name
## [1] "GO:0010977\n"
## 
## $`GO:0010977`$EM2_Name
## [1] "GO:0010977"
## 
## $`GO:0010977`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010977`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010977`$EM2_pvalue_dataset1
## [1] 2.59e-06
## 
## $`GO:0010977`$EM2_Colouring_dataset1
## [1] 0.9999974
## 
## $`GO:0010977`$EM2_fdr_qvalue_dataset1
## [1] 2.59e-06
## 
## $`GO:0010977`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0030900`
## $`GO:0030900`$name
## [1] "GO:0030900"
## 
## $`GO:0030900`$EM2_GS_DESCR
## [1] "FOREBRAIN DEVELOPMENT"
## 
## $`GO:0030900`$EM2_Formatted_name
## [1] "GO:0030900\n"
## 
## $`GO:0030900`$EM2_Name
## [1] "GO:0030900"
## 
## $`GO:0030900`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030900`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030900`$EM2_pvalue_dataset1
## [1] 8.43e-06
## 
## $`GO:0030900`$EM2_Colouring_dataset1
## [1] 0.9999916
## 
## $`GO:0030900`$EM2_fdr_qvalue_dataset1
## [1] 8.43e-06
## 
## $`GO:0030900`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0061138`
## $`GO:0061138`$name
## [1] "GO:0061138"
## 
## $`GO:0061138`$EM2_GS_DESCR
## [1] "MORPHOGENESIS OF A BRANCHING EPITHELIUM"
## 
## $`GO:0061138`$EM2_Formatted_name
## [1] "GO:0061138\n"
## 
## $`GO:0061138`$EM2_Name
## [1] "GO:0061138"
## 
## $`GO:0061138`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061138`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061138`$EM2_pvalue_dataset1
## [1] 2.85e-10
## 
## $`GO:0061138`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0061138`$EM2_fdr_qvalue_dataset1
## [1] 2.85e-10
## 
## $`GO:0061138`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:0090130`
## $`GO:0090130`$name
## [1] "GO:0090130"
## 
## $`GO:0090130`$EM2_GS_DESCR
## [1] "TISSUE MIGRATION"
## 
## $`GO:0090130`$EM2_Formatted_name
## [1] "GO:0090130\n"
## 
## $`GO:0090130`$EM2_Name
## [1] "GO:0090130"
## 
## $`GO:0090130`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0090130`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0090130`$EM2_pvalue_dataset1
## [1] 1.04e-11
## 
## $`GO:0090130`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0090130`$EM2_fdr_qvalue_dataset1
## [1] 1.04e-11
## 
## $`GO:0090130`$EM2_gs_size_dataset1
## [1] 34
## 
## 
## $`GO:0022602`
## $`GO:0022602`$name
## [1] "GO:0022602"
## 
## $`GO:0022602`$EM2_GS_DESCR
## [1] "OVULATION CYCLE PROCESS"
## 
## $`GO:0022602`$EM2_Formatted_name
## [1] "GO:0022602\n"
## 
## $`GO:0022602`$EM2_Name
## [1] "GO:0022602"
## 
## $`GO:0022602`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0022602`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0022602`$EM2_pvalue_dataset1
## [1] 4.21e-06
## 
## $`GO:0022602`$EM2_Colouring_dataset1
## [1] 0.9999958
## 
## $`GO:0022602`$EM2_fdr_qvalue_dataset1
## [1] 4.21e-06
## 
## $`GO:0022602`$EM2_gs_size_dataset1
## [1] 6
## 
## 
## $`GO:0044236`
## $`GO:0044236`$name
## [1] "GO:0044236"
## 
## $`GO:0044236`$EM2_GS_DESCR
## [1] "MULTICELLULAR ORGANISMAL METABOLIC PROCESS"
## 
## $`GO:0044236`$EM2_Formatted_name
## [1] "GO:0044236\n"
## 
## $`GO:0044236`$EM2_Name
## [1] "GO:0044236"
## 
## $`GO:0044236`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0044236`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0044236`$EM2_pvalue_dataset1
## [1] 3.76e-24
## 
## $`GO:0044236`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0044236`$EM2_fdr_qvalue_dataset1
## [1] 3.76e-24
## 
## $`GO:0044236`$EM2_gs_size_dataset1
## [1] 36
## 
## 
## $`GO:0090132`
## $`GO:0090132`$name
## [1] "GO:0090132"
## 
## $`GO:0090132`$EM2_GS_DESCR
## [1] "EPITHELIUM MIGRATION"
## 
## $`GO:0090132`$EM2_Formatted_name
## [1] "GO:0090132\n"
## 
## $`GO:0090132`$EM2_Name
## [1] "GO:0090132"
## 
## $`GO:0090132`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0090132`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0090132`$EM2_pvalue_dataset1
## [1] 1.35e-10
## 
## $`GO:0090132`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0090132`$EM2_fdr_qvalue_dataset1
## [1] 1.35e-10
## 
## $`GO:0090132`$EM2_gs_size_dataset1
## [1] 32
## 
## 
## $`GO:1904893`
## $`GO:1904893`$name
## [1] "GO:1904893"
## 
## $`GO:1904893`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF STAT CASCADE"
## 
## $`GO:1904893`$EM2_Formatted_name
## [1] "GO:1904893\n"
## 
## $`GO:1904893`$EM2_Name
## [1] "GO:1904893"
## 
## $`GO:1904893`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1904893`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1904893`$EM2_pvalue_dataset1
## [1] 6.92e-07
## 
## $`GO:1904893`$EM2_Colouring_dataset1
## [1] 0.9999993
## 
## $`GO:1904893`$EM2_fdr_qvalue_dataset1
## [1] 6.92e-07
## 
## $`GO:1904893`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0060284`
## $`GO:0060284`$name
## [1] "GO:0060284"
## 
## $`GO:0060284`$EM2_GS_DESCR
## [1] "REGULATION OF CELL DEVELOPMENT"
## 
## $`GO:0060284`$EM2_Formatted_name
## [1] "GO:0060284\n"
## 
## $`GO:0060284`$EM2_Name
## [1] "GO:0060284"
## 
## $`GO:0060284`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060284`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060284`$EM2_pvalue_dataset1
## [1] 8.35e-12
## 
## $`GO:0060284`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0060284`$EM2_fdr_qvalue_dataset1
## [1] 8.35e-12
## 
## $`GO:0060284`$EM2_gs_size_dataset1
## [1] 62
## 
## 
## $`GO:0022604`
## $`GO:0022604`$name
## [1] "GO:0022604"
## 
## $`GO:0022604`$EM2_GS_DESCR
## [1] "REGULATION OF CELL MORPHOGENESIS"
## 
## $`GO:0022604`$EM2_Formatted_name
## [1] "GO:0022604\n"
## 
## $`GO:0022604`$EM2_Name
## [1] "GO:0022604"
## 
## $`GO:0022604`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0022604`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0022604`$EM2_pvalue_dataset1
## [1] 9.01e-11
## 
## $`GO:0022604`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0022604`$EM2_fdr_qvalue_dataset1
## [1] 9.01e-11
## 
## $`GO:0022604`$EM2_gs_size_dataset1
## [1] 50
## 
## 
## $`GO:0018108`
## $`GO:0018108`$name
## [1] "GO:0018108"
## 
## $`GO:0018108`$EM2_GS_DESCR
## [1] "PEPTIDYL-TYROSINE PHOSPHORYLATION"
## 
## $`GO:0018108`$EM2_Formatted_name
## [1] "GO:0018108\n"
## 
## $`GO:0018108`$EM2_Name
## [1] "GO:0018108"
## 
## $`GO:0018108`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0018108`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0018108`$EM2_pvalue_dataset1
## [1] 2.92e-09
## 
## $`GO:0018108`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0018108`$EM2_fdr_qvalue_dataset1
## [1] 2.92e-09
## 
## $`GO:0018108`$EM2_gs_size_dataset1
## [1] 34
## 
## 
## $`GO:1904892`
## $`GO:1904892`$name
## [1] "GO:1904892"
## 
## $`GO:1904892`$EM2_GS_DESCR
## [1] "REGULATION OF STAT CASCADE"
## 
## $`GO:1904892`$EM2_Formatted_name
## [1] "GO:1904892\n"
## 
## $`GO:1904892`$EM2_Name
## [1] "GO:1904892"
## 
## $`GO:1904892`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1904892`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1904892`$EM2_pvalue_dataset1
## [1] 3.79e-06
## 
## $`GO:1904892`$EM2_Colouring_dataset1
## [1] 0.9999962
## 
## $`GO:1904892`$EM2_fdr_qvalue_dataset1
## [1] 3.79e-06
## 
## $`GO:1904892`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0030510`
## $`GO:0030510`$name
## [1] "GO:0030510"
## 
## $`GO:0030510`$EM2_GS_DESCR
## [1] "REGULATION OF BMP SIGNALING PATHWAY"
## 
## $`GO:0030510`$EM2_Formatted_name
## [1] "GO:0030510\n"
## 
## $`GO:0030510`$EM2_Name
## [1] "GO:0030510"
## 
## $`GO:0030510`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030510`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030510`$EM2_pvalue_dataset1
## [1] 9.2e-08
## 
## $`GO:0030510`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0030510`$EM2_fdr_qvalue_dataset1
## [1] 9.2e-08
## 
## $`GO:0030510`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`GO:0030199`
## $`GO:0030199`$name
## [1] "GO:0030199"
## 
## $`GO:0030199`$EM2_GS_DESCR
## [1] "COLLAGEN FIBRIL ORGANIZATION"
## 
## $`GO:0030199`$EM2_Formatted_name
## [1] "GO:0030199\n"
## 
## $`GO:0030199`$EM2_Name
## [1] "GO:0030199"
## 
## $`GO:0030199`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030199`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030199`$EM2_pvalue_dataset1
## [1] 9.53e-17
## 
## $`GO:0030199`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030199`$EM2_fdr_qvalue_dataset1
## [1] 9.53e-17
## 
## $`GO:0030199`$EM2_gs_size_dataset1
## [1] 15
## 
## 
## $`GO:0030198`
## $`GO:0030198`$name
## [1] "GO:0030198"
## 
## $`GO:0030198`$EM2_GS_DESCR
## [1] "EXTRACELLULAR MATRIX ORGANIZATION"
## 
## $`GO:0030198`$EM2_Formatted_name
## [1] "GO:0030198\n"
## 
## $`GO:0030198`$EM2_Name
## [1] "GO:0030198"
## 
## $`GO:0030198`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030198`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030198`$EM2_pvalue_dataset1
## [1] 6.62e-63
## 
## $`GO:0030198`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030198`$EM2_fdr_qvalue_dataset1
## [1] 6.62e-63
## 
## $`GO:0030198`$EM2_gs_size_dataset1
## [1] 100
## 
## 
## $`GO:0072078`
## $`GO:0072078`$name
## [1] "GO:0072078"
## 
## $`GO:0072078`$EM2_GS_DESCR
## [1] "NEPHRON TUBULE MORPHOGENESIS"
## 
## $`GO:0072078`$EM2_Formatted_name
## [1] "GO:0072078\n"
## 
## $`GO:0072078`$EM2_Name
## [1] "GO:0072078"
## 
## $`GO:0072078`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072078`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072078`$EM2_pvalue_dataset1
## [1] 8.03e-06
## 
## $`GO:0072078`$EM2_Colouring_dataset1
## [1] 0.999992
## 
## $`GO:0072078`$EM2_fdr_qvalue_dataset1
## [1] 8.03e-06
## 
## $`GO:0072078`$EM2_gs_size_dataset1
## [1] 10
## 
## 
## $`GO:0001658`
## $`GO:0001658`$name
## [1] "GO:0001658"
## 
## $`GO:0001658`$EM2_GS_DESCR
## [1] "BRANCHING INVOLVED IN URETERIC BUD MORPHOGENESIS"
## 
## $`GO:0001658`$EM2_Formatted_name
## [1] "GO:0001658\n"
## 
## $`GO:0001658`$EM2_Name
## [1] "GO:0001658"
## 
## $`GO:0001658`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001658`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001658`$EM2_pvalue_dataset1
## [1] 9.06e-07
## 
## $`GO:0001658`$EM2_Colouring_dataset1
## [1] 0.9999991
## 
## $`GO:0001658`$EM2_fdr_qvalue_dataset1
## [1] 9.06e-07
## 
## $`GO:0001658`$EM2_gs_size_dataset1
## [1] 10
## 
## 
## $`GO:0001657`
## $`GO:0001657`$name
## [1] "GO:0001657"
## 
## $`GO:0001657`$EM2_GS_DESCR
## [1] "URETERIC BUD DEVELOPMENT"
## 
## $`GO:0001657`$EM2_Formatted_name
## [1] "GO:0001657\n"
## 
## $`GO:0001657`$EM2_Name
## [1] "GO:0001657"
## 
## $`GO:0001657`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001657`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001657`$EM2_pvalue_dataset1
## [1] 2.77e-08
## 
## $`GO:0001657`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001657`$EM2_fdr_qvalue_dataset1
## [1] 2.77e-08
## 
## $`GO:0001657`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0001656`
## $`GO:0001656`$name
## [1] "GO:0001656"
## 
## $`GO:0001656`$EM2_GS_DESCR
## [1] "METANEPHROS DEVELOPMENT"
## 
## $`GO:0001656`$EM2_Formatted_name
## [1] "GO:0001656\n"
## 
## $`GO:0001656`$EM2_Name
## [1] "GO:0001656"
## 
## $`GO:0001656`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001656`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001656`$EM2_pvalue_dataset1
## [1] 7.7e-06
## 
## $`GO:0001656`$EM2_Colouring_dataset1
## [1] 0.9999923
## 
## $`GO:0001656`$EM2_fdr_qvalue_dataset1
## [1] 7.7e-06
## 
## $`GO:0001656`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0001655`
## $`GO:0001655`$name
## [1] "GO:0001655"
## 
## $`GO:0001655`$EM2_GS_DESCR
## [1] "UROGENITAL SYSTEM DEVELOPMENT"
## 
## $`GO:0001655`$EM2_Formatted_name
## [1] "GO:0001655\n"
## 
## $`GO:0001655`$EM2_Name
## [1] "GO:0001655"
## 
## $`GO:0001655`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001655`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001655`$EM2_pvalue_dataset1
## [1] 3.1e-11
## 
## $`GO:0001655`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001655`$EM2_fdr_qvalue_dataset1
## [1] 3.1e-11
## 
## $`GO:0001655`$EM2_gs_size_dataset1
## [1] 28
## 
## 
## $`GO:0001654`
## $`GO:0001654`$name
## [1] "GO:0001654"
## 
## $`GO:0001654`$EM2_GS_DESCR
## [1] "EYE DEVELOPMENT"
## 
## $`GO:0001654`$EM2_Formatted_name
## [1] "GO:0001654\n"
## 
## $`GO:0001654`$EM2_Name
## [1] "GO:0001654"
## 
## $`GO:0001654`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001654`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001654`$EM2_pvalue_dataset1
## [1] 5.07e-06
## 
## $`GO:0001654`$EM2_Colouring_dataset1
## [1] 0.9999949
## 
## $`GO:0001654`$EM2_fdr_qvalue_dataset1
## [1] 5.07e-06
## 
## $`GO:0001654`$EM2_gs_size_dataset1
## [1] 22
## 
## 
## $`REAC:2022090`
## $`REAC:2022090`$name
## [1] "REAC:2022090"
## 
## $`REAC:2022090`$EM2_GS_DESCR
## [1] "ASSEMBLY OF COLLAGEN FIBRILS AND OTHER MULTIMERIC STRUCTURES"
## 
## $`REAC:2022090`$EM2_Formatted_name
## [1] "REAC:2022090\n"
## 
## $`REAC:2022090`$EM2_Name
## [1] "REAC:2022090"
## 
## $`REAC:2022090`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:2022090`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:2022090`$EM2_pvalue_dataset1
## [1] 1.52e-20
## 
## $`REAC:2022090`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:2022090`$EM2_fdr_qvalue_dataset1
## [1] 1.52e-20
## 
## $`REAC:2022090`$EM2_gs_size_dataset1
## [1] 25
## 
## 
## $`GO:0030514`
## $`GO:0030514`$name
## [1] "GO:0030514"
## 
## $`GO:0030514`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF BMP SIGNALING PATHWAY"
## 
## $`GO:0030514`$EM2_Formatted_name
## [1] "GO:0030514\n"
## 
## $`GO:0030514`$EM2_Name
## [1] "GO:0030514"
## 
## $`GO:0030514`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030514`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030514`$EM2_pvalue_dataset1
## [1] 2.36e-06
## 
## $`GO:0030514`$EM2_Colouring_dataset1
## [1] 0.9999976
## 
## $`GO:0030514`$EM2_fdr_qvalue_dataset1
## [1] 2.36e-06
## 
## $`GO:0030514`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0007517`
## $`GO:0007517`$name
## [1] "GO:0007517"
## 
## $`GO:0007517`$EM2_GS_DESCR
## [1] "MUSCLE ORGAN DEVELOPMENT"
## 
## $`GO:0007517`$EM2_Formatted_name
## [1] "GO:0007517\n"
## 
## $`GO:0007517`$EM2_Name
## [1] "GO:0007517"
## 
## $`GO:0007517`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007517`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007517`$EM2_pvalue_dataset1
## [1] 5.08e-07
## 
## $`GO:0007517`$EM2_Colouring_dataset1
## [1] 0.9999995
## 
## $`GO:0007517`$EM2_fdr_qvalue_dataset1
## [1] 5.08e-07
## 
## $`GO:0007517`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:0042326`
## $`GO:0042326`$name
## [1] "GO:0042326"
## 
## $`GO:0042326`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF PHOSPHORYLATION"
## 
## $`GO:0042326`$EM2_Formatted_name
## [1] "GO:0042326\n"
## 
## $`GO:0042326`$EM2_Name
## [1] "GO:0042326"
## 
## $`GO:0042326`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0042326`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0042326`$EM2_pvalue_dataset1
## [1] 2.69e-06
## 
## $`GO:0042326`$EM2_Colouring_dataset1
## [1] 0.9999973
## 
## $`GO:0042326`$EM2_fdr_qvalue_dataset1
## [1] 2.69e-06
## 
## $`GO:0042326`$EM2_gs_size_dataset1
## [1] 36
## 
## 
## $`GO:1901654`
## $`GO:1901654`$name
## [1] "GO:1901654"
## 
## $`GO:1901654`$EM2_GS_DESCR
## [1] "RESPONSE TO KETONE"
## 
## $`GO:1901654`$EM2_Formatted_name
## [1] "GO:1901654\n"
## 
## $`GO:1901654`$EM2_Name
## [1] "GO:1901654"
## 
## $`GO:1901654`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1901654`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1901654`$EM2_pvalue_dataset1
## [1] 7.73e-07
## 
## $`GO:1901654`$EM2_Colouring_dataset1
## [1] 0.9999992
## 
## $`GO:1901654`$EM2_fdr_qvalue_dataset1
## [1] 7.73e-07
## 
## $`GO:1901654`$EM2_gs_size_dataset1
## [1] 12
## 
## 
## $`GO:0090288`
## $`GO:0090288`$name
## [1] "GO:0090288"
## 
## $`GO:0090288`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELLULAR RESPONSE TO GROWTH FACTOR STIMULUS"
## 
## $`GO:0090288`$EM2_Formatted_name
## [1] "GO:0090288\n"
## 
## $`GO:0090288`$EM2_Name
## [1] "GO:0090288"
## 
## $`GO:0090288`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0090288`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0090288`$EM2_pvalue_dataset1
## [1] 2.36e-11
## 
## $`GO:0090288`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0090288`$EM2_fdr_qvalue_dataset1
## [1] 2.36e-11
## 
## $`GO:0090288`$EM2_gs_size_dataset1
## [1] 20
## 
## 
## $`GO:1903035`
## $`GO:1903035`$name
## [1] "GO:1903035"
## 
## $`GO:1903035`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF RESPONSE TO WOUNDING"
## 
## $`GO:1903035`$EM2_Formatted_name
## [1] "GO:1903035\n"
## 
## $`GO:1903035`$EM2_Name
## [1] "GO:1903035"
## 
## $`GO:1903035`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1903035`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1903035`$EM2_pvalue_dataset1
## [1] 3.26e-06
## 
## $`GO:1903035`$EM2_Colouring_dataset1
## [1] 0.9999967
## 
## $`GO:1903035`$EM2_fdr_qvalue_dataset1
## [1] 3.26e-06
## 
## $`GO:1903035`$EM2_gs_size_dataset1
## [1] 12
## 
## 
## $`GO:0090287`
## $`GO:0090287`$name
## [1] "GO:0090287"
## 
## $`GO:0090287`$EM2_GS_DESCR
## [1] "REGULATION OF CELLULAR RESPONSE TO GROWTH FACTOR STIMULUS"
## 
## $`GO:0090287`$EM2_Formatted_name
## [1] "GO:0090287\n"
## 
## $`GO:0090287`$EM2_Name
## [1] "GO:0090287"
## 
## $`GO:0090287`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0090287`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0090287`$EM2_pvalue_dataset1
## [1] 5.05e-11
## 
## $`GO:0090287`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0090287`$EM2_fdr_qvalue_dataset1
## [1] 5.05e-11
## 
## $`GO:0090287`$EM2_gs_size_dataset1
## [1] 33
## 
## 
## $`GO:1903034`
## $`GO:1903034`$name
## [1] "GO:1903034"
## 
## $`GO:1903034`$EM2_GS_DESCR
## [1] "REGULATION OF RESPONSE TO WOUNDING"
## 
## $`GO:1903034`$EM2_Formatted_name
## [1] "GO:1903034\n"
## 
## $`GO:1903034`$EM2_Name
## [1] "GO:1903034"
## 
## $`GO:1903034`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1903034`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1903034`$EM2_pvalue_dataset1
## [1] 9.42e-06
## 
## $`GO:1903034`$EM2_Colouring_dataset1
## [1] 0.9999906
## 
## $`GO:1903034`$EM2_fdr_qvalue_dataset1
## [1] 9.42e-06
## 
## $`GO:1903034`$EM2_gs_size_dataset1
## [1] 20
## 
## 
## $`REAC:2129379`
## $`REAC:2129379`$name
## [1] "REAC:2129379"
## 
## $`REAC:2129379`$EM2_GS_DESCR
## [1] "MOLECULES ASSOCIATED WITH ELASTIC FIBRES"
## 
## $`REAC:2129379`$EM2_Formatted_name
## [1] "REAC:2129379\n"
## 
## $`REAC:2129379`$EM2_Name
## [1] "REAC:2129379"
## 
## $`REAC:2129379`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:2129379`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:2129379`$EM2_pvalue_dataset1
## [1] 6.94e-10
## 
## $`REAC:2129379`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:2129379`$EM2_fdr_qvalue_dataset1
## [1] 6.94e-10
## 
## $`REAC:2129379`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0016337`
## $`GO:0016337`$name
## [1] "GO:0016337"
## 
## $`GO:0016337`$EM2_GS_DESCR
## [1] "SINGLE ORGANISMAL CELL-CELL ADHESION"
## 
## $`GO:0016337`$EM2_Formatted_name
## [1] "GO:0016337\n"
## 
## $`GO:0016337`$EM2_Name
## [1] "GO:0016337"
## 
## $`GO:0016337`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0016337`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0016337`$EM2_pvalue_dataset1
## [1] 9.01e-06
## 
## $`GO:0016337`$EM2_Colouring_dataset1
## [1] 0.999991
## 
## $`GO:0016337`$EM2_fdr_qvalue_dataset1
## [1] 9.01e-06
## 
## $`GO:0016337`$EM2_gs_size_dataset1
## [1] 49
## 
## 
## $`GO:0071559`
## $`GO:0071559`$name
## [1] "GO:0071559"
## 
## $`GO:0071559`$EM2_GS_DESCR
## [1] "RESPONSE TO TRANSFORMING GROWTH FACTOR BETA"
## 
## $`GO:0071559`$EM2_Formatted_name
## [1] "GO:0071559\n"
## 
## $`GO:0071559`$EM2_Name
## [1] "GO:0071559"
## 
## $`GO:0071559`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0071559`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0071559`$EM2_pvalue_dataset1
## [1] 3.24e-06
## 
## $`GO:0071559`$EM2_Colouring_dataset1
## [1] 0.9999968
## 
## $`GO:0071559`$EM2_fdr_qvalue_dataset1
## [1] 3.24e-06
## 
## $`GO:0071559`$EM2_gs_size_dataset1
## [1] 26
## 
## 
## $`GO:0010595`
## $`GO:0010595`$name
## [1] "GO:0010595"
## 
## $`GO:0010595`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF ENDOTHELIAL CELL MIGRATION"
## 
## $`GO:0010595`$EM2_Formatted_name
## [1] "GO:0010595\n"
## 
## $`GO:0010595`$EM2_Name
## [1] "GO:0010595"
## 
## $`GO:0010595`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010595`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010595`$EM2_pvalue_dataset1
## [1] 6.31e-08
## 
## $`GO:0010595`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0010595`$EM2_fdr_qvalue_dataset1
## [1] 6.31e-08
## 
## $`GO:0010595`$EM2_gs_size_dataset1
## [1] 15
## 
## 
## $`GO:0034329`
## $`GO:0034329`$name
## [1] "GO:0034329"
## 
## $`GO:0034329`$EM2_GS_DESCR
## [1] "CELL JUNCTION ASSEMBLY"
## 
## $`GO:0034329`$EM2_Formatted_name
## [1] "GO:0034329\n"
## 
## $`GO:0034329`$EM2_Name
## [1] "GO:0034329"
## 
## $`GO:0034329`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0034329`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0034329`$EM2_pvalue_dataset1
## [1] 3.38e-10
## 
## $`GO:0034329`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0034329`$EM2_fdr_qvalue_dataset1
## [1] 3.38e-10
## 
## $`GO:0034329`$EM2_gs_size_dataset1
## [1] 35
## 
## 
## $`GO:0001649`
## $`GO:0001649`$name
## [1] "GO:0001649"
## 
## $`GO:0001649`$EM2_GS_DESCR
## [1] "OSTEOBLAST DIFFERENTIATION"
## 
## $`GO:0001649`$EM2_Formatted_name
## [1] "GO:0001649\n"
## 
## $`GO:0001649`$EM2_Name
## [1] "GO:0001649"
## 
## $`GO:0001649`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001649`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001649`$EM2_pvalue_dataset1
## [1] 4.42e-14
## 
## $`GO:0001649`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001649`$EM2_fdr_qvalue_dataset1
## [1] 4.42e-14
## 
## $`GO:0001649`$EM2_gs_size_dataset1
## [1] 33
## 
## 
## $`GO:0001525`
## $`GO:0001525`$name
## [1] "GO:0001525"
## 
## $`GO:0001525`$EM2_GS_DESCR
## [1] "ANGIOGENESIS"
## 
## $`GO:0001525`$EM2_Formatted_name
## [1] "GO:0001525\n"
## 
## $`GO:0001525`$EM2_Name
## [1] "GO:0001525"
## 
## $`GO:0001525`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001525`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001525`$EM2_pvalue_dataset1
## [1] 9.16e-19
## 
## $`GO:0001525`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001525`$EM2_fdr_qvalue_dataset1
## [1] 9.16e-19
## 
## $`GO:0001525`$EM2_gs_size_dataset1
## [1] 51
## 
## 
## $`GO:0051146`
## $`GO:0051146`$name
## [1] "GO:0051146"
## 
## $`GO:0051146`$EM2_GS_DESCR
## [1] "STRIATED MUSCLE CELL DIFFERENTIATION"
## 
## $`GO:0051146`$EM2_Formatted_name
## [1] "GO:0051146\n"
## 
## $`GO:0051146`$EM2_Name
## [1] "GO:0051146"
## 
## $`GO:0051146`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0051146`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0051146`$EM2_pvalue_dataset1
## [1] 8.28e-06
## 
## $`GO:0051146`$EM2_Colouring_dataset1
## [1] 0.9999917
## 
## $`GO:0051146`$EM2_fdr_qvalue_dataset1
## [1] 8.28e-06
## 
## $`GO:0051146`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0001763`
## $`GO:0001763`$name
## [1] "GO:0001763"
## 
## $`GO:0001763`$EM2_GS_DESCR
## [1] "MORPHOGENESIS OF A BRANCHING STRUCTURE"
## 
## $`GO:0001763`$EM2_Formatted_name
## [1] "GO:0001763\n"
## 
## $`GO:0001763`$EM2_Name
## [1] "GO:0001763"
## 
## $`GO:0001763`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001763`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001763`$EM2_pvalue_dataset1
## [1] 1.96e-10
## 
## $`GO:0001763`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001763`$EM2_fdr_qvalue_dataset1
## [1] 1.96e-10
## 
## $`GO:0001763`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0007507`
## $`GO:0007507`$name
## [1] "GO:0007507"
## 
## $`GO:0007507`$EM2_GS_DESCR
## [1] "HEART DEVELOPMENT"
## 
## $`GO:0007507`$EM2_Formatted_name
## [1] "GO:0007507\n"
## 
## $`GO:0007507`$EM2_Name
## [1] "GO:0007507"
## 
## $`GO:0007507`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007507`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007507`$EM2_pvalue_dataset1
## [1] 1.34e-12
## 
## $`GO:0007507`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0007507`$EM2_fdr_qvalue_dataset1
## [1] 1.34e-12
## 
## $`GO:0007507`$EM2_gs_size_dataset1
## [1] 42
## 
## 
## $`GO:0072088`
## $`GO:0072088`$name
## [1] "GO:0072088"
## 
## $`GO:0072088`$EM2_GS_DESCR
## [1] "NEPHRON EPITHELIUM MORPHOGENESIS"
## 
## $`GO:0072088`$EM2_Formatted_name
## [1] "GO:0072088\n"
## 
## $`GO:0072088`$EM2_Name
## [1] "GO:0072088"
## 
## $`GO:0072088`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072088`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072088`$EM2_pvalue_dataset1
## [1] 1.54e-06
## 
## $`GO:0072088`$EM2_Colouring_dataset1
## [1] 0.9999985
## 
## $`GO:0072088`$EM2_fdr_qvalue_dataset1
## [1] 1.54e-06
## 
## $`GO:0072088`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0040017`
## $`GO:0040017`$name
## [1] "GO:0040017"
## 
## $`GO:0040017`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF LOCOMOTION"
## 
## $`GO:0040017`$EM2_Formatted_name
## [1] "GO:0040017\n"
## 
## $`GO:0040017`$EM2_Name
## [1] "GO:0040017"
## 
## $`GO:0040017`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0040017`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0040017`$EM2_pvalue_dataset1
## [1] 1.6e-16
## 
## $`GO:0040017`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0040017`$EM2_fdr_qvalue_dataset1
## [1] 1.6e-16
## 
## $`GO:0040017`$EM2_gs_size_dataset1
## [1] 53
## 
## 
## $`GO:1901888`
## $`GO:1901888`$name
## [1] "GO:1901888"
## 
## $`GO:1901888`$EM2_GS_DESCR
## [1] "REGULATION OF CELL JUNCTION ASSEMBLY"
## 
## $`GO:1901888`$EM2_Formatted_name
## [1] "GO:1901888\n"
## 
## $`GO:1901888`$EM2_Name
## [1] "GO:1901888"
## 
## $`GO:1901888`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1901888`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1901888`$EM2_pvalue_dataset1
## [1] 1.7e-06
## 
## $`GO:1901888`$EM2_Colouring_dataset1
## [1] 0.9999983
## 
## $`GO:1901888`$EM2_fdr_qvalue_dataset1
## [1] 1.7e-06
## 
## $`GO:1901888`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`GO:0051272`
## $`GO:0051272`$name
## [1] "GO:0051272"
## 
## $`GO:0051272`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF CELLULAR COMPONENT MOVEMENT"
## 
## $`GO:0051272`$EM2_Formatted_name
## [1] "GO:0051272\n"
## 
## $`GO:0051272`$EM2_Name
## [1] "GO:0051272"
## 
## $`GO:0051272`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0051272`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0051272`$EM2_pvalue_dataset1
## [1] 3.24e-16
## 
## $`GO:0051272`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0051272`$EM2_fdr_qvalue_dataset1
## [1] 3.24e-16
## 
## $`GO:0051272`$EM2_gs_size_dataset1
## [1] 52
## 
## 
## $`GO:0051271`
## $`GO:0051271`$name
## [1] "GO:0051271"
## 
## $`GO:0051271`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELLULAR COMPONENT MOVEMENT"
## 
## $`GO:0051271`$EM2_Formatted_name
## [1] "GO:0051271\n"
## 
## $`GO:0051271`$EM2_Name
## [1] "GO:0051271"
## 
## $`GO:0051271`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0051271`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0051271`$EM2_pvalue_dataset1
## [1] 3.47e-11
## 
## $`GO:0051271`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0051271`$EM2_fdr_qvalue_dataset1
## [1] 3.47e-11
## 
## $`GO:0051271`$EM2_gs_size_dataset1
## [1] 32
## 
## 
## $`GO:0002062`
## $`GO:0002062`$name
## [1] "GO:0002062"
## 
## $`GO:0002062`$EM2_GS_DESCR
## [1] "CHONDROCYTE DIFFERENTIATION"
## 
## $`GO:0002062`$EM2_Formatted_name
## [1] "GO:0002062\n"
## 
## $`GO:0002062`$EM2_Name
## [1] "GO:0002062"
## 
## $`GO:0002062`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0002062`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0002062`$EM2_pvalue_dataset1
## [1] 9.35e-11
## 
## $`GO:0002062`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0002062`$EM2_fdr_qvalue_dataset1
## [1] 9.35e-11
## 
## $`GO:0002062`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0008285`
## $`GO:0008285`$name
## [1] "GO:0008285"
## 
## $`GO:0008285`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELL PROLIFERATION"
## 
## $`GO:0008285`$EM2_Formatted_name
## [1] "GO:0008285\n"
## 
## $`GO:0008285`$EM2_Name
## [1] "GO:0008285"
## 
## $`GO:0008285`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0008285`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0008285`$EM2_pvalue_dataset1
## [1] 6.29e-07
## 
## $`GO:0008285`$EM2_Colouring_dataset1
## [1] 0.9999994
## 
## $`GO:0008285`$EM2_fdr_qvalue_dataset1
## [1] 6.29e-07
## 
## $`GO:0008285`$EM2_gs_size_dataset1
## [1] 47
## 
## 
## $`GO:0034330`
## $`GO:0034330`$name
## [1] "GO:0034330"
## 
## $`GO:0034330`$EM2_GS_DESCR
## [1] "CELL JUNCTION ORGANIZATION"
## 
## $`GO:0034330`$EM2_Formatted_name
## [1] "GO:0034330\n"
## 
## $`GO:0034330`$EM2_Name
## [1] "GO:0034330"
## 
## $`GO:0034330`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0034330`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0034330`$EM2_pvalue_dataset1
## [1] 3.29e-11
## 
## $`GO:0034330`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0034330`$EM2_fdr_qvalue_dataset1
## [1] 3.29e-11
## 
## $`GO:0034330`$EM2_gs_size_dataset1
## [1] 39
## 
## 
## $`GO:0040013`
## $`GO:0040013`$name
## [1] "GO:0040013"
## 
## $`GO:0040013`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF LOCOMOTION"
## 
## $`GO:0040013`$EM2_Formatted_name
## [1] "GO:0040013\n"
## 
## $`GO:0040013`$EM2_Name
## [1] "GO:0040013"
## 
## $`GO:0040013`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0040013`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0040013`$EM2_pvalue_dataset1
## [1] 2.23e-10
## 
## $`GO:0040013`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0040013`$EM2_fdr_qvalue_dataset1
## [1] 2.23e-10
## 
## $`GO:0040013`$EM2_gs_size_dataset1
## [1] 30
## 
## 
## $`REAC:114608`
## $`REAC:114608`$name
## [1] "REAC:114608"
## 
## $`REAC:114608`$EM2_GS_DESCR
## [1] "PLATELET DEGRANULATION "
## 
## $`REAC:114608`$EM2_Formatted_name
## [1] "REAC:114608\n"
## 
## $`REAC:114608`$EM2_Name
## [1] "REAC:114608"
## 
## $`REAC:114608`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:114608`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:114608`$EM2_pvalue_dataset1
## [1] 5.28e-08
## 
## $`REAC:114608`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`REAC:114608`$EM2_fdr_qvalue_dataset1
## [1] 5.28e-08
## 
## $`REAC:114608`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`REAC:2243919`
## $`REAC:2243919`$name
## [1] "REAC:2243919"
## 
## $`REAC:2243919`$EM2_GS_DESCR
## [1] "CROSSLINKING OF COLLAGEN FIBRILS"
## 
## $`REAC:2243919`$EM2_Formatted_name
## [1] "REAC:2243919\n"
## 
## $`REAC:2243919`$EM2_Name
## [1] "REAC:2243919"
## 
## $`REAC:2243919`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:2243919`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:2243919`$EM2_pvalue_dataset1
## [1] 1.51e-06
## 
## $`REAC:2243919`$EM2_Colouring_dataset1
## [1] 0.9999985
## 
## $`REAC:2243919`$EM2_fdr_qvalue_dataset1
## [1] 1.51e-06
## 
## $`REAC:2243919`$EM2_gs_size_dataset1
## [1] 5
## 
## 
## $`GO:0034333`
## $`GO:0034333`$name
## [1] "GO:0034333"
## 
## $`GO:0034333`$EM2_GS_DESCR
## [1] "ADHERENS JUNCTION ASSEMBLY"
## 
## $`GO:0034333`$EM2_Formatted_name
## [1] "GO:0034333\n"
## 
## $`GO:0034333`$EM2_Name
## [1] "GO:0034333"
## 
## $`GO:0034333`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0034333`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0034333`$EM2_pvalue_dataset1
## [1] 6.03e-06
## 
## $`GO:0034333`$EM2_Colouring_dataset1
## [1] 0.999994
## 
## $`GO:0034333`$EM2_fdr_qvalue_dataset1
## [1] 6.03e-06
## 
## $`GO:0034333`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`KEGG:05200`
## $`KEGG:05200`$name
## [1] "KEGG:05200"
## 
## $`KEGG:05200`$EM2_GS_DESCR
## [1] "PATHWAYS IN CANCER"
## 
## $`KEGG:05200`$EM2_Formatted_name
## [1] "KEGG:05200\n"
## 
## $`KEGG:05200`$EM2_Name
## [1] "KEGG:05200"
## 
## $`KEGG:05200`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:05200`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:05200`$EM2_pvalue_dataset1
## [1] 3.6e-08
## 
## $`KEGG:05200`$EM2_Colouring_dataset1
## [1] 1
## 
## $`KEGG:05200`$EM2_fdr_qvalue_dataset1
## [1] 3.6e-08
## 
## $`KEGG:05200`$EM2_gs_size_dataset1
## [1] 46
## 
## 
## $`KEGG:04350`
## $`KEGG:04350`$name
## [1] "KEGG:04350"
## 
## $`KEGG:04350`$EM2_GS_DESCR
## [1] "TGF-BETA SIGNALING PATHWAY"
## 
## $`KEGG:04350`$EM2_Formatted_name
## [1] "KEGG:04350\n"
## 
## $`KEGG:04350`$EM2_Name
## [1] "KEGG:04350"
## 
## $`KEGG:04350`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:04350`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:04350`$EM2_pvalue_dataset1
## [1] 8.41e-07
## 
## $`KEGG:04350`$EM2_Colouring_dataset1
## [1] 0.9999992
## 
## $`KEGG:04350`$EM2_fdr_qvalue_dataset1
## [1] 8.41e-07
## 
## $`KEGG:04350`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0032835`
## $`GO:0032835`$name
## [1] "GO:0032835"
## 
## $`GO:0032835`$EM2_GS_DESCR
## [1] "GLOMERULUS DEVELOPMENT"
## 
## $`GO:0032835`$EM2_Formatted_name
## [1] "GO:0032835\n"
## 
## $`GO:0032835`$EM2_Name
## [1] "GO:0032835"
## 
## $`GO:0032835`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0032835`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0032835`$EM2_pvalue_dataset1
## [1] 2.13e-06
## 
## $`GO:0032835`$EM2_Colouring_dataset1
## [1] 0.9999979
## 
## $`GO:0032835`$EM2_fdr_qvalue_dataset1
## [1] 2.13e-06
## 
## $`GO:0032835`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`REAC:419037`
## $`REAC:419037`$name
## [1] "REAC:419037"
## 
## $`REAC:419037`$EM2_GS_DESCR
## [1] "NCAM1 INTERACTIONS"
## 
## $`REAC:419037`$EM2_Formatted_name
## [1] "REAC:419037\n"
## 
## $`REAC:419037`$EM2_Name
## [1] "REAC:419037"
## 
## $`REAC:419037`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:419037`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:419037`$EM2_pvalue_dataset1
## [1] 1.27e-06
## 
## $`REAC:419037`$EM2_Colouring_dataset1
## [1] 0.9999987
## 
## $`REAC:419037`$EM2_fdr_qvalue_dataset1
## [1] 1.27e-06
## 
## $`REAC:419037`$EM2_gs_size_dataset1
## [1] 12
## 
## 
## $`REAC:3000178`
## $`REAC:3000178`$name
## [1] "REAC:3000178"
## 
## $`REAC:3000178`$EM2_GS_DESCR
## [1] "ECM PROTEOGLYCANS"
## 
## $`REAC:3000178`$EM2_Formatted_name
## [1] "REAC:3000178\n"
## 
## $`REAC:3000178`$EM2_Name
## [1] "REAC:3000178"
## 
## $`REAC:3000178`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:3000178`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:3000178`$EM2_pvalue_dataset1
## [1] 5.55e-11
## 
## $`REAC:3000178`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:3000178`$EM2_fdr_qvalue_dataset1
## [1] 5.55e-11
## 
## $`REAC:3000178`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0007423`
## $`GO:0007423`$name
## [1] "GO:0007423"
## 
## $`GO:0007423`$EM2_GS_DESCR
## [1] "SENSORY ORGAN DEVELOPMENT"
## 
## $`GO:0007423`$EM2_Formatted_name
## [1] "GO:0007423\n"
## 
## $`GO:0007423`$EM2_Name
## [1] "GO:0007423"
## 
## $`GO:0007423`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007423`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007423`$EM2_pvalue_dataset1
## [1] 3.08e-06
## 
## $`GO:0007423`$EM2_Colouring_dataset1
## [1] 0.9999969
## 
## $`GO:0007423`$EM2_fdr_qvalue_dataset1
## [1] 3.08e-06
## 
## $`GO:0007423`$EM2_gs_size_dataset1
## [1] 26
## 
## 
## $`GO:0040007`
## $`GO:0040007`$name
## [1] "GO:0040007"
## 
## $`GO:0040007`$EM2_GS_DESCR
## [1] "GROWTH"
## 
## $`GO:0040007`$EM2_Formatted_name
## [1] "GO:0040007\n"
## 
## $`GO:0040007`$EM2_Name
## [1] "GO:0040007"
## 
## $`GO:0040007`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0040007`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0040007`$EM2_pvalue_dataset1
## [1] 9.51e-07
## 
## $`GO:0040007`$EM2_Colouring_dataset1
## [1] 0.999999
## 
## $`GO:0040007`$EM2_fdr_qvalue_dataset1
## [1] 9.51e-07
## 
## $`GO:0040007`$EM2_gs_size_dataset1
## [1] 52
## 
## 
## $`KEGG:05205`
## $`KEGG:05205`$name
## [1] "KEGG:05205"
## 
## $`KEGG:05205`$EM2_GS_DESCR
## [1] "PROTEOGLYCANS IN CANCER"
## 
## $`KEGG:05205`$EM2_Formatted_name
## [1] "KEGG:05205\n"
## 
## $`KEGG:05205`$EM2_Name
## [1] "KEGG:05205"
## 
## $`KEGG:05205`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:05205`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:05205`$EM2_pvalue_dataset1
## [1] 5.08e-10
## 
## $`KEGG:05205`$EM2_Colouring_dataset1
## [1] 1
## 
## $`KEGG:05205`$EM2_fdr_qvalue_dataset1
## [1] 5.08e-10
## 
## $`KEGG:05205`$EM2_gs_size_dataset1
## [1] 33
## 
## 
## $`GO:0061041`
## $`GO:0061041`$name
## [1] "GO:0061041"
## 
## $`GO:0061041`$EM2_GS_DESCR
## [1] "REGULATION OF WOUND HEALING"
## 
## $`GO:0061041`$EM2_Formatted_name
## [1] "GO:0061041\n"
## 
## $`GO:0061041`$EM2_Name
## [1] "GO:0061041"
## 
## $`GO:0061041`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061041`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061041`$EM2_pvalue_dataset1
## [1] 1.52e-06
## 
## $`GO:0061041`$EM2_Colouring_dataset1
## [1] 0.9999985
## 
## $`GO:0061041`$EM2_fdr_qvalue_dataset1
## [1] 1.52e-06
## 
## $`GO:0061041`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0045936`
## $`GO:0045936`$name
## [1] "GO:0045936"
## 
## $`GO:0045936`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF PHOSPHATE METABOLIC PROCESS"
## 
## $`GO:0045936`$EM2_Formatted_name
## [1] "GO:0045936\n"
## 
## $`GO:0045936`$EM2_Name
## [1] "GO:0045936"
## 
## $`GO:0045936`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045936`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045936`$EM2_pvalue_dataset1
## [1] 4.6e-06
## 
## $`GO:0045936`$EM2_Colouring_dataset1
## [1] 0.9999954
## 
## $`GO:0045936`$EM2_fdr_qvalue_dataset1
## [1] 4.6e-06
## 
## $`GO:0045936`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:0060993`
## $`GO:0060993`$name
## [1] "GO:0060993"
## 
## $`GO:0060993`$EM2_GS_DESCR
## [1] "KIDNEY MORPHOGENESIS"
## 
## $`GO:0060993`$EM2_Formatted_name
## [1] "GO:0060993\n"
## 
## $`GO:0060993`$EM2_Name
## [1] "GO:0060993"
## 
## $`GO:0060993`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060993`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060993`$EM2_pvalue_dataset1
## [1] 1.75e-07
## 
## $`GO:0060993`$EM2_Colouring_dataset1
## [1] 0.9999998
## 
## $`GO:0060993`$EM2_fdr_qvalue_dataset1
## [1] 1.75e-07
## 
## $`GO:0060993`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0061045`
## $`GO:0061045`$name
## [1] "GO:0061045"
## 
## $`GO:0061045`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF WOUND HEALING"
## 
## $`GO:0061045`$EM2_Formatted_name
## [1] "GO:0061045\n"
## 
## $`GO:0061045`$EM2_Name
## [1] "GO:0061045"
## 
## $`GO:0061045`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061045`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061045`$EM2_pvalue_dataset1
## [1] 1.05e-06
## 
## $`GO:0061045`$EM2_Colouring_dataset1
## [1] 0.999999
## 
## $`GO:0061045`$EM2_fdr_qvalue_dataset1
## [1] 1.05e-06
## 
## $`GO:0061045`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0032963`
## $`GO:0032963`$name
## [1] "GO:0032963"
## 
## $`GO:0032963`$EM2_GS_DESCR
## [1] "COLLAGEN METABOLIC PROCESS"
## 
## $`GO:0032963`$EM2_Formatted_name
## [1] "GO:0032963\n"
## 
## $`GO:0032963`$EM2_Name
## [1] "GO:0032963"
## 
## $`GO:0032963`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0032963`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0032963`$EM2_pvalue_dataset1
## [1] 6.2e-25
## 
## $`GO:0032963`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0032963`$EM2_fdr_qvalue_dataset1
## [1] 6.2e-25
## 
## $`GO:0032963`$EM2_gs_size_dataset1
## [1] 35
## 
## 
## $`REAC:5173105`
## $`REAC:5173105`$name
## [1] "REAC:5173105"
## 
## $`REAC:5173105`$EM2_GS_DESCR
## [1] "O-LINKED GLYCOSYLATION"
## 
## $`REAC:5173105`$EM2_Formatted_name
## [1] "REAC:5173105\n"
## 
## $`REAC:5173105`$EM2_Name
## [1] "REAC:5173105"
## 
## $`REAC:5173105`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:5173105`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:5173105`$EM2_pvalue_dataset1
## [1] 1.51e-09
## 
## $`REAC:5173105`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:5173105`$EM2_fdr_qvalue_dataset1
## [1] 1.51e-09
## 
## $`REAC:5173105`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0032964`
## $`GO:0032964`$name
## [1] "GO:0032964"
## 
## $`GO:0032964`$EM2_GS_DESCR
## [1] "COLLAGEN BIOSYNTHETIC PROCESS"
## 
## $`GO:0032964`$EM2_Formatted_name
## [1] "GO:0032964\n"
## 
## $`GO:0032964`$EM2_Name
## [1] "GO:0032964"
## 
## $`GO:0032964`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0032964`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0032964`$EM2_pvalue_dataset1
## [1] 6.51e-06
## 
## $`GO:0032964`$EM2_Colouring_dataset1
## [1] 0.9999935
## 
## $`GO:0032964`$EM2_fdr_qvalue_dataset1
## [1] 6.51e-06
## 
## $`GO:0032964`$EM2_gs_size_dataset1
## [1] 4
## 
## 
## $`GO:0010810`
## $`GO:0010810`$name
## [1] "GO:0010810"
## 
## $`GO:0010810`$EM2_GS_DESCR
## [1] "REGULATION OF CELL-SUBSTRATE ADHESION"
## 
## $`GO:0010810`$EM2_Formatted_name
## [1] "GO:0010810\n"
## 
## $`GO:0010810`$EM2_Name
## [1] "GO:0010810"
## 
## $`GO:0010810`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010810`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010810`$EM2_pvalue_dataset1
## [1] 7.54e-08
## 
## $`GO:0010810`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0010810`$EM2_fdr_qvalue_dataset1
## [1] 7.54e-08
## 
## $`GO:0010810`$EM2_gs_size_dataset1
## [1] 22
## 
## 
## $`REAC:4420332`
## $`REAC:4420332`$name
## [1] "REAC:4420332"
## 
## $`REAC:4420332`$EM2_GS_DESCR
## [1] "DEFECTIVE B3GALT6 CAUSES EDSP2 AND SEMDJL1"
## 
## $`REAC:4420332`$EM2_Formatted_name
## [1] "REAC:4420332\n"
## 
## $`REAC:4420332`$EM2_Name
## [1] "REAC:4420332"
## 
## $`REAC:4420332`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:4420332`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:4420332`$EM2_pvalue_dataset1
## [1] 7.08e-09
## 
## $`REAC:4420332`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:4420332`$EM2_fdr_qvalue_dataset1
## [1] 7.08e-09
## 
## $`REAC:4420332`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0061061`
## $`GO:0061061`$name
## [1] "GO:0061061"
## 
## $`GO:0061061`$EM2_GS_DESCR
## [1] "MUSCLE STRUCTURE DEVELOPMENT"
## 
## $`GO:0061061`$EM2_Formatted_name
## [1] "GO:0061061\n"
## 
## $`GO:0061061`$EM2_Name
## [1] "GO:0061061"
## 
## $`GO:0061061`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061061`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061061`$EM2_pvalue_dataset1
## [1] 1.08e-08
## 
## $`GO:0061061`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0061061`$EM2_fdr_qvalue_dataset1
## [1] 1.08e-08
## 
## $`GO:0061061`$EM2_gs_size_dataset1
## [1] 41
## 
## 
## $`GO:0048762`
## $`GO:0048762`$name
## [1] "GO:0048762"
## 
## $`GO:0048762`$EM2_GS_DESCR
## [1] "MESENCHYMAL CELL DIFFERENTIATION"
## 
## $`GO:0048762`$EM2_Formatted_name
## [1] "GO:0048762\n"
## 
## $`GO:0048762`$EM2_Name
## [1] "GO:0048762"
## 
## $`GO:0048762`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048762`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048762`$EM2_pvalue_dataset1
## [1] 8.57e-14
## 
## $`GO:0048762`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0048762`$EM2_fdr_qvalue_dataset1
## [1] 8.57e-14
## 
## $`GO:0048762`$EM2_gs_size_dataset1
## [1] 33
## 
## 
## $`GO:0071773`
## $`GO:0071773`$name
## [1] "GO:0071773"
## 
## $`GO:0071773`$EM2_GS_DESCR
## [1] "CELLULAR RESPONSE TO BMP STIMULUS"
## 
## $`GO:0071773`$EM2_Formatted_name
## [1] "GO:0071773\n"
## 
## $`GO:0071773`$EM2_Name
## [1] "GO:0071773"
## 
## $`GO:0071773`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0071773`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0071773`$EM2_pvalue_dataset1
## [1] 4.73e-10
## 
## $`GO:0071773`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0071773`$EM2_fdr_qvalue_dataset1
## [1] 4.73e-10
## 
## $`GO:0071773`$EM2_gs_size_dataset1
## [1] 24
## 
## 
## $`GO:0001667`
## $`GO:0001667`$name
## [1] "GO:0001667"
## 
## $`GO:0001667`$EM2_GS_DESCR
## [1] "AMEBOIDAL-TYPE CELL MIGRATION"
## 
## $`GO:0001667`$EM2_Formatted_name
## [1] "GO:0001667\n"
## 
## $`GO:0001667`$EM2_Name
## [1] "GO:0001667"
## 
## $`GO:0001667`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001667`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001667`$EM2_pvalue_dataset1
## [1] 1.95e-11
## 
## $`GO:0001667`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001667`$EM2_fdr_qvalue_dataset1
## [1] 1.95e-11
## 
## $`GO:0001667`$EM2_gs_size_dataset1
## [1] 38
## 
## 
## $`GO:0071772`
## $`GO:0071772`$name
## [1] "GO:0071772"
## 
## $`GO:0071772`$EM2_GS_DESCR
## [1] "RESPONSE TO BMP"
## 
## $`GO:0071772`$EM2_Formatted_name
## [1] "GO:0071772\n"
## 
## $`GO:0071772`$EM2_Name
## [1] "GO:0071772"
## 
## $`GO:0071772`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0071772`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0071772`$EM2_pvalue_dataset1
## [1] 4.73e-10
## 
## $`GO:0071772`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0071772`$EM2_fdr_qvalue_dataset1
## [1] 4.73e-10
## 
## $`GO:0071772`$EM2_gs_size_dataset1
## [1] 24
## 
## 
## $`REAC:3560783`
## $`REAC:3560783`$name
## [1] "REAC:3560783"
## 
## $`REAC:3560783`$EM2_GS_DESCR
## [1] "DEFECTIVE B4GALT7 CAUSES EDS, PROGEROID TYPE"
## 
## $`REAC:3560783`$EM2_Formatted_name
## [1] "REAC:3560783\n"
## 
## $`REAC:3560783`$EM2_Name
## [1] "REAC:3560783"
## 
## $`REAC:3560783`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:3560783`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:3560783`$EM2_pvalue_dataset1
## [1] 7.08e-09
## 
## $`REAC:3560783`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:3560783`$EM2_fdr_qvalue_dataset1
## [1] 7.08e-09
## 
## $`REAC:3560783`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`REAC:3560782`
## $`REAC:3560782`$name
## [1] "REAC:3560782"
## 
## $`REAC:3560782`$EM2_GS_DESCR
## [1] "DISEASES ASSOCIATED WITH GLYCOSAMINOGLYCAN METABOLISM"
## 
## $`REAC:3560782`$EM2_Formatted_name
## [1] "REAC:3560782\n"
## 
## $`REAC:3560782`$EM2_Name
## [1] "REAC:3560782"
## 
## $`REAC:3560782`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:3560782`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:3560782`$EM2_pvalue_dataset1
## [1] 8.25e-12
## 
## $`REAC:3560782`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:3560782`$EM2_fdr_qvalue_dataset1
## [1] 8.25e-12
## 
## $`REAC:3560782`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`REAC:1793185`
## $`REAC:1793185`$name
## [1] "REAC:1793185"
## 
## $`REAC:1793185`$EM2_GS_DESCR
## [1] "CHONDROITIN SULFATE/DERMATAN SULFATE METABOLISM"
## 
## $`REAC:1793185`$EM2_Formatted_name
## [1] "REAC:1793185\n"
## 
## $`REAC:1793185`$EM2_Name
## [1] "REAC:1793185"
## 
## $`REAC:1793185`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1793185`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1793185`$EM2_pvalue_dataset1
## [1] 2.97e-11
## 
## $`REAC:1793185`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:1793185`$EM2_fdr_qvalue_dataset1
## [1] 2.97e-11
## 
## $`REAC:1793185`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:0072073`
## $`GO:0072073`$name
## [1] "GO:0072073"
## 
## $`GO:0072073`$EM2_GS_DESCR
## [1] "KIDNEY EPITHELIUM DEVELOPMENT"
## 
## $`GO:0072073`$EM2_Formatted_name
## [1] "GO:0072073\n"
## 
## $`GO:0072073`$EM2_Name
## [1] "GO:0072073"
## 
## $`GO:0072073`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072073`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072073`$EM2_pvalue_dataset1
## [1] 6.71e-08
## 
## $`GO:0072073`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0072073`$EM2_fdr_qvalue_dataset1
## [1] 6.71e-08
## 
## $`GO:0072073`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0048754`
## $`GO:0048754`$name
## [1] "GO:0048754"
## 
## $`GO:0048754`$EM2_GS_DESCR
## [1] "BRANCHING MORPHOGENESIS OF AN EPITHELIAL TUBE"
## 
## $`GO:0048754`$EM2_Formatted_name
## [1] "GO:0048754\n"
## 
## $`GO:0048754`$EM2_Name
## [1] "GO:0048754"
## 
## $`GO:0048754`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048754`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048754`$EM2_pvalue_dataset1
## [1] 1.05e-09
## 
## $`GO:0048754`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0048754`$EM2_fdr_qvalue_dataset1
## [1] 1.05e-09
## 
## $`GO:0048754`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`REAC:1630316`
## $`REAC:1630316`$name
## [1] "REAC:1630316"
## 
## $`REAC:1630316`$EM2_GS_DESCR
## [1] "GLYCOSAMINOGLYCAN METABOLISM"
## 
## $`REAC:1630316`$EM2_Formatted_name
## [1] "REAC:1630316\n"
## 
## $`REAC:1630316`$EM2_Name
## [1] "REAC:1630316"
## 
## $`REAC:1630316`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1630316`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1630316`$EM2_pvalue_dataset1
## [1] 1.31e-11
## 
## $`REAC:1630316`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:1630316`$EM2_fdr_qvalue_dataset1
## [1] 1.31e-11
## 
## $`REAC:1630316`$EM2_gs_size_dataset1
## [1] 29
## 
## 
## $`GO:0048514`
## $`GO:0048514`$name
## [1] "GO:0048514"
## 
## $`GO:0048514`$EM2_GS_DESCR
## [1] "BLOOD VESSEL MORPHOGENESIS"
## 
## $`GO:0048514`$EM2_Formatted_name
## [1] "GO:0048514\n"
## 
## $`GO:0048514`$EM2_Name
## [1] "GO:0048514"
## 
## $`GO:0048514`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048514`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048514`$EM2_pvalue_dataset1
## [1] 8.71e-22
## 
## $`GO:0048514`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0048514`$EM2_fdr_qvalue_dataset1
## [1] 8.71e-22
## 
## $`GO:0048514`$EM2_gs_size_dataset1
## [1] 59
## 
## 
## $`REAC:1474244`
## $`REAC:1474244`$name
## [1] "REAC:1474244"
## 
## $`REAC:1474244`$EM2_GS_DESCR
## [1] "EXTRACELLULAR MATRIX ORGANIZATION"
## 
## $`REAC:1474244`$EM2_Formatted_name
## [1] "REAC:1474244\n"
## 
## $`REAC:1474244`$EM2_Name
## [1] "REAC:1474244"
## 
## $`REAC:1474244`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1474244`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1474244`$EM2_pvalue_dataset1
## [1] 9.81e-56
## 
## $`REAC:1474244`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:1474244`$EM2_fdr_qvalue_dataset1
## [1] 9.81e-56
## 
## $`REAC:1474244`$EM2_gs_size_dataset1
## [1] 85
## 
## 
## $`GO:0014065`
## $`GO:0014065`$name
## [1] "GO:0014065"
## 
## $`GO:0014065`$EM2_GS_DESCR
## [1] "PHOSPHATIDYLINOSITOL 3-KINASE SIGNALING"
## 
## $`GO:0014065`$EM2_Formatted_name
## [1] "GO:0014065\n"
## 
## $`GO:0014065`$EM2_Name
## [1] "GO:0014065"
## 
## $`GO:0014065`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0014065`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0014065`$EM2_pvalue_dataset1
## [1] 4.78e-06
## 
## $`GO:0014065`$EM2_Colouring_dataset1
## [1] 0.9999952
## 
## $`GO:0014065`$EM2_fdr_qvalue_dataset1
## [1] 4.78e-06
## 
## $`GO:0014065`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0014066`
## $`GO:0014066`$name
## [1] "GO:0014066"
## 
## $`GO:0014066`$EM2_GS_DESCR
## [1] "REGULATION OF PHOSPHATIDYLINOSITOL 3-KINASE SIGNALING"
## 
## $`GO:0014066`$EM2_Formatted_name
## [1] "GO:0014066\n"
## 
## $`GO:0014066`$EM2_Name
## [1] "GO:0014066"
## 
## $`GO:0014066`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0014066`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0014066`$EM2_pvalue_dataset1
## [1] 1.61e-07
## 
## $`GO:0014066`$EM2_Colouring_dataset1
## [1] 0.9999998
## 
## $`GO:0014066`$EM2_fdr_qvalue_dataset1
## [1] 1.61e-07
## 
## $`GO:0014066`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0014068`
## $`GO:0014068`$name
## [1] "GO:0014068"
## 
## $`GO:0014068`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF PHOSPHATIDYLINOSITOL 3-KINASE SIGNALING"
## 
## $`GO:0014068`$EM2_Formatted_name
## [1] "GO:0014068\n"
## 
## $`GO:0014068`$EM2_Name
## [1] "GO:0014068"
## 
## $`GO:0014068`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0014068`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0014068`$EM2_pvalue_dataset1
## [1] 4.55e-08
## 
## $`GO:0014068`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0014068`$EM2_fdr_qvalue_dataset1
## [1] 4.55e-08
## 
## $`GO:0014068`$EM2_gs_size_dataset1
## [1] 15
## 
## 
## $`GO:0045926`
## $`GO:0045926`$name
## [1] "GO:0045926"
## 
## $`GO:0045926`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF GROWTH"
## 
## $`GO:0045926`$EM2_Formatted_name
## [1] "GO:0045926\n"
## 
## $`GO:0045926`$EM2_Name
## [1] "GO:0045926"
## 
## $`GO:0045926`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045926`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045926`$EM2_pvalue_dataset1
## [1] 5.18e-06
## 
## $`GO:0045926`$EM2_Colouring_dataset1
## [1] 0.9999948
## 
## $`GO:0045926`$EM2_fdr_qvalue_dataset1
## [1] 5.18e-06
## 
## $`GO:0045926`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0030036`
## $`GO:0030036`$name
## [1] "GO:0030036"
## 
## $`GO:0030036`$EM2_GS_DESCR
## [1] "ACTIN CYTOSKELETON ORGANIZATION"
## 
## $`GO:0030036`$EM2_Formatted_name
## [1] "GO:0030036\n"
## 
## $`GO:0030036`$EM2_Name
## [1] "GO:0030036"
## 
## $`GO:0030036`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030036`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030036`$EM2_pvalue_dataset1
## [1] 4.97e-07
## 
## $`GO:0030036`$EM2_Colouring_dataset1
## [1] 0.9999995
## 
## $`GO:0030036`$EM2_fdr_qvalue_dataset1
## [1] 4.97e-07
## 
## $`GO:0030036`$EM2_gs_size_dataset1
## [1] 47
## 
## 
## $`GO:0030278`
## $`GO:0030278`$name
## [1] "GO:0030278"
## 
## $`GO:0030278`$EM2_GS_DESCR
## [1] "REGULATION OF OSSIFICATION"
## 
## $`GO:0030278`$EM2_Formatted_name
## [1] "GO:0030278\n"
## 
## $`GO:0030278`$EM2_Name
## [1] "GO:0030278"
## 
## $`GO:0030278`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030278`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030278`$EM2_pvalue_dataset1
## [1] 2.04e-12
## 
## $`GO:0030278`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030278`$EM2_fdr_qvalue_dataset1
## [1] 2.04e-12
## 
## $`GO:0030278`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:0010563`
## $`GO:0010563`$name
## [1] "GO:0010563"
## 
## $`GO:0010563`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF PHOSPHORUS METABOLIC PROCESS"
## 
## $`GO:0010563`$EM2_Formatted_name
## [1] "GO:0010563\n"
## 
## $`GO:0010563`$EM2_Name
## [1] "GO:0010563"
## 
## $`GO:0010563`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010563`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010563`$EM2_pvalue_dataset1
## [1] 4.6e-06
## 
## $`GO:0010563`$EM2_Colouring_dataset1
## [1] 0.9999954
## 
## $`GO:0010563`$EM2_fdr_qvalue_dataset1
## [1] 4.6e-06
## 
## $`GO:0010563`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:0030279`
## $`GO:0030279`$name
## [1] "GO:0030279"
## 
## $`GO:0030279`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF OSSIFICATION"
## 
## $`GO:0030279`$EM2_Formatted_name
## [1] "GO:0030279\n"
## 
## $`GO:0030279`$EM2_Name
## [1] "GO:0030279"
## 
## $`GO:0030279`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030279`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030279`$EM2_pvalue_dataset1
## [1] 2.69e-06
## 
## $`GO:0030279`$EM2_Colouring_dataset1
## [1] 0.9999973
## 
## $`GO:0030279`$EM2_fdr_qvalue_dataset1
## [1] 2.69e-06
## 
## $`GO:0030279`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0030155`
## $`GO:0030155`$name
## [1] "GO:0030155"
## 
## $`GO:0030155`$EM2_GS_DESCR
## [1] "REGULATION OF CELL ADHESION"
## 
## $`GO:0030155`$EM2_Formatted_name
## [1] "GO:0030155\n"
## 
## $`GO:0030155`$EM2_Name
## [1] "GO:0030155"
## 
## $`GO:0030155`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030155`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030155`$EM2_pvalue_dataset1
## [1] 4.91e-10
## 
## $`GO:0030155`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030155`$EM2_fdr_qvalue_dataset1
## [1] 4.91e-10
## 
## $`GO:0030155`$EM2_gs_size_dataset1
## [1] 55
## 
## 
## $`GO:0032331`
## $`GO:0032331`$name
## [1] "GO:0032331"
## 
## $`GO:0032331`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CHONDROCYTE DIFFERENTIATION"
## 
## $`GO:0032331`$EM2_Formatted_name
## [1] "GO:0032331\n"
## 
## $`GO:0032331`$EM2_Name
## [1] "GO:0032331"
## 
## $`GO:0032331`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0032331`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0032331`$EM2_pvalue_dataset1
## [1] 1.43e-07
## 
## $`GO:0032331`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0032331`$EM2_fdr_qvalue_dataset1
## [1] 1.43e-07
## 
## $`GO:0032331`$EM2_gs_size_dataset1
## [1] 7
## 
## 
## $`GO:0048598`
## $`GO:0048598`$name
## [1] "GO:0048598"
## 
## $`GO:0048598`$EM2_GS_DESCR
## [1] "EMBRYONIC MORPHOGENESIS"
## 
## $`GO:0048598`$EM2_Formatted_name
## [1] "GO:0048598\n"
## 
## $`GO:0048598`$EM2_Name
## [1] "GO:0048598"
## 
## $`GO:0048598`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048598`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048598`$EM2_pvalue_dataset1
## [1] 1.65e-18
## 
## $`GO:0048598`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0048598`$EM2_fdr_qvalue_dataset1
## [1] 1.65e-18
## 
## $`GO:0048598`$EM2_gs_size_dataset1
## [1] 51
## 
## 
## $`GO:0070372`
## $`GO:0070372`$name
## [1] "GO:0070372"
## 
## $`GO:0070372`$EM2_GS_DESCR
## [1] "REGULATION OF ERK1 AND ERK2 CASCADE"
## 
## $`GO:0070372`$EM2_Formatted_name
## [1] "GO:0070372\n"
## 
## $`GO:0070372`$EM2_Name
## [1] "GO:0070372"
## 
## $`GO:0070372`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0070372`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0070372`$EM2_pvalue_dataset1
## [1] 5.74e-06
## 
## $`GO:0070372`$EM2_Colouring_dataset1
## [1] 0.9999943
## 
## $`GO:0070372`$EM2_fdr_qvalue_dataset1
## [1] 5.74e-06
## 
## $`GO:0070372`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0090090`
## $`GO:0090090`$name
## [1] "GO:0090090"
## 
## $`GO:0090090`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CANONICAL WNT SIGNALING PATHWAY"
## 
## $`GO:0090090`$EM2_Formatted_name
## [1] "GO:0090090\n"
## 
## $`GO:0090090`$EM2_Name
## [1] "GO:0090090"
## 
## $`GO:0090090`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0090090`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0090090`$EM2_pvalue_dataset1
## [1] 1.55e-06
## 
## $`GO:0090090`$EM2_Colouring_dataset1
## [1] 0.9999984
## 
## $`GO:0090090`$EM2_fdr_qvalue_dataset1
## [1] 1.55e-06
## 
## $`GO:0090090`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`KEGG:04933`
## $`KEGG:04933`$name
## [1] "KEGG:04933"
## 
## $`KEGG:04933`$EM2_GS_DESCR
## [1] "AGE-RAGE SIGNALING PATHWAY IN DIABETIC COMPLICATIONS"
## 
## $`KEGG:04933`$EM2_Formatted_name
## [1] "KEGG:04933\n"
## 
## $`KEGG:04933`$EM2_Name
## [1] "KEGG:04933"
## 
## $`KEGG:04933`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:04933`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:04933`$EM2_pvalue_dataset1
## [1] 1.24e-08
## 
## $`KEGG:04933`$EM2_Colouring_dataset1
## [1] 1
## 
## $`KEGG:04933`$EM2_fdr_qvalue_dataset1
## [1] 1.24e-08
## 
## $`KEGG:04933`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0048589`
## $`GO:0048589`$name
## [1] "GO:0048589"
## 
## $`GO:0048589`$EM2_GS_DESCR
## [1] "DEVELOPMENTAL GROWTH"
## 
## $`GO:0048589`$EM2_Formatted_name
## [1] "GO:0048589\n"
## 
## $`GO:0048589`$EM2_Name
## [1] "GO:0048589"
## 
## $`GO:0048589`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048589`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048589`$EM2_pvalue_dataset1
## [1] 1.87e-07
## 
## $`GO:0048589`$EM2_Colouring_dataset1
## [1] 0.9999998
## 
## $`GO:0048589`$EM2_fdr_qvalue_dataset1
## [1] 1.87e-07
## 
## $`GO:0048589`$EM2_gs_size_dataset1
## [1] 26
## 
## 
## $`GO:0007045`
## $`GO:0007045`$name
## [1] "GO:0007045"
## 
## $`GO:0007045`$EM2_GS_DESCR
## [1] "CELL-SUBSTRATE ADHERENS JUNCTION ASSEMBLY"
## 
## $`GO:0007045`$EM2_Formatted_name
## [1] "GO:0007045\n"
## 
## $`GO:0007045`$EM2_Name
## [1] "GO:0007045"
## 
## $`GO:0007045`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007045`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007045`$EM2_pvalue_dataset1
## [1] 1.29e-06
## 
## $`GO:0007045`$EM2_Colouring_dataset1
## [1] 0.9999987
## 
## $`GO:0007045`$EM2_fdr_qvalue_dataset1
## [1] 1.29e-06
## 
## $`GO:0007045`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`KEGG:04015`
## $`KEGG:04015`$name
## [1] "KEGG:04015"
## 
## $`KEGG:04015`$EM2_GS_DESCR
## [1] "RAP1 SIGNALING PATHWAY"
## 
## $`KEGG:04015`$EM2_Formatted_name
## [1] "KEGG:04015\n"
## 
## $`KEGG:04015`$EM2_Name
## [1] "KEGG:04015"
## 
## $`KEGG:04015`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:04015`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:04015`$EM2_pvalue_dataset1
## [1] 4.96e-06
## 
## $`KEGG:04015`$EM2_Colouring_dataset1
## [1] 0.999995
## 
## $`KEGG:04015`$EM2_fdr_qvalue_dataset1
## [1] 4.96e-06
## 
## $`KEGG:04015`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`REAC:375165`
## $`REAC:375165`$name
## [1] "REAC:375165"
## 
## $`REAC:375165`$EM2_GS_DESCR
## [1] "NCAM SIGNALING FOR NEURITE OUT-GROWTH"
## 
## $`REAC:375165`$EM2_Formatted_name
## [1] "REAC:375165\n"
## 
## $`REAC:375165`$EM2_Name
## [1] "REAC:375165"
## 
## $`REAC:375165`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:375165`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:375165`$EM2_pvalue_dataset1
## [1] 8.65e-06
## 
## $`REAC:375165`$EM2_Colouring_dataset1
## [1] 0.9999913
## 
## $`REAC:375165`$EM2_fdr_qvalue_dataset1
## [1] 8.65e-06
## 
## $`REAC:375165`$EM2_gs_size_dataset1
## [1] 34
## 
## 
## $`GO:0007162`
## $`GO:0007162`$name
## [1] "GO:0007162"
## 
## $`GO:0007162`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELL ADHESION"
## 
## $`GO:0007162`$EM2_Formatted_name
## [1] "GO:0007162\n"
## 
## $`GO:0007162`$EM2_Name
## [1] "GO:0007162"
## 
## $`GO:0007162`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007162`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007162`$EM2_pvalue_dataset1
## [1] 3.71e-07
## 
## $`GO:0007162`$EM2_Colouring_dataset1
## [1] 0.9999996
## 
## $`GO:0007162`$EM2_fdr_qvalue_dataset1
## [1] 3.71e-07
## 
## $`GO:0007162`$EM2_gs_size_dataset1
## [1] 25
## 
## 
## $`GO:0035295`
## $`GO:0035295`$name
## [1] "GO:0035295"
## 
## $`GO:0035295`$EM2_GS_DESCR
## [1] "TUBE DEVELOPMENT"
## 
## $`GO:0035295`$EM2_Formatted_name
## [1] "GO:0035295\n"
## 
## $`GO:0035295`$EM2_Name
## [1] "GO:0035295"
## 
## $`GO:0035295`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0035295`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0035295`$EM2_pvalue_dataset1
## [1] 6.38e-15
## 
## $`GO:0035295`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0035295`$EM2_fdr_qvalue_dataset1
## [1] 6.38e-15
## 
## $`GO:0035295`$EM2_gs_size_dataset1
## [1] 43
## 
## 
## $`GO:1903510`
## $`GO:1903510`$name
## [1] "GO:1903510"
## 
## $`GO:1903510`$EM2_GS_DESCR
## [1] "MUCOPOLYSACCHARIDE METABOLIC PROCESS"
## 
## $`GO:1903510`$EM2_Formatted_name
## [1] "GO:1903510\n"
## 
## $`GO:1903510`$EM2_Name
## [1] "GO:1903510"
## 
## $`GO:1903510`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1903510`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1903510`$EM2_pvalue_dataset1
## [1] 5.43e-11
## 
## $`GO:1903510`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:1903510`$EM2_fdr_qvalue_dataset1
## [1] 5.43e-11
## 
## $`GO:1903510`$EM2_gs_size_dataset1
## [1] 25
## 
## 
## $`GO:0007044`
## $`GO:0007044`$name
## [1] "GO:0007044"
## 
## $`GO:0007044`$EM2_GS_DESCR
## [1] "CELL-SUBSTRATE JUNCTION ASSEMBLY"
## 
## $`GO:0007044`$EM2_Formatted_name
## [1] "GO:0007044\n"
## 
## $`GO:0007044`$EM2_Name
## [1] "GO:0007044"
## 
## $`GO:0007044`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007044`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007044`$EM2_pvalue_dataset1
## [1] 4.7e-07
## 
## $`GO:0007044`$EM2_Colouring_dataset1
## [1] 0.9999995
## 
## $`GO:0007044`$EM2_fdr_qvalue_dataset1
## [1] 4.7e-07
## 
## $`GO:0007044`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0030282`
## $`GO:0030282`$name
## [1] "GO:0030282"
## 
## $`GO:0030282`$EM2_GS_DESCR
## [1] "BONE MINERALIZATION"
## 
## $`GO:0030282`$EM2_Formatted_name
## [1] "GO:0030282\n"
## 
## $`GO:0030282`$EM2_Name
## [1] "GO:0030282"
## 
## $`GO:0030282`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030282`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030282`$EM2_pvalue_dataset1
## [1] 4.98e-07
## 
## $`GO:0030282`$EM2_Colouring_dataset1
## [1] 0.9999995
## 
## $`GO:0030282`$EM2_fdr_qvalue_dataset1
## [1] 4.98e-07
## 
## $`GO:0030282`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0007160`
## $`GO:0007160`$name
## [1] "GO:0007160"
## 
## $`GO:0007160`$EM2_GS_DESCR
## [1] "CELL-MATRIX ADHESION"
## 
## $`GO:0007160`$EM2_Formatted_name
## [1] "GO:0007160\n"
## 
## $`GO:0007160`$EM2_Name
## [1] "GO:0007160"
## 
## $`GO:0007160`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007160`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007160`$EM2_pvalue_dataset1
## [1] 5.28e-13
## 
## $`GO:0007160`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0007160`$EM2_fdr_qvalue_dataset1
## [1] 5.28e-13
## 
## $`GO:0007160`$EM2_gs_size_dataset1
## [1] 33
## 
## 
## $`GO:0050654`
## $`GO:0050654`$name
## [1] "GO:0050654"
## 
## $`GO:0050654`$EM2_GS_DESCR
## [1] "CHONDROITIN SULFATE PROTEOGLYCAN METABOLIC PROCESS"
## 
## $`GO:0050654`$EM2_Formatted_name
## [1] "GO:0050654\n"
## 
## $`GO:0050654`$EM2_Name
## [1] "GO:0050654"
## 
## $`GO:0050654`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050654`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050654`$EM2_pvalue_dataset1
## [1] 1.97e-10
## 
## $`GO:0050654`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0050654`$EM2_fdr_qvalue_dataset1
## [1] 1.97e-10
## 
## $`GO:0050654`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0030168`
## $`GO:0030168`$name
## [1] "GO:0030168"
## 
## $`GO:0030168`$EM2_GS_DESCR
## [1] "PLATELET ACTIVATION"
## 
## $`GO:0030168`$EM2_Formatted_name
## [1] "GO:0030168\n"
## 
## $`GO:0030168`$EM2_Name
## [1] "GO:0030168"
## 
## $`GO:0030168`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030168`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030168`$EM2_pvalue_dataset1
## [1] 6.5e-09
## 
## $`GO:0030168`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030168`$EM2_fdr_qvalue_dataset1
## [1] 6.5e-09
## 
## $`GO:0030168`$EM2_gs_size_dataset1
## [1] 33
## 
## 
## $`GO:0014910`
## $`GO:0014910`$name
## [1] "GO:0014910"
## 
## $`GO:0014910`$EM2_GS_DESCR
## [1] "REGULATION OF SMOOTH MUSCLE CELL MIGRATION"
## 
## $`GO:0014910`$EM2_Formatted_name
## [1] "GO:0014910\n"
## 
## $`GO:0014910`$EM2_Name
## [1] "GO:0014910"
## 
## $`GO:0014910`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0014910`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0014910`$EM2_pvalue_dataset1
## [1] 4.17e-06
## 
## $`GO:0014910`$EM2_Colouring_dataset1
## [1] 0.9999958
## 
## $`GO:0014910`$EM2_fdr_qvalue_dataset1
## [1] 4.17e-06
## 
## $`GO:0014910`$EM2_gs_size_dataset1
## [1] 8
## 
## 
## $`GO:1904030`
## $`GO:1904030`$name
## [1] "GO:1904030"
## 
## $`GO:1904030`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CYCLIN-DEPENDENT PROTEIN KINASE ACTIVITY"
## 
## $`GO:1904030`$EM2_Formatted_name
## [1] "GO:1904030\n"
## 
## $`GO:1904030`$EM2_Name
## [1] "GO:1904030"
## 
## $`GO:1904030`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1904030`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1904030`$EM2_pvalue_dataset1
## [1] 7.75e-06
## 
## $`GO:1904030`$EM2_Colouring_dataset1
## [1] 0.9999923
## 
## $`GO:1904030`$EM2_fdr_qvalue_dataset1
## [1] 7.75e-06
## 
## $`GO:1904030`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0030166`
## $`GO:0030166`$name
## [1] "GO:0030166"
## 
## $`GO:0030166`$EM2_GS_DESCR
## [1] "PROTEOGLYCAN BIOSYNTHETIC PROCESS"
## 
## $`GO:0030166`$EM2_Formatted_name
## [1] "GO:0030166\n"
## 
## $`GO:0030166`$EM2_Name
## [1] "GO:0030166"
## 
## $`GO:0030166`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030166`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030166`$EM2_pvalue_dataset1
## [1] 2.89e-08
## 
## $`GO:0030166`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030166`$EM2_fdr_qvalue_dataset1
## [1] 2.89e-08
## 
## $`GO:0030166`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`REAC:1474228`
## $`REAC:1474228`$name
## [1] "REAC:1474228"
## 
## $`REAC:1474228`$EM2_GS_DESCR
## [1] "DEGRADATION OF THE EXTRACELLULAR MATRIX"
## 
## $`REAC:1474228`$EM2_Formatted_name
## [1] "REAC:1474228\n"
## 
## $`REAC:1474228`$EM2_Name
## [1] "REAC:1474228"
## 
## $`REAC:1474228`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1474228`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1474228`$EM2_pvalue_dataset1
## [1] 1.85e-11
## 
## $`REAC:1474228`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:1474228`$EM2_fdr_qvalue_dataset1
## [1] 1.85e-11
## 
## $`REAC:1474228`$EM2_gs_size_dataset1
## [1] 21
## 
## 
## $`GO:0032102`
## $`GO:0032102`$name
## [1] "GO:0032102"
## 
## $`GO:0032102`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF RESPONSE TO EXTERNAL STIMULUS"
## 
## $`GO:0032102`$EM2_Formatted_name
## [1] "GO:0032102\n"
## 
## $`GO:0032102`$EM2_Name
## [1] "GO:0032102"
## 
## $`GO:0032102`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0032102`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0032102`$EM2_pvalue_dataset1
## [1] 1.13e-08
## 
## $`GO:0032102`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0032102`$EM2_fdr_qvalue_dataset1
## [1] 1.13e-08
## 
## $`GO:0032102`$EM2_gs_size_dataset1
## [1] 20
## 
## 
## $`GO:2000736`
## $`GO:2000736`$name
## [1] "GO:2000736"
## 
## $`GO:2000736`$EM2_GS_DESCR
## [1] "REGULATION OF STEM CELL DIFFERENTIATION"
## 
## $`GO:2000736`$EM2_Formatted_name
## [1] "GO:2000736\n"
## 
## $`GO:2000736`$EM2_Name
## [1] "GO:2000736"
## 
## $`GO:2000736`$EM2_GS_Source
## [1] "none"
## 
## $`GO:2000736`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:2000736`$EM2_pvalue_dataset1
## [1] 1.63e-06
## 
## $`GO:2000736`$EM2_Colouring_dataset1
## [1] 0.9999984
## 
## $`GO:2000736`$EM2_fdr_qvalue_dataset1
## [1] 1.63e-06
## 
## $`GO:2000736`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:0050770`
## $`GO:0050770`$name
## [1] "GO:0050770"
## 
## $`GO:0050770`$EM2_GS_DESCR
## [1] "REGULATION OF AXONOGENESIS"
## 
## $`GO:0050770`$EM2_Formatted_name
## [1] "GO:0050770\n"
## 
## $`GO:0050770`$EM2_Name
## [1] "GO:0050770"
## 
## $`GO:0050770`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050770`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050770`$EM2_pvalue_dataset1
## [1] 6.89e-07
## 
## $`GO:0050770`$EM2_Colouring_dataset1
## [1] 0.9999993
## 
## $`GO:0050770`$EM2_fdr_qvalue_dataset1
## [1] 6.89e-07
## 
## $`GO:0050770`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0050650`
## $`GO:0050650`$name
## [1] "GO:0050650"
## 
## $`GO:0050650`$EM2_GS_DESCR
## [1] "CHONDROITIN SULFATE PROTEOGLYCAN BIOSYNTHETIC PROCESS"
## 
## $`GO:0050650`$EM2_Formatted_name
## [1] "GO:0050650\n"
## 
## $`GO:0050650`$EM2_Name
## [1] "GO:0050650"
## 
## $`GO:0050650`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050650`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050650`$EM2_pvalue_dataset1
## [1] 3.39e-08
## 
## $`GO:0050650`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0050650`$EM2_fdr_qvalue_dataset1
## [1] 3.39e-08
## 
## $`GO:0050650`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0050771`
## $`GO:0050771`$name
## [1] "GO:0050771"
## 
## $`GO:0050771`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF AXONOGENESIS"
## 
## $`GO:0050771`$EM2_Formatted_name
## [1] "GO:0050771\n"
## 
## $`GO:0050771`$EM2_Name
## [1] "GO:0050771"
## 
## $`GO:0050771`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050771`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050771`$EM2_pvalue_dataset1
## [1] 4.91e-06
## 
## $`GO:0050771`$EM2_Colouring_dataset1
## [1] 0.9999951
## 
## $`GO:0050771`$EM2_fdr_qvalue_dataset1
## [1] 4.91e-06
## 
## $`GO:0050771`$EM2_gs_size_dataset1
## [1] 10
## 
## 
## $`GO:0061437`
## $`GO:0061437`$name
## [1] "GO:0061437"
## 
## $`GO:0061437`$EM2_GS_DESCR
## [1] "RENAL SYSTEM VASCULATURE DEVELOPMENT"
## 
## $`GO:0061437`$EM2_Formatted_name
## [1] "GO:0061437\n"
## 
## $`GO:0061437`$EM2_Name
## [1] "GO:0061437"
## 
## $`GO:0061437`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061437`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061437`$EM2_pvalue_dataset1
## [1] 1.07e-07
## 
## $`GO:0061437`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0061437`$EM2_fdr_qvalue_dataset1
## [1] 1.07e-07
## 
## $`GO:0061437`$EM2_gs_size_dataset1
## [1] 7
## 
## 
## $`GO:0060348`
## $`GO:0060348`$name
## [1] "GO:0060348"
## 
## $`GO:0060348`$EM2_GS_DESCR
## [1] "BONE DEVELOPMENT"
## 
## $`GO:0060348`$EM2_Formatted_name
## [1] "GO:0060348\n"
## 
## $`GO:0060348`$EM2_Name
## [1] "GO:0060348"
## 
## $`GO:0060348`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060348`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060348`$EM2_pvalue_dataset1
## [1] 3.74e-07
## 
## $`GO:0060348`$EM2_Colouring_dataset1
## [1] 0.9999996
## 
## $`GO:0060348`$EM2_fdr_qvalue_dataset1
## [1] 3.74e-07
## 
## $`GO:0060348`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0042476`
## $`GO:0042476`$name
## [1] "GO:0042476"
## 
## $`GO:0042476`$EM2_GS_DESCR
## [1] "ODONTOGENESIS"
## 
## $`GO:0042476`$EM2_Formatted_name
## [1] "GO:0042476\n"
## 
## $`GO:0042476`$EM2_Name
## [1] "GO:0042476"
## 
## $`GO:0042476`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0042476`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0042476`$EM2_pvalue_dataset1
## [1] 3.04e-07
## 
## $`GO:0042476`$EM2_Colouring_dataset1
## [1] 0.9999997
## 
## $`GO:0042476`$EM2_fdr_qvalue_dataset1
## [1] 3.04e-07
## 
## $`GO:0042476`$EM2_gs_size_dataset1
## [1] 6
## 
## 
## $`GO:1902532`
## $`GO:1902532`$name
## [1] "GO:1902532"
## 
## $`GO:1902532`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF INTRACELLULAR SIGNAL TRANSDUCTION"
## 
## $`GO:1902532`$EM2_Formatted_name
## [1] "GO:1902532\n"
## 
## $`GO:1902532`$EM2_Name
## [1] "GO:1902532"
## 
## $`GO:1902532`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1902532`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1902532`$EM2_pvalue_dataset1
## [1] 2.34e-06
## 
## $`GO:1902532`$EM2_Colouring_dataset1
## [1] 0.9999977
## 
## $`GO:1902532`$EM2_fdr_qvalue_dataset1
## [1] 2.34e-06
## 
## $`GO:1902532`$EM2_gs_size_dataset1
## [1] 25
## 
## 
## $`GO:0061439`
## $`GO:0061439`$name
## [1] "GO:0061439"
## 
## $`GO:0061439`$EM2_GS_DESCR
## [1] "KIDNEY VASCULATURE MORPHOGENESIS"
## 
## $`GO:0061439`$EM2_Formatted_name
## [1] "GO:0061439\n"
## 
## $`GO:0061439`$EM2_Name
## [1] "GO:0061439"
## 
## $`GO:0061439`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061439`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061439`$EM2_pvalue_dataset1
## [1] 3.34e-08
## 
## $`GO:0061439`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0061439`$EM2_fdr_qvalue_dataset1
## [1] 3.34e-08
## 
## $`GO:0061439`$EM2_gs_size_dataset1
## [1] 5
## 
## 
## $`GO:0061438`
## $`GO:0061438`$name
## [1] "GO:0061438"
## 
## $`GO:0061438`$EM2_GS_DESCR
## [1] "RENAL SYSTEM VASCULATURE MORPHOGENESIS"
## 
## $`GO:0061438`$EM2_Formatted_name
## [1] "GO:0061438\n"
## 
## $`GO:0061438`$EM2_Name
## [1] "GO:0061438"
## 
## $`GO:0061438`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061438`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061438`$EM2_pvalue_dataset1
## [1] 3.34e-08
## 
## $`GO:0061438`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0061438`$EM2_fdr_qvalue_dataset1
## [1] 3.34e-08
## 
## $`GO:0061438`$EM2_gs_size_dataset1
## [1] 5
## 
## 
## $`KEGG:04390`
## $`KEGG:04390`$name
## [1] "KEGG:04390"
## 
## $`KEGG:04390`$EM2_GS_DESCR
## [1] "HIPPO SIGNALING PATHWAY"
## 
## $`KEGG:04390`$EM2_Formatted_name
## [1] "KEGG:04390\n"
## 
## $`KEGG:04390`$EM2_Name
## [1] "KEGG:04390"
## 
## $`KEGG:04390`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:04390`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:04390`$EM2_pvalue_dataset1
## [1] 1.78e-06
## 
## $`KEGG:04390`$EM2_Colouring_dataset1
## [1] 0.9999982
## 
## $`KEGG:04390`$EM2_fdr_qvalue_dataset1
## [1] 1.78e-06
## 
## $`KEGG:04390`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:0050767`
## $`GO:0050767`$name
## [1] "GO:0050767"
## 
## $`GO:0050767`$EM2_GS_DESCR
## [1] "REGULATION OF NEUROGENESIS"
## 
## $`GO:0050767`$EM2_Formatted_name
## [1] "GO:0050767\n"
## 
## $`GO:0050767`$EM2_Name
## [1] "GO:0050767"
## 
## $`GO:0050767`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050767`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050767`$EM2_pvalue_dataset1
## [1] 6.34e-07
## 
## $`GO:0050767`$EM2_Colouring_dataset1
## [1] 0.9999994
## 
## $`GO:0050767`$EM2_fdr_qvalue_dataset1
## [1] 6.34e-07
## 
## $`GO:0050767`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:0010469`
## $`GO:0010469`$name
## [1] "GO:0010469"
## 
## $`GO:0010469`$EM2_GS_DESCR
## [1] "REGULATION OF RECEPTOR ACTIVITY"
## 
## $`GO:0010469`$EM2_Formatted_name
## [1] "GO:0010469\n"
## 
## $`GO:0010469`$EM2_Name
## [1] "GO:0010469"
## 
## $`GO:0010469`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010469`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010469`$EM2_pvalue_dataset1
## [1] 7.39e-06
## 
## $`GO:0010469`$EM2_Colouring_dataset1
## [1] 0.9999926
## 
## $`GO:0010469`$EM2_fdr_qvalue_dataset1
## [1] 7.39e-06
## 
## $`GO:0010469`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:0030178`
## $`GO:0030178`$name
## [1] "GO:0030178"
## 
## $`GO:0030178`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF WNT SIGNALING PATHWAY"
## 
## $`GO:0030178`$EM2_Formatted_name
## [1] "GO:0030178\n"
## 
## $`GO:0030178`$EM2_Name
## [1] "GO:0030178"
## 
## $`GO:0030178`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030178`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030178`$EM2_pvalue_dataset1
## [1] 5.54e-08
## 
## $`GO:0030178`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0030178`$EM2_fdr_qvalue_dataset1
## [1] 5.54e-08
## 
## $`GO:0030178`$EM2_gs_size_dataset1
## [1] 23
## 
## 
## $`GO:0050768`
## $`GO:0050768`$name
## [1] "GO:0050768"
## 
## $`GO:0050768`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF NEUROGENESIS"
## 
## $`GO:0050768`$EM2_Formatted_name
## [1] "GO:0050768\n"
## 
## $`GO:0050768`$EM2_Name
## [1] "GO:0050768"
## 
## $`GO:0050768`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050768`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050768`$EM2_pvalue_dataset1
## [1] 9.43e-07
## 
## $`GO:0050768`$EM2_Colouring_dataset1
## [1] 0.9999991
## 
## $`GO:0050768`$EM2_fdr_qvalue_dataset1
## [1] 9.43e-07
## 
## $`GO:0050768`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`GO:0035987`
## $`GO:0035987`$name
## [1] "GO:0035987"
## 
## $`GO:0035987`$EM2_GS_DESCR
## [1] "ENDODERMAL CELL DIFFERENTIATION"
## 
## $`GO:0035987`$EM2_Formatted_name
## [1] "GO:0035987\n"
## 
## $`GO:0035987`$EM2_Name
## [1] "GO:0035987"
## 
## $`GO:0035987`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0035987`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0035987`$EM2_pvalue_dataset1
## [1] 7.31e-12
## 
## $`GO:0035987`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0035987`$EM2_fdr_qvalue_dataset1
## [1] 7.31e-12
## 
## $`GO:0035987`$EM2_gs_size_dataset1
## [1] 12
## 
## 
## $`GO:0071560`
## $`GO:0071560`$name
## [1] "GO:0071560"
## 
## $`GO:0071560`$EM2_GS_DESCR
## [1] "CELLULAR RESPONSE TO TRANSFORMING GROWTH FACTOR BETA STIMULUS"
## 
## $`GO:0071560`$EM2_Formatted_name
## [1] "GO:0071560\n"
## 
## $`GO:0071560`$EM2_Name
## [1] "GO:0071560"
## 
## $`GO:0071560`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0071560`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0071560`$EM2_pvalue_dataset1
## [1] 2.63e-06
## 
## $`GO:0071560`$EM2_Colouring_dataset1
## [1] 0.9999974
## 
## $`GO:0071560`$EM2_fdr_qvalue_dataset1
## [1] 2.63e-06
## 
## $`GO:0071560`$EM2_gs_size_dataset1
## [1] 26
## 
## 
## $`REAC:76002`
## $`REAC:76002`$name
## [1] "REAC:76002"
## 
## $`REAC:76002`$EM2_GS_DESCR
## [1] "PLATELET ACTIVATION, SIGNALING AND AGGREGATION"
## 
## $`REAC:76002`$EM2_Formatted_name
## [1] "REAC:76002\n"
## 
## $`REAC:76002`$EM2_Name
## [1] "REAC:76002"
## 
## $`REAC:76002`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:76002`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:76002`$EM2_pvalue_dataset1
## [1] 9.6e-06
## 
## $`REAC:76002`$EM2_Colouring_dataset1
## [1] 0.9999904
## 
## $`REAC:76002`$EM2_fdr_qvalue_dataset1
## [1] 9.6e-06
## 
## $`REAC:76002`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`KEGG:04151`
## $`KEGG:04151`$name
## [1] "KEGG:04151"
## 
## $`KEGG:04151`$EM2_GS_DESCR
## [1] "PI3K-AKT SIGNALING PATHWAY"
## 
## $`KEGG:04151`$EM2_Formatted_name
## [1] "KEGG:04151\n"
## 
## $`KEGG:04151`$EM2_Name
## [1] "KEGG:04151"
## 
## $`KEGG:04151`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:04151`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:04151`$EM2_pvalue_dataset1
## [1] 1.12e-13
## 
## $`KEGG:04151`$EM2_Colouring_dataset1
## [1] 1
## 
## $`KEGG:04151`$EM2_fdr_qvalue_dataset1
## [1] 1.12e-13
## 
## $`KEGG:04151`$EM2_gs_size_dataset1
## [1] 51
## 
## 
## $`REAC:76005`
## $`REAC:76005`$name
## [1] "REAC:76005"
## 
## $`REAC:76005`$EM2_GS_DESCR
## [1] "RESPONSE TO ELEVATED PLATELET CYTOSOLIC CA2+"
## 
## $`REAC:76005`$EM2_Formatted_name
## [1] "REAC:76005\n"
## 
## $`REAC:76005`$EM2_Name
## [1] "REAC:76005"
## 
## $`REAC:76005`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:76005`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:76005`$EM2_pvalue_dataset1
## [1] 1.37e-07
## 
## $`REAC:76005`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`REAC:76005`$EM2_fdr_qvalue_dataset1
## [1] 1.37e-07
## 
## $`REAC:76005`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0060675`
## $`GO:0060675`$name
## [1] "GO:0060675"
## 
## $`GO:0060675`$EM2_GS_DESCR
## [1] "URETERIC BUD MORPHOGENESIS"
## 
## $`GO:0060675`$EM2_Formatted_name
## [1] "GO:0060675\n"
## 
## $`GO:0060675`$EM2_Name
## [1] "GO:0060675"
## 
## $`GO:0060675`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060675`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060675`$EM2_pvalue_dataset1
## [1] 1.8e-06
## 
## $`GO:0060675`$EM2_Colouring_dataset1
## [1] 0.9999982
## 
## $`GO:0060675`$EM2_fdr_qvalue_dataset1
## [1] 1.8e-06
## 
## $`GO:0060675`$EM2_gs_size_dataset1
## [1] 10
## 
## 
## $`GO:0048568`
## $`GO:0048568`$name
## [1] "GO:0048568"
## 
## $`GO:0048568`$EM2_GS_DESCR
## [1] "EMBRYONIC ORGAN DEVELOPMENT"
## 
## $`GO:0048568`$EM2_Formatted_name
## [1] "GO:0048568\n"
## 
## $`GO:0048568`$EM2_Name
## [1] "GO:0048568"
## 
## $`GO:0048568`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048568`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048568`$EM2_pvalue_dataset1
## [1] 8.05e-08
## 
## $`GO:0048568`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0048568`$EM2_fdr_qvalue_dataset1
## [1] 8.05e-08
## 
## $`GO:0048568`$EM2_gs_size_dataset1
## [1] 25
## 
## 
## $`GO:0008038`
## $`GO:0008038`$name
## [1] "GO:0008038"
## 
## $`GO:0008038`$EM2_GS_DESCR
## [1] "NEURON RECOGNITION"
## 
## $`GO:0008038`$EM2_Formatted_name
## [1] "GO:0008038\n"
## 
## $`GO:0008038`$EM2_Name
## [1] "GO:0008038"
## 
## $`GO:0008038`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0008038`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0008038`$EM2_pvalue_dataset1
## [1] 1.12e-06
## 
## $`GO:0008038`$EM2_Colouring_dataset1
## [1] 0.9999989
## 
## $`GO:0008038`$EM2_fdr_qvalue_dataset1
## [1] 1.12e-06
## 
## $`GO:0008038`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0014031`
## $`GO:0014031`$name
## [1] "GO:0014031"
## 
## $`GO:0014031`$EM2_GS_DESCR
## [1] "MESENCHYMAL CELL DEVELOPMENT"
## 
## $`GO:0014031`$EM2_Formatted_name
## [1] "GO:0014031\n"
## 
## $`GO:0014031`$EM2_Name
## [1] "GO:0014031"
## 
## $`GO:0014031`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0014031`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0014031`$EM2_pvalue_dataset1
## [1] 4.27e-13
## 
## $`GO:0014031`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0014031`$EM2_fdr_qvalue_dataset1
## [1] 4.27e-13
## 
## $`GO:0014031`$EM2_gs_size_dataset1
## [1] 32
## 
## 
## $`GO:0010594`
## $`GO:0010594`$name
## [1] "GO:0010594"
## 
## $`GO:0010594`$EM2_GS_DESCR
## [1] "REGULATION OF ENDOTHELIAL CELL MIGRATION"
## 
## $`GO:0010594`$EM2_Formatted_name
## [1] "GO:0010594\n"
## 
## $`GO:0010594`$EM2_Name
## [1] "GO:0010594"
## 
## $`GO:0010594`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010594`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010594`$EM2_pvalue_dataset1
## [1] 1.61e-07
## 
## $`GO:0010594`$EM2_Colouring_dataset1
## [1] 0.9999998
## 
## $`GO:0010594`$EM2_fdr_qvalue_dataset1
## [1] 1.61e-07
## 
## $`GO:0010594`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`REAC:1650814`
## $`REAC:1650814`$name
## [1] "REAC:1650814"
## 
## $`REAC:1650814`$EM2_GS_DESCR
## [1] "COLLAGEN BIOSYNTHESIS AND MODIFYING ENZYMES"
## 
## $`REAC:1650814`$EM2_Formatted_name
## [1] "REAC:1650814\n"
## 
## $`REAC:1650814`$EM2_Name
## [1] "REAC:1650814"
## 
## $`REAC:1650814`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1650814`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1650814`$EM2_pvalue_dataset1
## [1] 1.55e-24
## 
## $`REAC:1650814`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:1650814`$EM2_fdr_qvalue_dataset1
## [1] 1.55e-24
## 
## $`REAC:1650814`$EM2_gs_size_dataset1
## [1] 30
## 
## 
## $`GO:0030509`
## $`GO:0030509`$name
## [1] "GO:0030509"
## 
## $`GO:0030509`$EM2_GS_DESCR
## [1] "BMP SIGNALING PATHWAY"
## 
## $`GO:0030509`$EM2_Formatted_name
## [1] "GO:0030509\n"
## 
## $`GO:0030509`$EM2_Name
## [1] "GO:0030509"
## 
## $`GO:0030509`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030509`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030509`$EM2_pvalue_dataset1
## [1] 3.65e-08
## 
## $`GO:0030509`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030509`$EM2_fdr_qvalue_dataset1
## [1] 3.65e-08
## 
## $`GO:0030509`$EM2_gs_size_dataset1
## [1] 22
## 
## 
## $`GO:0001503`
## $`GO:0001503`$name
## [1] "GO:0001503"
## 
## $`GO:0001503`$EM2_GS_DESCR
## [1] "OSSIFICATION"
## 
## $`GO:0001503`$EM2_Formatted_name
## [1] "GO:0001503\n"
## 
## $`GO:0001503`$EM2_Name
## [1] "GO:0001503"
## 
## $`GO:0001503`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001503`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001503`$EM2_pvalue_dataset1
## [1] 1.14e-17
## 
## $`GO:0001503`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001503`$EM2_fdr_qvalue_dataset1
## [1] 1.14e-17
## 
## $`GO:0001503`$EM2_gs_size_dataset1
## [1] 46
## 
## 
## $`GO:0048566`
## $`GO:0048566`$name
## [1] "GO:0048566"
## 
## $`GO:0048566`$EM2_GS_DESCR
## [1] "EMBRYONIC DIGESTIVE TRACT DEVELOPMENT"
## 
## $`GO:0048566`$EM2_Formatted_name
## [1] "GO:0048566\n"
## 
## $`GO:0048566`$EM2_Name
## [1] "GO:0048566"
## 
## $`GO:0048566`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048566`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048566`$EM2_pvalue_dataset1
## [1] 2.01e-07
## 
## $`GO:0048566`$EM2_Colouring_dataset1
## [1] 0.9999998
## 
## $`GO:0048566`$EM2_fdr_qvalue_dataset1
## [1] 2.01e-07
## 
## $`GO:0048566`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0051960`
## $`GO:0051960`$name
## [1] "GO:0051960"
## 
## $`GO:0051960`$EM2_GS_DESCR
## [1] "REGULATION OF NERVOUS SYSTEM DEVELOPMENT"
## 
## $`GO:0051960`$EM2_Formatted_name
## [1] "GO:0051960\n"
## 
## $`GO:0051960`$EM2_Name
## [1] "GO:0051960"
## 
## $`GO:0051960`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0051960`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0051960`$EM2_pvalue_dataset1
## [1] 9.36e-08
## 
## $`GO:0051960`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0051960`$EM2_fdr_qvalue_dataset1
## [1] 9.36e-08
## 
## $`GO:0051960`$EM2_gs_size_dataset1
## [1] 30
## 
## 
## $`GO:0001501`
## $`GO:0001501`$name
## [1] "GO:0001501"
## 
## $`GO:0001501`$EM2_GS_DESCR
## [1] "SKELETAL SYSTEM DEVELOPMENT"
## 
## $`GO:0001501`$EM2_Formatted_name
## [1] "GO:0001501\n"
## 
## $`GO:0001501`$EM2_Name
## [1] "GO:0001501"
## 
## $`GO:0001501`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001501`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001501`$EM2_pvalue_dataset1
## [1] 5.25e-25
## 
## $`GO:0001501`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001501`$EM2_fdr_qvalue_dataset1
## [1] 5.25e-25
## 
## $`GO:0001501`$EM2_gs_size_dataset1
## [1] 58
## 
## 
## $`GO:0003007`
## $`GO:0003007`$name
## [1] "GO:0003007"
## 
## $`GO:0003007`$EM2_GS_DESCR
## [1] "HEART MORPHOGENESIS"
## 
## $`GO:0003007`$EM2_Formatted_name
## [1] "GO:0003007\n"
## 
## $`GO:0003007`$EM2_Name
## [1] "GO:0003007"
## 
## $`GO:0003007`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0003007`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0003007`$EM2_pvalue_dataset1
## [1] 1.53e-07
## 
## $`GO:0003007`$EM2_Colouring_dataset1
## [1] 0.9999998
## 
## $`GO:0003007`$EM2_fdr_qvalue_dataset1
## [1] 1.53e-07
## 
## $`GO:0003007`$EM2_gs_size_dataset1
## [1] 23
## 
## 
## $`GO:0051961`
## $`GO:0051961`$name
## [1] "GO:0051961"
## 
## $`GO:0051961`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF NERVOUS SYSTEM DEVELOPMENT"
## 
## $`GO:0051961`$EM2_Formatted_name
## [1] "GO:0051961\n"
## 
## $`GO:0051961`$EM2_Name
## [1] "GO:0051961"
## 
## $`GO:0051961`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0051961`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0051961`$EM2_pvalue_dataset1
## [1] 1.62e-07
## 
## $`GO:0051961`$EM2_Colouring_dataset1
## [1] 0.9999998
## 
## $`GO:0051961`$EM2_fdr_qvalue_dataset1
## [1] 1.62e-07
## 
## $`GO:0051961`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0060326`
## $`GO:0060326`$name
## [1] "GO:0060326"
## 
## $`GO:0060326`$EM2_GS_DESCR
## [1] "CELL CHEMOTAXIS"
## 
## $`GO:0060326`$EM2_Formatted_name
## [1] "GO:0060326\n"
## 
## $`GO:0060326`$EM2_Name
## [1] "GO:0060326"
## 
## $`GO:0060326`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060326`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060326`$EM2_pvalue_dataset1
## [1] 1.69e-06
## 
## $`GO:0060326`$EM2_Colouring_dataset1
## [1] 0.9999983
## 
## $`GO:0060326`$EM2_fdr_qvalue_dataset1
## [1] 1.69e-06
## 
## $`GO:0060326`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:0090092`
## $`GO:0090092`$name
## [1] "GO:0090092"
## 
## $`GO:0090092`$EM2_GS_DESCR
## [1] "REGULATION OF TRANSMEMBRANE RECEPTOR PROTEIN SERINE/THREONINE KINASE SIGNALING PATHWAY"
## 
## $`GO:0090092`$EM2_Formatted_name
## [1] "GO:0090092\n"
## 
## $`GO:0090092`$EM2_Name
## [1] "GO:0090092"
## 
## $`GO:0090092`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0090092`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0090092`$EM2_pvalue_dataset1
## [1] 1.32e-08
## 
## $`GO:0090092`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0090092`$EM2_fdr_qvalue_dataset1
## [1] 1.32e-08
## 
## $`GO:0090092`$EM2_gs_size_dataset1
## [1] 28
## 
## 
## $`GO:0042698`
## $`GO:0042698`$name
## [1] "GO:0042698"
## 
## $`GO:0042698`$EM2_GS_DESCR
## [1] "OVULATION CYCLE"
## 
## $`GO:0042698`$EM2_Formatted_name
## [1] "GO:0042698\n"
## 
## $`GO:0042698`$EM2_Name
## [1] "GO:0042698"
## 
## $`GO:0042698`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0042698`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0042698`$EM2_pvalue_dataset1
## [1] 5.35e-06
## 
## $`GO:0042698`$EM2_Colouring_dataset1
## [1] 0.9999946
## 
## $`GO:0042698`$EM2_fdr_qvalue_dataset1
## [1] 5.35e-06
## 
## $`GO:0042698`$EM2_gs_size_dataset1
## [1] 6
## 
## 
## $`GO:0007178`
## $`GO:0007178`$name
## [1] "GO:0007178"
## 
## $`GO:0007178`$EM2_GS_DESCR
## [1] "TRANSMEMBRANE RECEPTOR PROTEIN SERINE/THREONINE KINASE SIGNALING PATHWAY"
## 
## $`GO:0007178`$EM2_Formatted_name
## [1] "GO:0007178\n"
## 
## $`GO:0007178`$EM2_Name
## [1] "GO:0007178"
## 
## $`GO:0007178`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007178`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007178`$EM2_pvalue_dataset1
## [1] 3.85e-11
## 
## $`GO:0007178`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0007178`$EM2_fdr_qvalue_dataset1
## [1] 3.85e-11
## 
## $`GO:0007178`$EM2_gs_size_dataset1
## [1] 41
## 
## 
## $`GO:0043542`
## $`GO:0043542`$name
## [1] "GO:0043542"
## 
## $`GO:0043542`$EM2_GS_DESCR
## [1] "ENDOTHELIAL CELL MIGRATION"
## 
## $`GO:0043542`$EM2_Formatted_name
## [1] "GO:0043542\n"
## 
## $`GO:0043542`$EM2_Name
## [1] "GO:0043542"
## 
## $`GO:0043542`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0043542`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0043542`$EM2_pvalue_dataset1
## [1] 1.37e-11
## 
## $`GO:0043542`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0043542`$EM2_fdr_qvalue_dataset1
## [1] 1.37e-11
## 
## $`GO:0043542`$EM2_gs_size_dataset1
## [1] 28
## 
## 
## $`GO:1904018`
## $`GO:1904018`$name
## [1] "GO:1904018"
## 
## $`GO:1904018`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF VASCULATURE DEVELOPMENT"
## 
## $`GO:1904018`$EM2_Formatted_name
## [1] "GO:1904018\n"
## 
## $`GO:1904018`$EM2_Name
## [1] "GO:1904018"
## 
## $`GO:1904018`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1904018`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1904018`$EM2_pvalue_dataset1
## [1] 4.51e-08
## 
## $`GO:1904018`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:1904018`$EM2_fdr_qvalue_dataset1
## [1] 4.51e-08
## 
## $`GO:1904018`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0002040`
## $`GO:0002040`$name
## [1] "GO:0002040"
## 
## $`GO:0002040`$EM2_GS_DESCR
## [1] "SPROUTING ANGIOGENESIS"
## 
## $`GO:0002040`$EM2_Formatted_name
## [1] "GO:0002040\n"
## 
## $`GO:0002040`$EM2_Name
## [1] "GO:0002040"
## 
## $`GO:0002040`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0002040`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0002040`$EM2_pvalue_dataset1
## [1] 2.42e-08
## 
## $`GO:0002040`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0002040`$EM2_fdr_qvalue_dataset1
## [1] 2.42e-08
## 
## $`GO:0002040`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0030195`
## $`GO:0030195`$name
## [1] "GO:0030195"
## 
## $`GO:0030195`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF BLOOD COAGULATION"
## 
## $`GO:0030195`$EM2_Formatted_name
## [1] "GO:0030195\n"
## 
## $`GO:0030195`$EM2_Name
## [1] "GO:0030195"
## 
## $`GO:0030195`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030195`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030195`$EM2_pvalue_dataset1
## [1] 3.43e-06
## 
## $`GO:0030195`$EM2_Colouring_dataset1
## [1] 0.9999966
## 
## $`GO:0030195`$EM2_fdr_qvalue_dataset1
## [1] 3.43e-06
## 
## $`GO:0030195`$EM2_gs_size_dataset1
## [1] 8
## 
## 
## $`REAC:1566948`
## $`REAC:1566948`$name
## [1] "REAC:1566948"
## 
## $`REAC:1566948`$EM2_GS_DESCR
## [1] "ELASTIC FIBRE FORMATION"
## 
## $`REAC:1566948`$EM2_Formatted_name
## [1] "REAC:1566948\n"
## 
## $`REAC:1566948`$EM2_Name
## [1] "REAC:1566948"
## 
## $`REAC:1566948`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1566948`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1566948`$EM2_pvalue_dataset1
## [1] 5.18e-15
## 
## $`REAC:1566948`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:1566948`$EM2_fdr_qvalue_dataset1
## [1] 5.18e-15
## 
## $`REAC:1566948`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:0030193`
## $`GO:0030193`$name
## [1] "GO:0030193"
## 
## $`GO:0030193`$EM2_GS_DESCR
## [1] "REGULATION OF BLOOD COAGULATION"
## 
## $`GO:0030193`$EM2_Formatted_name
## [1] "GO:0030193\n"
## 
## $`GO:0030193`$EM2_Name
## [1] "GO:0030193"
## 
## $`GO:0030193`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030193`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030193`$EM2_pvalue_dataset1
## [1] 1.91e-06
## 
## $`GO:0030193`$EM2_Colouring_dataset1
## [1] 0.9999981
## 
## $`GO:0030193`$EM2_fdr_qvalue_dataset1
## [1] 1.91e-06
## 
## $`GO:0030193`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0060322`
## $`GO:0060322`$name
## [1] "GO:0060322"
## 
## $`GO:0060322`$EM2_GS_DESCR
## [1] "HEAD DEVELOPMENT"
## 
## $`GO:0060322`$EM2_Formatted_name
## [1] "GO:0060322\n"
## 
## $`GO:0060322`$EM2_Name
## [1] "GO:0060322"
## 
## $`GO:0060322`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060322`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060322`$EM2_pvalue_dataset1
## [1] 2.79e-06
## 
## $`GO:0060322`$EM2_Colouring_dataset1
## [1] 0.9999972
## 
## $`GO:0060322`$EM2_fdr_qvalue_dataset1
## [1] 2.79e-06
## 
## $`GO:0060322`$EM2_gs_size_dataset1
## [1] 35
## 
## 
## $`GO:0060562`
## $`GO:0060562`$name
## [1] "GO:0060562"
## 
## $`GO:0060562`$EM2_GS_DESCR
## [1] "EPITHELIAL TUBE MORPHOGENESIS"
## 
## $`GO:0060562`$EM2_Formatted_name
## [1] "GO:0060562\n"
## 
## $`GO:0060562`$EM2_Name
## [1] "GO:0060562"
## 
## $`GO:0060562`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060562`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060562`$EM2_pvalue_dataset1
## [1] 6.58e-10
## 
## $`GO:0060562`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0060562`$EM2_fdr_qvalue_dataset1
## [1] 6.58e-10
## 
## $`GO:0060562`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:2000147`
## $`GO:2000147`$name
## [1] "GO:2000147"
## 
## $`GO:2000147`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF CELL MOTILITY"
## 
## $`GO:2000147`$EM2_Formatted_name
## [1] "GO:2000147\n"
## 
## $`GO:2000147`$EM2_Name
## [1] "GO:2000147"
## 
## $`GO:2000147`$EM2_GS_Source
## [1] "none"
## 
## $`GO:2000147`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:2000147`$EM2_pvalue_dataset1
## [1] 5.72e-16
## 
## $`GO:2000147`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:2000147`$EM2_fdr_qvalue_dataset1
## [1] 5.72e-16
## 
## $`GO:2000147`$EM2_gs_size_dataset1
## [1] 51
## 
## 
## $`GO:2000027`
## $`GO:2000027`$name
## [1] "GO:2000027"
## 
## $`GO:2000027`$EM2_GS_DESCR
## [1] "REGULATION OF ORGAN MORPHOGENESIS"
## 
## $`GO:2000027`$EM2_Formatted_name
## [1] "GO:2000027\n"
## 
## $`GO:2000027`$EM2_Name
## [1] "GO:2000027"
## 
## $`GO:2000027`$EM2_GS_Source
## [1] "none"
## 
## $`GO:2000027`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:2000027`$EM2_pvalue_dataset1
## [1] 1.13e-08
## 
## $`GO:2000027`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:2000027`$EM2_fdr_qvalue_dataset1
## [1] 1.13e-08
## 
## $`GO:2000027`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0030111`
## $`GO:0030111`$name
## [1] "GO:0030111"
## 
## $`GO:0030111`$EM2_GS_DESCR
## [1] "REGULATION OF WNT SIGNALING PATHWAY"
## 
## $`GO:0030111`$EM2_Formatted_name
## [1] "GO:0030111\n"
## 
## $`GO:0030111`$EM2_Name
## [1] "GO:0030111"
## 
## $`GO:0030111`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030111`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030111`$EM2_pvalue_dataset1
## [1] 1.39e-09
## 
## $`GO:0030111`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030111`$EM2_fdr_qvalue_dataset1
## [1] 1.39e-09
## 
## $`GO:0030111`$EM2_gs_size_dataset1
## [1] 38
## 
## 
## $`GO:0001938`
## $`GO:0001938`$name
## [1] "GO:0001938"
## 
## $`GO:0001938`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF ENDOTHELIAL CELL PROLIFERATION"
## 
## $`GO:0001938`$EM2_Formatted_name
## [1] "GO:0001938\n"
## 
## $`GO:0001938`$EM2_Name
## [1] "GO:0001938"
## 
## $`GO:0001938`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001938`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001938`$EM2_pvalue_dataset1
## [1] 4.11e-07
## 
## $`GO:0001938`$EM2_Colouring_dataset1
## [1] 0.9999996
## 
## $`GO:0001938`$EM2_fdr_qvalue_dataset1
## [1] 4.11e-07
## 
## $`GO:0001938`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`REAC:1971475`
## $`REAC:1971475`$name
## [1] "REAC:1971475"
## 
## $`REAC:1971475`$EM2_GS_DESCR
## [1] "A TETRASACCHARIDE LINKER SEQUENCE IS REQUIRED FOR GAG SYNTHESIS"
## 
## $`REAC:1971475`$EM2_Formatted_name
## [1] "REAC:1971475\n"
## 
## $`REAC:1971475`$EM2_Name
## [1] "REAC:1971475"
## 
## $`REAC:1971475`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1971475`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1971475`$EM2_pvalue_dataset1
## [1] 4.3e-10
## 
## $`REAC:1971475`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:1971475`$EM2_fdr_qvalue_dataset1
## [1] 4.3e-10
## 
## $`REAC:1971475`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0050900`
## $`GO:0050900`$name
## [1] "GO:0050900"
## 
## $`GO:0050900`$EM2_GS_DESCR
## [1] "LEUKOCYTE MIGRATION"
## 
## $`GO:0050900`$EM2_Formatted_name
## [1] "GO:0050900\n"
## 
## $`GO:0050900`$EM2_Name
## [1] "GO:0050900"
## 
## $`GO:0050900`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050900`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050900`$EM2_pvalue_dataset1
## [1] 3.27e-06
## 
## $`GO:0050900`$EM2_Colouring_dataset1
## [1] 0.9999967
## 
## $`GO:0050900`$EM2_fdr_qvalue_dataset1
## [1] 3.27e-06
## 
## $`GO:0050900`$EM2_gs_size_dataset1
## [1] 32
## 
## 
## $`GO:0001936`
## $`GO:0001936`$name
## [1] "GO:0001936"
## 
## $`GO:0001936`$EM2_GS_DESCR
## [1] "REGULATION OF ENDOTHELIAL CELL PROLIFERATION"
## 
## $`GO:0001936`$EM2_Formatted_name
## [1] "GO:0001936\n"
## 
## $`GO:0001936`$EM2_Name
## [1] "GO:0001936"
## 
## $`GO:0001936`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001936`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001936`$EM2_pvalue_dataset1
## [1] 4.88e-07
## 
## $`GO:0001936`$EM2_Colouring_dataset1
## [1] 0.9999995
## 
## $`GO:0001936`$EM2_fdr_qvalue_dataset1
## [1] 4.88e-07
## 
## $`GO:0001936`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0001935`
## $`GO:0001935`$name
## [1] "GO:0001935"
## 
## $`GO:0001935`$EM2_GS_DESCR
## [1] "ENDOTHELIAL CELL PROLIFERATION"
## 
## $`GO:0001935`$EM2_Formatted_name
## [1] "GO:0001935\n"
## 
## $`GO:0001935`$EM2_Name
## [1] "GO:0001935"
## 
## $`GO:0001935`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001935`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001935`$EM2_pvalue_dataset1
## [1] 1.29e-07
## 
## $`GO:0001935`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0001935`$EM2_fdr_qvalue_dataset1
## [1] 1.29e-07
## 
## $`GO:0001935`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:2000146`
## $`GO:2000146`$name
## [1] "GO:2000146"
## 
## $`GO:2000146`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELL MOTILITY"
## 
## $`GO:2000146`$EM2_Formatted_name
## [1] "GO:2000146\n"
## 
## $`GO:2000146`$EM2_Name
## [1] "GO:2000146"
## 
## $`GO:2000146`$EM2_GS_Source
## [1] "none"
## 
## $`GO:2000146`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:2000146`$EM2_pvalue_dataset1
## [1] 1.45e-08
## 
## $`GO:2000146`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:2000146`$EM2_fdr_qvalue_dataset1
## [1] 1.45e-08
## 
## $`GO:2000146`$EM2_gs_size_dataset1
## [1] 26
## 
## 
## $`KEGG:05144`
## $`KEGG:05144`$name
## [1] "KEGG:05144"
## 
## $`KEGG:05144`$EM2_GS_DESCR
## [1] "MALARIA"
## 
## $`KEGG:05144`$EM2_Formatted_name
## [1] "KEGG:05144\n"
## 
## $`KEGG:05144`$EM2_Name
## [1] "KEGG:05144"
## 
## $`KEGG:05144`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:05144`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:05144`$EM2_pvalue_dataset1
## [1] 1.42e-07
## 
## $`KEGG:05144`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`KEGG:05144`$EM2_fdr_qvalue_dataset1
## [1] 1.42e-07
## 
## $`KEGG:05144`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0001933`
## $`GO:0001933`$name
## [1] "GO:0001933"
## 
## $`GO:0001933`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF PROTEIN PHOSPHORYLATION"
## 
## $`GO:0001933`$EM2_Formatted_name
## [1] "GO:0001933\n"
## 
## $`GO:0001933`$EM2_Name
## [1] "GO:0001933"
## 
## $`GO:0001933`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001933`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001933`$EM2_pvalue_dataset1
## [1] 9.85e-07
## 
## $`GO:0001933`$EM2_Colouring_dataset1
## [1] 0.999999
## 
## $`GO:0001933`$EM2_fdr_qvalue_dataset1
## [1] 9.85e-07
## 
## $`GO:0001933`$EM2_gs_size_dataset1
## [1] 35
## 
## 
## $`GO:0010769`
## $`GO:0010769`$name
## [1] "GO:0010769"
## 
## $`GO:0010769`$EM2_GS_DESCR
## [1] "REGULATION OF CELL MORPHOGENESIS INVOLVED IN DIFFERENTIATION"
## 
## $`GO:0010769`$EM2_Formatted_name
## [1] "GO:0010769\n"
## 
## $`GO:0010769`$EM2_Name
## [1] "GO:0010769"
## 
## $`GO:0010769`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010769`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010769`$EM2_pvalue_dataset1
## [1] 5.99e-12
## 
## $`GO:0010769`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0010769`$EM2_fdr_qvalue_dataset1
## [1] 5.99e-12
## 
## $`GO:0010769`$EM2_gs_size_dataset1
## [1] 40
## 
## 
## $`KEGG:05146`
## $`KEGG:05146`$name
## [1] "KEGG:05146"
## 
## $`KEGG:05146`$EM2_GS_DESCR
## [1] "AMOEBIASIS"
## 
## $`KEGG:05146`$EM2_Formatted_name
## [1] "KEGG:05146\n"
## 
## $`KEGG:05146`$EM2_Name
## [1] "KEGG:05146"
## 
## $`KEGG:05146`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:05146`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:05146`$EM2_pvalue_dataset1
## [1] 9.06e-07
## 
## $`KEGG:05146`$EM2_Colouring_dataset1
## [1] 0.9999991
## 
## $`KEGG:05146`$EM2_fdr_qvalue_dataset1
## [1] 9.06e-07
## 
## $`KEGG:05146`$EM2_gs_size_dataset1
## [1] 6
## 
## 
## $`GO:0033627`
## $`GO:0033627`$name
## [1] "GO:0033627"
## 
## $`GO:0033627`$EM2_GS_DESCR
## [1] "CELL ADHESION MEDIATED BY INTEGRIN"
## 
## $`GO:0033627`$EM2_Formatted_name
## [1] "GO:0033627\n"
## 
## $`GO:0033627`$EM2_Name
## [1] "GO:0033627"
## 
## $`GO:0033627`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0033627`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0033627`$EM2_pvalue_dataset1
## [1] 1.45e-08
## 
## $`GO:0033627`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0033627`$EM2_fdr_qvalue_dataset1
## [1] 1.45e-08
## 
## $`GO:0033627`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`GO:0007369`
## $`GO:0007369`$name
## [1] "GO:0007369"
## 
## $`GO:0007369`$EM2_GS_DESCR
## [1] "GASTRULATION"
## 
## $`GO:0007369`$EM2_Formatted_name
## [1] "GO:0007369\n"
## 
## $`GO:0007369`$EM2_Name
## [1] "GO:0007369"
## 
## $`GO:0007369`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007369`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007369`$EM2_pvalue_dataset1
## [1] 9.19e-13
## 
## $`GO:0007369`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0007369`$EM2_fdr_qvalue_dataset1
## [1] 9.19e-13
## 
## $`GO:0007369`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:0048705`
## $`GO:0048705`$name
## [1] "GO:0048705"
## 
## $`GO:0048705`$EM2_GS_DESCR
## [1] "SKELETAL SYSTEM MORPHOGENESIS"
## 
## $`GO:0048705`$EM2_Formatted_name
## [1] "GO:0048705\n"
## 
## $`GO:0048705`$EM2_Name
## [1] "GO:0048705"
## 
## $`GO:0048705`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048705`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048705`$EM2_pvalue_dataset1
## [1] 2.42e-06
## 
## $`GO:0048705`$EM2_Colouring_dataset1
## [1] 0.9999976
## 
## $`GO:0048705`$EM2_fdr_qvalue_dataset1
## [1] 2.42e-06
## 
## $`GO:0048705`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`KEGG:04974`
## $`KEGG:04974`$name
## [1] "KEGG:04974"
## 
## $`KEGG:04974`$EM2_GS_DESCR
## [1] "PROTEIN DIGESTION AND ABSORPTION"
## 
## $`KEGG:04974`$EM2_Formatted_name
## [1] "KEGG:04974\n"
## 
## $`KEGG:04974`$EM2_Name
## [1] "KEGG:04974"
## 
## $`KEGG:04974`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:04974`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:04974`$EM2_pvalue_dataset1
## [1] 7.84e-13
## 
## $`KEGG:04974`$EM2_Colouring_dataset1
## [1] 1
## 
## $`KEGG:04974`$EM2_fdr_qvalue_dataset1
## [1] 7.84e-13
## 
## $`KEGG:04974`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:1900046`
## $`GO:1900046`$name
## [1] "GO:1900046"
## 
## $`GO:1900046`$EM2_GS_DESCR
## [1] "REGULATION OF HEMOSTASIS"
## 
## $`GO:1900046`$EM2_Formatted_name
## [1] "GO:1900046\n"
## 
## $`GO:1900046`$EM2_Name
## [1] "GO:1900046"
## 
## $`GO:1900046`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1900046`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1900046`$EM2_pvalue_dataset1
## [1] 1.91e-06
## 
## $`GO:1900046`$EM2_Colouring_dataset1
## [1] 0.9999981
## 
## $`GO:1900046`$EM2_fdr_qvalue_dataset1
## [1] 1.91e-06
## 
## $`GO:1900046`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:1901136`
## $`GO:1901136`$name
## [1] "GO:1901136"
## 
## $`GO:1901136`$EM2_GS_DESCR
## [1] "CARBOHYDRATE DERIVATIVE CATABOLIC PROCESS"
## 
## $`GO:1901136`$EM2_Formatted_name
## [1] "GO:1901136\n"
## 
## $`GO:1901136`$EM2_Name
## [1] "GO:1901136"
## 
## $`GO:1901136`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1901136`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1901136`$EM2_pvalue_dataset1
## [1] 6.54e-06
## 
## $`GO:1901136`$EM2_Colouring_dataset1
## [1] 0.9999935
## 
## $`GO:1901136`$EM2_fdr_qvalue_dataset1
## [1] 6.54e-06
## 
## $`GO:1901136`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:1900047`
## $`GO:1900047`$name
## [1] "GO:1900047"
## 
## $`GO:1900047`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF HEMOSTASIS"
## 
## $`GO:1900047`$EM2_Formatted_name
## [1] "GO:1900047\n"
## 
## $`GO:1900047`$EM2_Name
## [1] "GO:1900047"
## 
## $`GO:1900047`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1900047`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1900047`$EM2_pvalue_dataset1
## [1] 3.43e-06
## 
## $`GO:1900047`$EM2_Colouring_dataset1
## [1] 0.9999966
## 
## $`GO:1900047`$EM2_fdr_qvalue_dataset1
## [1] 3.43e-06
## 
## $`GO:1900047`$EM2_gs_size_dataset1
## [1] 8
## 
## 
## $`GO:0022617`
## $`GO:0022617`$name
## [1] "GO:0022617"
## 
## $`GO:0022617`$EM2_GS_DESCR
## [1] "EXTRACELLULAR MATRIX DISASSEMBLY"
## 
## $`GO:0022617`$EM2_Formatted_name
## [1] "GO:0022617\n"
## 
## $`GO:0022617`$EM2_Name
## [1] "GO:0022617"
## 
## $`GO:0022617`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0022617`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0022617`$EM2_pvalue_dataset1
## [1] 9.67e-29
## 
## $`GO:0022617`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0022617`$EM2_fdr_qvalue_dataset1
## [1] 9.67e-29
## 
## $`GO:0022617`$EM2_gs_size_dataset1
## [1] 42
## 
## 
## $`GO:0010770`
## $`GO:0010770`$name
## [1] "GO:0010770"
## 
## $`GO:0010770`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF CELL MORPHOGENESIS INVOLVED IN DIFFERENTIATION"
## 
## $`GO:0010770`$EM2_Formatted_name
## [1] "GO:0010770\n"
## 
## $`GO:0010770`$EM2_Name
## [1] "GO:0010770"
## 
## $`GO:0010770`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010770`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010770`$EM2_pvalue_dataset1
## [1] 2.05e-06
## 
## $`GO:0010770`$EM2_Colouring_dataset1
## [1] 0.999998
## 
## $`GO:0010770`$EM2_fdr_qvalue_dataset1
## [1] 2.05e-06
## 
## $`GO:0010770`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0031214`
## $`GO:0031214`$name
## [1] "GO:0031214"
## 
## $`GO:0031214`$EM2_GS_DESCR
## [1] "BIOMINERAL TISSUE DEVELOPMENT"
## 
## $`GO:0031214`$EM2_Formatted_name
## [1] "GO:0031214\n"
## 
## $`GO:0031214`$EM2_Name
## [1] "GO:0031214"
## 
## $`GO:0031214`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0031214`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0031214`$EM2_pvalue_dataset1
## [1] 3.13e-07
## 
## $`GO:0031214`$EM2_Colouring_dataset1
## [1] 0.9999997
## 
## $`GO:0031214`$EM2_fdr_qvalue_dataset1
## [1] 3.13e-07
## 
## $`GO:0031214`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:0072009`
## $`GO:0072009`$name
## [1] "GO:0072009"
## 
## $`GO:0072009`$EM2_GS_DESCR
## [1] "NEPHRON EPITHELIUM DEVELOPMENT"
## 
## $`GO:0072009`$EM2_Formatted_name
## [1] "GO:0072009\n"
## 
## $`GO:0072009`$EM2_Name
## [1] "GO:0072009"
## 
## $`GO:0072009`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072009`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072009`$EM2_pvalue_dataset1
## [1] 9.08e-07
## 
## $`GO:0072009`$EM2_Colouring_dataset1
## [1] 0.9999991
## 
## $`GO:0072009`$EM2_fdr_qvalue_dataset1
## [1] 9.08e-07
## 
## $`GO:0072009`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`GO:0010631`
## $`GO:0010631`$name
## [1] "GO:0010631"
## 
## $`GO:0010631`$EM2_GS_DESCR
## [1] "EPITHELIAL CELL MIGRATION"
## 
## $`GO:0010631`$EM2_Formatted_name
## [1] "GO:0010631\n"
## 
## $`GO:0010631`$EM2_Name
## [1] "GO:0010631"
## 
## $`GO:0010631`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010631`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010631`$EM2_pvalue_dataset1
## [1] 9.99e-11
## 
## $`GO:0010631`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0010631`$EM2_fdr_qvalue_dataset1
## [1] 9.99e-11
## 
## $`GO:0010631`$EM2_gs_size_dataset1
## [1] 32
## 
## 
## $`GO:0010634`
## $`GO:0010634`$name
## [1] "GO:0010634"
## 
## $`GO:0010634`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF EPITHELIAL CELL MIGRATION"
## 
## $`GO:0010634`$EM2_Formatted_name
## [1] "GO:0010634\n"
## 
## $`GO:0010634`$EM2_Name
## [1] "GO:0010634"
## 
## $`GO:0010634`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010634`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010634`$EM2_pvalue_dataset1
## [1] 2.08e-06
## 
## $`GO:0010634`$EM2_Colouring_dataset1
## [1] 0.9999979
## 
## $`GO:0010634`$EM2_fdr_qvalue_dataset1
## [1] 2.08e-06
## 
## $`GO:0010634`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0072006`
## $`GO:0072006`$name
## [1] "GO:0072006"
## 
## $`GO:0072006`$EM2_GS_DESCR
## [1] "NEPHRON DEVELOPMENT"
## 
## $`GO:0072006`$EM2_Formatted_name
## [1] "GO:0072006\n"
## 
## $`GO:0072006`$EM2_Name
## [1] "GO:0072006"
## 
## $`GO:0072006`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072006`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072006`$EM2_pvalue_dataset1
## [1] 2.61e-09
## 
## $`GO:0072006`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0072006`$EM2_fdr_qvalue_dataset1
## [1] 2.61e-09
## 
## $`GO:0072006`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0071711`
## $`GO:0071711`$name
## [1] "GO:0071711"
## 
## $`GO:0071711`$EM2_GS_DESCR
## [1] "BASEMENT MEMBRANE ORGANIZATION"
## 
## $`GO:0071711`$EM2_Formatted_name
## [1] "GO:0071711\n"
## 
## $`GO:0071711`$EM2_Name
## [1] "GO:0071711"
## 
## $`GO:0071711`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0071711`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0071711`$EM2_pvalue_dataset1
## [1] 6.52e-06
## 
## $`GO:0071711`$EM2_Colouring_dataset1
## [1] 0.9999935
## 
## $`GO:0071711`$EM2_fdr_qvalue_dataset1
## [1] 6.52e-06
## 
## $`GO:0071711`$EM2_gs_size_dataset1
## [1] 5
## 
## 
## $`GO:0010632`
## $`GO:0010632`$name
## [1] "GO:0010632"
## 
## $`GO:0010632`$EM2_GS_DESCR
## [1] "REGULATION OF EPITHELIAL CELL MIGRATION"
## 
## $`GO:0010632`$EM2_Formatted_name
## [1] "GO:0010632\n"
## 
## $`GO:0010632`$EM2_Name
## [1] "GO:0010632"
## 
## $`GO:0010632`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0010632`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0010632`$EM2_pvalue_dataset1
## [1] 2.26e-06
## 
## $`GO:0010632`$EM2_Colouring_dataset1
## [1] 0.9999977
## 
## $`GO:0010632`$EM2_fdr_qvalue_dataset1
## [1] 2.26e-06
## 
## $`GO:0010632`$EM2_gs_size_dataset1
## [1] 21
## 
## 
## $`GO:0072001`
## $`GO:0072001`$name
## [1] "GO:0072001"
## 
## $`GO:0072001`$EM2_GS_DESCR
## [1] "RENAL SYSTEM DEVELOPMENT"
## 
## $`GO:0072001`$EM2_Formatted_name
## [1] "GO:0072001\n"
## 
## $`GO:0072001`$EM2_Name
## [1] "GO:0072001"
## 
## $`GO:0072001`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072001`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072001`$EM2_pvalue_dataset1
## [1] 5.78e-12
## 
## $`GO:0072001`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0072001`$EM2_fdr_qvalue_dataset1
## [1] 5.78e-12
## 
## $`GO:0072001`$EM2_gs_size_dataset1
## [1] 28
## 
## 
## $`GO:0060828`
## $`GO:0060828`$name
## [1] "GO:0060828"
## 
## $`GO:0060828`$EM2_GS_DESCR
## [1] "REGULATION OF CANONICAL WNT SIGNALING PATHWAY"
## 
## $`GO:0060828`$EM2_Formatted_name
## [1] "GO:0060828\n"
## 
## $`GO:0060828`$EM2_Name
## [1] "GO:0060828"
## 
## $`GO:0060828`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060828`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060828`$EM2_pvalue_dataset1
## [1] 2.13e-08
## 
## $`GO:0060828`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0060828`$EM2_fdr_qvalue_dataset1
## [1] 2.13e-08
## 
## $`GO:0060828`$EM2_gs_size_dataset1
## [1] 29
## 
## 
## $`GO:0002576`
## $`GO:0002576`$name
## [1] "GO:0002576"
## 
## $`GO:0002576`$EM2_GS_DESCR
## [1] "PLATELET DEGRANULATION"
## 
## $`GO:0002576`$EM2_Formatted_name
## [1] "GO:0002576\n"
## 
## $`GO:0002576`$EM2_Name
## [1] "GO:0002576"
## 
## $`GO:0002576`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0002576`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0002576`$EM2_pvalue_dataset1
## [1] 6.57e-08
## 
## $`GO:0002576`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0002576`$EM2_fdr_qvalue_dataset1
## [1] 6.57e-08
## 
## $`GO:0002576`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0006027`
## $`GO:0006027`$name
## [1] "GO:0006027"
## 
## $`GO:0006027`$EM2_GS_DESCR
## [1] "GLYCOSAMINOGLYCAN CATABOLIC PROCESS"
## 
## $`GO:0006027`$EM2_Formatted_name
## [1] "GO:0006027\n"
## 
## $`GO:0006027`$EM2_Name
## [1] "GO:0006027"
## 
## $`GO:0006027`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0006027`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0006027`$EM2_pvalue_dataset1
## [1] 3.07e-08
## 
## $`GO:0006027`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0006027`$EM2_fdr_qvalue_dataset1
## [1] 3.07e-08
## 
## $`GO:0006027`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0006026`
## $`GO:0006026`$name
## [1] "GO:0006026"
## 
## $`GO:0006026`$EM2_GS_DESCR
## [1] "AMINOGLYCAN CATABOLIC PROCESS"
## 
## $`GO:0006026`$EM2_Formatted_name
## [1] "GO:0006026\n"
## 
## $`GO:0006026`$EM2_Name
## [1] "GO:0006026"
## 
## $`GO:0006026`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0006026`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0006026`$EM2_pvalue_dataset1
## [1] 9.11e-08
## 
## $`GO:0006026`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0006026`$EM2_fdr_qvalue_dataset1
## [1] 9.11e-08
## 
## $`GO:0006026`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0045667`
## $`GO:0045667`$name
## [1] "GO:0045667"
## 
## $`GO:0045667`$EM2_GS_DESCR
## [1] "REGULATION OF OSTEOBLAST DIFFERENTIATION"
## 
## $`GO:0045667`$EM2_Formatted_name
## [1] "GO:0045667\n"
## 
## $`GO:0045667`$EM2_Name
## [1] "GO:0045667"
## 
## $`GO:0045667`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045667`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045667`$EM2_pvalue_dataset1
## [1] 1.03e-09
## 
## $`GO:0045667`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0045667`$EM2_fdr_qvalue_dataset1
## [1] 1.03e-09
## 
## $`GO:0045667`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0006029`
## $`GO:0006029`$name
## [1] "GO:0006029"
## 
## $`GO:0006029`$EM2_GS_DESCR
## [1] "PROTEOGLYCAN METABOLIC PROCESS"
## 
## $`GO:0006029`$EM2_Formatted_name
## [1] "GO:0006029\n"
## 
## $`GO:0006029`$EM2_Name
## [1] "GO:0006029"
## 
## $`GO:0006029`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0006029`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0006029`$EM2_pvalue_dataset1
## [1] 4.09e-11
## 
## $`GO:0006029`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0006029`$EM2_fdr_qvalue_dataset1
## [1] 4.09e-11
## 
## $`GO:0006029`$EM2_gs_size_dataset1
## [1] 21
## 
## 
## $`GO:0045669`
## $`GO:0045669`$name
## [1] "GO:0045669"
## 
## $`GO:0045669`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF OSTEOBLAST DIFFERENTIATION"
## 
## $`GO:0045669`$EM2_Formatted_name
## [1] "GO:0045669\n"
## 
## $`GO:0045669`$EM2_Name
## [1] "GO:0045669"
## 
## $`GO:0045669`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045669`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045669`$EM2_pvalue_dataset1
## [1] 2.88e-07
## 
## $`GO:0045669`$EM2_Colouring_dataset1
## [1] 0.9999997
## 
## $`GO:0045669`$EM2_fdr_qvalue_dataset1
## [1] 2.88e-07
## 
## $`GO:0045669`$EM2_gs_size_dataset1
## [1] 12
## 
## 
## $`GO:0006023`
## $`GO:0006023`$name
## [1] "GO:0006023"
## 
## $`GO:0006023`$EM2_GS_DESCR
## [1] "AMINOGLYCAN BIOSYNTHETIC PROCESS"
## 
## $`GO:0006023`$EM2_Formatted_name
## [1] "GO:0006023\n"
## 
## $`GO:0006023`$EM2_Name
## [1] "GO:0006023"
## 
## $`GO:0006023`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0006023`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0006023`$EM2_pvalue_dataset1
## [1] 5.47e-14
## 
## $`GO:0006023`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0006023`$EM2_fdr_qvalue_dataset1
## [1] 5.47e-14
## 
## $`GO:0006023`$EM2_gs_size_dataset1
## [1] 29
## 
## 
## $`GO:0045664`
## $`GO:0045664`$name
## [1] "GO:0045664"
## 
## $`GO:0045664`$EM2_GS_DESCR
## [1] "REGULATION OF NEURON DIFFERENTIATION"
## 
## $`GO:0045664`$EM2_Formatted_name
## [1] "GO:0045664\n"
## 
## $`GO:0045664`$EM2_Name
## [1] "GO:0045664"
## 
## $`GO:0045664`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045664`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045664`$EM2_pvalue_dataset1
## [1] 1.04e-06
## 
## $`GO:0045664`$EM2_Colouring_dataset1
## [1] 0.999999
## 
## $`GO:0045664`$EM2_fdr_qvalue_dataset1
## [1] 1.04e-06
## 
## $`GO:0045664`$EM2_gs_size_dataset1
## [1] 24
## 
## 
## $`GO:0045785`
## $`GO:0045785`$name
## [1] "GO:0045785"
## 
## $`GO:0045785`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF CELL ADHESION"
## 
## $`GO:0045785`$EM2_Formatted_name
## [1] "GO:0045785\n"
## 
## $`GO:0045785`$EM2_Name
## [1] "GO:0045785"
## 
## $`GO:0045785`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045785`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045785`$EM2_pvalue_dataset1
## [1] 1.79e-06
## 
## $`GO:0045785`$EM2_Colouring_dataset1
## [1] 0.9999982
## 
## $`GO:0045785`$EM2_fdr_qvalue_dataset1
## [1] 1.79e-06
## 
## $`GO:0045785`$EM2_gs_size_dataset1
## [1] 32
## 
## 
## $`GO:0006022`
## $`GO:0006022`$name
## [1] "GO:0006022"
## 
## $`GO:0006022`$EM2_GS_DESCR
## [1] "AMINOGLYCAN METABOLIC PROCESS"
## 
## $`GO:0006022`$EM2_Formatted_name
## [1] "GO:0006022\n"
## 
## $`GO:0006022`$EM2_Name
## [1] "GO:0006022"
## 
## $`GO:0006022`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0006022`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0006022`$EM2_pvalue_dataset1
## [1] 1.8e-11
## 
## $`GO:0006022`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0006022`$EM2_fdr_qvalue_dataset1
## [1] 1.8e-11
## 
## $`GO:0006022`$EM2_gs_size_dataset1
## [1] 31
## 
## 
## $`GO:0006024`
## $`GO:0006024`$name
## [1] "GO:0006024"
## 
## $`GO:0006024`$EM2_GS_DESCR
## [1] "GLYCOSAMINOGLYCAN BIOSYNTHETIC PROCESS"
## 
## $`GO:0006024`$EM2_Formatted_name
## [1] "GO:0006024\n"
## 
## $`GO:0006024`$EM2_Name
## [1] "GO:0006024"
## 
## $`GO:0006024`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0006024`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0006024`$EM2_pvalue_dataset1
## [1] 4.15e-14
## 
## $`GO:0006024`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0006024`$EM2_fdr_qvalue_dataset1
## [1] 4.15e-14
## 
## $`GO:0006024`$EM2_gs_size_dataset1
## [1] 29
## 
## 
## $`GO:0045665`
## $`GO:0045665`$name
## [1] "GO:0045665"
## 
## $`GO:0045665`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF NEURON DIFFERENTIATION"
## 
## $`GO:0045665`$EM2_Formatted_name
## [1] "GO:0045665\n"
## 
## $`GO:0045665`$EM2_Name
## [1] "GO:0045665"
## 
## $`GO:0045665`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045665`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045665`$EM2_pvalue_dataset1
## [1] 4.26e-06
## 
## $`GO:0045665`$EM2_Colouring_dataset1
## [1] 0.9999957
## 
## $`GO:0045665`$EM2_fdr_qvalue_dataset1
## [1] 4.26e-06
## 
## $`GO:0045665`$EM2_gs_size_dataset1
## [1] 12
## 
## 
## $`REAC:3560801`
## $`REAC:3560801`$name
## [1] "REAC:3560801"
## 
## $`REAC:3560801`$EM2_GS_DESCR
## [1] "DEFECTIVE B3GAT3 CAUSES JDSSDHD"
## 
## $`REAC:3560801`$EM2_Formatted_name
## [1] "REAC:3560801\n"
## 
## $`REAC:3560801`$EM2_Name
## [1] "REAC:3560801"
## 
## $`REAC:3560801`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:3560801`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:3560801`$EM2_pvalue_dataset1
## [1] 7.08e-09
## 
## $`REAC:3560801`$EM2_Colouring_dataset1
## [1] 1
## 
## $`REAC:3560801`$EM2_fdr_qvalue_dataset1
## [1] 7.08e-09
## 
## $`REAC:3560801`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0043009`
## $`GO:0043009`$name
## [1] "GO:0043009"
## 
## $`GO:0043009`$EM2_GS_DESCR
## [1] "CHORDATE EMBRYONIC DEVELOPMENT"
## 
## $`GO:0043009`$EM2_Formatted_name
## [1] "GO:0043009\n"
## 
## $`GO:0043009`$EM2_Name
## [1] "GO:0043009"
## 
## $`GO:0043009`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0043009`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0043009`$EM2_pvalue_dataset1
## [1] 2.33e-09
## 
## $`GO:0043009`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0043009`$EM2_fdr_qvalue_dataset1
## [1] 2.33e-09
## 
## $`GO:0043009`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:0031345`
## $`GO:0031345`$name
## [1] "GO:0031345"
## 
## $`GO:0031345`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELL PROJECTION ORGANIZATION"
## 
## $`GO:0031345`$EM2_Formatted_name
## [1] "GO:0031345\n"
## 
## $`GO:0031345`$EM2_Name
## [1] "GO:0031345"
## 
## $`GO:0031345`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0031345`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0031345`$EM2_pvalue_dataset1
## [1] 3.45e-06
## 
## $`GO:0031345`$EM2_Colouring_dataset1
## [1] 0.9999965
## 
## $`GO:0031345`$EM2_fdr_qvalue_dataset1
## [1] 3.45e-06
## 
## $`GO:0031345`$EM2_gs_size_dataset1
## [1] 12
## 
## 
## $`GO:0031589`
## $`GO:0031589`$name
## [1] "GO:0031589"
## 
## $`GO:0031589`$EM2_GS_DESCR
## [1] "CELL-SUBSTRATE ADHESION"
## 
## $`GO:0031589`$EM2_Formatted_name
## [1] "GO:0031589\n"
## 
## $`GO:0031589`$EM2_Name
## [1] "GO:0031589"
## 
## $`GO:0031589`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0031589`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0031589`$EM2_pvalue_dataset1
## [1] 1.72e-14
## 
## $`GO:0031589`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0031589`$EM2_fdr_qvalue_dataset1
## [1] 1.72e-14
## 
## $`GO:0031589`$EM2_gs_size_dataset1
## [1] 42
## 
## 
## $`REAC:1442490`
## $`REAC:1442490`$name
## [1] "REAC:1442490"
## 
## $`REAC:1442490`$EM2_GS_DESCR
## [1] "COLLAGEN DEGRADATION"
## 
## $`REAC:1442490`$EM2_Formatted_name
## [1] "REAC:1442490\n"
## 
## $`REAC:1442490`$EM2_Name
## [1] "REAC:1442490"
## 
## $`REAC:1442490`$EM2_GS_Source
## [1] "none"
## 
## $`REAC:1442490`$EM2_GS_Type
## [1] "ENR"
## 
## $`REAC:1442490`$EM2_pvalue_dataset1
## [1] 5.2e-06
## 
## $`REAC:1442490`$EM2_Colouring_dataset1
## [1] 0.9999948
## 
## $`REAC:1442490`$EM2_fdr_qvalue_dataset1
## [1] 5.2e-06
## 
## $`REAC:1442490`$EM2_gs_size_dataset1
## [1] 10
## 
## 
## $`GO:0001837`
## $`GO:0001837`$name
## [1] "GO:0001837"
## 
## $`GO:0001837`$EM2_GS_DESCR
## [1] "EPITHELIAL TO MESENCHYMAL TRANSITION"
## 
## $`GO:0001837`$EM2_Formatted_name
## [1] "GO:0001837\n"
## 
## $`GO:0001837`$EM2_Name
## [1] "GO:0001837"
## 
## $`GO:0001837`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001837`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001837`$EM2_pvalue_dataset1
## [1] 8.15e-11
## 
## $`GO:0001837`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001837`$EM2_fdr_qvalue_dataset1
## [1] 8.15e-11
## 
## $`GO:0001837`$EM2_gs_size_dataset1
## [1] 24
## 
## 
## $`GO:0072210`
## $`GO:0072210`$name
## [1] "GO:0072210"
## 
## $`GO:0072210`$EM2_GS_DESCR
## [1] "METANEPHRIC NEPHRON DEVELOPMENT"
## 
## $`GO:0072210`$EM2_Formatted_name
## [1] "GO:0072210\n"
## 
## $`GO:0072210`$EM2_Name
## [1] "GO:0072210"
## 
## $`GO:0072210`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072210`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072210`$EM2_pvalue_dataset1
## [1] 7.74e-07
## 
## $`GO:0072210`$EM2_Colouring_dataset1
## [1] 0.9999992
## 
## $`GO:0072210`$EM2_fdr_qvalue_dataset1
## [1] 7.74e-07
## 
## $`GO:0072210`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0002009`
## $`GO:0002009`$name
## [1] "GO:0002009"
## 
## $`GO:0002009`$EM2_GS_DESCR
## [1] "MORPHOGENESIS OF AN EPITHELIUM"
## 
## $`GO:0002009`$EM2_Formatted_name
## [1] "GO:0002009\n"
## 
## $`GO:0002009`$EM2_Name
## [1] "GO:0002009"
## 
## $`GO:0002009`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0002009`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0002009`$EM2_pvalue_dataset1
## [1] 5.81e-13
## 
## $`GO:0002009`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0002009`$EM2_fdr_qvalue_dataset1
## [1] 5.81e-13
## 
## $`GO:0002009`$EM2_gs_size_dataset1
## [1] 37
## 
## 
## $`GO:0001952`
## $`GO:0001952`$name
## [1] "GO:0001952"
## 
## $`GO:0001952`$EM2_GS_DESCR
## [1] "REGULATION OF CELL-MATRIX ADHESION"
## 
## $`GO:0001952`$EM2_Formatted_name
## [1] "GO:0001952\n"
## 
## $`GO:0001952`$EM2_Name
## [1] "GO:0001952"
## 
## $`GO:0001952`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001952`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001952`$EM2_pvalue_dataset1
## [1] 5.84e-07
## 
## $`GO:0001952`$EM2_Colouring_dataset1
## [1] 0.9999994
## 
## $`GO:0001952`$EM2_fdr_qvalue_dataset1
## [1] 5.84e-07
## 
## $`GO:0001952`$EM2_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0045778`
## $`GO:0045778`$name
## [1] "GO:0045778"
## 
## $`GO:0045778`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF OSSIFICATION"
## 
## $`GO:0045778`$EM2_Formatted_name
## [1] "GO:0045778\n"
## 
## $`GO:0045778`$EM2_Name
## [1] "GO:0045778"
## 
## $`GO:0045778`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045778`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045778`$EM2_pvalue_dataset1
## [1] 3.58e-06
## 
## $`GO:0045778`$EM2_Colouring_dataset1
## [1] 0.9999964
## 
## $`GO:0045778`$EM2_fdr_qvalue_dataset1
## [1] 3.58e-06
## 
## $`GO:0045778`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0061448`
## $`GO:0061448`$name
## [1] "GO:0061448"
## 
## $`GO:0061448`$EM2_GS_DESCR
## [1] "CONNECTIVE TISSUE DEVELOPMENT"
## 
## $`GO:0061448`$EM2_Formatted_name
## [1] "GO:0061448\n"
## 
## $`GO:0061448`$EM2_Name
## [1] "GO:0061448"
## 
## $`GO:0061448`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061448`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061448`$EM2_pvalue_dataset1
## [1] 3.44e-11
## 
## $`GO:0061448`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0061448`$EM2_fdr_qvalue_dataset1
## [1] 3.44e-11
## 
## $`GO:0061448`$EM2_gs_size_dataset1
## [1] 23
## 
## 
## $`GO:0061326`
## $`GO:0061326`$name
## [1] "GO:0061326"
## 
## $`GO:0061326`$EM2_GS_DESCR
## [1] "RENAL TUBULE DEVELOPMENT"
## 
## $`GO:0061326`$EM2_Formatted_name
## [1] "GO:0061326\n"
## 
## $`GO:0061326`$EM2_Name
## [1] "GO:0061326"
## 
## $`GO:0061326`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061326`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061326`$EM2_pvalue_dataset1
## [1] 2.47e-06
## 
## $`GO:0061326`$EM2_Colouring_dataset1
## [1] 0.9999975
## 
## $`GO:0061326`$EM2_fdr_qvalue_dataset1
## [1] 2.47e-06
## 
## $`GO:0061326`$EM2_gs_size_dataset1
## [1] 12
## 
## 
## $`KEGG:04514`
## $`KEGG:04514`$name
## [1] "KEGG:04514"
## 
## $`KEGG:04514`$EM2_GS_DESCR
## [1] "CELL ADHESION MOLECULES (CAMS)"
## 
## $`KEGG:04514`$EM2_Formatted_name
## [1] "KEGG:04514\n"
## 
## $`KEGG:04514`$EM2_Name
## [1] "KEGG:04514"
## 
## $`KEGG:04514`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:04514`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:04514`$EM2_pvalue_dataset1
## [1] 2.98e-07
## 
## $`KEGG:04514`$EM2_Colouring_dataset1
## [1] 0.9999997
## 
## $`KEGG:04514`$EM2_fdr_qvalue_dataset1
## [1] 2.98e-07
## 
## $`KEGG:04514`$EM2_gs_size_dataset1
## [1] 24
## 
## 
## $`KEGG:04512`
## $`KEGG:04512`$name
## [1] "KEGG:04512"
## 
## $`KEGG:04512`$EM2_GS_DESCR
## [1] "ECM-RECEPTOR INTERACTION"
## 
## $`KEGG:04512`$EM2_Formatted_name
## [1] "KEGG:04512\n"
## 
## $`KEGG:04512`$EM2_Name
## [1] "KEGG:04512"
## 
## $`KEGG:04512`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:04512`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:04512`$EM2_pvalue_dataset1
## [1] 2.63e-15
## 
## $`KEGG:04512`$EM2_Colouring_dataset1
## [1] 1
## 
## $`KEGG:04512`$EM2_fdr_qvalue_dataset1
## [1] 2.63e-15
## 
## $`KEGG:04512`$EM2_gs_size_dataset1
## [1] 28
## 
## 
## $`KEGG:04510`
## $`KEGG:04510`$name
## [1] "KEGG:04510"
## 
## $`KEGG:04510`$EM2_GS_DESCR
## [1] "FOCAL ADHESION"
## 
## $`KEGG:04510`$EM2_Formatted_name
## [1] "KEGG:04510\n"
## 
## $`KEGG:04510`$EM2_Name
## [1] "KEGG:04510"
## 
## $`KEGG:04510`$EM2_GS_Source
## [1] "none"
## 
## $`KEGG:04510`$EM2_GS_Type
## [1] "ENR"
## 
## $`KEGG:04510`$EM2_pvalue_dataset1
## [1] 5.35e-16
## 
## $`KEGG:04510`$EM2_Colouring_dataset1
## [1] 1
## 
## $`KEGG:04510`$EM2_fdr_qvalue_dataset1
## [1] 5.35e-16
## 
## $`KEGG:04510`$EM2_gs_size_dataset1
## [1] 45
## 
## 
## $`GO:0048008`
## $`GO:0048008`$name
## [1] "GO:0048008"
## 
## $`GO:0048008`$EM2_GS_DESCR
## [1] "PLATELET-DERIVED GROWTH FACTOR RECEPTOR SIGNALING PATHWAY"
## 
## $`GO:0048008`$EM2_Formatted_name
## [1] "GO:0048008\n"
## 
## $`GO:0048008`$EM2_Name
## [1] "GO:0048008"
## 
## $`GO:0048008`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0048008`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0048008`$EM2_pvalue_dataset1
## [1] 5.06e-07
## 
## $`GO:0048008`$EM2_Colouring_dataset1
## [1] 0.9999995
## 
## $`GO:0048008`$EM2_fdr_qvalue_dataset1
## [1] 5.06e-07
## 
## $`GO:0048008`$EM2_gs_size_dataset1
## [1] 9
## 
## 
## $`GO:0090101`
## $`GO:0090101`$name
## [1] "GO:0090101"
## 
## $`GO:0090101`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF TRANSMEMBRANE RECEPTOR PROTEIN SERINE/THREONINE KINASE SIGNALING PATHWAY"
## 
## $`GO:0090101`$EM2_Formatted_name
## [1] "GO:0090101\n"
## 
## $`GO:0090101`$EM2_Name
## [1] "GO:0090101"
## 
## $`GO:0090101`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0090101`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0090101`$EM2_pvalue_dataset1
## [1] 1.97e-06
## 
## $`GO:0090101`$EM2_Colouring_dataset1
## [1] 0.999998
## 
## $`GO:0090101`$EM2_fdr_qvalue_dataset1
## [1] 1.97e-06
## 
## $`GO:0090101`$EM2_gs_size_dataset1
## [1] 14
## 
## 
## $`GO:0061440`
## $`GO:0061440`$name
## [1] "GO:0061440"
## 
## $`GO:0061440`$EM2_GS_DESCR
## [1] "KIDNEY VASCULATURE DEVELOPMENT"
## 
## $`GO:0061440`$EM2_Formatted_name
## [1] "GO:0061440\n"
## 
## $`GO:0061440`$EM2_Name
## [1] "GO:0061440"
## 
## $`GO:0061440`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061440`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061440`$EM2_pvalue_dataset1
## [1] 1.07e-07
## 
## $`GO:0061440`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0061440`$EM2_fdr_qvalue_dataset1
## [1] 1.07e-07
## 
## $`GO:0061440`$EM2_gs_size_dataset1
## [1] 7
## 
## 
## $`GO:0050679`
## $`GO:0050679`$name
## [1] "GO:0050679"
## 
## $`GO:0050679`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF EPITHELIAL CELL PROLIFERATION"
## 
## $`GO:0050679`$EM2_Formatted_name
## [1] "GO:0050679\n"
## 
## $`GO:0050679`$EM2_Name
## [1] "GO:0050679"
## 
## $`GO:0050679`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050679`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050679`$EM2_pvalue_dataset1
## [1] 1.3e-07
## 
## $`GO:0050679`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0050679`$EM2_fdr_qvalue_dataset1
## [1] 1.3e-07
## 
## $`GO:0050679`$EM2_gs_size_dataset1
## [1] 20
## 
## 
## $`GO:0050678`
## $`GO:0050678`$name
## [1] "GO:0050678"
## 
## $`GO:0050678`$EM2_GS_DESCR
## [1] "REGULATION OF EPITHELIAL CELL PROLIFERATION"
## 
## $`GO:0050678`$EM2_Formatted_name
## [1] "GO:0050678\n"
## 
## $`GO:0050678`$EM2_Name
## [1] "GO:0050678"
## 
## $`GO:0050678`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050678`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050678`$EM2_pvalue_dataset1
## [1] 5.03e-09
## 
## $`GO:0050678`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0050678`$EM2_fdr_qvalue_dataset1
## [1] 5.03e-09
## 
## $`GO:0050678`$EM2_gs_size_dataset1
## [1] 29
## 
## 
## $`GO:0072104`
## $`GO:0072104`$name
## [1] "GO:0072104"
## 
## $`GO:0072104`$EM2_GS_DESCR
## [1] "GLOMERULAR CAPILLARY FORMATION"
## 
## $`GO:0072104`$EM2_Formatted_name
## [1] "GO:0072104\n"
## 
## $`GO:0072104`$EM2_Name
## [1] "GO:0072104"
## 
## $`GO:0072104`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072104`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072104`$EM2_pvalue_dataset1
## [1] 1.37e-06
## 
## $`GO:0072104`$EM2_Colouring_dataset1
## [1] 0.9999986
## 
## $`GO:0072104`$EM2_fdr_qvalue_dataset1
## [1] 1.37e-06
## 
## $`GO:0072104`$EM2_gs_size_dataset1
## [1] 4
## 
## 
## $`GO:0001706`
## $`GO:0001706`$name
## [1] "GO:0001706"
## 
## $`GO:0001706`$EM2_GS_DESCR
## [1] "ENDODERM FORMATION"
## 
## $`GO:0001706`$EM2_Formatted_name
## [1] "GO:0001706\n"
## 
## $`GO:0001706`$EM2_Name
## [1] "GO:0001706"
## 
## $`GO:0001706`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001706`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001706`$EM2_pvalue_dataset1
## [1] 4.85e-12
## 
## $`GO:0001706`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001706`$EM2_fdr_qvalue_dataset1
## [1] 4.85e-12
## 
## $`GO:0001706`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0001704`
## $`GO:0001704`$name
## [1] "GO:0001704"
## 
## $`GO:0001704`$EM2_GS_DESCR
## [1] "FORMATION OF PRIMARY GERM LAYER"
## 
## $`GO:0001704`$EM2_Formatted_name
## [1] "GO:0001704\n"
## 
## $`GO:0001704`$EM2_Name
## [1] "GO:0001704"
## 
## $`GO:0001704`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001704`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001704`$EM2_pvalue_dataset1
## [1] 1.25e-13
## 
## $`GO:0001704`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001704`$EM2_fdr_qvalue_dataset1
## [1] 1.25e-13
## 
## $`GO:0001704`$EM2_gs_size_dataset1
## [1] 24
## 
## 
## $`GO:0001823`
## $`GO:0001823`$name
## [1] "GO:0001823"
## 
## $`GO:0001823`$EM2_GS_DESCR
## [1] "MESONEPHROS DEVELOPMENT"
## 
## $`GO:0001823`$EM2_Formatted_name
## [1] "GO:0001823\n"
## 
## $`GO:0001823`$EM2_Name
## [1] "GO:0001823"
## 
## $`GO:0001823`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001823`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001823`$EM2_pvalue_dataset1
## [1] 1.32e-07
## 
## $`GO:0001823`$EM2_Colouring_dataset1
## [1] 0.9999999
## 
## $`GO:0001823`$EM2_fdr_qvalue_dataset1
## [1] 1.32e-07
## 
## $`GO:0001823`$EM2_gs_size_dataset1
## [1] 13
## 
## 
## $`GO:0001944`
## $`GO:0001944`$name
## [1] "GO:0001944"
## 
## $`GO:0001944`$EM2_GS_DESCR
## [1] "VASCULATURE DEVELOPMENT"
## 
## $`GO:0001944`$EM2_Formatted_name
## [1] "GO:0001944\n"
## 
## $`GO:0001944`$EM2_Name
## [1] "GO:0001944"
## 
## $`GO:0001944`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001944`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001944`$EM2_pvalue_dataset1
## [1] 1.59e-24
## 
## $`GO:0001944`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001944`$EM2_fdr_qvalue_dataset1
## [1] 1.59e-24
## 
## $`GO:0001944`$EM2_gs_size_dataset1
## [1] 66
## 
## 
## $`GO:0001822`
## $`GO:0001822`$name
## [1] "GO:0001822"
## 
## $`GO:0001822`$EM2_GS_DESCR
## [1] "KIDNEY DEVELOPMENT"
## 
## $`GO:0001822`$EM2_Formatted_name
## [1] "GO:0001822\n"
## 
## $`GO:0001822`$EM2_Name
## [1] "GO:0001822"
## 
## $`GO:0001822`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0001822`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0001822`$EM2_pvalue_dataset1
## [1] 3.85e-11
## 
## $`GO:0001822`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0001822`$EM2_fdr_qvalue_dataset1
## [1] 3.85e-11
## 
## $`GO:0001822`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:0072103`
## $`GO:0072103`$name
## [1] "GO:0072103"
## 
## $`GO:0072103`$EM2_GS_DESCR
## [1] "GLOMERULUS VASCULATURE MORPHOGENESIS"
## 
## $`GO:0072103`$EM2_Formatted_name
## [1] "GO:0072103\n"
## 
## $`GO:0072103`$EM2_Name
## [1] "GO:0072103"
## 
## $`GO:0072103`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0072103`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0072103`$EM2_pvalue_dataset1
## [1] 1.37e-06
## 
## $`GO:0072103`$EM2_Colouring_dataset1
## [1] 0.9999986
## 
## $`GO:0072103`$EM2_fdr_qvalue_dataset1
## [1] 1.37e-06
## 
## $`GO:0072103`$EM2_gs_size_dataset1
## [1] 4
## 
## 
## $`GO:0050673`
## $`GO:0050673`$name
## [1] "GO:0050673"
## 
## $`GO:0050673`$EM2_GS_DESCR
## [1] "EPITHELIAL CELL PROLIFERATION"
## 
## $`GO:0050673`$EM2_Formatted_name
## [1] "GO:0050673\n"
## 
## $`GO:0050673`$EM2_Name
## [1] "GO:0050673"
## 
## $`GO:0050673`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050673`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050673`$EM2_pvalue_dataset1
## [1] 6.77e-10
## 
## $`GO:0050673`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0050673`$EM2_fdr_qvalue_dataset1
## [1] 6.77e-10
## 
## $`GO:0050673`$EM2_gs_size_dataset1
## [1] 33
## 
## 
## $`GO:0030029`
## $`GO:0030029`$name
## [1] "GO:0030029"
## 
## $`GO:0030029`$EM2_GS_DESCR
## [1] "ACTIN FILAMENT-BASED PROCESS"
## 
## $`GO:0030029`$EM2_Formatted_name
## [1] "GO:0030029\n"
## 
## $`GO:0030029`$EM2_Name
## [1] "GO:0030029"
## 
## $`GO:0030029`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0030029`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0030029`$EM2_pvalue_dataset1
## [1] 3.47e-08
## 
## $`GO:0030029`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0030029`$EM2_fdr_qvalue_dataset1
## [1] 3.47e-08
## 
## $`GO:0030029`$EM2_gs_size_dataset1
## [1] 56
## 
## 
## $`GO:0050795`
## $`GO:0050795`$name
## [1] "GO:0050795"
## 
## $`GO:0050795`$EM2_GS_DESCR
## [1] "REGULATION OF BEHAVIOR"
## 
## $`GO:0050795`$EM2_Formatted_name
## [1] "GO:0050795\n"
## 
## $`GO:0050795`$EM2_Name
## [1] "GO:0050795"
## 
## $`GO:0050795`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0050795`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0050795`$EM2_pvalue_dataset1
## [1] 4.35e-07
## 
## $`GO:0050795`$EM2_Colouring_dataset1
## [1] 0.9999996
## 
## $`GO:0050795`$EM2_fdr_qvalue_dataset1
## [1] 4.35e-07
## 
## $`GO:0050795`$EM2_gs_size_dataset1
## [1] 18
## 
## 
## $`GO:0007259`
## $`GO:0007259`$name
## [1] "GO:0007259"
## 
## $`GO:0007259`$EM2_GS_DESCR
## [1] "JAK-STAT CASCADE"
## 
## $`GO:0007259`$EM2_Formatted_name
## [1] "GO:0007259\n"
## 
## $`GO:0007259`$EM2_Name
## [1] "GO:0007259"
## 
## $`GO:0007259`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007259`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007259`$EM2_pvalue_dataset1
## [1] 9.17e-06
## 
## $`GO:0007259`$EM2_Colouring_dataset1
## [1] 0.9999908
## 
## $`GO:0007259`$EM2_fdr_qvalue_dataset1
## [1] 9.17e-06
## 
## $`GO:0007259`$EM2_gs_size_dataset1
## [1] 21
## 
## 
## $`GO:0045766`
## $`GO:0045766`$name
## [1] "GO:0045766"
## 
## $`GO:0045766`$EM2_GS_DESCR
## [1] "POSITIVE REGULATION OF ANGIOGENESIS"
## 
## $`GO:0045766`$EM2_Formatted_name
## [1] "GO:0045766\n"
## 
## $`GO:0045766`$EM2_Name
## [1] "GO:0045766"
## 
## $`GO:0045766`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045766`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045766`$EM2_pvalue_dataset1
## [1] 6e-09
## 
## $`GO:0045766`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0045766`$EM2_fdr_qvalue_dataset1
## [1] 6e-09
## 
## $`GO:0045766`$EM2_gs_size_dataset1
## [1] 19
## 
## 
## $`GO:0051093`
## $`GO:0051093`$name
## [1] "GO:0051093"
## 
## $`GO:0051093`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF DEVELOPMENTAL PROCESS"
## 
## $`GO:0051093`$EM2_Formatted_name
## [1] "GO:0051093\n"
## 
## $`GO:0051093`$EM2_Name
## [1] "GO:0051093"
## 
## $`GO:0051093`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0051093`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0051093`$EM2_pvalue_dataset1
## [1] 5.53e-16
## 
## $`GO:0051093`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0051093`$EM2_fdr_qvalue_dataset1
## [1] 5.53e-16
## 
## $`GO:0051093`$EM2_gs_size_dataset1
## [1] 47
## 
## 
## $`GO:0045765`
## $`GO:0045765`$name
## [1] "GO:0045765"
## 
## $`GO:0045765`$EM2_GS_DESCR
## [1] "REGULATION OF ANGIOGENESIS"
## 
## $`GO:0045765`$EM2_Formatted_name
## [1] "GO:0045765\n"
## 
## $`GO:0045765`$EM2_Name
## [1] "GO:0045765"
## 
## $`GO:0045765`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0045765`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0045765`$EM2_pvalue_dataset1
## [1] 5.52e-10
## 
## $`GO:0045765`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0045765`$EM2_fdr_qvalue_dataset1
## [1] 5.52e-10
## 
## $`GO:0045765`$EM2_gs_size_dataset1
## [1] 28
## 
## 
## $`GO:1901342`
## $`GO:1901342`$name
## [1] "GO:1901342"
## 
## $`GO:1901342`$EM2_GS_DESCR
## [1] "REGULATION OF VASCULATURE DEVELOPMENT"
## 
## $`GO:1901342`$EM2_Formatted_name
## [1] "GO:1901342\n"
## 
## $`GO:1901342`$EM2_Name
## [1] "GO:1901342"
## 
## $`GO:1901342`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1901342`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1901342`$EM2_pvalue_dataset1
## [1] 2.86e-10
## 
## $`GO:1901342`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:1901342`$EM2_fdr_qvalue_dataset1
## [1] 2.86e-10
## 
## $`GO:1901342`$EM2_gs_size_dataset1
## [1] 30
## 
## 
## $`GO:0009792`
## $`GO:0009792`$name
## [1] "GO:0009792"
## 
## $`GO:0009792`$EM2_GS_DESCR
## [1] "EMBRYO DEVELOPMENT ENDING IN BIRTH OR EGG HATCHING"
## 
## $`GO:0009792`$EM2_Formatted_name
## [1] "GO:0009792\n"
## 
## $`GO:0009792`$EM2_Name
## [1] "GO:0009792"
## 
## $`GO:0009792`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0009792`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0009792`$EM2_pvalue_dataset1
## [1] 2.33e-09
## 
## $`GO:0009792`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0009792`$EM2_fdr_qvalue_dataset1
## [1] 2.33e-09
## 
## $`GO:0009792`$EM2_gs_size_dataset1
## [1] 27
## 
## 
## $`GO:1901343`
## $`GO:1901343`$name
## [1] "GO:1901343"
## 
## $`GO:1901343`$EM2_GS_DESCR
## [1] "NEGATIVE REGULATION OF VASCULATURE DEVELOPMENT"
## 
## $`GO:1901343`$EM2_Formatted_name
## [1] "GO:1901343\n"
## 
## $`GO:1901343`$EM2_Name
## [1] "GO:1901343"
## 
## $`GO:1901343`$EM2_GS_Source
## [1] "none"
## 
## $`GO:1901343`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:1901343`$EM2_pvalue_dataset1
## [1] 3.03e-06
## 
## $`GO:1901343`$EM2_Colouring_dataset1
## [1] 0.999997
## 
## $`GO:1901343`$EM2_fdr_qvalue_dataset1
## [1] 3.03e-06
## 
## $`GO:1901343`$EM2_gs_size_dataset1
## [1] 10
## 
## 
## $`GO:0007492`
## $`GO:0007492`$name
## [1] "GO:0007492"
## 
## $`GO:0007492`$EM2_GS_DESCR
## [1] "ENDODERM DEVELOPMENT"
## 
## $`GO:0007492`$EM2_Formatted_name
## [1] "GO:0007492\n"
## 
## $`GO:0007492`$EM2_Name
## [1] "GO:0007492"
## 
## $`GO:0007492`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0007492`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0007492`$EM2_pvalue_dataset1
## [1] 3.08e-11
## 
## $`GO:0007492`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0007492`$EM2_fdr_qvalue_dataset1
## [1] 3.08e-11
## 
## $`GO:0007492`$EM2_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0032330`
## $`GO:0032330`$name
## [1] "GO:0032330"
## 
## $`GO:0032330`$EM2_GS_DESCR
## [1] "REGULATION OF CHONDROCYTE DIFFERENTIATION"
## 
## $`GO:0032330`$EM2_Formatted_name
## [1] "GO:0032330\n"
## 
## $`GO:0032330`$EM2_Name
## [1] "GO:0032330"
## 
## $`GO:0032330`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0032330`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0032330`$EM2_pvalue_dataset1
## [1] 9.77e-07
## 
## $`GO:0032330`$EM2_Colouring_dataset1
## [1] 0.999999
## 
## $`GO:0032330`$EM2_fdr_qvalue_dataset1
## [1] 9.77e-07
## 
## $`GO:0032330`$EM2_gs_size_dataset1
## [1] 8
## 
## 
## $`GO:0061333`
## $`GO:0061333`$name
## [1] "GO:0061333"
## 
## $`GO:0061333`$EM2_GS_DESCR
## [1] "RENAL TUBULE MORPHOGENESIS"
## 
## $`GO:0061333`$EM2_Formatted_name
## [1] "GO:0061333\n"
## 
## $`GO:0061333`$EM2_Name
## [1] "GO:0061333"
## 
## $`GO:0061333`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0061333`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0061333`$EM2_pvalue_dataset1
## [1] 2.04e-06
## 
## $`GO:0061333`$EM2_Colouring_dataset1
## [1] 0.999998
## 
## $`GO:0061333`$EM2_fdr_qvalue_dataset1
## [1] 2.04e-06
## 
## $`GO:0061333`$EM2_gs_size_dataset1
## [1] 11
## 
## 
## $`GO:0060485`
## $`GO:0060485`$name
## [1] "GO:0060485"
## 
## $`GO:0060485`$EM2_GS_DESCR
## [1] "MESENCHYME DEVELOPMENT"
## 
## $`GO:0060485`$EM2_Formatted_name
## [1] "GO:0060485\n"
## 
## $`GO:0060485`$EM2_Name
## [1] "GO:0060485"
## 
## $`GO:0060485`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0060485`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0060485`$EM2_pvalue_dataset1
## [1] 1.26e-17
## 
## $`GO:0060485`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0060485`$EM2_fdr_qvalue_dataset1
## [1] 1.26e-17
## 
## $`GO:0060485`$EM2_gs_size_dataset1
## [1] 41
## 
## 
## $`GO:0009790`
## $`GO:0009790`$name
## [1] "GO:0009790"
## 
## $`GO:0009790`$EM2_GS_DESCR
## [1] "EMBRYO DEVELOPMENT"
## 
## $`GO:0009790`$EM2_Formatted_name
## [1] "GO:0009790\n"
## 
## $`GO:0009790`$EM2_Name
## [1] "GO:0009790"
## 
## $`GO:0009790`$EM2_GS_Source
## [1] "none"
## 
## $`GO:0009790`$EM2_GS_Type
## [1] "ENR"
## 
## $`GO:0009790`$EM2_pvalue_dataset1
## [1] 2.43e-20
## 
## $`GO:0009790`$EM2_Colouring_dataset1
## [1] 1
## 
## $`GO:0009790`$EM2_fdr_qvalue_dataset1
## [1] 2.43e-20
## 
## $`GO:0009790`$EM2_gs_size_dataset1
## [1] 66
```

```r
list_of_windows <- getWindowList(cy)
list_of_windows
```

```
## [1] "EM1_Enrichment Map" "EM2_Enrichment Map"
```

```r
## last created and then use that to connect to that window
## hard because suids are just given however?
		resource.uri <- paste(cy@uri,
		                      pluginVersion(cy),
		                      "networks",
		                      sep="/")
		request.res <- GET(resource.uri)
		# SUIDs list of the existing Cytoscape networks	
		cy.networks.SUIDs <- fromJSON(rawToChar(request.res$content))
		# most recently made enrichment map will have the highest SUID
		cy.networks.SUIDs.last <- max(cy.networks.SUIDs)
		
		res.uri.last <- paste(cy@uri,
		                      pluginVersion(cy),
		                      "networks",
		                      as.character(cy.networks.SUIDs.last),
		                      sep="/")
			result <- GET(res.uri.last)
			net.name <- fromJSON(rawToChar(result$content))$data$name

## here!!		
## so the suids seem to increase in number as they are made. ## so it is a matter of extracting them and then getting hte name and linking up to an existing window!

getWindowList(cy)
```

```
## [1] "EM1_Enrichment Map" "EM2_Enrichment Map"
```

```r
## how do I connect to that window??
getWindowID(cy,net.name)
```

```
## [1] "4124"
```

```r
## object needs to be a CytoscapeWindowClass object
## connect to existing window....
test_existing_window <- existing.CytoscapeWindow (net.name,
                                                  copy.graph.from.cytoscape.to.R=FALSE)

saveImage(test_existing_window,
          "test_EM_new",
          "png",
          scale=4)
```

![](./test_EM_new.png)


```r
enrichmentmap.url <- paste(base.url,
                           "commands",
                           "enrichmentmap",
                           "build",
                           sep="/") 

path_to_file="/home/julia_g/windows_school/gsoc/EM-tutorials-docker/notebooks/data/"

enr_file = paste(path_to_file,"gprofiler_results_mesenonly_ordered_computedinR.txt",sep="")

em_params <- list(analysisType = "generic",
                  enrichmentsDataset1 =enr_file,
                  pvalue="1.0",
                  qvalue="0.00001",
                  #expressionDataset1 = exp_file, 
                  similaritycutoff="0.25",
                  coeffecients="JACCARD")

response <- GET(url=enrichmentmap.url,
                query=em_params)
response$url
```

```
## [1] "http://localhost:1234/v1/commands/enrichmentmap/build?analysisType=generic&enrichmentsDataset1=%2Fhome%2Fjulia_g%2Fwindows_school%2Fgsoc%2FEM-tutorials-docker%2Fnotebooks%2Fdata%2Fgprofiler_results_mesenonly_ordered_computedinR.txt&pvalue=1.0&qvalue=0.00001&similaritycutoff=0.25&coeffecients=JACCARD"
```

## Next steps

- Verify that I have made these functions correctly for use in S4 framework
- Clean up the use of the functions
- EM with two inputs.- see tutorial for ideas
