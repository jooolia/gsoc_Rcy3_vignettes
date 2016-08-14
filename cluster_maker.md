# cluster_maker
Julia Gustavsen  
June 23, 2016  


```r
library(RCy3)
library(httr)
library(RJSONIO)
source("./functions_to_add_to_RCy3/working_with_namespaces.R")
```

# Trying out clusterMaker with R 

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

Following this tutorial: 

http://opentutorials.cgl.ucsf.edu/index.php/Tutorial:Cluster_Maker

# Read in provided session file (.cys file)

```r
command.name <- "open"

request.uri <- paste(cy@uri,
                     pluginVersion(cy),
                     "commands/session",
                     as.character(command.name),
                     sep = "/")
## load session
properties.list <- list(file="/home/julia_g/windows_school/gsoc/gsoc_Rcy3_vignettes/data/GalFiltered.cys")
request.res <- GET(url = request.uri,
                   query = properties.list)

getWindowList(cy)
```

```
## [1] "galFiltered.sif"
```

```r
connect_window_to_R_session <- existing.CytoscapeWindow("galFiltered.sif",                                                                      copy.graph.from.cytoscape.to.R = FALSE)
```

Graph from session is loaded into Cytoscape


```r
getCommandsWithinNamespace(connect_window_to_R_session, "cluster/hierarchical")
```

```
##  [1] "adjustDiagonals"   "clusterAttributes" "createGroups"     
##  [4] "edgeAttributeList" "ignoreMissing"     "linkage"          
##  [7] "metric"            "network"           "nodeAttributeList"
## [10] "selectedOnly"      "showUI"            "zeroMissing"
```

```r
getCommandsWithinNamespace(connect_window_to_R_session, "cluster/getcluster")
```

```
## [1] "algorithm" "network"   "type"
```


( from Scooter "cluster getcluster algorithm=hierarchical")


```r
node_list <- list("gal1RGexp",
                  "gal4RGexp",
                  "gal80Rexp")

properties.list <- list(nodeAttributeList = node_list[[1]],
                        nodeAttributeList = node_list[[2]],
                        nodeAttributeList = node_list[[3]],
                        network = connect_window_to_R_session@title,
                        selectedOnly = FALSE,
                        clusterAttributes = FALSE,
                        ignoreMissing = FALSE,
                        createGroups = TRUE,
                        showUI = FALSE)

command.name <- "hierarchical"
request.uri <- paste(connect_window_to_R_session@uri,
                     pluginVersion(cy),
                     "commands/cluster",
                     as.character(command.name),
                     sep = "/")

request.res <- GET(url = request.uri,
                   query = properties.list,
                   verbose())
request.res$url
```

```
## [1] "http://localhost:1234/v1/commands/cluster/hierarchical?nodeAttributeList=gal1RGexp&nodeAttributeList=gal4RGexp&nodeAttributeList=gal80Rexp&network=galFiltered.sif&selectedOnly=FALSE&clusterAttributes=FALSE&ignoreMissing=FALSE&createGroups=TRUE&showUI=FALSE"
```

```r
http_status(request.res)
```

```
## $category
## [1] "Success"
## 
## $reason
## [1] "OK"
## 
## $message
## [1] "Success: (200) OK"
```

```r
request.res$status_code
```

```
## [1] 200
```

```r
command.name <- "getcluster"

properties.list <- list(algorithm = "hierarchical",
                        type = "node")

request.uri <- paste(connect_window_to_R_session@uri,
                     pluginVersion(cy),
                     "commands/cluster",
                     as.character(command.name),
                     sep = "/")

request.res <- GET(url = request.uri,
                   query = properties.list,
                   verbose())
request.res$url
```

```
## [1] "http://localhost:1234/v1/commands/cluster/getcluster?algorithm=hierarchical&type=node"
```

```r
http_status(request.res)
```

```
## $category
## [1] "Success"
## 
## $reason
## [1] "OK"
## 
## $message
## [1] "Success: (200) OK"
```

```r
request.res$status_code
```

```
## [1] 200
```

Ok puts things into the network table in Cytoscape.

How to work with this?
