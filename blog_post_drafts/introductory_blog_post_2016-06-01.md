# Introducing the Google Summer of Code project on extending RCy3 vignettes

[Cytoscape](http://www.cytoscape.org/) is a popular open-source program for visualizing and analysing networks (biological and otherwise).

This summer [I](www.juliagustavsen.com) have been working on a [Google Summer of Code project](https://summerofcode.withgoogle.com/projects/#6682250145955840) with the [National Resource for Network Biology](http://nrnb.org/) that aims to make it easier for scientists to run [Cytoscape](http://www.cytoscape.org/) via R (using [CyREST](https://github.com/cytoscape/cyREST)). Cytoscape is a very powerful tool for visualizing and analysing networks, and as scientists generate more data it can be efficient to reuse the same analytical steps on different dataset or to easily re-run analyses. The main objective of the project has been and will be to create code demonstrations of common workflows using the Bioconductor R package [RCy3](https://bioconductor.org/packages/release/bioc/html/RCy3.html). 

## Description of the project

One of the main goals of this project is to extend the vignettes in RCy3 to demonstrate how some common workflows in Cytoscape can be scripted in R. RCy3 uses the [CyREST](https://github.com/cytoscape/cyREST) framework to send commands to Cytoscape. These vignettes will cover a range of network analysis topics. 

Another goal is to enable the scripting of some analytical functions in Cytoscape (using Cytoscape plugins). Plugins that are currently being developed for this workflow include [Enrichment Map](http://www.baderlab.org/Software/EnrichmentMap) and [Clustermaker2](http://www.cgl.ucsf.edu/cytoscape/clusterMaker2/clusterMaker2.shtml). 

### Things I am excited to do and learn about:
- making workflows that are flexible enough to be included in the package and flexible enough for people to use with their data.
- encouraging extensibility in the RCy3 workflows and functions to make it clear how users can extend RCy3 to make it work with different Cytoscape plugins that use REST APIs. 
- Finding candidate datasets to be used in the vignettes to be included in RCy3.
- S4 object-oriented programming: The RCy3 package is written using the S4 framework. To understand and potentially extend the package I will need to learn about the S4 framework.
- Working with JSON in R.
- Learning more about different types of network analyses for biological data

## People involved

### Student developper

I recently completed my PhD at the University of British Columbia in Vancouver, B.C.. My dissertation work was on the diversity and ecology of groups of marine viruses and their hosts in coastal waters of British Columbia. As part of my dissertation, I used network analysis and Cytoscape to visualize co-occurrence of the microbes in a time-series at our study site in Vancouver. 

#### Summer project motivation:

I did some network analysis as part of my PhD and am interested in learning more about networks and their analysis, working with other open source developers, facilitating analysis for other scientists, learning more about R package development and how to make a great vignette, and of course improving my R skills. 

### Mentor 

Google summer of code projects are all guided by a mentor with experience in the area of the project. My mentor is [Augustin Luna](http://lunean.com/), research Fellow in the Department of Biostatistics and Computational Biology, and Dana-Farber Cancer Institute at Harvard University, Boston, MA. Author of the R package [paxtoolsr](https://github.com/BioPAX/paxtoolsr).

## In progress: 

- Currently making a vignette on species co-occurrence networks (food webs)
- Writing functions to enable access to Cytoscape plugins via RCy3
- Writing a vignette on using [EnrichmentMap](http://www.baderlab.org/Software/EnrichmentMap) with RCy3

## Conclusion

The ultimate goal of the project is to extend the vignettes in RCy3 and also to provide useful workflows for scientists using Cytoscape. 

Work will be done in [this Github repository](https://github.com/jooolia/gsoc_Rcy3_vignettes) and then vignettes and functions could be integrated into the [development version of RCy3](https://github.com/tmuetze/Bioconductor_RCy3_the_new_RCytoscape). 

### Do you use Cytoscape and R together? 

If you use Cytoscape and R, do you use them together? What would you like to see? What kind of data do you use? What would you like to do, but can't or find challenging to do in your current analysis?

If interested you can fill in [this google form](https://docs.google.com/forms/d/1_XsAFzIE1YQbBnLRdql2KLpYo4namn7PPdsVhX7CpD0/viewform?c=0&w=1&usp=mail_form_link) or get in touch via [e-mail](mailto:j.gustavsen@gmail.com) or [twitter](http://twitter.com/JuliaGustavsen).
