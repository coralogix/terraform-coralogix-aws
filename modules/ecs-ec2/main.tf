locals {
  name = "coralogix-otel-agent"
  # KMS key ID from Secrets Manager secret (when customer-managed). Null when api_key_secret_kms_key_arn provided (skips lookup).
  _secret_kms_key_id = try(data.aws_secretsmanager_secret.api_key[0].kms_key_id, null)
  # Use provided ARN or resolve via aws_kms_key data source (handles aliases; IAM kms:Decrypt requires key ARN, not alias)
  secrets_kms_key_arn = (var.api_key_secret_kms_key_arn != null && var.api_key_secret_kms_key_arn != "") ? var.api_key_secret_kms_key_arn : try(data.aws_kms_key.secret_key[0].arn, null)
  tags = merge(
    {
      "ecs:taskDefinition:createdFrom" = "terraform"
    },
    var.tags
  )
  coralogix_region_domain_map = module.locals_variables.coralogix_domains
  coralogix_domain            = var.task_definition_arn == null ? coalesce(var.custom_domain, local.coralogix_region_domain_map[var.coralogix_region]) : null

  use_supervised_image     = var.supervisor_enabled
  s3_config_bucket         = var.s3_config_bucket == null ? "" : var.s3_config_bucket
  s3_config_key            = var.s3_config_key == null ? "" : var.s3_config_key
  s3_supervisor_config_key = var.s3_supervisor_config_key == null ? "" : var.s3_supervisor_config_key
  execution_role_arn       = var.task_execution_role_arn != null ? var.task_execution_role_arn : try(aws_iam_role.otel_task_execution_role_s3[0].arn, null)
  task_role_arn            = var.task_role_arn != null ? var.task_role_arn : try(aws_iam_role.otel_task_role_s3[0].arn, null)

  collector_config = <<-YAML
    receivers:
      nop:

    exporters:
      nop:

    extensions:
      health_check:
        endpoint: "localhost:13133"

    service:
      extensions:
        - health_check
      telemetry:
        logs:
          encoding: json
      pipelines:
        traces:
          receivers: [nop]
          exporters: [nop]
        metrics:
          receivers: [nop]
          exporters: [nop]
        logs:
          receivers: [nop]
          exporters: [nop]
  YAML

  supervisor_config = <<-YAML
    server:
      endpoint: "https://ingress.$${env:CORALOGIX_DOMAIN}/opamp/v1"
      headers:
        Authorization: "Bearer $${env:CORALOGIX_PRIVATE_KEY}"
      tls:
        insecure_skip_verify: false

    capabilities:
      reports_effective_config: true
      reports_own_metrics: true
      reports_own_logs: true
      reports_own_traces: true
      reports_health: true
      accepts_remote_config: true
      reports_remote_config: true

    agent:
      executable: /cdot
      passthrough_logs: true
      config_files:
        - /otel-config/collector-config.yaml

    storage:
      directory: /etc/otelcol-contrib/supervisor-data/

    telemetry:
      logs:
        level: info
  YAML

  config_loader_command = <<-SH
    set -e
    if [ -n "$S3_CONFIG_BUCKET" ] && [ -n "$S3_CONFIG_KEY" ]; then
      aws s3 cp "s3://$S3_CONFIG_BUCKET/$S3_CONFIG_KEY" /otel-config/collector-config.yaml
    elif [ "$SUPERVISOR_ENABLED" = "true" ]; then
      printf '%s\n' "$COLLECTOR_CONFIG" > /otel-config/collector-config.yaml
    else
      echo "s3_config_bucket and s3_config_key are required in collector mode" >&2
      exit 1
    fi

    if [ "$SUPERVISOR_ENABLED" = "true" ]; then
      if [ -n "$S3_CONFIG_BUCKET" ] && [ -n "$S3_SUPERVISOR_CONFIG_KEY" ]; then
        aws s3 cp "s3://$S3_CONFIG_BUCKET/$S3_SUPERVISOR_CONFIG_KEY" /otel-config/supervisor.yaml
      else
        printf '%s\n' "$SUPERVISOR_CONFIG" > /otel-config/supervisor.yaml
      fi
    fi
  SH

  collector_command = local.use_supervised_image ? "exec /opampsupervisor -config /otel-config/supervisor.yaml" : "exec /cdot --config /otel-config/collector-config.yaml"
}

module "locals_variables" {
  source           = "../locals_variables"
  integration_type = "ecs-ec2"
  random_string    = random_string.id.result
}

data "aws_caller_identity" "current" {}

# Lookup secret metadata for KMS key ID. Skipped when api_key_secret_kms_key_arn is set (avoids DescribeSecret on deploy role).
data "aws_secretsmanager_secret" "api_key" {
  count = var.task_definition_arn == null && var.task_execution_role_arn == null && var.use_api_key_secret && var.api_key_secret_arn != null && (var.api_key_secret_kms_key_arn == null || var.api_key_secret_kms_key_arn == "") ? 1 : 0
  arn   = var.api_key_secret_arn
}

# Resolve KMS key ID or alias to key ARN (IAM kms:Decrypt requires key ARN, not alias). Skipped when api_key_secret_kms_key_arn is set (avoids DescribeKey on deploy role).
data "aws_kms_key" "secret_key" {
  count  = var.task_definition_arn == null && var.task_execution_role_arn == null && var.use_api_key_secret && var.api_key_secret_arn != null && (var.api_key_secret_kms_key_arn == null || var.api_key_secret_kms_key_arn == "") && (local._secret_kms_key_id == null ? false : (local._secret_kms_key_id != "" && !startswith(local._secret_kms_key_id, "alias/aws/secretsmanager"))) ? 1 : 0
  key_id = local._secret_kms_key_id
}

