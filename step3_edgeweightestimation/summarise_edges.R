#### set up ####
library(tidyverse)

theme_set(theme_bw())

#### count nodes ANP short ####
nodes <- read_csv('../data_processed/step4_nodalregression/anp_allnodes.csv')

counts <- data.frame(window = sort(unique(nodes$window)),
                     count = NA)
for(i in 1:nrow(counts)){
  x <- nodes %>%
    filter(window == counts$window[i])
  counts$count[i] <- length(unique(x$id))
}

rm(list = ls()) ; gc()

#### count nodes MPNP short ####
counts <- data.frame(window = 1:5,
                     count = NA)

for(time_window in 1:5){
  ages <- readRDS(paste0('../data_processed/step2_ageestimation/mpnp',
                         time_window,'_ageestimates_mcmcoutput.rds'))
  counts$count[time_window] <- ncol(ages)
}

rm(list = ls()) ; gc()

#### count nodes ANP long ####
counts <- data.frame(window = 1:7,
                     count = NA)

for(time_window in 1:7){
  eigen <- readRDS(paste0('../data_processed/step4_nodalregression/anplong',
                         time_window,'eigenvectorestimates.rds'))
  counts$count[time_window] <- length(unique(eigen$node))
}

#### summarise edge weights ####
## load in MOTNP data
load('motnp_edgeweights_conditionalprior.RData')
motnp_edges <- edge_samples
motnp_summary <- summary
rm(list = ls()[!ls() %in% c('motnp_edges','motnp_summary')]) ; gc()

## load in MPNP long data
load('mpnp_edgecalculations/mpnplong_edgeweights_conditionalprior.RData')
mpnplong_edges <- edge_samples
mpnplong_summary <- summary
rm(list = ls()[!ls() %in% c('motnp_edges','motnp_summary',
                            'mpnplong_edges','mpnplong_summary')]) ; gc()

# ## load in MPNP short data
# mpnpshort_edges <- list()
# mpnpshort_summary <- list()
# for(time_window in 1:5){
#   load(paste0('mpnp_edgecalculations/mpnpshort',time_window,'_edgeweights_conditionalprior.RData'))
#   if('edge_weights_matrix' %in% ls()){
#     edge_samples <- edge_weights_matrix
#   }
#   mpnpshort_edges[[time_window]] <- edge_samples
#   mpnpshort_summary[[time_window]] <- summary
#   rm(list = ls()[!ls() %in% c('motnp_edges','motnp_summary',
#                               'mpnplong_edges','mpnplong_summary',
#                               'mpnpshort_edges','mpnpshort_summary','time_window')]) ; gc()
# }

## load in ANP short data
anpshort_edges <- list()
anpshort_summary <- list()
for(time_window in 1:36){
  load(paste0('anp_edgecalculations/anpshort',time_window,'_edgeweights_conditionalprior.RData'))
  if('edge_weights_matrix' %in% ls()){
    edge_samples <- edge_weights_matrix
  }
  anpshort_edges[[time_window]] <- edge_samples
  anpshort_summary[[time_window]] <- summary
  rm(list = ls()[!ls() %in% c('motnp_edges','motnp_summary',
                              'mpnplong_edges','mpnplong_summary',
                              'mpnpshort_edges','mpnpshort_summary',
                              'anpshort_edges','anpshort_summary','time_window')]) ; gc()
}

## load in ANP long data
anplong_edges <- list()
anplong_summary <- list()
for(time_window in 1:7){
  load(paste0('anp_edgecalculations/anplong',time_window,'_edgeweights_conditionalprior.RData'))
  if('edge_weights_matrix' %in% ls()){
    edge_samples <- edge_weights_matrix
  }
  anplong_edges[[time_window]] <- edge_samples
  anplong_summary[[time_window]] <- summary
  rm(list = ls()[!ls() %in% c('motnp_edges','motnp_summary',
                              'mpnplong_edges','mpnplong_summary',
                              'mpnpshort_edges','mpnpshort_summary',
                              'anpshort_edges','anpshort_summary',
                              'anplong_edges','anplong_summary','time_window')]) ; gc()
}
rm(time_window) ; gc()

## combine data together
summary <- motnp_summary %>%
  select(dyad_id, node_1, node_2, median, `2.5%`, `97.5%`) %>%
  mutate(period = 1,
         population = 'Mosi-Oa-Tunya',
         duration = 'Short') %>%
  relocate(duration) %>%
  relocate(population)

