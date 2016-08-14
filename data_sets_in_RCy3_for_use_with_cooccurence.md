# data_sets_in_RCy3
Julia Gustavsen  
May 24, 2016  

# Descriptions of vignette

## Tara Oceans

So there has been many projects where they collect data from all over the world. Some, such as the pioneering Venter study have pioneered metagenomic and others have just been interesting ways to collect a lot of data.

The researchers have boarded a small sailboat and collected samples that were from many different size fractions of microorganisms in the the oceans over a period of X years. They collected these samples so that they could look at the different kinds of microorganisms present in different parts of the oceans and to see what the patterns of the presence and distribution of these organisms were over space. 

They collected all of these samples and then either used targeted sequencing (amplicon approach using primers for specific targets such as the ribosomal markers and PCR ) or using metagenomic sequencing (here they sequence all of the genetic material in a sample so that it is not based on what has been seen before, but trying to sequence as much as possible all of the genetic material from the sample) of each of the different size fractions.

After the sequencing and quality checking of the samples was done the sequences were classified (different approaches for the different targets, see here for the details). After that the data could be made into a species occurrence table where you have rows of the different sites and then columns of the different organisms found there.

## What is co-occurence data?

Many of these species have not been characterized in the lab and thus to know more about the species and their interactions we can often look to see which ones are occurring at the same sites or under the same kinds of environmental conditions. One way that we can do that is by using co-occurrence networks where it is examined which species are occurring together at which sites and the more frequently that this happens the more stronger the interaction you predict among different species. For a review of some of the different kinds of software please see: Knight  et al paper. There are many different ways to do this and many different software that can be used to calculate these interaction networks.

## What kinds of things can we find out using this?

These kinds of analyses can be useful for the data with where have not characterized the organisms in the lab because they can give us insights about the communities and how the organisms are interacting within them and also they can be exploratory so that we can then see organisms that then warrant further insights and perhaps experiments. 

We can also learn about how the overall community is structure by looking at some of the network properties..

## More specifically what kind of data here?

In this data set we have data that have come from the bacterial dataset and also from the viral dataset. We compared the data to see how the viral data co-occurs with the 

# Set up Cytoscape and R connection


```r
library(RCy3)
library(igraph)
library(RJSONIO)
library(reshape2)
library(dplyr)
library(RColorBrewer)
```
**Note** to run this example your Cytoscape software must be open. If you are having problems installing please see (this)[XX]. In Cytoscape we will also need Allegro-plugin for this example. **IS THERE A WAY TO TEST THIS?**?

We will run this example using RCy3 to provide a connection between our Rsession and Cytoscape using CyREST (link here).

Here we create a connection in R that we can use to manipulate the networks and then we will delete any windows that we in Cytoscape (if there are none that was no problem) so that we don't use up all of our memory. 

```r
cy <- CytoscapeConnection()
deleteAllWindows(cy)
```

# Read in data

We will read in a species co-occurrence matrix that was calculated using Spearman Rank coefficient. (If interested in seeing how this was done please see scripts in inst/data-raw)

Or how to describe how this was done??

```r
## scripts for processing in "inst/data-raw/"
prok_vir_cor <- read.delim("./data/virus_prok_cor_abundant.tsv")
```

There are many different ways to work with graphs in R. We will use both the igraph (link) and the graph (link) package to work with our network with Cytoscape.

The igraph package is used to convert the co-occurrence dataframe into a network that we can send to Cytoscape. In this case our graph is undirected (so "directed = FALSE") since we do not have any information about which way the interactions are going. 

```r
graph_vir_prok <- simplify(graph.data.frame(prok_vir_cor,
                                            directed = FALSE))
```

# Read in taxonomic classification

