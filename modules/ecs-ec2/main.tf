locals {
  coralogix_region_endpoint_map = {
    "Europe"    = "coralogix.com"
    "Europe2"   = "eu2.coralogix.com"
    "India"     = "coralogix.in"
    "Singapore" = "coralogixsg.com"
    "US"        = "coralogix.us"
    "US2"       = "cx498.coralogix.com"
  }
  coralogix_region_endpoint = local.coralogix_region_endpoint_map[var.coralogix_region]
  otel_config = coalesce(var.otel_config, (
    var.metrics ? templatefile("${path.module}/otel_config_metrics.tftpl.yaml", {})
    : templatefile("${path.module}/otel_config.tftpl.yaml", {})
  ))
}

resource "aws_ecs_task_definition" "coralogix_otel_agent" {
  family = "coralogix-otel-agent"
  cpu    = max(var.memory, 256)
  memory = var.memory
  volume {
    name      = "hostfs"
    host_path = "/"
  }
  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }
  container_definitions = jsonencode(
    [{
        "name"        : "coralogix-otel-agent",
        "networkMode" : "host",
        "requiresCompatibilities": ["EC2"],
        "image"       : "${var.image}:${var.image_version}",
        "essential"   : true,
        "portMappings": [
            {
            "containerPort" : 4317,
            "hostPort"      : 4317
            },
            {
            "containerPort" : 4318,
            "hostPort"      : 4318
            },
            {
            "containerPort" : 8888,
            "hostPort"      : 8888
            }
        ],
        "privileged": true,
        "mountPoints" : [
            {
            "sourceVolume" : "hostfs",
            "containerPath" : "/hostfs",
            "readOnly" : true
            },
            {
            "sourceVolume" : "docker-socket",
            "containerPath" : "/var/run/docker.sock"
            }
        ],
        "environment" : [
            {
                "name" : "CORALOGIX_DOMAIN",
                "value" : "${local.coralogix_region_endpoint}"
            },
            {
                "name" : "PRIVATE_KEY",
                "value" : "${var.private_key}"
            },
            {
                "name" : "APP_NAME",
                "value" : "${var.default_application_name}"
            },
            {
                "name" : "SUB_SYS",
                "value" : "${var.default_subsystem_name}"
            },
            {
                "name" : "OTEL_CONFIG",
                "value" : "${local.otel_config}"
            }
        ]
    }])
    tags = {
        "ecs:taskDefinition:createdFrom" = "terraform"
    }
}

resource "aws_ecs_service" "coralogix_otel_agent" {
  name            = "coralogix-otel-agent"
  cluster         = var.ecs_cluster_name
  launch_type     = "EC2"
  task_definition = aws_ecs_task_definition.coralogix_otel_agent.arn
  scheduling_strategy = "DAEMON"
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
}
