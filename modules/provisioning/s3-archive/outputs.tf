output "bucket_name_same" {
  value = local.is_same_bucket_name ? "Logs and Metrics bucket name should not be the same" : ""
}

output "wrong_region" {
  value = local.is_valid_region ? "" : "You tried to configure the bucket in a region that is not supported, or you are not in the region that you specified"
}

output "logs_kms_problem" {
  value = var.logs_kms_arn == "" || contains(split(":", var.logs_kms_arn), var.coralogix_region) ? "" : "The KMS that you specified for logs is not in the same region as your coralogix_region"
}

output "metrics_kms_problem" {
  value = var.metrics_kms_arn == "" || contains(split(":", var.metrics_kms_arn), var.coralogix_region) ? "" : "The KMS that you specified for metrics is not in the same region as your coralogix_region"
}