data {
  int num_nodes;                    // Number of nodes
  vector[num_nodes] nodes;          // Node IDs
  vector[num_nodes] centrality_mu;  // Means of centrality estimates
  matrix[num_nodes, num_nodes] centrality_cov;  // standard deviations of centrality estimates
  vector[num_nodes] age_mu;         // mean of node age distribution
  vector[num_nodes] age_sd;         // stdv of node age distribution
}

parameters {
  real beta_age;
  real<lower=0> sigma;
  vector[num_nodes] node_age;
}

transformed parameters {
  // linear model
  vector[num_nodes] predictor;
  predictor = beta_age*node_age;
}

model {
  // priors
  beta_age ~ normal(0, 0.1);
  sigma ~ exponential(2);
  
  // likelihood
  centrality_mu ~ multi_normal(predictor, centrality_cov + diag_matrix(rep_vector(sigma, num_nodes)));
  
  // node age
  node_age ~ normal(age_mu, age_sd);
  
}