# x <- mpnplong_summary %>%
#   select(dyad_id, node_1, node_2, median, `2.5%`, `97.5%`) %>%
#   mutate(period = 1,
#          population = 'Makgadikgadi Pans',
#          duration = 'Long') %>%
#   relocate(duration) %>%
#   relocate(population)
# 
# summary <- rbind(summary, x)
# 
# for(time_window in 1:length(mpnpshort_summary)){
#   x <- mpnpshort_summary[[time_window]] %>%
#     select(dyad_id, node_1, node_2, median, `2.5%`, `97.5%`, period) %>%
#     mutate(population = 'Makgadikgadi Pans',
#            duration = 'Short') %>%
#     relocate(duration) %>%
#     relocate(population)
#   summary <- rbind(summary, x)
# }

for(time_window in 1:length(anplong_summary)){
  x <- anplong_summary[[time_window]] %>%
    select(dyad_id, node_1, node_2, median, `2.5%`, `97.5%`, period) %>%
    mutate(population = 'Amboseli',
           duration = 'Long') %>%
    relocate(duration) %>%
    relocate(population)
  summary <- rbind(summary, x)
}

for(time_window in 1:length(anpshort_summary)){
  x <- anpshort_summary[[time_window]] %>%
    select(dyad_id, node_1, node_2, median, `2.5%`, `97.5%`, period) %>%
    mutate(population = 'Amboseli',
           duration = 'Short') %>%
    relocate(duration) %>%
    relocate(population)
  summary <- rbind(summary, x)
}
rm(x) ; gc()

save.image('step3_edgeweightestimation/allpopulations_summarydata.RData')
saveRDS(summary, '../data_processed/step3_edgeweightestimation/allpopulations_summarydata.RDS')

#### values to report ####
## prep data
summary <- readRDS('../data_processed/step3_edgeweightestimation/allpopulations_summarydata.RDS')
summary$population <- factor(summary$population,
                             levels = c('Amboseli','Makgadikgadi Pans','Mosi-Oa-Tunya'))
summary$duration <- factor(summary$duration, levels = c('Short','Long'))

## split into populations
anp <- summary %>%
  filter(population == 'Amboseli')
motnp <- summary %>%
  filter(population == 'Mosi-Oa-Tunya')
mpnp <- summary %>%
  filter(population == 'Makgadikgadi Pans')

## median bond strength: ANP
anp_short <- anp %>%
  filter(duration == 'Short')
min(tapply(anp_short$median, anp_short$period, median))
max(tapply(anp_short$median, anp_short$period, median))
mean(anp_short$median)
sd(anp_short$median)

anp_long <- anp %>%
  filter(duration == 'Long')
min(tapply(anp_long$median, anp_long$period, median))
max(tapply(anp_long$median, anp_long$period, median))
mean(anp_long$median)
sd(anp_long$median)

anp_short_averages <- data.frame(
  population = 'ANP, short window ',
  window = min(anp_short$period):max(anp_short$period),
  elephants = NA,
  median = NA,
  mean = NA,
  sd = NA)
for(i in 1:nrow(anp_short_averages)){
  window <- anp_short %>%
    filter(period == i)
  anp_short_averages$elephants[i] <- length(unique(c(window$node_1,window$node_2)))
  anp_short_averages$median[i] <- median(window$median)
  anp_short_averages$mean[i] <- round(mean(window$median),3)
  anp_short_averages$sd[i] <- round(sd(window$median),3)
}

ggplot()+
  geom_boxplot(data = anp_short,
               aes(y = fct_rev(as.factor(period)),
                   x = median),
               fill = '#1F968BFF')+
  labs(y = 'time window',
       x = 'median edge weight')+
  annotate('text',
           x = rep(0.56, nrow(anp_short_averages)),
           y = nrow(anp_short_averages):1,
           label = paste0(anp_short_averages$mean,
                          ' ± ',
                          anp_short_averages$sd)
           # label = anp_short_averages$median
  )+
  scale_x_continuous(limits = c(0,0.62))
ggsave(filename = 'anp_short_mediandistributions.svg',
       path = '../outputs/step3_edgeweightestimation/',
       device = 'svg', width = 1400, height = 2400, units = 'px')

anp_long_averages <- data.frame(
  population = 'ANP, long window ',
  window = min(anp_long$period):max(anp_long$period),
  elephants = NA,
  median = NA,
  mean = NA,
  sd = NA)
