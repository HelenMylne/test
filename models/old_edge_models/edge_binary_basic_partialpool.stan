data {
  int<lower=0> n_dyads;                   // Number of dyads
  array[n_dyads] int<lower=0> dyad_ids;   // int<lower=0> dyad_ids[n_dyads];   // Dyad ID corresponding to each data point
  array[n_dyads] int together;            // int together[n_dyads];            // Total sightings of dyad in which they were together
  array[n_dyads] int count_dyad;          // int count_dyad[n_dyads];          // Total sightings of dyad
}

parameters {
  vector<lower=0, upper=1>[n_dyads] edge_weight;      // edge weights for each dyad.
  real<lower=0> alpha;
  real<lower=0> beta;
}

model {
    for (i in 1:n_dyads) {
        // Conditional priors
        if (together[i] == 0)
            edge_weight[i] ~ beta(0.7, 10);
        else
            edge_weight[i] ~ beta(alpha, beta);
            alpha ~ gamma() // more likely to choose lower values but non-negative and have a long tail -- set a different prior for each of alpha and beta. check on stan forums to work out what they should be
            beta ~ gamma()
        }

    together ~ binomial(count_dyad, edge_weight);

}

