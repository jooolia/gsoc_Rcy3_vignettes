
library(reshape2)
library(dplyr)
library(igraph)
library(Hmisc)

## will use DCM 
## the virus matrix contains both the prokaryote and virus taxa
prok_virus_matrix <- read.delim("./matrix_23.txt",                           check.names = FALSE,
                           row.names = 1)
## divide up the matrix
## viruses start with ph and can be found in Table X of Brum 2016
virus_matrix <- prok_virus_matrix[grepl("ph_", rownames(prok_virus_matrix)),]

prok_matrix <- prok_virus_matrix[!(rownames(prok_virus_matrix) %in% rownames(virus_matrix)),]

## need to remove the filter and unclassified
prok_matrix <- prok_matrix[!grepl("_filter", rownames(prok_matrix)),]
prok_matrix <- prok_matrix[!grepl("unclass",
                                  rownames(prok_matrix)),]

## keep rows that are present in at least 80% of sites
n_sites <- ncol(virus_matrix)
eighty_percent_sites <- 0.2 * n_sites
virus_matrix <- virus_matrix[rowSums(virus_matrix == 0) < eighty_percent_sites,]

prok_in_virus <- prok_matrix[rowSums(prok_matrix == 0) < eighty_percent_sites,]

## let's talk about abundance of each speices
virus_matrix <- virus_matrix[rowSums(virus_matrix)/n_sites > 0.0001,]
# rownames(virus_matrix) <- gsub("$",
#                                "_vir",
#                                rownames(virus_matrix))
prok_matrix <- prok_matrix[rowSums(prok_matrix)/n_sites > 0.0001,]
# rownames(prok_in_virus) <- gsub("$",
#                                 "_prok",
#                                 rownames(prok_in_virus))

## only want to look at comparisons between the two data frames...and not within each data frame...

A <- as.matrix(virus_matrix)
B <- as.matrix(prok_matrix)

## so what I want to do is correlations across rows. Which or
## ok I think this did what I wanted. 
cor_row_by_row <- cor(t(A), t(B))
cor_row_by_row[upper.tri(cor_row_by_row)] <- NA

## now remove those with less than 0.6 
melted_rows <- melt(cor_row_by_row)
melted_together <- na.omit(melted_rows)

names(melted_together)[3] <- "weight"
filtered_row_by_row <- filter(melted_together,
                              abs(weight) > 0.8)

no_self_filtered_row_by_row <- filter(filtered_row_by_row,
                                      weight != 1)

write.table(no_self_filtered_row_by_row,
            "../../data/virus_prok_cor.tsv",
            sep="\t")