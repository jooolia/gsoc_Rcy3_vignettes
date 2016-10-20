# Description of vignettes created during the GSOC project

This summer I have worked on a project for the Google Summer of Code to create a number of demonstrations of the Bioconductor R package RCy3 that could be used to run common workflows in Cytoscape. My goal was to create some vignettes that would help users create reproducible work for their analysis using Cytoscape. In this post I discuss five of the vignettes that I worked on. Some vignettes turned out to be more challenging than initially planned, but I am hopeful that some of the roadblocks that I encountered (see details below in sections about EnrichmentMap and Clustermaker2), can be resolved in the future. 

## Background on RCy3

RCy3 is an R package that interacts with Cytoscape and was updated from a previous version by developers Tanja Muetze, Paul Shannon and Georgi Kolishovski. It was converted from another version (RCytoscape) to leverage a new way of interacting with Cytoscape, via an application programming interface (API) called cyREST. cyREST was developed to facilitate the scripting of network visualizations and analysis in Cytoscape using various programming languages. 

# Description of five vignettes

## Enrichment Map:

Enrichment analysis of different genes can be done in Cytoscape using the plugin [Enrichment Map](http://nrnb.org/tools/enrichmentmap.html). To demonstrate how to conduct these analyses with RCy3 and Cytoscape, I have recreated the tutorial created by the [Bader lab](http://www.baderlab.org/Software/EnrichmentMap/Tutorial) by using RCy3 and some small functions to script this analysis. See [here for the markdown](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/recreating_enrichment_map_vignette.md) and [here for the pdf](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/recreating_enrichment_map_vignette.pdf)

### Going further with Enrichment Map

There are several Cytoscape plugins that can make these enrichment map figures more easily interpretable and visually appealing. Two of these plugins are autoannotate and wordcloud, however, I have not yet gotten them to work with cyREST. [Autoannotate](http://apps.cytoscape.org/apps/autoannotate) automatically annotates the enrichment maps created. [Wordcloud](http://apps.cytoscape.org/apps/wordcloud) creates a word cloud of the desired annotations from an enrichment map. (Can also be used with any kind of analysis where it plots the frequency of certain words occuring in the network). If there were a way to export the image automatically then the annotations could be made into a word cloud that would be generated each time an analysis was run. These plugins could be useful for automating these analyses in the future. Some ideas of this was tested out in [part two of the EM vignette](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/recreating_enrichment_map_vignette_part2.md)

## Co-occurence network vignette from microbial global ocean data:
Biologists are often interested in examining which organisms inhabit the same areas. I used data from one part of the global [Tara Oceans expedition](http://oceans.taraexpeditions.org/) to look at how often viruses and bacteria co-occur in different oceanic sites. These co-occurrences are made into a network which is visualized in Cytoscape. Then I used taxonomic data associated with the network to highlight different aspects of the network. See [here for the markdown file]( https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/tara_oceans_co-occurence_net_RCy3_vignette.md) or [here for the pdf](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/tara_oceans_co-occurence_net_RCy3_vignette.pdf)

## Paxtoolsr

Retrieving and analysing biological pathway information is important for many different scientists. Paxtoolsr is an [R Bioconductor package](http://bioconductor.org/packages/release/bioc/html/paxtoolsr.html) that leverages the java tools library paxtools. These tools are very helpful for retrieving information from Pathway Commons, and retrieving a network or subnetwork related to a particular pathway. In this vignette I used paxtoolsr to retrieve various different kinds networks and then used RCy3 to visualize and manipulate them in Cytoscape. See the markdown version [here](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/paxtoolsR_vignette.md) or the pdf version [here](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/paxtoolsR_vignette.pdf) 

## Chemviz

In Cytoscape, using a plugin called [Chemviz](http://www.cgl.ucsf.edu/cytoscape/chemViz2/index.shtml), it is possible to examine the chemical properties of sample data and then use these chemical data to associate the 2D chemical structures to the samples. It is also possible to create similarity networks from a list of  of chemicals and visualize their similarity this way. I used the R package [rcellminer](https://github.com/cannin/rcellminer) to generate some data to look a some drug compounds.Then I used the Chemviz plugin via RCy3 to display the chemical structures on the nodes of the networks. I then created a similarity network and coloured the nodes based on their associated method of actions (MOA) to see if it is related to their similarity. See here for the [markdown version of the vignette](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/chemviz_vignette.md) and here for the [pdf version](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/chemviz_vignette.pdf).

## clustermaker2 (work in progress)

Another common activity done with networks is clustering the nodes based on the network properties to be able to make inferences about the network. In Cytoscape there is a popular plugin that is used to do this called [Clustermaker2](http://apps.cytoscape.org/apps/clustermaker2). Working with this plugin was a bit of a challenge because commands that I thought would work exactly as they did with the graphical user interface (GUI) required a little playing around with. 

This vignette is not yet completed. I have created a demo of the commands that are required to run clustermaker2 via RCy3. The clusters are supposed to end up as information that is associated with the "network table " (http://idekerlab.github.io/cyREST/), so the network table thus needs to be parsed to find out which clusters belong to which group. See here for the [work in progress](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/cluster_maker.md)

# Conclusion

Thanks for reading! If you have any questions or comments feel free to email me at j.gustavsen@gmail.com or get in touch about the code via github. 