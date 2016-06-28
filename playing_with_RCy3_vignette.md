# playing_with_RCy3_vignette
Julia Gustavsen  
June 28, 2016  


```r
library(RCy3)
library(igraph)
library(RJSONIO)
library(reshape2)
library(dplyr)

species_data <- read.table(header=T, row.names=1, text=
"    Species1 Species2 Species3 Species4
 1   1   1   0  2
 2   1   0   1  3
 3   1   2   1  4
 4   0   3   1  2
 5   2   0   0  0
 6   2   1   1  1
")

spe_cor <- cor(as.matrix(species_data),
                  method="spearman") 

spe_cor[upper.tri(spe_cor)] <- NA

melted_cor <- melt(spe_cor)
melted_cor <- na.omit(melted_cor)


filtered_data <- filter(melted_cor, abs(value) > 0.6)

graph_spe <- graph.data.frame(filtered_data,
                          directed=FALSE)

plot(graph_spe)
```

![](playing_with_RCy3_vignette_files/figure-html/unnamed-chunk-1-1.png)<!-- -->
 
Williams et al did a good job here:

http://co-occurrence.readthedocs.io/en/latest/

 
Let's try to send the first one to Cytoscape

Oh RCy3 doesn't work with igraph!

Can that be fixed? Or should it be?

Can I try to use graph instead?



```r
## ok can quickly do this:
graphNEL_spe <- igraph.to.graphNEL(graph_spe)
plot(graphNEL_spe)
```

![](playing_with_RCy3_vignette_files/figure-html/unnamed-chunk-2-1.png)<!-- -->

```r
graphNEL_spe <- initEdgeAttribute (graphNEL_spe,
                                   "weight",
                                   "integer",
                                   3)
graphNEL_spe <- initEdgeAttribute (graphNEL_spe,
                                   "value", 
                                   "numeric",
                                   1.0)

cw <- CytoscapeWindow('co-occurrence',
                      graph=graphNEL_spe,
                      overwrite=TRUE)
displayGraph(cw)
```

```
## [1] "label"
## [1] "weight"
## [1] "value"
```


next in their vignette

the layout


```r
layoutNetwork(cw, layout.name='grid')
```

# Add node attributes


```r
g <- cw@graph   # created above, in the section  'A minimal example'
g <- initNodeAttribute (graph=g,
                            attribute.name='Family',
                            attribute.type='char',
                            default.value='undefined')
nodeData(g, 'Species1', 'Family') <- 'Family1'
nodeData(g, 'Species2', 'Family') <- 'Family2'
nodeData(g, 'Species3', 'Family') <- 'Family1'
nodeData(g, 'Species4', 'Family') <- 'Family1'
    
g <- initNodeAttribute (graph=g,  'lfc', 'numeric', 0.0)
nodeData(g, 'Species1', 'lfc') <- -1.2
nodeData(g, 'Species2', 'lfc') <- 1.8
nodeData(g, 'Species3', 'lfc') <- 3.2
 nodeData(g, 'Species4', 'lfc') <- 0.0    
## setGraph?? maybe the documentation is a bit hard to understand if you do not know S4?
    ## so other things can be assigned in the other slots?
cw <- setGraph(cw, g)
str(cw)
```

