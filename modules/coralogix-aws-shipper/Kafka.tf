resource "aws_lambda_event_source_mapping" "kafka" {
  count             = var.kafka_brokers != null ? 1 : 0
  function_name     = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  depends_on        = [module.lambda]
  topics            = [var.kafka_topic]
  starting_position = "TRIM_HORIZON"

  self_managed_event_source {
    endpoints = {
      KAFKA_BOOTSTRAP_SERVERS = var.kafka_brokers
    }
  }
  dynamic "source_access_configuration" {
    for_each = var.kafka_subnets_ids
    content {
      type = "VPC_SUBNET"
      uri  = "subnet:${source_access_configuration.value}"
    }
  }

  dynamic "source_access_configuration" {
    for_each = var.kafka_security_groups
    content {
      type = "VPC_SECURITY_GROUP"
      uri  = "security_group:${source_access_configuration.value}"
    }
  }
}
