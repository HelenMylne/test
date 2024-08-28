data {
  // global data size
  int num_dyads;                      // Number of edges
  int num_nodes;                      // Number of nodes
  int num_age_cat;                    // Number of unique age categories
  int length_dirichlet;               // Number of unique age categories + 1
  
  // Gaussian approximation of edge weights
  vector[num_dyads] logit_edge_mu;    // Means of logit edge weights
  vector[num_dyads] logit_edge_sd;    // Standard deviation of logit edge weights
  
  // explanatory variable
  array[num_dyads] int age_min_cat;   // age of younger dyad member
  
  // multimembership terms
  array[num_dyads] int node_1;        // Node 1 IDs for multimembership terms
  array[num_dyads] int node_2;        // Node 2 IDs for multimembership terms
  
  // prior values for Dirichlet
  vector[num_age_cat] prior_min;      // Dirichlet prior values
}

parameters {
  // intercept
  real intercept;
  
  // exposure slope
  real beta_age_min;
  
  // variance
  real<lower=0> sigma;
  
  // multimembership effects
  real mu_mm;
  vector[num_nodes] rand_mm;
  real<lower=0> sigma_mm;
  
  // difference between age categories
  simplex[num_age_cat] delta_min;
}

transformed parameters {
  // create prior for cumulative probability of each age category
  vector[length_dirichlet] delta_j_min;
  delta_j_min = append_row(0, delta_min);
  
  // multimembership effects
  vector[num_nodes] mm_nodes;
  mm_nodes = mu_mm + rand_mm * sigma_mm;

  // regression equation
  vector[num_dyads] predictor;
  for (i in 1:num_dyads) {
    predictor[i] = intercept + beta_age_min * sum(delta_j_min[1:age_min_cat[i]]) + mm_nodes[node_1[i]] + mm_nodes[node_2[i]];
  }
}

model {
  // intercept prior
  intercept ~ normal(0,1);
  
  // age priors
  beta_age_min ~ normal(0,2.5);
  delta_min ~ dirichlet(prior_min);
  
  // variance
  sigma ~ exponential(2);
  
  // multimembership priors
  mu_mm ~ normal(0,1);
  rand_mm ~ normal(0,1);
  sigma_mm ~ normal(0,1)T[0,];

  // likelihood
  logit_edge_mu ~ normal(predictor, logit_edge_sd + rep_vector(sigma, num_dyads));
}
