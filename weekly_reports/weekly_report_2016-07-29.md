# Weekly report

## Week July 25th-29th
Things I did this week:

- edited first potential blog post of RCy3
- tidy up Enrichment map vignette 
	- download new release with bug fix
	- recreated the tutorials.
    - would like feedback on:
      - intro to vignette, is this specific enough?
      - I am not clear what the difference between ```build``` and ```gseabuild``` as available from cyREST are. Any thoughts? I have not used gseabuild to recreate the tutorials. Is it a better option for some data?
      - Section 5 option 2 does not work. I don't know what is going on. Should I just drop it or any thoughts on why it might not be working? 
      - Section 6 - not clear how to iterate what the purpose is and it is not clear to me from the original tutorial. Could you help me explain a bit what is going on (i.e. I am not sure where these files are from or how they were generated. )
- question about functions used for working with EnrichmentMap:
  - setEnrichmentMapProperties() uses the last made window in Cytoscape as the one to connect to to get the EnrichmentMap graph into R. Is there a situation where using the last made window for this enrichment map will fail? What other option could I find?


## Next week: 
- Tara oceans network:
	- tidy up writing for vignette
	- determine what else needs to be done here: want to give a general idea of how to display these networks, but this is not always the most efficient way to get the info from them, so what to really show?

- Work on subnetwork function:
	- incorporate the edges for the new network via R. Edit and tidy function from Mark Grimes. (Alternatively how to replicate what that button in Cytoscape does when you click "Create Subnetowrk from selected nodes")

- Clustermaker 
  - move forward with the functions used for this plugin. 
