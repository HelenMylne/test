### Bayesian analysis of EfA data ####
# Script to process association data from Makgadikgadi Pans National Park, Botswana.
# Data collected: 1st November 2019 to 5th August 2021
# Collected by: Elephants for Africa (Dr Kate Evans)
# Data supplied by: EfA and Dr Kate Evans, 19th October 2021

### Set up ####
# load packages
library(tidyverse, lib.loc = 'packages/')   # library(tidyverse)
library(dplyr, lib.loc = 'packages/')       # library(dplyr)
#library(rstan, lib.loc = 'packages/')      # library(rstan)
library(cmdstanr, lib.loc = 'packages/')    # library(cmdstanr)
library(rethinking, lib.loc = 'packages/')  # library(rethinking)
library(igraph, lib.loc = 'packages/')      # library(igraph)
library(dagitty, lib.loc = 'packages/')     # library(dagitty)
library(janitor, lib.loc = 'packages/')     # library(janitor)
library(lubridate, lib.loc = 'packages/')   # library(lubridate)
library(hms, lib.loc = 'packages/')         # library(hms)
library(readxl, lib.loc = 'packages/')      # library(readxl)

# information
sessionInfo()
R.Version()
rstan::stan_version()
#packageVersion('')
#citation('')

# set stan path
set_cmdstan_path('/home/userfs/h/hkm513/.cmdstan/cmdstan-2.29.2')

# load model
mod_2.2 <- cmdstan_model("models/simpleBetaNet.stan")
mod_2.2

# set seed
set.seed(12345)

################ Run model on real standardised data -- period 3 ################
counts_df3 <- read_csv('../../../../Google Drive/Shared drives/Helen PhD/chapter1_age/data_processed/mpnp_period3_pairwiseevents.csv') %>% 
  select(dyad, dyad_id, id_1, id_2, period, count_dyad, together, apart) %>% 
  distinct()
counts_ls3 <- list(
  n_dyads  = nrow(counts_df3),          # total number of times one or other of the dyad was observed
  together = counts_df3$together   ,    # count number of sightings seen together
  apart    = counts_df3$apart,          # count number of sightings seen apart
  period   = counts_df3$period)         # which period it's within

### Fit model
weight_mpnp3_2.2 <- mod_2.2$sample(
  data = counts_ls3, 
  seed = 12345, 
  chains = 4, 
  parallel_chains = 4)

# print progress stamp
print(paste0('MCMC chain for period 3 completed at ', Sys.time()))

### check model
weight_mpnp3_2.2
rm(counts_ls3)

output1 <- read_cmdstan_csv(weight_mpnp3_2.2$output_files()[1])
draws1_mpnp3 <- as.data.frame(output1$post_warmup_draws)
rm(output1)

output2 <- read_cmdstan_csv(weight_mpnp3_2.2$output_files()[2])
draws2_mpnp3 <- as.data.frame(output2$post_warmup_draws)
rm(output2)

output3 <- read_cmdstan_csv(weight_mpnp3_2.2$output_files()[3])
draws3_mpnp3 <- as.data.frame(output3$post_warmup_draws)
rm(output3)

output4 <- read_cmdstan_csv(weight_mpnp3_2.2$output_files()[4])
draws4_mpnp3 <- as.data.frame(output4$post_warmup_draws)
rm(output4)

draws_mpnp3 <- rbind(draws1_mpnp3, draws2_mpnp3, draws3_mpnp3, draws4_mpnp3)

colnames(draws_mpnp3)[2:ncol(draws_mpnp3)] <- counts_df3$dyad

### save data 
saveRDS(draws_mpnp3, '../../../../Google Drive/Shared drives/Helen PhD/chapter1_age/data_processed/mpnp3_edgeweightestimates_mcmcoutput.rds')
rm(list = ls())

# print progress stamp
print(paste0('Data writing for period 3 written at ', Sys.time()))

################ Plot model outputs -- period 3 ################
### elephant data
counts_df3 <- read_csv('../../../../Google Drive/Shared drives/Helen PhD/chapter1_age/data_processed/mpnp_period3_pairwiseevents.csv')

### model data
draws_mpnp3 <- readRDS('../../../../Google Drive/Shared drives/Helen PhD/chapter1_age/data_processed/mpnp3_edgeweightestimates_mcmcoutput.rds')

