output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = module.resource-metadata.lambda_function_arn
}

output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = module.resource-metadata.lambda_function_name
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda Function"
  value       = module.resource-metadata.lambda_role_arn
}

output "lambda_role_name" {
  description = "The name of the IAM role created for the Lambda Function"
  value       = module.resource-metadata.lambda_role_name
}

output "secret_arn" {
  description = "The ARN of the created secret (if using secret manager with create_secret = true)"
  value       = module.resource-metadata.secret_arn
}

output "secret_access_policy_arn" {
  description = "The ARN of the secret access policy (if using secret manager)"
  value       = module.resource-metadata.secret_access_policy_arn
}

