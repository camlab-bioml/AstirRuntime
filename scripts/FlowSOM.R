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

# Run flowsom
flow <- cytof_cluster(xdata = imc.data, method = "FlowSOM",
                      FlowSOM_k = as.integer(snakemake@wildcards[['k']]))

# End timer
total_time <- proc.time() - start

# Create output
out <- data.frame(time = as.numeric(total_time[3]),
                  method = paste0("FlowSOM-", snakemake@wildcards[['markers']],
                                  "-k", snakemake@wildcards[['k']]),
                  cells = snakemake@wildcards[['cells']])

# save
write_csv(out, file = snakemake@output[['runtime']])