# Assign random set of columns to check
plot_cols <- sample(x = 2:ncol(draws_mpnp3), size = 30, replace = F)

# create file of output graphs
pdf('../../../../Google Drive/Shared drives/Helen PhD/chapter1_age/data_processed/mpnp3_networkplots.pdf', width = 10, height = 10)

### build traceplots -- period 3 -- very wide ####
plot(draws_mpnp3[,plot_cols[1]], type = 'l',
     ylim = c(0,1), las = 1, ylab = 'edge weight')
lines(draws_mpnp3[,plot_cols[2]], col = 'tan')
lines(draws_mpnp3[,plot_cols[3]], col = 'orange')
lines(draws_mpnp3[,plot_cols[4]], col = 'green')
lines(draws_mpnp3[,plot_cols[5]], col = 'chocolate')
lines(draws_mpnp3[,plot_cols[6]], col = 'blue')
lines(draws_mpnp3[,plot_cols[7]], col = 'red')
lines(draws_mpnp3[,plot_cols[8]], col = 'seagreen')
lines(draws_mpnp3[,plot_cols[9]], col = 'purple')
lines(draws_mpnp3[,plot_cols[10]],col = 'magenta')
lines(draws_mpnp3[,plot_cols[11]],col = 'black')
lines(draws_mpnp3[,plot_cols[12]], col = 'tan')
lines(draws_mpnp3[,plot_cols[13]], col = 'orange')
lines(draws_mpnp3[,plot_cols[14]], col = 'green')
lines(draws_mpnp3[,plot_cols[15]], col = 'chocolate')
lines(draws_mpnp3[,plot_cols[16]], col = 'blue')
lines(draws_mpnp3[,plot_cols[17]], col = 'red')
lines(draws_mpnp3[,plot_cols[18]], col = 'seagreen')
lines(draws_mpnp3[,plot_cols[19]], col = 'purple')
lines(draws_mpnp3[,plot_cols[20]],col = 'magenta')
lines(draws_mpnp3[,plot_cols[21]],col = 'black')
lines(draws_mpnp3[,plot_cols[22]], col = 'tan')
lines(draws_mpnp3[,plot_cols[23]], col = 'orange')
lines(draws_mpnp3[,plot_cols[24]], col = 'green')
lines(draws_mpnp3[,plot_cols[25]], col = 'chocolate')
lines(draws_mpnp3[,plot_cols[26]], col = 'blue')
lines(draws_mpnp3[,plot_cols[27]], col = 'red')
lines(draws_mpnp3[,plot_cols[28]], col = 'seagreen')
lines(draws_mpnp3[,plot_cols[29]], col = 'purple')
lines(draws_mpnp3[,plot_cols[30]],col = 'magenta')

### density plots -- period 3 ####
dens(draws_mpnp3[,2], ylim = c(0,10),xlim = c(0,1), las = 1)
for(i in 1:30){  # looks like a poisson distribution - peaks just above 0 and then exponential decline. almost nothing above 0.5
  dens(add = T, draws_mpnp3[,plot_cols[i]], col = col.alpha('blue', alpha = 0.3))
}

# print progress stamp
print(paste0('Chain checking for period 3 completed at ', Sys.time()))

### summarise ####
summaries <- data.frame(dyad = colnames(draws_mpnp3[,2:ncol(draws_mpnp3)]),
                        min = rep(NA, ncol(draws_mpnp3)-1),
                        max = rep(NA, ncol(draws_mpnp3)-1),
                        mean = rep(NA, ncol(draws_mpnp3)-1),
                        median = rep(NA, ncol(draws_mpnp3)-1),
                        sd = rep(NA, ncol(draws_mpnp3)-1),
                        q2.5 = rep(NA, ncol(draws_mpnp3)-1),
                        q97.5 = rep(NA, ncol(draws_mpnp3)-1))
for(i in 1:nrow(summaries)){
  summaries$min[i]    <- min(draws_mpnp3[,i+1])
  summaries$max[i]    <- max(draws_mpnp3[,i+1])
  summaries$mean[i]   <- mean(draws_mpnp3[,i+1])
  summaries$median[i] <- median(draws_mpnp3[,i+1])
  summaries$sd[i]     <- sd(draws_mpnp3[,i+1])
  summaries$q2.5[i]   <- quantile(draws_mpnp3[,i+1], 0.025)
  summaries$q97.5[i]  <- quantile(draws_mpnp3[,i+1], 0.975)
  if(i %% 1000 == 0) { print(paste0('Summary row ', i, ' completed at: ', Sys.time() )) }
}

