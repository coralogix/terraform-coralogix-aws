output "coralogix_metrics_role_arn" {
  description = "The ARN of the Coralogix AWS Metrics role."
  value       = aws_iam_role.this.arn
}

output "external_id" {
  description = "The external ID used in sts:AssumeRole, computed as <external_id_secret>@<coralogix_company_id>."
  value       = "${var.external_id_secret}@${var.coralogix_company_id}"
}
