library(tidyverse)
library(devtools)
devtools::load_all("../taproom/")



all <- read_csv(snakemake@input[['runtimes']])
all <- read_csv("../astir-manuscript-runtime/output/cardinal/runtime/all_runtimes.csv")

pdf(snakemake@output[['fig']], width = 7, height = 5)
pdf("../astir-manuscript-runtime/output/cardinal/figures/runtime.pdf", width = 7, height = 4)
all %>% 
  mutate(algorithm = str_split_fixed(.$method, "-", 2)[,1]) %>% 
  group_by(algorithm, cells) %>% 
  summarise(mean_runtime = mean(time)) %>% 
  ggplot(aes(x = cells, y = mean_runtime, color = algorithm)) +
  geom_point(size = 3) +
  geom_line(size = 2) +
  scale_y_log10() + 
  scale_x_continuous(breaks = unique(all$cells)) +
  scale_color_brewer(palette = "Set1") +
  astir_paper_theme() +
  labs(x = "Number of cells", y = "Run time (s)", color = "Method") +
  theme(legend.position = "top",
        axis.text.x = element_text(angle = 45,  hjust = 1, vjust = 1))
dev.off()


# all[,1:3] %>% 
#   drop_na() %>% 
#   mutate(algorithm = str_split_fixed(.$method, "-", 2)[,1]) %>% 
#   filter(algorithm == "Phenograph") %>% 
#   mutate(k = str_split_fixed(.$method, "-", 3)[,3]) %>% 
#   ggplot(aes(x = cells, y = log10(time), color = k, group = method)) +
#   geom_point() +
#   geom_line() +
#   scale_x_continuous(breaks = unique(all$cells)) +
#   scale_color_brewer(palette = "Set1") +
#   astir_paper_theme() +
#   labs(x = "Number of Cells", y = "log10(Time (seconds))", color = "Method")
# 
# 
# 
# 
# all %>% 
#   mutate(algorithm = str_split_fixed(.$method, "-", 2)[,1]) %>% 
#   ggplot(aes(x = cells, y = time, color = algorithm, group = method)) +
#   geom_point() +
#   geom_line() +
#   scale_x_continuous(breaks = unique(all$cells)) +
#   scale_color_brewer(palette = "Set1") +
#   astir_paper_theme() +
#   labs(x = "Number of Cells", y = "Time (seconds)", color = "Method")