# print progress stamp
print(paste0('Summaries for period 3 completed at ', Sys.time()))

### create network plots -- period 3 ################
head(summaries)
length(unique(summaries$id_1))+1 # number of individuals = 55

par(mai = c(0.1,0.1,0.1,0.1))

# create array of draws per dyad (distributions)
adj_tensor <- array(0, c(NROW(unique(counts_df3$id_1))+1,
                         NROW(unique(counts_df3$id_2))+1,
                         NROW(draws_mpnp3)),
                    dimnames = list(c(unique(counts_df3$id_1),
                                      unique(counts_df3$id_2)[length(unique(counts_df3$id_2))]),
                                    c(unique(counts_df3$id_1),
                                      unique(counts_df3$id_2)[length(unique(counts_df3$id_2))]),
                                    NULL))
N <- nrow(counts_df3)

for (i in 1:N) {
  dyad_row <- counts_df3[i, ]
  adj_tensor[dyad_row$id_1, dyad_row$id_2, ] <- draws_mpnp3[, i+1]
}
adj_tensor[,,1]

# convert to array of medians and 95% credible intervals
adj_quantiles <- apply(adj_tensor, c(1, 2), function(x) quantile(x, probs = c(0.025, 0.5, 0.975)))
(adj_lower <- adj_quantiles[1, , ])
(adj_mid   <- adj_quantiles[2, , ])
(adj_upper <- adj_quantiles[3, , ])
adj_range <- (adj_upper - adj_lower) ; adj_range[is.nan(adj_range)] <- 0

# Generate two igraph objects, one from the median and one from the standardised width.
g_mid <- graph_from_adjacency_matrix(adj_mid,   mode="undirected", weighted=TRUE)
g_rng <- graph_from_adjacency_matrix(adj_range, mode="undirected", weighted=TRUE)

# Generate nodes data for plotting characteristics
males3 <- data.frame(id = sort(unique(c(counts_df3$id_1, counts_df3$id_2))),
                     age_median = NA,
                     count_period = NA)
for(i in 1:nrow(males3)){
  male_id1 <- counts_df3[counts_df3$id_1 == males3$id[i],c('id_1','age_median_1','count_period_1')]
  male_id2 <- counts_df3[counts_df3$id_2 == males3$id[i],c('id_2','age_median_2','count_period_2')]
  colnames(male_id1) <- c('id','age_median','count_period')
  colnames(male_id2) <- c('id','age_median','count_period')
  male <- rbind(male_id1, male_id2) %>% distinct()
  males3$count_period[i] <- male$count_period[1]
  if(nrow(male) == 1){
    males3$age_median[i] <- ifelse(is.na(male$age_median[1]) == TRUE, 10, male$age_median[1])
  }
  else {
    males3$age_median[i] <- median(male$age_median)
  }
  rm(male_id1, male_id2, male)
}

# convert to true age distributions
ages <- readRDS('../../../../Google Drive/Shared drives/Helen PhD/chapter1_age/data_processed/mpnp3_ageestimates_mcmcoutput.rds')
ages <- as.data.frame(ages[, colnames(ages) %in% males3$id])

males3$age_mean <- NA
for(i in 1:nrow(males3)){
  males3$age_mean[i] <- mean(ages[,i])
}

# create variables for different degrees of node connectedness
males3$degree_0.1 <- NA
males3$degree_0.2 <- NA
males3$degree_0.3 <- NA
males3$degree_0.4 <- NA
males3$degree_0.5 <- NA

summaries <- separate(summaries, dyad, c('id_1','id_2'), '_', F)
for(i in 1:NROW(males3)){
  rows <- summaries[summaries$id_1 == males3$id[i] | summaries$id_2 == males3$id[i],]
  males3$degree_0.1[i] <- length(which(rows$median > 0.1))
  males3$degree_0.2[i] <- length(which(rows$median > 0.2))
  males3$degree_0.3[i] <- length(which(rows$median > 0.3))
  males3$degree_0.4[i] <- length(which(rows$median > 0.4))
  males3$degree_0.5[i] <- length(which(rows$median > 0.5))
}

which(males3$degree_0.1 < males3$degree_0.2)
which(males3$degree_0.2 < males3$degree_0.3)
which(males3$degree_0.3 < males3$degree_0.4)
which(males3$degree_0.4 < males3$degree_0.5)

