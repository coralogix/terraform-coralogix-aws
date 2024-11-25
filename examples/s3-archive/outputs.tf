output "wrong_region" {
  value = local.is_valid_region ? "" : "You tried to configure the bucket in a region that is not supported, or you are not in the region that you specified. Allow regions: eu-west-1, eu-north-1, ap-southeast-1, ap-south-1, us-east-2, us-west-2"
}

output "logs_kms_problem" {
  value = var.logs_kms_arn == "" || contains(split(":", var.logs_kms_arn), var.aws_region) ? "" : "The KMS that you specified for logs is not in the same region as your aws_region"
}

output "metrics_kms_problem" {
  value = var.metrics_kms_arn == "" || contains(split(":", var.metrics_kms_arn), var.aws_region) ? "" : "The KMS that you specified for metrics is not in the same region as your aws_region"
}