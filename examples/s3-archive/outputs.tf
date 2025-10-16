output "wrong_region" {
  value = module.s3-archive.wrong_region
}

output "logs_kms_problem" {
  value = module.s3-archive.logs_kms_problem
}

output "metrics_kms_problem" {
  value = module.s3-archive.metrics_kms_problem
}
