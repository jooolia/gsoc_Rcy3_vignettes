# Final work submission for GSOC project:

This summer I have worked on a project for the Google Summer of Code to create a number of demonstrations of the R package RCy3 that could be used to run common workflows in Cytoscape. RCy3 is a R package that interacts with Cytoscape that was updated from a previous version by a group of developpers. The reason that it was converted to another version is because of an API, cyREST, which was developped to enable the scriptability of network visualisations and analysis in Cytoscape using various different programming languages. 

In this page I have included the work that I have done by topic, and also at the bottom of the page is a list of all the commits that I have made to this project's repository and to the RCy3 project repository under "View by commits".

## Original work goal:

- Create vignettes of common and/or useful workflows in RCy3 with Cytoscape. The idea was to recreate common workflows via scripting and to highlight how to do this with some different Cytoscape plugins via RCy3.

## Challenges:

There have been several unanticipated challenges that I have encountered while working with these workflows.

I will elaborate further in a forthcoming blog post, but I will list a few of the surprising challenges here:

1) Saving images from Cytoscape via cyREST is really dependent on the size of the window that you have open. You can use a parameter "h" which sets the size of the final image, but the width is set automatically.
2) Plugins in Cytoscape that present an API interface do not have a standard verb-action vocabulary. This is not a huge deal, but requires some guessing of how plugins can be used via cyREST. 

# Work by topic

(including work left to do)

## Enrichment Map:

Enrichment analysis of different genes can be done in Cytoscape using the plugin Enrichment Map (http://nrnb.org/tools/enrichmentmap.html). Here I have recreated the tutorial presented by the [Bader lab](http://www.baderlab.org/Software/EnrichmentMap/Tutorial) by using RCy3 and some small functions to script this analysis. See here: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/recreating_enrichment_map_vignette.md and https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/recreating_enrichment_map_vignette_part2.md

There are several plugins that quickly make these figures more easy to interpret and visually appealing. Two of these plugins are autoannotate and wordcloud, however I have not gotten them to work with cyREST as they work with this gui, yet. Things that I would like to do if plugins were tweaked: 

- autoannotate - could be used to automatically annotate the enrichment maps created. 
- wordcloud - if a way to export the image automatically were available then the annotations could be made into a word cloud that would be generated each time. 

## Co-occurence network vignette:

Have used data from part of the Tara Oceans [Tara Oceans Expedition](http://oceans.taraexpeditions.org/) expedition to look at the co-occurrence of viruses and bacteria in different oceanic sites.  The network is visualized and then we used some of the taxonomic data associated with the network to ask questions of the network and also to find parts of the network where we would like to examine more of it or to ask more questions or to explore more. See here: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/tara_oceans_co-occurence_net_RCy3_vignette.md

### Other activities

I presented part of this analysis at the Viruses of Microbes meeting in Liverpool, UK. Repository that contains the poster and code used to generate it are [here](https://github.com/jooolia/RCy3_VOM_poster)

## Paxtoolsr

Paxtoolsr is an R package (http://bioconductor.org/packages/release/bioc/html/paxtoolsr.html) that leverages the java tools library paxtools. These tools are very helpful for retrieving information from Pathway Commons, and retrieving a network or subnetwork related to a particular pathway. In this vignette we used paxtoolsr to retrieve different networks and then we used RCy3 to visualize them in Cytoscape. See here: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/paxtoolsR_vignette.md

## clustermaker2

Another common activity done with networks is clustering the nodes based on the network properties to be be able to make inferences about the network. In Cytoscape there is a popular plugin that is used to do this called "Clustermaker2" (http://apps.cytoscape.org/apps/clustermaker2). Working with this plugin was a bit of a challenge because commands that I thought would work exactly as they did with the graphical user interface (gui) required a little playing around with. This vignette is not completed, I have created a demo of the commands that are required to run clustermaker2 via RCy3. The clusters end up as information that is associated with the "network table " (http://idekerlab.github.io/cyREST/), so the network table thus needs to be parsed to find out which clusters belong to which group. See here for the work in progress: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/cluster_maker.md

## Chemviz

Another activity that is possible in Cytoscape is examing the chemical properties of sample data and then using these chemical data to associate the 2D chemical structures with the samples and also to create similarity networks of a subset of chemicals (drugs) and examine groups chemicals in this way. We used the R package rcellminer (https://github.com/cannin/rcellminer) to get information about XX and then we ran the data through the Chemviz (http://www.cgl.ucsf.edu/cytoscape/chemViz2/index.shtml) using RCy3 where we displayed the chemical structures on the nodes of the networks, we created a similarity network and we coloured the nodes based on their method of actions(MOA). See here for this vignette: https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/chemviz_vignette.md

## Blog posts:

### Posted:

- Introduction to the project: http://blog.lunean.com/2016/08/05/extending-rcy3-vignettes-google-summer-of-code-project/

### To come:

- Experience working with cyREST
- a post about each of these topics

# View by commits:

### Commits to single author repository where I have developped these vignettes.

The coding is in the .Rmd files and in a directory entitled "functions_to_add_to_RCy3" which contains .R files:

https://github.com/jooolia/gsoc_Rcy3_vignettes/commits/master?author=jooolia 

### Commits to the RCy3 development repository:

https://github.com/tmuetze/Bioconductor_RCy3_the_new_RCytoscape/commits/master?author=jooolia

