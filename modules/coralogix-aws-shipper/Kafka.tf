resource "aws_lambda_event_source_mapping" "example" {
    function_name     = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
    depends_on = [ module.lambda ]
    topics            = [var.msk_topic_name]
    starting_position = "TRIM_HORIZON"

    self_managed_event_source {
        endpoints = {
            KAFKA_BOOTSTRAP_SERVERS = var.kafka_brokers
        }
    }
    for_each = toset(var.kafka_subnets_ids)
    source_access_configuration {
        type = "VPC_SUBNET"
        uri  = "subnet:${each.value}"
    }
}

resource "aws_lambda_event_source_mapping" "example" {
    function_name     = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
    depends_on = [ module.lambda ]
    topics            = [var.msk_topic_name]
    starting_position = "TRIM_HORIZON"

    self_managed_event_source {
        endpoints = {
            KAFKA_BOOTSTRAP_SERVERS = var.kafka_brokers
        }
    }

    for_each = toset(var.kafka_security_groups)
    source_access_configuration {
        type = "VPC_SECURITY_GROUP"
        uri  = "security_group:${each.value}"
    }
}