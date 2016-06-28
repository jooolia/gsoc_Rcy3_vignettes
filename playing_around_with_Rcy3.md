# playing_around_with_RCy3_functions
Julia Gustavsen  
May 24, 2016  

# Purpose

Testing out some ways to develop functions that could be used in R with RCy3 to access Cytoscape plugins

# Sandbox


```r
library(RCy3)
```

```
## Loading required package: graph
```

```r
library(RJSONIO)
library(httr)
```

## Connection to Cytoscape 


```r
CytoscapeConnection() # checks for the connection
```

```
## An object of class "CytoscapeConnectionClass"
## Slot "uri":
## [1] "http://localhost:1234"
```

```r
CytoscapeWindow("test", overwriteWindow = TRUE) # creates empty window in Cytoscape
```

```
## An object of class "CytoscapeWindowClass"
## Slot "title":
## [1] "test"
## 
## Slot "window.id":
## [1] "77660"
## 
## Slot "graph":
## A graphNEL graph with directed edges
## Number of Nodes = 0 
## Number of Edges = 0 
## 
## Slot "collectTimings":
## [1] FALSE
## 
## Slot "suid.name.dict":
## list()
## 
## Slot "edge.suid.name.dict":
## list()
## 
## Slot "view.id":
## numeric(0)
## 
## Slot "uri":
## [1] "http://localhost:1234"
```

```r
existing.CytoscapeWindow("new") # throws an error if it does not exist yet
```

```
## [1] NA
```

```r
existing.CytoscapeWindow("test") # The constructor for the CytoscapeWindowClass, used when Cytoscape already contains 
```

```
## An object of class "CytoscapeWindowClass"
## Slot "title":
## [1] "test"
## 
## Slot "window.id":
## [1] "77660"
## 
## Slot "graph":
## A graphNEL graph with directed edges
## Number of Nodes = 0 
## Number of Edges = 0 
## 
## Slot "collectTimings":
## [1] FALSE
## 
## Slot "suid.name.dict":
## list()
## 
## Slot "edge.suid.name.dict":
## list()
## 
## Slot "view.id":
## numeric(0)
## 
## Slot "uri":
## [1] "http://localhost:1234"
```

```r
## and displays a network. COuld be useful. 

#check.cytoscape.plugin.version() ## doesn't work with loading the regular library. or in dev. Seems to work a bit more if loaded separately
```

## Visualizing REST urls


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

## Basic cytoscape info


```r
version.url = paste(base.url,
                    "version",
                    sep="/")

cytoscape.version = GET(version.url)
cy.version = fromJSON(rawToChar(cytoscape.version$content))
cy.version
```

```
##       apiVersion cytoscapeVersion 
##             "v1"          "3.4.0"
```

```r
basic_info = GET(base.url)

basic_info = fromJSON(rawToChar(basic_info$content))
basic_info
```

```
## $apiVersion
## [1] "v1"
## 
## $numberOfCores
## [1] 4
## 
## $memoryStatus
##  usedMemory  freeMemory totalMemory   maxMemory 
##        1568        3255        4824       13305
```


## List of networks currently available


```r
## lists networks 
network.url = paste(base.url, "networks", sep="/")
network.url
```

```
## [1] "http://localhost:1234/v1/networks"
```

## Code from RCy3 on getLayoutNames

Help to figure out how to access the commands for manipulating networks n Cytoscape via plugins. 

standardGeneric() is like the S3 UseMethod()

```r
## lifted from RCy3 code

setMethod('getLayoutNames',
          'CytoscapeConnectionClass', 
          function(obj) {
            request.uri <- paste(obj@uri,
                                 pluginVersion(obj),
                                 "apply/layouts",
                                 sep="/")
            request.res <- GET(url=request.uri)
            
            available.layouts <- unname(fromJSON(rawToChar(request.res$content)))
            return(available.layouts)
          })
```

```
## [1] "getLayoutNames"
```

To look at the current parameters of one type of attribute: 

http://localhost:1234/v1/apply/layouts/attribute-circle/parameters

Will come back later to find the function that RCy3 uses to apply parameters


```r
cy <- CytoscapeConnection ()
getLayoutNames (cy)
```

