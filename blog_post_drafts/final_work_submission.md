# Final work submission:

Here I have included the work that I have done by topic, but also all of the commits that I have made are linked at the bottom of this page under "View by commits".

## Original work goal:

- Create vignettes of common and/or useful workflows in RCy3 with Cytoscape. Wanted to recreate and show to make some common things, but also wanted to show how to use different Cytoscape plugins via RCy3

## Challenges:

RCy3 is a R package that has been converted from a previous version by a group of developpers. The reason that it was converted to another version is because of an API, cyREST, which was developped to work programming languages to enable the scriptability of network visualisations and analysis in Cytoscape. Also increases the reproducibility of this kind of work. 

Below I will list the main vignettes that I have worked. Not included in this, but included in the commit section are functions and little fixes that I submitted to the RCy3 package. 

# Work by topic

(including work left to do)

## Enrichment Map:

Enrichment analysis of different genes and (then how is it visualized as a network?) can be done in Cytoscape using the plugin Enrichment Map (link). Here I have recreated the tutorial presented by the [Bader lab](http://www.baderlab.org/Software/EnrichmentMap/Tutorial) by using RCy3 and some small functions to script this analysis. See here: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/recreating_enrichment_map_vignette.md

## Co-occurence network vignette:

Have used data from part of the Tara Oceans [Tara Oceans Expedition](http://oceans.taraexpeditions.org/) expedition to look at the co-occurrence of viruses and bacteria in different oceanic sites.  The network is visualized and then we used some of the taxonomic data associated with the network to ask questions of the network and also to find parts of the network where we would like to examine more of it or to ask more questions or to explore more. See here: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/tara_oceans_co-occurence_net_RCy3_vignette.md

## Paxtoolsr

Paxtoolsr is an R package (link) that leverages the java tools library paxtools. These tools are very helpful for retrieving information from Pathway commons, and retrieving a network or subnetwork related to a particular pathway. In this vignette we used paxtoolsr to retrieve different networks and then we used RCy3 to visualize them in Cytoscape. See here: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/paxtoolsR_vignette.md

## clustermaker2

Another common activity done with networks is clustering the nodes based on the network properties to be be able to make inferences about the network. In Cytoscape there is a popular plugin that is used to do this called "Clustermaker2" (website link). Working with this plugin was a bit of a challenge because commands that I thought would work exactly as they did with the graphical user interface (gui) required a little playing around with. This vignette is not completed, I have created a demo of the commands that are required to run clustermaker2 via RCy3. The clusters end up as information that is associated with the "network table " (link here to cyrest api page), so the network table thus needs to be parse to find out which clusters belong to which group. See here for the work in progress: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/cluster_maker.md

## Chemviz

Another activity that is possible in Cytoscape is examing the chemical properties of sample data and then using these chemical data to associate the 2D chemical structures with the samples and also to create similarity networks of a subset of chemicals (drugs) and examine groups chemicals in this way. We used the R package rcellminer (link) to get information about XX and then we ran the data through the Chemviz using RCy3 where we displayed the chemical structures on the nodes of the networks, we created a similarity network and we coloured the nodes based on their method of actions(MOA). See here for this vignette: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/chemviz_vignette.md


## Blog posts:

### Posted:

- Introduction to the project: 

### To come:

- Experience working with cyREST
- a post about each of these topics


# View by commits:

### Commits to single author repository where I have developped these vignettes.

The coding is in the .Rmd files and in a directory entitled "functions_to_add_to_RCy3" which contains .R files:

https://github.com/jooolia/gsoc_Rcy3_vignettes/commits/master?author=jooolia 

### Commits to the RCy3 development repository:

https://github.com/tmuetze/Bioconductor_RCy3_the_new_RCytoscape/commits/master?author=jooolia

