output "lambda_layer_version_arn" {
  description = "Lambda Layer version ARN for coralogix-smlayer"
  value       = aws_lambda_layer_version.coralogix_smlayer.arn
}
