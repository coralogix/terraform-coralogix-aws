output "firehose_stream_arn" {
  value       = aws_kinesis_firehose_delivery_stream.coralogix_stream_metrics.arn
  description = "value of the firehose stream ARN"
}

output "firehose_stream_name" {
  value       = aws_kinesis_firehose_delivery_stream.coralogix_stream_metrics.name
  description = "value of the firehose stream name"
}

output "firehose_iam_role_arn" {
  value       = local.firehose_iam_role_arn
  description = "value of the firehose IAM role ARN used"
}

output "s3_backup_bucket_arn" {
  value       = local.s3_backup_bucket_arn
  description = "value of the S3 backup bucket ARN used"
}

output "lambda_processor_arn" {
  value       = one(aws_lambda_function.lambda_processor[*].arn)
  description = "value of the firehose lambda processor ARN used"
}

output "lambda_processor_iam_arn" {
  value       = local.lambda_processor_iam_role_arn
  description = "value of the firehose lambda processor IAM role ARN used"
}

output "metric_stream_arn" {
  value       = one(aws_cloudwatch_metric_stream.cloudwatch_metric_stream[*].arn)
  description = "value of the cloudwatch metric stream ARN"
}

output "metrics_stream_iam_role_arn" {
  value       = local.metrics_stream_iam_role_arn
  description = "value of the cloudwatch metric stream IAM role ARN used"
}
