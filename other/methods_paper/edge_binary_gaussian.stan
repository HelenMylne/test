data {
  int<lower=0> n_dyads;                   // Number of dyads
  array[n_dyads] int<lower=0> dyad_ids;   // Dyad ID corresponding to each data point
  array[n_dyads] int together;            // Total sightings of dyad in which they were together
  array[n_dyads] int count_dyad;          // Total sightings of dyad
  //int prior_mean;                         // 0 for wide/symmetrical prior, -2.5 for right skewed
  //int prior_stdev;                        // 2.5 for wide/symmetrical prior, 1.5 for right skewed
}

parameters {
  vector<lower=0, upper=1>[n_dyads] edge_weight;      // edge weights for each dyad.
}

model {
    edge_weight ~ normal(0, 2.5);
    together ~ binomial(count_dyad, inv_logit(edge_weight));
}
