

## need to read in xls file
library(readxl)
library(rentrez)
library(stringr)
phage_ids <- "./Tara_Phage_host_copresence.xls"

first_sheet <- read_excel(phage_ids, sheet = 1)

second_sheet <- read_excel(phage_ids, sheet = 2)

sum(second_sheet$Phage_id %in% first_sheet$Phage_id) # only 73!

phage_affiliation <- second_sheet$Affiliation[match(first_sheet$Phage_id, second_sheet$Phage_id)]

network_ids_with_affiliation <- data.frame(first_sheet$Phage_id,
                                           first_sheet$Phage_id_network, phage_affiliation
)

## testing out trying to search for taxonomic data
all_phage_affiliations <- levels(network_ids_with_affiliation$phage_affiliation)


get_tax_lineage_fr_NCBI <- function(phage_from_affiliation ) {
  test_cyano <- entrez_search("genome",
                              phage_from_affiliation)
  
  cyano_data <- entrez_link(db="all",
                            id=test_cyano$ids,
                            dbfrom="genome")
  cyano_data$links$genome_taxonomy
  
  cyano_tax_xml <- entrez_fetch(db="taxonomy",
                                id=cyano_data$links$genome_taxonomy,
                                rettype = "xml",
                                parsed = TRUE)
  
  lineage <- XML::xpathSApply(cyano_tax_xml,                                        
                              "//Lineage",
                              XML::xmlValue) 
  split_lineage <- str_split(lineage, ";")
  print(phage_from_affiliation)
  print(split_lineage)
  return(split_lineage)
}

test <- get_tax_lineage_fr_NCBI(all_phage_affiliations[7])

list_of_affiliations <- sapply(all_phage_affiliations[-19], get_tax_lineage_fr_NCBI)


## because these are not all the same length
indx <- lengths(list_of_affiliations) 
data_frame_aff <- as.data.frame(do.call(rbind,
                                        lapply(list_of_affiliations,
                                               `length<-`,
                                               max(indx))))
colnames(data_frame_aff) <- c("Domain",
                              "DNA_or_RNA",
                              "Tax_order",
                              "Tax_subfamily",
                              "Tax_family",
                              "Tax_genus",
                              "Tax_species")


## ok now add this in to to the original table

## for each row, if there is a match 
phage_ids_with_affiliation <- data.frame(first_sheet.Phage_id = factor(),
                                         first_sheet.Phage_id_network = factor(),
                                         phage_affiliation = factor(),
                                         Domain = factor(),
                                         DNA_or_RNA = factor(),
                                         Tax_order = factor(),
                                         Tax_subfamily = factor(),
                                         Tax_family = factor(),
                                         Tax_genus = factor(),
                                         Tax_species = factor())


seven_nas <- rep(NA, 7)
names(seven_nas) <- c("Domain",
                      "DNA_or_RNA",
                      "Tax_order",
                      "Tax_subfamily",
                      "Tax_family",
                      "Tax_genus",
                      "Tax_species")

## do not know why row 7 is having a problem. 
for (row in 1:nrow(network_ids_with_affiliation)){
  print(row)
  if (is.na(network_ids_with_affiliation[row,"phage_affiliation"])) {
    print("yay")
    current_row <- network_ids_with_affiliation[row,]
    new_row <- c(current_row, seven_nas)
    phage_ids_with_affiliation <- rbind(phage_ids_with_affiliation,new_row)
    ## add columns of NAs
  }
  else{
    ## add matching row for phage name
    row_of_interest <- data_frame_aff[network_ids_with_affiliation[row,"phage_affiliation"],]
    current_row <- network_ids_with_affiliation[row,]
    new_row <- cbind(current_row, row_of_interest)
    phage_ids_with_affiliation <- rbind(phage_ids_with_affiliation,new_row)
  }
}

write.csv(phage_ids_with_affiliation, "../../data/phage_ids_with_affiliation.csv")