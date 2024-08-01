output "firehose_stream_name" {
  value       = aws_kinesis_firehose_delivery_stream.coralogix_stream_metrics.name
  description = "value of the firehose stream name"
}

output "firehose_iam_role_name" {
  value       = one(aws_iam_role.firehose_to_coralogix[*]).name
  description = "value of the firehose IAM role name"
}

output "firehose_iam_role_arn" {
  value       = one(aws_iam_role.firehose_to_coralogix[*]).arn
  description = "value of the firehose IAM role ARN"
}

output "new_s3_backup_bucket_name" {
  value       = one(aws_s3_bucket.new_firehose_bucket[*].id)
  description = "value of the S3 backup bucket name"
}

output "new_s3_backup_bucket_arn" {
  value       = one(aws_s3_bucket.new_firehose_bucket[*].arn)
  description = "value of the S3 backup bucket ARN"
}

output "lambda_processor_arn" {
  value       = one(aws_lambda_function.lambda_processor[*].arn)
  description = "value of the firehose lambda processor ARN"
}

output "aws_cloudwatch_metric_stream_arn" {
  value       = one(aws_cloudwatch_metric_stream.cloudwatch_metric_stream[*].arn)
  description = "value of the cloudwatch metric stream ARN"
}
