output "coralogix_otel_agent_task_definition_arn" {
  value       = coalesce(one(aws_ecs_task_definition.coralogix_otel_agent[*].arn), var.task_definition_arn)
  description = "ARN of the ECS Task Definition for the OTEL Agent Daemon"
}

output "coralogix_otel_agent_service_id" {
  value       = aws_ecs_service.coralogix_otel_agent.id
  description = "ID of the ECS Service for the OTEL Agent Daemon"
}

output "coralogix_otel_profiling_agent_task_definition_arn" {
  value       = try(aws_ecs_task_definition.coralogix_otel_profiling_agent[0].arn, null)
  description = "ARN of the ECS Task Definition for the profiling agent daemon. Null when profiling is disabled."
}

output "coralogix_otel_profiling_agent_service_id" {
  value       = try(aws_ecs_service.coralogix_otel_profiling_agent[0].id, null)
  description = "ID of the ECS Service for the profiling agent daemon. Null when profiling is disabled."
}
