# Conditional Outputs based on test scenario
output "test_scenario" {
  description = "The test scenario that was executed"
  value       = var.test_scenario
}

# Tail Sampling Deployment Outputs
output "tail_sampling_cloudmap_namespace_id" {
  description = "ID of the CloudMap namespace for tail sampling deployment"
  value       = var.test_scenario == "tail-sampling" ? module.otel_tail_sampling[0].cloudmap_namespace_id : null
}

output "tail_sampling_gateway_service_id" {
  description = "ID of the Gateway CloudMap service for tail sampling deployment"
  value       = var.test_scenario == "tail-sampling" ? module.otel_tail_sampling[0].gateway_service_id : null
}

output "tail_sampling_agent_task_definition_arn" {
  description = "ARN of the Agent task definition for tail sampling deployment"
  value       = var.test_scenario == "tail-sampling" ? module.otel_tail_sampling[0].agent_task_definition_arn : null
}

output "tail_sampling_gateway_task_definition_arn" {
  description = "ARN of the Gateway task definition for tail sampling deployment"
  value       = var.test_scenario == "tail-sampling" ? module.otel_tail_sampling[0].gateway_task_definition_arn : null
}

output "tail_sampling_agent_service_name" {
  description = "Name of the Agent ECS service for tail sampling deployment"
  value       = var.test_scenario == "tail-sampling" ? module.otel_tail_sampling[0].agent_service_name : null
}

output "tail_sampling_gateway_service_name" {
  description = "Name of the Gateway ECS service for tail sampling deployment"
  value       = var.test_scenario == "tail-sampling" ? module.otel_tail_sampling[0].gateway_service_name : null
}

# Central Cluster Deployment Outputs
output "central_cluster_cloudmap_namespace_id" {
  description = "ID of the CloudMap namespace for central cluster deployment"
  value       = var.test_scenario == "central-cluster" ? module.otel_central_cluster[0].cloudmap_namespace_id : null
}

output "central_cluster_gateway_service_id" {
  description = "ID of the Gateway CloudMap service for central cluster deployment"
  value       = var.test_scenario == "central-cluster" ? module.otel_central_cluster[0].gateway_service_id : null
}

output "central_cluster_agent_task_definition_arn" {
  description = "ARN of the Agent task definition for central cluster deployment"
  value       = var.test_scenario == "central-cluster" ? module.otel_central_cluster[0].agent_task_definition_arn : null
}

output "central_cluster_gateway_task_definition_arn" {
  description = "ARN of the Gateway task definition for central cluster deployment"
  value       = var.test_scenario == "central-cluster" ? module.otel_central_cluster[0].gateway_task_definition_arn : null
}

output "central_cluster_agent_service_name" {
  description = "Name of the Agent ECS service for central cluster deployment"
  value       = var.test_scenario == "central-cluster" ? module.otel_central_cluster[0].agent_service_name : null
}

output "central_cluster_gateway_service_name" {
  description = "Name of the Gateway ECS service for central cluster deployment"
  value       = var.test_scenario == "central-cluster" ? module.otel_central_cluster[0].gateway_service_name : null
}

output "central_cluster_receiver_service_name" {
  description = "Name of the Receiver ECS service for central cluster deployment"
  value       = var.test_scenario == "central-cluster" ? module.otel_central_cluster[0].receiver_service_name : null
}

output "central_cluster_receiver_task_definition_arn" {
  description = "ARN of the Receiver task definition for central cluster deployment"
  value       = var.test_scenario == "central-cluster" ? module.otel_central_cluster[0].receiver_task_definition_arn : null
}

# External Role Deployment Outputs
output "external_role_cloudmap_namespace_id" {
  description = "ID of the CloudMap namespace for external role deployment"
  value       = var.test_scenario == "external-role" ? module.otel_external_role[0].cloudmap_namespace_id : null
}

output "external_role_gateway_service_id" {
  description = "ID of the Gateway CloudMap service for external role deployment"
  value       = var.test_scenario == "external-role" ? module.otel_external_role[0].gateway_service_id : null
}

output "external_role_agent_task_definition_arn" {
  description = "ARN of the Agent task definition for external role deployment"
  value       = var.test_scenario == "external-role" ? module.otel_external_role[0].agent_task_definition_arn : null
}

output "external_role_gateway_task_definition_arn" {
  description = "ARN of the Gateway task definition for external role deployment"
  value       = var.test_scenario == "external-role" ? module.otel_external_role[0].gateway_task_definition_arn : null
}

output "external_role_agent_service_name" {
  description = "Name of the Agent ECS service for external role deployment"
  value       = var.test_scenario == "external-role" ? module.otel_external_role[0].agent_service_name : null
}

output "external_role_gateway_service_name" {
  description = "Name of the Gateway ECS service for external role deployment"
  value       = var.test_scenario == "external-role" ? module.otel_external_role[0].gateway_service_name : null
}

# Generic deployment type output
output "deployment_type" {
  description = "The deployment type that was used"
  value = (
    var.test_scenario == "tail-sampling" ? module.otel_tail_sampling[0].deployment_type :
    var.test_scenario == "central-cluster" ? module.otel_central_cluster[0].deployment_type :
    var.test_scenario == "external-role" ? module.otel_external_role[0].deployment_type : null
  )
}

