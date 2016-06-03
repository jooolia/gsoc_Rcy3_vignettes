# Weekly report

## May 23rd - June 3rd 2016

- please note: no report for week of May 23rd because student was moving. 

### Progress to date:

- Wrote introductory blog post to promote project, RCy3 and the work. [See file](../blog_post_drafts/introductory_blog_post_2016-06-01.md)
- Successfully accessed EnrichmentMap namespace commands in Cytoscape via R and RCy3. Created a function using RCy3 (using S4 framework) to access these commands. [See section in file](playing_around_with_Rcy3.md#finding-command-names-available-in-cytoscape-using-r)
- Started vignette for species co-occurrence network analysis. Have used RCy3 vignette to get started and will start modifying example to answer questions about the data set(what?). Working on using some data released as part of Tara Oceans (http://www.raeslab.org/companion/ocean-interactome.html). Would like to use the data from the surface ocean bacteria and the surface ocean phages. This leads me to questions on how to organize data when it could be included as part of a package. I have been looking at [the data of Advanced R](http://r-pkgs.had.co.nz/data.html), but would likely need permission of authors. (Do I keep a data-raw folder like https://github.com/hadley/babynames and then save processed data to /data?) 
- Submitted a pull request to [RCy3](https://github.com/tmuetze/Bioconductor_RCy3_the_new_RCytoscape/pull/23). Just changing latex quote characters, but more so to test out how to work with the developers. Success from developing on branch and then submitting pull request. They granted me push access to repository, but I am a bit too timid to just push to repo on my own.
 - I think that there are small little things that I could do that would be very helpful such as adding help(RCy3) via roxygen comments. 

### Plan for next week: 

- Continue to work on EnrichmentMap functions and then vignette:
    - work on functions that will enable user to set parameters in EnrichmentMap
- Continue to work on species co-occurrence network example:
    - decide on questions to ask of dataset and how to filter dataset (maybe focus on specific phage types and associated bacteria?)
    - have this example ready to be reviewed by the end of next week.
- Write post on the first progress in these examples
- plan out next two vignettes (not that the first two will be completely finished, but rather to  be able to start thinking about the next approaches):metabolic interactions, and protein-protein interactions

### Problems or things that I am stuck on:

- Still learning how S4 classes work. Do not quite understand how it works yet. Have been looking at the page in [Hadley Wickam's Ad-R on OO](http://adv-r.had.co.nz/OO-essentials.html) and the [bioconductor tutorial](http://www.bioconductor.org/help/course-materials/2010/AdvancedR/S4InBioconductor.pdf)
- How much to worry about how general the functions are?? E.g. if I make something for Enrichment Map is that ok or should I somehow make it so that i can interact with other plugins? Maybe ok to start like that?

### Questions for mentor:

- Is there a good dataset that I could play around with for Enrichment Map vignette? Something that could be helpful for you? 
- What else? Is there anything else I should be doing? 