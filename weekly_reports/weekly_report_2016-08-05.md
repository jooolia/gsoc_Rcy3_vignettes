# Weekly report

## Week August 2nd-August 5th 2016
Things I did this week:

- took the holiday on August 1st (CH and CA both had days off)
- emailed Scooter Morris re: problem I am having getting the output from clustermaker2 to display in Cytoscape when run via cyREST. Message returned when command run is "Finished" and the http status is 200. 
- For the Enrichment Map vignette continued along adding in further stuff from:
  - AutoAnnotate: running into the same problem as in clusterMaker2. Get "Finished" as content and http is 200. Have asked for help on the [Bader lab repo](https://github.com/BaderLab/AutoAnnotateApp/issues/68#issuecomment-237782592)
  - WordCloud: runs successfully via cyREST, but no way to programmatically export the image (as in the Cytoscape gui app). Have requested such functionality via github [issue](https://github.com/BaderLab/WordCloudPlugin/issues/57)
  - Scale issue: zoom on images changes each time the Rmd is run. Might consider saving in another format that could play nicely with the Rmd vignette. 
- Have submitted some small functions to RCy3 for selecting nodes and edges and for copying networks. Commites were merged into [project](https://github.com/tmuetze/Bioconductor_RCy3_the_new_RCytoscape/commit/0084963beb2e5b9d34c6ee513b66cf23e890b774). 

## Next week: 
- Enrichment Map vignette:
  - Would really like to resolve the issues with clusterMaker and AutoAnnotate that I am having. If there seems to be no quick resolution I will at least make the EMs look more aesthetically pleasing and we could make a blog post from this. 

- Tara oceans network:
	- tidy up writing for vignette
	- determine what else needs to be done here: want to give a general idea of how to display these networks, but this is not always the most efficient way to get the info from them, so what to really show?

- Work on subnetwork function:
	- incorporate the edges for the new network via R using the newly created functions that I have submitted to RCy3. (e.g. copy network function will be easily modified to make a function to create a subnetwork from selected nodes).
	
- Prepare for the final evaluation:
  - What can I reasonably finish and what are the most important aspects?
  - Discuss with mentor
  
## Mentor feedback
  
  - make sure that some vignettes are finished soon. 
  - PaxtoolsR and microbiome should be more straightforward and need to be completed. 
  - ones that were discussed previously clusterMaker, cyanimator, chemviz, enrichmentmap, microbiome, paxtoolsr. Need to have basic steps taken on them. 
  - share screen to show what the problem is with clustermaker window
  - send reminder e-mail to Scooter regarding clusterMaker
  - blog post - a few people have seen it.
  - submit issues for both: scale issue for RCy3 and cyREST h parameter. 
  
  
