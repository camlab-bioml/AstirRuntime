library(tidyverse)


astir <- map_dfr(snakemake@input[['astir']], read_csv)
phenograph <- map_dfr(snakemake@input[['phenograph']], read_csv)
clusterx <- map_dfr(snakemake@input[['clusterx']], read_csv)
FlowSOM <- map_dfr(snakemake@input[['FlowSOM']], read_csv)
acdc <- map_dfr(snakemake@input[['acdc']], read_csv)


all <- bind_rows(astir, phenograph, clusterx, FlowSOM, acdc)

write_csv(all, snakemake@output[['csv']])