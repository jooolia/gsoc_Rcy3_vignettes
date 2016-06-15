# recreating_enrichment_map_tut_with_RCy3
Julia Gustavsen  
May 24, 2016  

# Purpose: 

* Recreating tutorials from Bader lab (link) using Rcy3 and cytoscape.
* creating functions using RCy3 that make it easy to use Enrichment Map



```r
library(RCy3)
```

```
## Loading required package: graph
```

```r
library(httr)
library(RJSONIO)
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
## create function to get command names for available plugins from Cytoscape
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
            ## to remove "Available namespaces" title
            ## remove the first value
            available.commands <- available.commands[-1]
            return(available.commands) 
          })
```

```
## [1] "getCommandNames"
```

Test out the function to see what commands are available in Cytoscape

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

### Accessing the commands within Enrichment map?


```r
port.number = 1234
base.url = paste("http://localhost:",
                 toString(port.number),
                 "/v1",
                 sep="")
base.url
```

```
## [1] "http://localhost:1234/v1"
```

```r
commands_enrichment_map.uri <- paste(base.url,
                                     "commands/enrichmentmap",
                                     sep="/")

request.res <- GET(url = commands_enrichment_map.uri )
request.res
```

```
## Response [http://localhost:1234/v1/commands/enrichmentmap]
##   Date: 2016-06-15 14:25
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

Now try to extend the function to be able to find commands from a specific plugin?


```r
## make function to get commands from Enrichment map
setGeneric ('getCommandNamesEnrichmentMap', 
            signature = 'obj',
            function(obj) standardGeneric ('getCommandNamesEnrichmentMap'))
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
            ## remove "Available commands" title
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


### Make a function to look for commands within different plugins.



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
            ## remove "Available commands" title
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

### For reference list of arguments for EnrichmentMap "build"
```help enrichmentmap build```
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

### For reference list of arguments for EnrichmentMap gseabuild
```help enrichmentmap gseabuild``` at Cytoscape command line
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
# setGeneric ('getEnrichmentMapCommands', 
# 	signature='obj', function(obj) standardGeneric ('getEnrichmentMapCommands'))
setGeneric ('getEnrichmentMapCommandsNames',	
	signature='obj', function(obj, command.name) standardGeneric ('getEnrichmentMapCommandsNames'))
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
## need to specify which one would be most useful here? build or gseabuild or just make stuff for both?
            
#http://localhost:1234/v1/commands/enrichmentmap/build/

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

## Send data to the cytoscape network

Use data from the Bader lab tutorial

```r
## Note: You cannot use relative paths in this,
## it needs to be the absolute path
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
                     command.name,
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

## no graph is returned, just the connection to the graph
EM_1 <- setEnrichmentMapProperties(cy,
                                  "build",
                                  em_params)
```

```
## [1] "Successfully built the EnrichmentMap."
## [1] "Cytoscape window EM3_Enrichment Map successfully connected to R session."
```

Is there a situation where using the last made window for this enrichment map will fail? What other option could I find?


```r
saveImage(EM_1,
          "EM_1",
          "png",
          scale=4)
```

![](./EM_1.png)


```r
head(noa.names(getGraph(EM_1)))
```

```
## NULL
```

```r
## test setting layout from R
layoutNetwork(EM_1,
                  'grid')

saveImage(EM_1,
          "EM_1_gridded",
          "png",
          scale=4)
```
![](./EM_1_gridded.png)


```r
saveNetwork(EM_1, "EM_1")    
EM_1@graph
```

```
## A graphNEL graph with directed edges
## Number of Nodes = 0 
## Number of Edges = 0
```

```r
## if we want the graph data to be returned
## this part is slooooow!
EM_1_2 <- setEnrichmentMapProperties(cy,
                                   "build",
                                   em_params,
                                   copy.graph.to.R = TRUE)
```

```
## [1] "Successfully built the EnrichmentMap."
## [1] "Cytoscape windowEM4_Enrichment Map successfully connected to R session and graph copied to R."
```

```r
print(noa.names(getGraph(EM_1_2)))
```

```
##  [1] "name"                    "EM4_GS_DESCR"           
##  [3] "EM4_Formatted_name"      "EM4_Name"               
##  [5] "EM4_GS_Source"           "EM4_GS_Type"            
##  [7] "EM4_pvalue_dataset1"     "EM4_Colouring_dataset1" 
##  [9] "EM4_fdr_qvalue_dataset1" "EM4_gs_size_dataset1"
```

```r
head(nodeData(EM_1_2@graph))
```

