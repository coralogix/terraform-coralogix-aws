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

output "lambda_policy_statements" {
  description = "IAM statements attached to the Lambda Function role"
  value       = local.policy_statements
}

output "lambda_package_key" {
  description = "S3 key of the deployed Lambda Manager package"
  value       = local.package_key
}
