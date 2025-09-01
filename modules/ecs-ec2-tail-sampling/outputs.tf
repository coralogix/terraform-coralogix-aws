output "cloudmap_namespace_id" {
  description = "ID of the CloudMap namespace"
  value       = aws_service_discovery_private_dns_namespace.otel.id
}

output "cloudmap_namespace_name" {
  description = "Name of the CloudMap namespace"
  value       = aws_service_discovery_private_dns_namespace.otel.name
}

output "gateway_service_id" {
  description = "ID of the Gateway CloudMap service"
  value       = aws_service_discovery_service.gateway.id
}

output "gateway_service_arn" {
  description = "ARN of the Gateway CloudMap service"
  value       = aws_service_discovery_service.gateway.arn
}

output "receiver_service_id" {
  description = "ID of the Receiver CloudMap service (only for central-cluster deployment)"
  value       = var.deployment_type == "central-cluster" ? aws_service_discovery_service.receiver[0].id : null
}

output "receiver_service_arn" {
  description = "ARN of the Receiver CloudMap service (only for central-cluster deployment)"
  value       = var.deployment_type == "central-cluster" ? aws_service_discovery_service.receiver[0].arn : null
}

output "task_execution_role_arn" {
  description = "ARN of the task execution role (either created or provided)"
  value       = local.execution_role_arn
}

output "task_execution_role_name" {
  description = "Name of the task execution role (only if created by module)"
  value       = local.create_iam_role ? aws_iam_role.task_execution_role[0].name : null
}

output "agent_task_definition_arn" {
  description = "ARN of the Agent task definition (only for tail-sampling deployment)"
  value       = var.deployment_type == "tail-sampling" ? aws_ecs_task_definition.agent[0].arn : null
}

output "gateway_task_definition_arn" {
  description = "ARN of the Gateway task definition"
  value       = aws_ecs_task_definition.gateway.arn
}

output "receiver_task_definition_arn" {
  description = "ARN of the Receiver task definition (only for central-cluster deployment)"
  value       = var.deployment_type == "central-cluster" ? aws_ecs_task_definition.receiver[0].arn : null
}

output "agent_service_name" {
  description = "Name of the Agent ECS service (only for tail-sampling deployment)"
  value       = var.deployment_type == "tail-sampling" ? aws_ecs_service.agent[0].name : null
}

output "gateway_service_name" {
  description = "Name of the Gateway ECS service"
  value       = aws_ecs_service.gateway.name
}

output "receiver_service_name" {
  description = "Name of the Receiver ECS service (only for central-cluster deployment)"
  value       = var.deployment_type == "central-cluster" ? aws_ecs_service.receiver[0].name : null
}

output "deployment_type" {
  description = "The deployment type that was used"
  value       = var.deployment_type
}
