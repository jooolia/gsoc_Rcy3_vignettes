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

##JAG note:
From Sunagawa: taxonomically annotated 16S reference
sequences from the SILVA database (release
115: SSU Ref NR 99) 

To get this info I downloaded https://www.arb-silva.de/fileadmin/silva_databases/release_115/Exports/SSURef_NR99_115_tax_silva.fasta.tgz

then I ran ```grep "^>" SSURef_NR99_115_tax_silva.fasta > ~/windows_school/gsoc/gsoc_RCy3_vignettes/inst/data-raw/SSURef_NR99_115_tax_silva_headers.txt

## 10 June 2016

Emailed Dr. Matt Sullivan (corresponding author on Brum et al 2015 paper: [Patterns and ecological drivers of ocean viral communities. Science. 348. doi:10.1126/science.1261498.] (http://www.sciencemag.org/content/348/6237/1261498.full))

My email: 

Hi Dr. Sullivan,

I hope that you are well and perhaps I will see you this summer at either VOM or ISME in Montreal. 

I'm working on a small project this summer that is funded by Google summer of code with the National Resource on Network Biology and we're looking to facilitate the reproducible analysis of biological networks (project here and working github repo here ). I thought it would be great to use some of the Tara oceans data for one of the examples that we are developing. 

I want to use the deep chlorophyll max virus and bacteria,archaea abundance tables and I have discussed a bit with the Raes lab and they have been very helpful for figuring out some things, but I have one question for your group. 
1) Are the annotations for the viral clusters available? I mean those that look like ph_9996. I have looked in the http://mirrors.iplantcollaborative.org/browse/iplant/home/shared/iVirus/TOV_43_viromes folder, but perhaps I overlooked something. I realize it is not a big deal to redo this analysis, but thought it would be more straightforward to use the annotations from the papers.

Thanks for any help! 

Cheers, Julia

### Response: 

Hi Julia,

Thank you for your email, great to hear about this project to try to reproduce the networks. I’m assuming you want the annotations for the protein clusters (the viral clusters are something different) or else for the viral populations. Cesar or Simon can help you with this for the protein clusters or viral populations, respectively. Both are CC’d to this email.

Best,
Matt

### Response: 
Hi Julia,

Enclosed is a spreadsheet that should help (to some extent.. ). Fist tab has the co-presence of phage and host (i.e. the co-occurrence network results), with the correspondence between network ids (ph_XXXX) and the contig ID (that you have in the files at http://mirrors.iplantcollaborative.org/browse/iplant/home/shared/iVirus/TOV_43_viromes). Second tab has all the BLAST-based affiliations we have for these contigs: note that most of the contigs are "unclassified" (meaning that they have inconsistent hits to multiple phages, or no hits at all), and not all contigs are in this affiliation table (we only tried to affiliated large contigs, as we did not believe that contigs with 2-3 genes could give us a reliable affiliation). The lack of affiliation is also due to the fact that we used very stringent cutoffs (we really looked for contigs near-identical to isolated phages). The good side of this is that when we provide an affiliation, usually we are relatively confident that the contigs come from a virus with a similar host as the isolate (at least most of the time). 

Anyway, let me know if you have any question on these data, or if anything looks inconsistent !

Best,

Simon

attached: Tara_Phage_host_copresence.xls


