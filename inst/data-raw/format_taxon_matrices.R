
library(reshape2)
library(dplyr)
library(igraph)
library(Hmisc)

## will use DCM instead of surface..

prokaryote_matrix <- read.delim("./matrix_15.txt",
                                check.names = FALSE,
                                row.names = 1)
head(prokaryote_matrix)


virus_matrix <- read.delim("./matrix_23.txt",                           check.names = FALSE,
                           row.names = 1)


## so have to pick columns that are in both
prok_in_virus <- subset(prokaryote_matrix,
                        select = colnames(prokaryote_matrix) %in% colnames(virus_matrix))

## only 19 sites in common. Let's say that rows have to be in at least 30% of them
n_sites <- ncol(virus_matrix)
eighty_percent_sites <- 0.2 * n_sites


## keep rows that are present in at least 80% of sites
virus_matrix <- virus_matrix[rowSums(virus_matrix == 0) < eighty_percent_sites,]

prok_in_virus <- prok_in_virus[rowSums(prok_in_virus == 0) < eighty_percent_sites,]


## let's talk about abundance of each speices
virus_matrix <- virus_matrix[rowSums(virus_matrix)/n_sites > 0.001,]
rownames(virus_matrix) <- gsub("$", "_vir", rownames(virus_matrix))
prok_in_virus <- prok_in_virus[rowSums(prok_in_virus)/n_sites > 0.001,]
rownames(prok_in_virus) <- gsub("$", "_prok", rownames(prok_in_virus))
## what is ph_99?

## only want to look at comparisons between the two data frames...and not within each data frame...

A <- as.matrix(virus_matrix)
B <- as.matrix(prok_in_virus)

## so what I want to do is correlations across rows. Which or
## ok I think this did what I wanted. 
test_row_by_row <- cor(t(A), t(B))
test_row_by_row[upper.tri(test_row_by_row)] <- NA


## also only want the between virus and bac

## but some have the same accession numbers....what is happening here?


## show compare these two. One seems to have many more than the other....
# tara_cor <- rcorr(t(A), t(B),
#                   type="spearman") 
# 
# correlations <- dune_cor$r
# p_values <- dune_cor$P
# 
# ## get rid of the upper section by turning to NA. 
# correlations[upper.tri(correlations )] <- NA
# p_values[upper.tri(p_values)] <- NA
# 
# melted_cor <- melt(correlations)
# melted_p <- melt(p_values)
# 
# melted_together <- cbind(melted_p$value,
#                          melted_cor)
# 
# melted_together <- na.omit(melted_together) ## gets rid of the leftover diagonals
# names(melted_together)
# names(melted_together)[1] <- "p_value"
# names(melted_together)[4] <- "weight"

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
