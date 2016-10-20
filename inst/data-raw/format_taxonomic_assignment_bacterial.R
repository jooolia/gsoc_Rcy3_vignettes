library(stringr)
library(tidyr)
library(dplyr)
results <- read.delim("./SSURef_NR99_115_tax_silva_headers.txt", header=F)
results <- as.data.frame(str_split_fixed(results$V1, " ", n=2))
results$V1 <- gsub(">","", results$V1)

results <- separate(results,
                    V2,
                    c("Kingdom",
                      "Phylum",
                      "Class",
                      "Order",
                      "Family",
                      "Genus",
                      "Species",
                      "What",
                      "What2",
                      "What3",
                      "What4",
                      "What5",
                      "What6",
                      "What7",
                      "What8"),
                    sep = ";")

results <- filter(results, Kingdom == "Bacteria" | Kingdom == "Archaea")
names(results)[1] <- "Accession_ID"

## find matches in matrix23.txt

## it seems to be able to find the matches the accession ids in the matrix you need to get rid of some of the numbers after the periods.
results$Accession_ID <- gsub("([[:alnum:]]*)\\.?.*$", "\\1", results$Accession_ID)


prok_virus_matrix <- read.delim("./matrix_23.txt",
                                check.names = FALSE,
                                row.names = 1)

## just bacteria to make sure htey are all identified
virus_matrix <- prok_virus_matrix[grepl("ph_", rownames(prok_virus_matrix)),]

prok_matrix <- prok_virus_matrix[!(rownames(prok_virus_matrix) %in% rownames(virus_matrix)),]
Found_In_Silva <- rownames(prok_matrix)[rownames(prok_matrix) %in% results$Accession_ID]

## filter the table to be just those found in the tara oceans

taxa_in_tara_oc <- filter(results, Accession_ID %in% Found_In_Silva)
## the other columns were all empty after removing the 
## eukaryotes from the table
taxa_in_tara_oc_trimmed <- select(taxa_in_tara_oc, Accession_ID, Kingdom,
                                  Phylum,Class,Order,Family,Genus, Species)

write.table(taxa_in_tara_oc_trimmed,
            "../../data/prok_tax_from_silva.tsv",
            sep="\t")