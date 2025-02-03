output "collector_lambda_function_arn" {
  description = "The ARN of the Collector Lambda Function"
  value       = module.collector_lambda.lambda_function_arn
}

output "collector_lambda_function_name" {
  description = "The name of the Collector Lambda Function"
  value       = module.collector_lambda.lambda_function_name
}

output "collector_lambda_role_arn" {
  description = "The ARN of the IAM role created for the Collector Lambda Function"
  value       = module.collector_lambda.lambda_role_arn
}

output "collector_lambda_role_name" {
  description = "The name of the IAM role created for the Collector Lambda Function"
  value       = module.collector_lambda.lambda_role_name
}

output "generator_lambda_function_arn" {
  description = "The ARN of the Generator Lambda Function"
  value       = var.secret_manager_enabled ? module.generator_lambda_sm.lambda_function_arn : module.generator_lambda.lambda_function_arn
}

output "generator_lambda_function_name" {
  description = "The name of the Generator Lambda Function"
  value       = var.secret_manager_enabled ? module.generator_lambda_sm.lambda_function_name : module.generator_lambda.lambda_function_name
}

output "generator_lambda_role_arn" {
  description = "The ARN of the IAM role created for the Generator Lambda Function"
  value       = var.secret_manager_enabled ? module.generator_lambda_sm.lambda_role_arn : module.generator_lambda.lambda_role_arn
}

output "generator_lambda_role_name" {
  description = "The name of the IAM role created for the Generator Lambda Function"
  value       = var.secret_manager_enabled ? module.generator_lambda_sm.lambda_role_name : module.generator_lambda.lambda_role_name
}

output "metadata_queue_arn" {
  description = "The ARN of the SQS queue for metadata"
  value       = aws_sqs_queue.metadata_queue.arn
}

output "metadata_queue_url" {
  description = "The URL of the SQS queue for metadata"
  value       = aws_sqs_queue.metadata_queue.url
}

output "cloudtrail_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs"
  value       = var.event_mode == "EnabledCreateTrail" ? aws_s3_bucket.cloudtrail[0].id : null
}

output "cloudtrail_bucket_arn" {
  description = "The ARN of the S3 bucket for CloudTrail logs"
  value       = var.event_mode == "EnabledCreateTrail" ? aws_s3_bucket.cloudtrail[0].arn : null
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for failure notifications"
  value       = aws_sns_topic.this.arn
}