```
## Formal class 'CytoscapeWindowClass' [package "RCy3"] with 8 slots
##   ..@ title              : chr "co-occurrence"
##   ..@ window.id          : chr "129596"
##   ..@ graph              :Formal class 'graphNEL' [package "graph"] with 6 slots
##   .. .. ..@ nodes     : chr [1:4] "Species1" "Species2" "Species4" "Species3"
##   .. .. ..@ edgeL     :List of 4
##   .. .. .. ..$ Species1:List of 1
##   .. .. .. .. ..$ edges: num [1:3] 1 2 3
##   .. .. .. ..$ Species2:List of 1
##   .. .. .. .. ..$ edges: num 2
##   .. .. .. ..$ Species4:List of 1
##   .. .. .. .. ..$ edges: num 3
##   .. .. .. ..$ Species3:List of 1
##   .. .. .. .. ..$ edges: num 4
##   .. .. ..@ edgeData  :Formal class 'attrData' [package "graph"] with 2 slots
##   .. .. .. .. ..@ data    : list()
##   .. .. .. .. ..@ defaults:List of 2
##   .. .. .. .. .. ..$ weight:Class 'INTEGER'  num 3
##   .. .. .. .. .. ..$ value :Class 'FLOATING'  num 1
##   .. .. ..@ nodeData  :Formal class 'attrData' [package "graph"] with 2 slots
##   .. .. .. .. ..@ data    :List of 4
##   .. .. .. .. .. ..$ Species1:List of 3
##   .. .. .. .. .. .. ..$ label : chr "Species1"
##   .. .. .. .. .. .. ..$ Family: chr "Family1"
##   .. .. .. .. .. .. ..$ lfc   : num -1.2
##   .. .. .. .. .. ..$ Species2:List of 3
##   .. .. .. .. .. .. ..$ label : chr "Species2"
##   .. .. .. .. .. .. ..$ Family: chr "Family2"
##   .. .. .. .. .. .. ..$ lfc   : num 1.8
##   .. .. .. .. .. ..$ Species4:List of 3
##   .. .. .. .. .. .. ..$ label : chr "Species4"
##   .. .. .. .. .. .. ..$ Family: chr "Family1"
##   .. .. .. .. .. .. ..$ lfc   : num 0
##   .. .. .. .. .. ..$ Species3:List of 3
##   .. .. .. .. .. .. ..$ label : chr "Species3"
##   .. .. .. .. .. .. ..$ Family: chr "Family1"
##   .. .. .. .. .. .. ..$ lfc   : num 3.2
##   .. .. .. .. ..@ defaults:List of 3
##   .. .. .. .. .. ..$ label :Class 'STRING'  chr "noLabel"
##   .. .. .. .. .. ..$ Family:Class 'STRING'  chr "undefined"
##   .. .. .. .. .. ..$ lfc   :Class 'FLOATING'  num 0
##   .. .. ..@ renderInfo:Formal class 'renderInfo' [package "graph"] with 4 slots
##   .. .. .. .. ..@ nodes: list()
##   .. .. .. .. ..@ edges: list()
##   .. .. .. .. ..@ graph: list()
##   .. .. .. .. ..@ pars : list()
##   .. .. ..@ graphData :List of 1
##   .. .. .. ..$ edgemode: chr "directed"
##   ..@ collectTimings     : logi FALSE
##   ..@ suid.name.dict     :List of 4
##   .. ..$ :List of 2
##   .. .. ..$ name: chr "Species1"
##   .. .. ..$ SUID: num 129608
##   .. ..$ :List of 2
##   .. .. ..$ name: chr "Species2"
##   .. .. ..$ SUID: num 129609
##   .. ..$ :List of 2
##   .. .. ..$ name: chr "Species4"
##   .. .. ..$ SUID: num 129610
##   .. ..$ :List of 2
##   .. .. ..$ name: chr "Species3"
##   .. .. ..$ SUID: num 129611
##   ..@ edge.suid.name.dict:List of 6
##   .. ..$ :List of 4
##   .. .. ..$ SUID       : num 129616
##   .. .. ..$ name       : chr "Species1 (unspecified) Species1"
##   .. .. ..$ source.node: num 129608
##   .. .. ..$ target.node: num 129608
##   .. ..$ :List of 4
##   .. .. ..$ SUID       : num 129617
##   .. .. ..$ name       : chr "Species1 (unspecified) Species2"
##   .. .. ..$ source.node: num 129608
##   .. .. ..$ target.node: num 129609
##   .. ..$ :List of 4
##   .. .. ..$ SUID       : num 129618
##   .. .. ..$ name       : chr "Species1 (unspecified) Species4"
##   .. .. ..$ source.node: num 129608
##   .. .. ..$ target.node: num 129610
##   .. ..$ :List of 4
##   .. .. ..$ SUID       : num 129619
##   .. .. ..$ name       : chr "Species2 (unspecified) Species2"
##   .. .. ..$ source.node: num 129609
##   .. .. ..$ target.node: num 129609
##   .. ..$ :List of 4
##   .. .. ..$ SUID       : num 129620
##   .. .. ..$ name       : chr "Species4 (unspecified) Species4"
##   .. .. ..$ source.node: num 129610
##   .. .. ..$ target.node: num 129610
##   .. ..$ :List of 4
##   .. .. ..$ SUID       : num 129621
##   .. .. ..$ name       : chr "Species3 (unspecified) Species3"
##   .. .. ..$ source.node: num 129611
##   .. .. ..$ target.node: num 129611
##   ..@ view.id            : num(0) 
##   ..@ uri                : chr "http://localhost:1234"
```

