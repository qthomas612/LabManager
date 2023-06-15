
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("DESeq2")
library(DESeq2)

setwd("~/Downloads/")

countdata1<-as.matrix(read.csv("count_matrix.csv", row.names="Geneid"))
head(countdata1)

countdata2 <- countdata1[,c(6:210)]
head(countdata2)

rnames <- rownames(countdata2)
cnames <- colnames(countdata2)
c_temp <- str_split(cnames, "_", n = 2)
cnames <- sapply(c_temp,"[[",1)

count2 <- matrix(as.numeric(unlist(countdata2)),nrow=nrow(countdata2))
rownames(count2) <- rnames
colnames(count2) <- gf
head(count2)

coldata1<-as.matrix(read.csv("sample_info1.csv", header = TRUE, row.names=1))
coldata2<-as.matrix(read.csv("sample_info2.csv", header = TRUE, row.names=1))

colD1 <- as.matrix(coldata1[,2])
colD2 <- as.matrix(coldata2[,2])
colnames(colD1) <- "Treatment"
colnames(colD2) <- "Treatment"

gf <- rownames(colD1)

head(coldata1)

ddsJac <- DESeqDataSetFromMatrix(countData = count2, colData = colD1, design =~ Treatment)

ddsJac$sample <- as.factor(cnames)
#ddsJac$

ddsColl1 <- collapseReplicates(ddsJac, ddsJac$sample)


#######################################################################
# Add in proper ensembl gene names
#######################################################################

#read in count data files
counts_TnA<-as.data.frame(read.csv("counts_with_genes_TnA.csv"))
counts_POA<-as.data.frame(read.csv("counts_with_genes_POA.csv"))

geneNames<- read.delim("GenesWithNames.txt", header = TRUE, sep = "\t")


colnames(counts_TnA)[1:2] <- c("Gene.stable.ID", "Annotation.Names") 
colnames(counts_POA)[1:2] <- c("Gene.stable.ID", "Annotation.Names") 


merged1 <- merge(geneNames, counts_TnA)
merged2 <- merge(geneNames, counts_POA)

write.csv(merged1, file="counts_with_egenes_TnA.csv")
write.csv(merged2, file="counts_with_egenes_POA.csv")









dds <- makeExampleDESeqDataSet(m=12)

# make data with two technical replicates for three samples
dds$sample <- factor(sample(paste0("sample",rep(1:9, c(2,1,1,2,1,1,2,1,1)))))
dds$run <- paste0("run",1:12)

ddsColl <- collapseReplicates(dds, dds$sample, dds$run)

# examine the colData and column names of the collapsed data
colData(ddsColl)
colnames(ddsColl)

# check that the sum of the counts for "sample1" is the same
# as the counts in the "sample1" column in ddsColl
matchFirstLevel <- dds$sample == levels(dds$sample)[1]
stopifnot(all(rowSums(counts(dds[,matchFirstLevel])) == counts(ddsColl[,1])))






