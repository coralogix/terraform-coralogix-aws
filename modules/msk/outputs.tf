output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = module.lambda.lambda_function_name
}

output "lambdaSSM_function_name" {
  description = "The name of the LambdaSSM Function"
  value       = module.lambdaSSM.lambda_function_name
}