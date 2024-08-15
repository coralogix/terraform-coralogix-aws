output "cluster_public_brokers" {
  value = aws_msk_cluster.coralogix-msk-cluster.bootstrap_brokers_public_sasl_iam
}
