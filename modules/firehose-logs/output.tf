output "firehose_stream_arn" {
  value       = aws_kinesis_firehose_delivery_stream.coralogix_stream_logs.arn
  description = "value of the firehose stream ARN"
}

output "firehose_stream_name" {
  value       = aws_kinesis_firehose_delivery_stream.coralogix_stream_logs.name
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
