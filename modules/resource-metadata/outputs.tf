output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = module.lambda.lambda_function_arn
}

output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = module.lambda.lambda_function_name
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda Function"
  value       = module.lambda.lambda_role_arn
}

output "lambda_role_name" {
  description = "The name of the IAM role created for the Lambda Function"
  value       = module.lambda.lambda_role_name
}

output "secret_arn" {
  description = "The ARN of the created secret (if using secret manager with create_secret = true)"
  value       = var.secret_manager_enabled && var.create_secret && length(aws_secretsmanager_secret.private_key_secret) > 0 ? aws_secretsmanager_secret.private_key_secret[0].arn : null
}

output "secret_access_policy_arn" {
  description = "The ARN of the secret access policy (if using secret manager)"
  value       = var.secret_manager_enabled && length(aws_iam_policy.secret_access_policy) > 0 ? aws_iam_policy.secret_access_policy[0].arn : null
}
