data {
  int<lower=0> n_dyads;                   // Number of dyads
  array[n_dyads] int<lower=0> dyad_ids;   // Dyad ID corresponding to each data point
  array[n_dyads] int together;            // Total sightings of dyad in which they were together
  array[n_dyads] int count_dyad;          // Total sightings of dyad
}

parameters {
  vector<lower=0, upper=1>[n_dyads] edge_weight;      // edge weights for each dyad.
}

model {
    for (i in 1:n_dyads) {
        // Conditional priors
        if (together[i] == 0)
            edge_weight[i] ~ beta(0.7, 10);
        else
            edge_weight[i] ~ beta(2, 8);
        }

    together ~ binomial(count_dyad, edge_weight);

  for (d in 1:n_dyads) {
    i = id_1[d]
    j = id_2[d]
    edge_weight ~ age + U[i] + U[j]
  }
  U ~ gaussian(0, sigma_u)
  sigma_u ~

}

