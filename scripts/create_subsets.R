library(zellkonverter)
library(SingleCellExperiment)
library(scRNAseq)


sce <- readRDS(snakemake@input[['basel']])

no_of_cells <- snakemake@wildcards[['cells']]

# Subset sce to number of cells selected
subset <- sce[,1:no_of_cells]

# Add batch information - required by astir
subset$batch <- sub("_[^_]+$", "", colnames(subset))

# Remove raw_imc and unwinsorized counts so that these are not copied to h5ad
assays(subset)$raw_imc <- NULL
assays(subset)$logcounts_unwinsorized <- NULL

writeH5AD(subset, snakemake@output[['h5ad']])
saveRDS(subset, snakemake@output[['sce']])