```
##  [1] "attribute-circle"                           
##  [2] "allegro-weak-clustering"                    
##  [3] "allegro-edge-repulsive-fruchterman-reingold"
##  [4] "stacked-node-layout"                        
##  [5] "allegro-edge-repulsive-strong-clustering"   
##  [6] "allegro-strong-clustering"                  
##  [7] "degree-circle"                              
##  [8] "allegro-fruchterman-reingold"               
##  [9] "allegro-edge-repulsive-spring-electric"     
## [10] "circular"                                   
## [11] "attributes-layout"                          
## [12] "kamada-kawai"                               
## [13] "force-directed"                             
## [14] "allegro-edge-repulsive-weak-clustering"     
## [15] "grid"                                       
## [16] "hierarchical"                               
## [17] "allegro-spring-electric"                    
## [18] "fruchterman-rheingold"                      
## [19] "isom"
```

## URLs used to test out API calls

http://localhost:1234/v1/networks - gives list of networks

http://localhost:1234/v1/networks/13633 - gives json formatted view of network

http://localhost:1234/v1/networks/13633/tables - shows all networks?

http://localhost:1234/v1/networks/13633/tables/defaultnode

http://localhost:1234/v1/networks/13633/tables/defaultnode/rows

http://localhost:1234/v1/networks/13633/tables/defaultedge

http://localhost:1234/v1/networks/13633/tables/defaultedge/rows

http://localhost:1234/v1/apply/styles

http://localhost:1234/v1/networks.names/ - returns json list

http://localhost:1234/v1/tables/count/

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
commands_enrichment_map.uri <- paste(base.url, "commands/enrichmentmap", sep="/")
request.res <- GET(url = commands_enrichment_map.uri )
request.res
```

```
## Response [http://localhost:1234/v1/commands/enrichmentmap]
##   Date: 2016-06-13 13:05
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
                     properties.list) standardGeneric('setEnrichmentMapProperties')
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
                   properties.list) {
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
                  print("Successfully buitl the EnrichmentMap.")
                        stdout ()
                } else {
                  print("Something went wrong. Unable to build EnrichmentMap")
                        stderr ()
                }
                invisible(request.res)
              }
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

new <- setEnrichmentMapProperties(cy, "build", em_params)
```

```
## [1] "Successfully buitl the EnrichmentMap."
```

```r
#displayGraph(new)
## does not work because the class is not right
## see line 404 in RCy3.R

## does this print the enrichment map? no
#saveImage(cy,"test_EM", "pdf", scale=1.0)
#saveImage(cy,"test_EM", "png", scale=0.3)



## what is I do 
cw <- CytoscapeWindow('co-occurrence',
                      overwriteWindow = TRUE)
displayGraph(cw)
```

```
## NULL
```

```r
setEnrichmentMapProperties(cw, "build", em_params)
```

```
## [1] "Successfully buitl the EnrichmentMap."
```

```r
## how to get the name of the graph made??
## how can I then manipulate it?
existing.CytoscapeWindow("julia")
```

```
## [1] NA
```

```r
getWindowList(cy)
```

```
##  [1] "EM9_Enrichment Map"  "EM1_Enrichment Map"  "EM6_Enrichment Map" 
##  [4] "EM13_Enrichment Map" "EM19_Enrichment Map" "EM11_Enrichment Map"
##  [7] "EM17_Enrichment Map" "EM3_Enrichment Map"  "EM8_Enrichment Map" 
## [10] "EM15_Enrichment Map" "EM21_Enrichment Map" "EM12_Enrichment Map"
## [13] "co-occurrence"       "EM4_Enrichment Map"  "EM10_Enrichment Map"
## [16] "EM16_Enrichment Map" "EM2_Enrichment Map"  "EM7_Enrichment Map" 
## [19] "EM14_Enrichment Map" "EM20_Enrichment Map" "EM5_Enrichment Map" 
## [22] "EM18_Enrichment Map" "test"
```

```r
## how do I connect to that window??
getWindowID(cy, "EM18_Enrichment Map")
```

```
## [1] "69532"
```

```r
#http://localhost:1234/v1/networks
## need to create a CytoscapeWindowClassObject in R for this. 
## ok this saves the graph as graphnel. 
## and is very slow
#test_cw <- getGraphFromCyWindow(cy, "EM18_Enrichment Map")
## need to print specific window...

## object needs to be a CytoscapeWindowClass object
## connect to existing window....
test_existing_window <- existing.CytoscapeWindow ("EM18_Enrichment Map",
                                                  host='localhost',
                                                  port=1234,
                                                  copy.graph.from.cytoscape.to.R=FALSE)

saveImage(test_existing_window,"test_EM_new", "png", scale=0.3)
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

- Examine RCy3 to see what functions I can use to send info (POST) to the commands in Cytoscape. 
- Verify that I have made these functions correctly for use in S4 framework
- Start working through Enrichment map tutorial (or other data?) using these R functions.
- Is it wrong to have variable `available.commands`? Does this mess with S4 stuff? 
- timecourse ideas??
