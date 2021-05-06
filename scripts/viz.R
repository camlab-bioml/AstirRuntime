library(tidyverse)
library(devtools)
devtools::load_all("../taproom/")

astir <- lapply(snakemake@input[['astir']], read_csv) %>% 
  bind_rows()
phenograph <- lapply(snakemake@input[['phenograph']], read_csv) %>% 
  bind_rows()
# phenograph <- lapply(dir("../astir-manuscript-runtime/output/cardinal/runtime/",
#                          pattern = "phenograph", full.names = TRUE), read_csv) %>% 
#   bind_rows()
FlowSOM <- lapply(snakemake@input[['FlowSOM']], read_csv) %>% 
  bind_rows()
# FlowSOM <- lapply(dir("../astir-manuscript-runtime/output/cardinal/runtime/",
#                       pattern = "FlowSOM", full.names = TRUE), read_csv) %>% 
#   bind_rows()
ClusterX <- lapply(snakemake@input[['ClusterX']], read_csv) %>% 
  bind_rows()


all <- bind_rows(astir, phenograph, FlowSOM, ClusterX)
#all <- bind_rows(phenograph, FlowSOM)


pdf(snakemake@output[['fig']], width = 10, height = 5)

all %>% 
  mutate(algorithm = str_split_fixed(.$method, "-", 2)[,1]) %>% 
  ggplot(aes(x = cells, y = time, color = algorithm, group = method)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = unique(all$cells)) +
  scale_color_brewer(palette = "Set1") +
  astir_paper_theme() +
  labs(x = "Number of Cells", y = "Time (seconds)", color = "Method")
dev.off()