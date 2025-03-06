locals {
  name = "coralogix-otel-agent"
  tags = merge(
    {
      "ecs:taskDefinition:createdFrom" = "terraform"
    },
    var.tags
  )
  coralogix_region_domain_map = module.locals_variables.coralogix_domains
  coralogix_domain = coalesce(var.custom_domain, local.coralogix_region_domain_map[var.coralogix_region])
  otel_config_file = coalesce(var.otel_config_file, "${path.module}/otel_config.tftpl.yaml")
  otel_config = file(local.otel_config_file)
}

module "locals_variables" {
  source = "../locals_variables"
  integration_type = "ecs-ec2"
  random_string    = random_string.id.result
}

resource "random_string" "id" {
  length  = 7
  lower   = true
  numeric = true
  upper   = false
  special = false
}

resource "aws_ecs_task_definition" "coralogix_otel_agent" {
  count = var.task_definition_arn == null ? 1 : 0
  family                   = "${local.name}-${random_string.id.result}"
  cpu                      = max(var.memory, 256)
  memory                   = var.memory
  requires_compatibilities = ["EC2"]
  execution_role_arn      = (var.custom_config_parameter_store_name != null || var.use_api_key_secret == true) ? var.task_execution_role_arn : null
  volume {
    name      = "hostfs"
    host_path = "/var/lib/docker/"
  }
  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }
  tags = merge(
    {
      Name = "${local.name}-${random_string.id.result}"
    },
    var.tags
  )
  container_definitions = jsonencode([{
    name : local.name
    networkMode : "host"
    image : "${var.image}:${var.image_version}"
    essential : true
    portMappings : [
      {
        containerPort : 4317
        hostPort : 4317
        appProtocol: "grpc"
      },
      {
        containerPort : 4318
        hostPort : 4318
      },
      {
        containerPort : 8888
        hostPort : 8888
      },
      {
        containerPort : 13133
        hostPort : 13133
      }
    ],
    privileged : true,
    mountPoints : [
      {
        sourceVolume : "hostfs"
        containerPath : "/hostfs/var/lib/docker/"
        readOnly : true
      },
      {
        sourceVolume : "docker-socket"
        containerPath : "/var/run/docker.sock"
      }
    ],
    environment : concat([
      {
        name : "CORALOGIX_DOMAIN"
        value : local.coralogix_domain
      },
      {
        name : "APP_NAME"
        value : var.default_application_name
      },
      {
        name : "SUB_SYS"
        value : var.default_subsystem_name
      }
    ],
    var.custom_config_parameter_store_name == null ? [{
      name : "OTEL_CONFIG"
      value : local.otel_config
    }] : [],
    var.use_api_key_secret != true ? [{
      name : "PRIVATE_KEY"
      value : var.api_key
    }] : []),
    secrets : concat(
      var.custom_config_parameter_store_name != null ? [{
        name : "OTEL_CONFIG"
        valueFrom : var.custom_config_parameter_store_name
      }] : [],
      var.use_api_key_secret == true ? [{
        name : "PRIVATE_KEY"
        valueFrom : var.api_key_secret_arn
      }] : []
    ),
    command: ["--config", "env:OTEL_CONFIG"],
    healthCheck : {
      command : ["CMD-SHELL", "nc -vz localhost 13133 || exit 1"]
      startPeriod : 30
      interval : 30
      timeout : 5
      retries : 3
    },
    logConfiguration: {
      logDriver: "json-file"
    }
  }])
}

resource "aws_ecs_service" "coralogix_otel_agent" {
  name                               = "${local.name}-${random_string.id.result}"
  cluster                            = var.ecs_cluster_name
  launch_type                        = "EC2"
  task_definition                    = var.task_definition_arn == null ? aws_ecs_task_definition.coralogix_otel_agent[0].arn : var.task_definition_arn
  scheduling_strategy                = "DAEMON"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }
  service_connect_configuration {
    enabled = false
  }
  enable_ecs_managed_tags = true
  tags = merge(
    {
      Name = "${local.name}-${random_string.id.result}"
    },
    var.tags
  )
}
