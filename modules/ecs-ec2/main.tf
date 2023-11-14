locals {
  coralogix_region_domain_map = {
    "europe"    = "coralogix.com"
    "europe2"   = "eu2.coralogix.com"
    "india"     = "coralogix.in"
    "singapore" = "coralogixsg.com"
    "us"        = "coralogix.us"
    "us2"       = "cx498.coralogix.com"
    "custom"    = null
  }
  coralogix_domain = coalesce(var.custom_domain, local.coralogix_region_domain_map[lower(var.coralogix_region)])
  otel_config_file = coalesce(var.otel_config_file,
    (var.metrics ? "${path.module}/otel_config_metrics.tftpl.yaml" : "${path.module}/otel_config.tftpl.yaml")
  )
  otel_config = templatefile(local.otel_config_file, {})
}

resource "aws_ecs_task_definition" "coralogix_otel_agent" {
  family                   = "coralogix-otel-agent"
  cpu                      = max(var.memory, 256)
  memory                   = var.memory
  requires_compatibilities = ["EC2"]
  volume {
    name      = "hostfs"
    host_path = "/"
  }
  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }
  tags = {
    "ecs:taskDefinition:createdFrom" = "terraform"
  }
  container_definitions = jsonencode(
    [{
      "name" : "coralogix-otel-agent"
      "networkMode" : "host"
      "image" : "${var.image}:${var.image_version}"
      "essential" : true
      "portMappings" : [
        {
          "containerPort" : 4317
          "hostPort" : 4317
        },
        {
          "containerPort" : 4318
          "hostPort" : 4318
        },
        {
          "containerPort" : 8888
          "hostPort" : 8888
        },
        {
          "containerPort" : 13133
          "hostPort" : 13133
        }
      ],
      "privileged" : true,
      "mountPoints" : [
        {
          "sourceVolume" : "hostfs"
          "containerPath" : "/hostfs"
          "readOnly" : true
        },
        {
          "sourceVolume" : "docker-socket"
          "containerPath" : "/var/run/docker.sock"
        }
      ],
      "environment" : [
        {
          "name" : "CORALOGIX_DOMAIN"
          "value" : "${local.coralogix_domain}"
        },
        {
          "name" : "PRIVATE_KEY"
          "value" : "${var.api_key}"
        },
        {
          "name" : "APP_NAME"
          "value" : "${var.default_application_name}"
        },
        {
          "name" : "SUB_SYS"
          "value" : "${var.default_subsystem_name}"
        },
        {
          "name" : "OTEL_CONFIG"
          "value" : "${local.otel_config}"
        }
      ],
      "healthCheck" : {
        "command" : ["CMD-SHELL", "nc -vz localhost 13133 || exit 1"]
        "startPeriod" : 30
        "interval" : 30
        "timeout" : 5
        "retries" : 3
      }
  }])
}

resource "aws_ecs_service" "coralogix_otel_agent" {
  name                               = "coralogix-otel-agent"
  cluster                            = var.ecs_cluster_name
  launch_type                        = "EC2"
  task_definition                    = aws_ecs_task_definition.coralogix_otel_agent.arn
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
}
