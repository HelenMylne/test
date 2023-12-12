data {
  int num_data;                                // Number of edges in total data
  int num_dyads;                               // Number of unique dyads across all windows
  int num_nodes;                               // Number of unique nodes across all windows
  int num_windows;                             // Number of time windows
  vector[num_data] logit_edge_mu;              // Means of Gaussian approximation of logit edge weights
  matrix[num_data, num_data] logit_edge_cov;   // Covariance matrix of Gaussian approximation of logit edge weights
  array[num_data] real age_min;                // age of younger dyad member
  array[num_data] real age_max;                // age of older dyad member
  array[num_data] int node_1;                  // Node 1 IDs for multimembership terms
  array[num_data] int node_2;                  // Node 2 IDs for multimembership terms
  array[num_data] int window;                  // ID of time window (random effect)
  array[num_data] int dyad_id;                 // ID of dyad (random effect -- same value when dyad seen in multiple windows)
}

parameters {
  // intercept
  real intercept;
  // exposure slopes
  real beta_age_max;
  real beta_age_min;
  // multimembership effects
  vector[num_nodes] mm_nodes;
  real<lower=0> sigma;
  real<lower=0> sigma_mm;
  // random effects
  vector[num_windows] rand_window;
  vector[num_dyads] rand_dyad;
}

transformed parameters {
  //  Cholesky factor of the covariance matrix
  matrix[num_data, num_data] L_cov;
  L_cov = cholesky_decompose(logit_edge_cov + diag_matrix(rep_vector(sigma, num_data)));
  
  // regression equation
  vector[num_data] predictor;
  for (i in 1:num_data) {
    predictor[i] = intercept + beta_age_min * age_min[i] + beta_age_max * age_max[i] + mm_nodes[node_1[i]] + mm_nodes[node_2[i]] + rand_window[window[i]] + rand_dyad[dyad_id[i]];
  }
}

model {
  // priors
  beta_age_max ~ normal(0,1);
  beta_age_min ~ normal(0,1);
  mm_nodes ~ normal(0, sigma_mm);
  sigma ~ exponential(1);
  sigma_mm ~ exponential(1);
  intercept ~ normal(0,1);
  rand_window ~ normal(0,1);
  rand_dyad ~ normal(0,1);

  // likelihood using Cholesky decomposition
  logit_edge_mu ~ multi_normal_cholesky(predictor, L_cov);
}
