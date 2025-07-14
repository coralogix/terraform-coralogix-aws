output "coralogix_otel_agent_service_id" {
  description = "ID of the ECS Service for the OTEL Agent Daemon"
  value       = module.otel_ecs_ec2_coralogix.coralogix_otel_agent_service_id
}

output "coralogix_otel_agent_task_definition_arn" {
  description = "ARN of the ECS Task Definition for the OTEL Agent Daemon"
  value       = module.otel_ecs_ec2_coralogix.coralogix_otel_agent_task_definition_arn
} 