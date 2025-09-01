output "cloudmap_namespace_id" {
  description = "ID of the CloudMap namespace"
  value       = module.otel_ecs_ec2_tail_sampling.cloudmap_namespace_id
}

output "gateway_service_name" {
  description = "Name of the Gateway ECS service"
  value       = module.otel_ecs_ec2_tail_sampling.gateway_service_name
}

output "gateway_task_definition_arn" {
  description = "ARN of the Gateway task definition"
  value       = module.otel_ecs_ec2_tail_sampling.gateway_task_definition_arn
}

output "agent_service_name" {
  description = "Name of the Agent ECS service (only for tail-sampling deployment)"
  value       = module.otel_ecs_ec2_tail_sampling.agent_service_name
}

output "agent_task_definition_arn" {
  description = "ARN of the Agent task definition (only for tail-sampling deployment)"
  value       = module.otel_ecs_ec2_tail_sampling.agent_task_definition_arn
}

output "receiver_service_name" {
  description = "Name of the Receiver ECS service (only for central-cluster deployment)"
  value       = module.otel_ecs_ec2_tail_sampling.receiver_service_name
}

output "receiver_task_definition_arn" {
  description = "ARN of the Receiver task definition (only for central-cluster deployment)"
  value       = module.otel_ecs_ec2_tail_sampling.receiver_task_definition_arn
}

output "deployment_type" {
  description = "The deployment type that was used"
  value       = module.otel_ecs_ec2_tail_sampling.deployment_type
}