for(i in 1:nrow(anp_long_averages)){
  window <- anp_long %>%
    filter(period == i)
  anp_long_averages$elephants[i] <- length(unique(c(window$node_1,window$node_2)))
  anp_long_averages$median[i] <- median(window$median)
  anp_long_averages$mean[i] <- round(mean(window$median),3)
  anp_long_averages$sd[i] <- round(sd(window$median),3)
}

ggplot()+
  geom_boxplot(data = anp_long,
               aes(y = fct_rev(as.factor(period)),
                   x = median),
               fill = '#1F968BFF')+
  labs(y = 'time window',
       x = 'median edge weight')+
  annotate('text',
           x = rep(0.56, nrow(anp_long_averages)),
           y = nrow(anp_long_averages):1,
           label = paste0(anp_long_averages$mean,
                          ' ± ',
                          anp_long_averages$sd)
           # label = anp_long_averages$median
  )+
  scale_x_continuous(limits = c(0,0.62))
ggsave(filename = 'anp_long_mediandistributions.svg',
       path = '../outputs/step3_edgeweightestimation/',
       device = 'svg', width = 1400, height = 600, units = 'px')

## median bond strength: MOTNP
min(motnp$median)
max(motnp$median)
median(motnp$median)
mean(motnp$median)
sd(motnp$median)

motnp_averages <- data.frame(
  population = 'MOTNP',
  window = min(motnp$period):max(motnp$period),
  elephants = length(unique(c(motnp$node_1,motnp$node_2))),
  median = median(motnp$median),
  mean = round(mean(motnp$median),3),
  sd = round(sd(motnp$median),3))

averages <- rbind(anp_short_averages,
                  anp_long_averages,
                  motnp_averages) %>%
  mutate(window = paste0(population,window))

summary <- summary %>%
  mutate(population_duration = ifelse(population == 'Amboseli',
                                      ifelse(duration == 'Short',
                                             'ANP, short ',
                                             'ANP, long '),
                                      ifelse(population == 'Makgadikgadi Pans',
                                             ifelse(duration == 'Short',
                                                    'MPNP, short ',
                                                    'MPNP, long '),
                                             'MOTNP'))) %>%
  mutate(window = ifelse(population_duration == 'MOTNP',
                         'MOTNP',
                         paste0(population_duration, period))) %>%
  mutate(window = factor(window,
                         levels = unique(summary$window)))

ggplot()+
  geom_boxplot(data = summary[summary$population != 'Makgadikgadi Pans',],
               aes(y = fct_rev(window),
                   x = median,
                   fill = population_duration))+
  scale_fill_viridis_d()+
  labs(y = 'time window',
       x = 'median edge weight')+
  annotate('text',
           x = rep(0.56, nrow(averages)),
           y = nrow(averages):1,
           label = paste0(averages$mean,' ± ',averages$sd)
  )+
  scale_x_continuous(limits = c(0,0.62))+
  theme(legend.position = 'none')
ggsave(filename = 'anp_motnp_mediandistributions.svg',
       path = '../outputs/step3_edgeweightestimation/',
       device = 'svg', width = 1800, height = 3600, units = 'px')
ggsave(filename = 'anp_motnp_mediandistributions.png',
       path = '../outputs/step3_edgeweightestimation/',
       device = 'png', width = 1800, height = 3600, units = 'px')

## median bond strength: MPNP
min(tapply(mpnp$median, mpnp$period, median))
max(tapply(mpnp$median, mpnp$period, median))
mean(mpnp$median)
sd(mpnp$median)

#### plot edge weight density plots ####
## make colours prettier
summary$period_new <- ifelse(summary$population == 'Mosi-Oa-Tunya',
                         14,
                         ifelse(summary$population == 'Makgadikgadi Pans',
                                ifelse(summary$duration == 'Long',
                                       14,
                                       ifelse(summary$period == 1, 1,
                                              ifelse(summary$period == 2, 10,
                                                     ifelse(summary$period == 3, 19,
                                                            ifelse(summary$period == 4, 27, 36))))),
                                ifelse(summary$duration == 'Long',
                                       ifelse(summary$period == 1, 1,
                                              ifelse(summary$period == 2, 7,
                                                     ifelse(summary$period == 3, 13,
                                                            ifelse(summary$period == 4, 19,
                                                                   ifelse(summary$period == 5, 24,
                                                                          ifelse(summary$period == 6, 30, 36)))))),
                                       summary$period)))

