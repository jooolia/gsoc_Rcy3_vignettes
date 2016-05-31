# playing_around_with_RCy3_functions
Julia Gustavsen  
May 24, 2016  


```r
library(RCy3)
```

```
## Loading required package: graph
```


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
## [1] "248"
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
## [1] "248"
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

So how do I get the api version and see what is available?


```r
library(igraph)
```

```
## 
## Attaching package: 'igraph'
```

```
## The following objects are masked from 'package:graph':
## 
##     degree, edges, intersection, union
```

```
## The following objects are masked from 'package:stats':
## 
##     decompose, spectrum
```

```
## The following object is masked from 'package:base':
## 
##     union
```

```r
library(RJSONIO)
library(httr)
```



```r
resetCytoscapeSession <-
  function(port.number=1234)
  {
    base.url = paste("http://localhost:", toString(port.number), "/v1", sep="")
    reset.url <- paste(base.url,"session",sep="/")
    if (requireNamespace("httr",quietly=TRUE)) {res<-httr::DELETE(reset.url)}
    else {stop("httr package must be installed to use this function")}
  }
```





```r
port.number = 1234

resetCytoscapeSession(port.number) # just to make sure you are using a clean Cytoscape
## removes all previous networks that were loaded in that session.

base.url = paste("http://localhost:",
                 toString(port.number),
                 "/v1", sep="")
base.url
```

```
## [1] "http://localhost:1234/v1"
```

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
##         645        2432        3078       13305
```

The idea is how do I find more info on the api and what it shows? For example...how do I access enrichment map.


```r
  network.url = paste(base.url, "networks", sep="/")
## lists networks 

  # res <- POST(url=network.url, body=cygraph, encode="json")
  # 
  # # Extract SUID of the new network
  # network.suid = unname(fromJSON(rawToChar(res$content)))
  # network.suid
  # 
  # 
  # #http://localhost:1234/v1/apply/styles
  # ## what else apply?
  # #http://localhost:1234/v1/apply/layouts
  # ## and then give to specific network
  # #and can send the parameters via jsonlite::
  # 
  # # Apply style
  # apply.style.url = paste(base.url, "apply/styles", style.name , toString(network.suid), sep="/")
  # GET(apply.style.url)
  # 
  # # Apply force-directed layout --need this first
  #   # Tweak Layout parameters
  #   layout.params = list(
  #    name="unweighted",
  #    value=TRUE
  #    )
  # 
  #   layout.params.url = paste(base.url, "apply/layouts/kamada-kawai/parameters", sep="/")
  #   PUT(layout.params.url, body=toJSON(list(layout.params)), encode = "json")
  # 
  #   apply.layout.url = paste(base.url, "apply/layouts/kamada-kawai", toString(network.suid), sep="/")
```


How do I find out what is available at the for the REST APIs?

from manual - not sure I understand the difference
" Cytoscape offers two flavors of REST-style control: REST Commands and cyREST. REST Commands uses a REST interface to issue script commands. cyREST uses a REST interface to access the Cytoscape data model as a document via a formal API"

Trying with clustermaker

```r
  ## what else apply?
#  http://localhost:1234/v1/apply/layouts
  ## and then give to specific network
  #and can send the parameters via jsonlite::
  

##cluster maker stuff idea?
#   apply.clustering.url = paste(base.url,"apply/cluster",cluster.command, toString(network.suid), sep="/")
# GET(apply.clustering.url)
# 
# try cluster network?
  
  # Apply force-directed layout --need this first
    # Tweak Layout parameters
    # layout.params = list(
    #  name="unweighted",
    #  value=TRUE
    #  )
    # 
    # layout.params.url = paste(base.url, "apply/layouts/kamada-kawai/parameters", sep="/")
    # PUT(layout.params.url, body=toJSON(list(layout.params)), encode = "json")
    # 
    # apply.layout.url = paste(base.url, "apply/layouts/kamada-kawai", toString(network.suid), sep="/")
```


can I use this to query other types of things? 



```r
## so get layoutNames looks like this.


setMethod('getLayoutNames', 'CytoscapeConnectionClass', 
	function(obj) {
request.uri <- paste(obj@uri, pluginVersion(obj), "apply/layouts", sep="/")
        request.res <- GET(url=request.uri)
        
        available.layouts <- unname(fromJSON(rawToChar(request.res$content)))
                return(available.layouts)
})
```

```
## [1] "getLayoutNames"
```

so to look at the current parameters of one type of attribute: 

http://localhost:1234/v1/apply/layouts/attribute-circle/parameters



so we see they are pasting url/v1/apply/layouts/ to find available layouts


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


Ok maybe we are getting somewhere. 


```r
# paste(obj@uri, version, "networks", net.SUID, "tables/defaultnode/rows", as.character(node.SUIDs[i]), attribute.name, sep="/")
```

http://localhost:1234/v1/networks - gives list of networks

http://localhost:1234/v1/networks/13633 - gives json formatted view of network
http://localhost:1234/v1/networks/13633/tables - shows all networks?
http://localhost:1234/v1/networks/13633/tables/defaultnode
http://localhost:1234/v1/networks/13633/tables/defaultnode/rows

http://localhost:1234/v1/networks/13633/tables/defaultedge
http://localhost:1234/v1/networks/13633/tables/defaultedge/rows


what about how to list what can be applied???

http://localhost:1234/v1/apply/enrichmentmap/


```r
#paste(obj@uri, version, "apply/styles", "default", net.SUID, sep = "/")
## fit.content
#resource.uri <- paste(obj@uri, pluginVersion(obj), "apply/fit", net.SUID, sep="/")
## get style names
#paste(obj@uri, pluginVersion(obj), "apply/styles", sep="/")
```

http://localhost:1234/v1/apply/styles

found this page which is helpful for the api:

http://idekerlab.github.io/cyREST/#1637304040
http://localhost:1234/v1/networks.names/ - returns json list
http://localhost:1234/v1/tables/count/


Ok hhallelya!! http://localhost:1234/v1/commands !!!


```r
# setMethod('getCommandNames', 'CytoscapeConnectionClass', 
# 	
#           function(obj) {
# request.uri <- paste(obj@uri, pluginVersion(obj), "commands", sep="/")
#         request.res <- GET(url=request.uri)
#         
#         available.commands <- unname(fromJSON(rawToChar(request.res$content)))
#                 return(available.commands)
# })

## playing around

commands.uri <- paste(base.url, "commands", sep="/")
request.res <- GET(url=commands.uri)
request.res
```

```
## Response [http://localhost:1234/v1/commands]
##   Date: 2016-05-31 15:12
##   Status: 200
##   Content-Type: text/plain
##   Size: 146 B
```

```
## No encoding supplied: defaulting to UTF-8.
```

```
## Available namespaces:
##   cluster
##   clusterviz
##   command
##   edge
##   enrichmentmap
##   group
##   layout
##   network
##   node
## ...
```

```r
commands_enrichment_map.uri <- paste(base.url, "commands/enrichmentmap", sep="/")
request.res <- GET(url=commands_enrichment_map.uri )
request.res
```

```
## Response [http://localhost:1234/v1/commands/enrichmentmap]
##   Date: 2016-05-31 15:12
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

