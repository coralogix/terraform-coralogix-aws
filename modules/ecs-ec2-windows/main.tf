locals {
  name = "coralogix-otel-agent"
  tags = merge(
    {
      "ecs:taskDefinition:createdFrom" = "terraform"
    },
    var.tags
  )
  coralogix_region_domain_map = module.locals_variables.coralogix_domains
  coralogix_domain            = var.coralogix_region == "custom" ? var.custom_domain : coalesce(var.custom_domain, local.coralogix_region_domain_map[var.coralogix_region])

  otel_template_vars = {
    coralogix_domain   = local.coralogix_domain
    application_name   = var.default_application_name
    subsystem_name     = var.default_subsystem_name
    EnableHeadSampler  = tostring(var.enable_head_sampler)
    EnableSpanMetrics  = tostring(var.enable_span_metrics)
    EnableTracesDB     = tostring(var.enable_traces_db)
    SamplingPercentage = var.sampling_percentage
    SamplerMode        = var.sampler_mode
  }

  otel_config = templatefile("${path.module}/otel_config.tftpl.yaml", local.otel_template_vars)

  # Windows tasks need execution role for ECR pull and CloudWatch Logs (awslogs). Use provided or create default.
  execution_role_arn = var.task_execution_role_arn != null ? var.task_execution_role_arn : aws_iam_role.otel_task_execution[0].arn

  # Determine command based on config source (Windows collector with profiles support)
  container_command = var.config_source == "s3" ? ["--config", "s3://${var.s3_config_bucket}.s3.${data.aws_region.current.id}.amazonaws.com/${var.s3_config_key}", "--feature-gates=service.profilesSupport"] : ["--config", "env:OTEL_CONFIG", "--feature-gates=service.profilesSupport"]

  # Determine which task role to use (for S3 config at runtime)
  task_role_arn = var.task_role_arn != null ? var.task_role_arn : (
    var.config_source == "s3" ? aws_iam_role.otel_task_role_s3[0].arn : null
  )

  # CloudWatch log group: use provided name or create one
  log_group_name = var.cloudwatch_log_group_name != null ? var.cloudwatch_log_group_name : aws_cloudwatch_log_group.otel_agent[0].name
}

module "locals_variables" {
  source           = "../locals_variables"
  integration_type = "ecs-ec2-windows"
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

# CloudWatch log group for OTEL agent (only when not provided)
resource "aws_cloudwatch_log_group" "otel_agent" {
  count             = var.cloudwatch_log_group_name == null ? 1 : 0
  name              = "/ecs/${local.name}-${random_string.id.result}"
  retention_in_days  = var.cloudwatch_log_retention_days
  tags              = local.tags
}

# Default task execution role (ECR pull + CloudWatch Logs) when not provided
resource "aws_iam_role" "otel_task_execution" {
  count = var.task_execution_role_arn == null ? 1 : 0
  name  = "${local.name}-${random_string.id.result}-task-execution"

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

resource "aws_iam_role_policy_attachment" "otel_task_execution" {
  count      = var.task_execution_role_arn == null ? 1 : 0
  role       = aws_iam_role.otel_task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for task runtime S3 access (only when config_source=s3 AND no custom task role provided)
resource "aws_iam_role" "otel_task_role_s3" {
  count = (var.config_source == "s3" && var.task_role_arn == null) ? 1 : 0
  name  = "${local.name}-${random_string.id.result}-task-role-s3"

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

resource "aws_iam_role_policy" "otel_task_role_s3_s3_policy" {
  count = (var.config_source == "s3" && var.task_role_arn == null) ? 1 : 0
  name  = "S3ReadAccess"
  role  = aws_iam_role.otel_task_role_s3[0].id

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

resource "aws_ecs_task_definition" "coralogix_otel_agent" {
  count                    = var.task_definition_arn == null ? 1 : 0
  family                   = "${local.name}-${random_string.id.result}"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = local.execution_role_arn
  task_role_arn            = local.task_role_arn

  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2022_CORE"
    cpu_architecture        = "X86_64"
  }

  volume {
    name      = "hostfs"
    host_path = "C:\\"
  }

  volume {
    name      = "programdata"
    host_path = "C:\\ProgramData\\Amazon\\ECS"
  }

  tags = merge(
    {
      Name = "${local.name}-${random_string.id.result}"
    },
    var.tags
  )

  container_definitions = jsonencode([{
    name       = local.name
    image      = "${var.image}:${var.image_version}"
    cpu        = var.cpu
    memory     = var.memory
    essential  = true
    privileged = false

    portMappings = [
      { containerPort = 4317, hostPort = 4317, appProtocol = "grpc" },
      { containerPort = 4318, hostPort = 4318 },
      { containerPort = 8888, hostPort = 8888 },
      { containerPort = 13133, hostPort = 13133 },
      { containerPort = 14250, hostPort = 14250 },
      { containerPort = 14268, hostPort = 14268 },
      { containerPort = 6831, hostPort = 6831, protocol = "udp" },
      { containerPort = 6832, hostPort = 6832, protocol = "udp" },
      { containerPort = 8125, hostPort = 8125, protocol = "udp" },
      { containerPort = 9411, hostPort = 9411 }
    ]

    mountPoints = [
      { sourceVolume = "hostfs", containerPath = "C:\\hostfs", readOnly = true },
      { sourceVolume = "programdata", containerPath = "C:\\ProgramData\\Amazon\\ECS", readOnly = true }
    ]

    environment = concat(
      [
        { name = "MY_POD_IP", value = "0.0.0.0" }
      ],
      var.config_source == "template" ? [{ name = "OTEL_CONFIG", value = local.otel_config }] : [],
      var.use_api_key_secret != true ? [{ name = "CORALOGIX_PRIVATE_KEY", value = var.api_key }] : []
    )

    secrets = concat(
      var.config_source == "parameter-store" ? [{ name = "OTEL_CONFIG", valueFrom = var.custom_config_parameter_store_name }] : [],
      var.use_api_key_secret == true ? [{ name = "CORALOGIX_PRIVATE_KEY", valueFrom = var.api_key_secret_arn }] : []
    )

    command = local.container_command

    healthCheck = var.health_check_enabled ? {
      command     = ["CMD-SHELL", "exit 0"]
      startPeriod = var.health_check_start_period
      interval    = var.health_check_interval
      timeout     = var.health_check_timeout
      retries     = var.health_check_retries
    } : null

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = local.log_group_name
        "awslogs-region"        = data.aws_region.current.id
        "awslogs-stream-prefix" = "ecs"
      }
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

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_registry_arn != null ? [1] : []
    content {
      registry_arn   = var.service_discovery_registry_arn
      container_name = local.name
    }
  }

  enable_ecs_managed_tags = true

  tags = merge(
    {
      Name = "${local.name}-${random_string.id.result}"
    },
    var.tags
  )
}
