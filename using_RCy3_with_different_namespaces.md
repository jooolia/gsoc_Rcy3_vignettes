# Using RCy3 with different namespaces
Julia Gustavsen  
June 17, 2016  




```r
library(RCy3)
```



```r
source("./functions_to_add_to_RCy3/working_with_namespaces.R")
```

Test out the function to see what commands are available in Cytoscape


```r
cy <- CytoscapeConnection ()
## now this is giving a weird return of including paragraph styles, etc
getCommandNames(cy)
```

```
##  [1] "cluster"       "clusterviz"    "command"       "edge"         
##  [5] "enrichmentmap" "group"         "layout"        "network"      
##  [9] "node"          "session"       "table"         "view"         
## [13] "vizmap"
```

```r
str(getCommandNames(cy))
```

```
##  chr [1:13] "cluster" "clusterviz" "command" "edge" ...
```

Test out using different namespaces available


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
##  [1] "apply preferred"       "attribute-circle"     
##  [3] "attributes-layout"     "circular"             
##  [5] "degree-circle"         "force-directed"       
##  [7] "fruchterman-rheingold" "get preferred"        
##  [9] "grid"                  "hierarchical"         
## [11] "isom"                  "kamada-kawai"         
## [13] "set preferred"         "stacked-node-layout"
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
