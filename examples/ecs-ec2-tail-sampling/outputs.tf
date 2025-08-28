output "coralogix_otel_agent_service_id" {
  description = "ID of the ECS Service for the OTEL Agent Daemon"
  value       = module.otel_ecs_ec2_tail_sampling.agent_service_name
}

output "coralogix_otel_agent_task_definition_arn" {
  description = "ARN of the ECS Task Definition for the OTEL Agent Daemon"
  value       = module.otel_ecs_ec2_tail_sampling.agent_task_definition_arn
}

output "coralogix_otel_gateway_service_id" {
  description = "ID of the ECS Service for the OTEL Gateway"
  value       = module.otel_ecs_ec2_tail_sampling.gateway_service_name
}

output "coralogix_otel_gateway_task_definition_arn" {
  description = "ARN of the ECS Task Definition for the OTEL Gateway"
  value       = module.otel_ecs_ec2_tail_sampling.gateway_task_definition_arn
}

output "coralogix_otel_receiver_service_id" {
  description = "ID of the ECS Service for the OTEL Receiver (central-cluster deployment only)"
  value       = module.otel_ecs_ec2_tail_sampling.receiver_service_name
}

output "coralogix_otel_receiver_task_definition_arn" {
  description = "ARN of the ECS Task Definition for the OTEL Receiver (central-cluster deployment only)"
  value       = module.otel_ecs_ec2_tail_sampling.receiver_task_definition_arn
}