resource "random_string" "id" {
  length  = 7
  lower   = true
  numeric = true
  upper   = false
  special = false
}

# ECS task execution role (created when the module manages the task definition and no custom role is provided)
resource "aws_iam_role" "otel_task_execution_role_s3" {
  count = var.task_definition_arn == null && var.task_execution_role_arn == null ? 1 : 0
  name  = "${local.name}-${random_string.id.result}-task-execution-role-s3"

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

resource "aws_iam_role_policy_attachment" "otel_task_execution_role_s3_policy" {
  count      = var.task_definition_arn == null && var.task_execution_role_arn == null ? 1 : 0
  role       = aws_iam_role.otel_task_execution_role_s3[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Secrets Manager access for API key (when use_api_key_secret, api_key_secret_arn set, and module creates execution role)
# Includes kms:Decrypt when secret uses customer-managed KMS key (required for ECS to resolve the secret)
resource "aws_iam_role_policy" "otel_task_execution_role_secrets" {
  count = var.task_definition_arn == null && var.task_execution_role_arn == null && var.use_api_key_secret && var.api_key_secret_arn != null ? 1 : 0
  name  = "SecretsManagerAccess"
  role  = aws_iam_role.otel_task_execution_role_s3[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect   = "Allow"
          Action   = ["secretsmanager:GetSecretValue"]
          Resource = var.api_key_secret_arn
        }
      ],
      # kms:Decrypt required when secret uses customer-managed KMS key
      local.secrets_kms_key_arn != null ? [
        {
          Effect   = "Allow"
          Action   = ["kms:Decrypt"]
          Resource = local.secrets_kms_key_arn
        }
      ] : []
    )
  })
}

# IAM Role for task runtime S3 access (created when module creates task definition and no custom task role provided)
resource "aws_iam_role" "otel_task_role_s3" {
  count = var.task_definition_arn == null && var.task_role_arn == null ? 1 : 0
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
  count = var.task_definition_arn == null && var.task_role_arn == null ? 1 : 0
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
        Resource = "arn:aws:s3:::${local.s3_config_bucket}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${local.s3_config_bucket}"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "coralogix_otel_agent" {
  count                    = var.task_definition_arn == null ? 1 : 0
  family                   = "${local.name}-${random_string.id.result}"
  cpu                      = max(var.memory, 256)
  memory                   = var.memory
  requires_compatibilities = ["EC2"]
  network_mode             = "host"
  execution_role_arn       = local.execution_role_arn
  task_role_arn            = local.task_role_arn

  volume {
    name = "otel-config"
  }
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
  container_definitions = jsonencode([
    {
      name              = "config-loader"
      image             = "public.ecr.aws/aws-cli/aws-cli:2.28.17"
      essential         = false
      memoryReservation = 32
      entryPoint        = ["sh", "-c"]
      command           = [local.config_loader_command]
      environment = concat(
        [
          {
            name  = "SUPERVISOR_ENABLED"
            value = tostring(var.supervisor_enabled)
          },
          {
            name  = "S3_CONFIG_BUCKET"
            value = local.s3_config_bucket
          },
          {
            name  = "S3_CONFIG_KEY"
            value = local.s3_config_key
          },
          {
            name  = "S3_SUPERVISOR_CONFIG_KEY"
            value = local.s3_supervisor_config_key
          }
        ],
        local.use_supervised_image ? [
          {
            name  = "COLLECTOR_CONFIG"
            value = local.collector_config
          },
          {
            name  = "SUPERVISOR_CONFIG"
            value = local.supervisor_config
          }
        ] : []
      )
      mountPoints = [
        {
          sourceVolume  = "otel-config"
          containerPath = "/otel-config"
        }
      ]
    },
    {
      name       = local.name
      image      = local.use_supervised_image ? "${var.supervised_image_repository}:${var.supervised_image_version}" : "${var.image}:${coalesce(var.image_version, "v0.5.10")}"
      essential  = true
      privileged = true
      entryPoint = ["sh", "-c"]
      command    = [local.collector_command]
      dependsOn = [
        {
          containerName = "config-loader"
          condition     = "SUCCESS"
        }
      ]
      portMappings = [
        {
          containerPort = 4317
          hostPort      = 4317
          appProtocol   = "grpc"
        },
        {
          containerPort = 4318
          hostPort      = 4318
        },
        {
          containerPort = 8888
          hostPort      = 8888
        },
        {
          containerPort = 13133
          hostPort      = 13133
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "otel-config"
          containerPath = "/otel-config"
          readOnly      = true
        },
        {
          sourceVolume  = "hostfs"
          containerPath = "/hostfs/var/lib/docker/"
          readOnly      = true
        },
        {
          sourceVolume  = "docker-socket"
          containerPath = "/var/run/docker.sock"
        }
      ]
      environment = concat(
        [
          {
            name  = "CORALOGIX_DOMAIN"
            value = local.coralogix_domain
          },
          {
            name  = "MY_POD_IP"
            value = "0.0.0.0"
          }
        ],
        var.use_api_key_secret != true ? [
          {
            name  = "CORALOGIX_PRIVATE_KEY"
            value = var.api_key
          }
        ] : []
      )
      secrets = var.use_api_key_secret == true ? [
        {
          name      = "CORALOGIX_PRIVATE_KEY"
          valueFrom = var.api_key_secret_arn
        }
      ] : []
      healthCheck = var.health_check_enabled ? {
        command     = ["CMD", "/healthcheck"]
        startPeriod = var.health_check_start_period
        interval    = var.health_check_interval
        timeout     = var.health_check_timeout
        retries     = var.health_check_retries
      } : null
      logConfiguration = {
        logDriver = "json-file"
      }
    }
  ])
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
