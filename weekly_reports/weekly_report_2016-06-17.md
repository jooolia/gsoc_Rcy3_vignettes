# Weekly report

## June 13th- June 17th 2016

### Progress to date:

- Successfully recreated Enrichment maps from tutorials on the Bader lab website (http://www.baderlab.org/Software/EnrichmentMap/Tutorial) and github repo(https://github.com/BaderLab/EM-tutorials-docker).
- Spent time getting the taxonomic info from Tara oceans. (See [readme.md](gsoc_Rcy3_vignettes/inst/data-raw/readme.md) in /inst/data/ for details.) Furthermore had to retrieve bacterial taxonomic annotation references from SILVA database and parse into an appropriate format. 
- Getting a better understanding of S4. Roger Peng videos helped greatly here (https://www.youtube.com/watch?v=93N0HdoZW9g). 
- Will be submitting a few small functions to RCy3 on accessing namespaces and adding help() to the overall package.

### Plan for next week: 

- Finish writing up EnrichmentMap vignette
- Write accompanying blog post on EnrichmentMap functions
- Continue to work on species co-occurrence network example:
    - add in taxonomic data for networks
    - consider comparing to surface water network
- Write post on the first progress in these examples
- If time permits start working with cytoscape plugins: clusterMaker, cyanimator, chemviz. 

### Problems or things that I am stuck on:

- Wondered about small issue with expression data from Bader lab tutorial in [cell 16](https://github.com/BaderLab/EM-tutorials-docker/blob/master/notebooks/Create%20Enrichment%20Map%20directly%20from%20R.ipynb). Emailed Ruth Isserlin to see if she had any insight. 

### Questions for mentor:

- When shall we publish the introductory blog post?