```
## $`REAC:5173214`
## $`REAC:5173214`$name
## [1] "REAC:5173214"
## 
## $`REAC:5173214`$EM4_GS_DESCR
## [1] "O-GLYCOSYLATION OF TSR DOMAIN-CONTAINING PROTEINS"
## 
## $`REAC:5173214`$EM4_Formatted_name
## [1] "REAC:5173214\n"
## 
## $`REAC:5173214`$EM4_Name
## [1] "REAC:5173214"
## 
## $`REAC:5173214`$EM4_GS_Source
## [1] "none"
## 
## $`REAC:5173214`$EM4_GS_Type
## [1] "ENR"
## 
## $`REAC:5173214`$EM4_pvalue_dataset1
## [1] 2.21e-12
## 
## $`REAC:5173214`$EM4_Colouring_dataset1
## [1] 1
## 
## $`REAC:5173214`$EM4_fdr_qvalue_dataset1
## [1] 2.21e-12
## 
## $`REAC:5173214`$EM4_gs_size_dataset1
## [1] 17
## 
## 
## $`GO:0010720`
## $`GO:0010720`$name
## [1] "GO:0010720"
## 
## $`GO:0010720`$EM4_GS_DESCR
## [1] "POSITIVE REGULATION OF CELL DEVELOPMENT"
## 
## $`GO:0010720`$EM4_Formatted_name
## [1] "GO:0010720\n"
## 
## $`GO:0010720`$EM4_Name
## [1] "GO:0010720"
## 
## $`GO:0010720`$EM4_GS_Source
## [1] "none"
## 
## $`GO:0010720`$EM4_GS_Type
## [1] "ENR"
## 
## $`GO:0010720`$EM4_pvalue_dataset1
## [1] 3.52e-07
## 
## $`GO:0010720`$EM4_Colouring_dataset1
## [1] 0.9999996
## 
## $`GO:0010720`$EM4_fdr_qvalue_dataset1
## [1] 3.52e-07
## 
## $`GO:0010720`$EM4_gs_size_dataset1
## [1] 34
## 
## 
## $`GO:0010721`
## $`GO:0010721`$name
## [1] "GO:0010721"
## 
## $`GO:0010721`$EM4_GS_DESCR
## [1] "NEGATIVE REGULATION OF CELL DEVELOPMENT"
## 
## $`GO:0010721`$EM4_Formatted_name
## [1] "GO:0010721\n"
## 
## $`GO:0010721`$EM4_Name
## [1] "GO:0010721"
## 
## $`GO:0010721`$EM4_GS_Source
## [1] "none"
## 
## $`GO:0010721`$EM4_GS_Type
## [1] "ENR"
## 
## $`GO:0010721`$EM4_pvalue_dataset1
## [1] 2.38e-06
## 
## $`GO:0010721`$EM4_Colouring_dataset1
## [1] 0.9999976
## 
## $`GO:0010721`$EM4_fdr_qvalue_dataset1
## [1] 2.38e-06
## 
## $`GO:0010721`$EM4_gs_size_dataset1
## [1] 16
## 
## 
## $`GO:0044273`
## $`GO:0044273`$name
## [1] "GO:0044273"
## 
## $`GO:0044273`$EM4_GS_DESCR
## [1] "SULFUR COMPOUND CATABOLIC PROCESS"
## 
## $`GO:0044273`$EM4_Formatted_name
## [1] "GO:0044273\n"
## 
## $`GO:0044273`$EM4_Name
## [1] "GO:0044273"
## 
## $`GO:0044273`$EM4_GS_Source
## [1] "none"
## 
## $`GO:0044273`$EM4_GS_Type
## [1] "ENR"
## 
## $`GO:0044273`$EM4_pvalue_dataset1
## [1] 2.64e-06
## 
## $`GO:0044273`$EM4_Colouring_dataset1
## [1] 0.9999974
## 
## $`GO:0044273`$EM4_fdr_qvalue_dataset1
## [1] 2.64e-06
## 
## $`GO:0044273`$EM4_gs_size_dataset1
## [1] 8
## 
## 
## $`GO:0043062`
## $`GO:0043062`$name
## [1] "GO:0043062"
## 
## $`GO:0043062`$EM4_GS_DESCR
## [1] "EXTRACELLULAR STRUCTURE ORGANIZATION"
## 
## $`GO:0043062`$EM4_Formatted_name
## [1] "GO:0043062\n"
## 
## $`GO:0043062`$EM4_Name
## [1] "GO:0043062"
## 
## $`GO:0043062`$EM4_GS_Source
## [1] "none"
## 
## $`GO:0043062`$EM4_GS_Type
## [1] "ENR"
## 
## $`GO:0043062`$EM4_pvalue_dataset1
## [1] 9.28e-63
## 
## $`GO:0043062`$EM4_Colouring_dataset1
## [1] 1
## 
## $`GO:0043062`$EM4_fdr_qvalue_dataset1
## [1] 9.28e-63
## 
## $`GO:0043062`$EM4_gs_size_dataset1
## [1] 100
## 
## 
## $`GO:0048864`
## $`GO:0048864`$name
## [1] "GO:0048864"
## 
## $`GO:0048864`$EM4_GS_DESCR
## [1] "STEM CELL DEVELOPMENT"
## 
## $`GO:0048864`$EM4_Formatted_name
## [1] "GO:0048864\n"
## 
## $`GO:0048864`$EM4_Name
## [1] "GO:0048864"
## 
## $`GO:0048864`$EM4_GS_Source
## [1] "none"
## 
## $`GO:0048864`$EM4_GS_Type
## [1] "ENR"
## 
## $`GO:0048864`$EM4_pvalue_dataset1
## [1] 6.74e-13
## 
## $`GO:0048864`$EM4_Colouring_dataset1
## [1] 1
## 
## $`GO:0048864`$EM4_fdr_qvalue_dataset1
## [1] 6.74e-13
## 
## $`GO:0048864`$EM4_gs_size_dataset1
## [1] 32
```

```r
saveImage(EM_1_2,
          "EM_1_2",
          "png",
          scale=4)
```

![](./EM_1_2.png)

## EM with two inputs

to come!

## Next steps

- Verify that I have made these functions correctly for use in S4 framework
- Clean up the use of the functions
- EM with two inputs.- see tutorial for ideas
- command to print list of setable properties?
