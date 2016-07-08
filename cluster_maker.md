# cluster_maker
Julia Gustavsen  
June 23, 2016  


```r
library(RCy3)
library(httr)
library(RJSONIO)
source("./functions_to_add_to_RCy3/working_with_namespaces.R")
```

Trying out cluster maker with R 


```r
cy <- CytoscapeConnection ()
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


http://opentutorials.cgl.ucsf.edu/index.php/Tutorial:Cluster_Maker



## need to read in cys


```r
#help session

command.name <- "open"

request.uri <- paste(cy@uri,
                     pluginVersion(cy),
                     "commands/session",
                     as.character(command.name),
                     sep = "/")
## file

## load session
properties.list <- list(file="/home/julia_g/windows_school/gsoc/gsoc_Rcy3_vignettes/data/GalFiltered.cys")
request.res <- GET(url = request.uri,
                   query = properties.list)

#cy.window <- new('CytoscapeWindowClass', title=title, window.id=existing.window.id, uri=uri)
## how do I list networks in cy?
#get

getWindowList(cy)
```

```
## [1] "galFiltered.sif"
```

```r
connect_EM_to_R_session <- existing.CytoscapeWindow("galFiltered.sif",                                                                      copy.graph.from.cytoscape.to.R = FALSE)
```

Graph from session is loaded into Cytoscape


```r
getCommandsWithinNamespace(cy, "cluster/hierarchical")
```

```
##  [1] "adjustDiagonals"   "clusterAttributes" "createGroups"     
##  [4] "edgeAttributeList" "ignoreMissing"     "linkage"          
##  [7] "metric"            "network"           "nodeAttributeList"
## [10] "selectedOnly"      "showUI"            "zeroMissing"
```

```r
properties.list <- list(nodeAttributeList = c("node.gal1RGexp",
                                           "node.gal4RGexp",
                                           "node.gal80Rexp"),
                     selectedOnly = FALSE)


## I think this works to send an array to via json...
node_list <- c('[ "node.gal1RGexp",
                                          "node.gal4RGexp",
                                          "node.gal80Rexp"]')

properties.list <- list(nodeAttributeList = node_list,
                     selectedOnly = FALSE)

command.name <- "hierarchical"
request.uri <- paste(cy@uri,pluginVersion(cy),
                     "commands/cluster",
                     as.character(command.name),
                     sep = "/")
## file
request.res <- GET(url = request.uri,
                   query = properties.list)
```

Ok so how to get this to be more like a function? make specific things for the R funciton??
- also connect to this network in R
