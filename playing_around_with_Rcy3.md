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
## [1] "192"
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
## [1] "192"
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
##         430        2699        3129       13305
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
##   Date: 2016-06-01 14:13
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

## Next steps

- Examine RCy3 to see what functions I can use to send info (POST) to the commands in Cytoscape. 
- Verify that I have made these functions correctly for use in S4 framework
- Start working through Enrichment map tutorial (or other data?) using these R functions.
- Is it wrong to have variable `available.commands`? Does this mess with S4 stuff? 
