output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = [for lambda in module.lambda : lambda.lambda_function_arn]
}

output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = [for lambda in module.lambda : lambda.lambda_function_name]
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role used by all Lambda Functions"
  value       = var.execution_role_name != null ? [data.aws_iam_role.LambdaExecutionRole[0].arn] : [aws_iam_role.lambda_role[0].arn]
}

output "lambda_role_name" {
  description = "The name of the IAM role used by all Lambda Functions"
  value       = var.execution_role_name != null ? [data.aws_iam_role.LambdaExecutionRole[0].name] : [aws_iam_role.lambda_role[0].name]
}