# age variable
males3$age_class <- ifelse(males3$age_median == 10, 10,
                           ifelse(males3$age_median < 4, 2,
                                  ifelse(males3$age_median < 5, 3,
                                         ifelse(males3$age_median < 6, 4, 
                                                ifelse(males3$age_median < 7, 5, 
                                                       ifelse(males3$age_median < 8, 6, 7))))))

# print progress stamp
print(paste0('Networks ready to plot for period 3 completed at ', Sys.time()))

# Plot whole network
coords <- igraph::layout_nicely(g_mid)
plot(g_mid,
     edge.width = E(g_rng)$weight*3,
     edge.color = rgb(0, 0, 0, 0.25), 
     vertex.label = NA,
     vertex.size = 5,
     layout = coords)
plot(g_mid,
     edge.width = E(g_mid)$weight*3,
     edge.color = 'black',
     vertex.size = 8,
     vertex.label = males3$elephant,
     vertex.label.dist = 0,
     vertex.label.color = ifelse(males3$age_class == 10,'white','black'),
     vertex.label.family = 'Helvetica',
     vertex.label.cex = 0.5,
     vertex.color= ifelse(males3$age_class == 7,'seagreen4',
                          ifelse(males3$age_class == 6,'seagreen3',
                                 ifelse(males3$age_class == 5,'seagreen2',
                                        ifelse(males3$age_class == 4,'steelblue3',
                                               ifelse(males3$age_class == 3,'steelblue1',
                                                      ifelse(males3$age_class == 2,'yellow',
                                                             'black')))))),
     layout = coords, add = TRUE)

plot(g_mid,
     edge.width = E(g_mid)$weight*3,
     vertex.label = NA,
     vertex.size = 5,
     edge.color = ifelse(adj_mid < 0.2,'transparent','black'),
     layout = coords)
plot(g_mid,
     edge.width = E(g_rng)$weight*3,
     edge.color = ifelse(adj_mid < 0.2,'transparent',rgb(0,0,0,0.25)),
     vertex.size = 8,
     vertex.label = males3$elephant,
     vertex.label.dist = 0,
     vertex.label.color = ifelse(males3$age_class == 10,'white','black'),
     vertex.label.family = 'Helvetica',
     vertex.label.cex = 0.5,
     vertex.color = ifelse(males3$age_class == 7,'seagreen4',
                           ifelse(males3$age_class == 6,'seagreen3',
                                  ifelse(males3$age_class == 5,'seagreen2',
                                         ifelse(males3$age_class == 4,'steelblue3',
                                                ifelse(males3$age_class == 3,'steelblue1',
                                                       ifelse(males3$age_class == 2,'yellow',
                                                              'black')))))),
     layout = coords, add = TRUE)

plot(g_mid,
     edge.width = E(g_mid)$weight*3,
     vertex.label = NA,
     vertex.size = 5,
     edge.color = ifelse(adj_mid < 0.2,'transparent','black'),
     layout = coords)
plot(g_mid,
     edge.width = E(g_rng)$weight*3,
     edge.color = ifelse(adj_mid < 0.2,'transparent',rgb(0,0,0,0.25)),
     vertex.size = 8,
     vertex.label = males3$elephant,
     vertex.label.dist = 0,
     vertex.label.color = ifelse(males3$age_class == 10,'white','black'),
     vertex.label.family = 'Helvetica',
     vertex.label.cex = 0.5,
     vertex.color = males3$age_mean,
     layout = coords, add = TRUE)

# print progress stamp
print(paste0('Full population plots for period 3 completed at ', Sys.time()))

### only elephants degree > 0.3 -- period 3 ####
g_mid_0.3 <- delete.vertices(graph = g_mid, v = males3$id[which(males3$degree_0.3 == 0)])
g_rng_0.3 <- delete.vertices(graph = g_rng, v = males3$id[which(males3$degree_0.3 == 0)])

males3_0.3 <- males3[males3$degree_0.3 > 0,]

set.seed(3)
coords_0.3 <- layout_nicely(g_mid_0.3)
plot(g_mid_0.3,
     edge.color = rgb(0,0,0,0.25),
     edge.width = ifelse(E(g_mid_0.3)$weight > 0.3, E(g_rng_0.3)$weight*10, 0),
     vertex.size = 6,
     vertex.label = NA,
     layout = coords_0.3)