## plot
(p <- ggplot(summary)+
  geom_density(aes(x = median, colour = as.factor(period_new))) +
  facet_grid(duration ~ population) +
    scale_colour_viridis_d()+
  labs(colour = 'Time window',
       x = 'Median of dyad edge distribution',
       y = 'Density')
  )
(p <- p +
    theme_bw()+
    theme(legend.position = 'none',#legend.position = 'inside', #legend.position = c(1, 0),
          #legend.position.inside = c(0.9, 0.1),
          #legend.justification = c(1, 0),
          legend.text = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.title = element_text(size = 12),
          strip.text = element_text(size = 12),
          strip.background = element_rect(fill = 'white'))
)

ggsave('../outputs/step3_edgeweightestimation/compare_populations_all.png',
       plot = p, device = 'png', height = 1600, width = 2400, units = 'px')
ggsave('../outputs/step3_edgeweightestimation/compare_populations_all.svg',
       plot = p, device = 'svg', height = 1600, width = 2400, units = 'px')


## remove MPNP as potentially no longer including
summary <- summary %>%
  filter(population != 'Makgadikgadi Pans') %>%
  mutate(population = factor(population, levels = c('Amboseli','Mosi-Oa-Tunya')))

## combine population and duration
summary <- summary %>%
  mutate(pop_durn = ifelse(population == 'Mosi-Oa-Tunya',
                           'Mosi-Oa-Tunya (504 days)',
                           ifelse(duration == 'Long',
                                  'Amboseli (2571 days)',
                                  'Amboseli (500 days)'))) %>%
  mutate(pop_durn = factor(pop_durn,
                           levels = c('Mosi-Oa-Tunya (504 days)',
                                      'Amboseli (2571 days)',
                                      'Amboseli (500 days)')))

## plot without MPNP
(p <- ggplot(summary)+
    geom_density(aes(x = median, colour = as.factor(period_new))) +
    facet_wrap(. ~ pop_durn) +
    scale_colour_viridis_d()+
    labs(colour = 'Time window',
         x = 'Median of dyad edge distribution',
         y = 'Density')
)
(p <- p +
    theme_bw()+
    theme(legend.position = 'none',#legend.position = 'inside', #legend.position = c(1, 0),
          #legend.position.inside = c(0.9, 0.1),
          #legend.justification = c(1, 0),
          legend.text = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.title = element_text(size = 12),
          strip.text = element_text(size = 12),
          strip.background = element_rect(fill = 'white'))
)

ggsave('../outputs/step3_edgeweightestimation/compare_populations_nompnp.png',
       plot = p, device = 'png', height = 800, width = 2400, units = 'px')
ggsave('../outputs/step3_edgeweightestimation/compare_populations_nompnp.svg',
       plot = p, device = 'svg', height = 800, width = 2400, units = 'px')


#### plot edge weight density ridges ####
library(ggridges)
rm(list = ls()) ; gc()
summary <- readRDS('../data_processed/step3_edgeweightestimation/allpopulations_summarydata.RDS') %>% 
  filter(population != 'Makgadikgadi Pans') %>% 
  mutate(model = ifelse(population == 'Mosi-Oa-Tunya', 'MOTNP','ANP'),
         time = ifelse(duration == 'Short',' S',' L')) %>% 
  mutate(duration = ifelse(duration == 'Short','short','long'),
         model = paste0(model, time, period)) %>% 
  dplyr::select(-time) %>% 
  mutate(model = ifelse(model == 'MOTNP S1', 'MOTNP', model)) %>% 
  mutate(model = factor(model,
                        levels = c(#'',
                                   'MOTNP',
                                   'ANP S1','ANP S2','ANP S3','ANP S4','ANP S5',
                                   'ANP S6','ANP S7','ANP S8','ANP S9','ANP S10',
                                   'ANP S11','ANP S12','ANP S13','ANP S14','ANP S15',
                                   'ANP S16','ANP S17','ANP S18','ANP S19','ANP S20',
                                   'ANP S21','ANP S22','ANP S23','ANP S24','ANP S25',
                                   'ANP S26','ANP S27','ANP S28','ANP S29','ANP S30',
                                   'ANP S31','ANP S32','ANP S33','ANP S34','ANP S35',
                                   'ANP S36',
                                   'ANP L1','ANP L2','ANP L3','ANP L4','ANP L5',
                                   'ANP L6','ANP L7')))

