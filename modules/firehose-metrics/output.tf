output "firehose_stream_name" {
  value       = aws_kinesis_firehose_delivery_stream.firehose_stream.name
  description = "value of the firehose stream name"
}

output "firehose_iam_role_arn" {
  value       = aws_iam_role.firehose_to_coralogix.arn
  description = "value of the firehose IAM role name ARN"
}

output "s3_backup_bucket_name" {
  value       = aws_s3_bucket.firehose_backup_bucket.bucket
  description = "value of the S3 backup bucket name"
}

output "lambda_processor_arn" {
  value       = aws_lambda_function.lambda_processor.arn
  description = "value of the firehose lambda processor ARN"
}

output "aws_cloudwatch_metric_stream_name" {
  value       = aws_cloudwatch_metric_stream.firehose_metric_stream.name
  description = "value of the cloudwatch metric stream name"
}