plot(g_mid_0.3,
     edge.width = ifelse(E(g_mid_0.3)$weight > 0.3, E(g_mid_0.3)$weight*10, 0),
     edge.color = 'black',
     vertex.size = 6,
     vertex.label = males3_0.3$id,
     vertex.label.color = ifelse(males3_0.3$age_class == 10,'white','black'),
     vertex.label.family = 'Helvetica',
     vertex.label.cex = 0.5,
     vertex.label.dist = 0,
     vertex.color = ifelse(males3_0.3$age_class == 7,'seagreen4',
                           ifelse(males3_0.3$age_class == 6,'seagreen3',
                                  ifelse(males3_0.3$age_class == 5,'seagreen2',
                                         ifelse(males3_0.3$age_class == 4,'steelblue3',
                                                ifelse(males3_0.3$age_class == 3,'steelblue1',
                                                       ifelse(males3_0.3$age_class == 2,'yellow',
                                                              'black')))))),
     layout = coords_0.3, add = TRUE)

par(mai = c(0.1,0.4,0.1,0.3))
plot(g_mid_0.3,
     edge.color = rgb(0,0,0,0.25),
     edge.width = ifelse(E(g_mid_0.3)$weight > 0.3, E(g_rng_0.3)$weight*10, 0),
     vertex.size = 1,
     vertex.label = NA,
     layout = coords_0.3)
plot(g_mid_0.3,
     edge.width = ifelse(E(g_mid_0.3)$weight > 0.3, E(g_mid_0.3)$weight*10, 0),
     edge.color = 'black',
     vertex.size = males3_0.3$count_period*8,
     vertex.label = males3_0.3$id,
     vertex.label.family = 'Helvetica',
     vertex.label.color = ifelse(males3_0.3$age_class == 10,'white','black'),
     vertex.label.cex = 0.5,
     vertex.label.dist = 0,
     vertex.color = ifelse(males3_0.3$age_class == 7,'seagreen4',
                           ifelse(males3_0.3$age_class == 6,'seagreen3',
                                  ifelse(males3_0.3$age_class == 5,'seagreen2',
                                         ifelse(males3_0.3$age_class == 4,'steelblue3',
                                                ifelse(males3_0.3$age_class == 3,'steelblue1',
                                                       ifelse(males3_0.3$age_class == 2,'yellow',
                                                              'black')))))),
     layout = coords_0.3, add = TRUE)

plot(g_mid_0.3,
     edge.color = rgb(0,0,0,0.25),
     edge.width = ifelse(E(g_mid_0.3)$weight > 0.3, E(g_rng_0.3)$weight*10, 0),
     vertex.size = 1,
     vertex.label = NA,
     layout = coords_0.3)
plot(g_mid_0.3,
     edge.width = ifelse(E(g_mid_0.3)$weight > 0.3, E(g_mid_0.3)$weight*10, 0),
     edge.color = 'black',
     vertex.size = males3_0.3$count_period*8,
     vertex.label = males3_0.3$id,
     vertex.label.family = 'Helvetica',
     vertex.label.color = ifelse(males3_0.3$age_class == 10,'white','black'),
     vertex.label.cex = 0.5,
     vertex.label.dist = 0,
     vertex.color = males3_0.3$age_mean,
     layout = coords_0.3, add = TRUE)

# print progress stamp
print(paste0('All network plots for period 3 completed at ', Sys.time()))

### save summary data -- period 3 ####
dyad_period_weights <- counts_df3
summaries$period <- 3
summaries <- summaries[,c(1,4:11)]
dyad_period_weights <- left_join(x = dyad_period_weights, y = summaries,
                                 by = c('dyad','period'))
rm(adj_lower, adj_mid, adj_range, adj_upper, coords, coords_0.3,
   counts_df3, draws_mpnp3, dyad_row, g_mid,g_mid_0.3, g_rng, g_rng_0.3, males3, rows, summaries, adj_quantiles, adj_tensor, i, N, plot_cols)

# print progress stamp
print(paste0('Time period 3 completed at ', Sys.time()))

# save summary data
write_csv(dyad_period_weights, '../../../../Google Drive/Shared drives/Helen PhD/chapter1_age/data_processed/mpnp3_dyad_weightdistributions.csv')

# save graphs
dev.off()