count <- summary %>% 
  group_by(model) %>% 
  summarise(n_dyads = length(median),
            n_nodes = length(unique(node_1)) + 1,
            mu = mean(median),
            sd = sd(median),
            lwr = quantile(median, prob = 0.025),
            upr = quantile(median, prob = 0.925)) %>% 
  mutate(n_nodes = as.character(n_nodes)) %>% 
  separate(model, into = c('population','duration'), sep = ' ', remove = F) %>% 
  separate(duration, into = c('duration','window_number'), sep = 1, remove = F) %>% 
  mutate(population = ifelse(population == 'ANP',
                             ifelse(duration == 'S',
                                    'Amboseli (short)',
                                    'Amboseli (long)'),
                             'Mosi-Oa-Tunya')) %>% 
  dplyr::select(-duration, -window_number) %>% 
  mutate(label = paste0(n_nodes,': ',
                        round(mu,3),' ± ',
                        round(sd,3)))

count$label <- ifelse(count$label == '52: 0.044 ± 0.047',
                      ' 52: 0.044 ± 0.047', count$label)
count$label <- ifelse(count$label == '31: 0.041 ± 0.044',
                      ' 31: 0.041 ± 0.044', count$label)
count$label <- ifelse(count$label == '92: 0.03 ± 0.028',
                      ' 92: 0.030 ± 0.028', count$label)
count$label <- ifelse(count$label == '99: 0.04 ± 0.036',
                      ' 99: 0.040 ± 0.036', count$label)

count$label <- ifelse(count$label == '181: 0.023 ± 0.02',
                      '181: 0.023 ± 0.020', count$label)
count$label <- ifelse(count$label == '144: 0.028 ± 0.02',
                      '144: 0.028 ± 0.020', count$label)
count$label <- ifelse(count$label == '177: 0.024 ± 0.02',
                      '177: 0.024 ± 0.020', count$label)
count$label <- ifelse(count$label == '194: 0.026 ± 0.02',
                      '194: 0.026 ± 0.020', count$label)

summary %>% 
  ggplot()+
  geom_density_ridges(data = summary,
                      aes(x = median,
                          y = model,
                          fill = population),
                      rel_min_height = 0.001,
                      scale = 3,
                      alpha = 0.6)+
  geom_label(data = count,
            aes(y = model,
                x = 0.38,
                label = label,
                fill = population,
                colour = population),
            label.size = 0,
            family = 'mono')+
  scale_x_continuous(name = 'median edge weight per dyad',
                     limits = c(0,0.45))+
  scale_y_discrete(name = 'population and time window',
                   limits = rev,
                   drop = F)+
  scale_fill_viridis_d(name = 'time window')+
  scale_colour_manual(name = 'time window', values = c('white','white','black'))+
  theme(legend.position = 'bottom')+
  guides(colour = guide_legend(override.aes = list(size = 0) ) )
ggsave(plot = last_plot(), device = 'png',
       filename = 'median_distributions_motnp_anp_fulldist.png',
       path = '../outputs/step3_edgeweightestimation/',
       height = 2700, width = 1800, unit = 'px')

summary <- summary %>%
  dplyr::select(-population) %>%
  left_join(count[,c('model','population','lwr','upr')],
            by = 'model') %>% 
  filter(median > lwr) %>% 
  filter(median < upr)
summary %>% 
  ggplot()+
  geom_density_ridges(data = summary,
                      aes(x = median,
                          y = model,
                          fill = population),
                      #rel_min_height = 0.001,
                      scale = 3,
                      alpha = 0.6)+
  geom_label(data = count,
             aes(y = model,
                 x = 0.19,
                 label = label,
                 fill = population,
                 colour = population),
             label.size = 0,
             family = 'mono')+
  scale_x_continuous(name = 'median edge weight per dyad',
                     limits = c(0,0.23))+
  scale_y_discrete(name = 'population and time window',
                   limits = rev,
                   drop = F)+
  scale_fill_viridis_d(name = 'time window')+
  scale_colour_manual(name = 'time window', values = c('white','white','black'))+
  theme(legend.position = 'bottom')+
  guides(colour = guide_legend(override.aes = list(size = 0) ) )
ggsave(plot = last_plot(), device = 'png',
       filename = 'median_distributions_motnp_anp_95percent.png',
       path = '../outputs/step3_edgeweightestimation/',
       height = 2700, width = 1800, unit = 'px')




