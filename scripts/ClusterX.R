library(SingleCellExperiment)
library(tidyverse)
library(devtools)
library(cytofkit)
devtools::load_all("../taproom/")


sce <- readRDS(snakemake@input[['sce']])

if(snakemake@wildcards[['markers']] == "all_markers"){
  imc.data <- t(logcounts(sce))
}else{
  markers <- read_markers(snakemake@input[['markers']])
  imc.data <- t(logcounts(sce[unique(unlist(markers$cell_types)),]))
}

# Start timer
start = proc.time()

# Run clusterx
tsne <- cytof_dimReduction(data=imc.data, method = "tsne")
clusterx <- cytof_cluster(ydata = tsne, method = "ClusterX")

# End timer
total_time <- proc.time() - start

# Create output
out <- data.frame(time = as.numeric(total_time[3]),
                  method = paste0("ClusterX-", snakemake@wildcards[['markers']]),
                  cells = snakemake@wildcards[['cells']])

# save
write_csv(out, file = snakemake@output[['runtime']])
