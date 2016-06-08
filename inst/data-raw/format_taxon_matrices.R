
library(reshape2)
library(dplyr)
library(igraph)
library(Hmisc)

## will use DCM instead of surface..

# prokaryote_matrix <- read.delim("./matrix_15.txt",
#                                 check.names = FALSE,
#                                 row.names = 1)
# head(prokaryote_matrix)

## found out that the virus matrix contains both the prokaryote and virus taxa

prok_virus_matrix <- read.delim("./matrix_23.txt",                           check.names = FALSE,
                           row.names = 1)
## divide up the matrix
## viruses start with ph and can be found in Table X of Brum 2016
virus_matrix <- prok_virus_matrix[grepl("ph_", rownames(prok_virus_matrix)),]

prok_matrix <- prok_virus_matrix[!(rownames(prok_virus_matrix) %in% rownames(virus_matrix)),]

## need to remove the filter and unclassified
prok_matrix <- prok_matrix[!grepl("_filter", rownames(prok_matrix)),]
prok_matrix <- prok_matrix[!grepl("unclass", rownames(prok_matrix)),]


## only 19 sites in common. Let's say that rows have to be in at least 30% of them
n_sites <- ncol(virus_matrix)
eighty_percent_sites <- 0.2 * n_sites


## keep rows that are present in at least 80% of sites
virus_matrix <- virus_matrix[rowSums(virus_matrix == 0) < eighty_percent_sites,]

prok_in_virus <- prok_matrix[rowSums(prok_matrix == 0) < eighty_percent_sites,]


## let's talk about abundance of each speices
virus_matrix <- virus_matrix[rowSums(virus_matrix)/n_sites > 0.0001,]
rownames(virus_matrix) <- gsub("$", "_vir", rownames(virus_matrix))
prok_matrix <- prok_matrix[rowSums(prok_matrix)/n_sites > 0.0001,]
rownames(prok_in_virus) <- gsub("$", "_prok", rownames(prok_in_virus))

## what is ph_99?

## only want to look at comparisons between the two data frames...and not within each data frame...

A <- as.matrix(virus_matrix)
B <- as.matrix(prok_matrix)

## so what I want to do is correlations across rows. Which or
## ok I think this did what I wanted. 
test_row_by_row <- cor(t(A), t(B))
test_row_by_row[upper.tri(test_row_by_row)] <- NA


## also only want the between virus and bac

## show compare these two. One seems to have many more than the other....
# tara_cor <- rcorr(t(A), t(B),
#                   type="spearman")
# # 
#  correlations <- tara_cor$r
#  p_values <- tara_cor$P
# # 
# # ## get rid of the upper section by turning to NA. 
# correlations[upper.tri(correlations )] <- NA
# p_values[upper.tri(p_values)] <- NA
# # 
# melted_cor <- melt(correlations)
# melted_p <- melt(p_values)
# # 
# melted_together <- cbind(melted_p$value,
#                           melted_cor)
# # 
# melted_together <- na.omit(melted_together) ## gets rid of the leftover diagonals
# names(melted_together)
# names(melted_together)[1] <- "p_value"
# names(melted_together)[4] <- "weight"
# 
# filtered_row_by_row <- filter(melted_together, abs(weight) > 0.8 & p_value < 0.001)

## now remove those with less than 0.6 
melted_rows <- melt(test_row_by_row)
melted_together <- na.omit(melted_rows)
filtered_row_by_row <- filter(melted_together, abs(value) > 0.8)

no_self_filtered_row_by_row <- filter(filtered_row_by_row, value != 1)

write.table(no_self_filtered_row_by_row,"../../data/virus_prok_cor.tsv",
            sep="\t")

graph_dune <- graph.data.frame(no_self_filtered_row_by_row,
                               directed=FALSE)
plot(graph_dune)
