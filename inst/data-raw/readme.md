Data retrieved from Tara Oceans paper. 

http://www.raeslab.org/companion/ocean-interactome.html

Abundance tables for the phage and prokaryotes in the surface. 


## 7 June 2016

Sent email to Dr. Raes (corresponding author for Lima-Mendez paper) to answer some questions regarding the data and some confusion:

Greetings Dr. Raes,

I am currently working on a Google Summer of Code project on visualizing biological networks in Cytoscape programmatically using R (project description here). I developing some examples with code and I thought that using some of the Tara Ocean would be interesting. 

I have downloaded the data from your lab's website (abundance tables), and have re-read the methods of both the Lima-Mendez and Brum papers, but I still had a few additional questions about the data and how they are organized.

Specifically I am trying to work with matrix23.txt and matrix15.txt which I assume to refer to prok_phage_DCM ( so bacterial and archaeal viruses in the deep chlorophyll max) and then prok_DCM  (so bacteria and archaea in the deep chlorophyll max). 

My questions are:

1) Where do these Taxon IDs come from? From the methods section it says that bacterial metagenomes were annotated using SILVA, but I only find what seem to be Genbank accession numbers which are to metagenomes. 

2) Is there more info on the phage ids? e.g. ph_9998

3) I am wondering why so many of the same ids in the phage table and the bacterial table are shared? For the sites that are common the abundance seems to be the same.

4) What do "prok_to_filter", "bact_to_filter", and "phage_to_filter" mean?

If there is another resource that you can point me to that explains the data a bit more I am happy to continue my investigations there.  

Thanks!

Sincerely, Julia Gustavsen

## Response

Dear Julia,

Thanks for your interest in using this dataset,

here below I ‘ll answer your questions.


> Specifically I am trying to work with matrix23.txt

matrix_23 contains phage and bacterial counts (it is actually a merge of 2 fractions, phage only abundances are never used).

and matrix15.txt which I assume to refer to prok_phage_DCM ( so bacterial and archaeal viruses in the deep chlorophyll max) and then prok_DCM  (so bacteria and archaea in the deep chlorophyll max). 

> My questions are:

> 1) Where do these Taxon IDs come from? From the methods section it says that bacterial metagenomes were annotated using SILVA, but I only find what seem to be Genbank accession numbers which are to metagenomes. 

The taxonIds are the SILVA accession numbers, e.g. AACY020068177 in http://www.arb-silva.de/search/: 


AACY020068177	marine metagenome	1478	94.36%	95.19%	n/a	Bacteria;Chloroflexi;SAR202 clade


> 2) Is there more info on the phage ids? e.g. ph_9998

yes, these phage ids correspond to phage contig populations generated in Brum et al. The first and second column of accompanying table W12 (available at http://www.raeslab.org/companion/ocean-interactome.html) specified the contig - phageId pair.

> 3) I am wondering why so many of the same ids in the phage table and the bacterial table are shared? For the sites that are common the abundance seems to be the same.

Because the phage table contains the bacterial table. Because of our procedure we generated one table per network, we inferred 23 networks that were later merged.

> 4) What do "prok_to_filter", "bact_to_filter", and "phage_to_filter" mean?

They correspond to the sum of all rows (OTUs) that were filtered because they were below the prevalence threshold (being present in at least 20-50% of samples depending on the fraction). They are not considered for generating the network but the sum is kept so when renormalization is done the rest of the abundances are not re-scaled…

> If there is another resource that you can point me to that explains the data a bit more I am happy to continue my investigations there.

Everything is in http://www.raeslab.org/companion/, plus you can consult also Sunagawa et al for details on the annotation of bacteria and archaea). Please do not hesitate in asking us if you don’t get all your answers in those.

> Thanks!

> Sincerely, Julia Gustavsen

Cheers,

Gipsi

