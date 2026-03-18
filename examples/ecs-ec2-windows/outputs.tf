output "coralogix_otel_agent_service_id" {
  description = "ID of the ECS Service for the OTEL Agent Daemon"
  value       = module.otel_ecs_ec2_windows_coralogix.coralogix_otel_agent_service_id
}

output "coralogix_otel_agent_task_definition_arn" {
  description = "ARN of the ECS Task Definition for the OTEL Agent Daemon"
  value       = module.otel_ecs_ec2_windows_coralogix.coralogix_otel_agent_task_definition_arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name used by the OTEL agent"
  value       = module.otel_ecs_ec2_windows_coralogix.cloudwatch_log_group_name
}