```r
displayGraph(cw)    # cw's graph is sent to Cytoscape
```

```
## [1] "label"
## [1] "Family"
## [1] "lfc"
## [1] "weight"
## [1] "value"
```

Ok now see these attributes show up in Cytoscape

# Set up the default colours in cytoscape

```r
setDefaultNodeShape(cw, 'OCTAGON')
setDefaultNodeColor(cw, '#AAFF88')
setDefaultNodeSize(cw, 80)
```

```
## Locked node dimensions successfully even if the check box is not ticked.
```

```r
 setDefaultNodeFontSize(cw, 40)
```


## Map attributes

So first we look at ways of getting the info from cytoscape so that we can work with it. Interactive a bit. 


```r
getNodeShapes(cw)   # diamond, ellipse, trapezoid, triangle, etc.
```

```
## [1] "DIAMOND"         "PARALLELOGRAM"   "OCTAGON"         "HEXAGON"        
## [5] "ROUND_RECTANGLE" "RECTANGLE"       "VEE"             "TRIANGLE"       
## [9] "ELLIPSE"
```

```r
## noa.names --make title more informatic Names of node attributes
print(noa.names(getGraph(cw)))  # what data attributes are defined?
```

```
## [1] "label"  "Family" "lfc"
```

```r
print(noa(getGraph(cw),
          'moleculeType'))
```

```
## [1] NA
```

```r
print(noa(getGraph(cw),
          'Family'))   
```

```
##  Species1  Species2  Species4  Species3 
## "Family1" "Family2" "Family1" "Family1"
```

```r
attribute.values <- c('Family1',
                      'Family2')
node.shapes      <- c('DIAMOND',
                      'TRIANGLE')
    
## this applies the rule
setNodeShapeRule(cw,
                 node.attribute.name='Family',
                 attribute.values,
                 node.shapes)
```

```
## Successfully set rule.
```


## Interpolation rules

used for values that can vary of are between certain levels

```r
setNodeColorRule(cw,
                 'lfc',
                 c(-3.0,
                   0.0,
                   3.0),
                 c('#00AA00',
                   '#00FF00',
                   '#FFFFFF',
                   '#FF0000',
                   '#AA0000'),
                 mode='interpolate')
```

```
## Successfully set rule.
```

