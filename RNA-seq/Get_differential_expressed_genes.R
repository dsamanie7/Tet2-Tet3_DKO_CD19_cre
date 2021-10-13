### Use DESeq2, in R, to get DEGs

library(DESeq2)

counts <- read.table("/mnt/BioScratch/danielasc/RNA-seq_Vipul/featurecounts/Genes_featurecounts.txt",header=TRUE) 
x<- colnames(counts)
x <- gsub("X.mnt.BioScratch.danielasc.RNA.seq_Vipul.star_alignment.", "", x)
x <- gsub(".Aligned.out.sam", "", x)
colnames(counts) <- x
rownames(counts) <- as.vector(counts[,1])
counts <- counts[,6:ncol(counts)]

#filter and take only those rows where we see at least one count as a sum
counts <- (counts[(rowSums(counts[,2:ncol(counts)])>0),])

test_part1 = counts[,2:ncol(counts)]/(counts[,1]/1000)
test_part2 = (colSums(test_part1))/1000000
test_part3<-((t(apply(test_part1, 1, "/", test_part2))))
tpm <- test_part3

genenamee <- (paste(rownames(tpm), "'", sep=""))
tpm2 <- data.frame(genenamee, tpm)

write.table(tpm2, "20180315_gene_names_tpm.csv", col.names=TRUE, row.names=TRUE, sep=",", quote=FALSE)

counts2 <- counts[,2:ncol(counts)]

countsname <- data.frame(genenamee,counts2)
write.table(countsname, "20180315_gene_names_raw.csv", col.names=TRUE, row.names=TRUE, sep=",", quote=FALSE)

counts2 <- counts2[,2:5]
epn.countTable = counts2
colnames(epn.countTable) = colnames(counts2)

conditions <- c("DKO","DKO","Dfl","Dfl")
conditions2 <- unique(conditions)
epn.Design = data.frame(
    row.names = colnames( epn.countTable ),
	condition = conditions
)


dds <- DESeqDataSetFromMatrix(countData = counts2,
                              colData = epn.Design,
                              design = ~ condition)


dds <- dds[ rowSums(counts(dds)) > 0, ]
dds <- DESeq(dds)

rld <- rlog(dds)
pdf("20180315_PCA.pdf")
plotPCA(rld)
dev.off()

v1 <- c("DKO")
v2 <- c("Dfl")

normcounts <- (counts(dds, normalized=TRUE))
normcountse <- (counts(dds, normalized=TRUE))

write.table(normcounts, "20180315_gene_names_normalized.csv", col.names=TRUE, row.names=TRUE, sep=",", quote=FALSE)


res <- NULL
for (i in 1:1){
res[i] <- list(results(dds,alpha=0.05,  contrast=c("condition",paste(v1[i]),paste(v2[i]))))
}

rescut <- NULL

for (i in 1:1){
res[[i]][(is.na(res[[i]][,6])),6]=2
rescut[i] <- list((res[[i]][abs(res[[i]][,2])>1 & res[[i]][,6] < 0.05,]))
}

tempall <- NULL
tempders <- NULL
for (i in 1:1){
tempall <- NULL
tempders <- NULL
tempders <- rescut[[i]]
tempall <- data.frame(normcountse,res[[i]])
write.table(tempall,paste("20180315_All_regions_DESEQ_",v1[i],"_vs_",v2[i],".csv", sep="" ), row.names=TRUE, col.names=TRUE, quote=FALSE, sep=",")
tempders <- tempall[rownames(tempall) %in% rownames(rescut[[i]]),]
write.table(tempders,paste("20180315_DEGs_",v1[i],"_vs_",v2[i],".csv", sep="" ), row.names=TRUE, col.names=TRUE, quote=FALSE, sep=",")

}

