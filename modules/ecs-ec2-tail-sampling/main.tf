locals {
  name        = "coralogix-otel-tail-sampling"
  name_prefix = var.name_prefix != "" ? "${var.name_prefix}-" : ""
  tags = merge(
    {
      "ecs:taskDefinition:createdFrom" = "terraform"
    },
    var.tags
  )
  coralogix_region_domain_map = module.locals_variables.coralogix_domains
  coralogix_domain            = coalesce(var.custom_domain, local.coralogix_region_domain_map[var.coralogix_region])

  # Determine which execution role to use
  execution_role_arn = var.task_execution_role_arn != null ? var.task_execution_role_arn : aws_iam_role.task_execution_role[0].arn

  # Determine if we need to create IAM role
  create_iam_role = var.task_execution_role_arn == null

  # Determine which image to use (custom image or Coralogix image with version)
  use_custom_image = var.custom_image != null
  container_image  = local.use_custom_image ? var.custom_image : "coralogixrepo/coralogix-otel-collector:${var.image_version}"
}

module "locals_variables" {
  source           = "../locals_variables"
  integration_type = "ecs-ec2-tail-sampling"
  random_string    = random_string.id.result
}

data "aws_region" "current" {}

resource "random_string" "id" {
  length  = 7
  lower   = true
  numeric = true
  upper   = false
  special = false
}

# CloudMap Namespace
resource "aws_service_discovery_private_dns_namespace" "otel" {
  name        = "cx-otel"
  vpc         = var.vpc_id
  description = "Cloud Map namespace for OpenTelemetry services"
  tags        = local.tags
}

# CloudMap Service for Gateway
resource "aws_service_discovery_service" "gateway" {
  name = "grpc-gateway"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.otel.id

    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  health_check_custom_config {
  }

  tags = local.tags
}

# CloudMap Service for Receiver (only for central cluster)
resource "aws_service_discovery_service" "receiver" {
  count = var.deployment_type == "central-cluster" ? 1 : 0
  name  = "grpc-receiver"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.otel.id

    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  health_check_custom_config {
  }

  tags = local.tags
}