Note that there \emph{five} colors, but only three control.points. The two additional colors tell the interpolated mapper which colors to use if the stated data attribute (lfc) has a value less than the smallest control point (paint it a darkish green, \#00AA00) or larger than the largets control point (paint it a darkish red, \#AA0000).  These extreme (or out-of-bounds) colors may be omitted:


## Interpolating node size


```r
control.points = c (-1.2,
                    2.0,
                    4.0)
node.sizes     = c (10,
                    20,
                    50,
                    200,
                    205)
setNodeSizeRule (cw,
                 'lfc',
                 control.points,
                 node.sizes,
                 mode='interpolate')
```

```
## Locked node dimensions successfully even if the check box is not ticked.
## Locked node dimensions successfully even if the check box is not ticked.
## Successfully set rule.
```

# Edge attributes


```r
g <- cw@graph
g <- initEdgeAttribute(graph=g,
                       attribute.name='edgeType',
                       attribute.type='char',
                       default.value='unspecified')
edgeData(g, 'Species1', 'Species2', 'edgeType') <- 'phosphorylates'
edgeData(g, 'Species1', 'Species4', 'edgeType') <- 'promotes'
## so this added edges

    
cw@graph <- g
displayGraph (cw)
```

```
## [1] "label"
## [1] "Family"
## [1] "lfc"
## [1] "weight"
## [1] "value"
## [1] "edgeType"
```

```r
line.styles = c ('DOT', 'SOLID')
edgeType.values = c ('phosphorylates', 'promotes')
setEdgeLineStyleRule (cw,
                      'edgeType',
                      edgeType.values,
                      line.styles)
```

```
## Successfully set rule.
```

```r
arrow.styles = c('Arrow', 'Delta')
setEdgeTargetArrowRule(cw,
                       'edgeType',
                       edgeType.values,
                       arrow.styles)
```

```
## Successfully set rule.
```

# Manipulating the cytoscape window

could be very useful for the use with a monitor


```r
hidePanel(cw, 'Data Panel')
floatPanel(cw, 'D')
dockPanel(cw, 'd')
hidePanel(cw, 'Control Panel')
floatPanel(cw, 'control')
dockPanel(cw, 'c')
```


Selecting specific nodes

```r
selectNodes(cw, 'Family1') # gives error
selectNodes(cw, 'Species1')
```


Here could get a list of those selected


```r
getSelectedNodes(cw)
```

```
## [1] "Species4"
```

```r
selectFirstNeighborsOfSelectedNodes(cw)
selected_nodes <- getSelectedNodes(cw)
```

What about printing window to a pdf or png??


```r
saveImage(cw,"test", "pdf", scale=1.0)
saveImage(cw,"test", "png", scale=0.3)
## shouldn't saveImage have in the See Also section something about saving session?
saveNetwork(cw, "test") ## makes test.cys, which is not a session file and I am not sure what to do with it...
## what about a saveSession idea??
```


# Send network to Cytoscape

Function to be ported to RCy3??

```r
## can I somehow port this function to RCy3?
toCytoscape <- function (igraphobj) {
  # Extract graph attributes
  graph_attr = graph.attributes(igraphobj)
  # Extract nodes
  node_count = length(V(igraphobj))
  if('name' %in% list.vertex.attributes(igraphobj)) {
    V(igraphobj)$id <- V(igraphobj)$name
  } else {
    V(igraphobj)$id <- as.character(c(1:node_count))
  }
  
  nodes <- V(igraphobj)
  v_attr = vertex.attributes(igraphobj)
  v_names = list.vertex.attributes(igraphobj)
  
  nds <- array(0, dim=c(node_count))
  for(i in 1:node_count) {
    if(i %% 1000 == 0) {
      print(i)
    }
    nds[[i]] = list(data = mapAttributes(v_names, v_attr, i))
  }
  
  edges <- get.edgelist(igraphobj)
  edge_count = ecount(igraphobj)
  e_attr <- edge.attributes(igraphobj)
  e_names = list.edge.attributes(igraphobj)
  
  attr_exists = FALSE
  e_names_len = 0
  if(identical(e_names, character(0)) == FALSE) {
    attr_exists = TRUE
    e_names_len = length(e_names)
  }
  e_names_len <- length(e_names)
  
  eds <- array(0, dim=c(edge_count))
  for(i in 1:edge_count) {
    st = list(source=toString(edges[i,1]), target=toString(edges[i,2]))
    
    # Extract attributes
    if(attr_exists) {
      eds[[i]] = list(data=c(st, mapAttributes(e_names, e_attr, i)))
    } else {
      eds[[i]] = list(data=st)
    }

    if(i %% 1000 == 0) {
      print(i)
    }
  }
  
  el = list(nodes=nds, edges=eds)
  
  x <- list(data = graph_attr, elements = el)
  print("Done.  To json Start...")
  return (toJSON(x))
}

mapAttributes <- function(attr.names, all.attr, i) {
  attr = list()
  cur.attr.names = attr.names
  attr.names.length = length(attr.names)
  
  for(j in 1:attr.names.length) {
    if(is.na(all.attr[[j]][i]) == FALSE) {
      #       attr[j] = all.attr[[j]][i]
      attr <- c(attr, all.attr[[j]][i])
    } else {
      cur.attr.names <- cur.attr.names[cur.attr.names != attr.names[j]]
    }
  }
  names(attr) = cur.attr.names
  return (attr)
}
```