Since these are data from small, microscopic organisms that were sequenced using shotgun sequencing (for details see the papers here: XXX) we do not always know what they are. It is useful to know what kind of organisms are in the samples. In this case the bacterial viruses (bacteriophage), were classified by Basic Local Alignment Search Tool (BLAST http://blast.ncbi.nlm.nih.gov/Blast.cgi) by searching for their closest resembling sequence in **XX* database (see methods here). The percent of the read and the identity required between the study sequences and the databases. that had to match the database


```r
phage_id_affiliation <- read.delim("./data/phage_ids_with_affiliation.tsv")
bac_id_affi <- read.delim("./data/prok_tax_from_silva.tsv")
```

# Get the network in a mode to send to Cytoscape

I think this could be hidden and put somewhere else so that if it is of interest it could be used, otherwise I could simplify things. 

just have some key things here. 

```r
genenet.nodes <- as.data.frame(vertex.attributes(graph_vir_prok))

## ids do not match for the phage ids 
## move this to the raw data stuff.
phage_id_affiliation$first_sheet.Phage_id_network <- gsub("-",
                                                          "_",
                                                          phage_id_affiliation$first_sheet.Phage_id_network)

## not all have classification, so create empty columns
## before had NA but was worried it was messing up the setting of attributes.
genenet.nodes$phage_aff <- rep("test", nrow(genenet.nodes))
genenet.nodes$Tax_order <- rep("test", nrow(genenet.nodes))
genenet.nodes$Tax_subfamily <- rep("test", nrow(genenet.nodes))

for (row in seq_along(1:nrow(genenet.nodes))){
  if (genenet.nodes$name[row] %in% phage_id_affiliation$first_sheet.Phage_id_network){
    aff_to_add <- unique(subset(phage_id_affiliation,
              first_sheet.Phage_id_network == genenet.nodes$name[row],
              select = c(phage_affiliation,
                         Tax_order,
                         Tax_subfamily)))
    
    genenet.nodes$phage_aff[row] <- as.character(aff_to_add$phage_affiliation)
    genenet.nodes$Tax_order[row] <- as.character(aff_to_add$Tax_order)
    genenet.nodes$Tax_subfamily[row] <- as.character(aff_to_add$Tax_subfamily)
  }
}
## do the same for proks

genenet.nodes$prok_king <- rep("test", nrow(genenet.nodes))
genenet.nodes$prok_tax_phylum <- rep("test", nrow(genenet.nodes))
genenet.nodes$prok_tax_class <- rep("test", nrow(genenet.nodes))

for (row in seq_along(1:nrow(genenet.nodes))){
  if (genenet.nodes$name[row] %in% bac_id_affi$Accession_ID){
     aff_to_add <- unique(subset(bac_id_affi,
              Accession_ID == as.character(genenet.nodes$name[row]),
              select = c(Kingdom,
                         Phylum,
                         Class)))
    
    genenet.nodes$prok_king[row] <- as.character(aff_to_add$Kingdom)
    genenet.nodes$prok_tax_phylum[row] <- as.character(aff_to_add$Phylum)
    genenet.nodes$prok_tax_class[row] <- as.character(aff_to_add$Class)
  }
}

genenet.edges <- data.frame(as_edgelist(graph_vir_prok))
names(genenet.edges) <- c("name.1",
                          "name.2")
genenet.edges$Weight <- edge_attr(graph_vir_prok)[[1]]

genenet.edges$name.1 <- as.character(genenet.edges$name.1)
genenet.edges$name.2 <- as.character(genenet.edges$name.2)
genenet.nodes$name <- as.character(genenet.nodes$name)

## works if I load the source from the cyplot Branch of Rcy3
ug <- cyPlot(genenet.nodes,genenet.edges)
```

# Send network to Cytoscape using RCy3


```r
cw <- CytoscapeWindow("Tara oceans",
                      graph = ug,
                      overwriteWindow = TRUE)
```


```r
displayGraph(cw)
layoutNetwork(cw)
```

![](./co-occur0.svg)<!-- -->

# Colour network by prokaryotic phylum

We would like to get an overview of the different phylum of bacteria that we have in our network. One way that this can be visualized is by colouring the different nodes based on their phylum classifications. Rcolorbrewer will be used to generate a set of good (???) colours to colour the nodes. It will be seen how many nodes there are and then it can be seen what the strong associations are. 


```r
families_to_colour <- unique(genenet.nodes$prok_tax_phylum)
families_to_colour <- families_to_colour[!families_to_colour %in% "test"]
node.colour <- brewer.pal(length(families_to_colour),
                          "Set3")
setNodeColorRule(cw,
                 'prok_tax_phylum',
                 families_to_colour,
                 node.colour,
                 "lookup",
                 default.color='#ffffff')
```

```
## Successfully set rule.
```



```r
displayGraph(cw)
```

![](./co-occur0_1.svg)<!-- -->

## Set node shape to reflect virus or prokaryote

Next we would like to change the shape of the node to reflect whether the nodes are viral or bacterial in origin. We know that in the dataset all of the viral node names start with "ph_", so thus we can set the viral nodes to be diamonds by looking for all the nodes that start with "ph" in the network. 

```r
## set shape to be virus or prok
shapes_for_nodes <- c('DIAMOND')

phage_names <- grep("ph_",
                    genenet.nodes$name,
                    value = TRUE)
setNodeShapeRule(cw,
                 "label",
                 phage_names,
                 shapes_for_nodes)
```

```
## Successfully set rule.
```


```r
displayGraph(cw)
```


![](./co-occur1.svg)<!-- -->

# Colour edges of phage nodes

The classification of the viral data was done in a very conservative manner, but if we do want to add some of this information in to our visualization we can add some colouring of the viral nodes by family. The main families that were identified in this dataset are the *Podoviridae*, the *Siphoviridae* and the *Myoviridae* (for more info see here: NCBI or GenBank link.)


```r
setDefaultNodeBorderWidth (cw, 5)
families_to_colour <- c(" Podoviridae",
                        " Siphoviridae",
                        " Myoviridae")
node.colour <- brewer.pal(length(families_to_colour),
                          "Dark2")
setNodeBorderColorRule(cw,
                 'Tax_subfamily',
                 families_to_colour,
                 node.colour,
                 "lookup", 
                 default.color = "#000000")
```

```
## Successfully set rule.
```


```r
displayGraph(cw)
```

![](./co-occur2.svg)<!-- -->

# Do layout to minimize overlap of nodes. 

After doing all of this colouring to the network we would like to lay out the network in a way that allows us to see more easily which nodes are connected to which ones without overlapping. Do to do that we are using the plugin app Allegro. 

If we are not sure what the current values are for a layout or we are not sure what kinds of values are accepted for the different parameters of our layout we can investigate using the RCy3 functions `getLayoutPropertyNames()` and then `getLayoutPropertyValue()`.


```r
getLayoutNames(cy)
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

```r
getLayoutPropertyNames(cw, layout.name = 'allegro-spring-electric')
```

```
## [1] "randomize"                    "maxIterations"               
## [3] "noOverlapIterations"          "deviceSelection"             
## [5] "componentProcessingSelection" "componentSorting"            
## [7] "scale"                        "gravityTypeSelection"        
## [9] "gravity"
```

```r
getLayoutPropertyValue(cw, 'allegro-spring-electric',"gravity") 
```

```
## [[1]]
## [1] 100
```

```r
getLayoutPropertyValue(cw, 'allegro-spring-electric',"maxIterations")  
```

```
## [[1]]
## [1] 2000
```

```r
getLayoutPropertyValue(cw, 'allegro-spring-electric',"noOverlapIterations")
```

```
## [[1]]
## [1] TRUE
```

Once we decide on the properties we want, we can go ahead and set them like this:


```r
setLayoutProperties(cw,
                    layout.name = 'allegro-spring-electric',
                    list(gravity = 100,
                         scale = 6))
```

```
## Successfully updated the property 'gravity'.
## Successfully updated the property 'scale'.
```

```r
layoutNetwork(cw,
              layout.name = 'allegro-spring-electric')
```

![](./co-occur3.svg)<!-- -->

# Look at network properties

One thing that might be interesting when we look at our network is to highlight the nodes that are connected to many different nodes and those that are not very connected. We can use a gradient of colour to do this. 


```r
## add degree property to cw
## r colour brewer colours for variety of degrees. From low to high. 
## YlGn as a series of colours?
## new one
ug2 <- initNodeAttribute (graph = ug,
                          'degree',
                          'numeric',
                          0.0) 

## degree from graph package for undirected graphs not working well.
nodeData(ug2, nodes(ug2), "degree") <- degree(graph_vir_prok)

cw2 <- CytoscapeWindow("Tara oceans with degree",
                      graph = ug2,
                      overwriteWindow = TRUE)
```


```r
displayGraph(cw2)
layoutNetwork(cw2)
```

# Size by degree

(what do the different sizes mean? How do I find out about this?)

```r
degree_control_points <- c(min(degree(graph_vir_prok)),
                           mean(degree(graph_vir_prok)),
                           max(degree(graph_vir_prok)))
node_sizes <- c(20,
                20,
                80,
                100,
                110)

setNodeSizeRule(cw2,
                "degree",
                degree_control_points,
                node_sizes,
                mode = "interpolate")
```

```
## Locked node dimensions successfully even if the check box is not ticked.
## Locked node dimensions successfully even if the check box is not ticked.
## Successfully set rule.
```

```r
layoutNetwork(cw2,
              "force-directed")
```





<img src="./co-occur_degree.svg" width="1600" />

# Select an interesting node and make a subnetwork

The degree visualization showed us that perhaps we would like to look at all the cyanobacterial nodes that are hignodes connected to node XX, we have already decided that we want to investigate this node further experimentally, but perhaps we also want to examine and visualize the nodes associated with node XX. 

-To do so we will select x node,
-select all of its first neighbours
-make a new netwokr (ensuring there are all the nodes also selected)



```r
selectNodes(cw2,
            "GQ377772") # selects specific nodes
getSelectedNodes(cw2)
```

```
## [1] "GQ377772"
```

```r
selectFirstNeighborsOfSelectedNodes(cw2)
getSelectedNodes(cw2)
```

```
##  [1] "ph_3164"  "ph_1392"  "ph_1808"  "ph_3901"  "ph_407"   "ph_4377" 
##  [7] "ph_553"   "ph_765"   "ph_7661"  "GQ377772"
```


```r
selectFirstNeighborsOfSelectedNodes(cw2)
getSelectedNodes(cw2)
```

```
##  [1] "ph_3164"       "ph_1392"       "ph_1808"       "ph_3901"      
##  [5] "ph_407"        "ph_4377"       "ph_553"        "ph_765"       
##  [9] "ph_7661"       "AACY020207233" "AY663941"      "AY663999"     
## [13] "AY664000"      "AY664012"      "EF574484"      "EU802893"     
## [17] "GQ377772"      "GU061586"      "GU119298"      "GU941055"
```



```r
selectEdgesConnectedBySelectedNodes <- function(c_w) {
 selectedNodes = getSelectedNodes(c_w)
 if (length (selectedNodes) == 1 && is.na (selectedNodes))
   return ()
 graphEdges <- getAllEdges(c_w)  
 selectedEdges <- unlist(mapply(function(x) return(graphEdges [grep(x, graphEdges)]), selectedNodes)) 
 if (length (selectedEdges) > 0)
    selectEdges(c_w, selectedEdges)
 }
# END selectEdgesConnectedBySelectedNodes	

selectEdgesConnectedBySelectedNodes(cw2)

getSelectedEdges(cw2)
```

```
##   [1] "ph_1703 (unspecified) AY663941"     
##   [2] "ph_1703 (unspecified) EF574484"     
##   [3] "ph_1703 (unspecified) EU802893"     
##   [4] "ph_1703 (unspecified) GU119298"     
##   [5] "ph_1871 (unspecified) GU119298"     
##   [6] "ph_18855 (unspecified) EU802893"    
##   [7] "ph_193 (unspecified) EU802893"      
##   [8] "ph_24577 (unspecified) EF574484"    
##   [9] "ph_24577 (unspecified) EU802893"    
##  [10] "ph_24577 (unspecified) GU119298"    
##  [11] "ph_3280 (unspecified) EU802893"     
##  [12] "ph_36155 (unspecified) EU802893"    
##  [13] "ph_36155 (unspecified) GU119298"    
##  [14] "ph_5108 (unspecified) EU802893"     
##  [15] "ph_5981 (unspecified) EU802893"     
##  [16] "ph_675 (unspecified) EU802893"      
##  [17] "ph_675 (unspecified) GU119298"      
##  [18] "ph_841 (unspecified) EF574484"      
##  [19] "ph_1095 (unspecified) AY663941"     
##  [20] "ph_1095 (unspecified) AY664000"     
##  [21] "ph_1095 (unspecified) AY664012"     
##  [22] "ph_1186 (unspecified) AY663941"     
##  [23] "ph_1186 (unspecified) AY663999"     
##  [24] "ph_1186 (unspecified) AY664000"     
##  [25] "ph_1186 (unspecified) AY664012"     
##  [26] "ph_1186 (unspecified) EF574484"     
##  [27] "ph_1205 (unspecified) AY663941"     
##  [28] "ph_1205 (unspecified) AY663999"     
##  [29] "ph_1205 (unspecified) AY664000"     
##  [30] "ph_1205 (unspecified) AY664012"     
##  [31] "ph_1205 (unspecified) EF574484"     
##  [32] "ph_1392 (unspecified) AY663941"     
##  [33] "ph_1392 (unspecified) AY664000"     
##  [34] "ph_1392 (unspecified) AY664012"     
##  [35] "ph_1392 (unspecified) EF574484"     
##  [36] "ph_1392 (unspecified) GQ377772"     
##  [37] "ph_1392 (unspecified) GU119298"     
##  [38] "ph_1392 (unspecified) GU941055"     
##  [39] "ph_1808 (unspecified) AY663941"     
##  [40] "ph_1808 (unspecified) AY664000"     
##  [41] "ph_1808 (unspecified) AY664012"     
##  [42] "ph_1808 (unspecified) EF574484"     
##  [43] "ph_1808 (unspecified) GQ377772"     
##  [44] "ph_1808 (unspecified) GU119298"     
##  [45] "ph_1808 (unspecified) GU941055"     
##  [46] "ph_3901 (unspecified) AY663941"     
##  [47] "ph_3901 (unspecified) AY664000"     
##  [48] "ph_3901 (unspecified) AY664012"     
##  [49] "ph_3901 (unspecified) EF574484"     
##  [50] "ph_3901 (unspecified) GQ377772"     
##  [51] "ph_3901 (unspecified) GU119298"     
##  [52] "ph_3901 (unspecified) GU941055"     
##  [53] "ph_407 (unspecified) AY663941"      
##  [54] "ph_407 (unspecified) AY664000"      
##  [55] "ph_407 (unspecified) AY664012"      
##  [56] "ph_407 (unspecified) EF574484"      
##  [57] "ph_407 (unspecified) GQ377772"      
##  [58] "ph_407 (unspecified) GU119298"      
##  [59] "ph_407 (unspecified) GU941055"      
##  [60] "ph_4377 (unspecified) AY663941"     
##  [61] "ph_4377 (unspecified) AY663999"     
##  [62] "ph_4377 (unspecified) AY664000"     
##  [63] "ph_4377 (unspecified) AY664012"     
##  [64] "ph_4377 (unspecified) EF574484"     
##  [65] "ph_4377 (unspecified) GQ377772"     
##  [66] "ph_4377 (unspecified) GU061586"     
##  [67] "ph_4377 (unspecified) GU119298"     
##  [68] "ph_4377 (unspecified) GU941055"     
##  [69] "ph_553 (unspecified) AY663941"      
##  [70] "ph_553 (unspecified) AY664000"      
##  [71] "ph_553 (unspecified) AY664012"      
##  [72] "ph_553 (unspecified) EF574484"      
##  [73] "ph_553 (unspecified) GQ377772"      
##  [74] "ph_553 (unspecified) GU119298"      
##  [75] "ph_553 (unspecified) GU941055"      
##  [76] "ph_765 (unspecified) AY663941"      
##  [77] "ph_765 (unspecified) EF574484"      
##  [78] "ph_765 (unspecified) EU802893"      
##  [79] "ph_765 (unspecified) GQ377772"      
##  [80] "ph_765 (unspecified) GU119298"      
##  [81] "ph_1431 (unspecified) AY663999"     
##  [82] "ph_1431 (unspecified) GU061586"     
##  [83] "ph_6665 (unspecified) AY663999"     
##  [84] "ph_6665 (unspecified) EF574484"     
##  [85] "ph_6665 (unspecified) GU061586"     
##  [86] "ph_2435 (unspecified) AY664012"     
##  [87] "ph_2435 (unspecified) GU119298"     
##  [88] "ph_2435 (unspecified) GU941055"     
##  [89] "ph_3450 (unspecified) AY664012"     
##  [90] "ph_4276 (unspecified) AY664012"     
##  [91] "ph_4276 (unspecified) EF574484"     
##  [92] "ph_4358 (unspecified) AY664012"     
##  [93] "ph_7661 (unspecified) AY664012"     
##  [94] "ph_7661 (unspecified) GQ377772"     
##  [95] "ph_7661 (unspecified) GU119298"     
##  [96] "ph_11583 (unspecified) EF574484"    
##  [97] "ph_16719 (unspecified) EF574484"    
##  [98] "ph_16719 (unspecified) GU119298"    
##  [99] "ph_2393 (unspecified) EU802893"     
## [100] "ph_331 (unspecified) EU802893"      
## [101] "ph_408 (unspecified) EU802893"      
## [102] "ph_459 (unspecified) EU802893"      
## [103] "ph_4072 (unspecified) GU940773"     
## [104] "ph_4072 (unspecified) HQ671891"     
## [105] "ph_1258 (unspecified) AACY020207233"
## [106] "ph_3164 (unspecified) AACY020207233"
## [107] "ph_3164 (unspecified) AY663941"     
## [108] "ph_3164 (unspecified) AY664000"     
## [109] "ph_3164 (unspecified) AY664012"     
## [110] "ph_3164 (unspecified) EF574484"     
## [111] "ph_3164 (unspecified) EU802893"     
## [112] "ph_3164 (unspecified) GQ377772"     
## [113] "ph_3164 (unspecified) GU061586"     
## [114] "ph_3164 (unspecified) GU119298"     
## [115] "ph_3164 (unspecified) GU941055"
```

Move to separate file

```r
library(httr)
subnetwork_from_selected <- function(obj,
                                     copy.graph.to.R = TRUE) {
  ## get selected nodes
  resource.uri <- paste(obj@uri,
                        pluginVersion(obj),
                        "networks",
                        obj@window.id,
                        "nodes?column=selected&query=true",
                        sep = "/")
  request.res <- GET(url = resource.uri)
  
  selected.node.SUIDs <- fromJSON(rawToChar(request.res$content))
  
  selected_node_SUIDs.json <- toJSON(selected.node.SUIDs)
  
  ## create new network from the selected nodes
  resource.uri <- paste(obj@uri,
                        pluginVersion(obj),
                        "networks",
                        obj@window.id,
                        sep = "/")
  request.res <- POST(resource.uri,
                      body = selected_node_SUIDs.json,
                      encode = "json")
  
  ## connect to this new network
  resource.uri <- paste(cy@uri,
                        pluginVersion(cy),
                        "networks",
                        sep = "/")
  request.res <- GET(resource.uri)
  # SUIDs list of the existing Cytoscape networks	
  cy.networks.SUIDs <- fromJSON(rawToChar(request.res$content))
  # most recently made will have the highest SUID
  cy.networks.SUIDs.last <- max(cy.networks.SUIDs)
  
  res.uri.last <- paste(cy@uri,
                        pluginVersion(cy),
                        "networks",
                        as.character(cy.networks.SUIDs.last),
                        sep = "/")
  result <- GET(res.uri.last)
  net.name <- fromJSON(rawToChar(result$content))$data$name
  
  if (copy.graph.to.R){
    subnetwork_from_selected <- existing.CytoscapeWindow(net.name,
                                                         copy.graph.from.cytoscape.to.R = TRUE)
    
    print(paste("Cytoscape window",
                 net.name,
                 "successfully connected to R session and graph copied to R."))
  } 
  else {
    subnetwork_from_selected <- existing.CytoscapeWindow(net.name,
                                                         copy.graph.from.cytoscape.to.R = FALSE) 
    print(paste0("Cytoscape window ",
                 net.name,
                 " successfully connected to R session."))
  }
  
  invisible(request.res)
  return(subnetwork_from_selected)    
  
}

newnet <- subnetwork_from_selected(cw2)
```

```
## [1] "Cytoscape window Tara oceans with degree(1) successfully connected to R session and graph copied to R."
```

```r
layoutNetwork(newnet, "force-directed")
```




<img src="./co-occur_subnet.svg" width="1600" />


## Conclusion 

Text here!

## References

-followup- how to read in a network generated by qiime??
