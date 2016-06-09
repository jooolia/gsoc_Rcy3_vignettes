# Weekly report

## June 6th- June 10th 2016

### Progress to date:

- Successfully used the RCy3 framework to create an enrichment map in Cytoscape. The next goals for this would then be to manipulate the network via RCy3. Another goal would be to create robust functions that enable the creating of Enrichment map using RCy3. I need to be thinking of further analysis that can be done. 

- I sorted out a data set that will be used for a vignette on microbial co-occurence networks. It is data from Tara Oceans (see big Science issue here: http://www.aaas.org/news/science-tara-oceans-expedition-yields-treasure-trove-plankton-data) and the data I will include in this vignette are from metagenomic data. The data I have chosen to include is from the viruses and bacteria at the deep chlorophyll maximum, that is the depth in the water column where there is the highest concentration of photosynthetic organisms. The data are available [online](http://www.raeslab.org/companion/ocean-interactome.html), and are mostly well annotated but I corresponded a bit with the authors to confirm a few more details about the data and how they are organized. The data, the e-mails and the scripts used to process the data are in the folder [inst/data-raw](../inst/data-raw/). 

- The next step with these networks would be to be able to do layouts that separate the viruses from the prokaryotes and also to be able to add the taxonomic data to these networks. 

- Slowly making progress on OO and S4. Getting there, but still not completely understanding how it works, but getting a better understanding about methods and classes in S4. 

### Plan for next week: 

- Continue to work on EnrichmentMap functions and then vignette:
    - convert EnrichmentMap functions to work properly in the S4 framework
    
- Continue to work on species co-occurrence network example:
    - add in taxonomic data for networks
    - further analysis and layouts to look at ecology of microbes
    - consider comparing to surface water network
- Write post on the first progress in these examples

### Problems or things that I am stuck on:

- Got stuck a bit on how to send graphs with attribute data to Cytoscape via RCy3. Have posted an issue on the [RCy3 repo](https://github.com/tmuetze/Bioconductor_RCy3_the_new_RCytoscape/issues/25) and an example of what I was trying to do in [my gsoc repo](https://github.com/jooolia/gsoc_Rcy3_vignettes/blob/master/testing_sending_data_edge_and_node_data_to_Cy/testing_igraph_properties.md)

### Questions for mentor:

- Once I get functions working for Enrichment map, how should I continue the analysis?