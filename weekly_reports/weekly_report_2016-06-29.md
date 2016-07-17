# Weekly report

## June 20th - June 29th 2016

### Progress to date:

- Edited cyPlot() function to be able to more simply create graphs that can be sent to Cytoscape via RCy3. See issue [#25](https://github.com/tmuetze/Bioconductor_RCy3_the_new_RCytoscape/issues/25) and pull request [#27](https://github.com/tmuetze/Bioconductor_RCy3_the_new_RCytoscape/pull/27) 
- Spent time getting the taxonomic info from Tara oceans into Cytoscape. (See [datasets in RCy3](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/data_sets_in_RCy3_for_use_with_cooccurence.Rmd) in for details.). 
- Started work on [clusterMaker functions](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/cluster_maker.md). Next step to figure out how to send more than one thing as a value and to create functions that would make this easy to work with.


### Plan for next week: 

- Edit EnrichmentMap vignette text (in progress)
- Write accompanying blog post on EnrichmentMap functions
- Continue to work on species co-occurrence network example:
    - fix cyplot() so that edges will be sent
    - continue on vignette so that layout is manipulated
    - add in images for the vignette
    - show a comparison between surface and DCM networks?
- Continue work on clusterMaker
- Draft ideas for poster on co-occurrence vignette for VOM meeting (July 18th)

### Problems or things that I am stuck on:

- Was stuck for a bit on sending networks made in igraph to Cytoscape via RCy3. RCy3 uses Bioconductor's graph package which I was less familiar with. Mark Grimes (@m-grimes) introduced me to cyPlot() which works ok, but required some more coding so that it would be more general. 


### Questions for mentor:

- (from last report) When shall we publish the introductory blog post? -JAG could publish on my own github site if the other is not working well. 
- should the functions related to EM be a separate package? or should I ask if it is something to be incorporated into RCy3? Should I be writing corresponding tests for use with these?

#### Response from mentor:

* Wait for the blog posts.
* For the EM code we can refactor it out later into a separate package.
* You can write tests, such as is the connection to Cytoscape
available, but there needs to be a way disable them because they won't
work in many situations. See the skip_on_bioc method here:

https://github.com/BioPAX/paxtoolsr/blob/master/R/paxtoolsr.R

I have some tests that needed to be skipped when Bioconductor runs tests.