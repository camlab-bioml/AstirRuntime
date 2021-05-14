library(tidyverse)
library(devtools)
devtools::load_all("../taproom/")



all <- read_csv(input@snakemake[['runtimes']])

pdf(snakemake@output[['fig']], width = 10, height = 5)
all %>% 
  mutate(algorithm = str_split_fixed(.$method, "-", 2)[,1]) %>% 
  ggplot(aes(x = cells, y = log10(time), color = algorithm, group = method)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = unique(all$cells)) +
  scale_color_brewer(palette = "Set1") +
  astir_paper_theme() +
  labs(x = "Number of Cells", y = "log10(Time (seconds))", color = "Method")
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