# Task Execution Role (only created if external role not provided)
resource "aws_iam_role" "task_execution_role" {
  count = local.create_iam_role ? 1 : 0
  name  = "${local.name}-${random_string.id.result}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# Attach ECS task execution policy
resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  count      = local.create_iam_role ? 1 : 0
  role       = aws_iam_role.task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# S3 read access policy
resource "aws_iam_role_policy" "task_execution_role_s3_policy" {
  count = local.create_iam_role ? 1 : 0
  name  = "S3ReadAccess"
  role  = aws_iam_role.task_execution_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.s3_config_bucket}/*"
      }
    ]
  })
}

# CloudMap discovery policy
resource "aws_iam_role_policy" "task_execution_role_cloudmap_policy" {
  count = local.create_iam_role ? 1 : 0
  name  = "CloudMapDiscovery"
  role  = aws_iam_role.task_execution_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "servicediscovery:DiscoverInstances",
          "servicediscovery:ListInstances",
          "servicediscovery:ListServices",
          "servicediscovery:ListNamespaces"
        ]
        Resource = "*"
      }
    ]
  })
}

# Agent Task Definition (only for tail sampling)
resource "aws_ecs_task_definition" "agent" {
  count                    = var.deployment_type == "tail-sampling" ? 1 : 0
  family                   = "${local.name_prefix}opentelemetry-agent"
  cpu                      = max(var.memory, 256)
  memory                   = var.memory
  requires_compatibilities = ["EC2"]
  network_mode             = "host"
  execution_role_arn       = local.execution_role_arn
  task_role_arn            = local.execution_role_arn

  volume {
    name      = "hostfs"
    host_path = "/var/lib/docker/"
  }

  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }

  container_definitions = jsonencode([{
    name : "coralogix-otel-agent"
    networkMode : "host"
    image : local.container_image
    essential : true
    portMappings : [
      {
        containerPort : 4317
        hostPort : 4317
        appProtocol : "grpc"
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
    environment : [
      {
        name : "CORALOGIX_DOMAIN"
        value : local.coralogix_domain
      },
      {
        name : "CORALOGIX_PRIVATE_KEY"
        value : var.api_key
      },
      {
        name : "APP_NAME"
        value : var.default_application_name
      },
      {
        name : "SUB_SYS"
        value : var.default_subsystem_name
      },
      {
        name : "MY_POD_IP"
        value : "0.0.0.0"
      }
    ],
    command : [
      "--config",
      "s3://${var.s3_config_bucket}.s3.${data.aws_region.current.id}.amazonaws.com/${var.agent_s3_config_key}"
    ],
    healthCheck : var.health_check_enabled ? {
      command : ["/healthcheck"]
      startPeriod : var.health_check_start_period
      interval : var.health_check_interval
      timeout : var.health_check_timeout
      retries : var.health_check_retries
    } : null,
    logConfiguration : {
      logDriver : "json-file"
    }
  }])

  tags = local.tags
}

# Gateway Task Definition
resource "aws_ecs_task_definition" "gateway" {
  family                   = "opentelemetry-gateway"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = local.execution_role_arn
  task_role_arn            = local.execution_role_arn

  container_definitions = jsonencode([{
    Name : "coralogix-otel-gateway"
    Image : local.container_image
    Command : [
      "--config",
      "s3://${var.s3_config_bucket}.s3.${data.aws_region.current.id}.amazonaws.com/${var.gateway_s3_config_key}"
    ]
    Cpu : 0
    Memory : var.memory
    Essential : true
    Privileged : true

    PortMappings : [
      {
        ContainerPort : 4317
        Name : "grpc"
        Protocol : "tcp"
        AppProtocol : "grpc"
      },
      {
        ContainerPort : 4318
        Name : "http"
        Protocol : "tcp"
      },
      {
        ContainerPort : 8888
        Name : "metrics"
        Protocol : "tcp"
      },
      {
        ContainerPort : 1777
        Name : "pprof"
        Protocol : "tcp"
      }
    ]

    Environment : [
      {
        Name : "CORALOGIX_DOMAIN"
        Value : local.coralogix_domain
      },
      {
        Name : "CORALOGIX_PRIVATE_KEY"
        Value : var.api_key
      },
      {
        Name : "APP_NAME"
        Value : var.default_application_name
      },
      {
        Name : "SUB_SYS"
        Value : var.default_subsystem_name
      },
      {
        Name : "MY_POD_IP"
        Value : "0.0.0.0"
      }
    ]

    HealthCheck : var.health_check_enabled ? {
      Command : ["/healthcheck"]
      StartPeriod : var.health_check_start_period
      Interval : var.health_check_interval
      Timeout : var.health_check_timeout
      Retries : var.health_check_retries
    } : null

    LogConfiguration : {
      LogDriver : "awslogs"
      Options : {
        "awslogs-group" : "/ecs/opentelemetry-gateway"
        "awslogs-region" : data.aws_region.current.id
        "awslogs-stream-prefix" : "ecs"
        "mode" : "non-blocking"
        "awslogs-create-group" : "true"
        "max-buffer-size" : "25m"
      }
    }
  }])

  tags = local.tags
}

# Receiver Task Definition (only for central cluster)
resource "aws_ecs_task_definition" "receiver" {
  count                    = var.deployment_type == "central-cluster" ? 1 : 0
  family                   = "opentelemetry-receiver"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = local.execution_role_arn
  task_role_arn            = local.execution_role_arn

  container_definitions = jsonencode([{
    Name : "coralogix-otel-receiver"
    Image : local.container_image
    Command : [
      "--config",
      "s3://${var.s3_config_bucket}.s3.${data.aws_region.current.id}.amazonaws.com/${var.receiver_s3_config_key}"
    ]
    Cpu : 0
    Memory : var.memory
    Essential : true
    Privileged : true

    PortMappings : [
      {
        ContainerPort : 4317
        Name : "grpc"
        Protocol : "tcp"
        AppProtocol : "grpc"
      },
      {
        ContainerPort : 4318
        Name : "http"
        Protocol : "tcp"
      },
      {
        ContainerPort : 8888
        Name : "metrics"
        Protocol : "tcp"
      },
      {
        ContainerPort : 1777
        Name : "pprof"
        Protocol : "tcp"
      }
    ]

    Environment : [
      {
        Name : "CORALOGIX_DOMAIN"
        Value : local.coralogix_domain
      },
      {
        Name : "CORALOGIX_PRIVATE_KEY"
        Value : var.api_key
      },
      {
        Name : "APP_NAME"
        Value : var.default_application_name
      },
      {
        Name : "SUB_SYS"
        Value : var.default_subsystem_name
      },
      {
        Name : "MY_POD_IP"
        Value : "0.0.0.0"
      }
    ]

    HealthCheck : var.health_check_enabled ? {
      Command : ["/healthcheck"]
      StartPeriod : var.health_check_start_period
      Interval : var.health_check_interval
      Timeout : var.health_check_timeout
      Retries : var.health_check_retries
    } : null

    LogConfiguration : {
      LogDriver : "awslogs"
      Options : {
        "awslogs-group" : "/ecs/opentelemetry-receiver"
        "awslogs-region" : data.aws_region.current.id
        "awslogs-stream-prefix" : "ecs"
        "mode" : "non-blocking"
        "awslogs-create-group" : "true"
        "max-buffer-size" : "25m"
      }
    }
  }])

  tags = local.tags
}

# Agent Service (only for tail sampling)
resource "aws_ecs_service" "agent" {
  count                              = var.deployment_type == "tail-sampling" ? 1 : 0
  name                               = "${local.name_prefix}coralogix-otel-agent"
  cluster                            = var.ecs_cluster_name
  task_definition                    = aws_ecs_task_definition.agent[0].arn
  launch_type                        = "EC2"
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
  propagate_tags          = "SERVICE"

  tags = local.tags
}

# Gateway Service
resource "aws_ecs_service" "gateway" {
  name            = "${local.name_prefix}coralogix-otel-gateway"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.gateway.arn
  launch_type     = "EC2"
  desired_count   = var.gateway_task_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.gateway.arn
  }

  deployment_controller {
    type = "ECS"
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  tags = local.tags
}

# Receiver Service (only for central cluster)
resource "aws_ecs_service" "receiver" {
  count           = var.deployment_type == "central-cluster" ? 1 : 0
  name            = "${local.name_prefix}coralogix-otel-receiver"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.receiver[0].arn
  launch_type     = "EC2"
  desired_count   = var.receiver_task_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.receiver[0].arn
  }

  deployment_controller {
    type = "ECS"
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  tags = local.tags
}
