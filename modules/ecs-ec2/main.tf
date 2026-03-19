locals {
  name = "coralogix-otel-agent"
  # KMS key ID from Secrets Manager secret (when customer-managed). Null for default aws/secretsmanager key.
  _secret_kms_key_id = try(data.aws_secretsmanager_secret.api_key[0].kms_key_id, null)
  # Resolve to key ARN via aws_kms_key data source (handles aliases; IAM kms:Decrypt requires key ARN, not alias)
  secrets_kms_key_arn = try(data.aws_kms_key.secret_key[0].arn, null)
  tags = merge(
    {
      "ecs:taskDefinition:createdFrom" = "terraform"
    },
    var.tags
  )
  coralogix_region_domain_map = module.locals_variables.coralogix_domains
  coralogix_domain            = var.task_definition_arn == null ? coalesce(var.custom_domain, local.coralogix_region_domain_map[var.coralogix_region]) : null

  execution_role_arn = var.task_execution_role_arn != null ? var.task_execution_role_arn : try(aws_iam_role.otel_task_execution_role_s3[0].arn, null)
  task_role_arn      = var.task_role_arn != null ? var.task_role_arn : try(aws_iam_role.otel_task_role_s3[0].arn, null)
}

module "locals_variables" {
  source           = "../locals_variables"
  integration_type = "ecs-ec2"
  random_string    = random_string.id.result
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "api_key" {
  count = var.task_definition_arn == null && var.task_execution_role_arn == null && var.use_api_key_secret && var.api_key_secret_arn != null ? 1 : 0
  arn   = var.api_key_secret_arn
}

# Resolve KMS key ID or alias to key ARN (IAM kms:Decrypt requires key ARN, not alias)
data "aws_kms_key" "secret_key" {
  count  = var.task_definition_arn == null && var.task_execution_role_arn == null && var.use_api_key_secret && var.api_key_secret_arn != null && (local._secret_kms_key_id == null ? false : (local._secret_kms_key_id != "" && !startswith(local._secret_kms_key_id, "alias/aws/secretsmanager"))) ? 1 : 0
  key_id = local._secret_kms_key_id
}

resource "random_string" "id" {
  length  = 7
  lower   = true
  numeric = true
  upper   = false
  special = false
}

# IAM Role for S3 access (created when module creates task definition and no custom execution role provided)
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

resource "aws_iam_role_policy" "otel_task_execution_role_s3_s3_policy" {
  count = var.task_definition_arn == null && var.task_execution_role_arn == null ? 1 : 0
  name  = "S3ReadAccess"
  role  = aws_iam_role.otel_task_execution_role_s3[0].id

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
        Resource = "arn:aws:s3:::${var.s3_config_bucket}/*"
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
  execution_role_arn       = local.execution_role_arn
  task_role_arn            = local.task_role_arn
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
    image : "${var.image}:${coalesce(var.image_version, "v0.5.10")}"
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
    environment : concat([
      {
        name : "CORALOGIX_DOMAIN"
        value : local.coralogix_domain
      },
      {
        name : "MY_POD_IP"
        value : "0.0.0.0"
      }
      ],
      var.use_api_key_secret != true ? [{
        name : "CORALOGIX_PRIVATE_KEY"
        value : var.api_key
    }] : []),
    secrets : var.use_api_key_secret == true ? [{
      name      : "CORALOGIX_PRIVATE_KEY"
      valueFrom : var.api_key_secret_arn
    }] : [],
    command : ["--config", "s3://${var.s3_config_bucket}.s3.${data.aws_region.current.id}.amazonaws.com/${var.s3_config_key}"],
    healthCheck : var.health_check_enabled ? {
      command     : ["/healthcheck"]
      startPeriod : var.health_check_start_period
      interval    : var.health_check_interval
      timeout     : var.health_check_timeout
      retries     : var.health_check_retries
    } : null,
    logConfiguration : {
      logDriver : "json-file"
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
  deployment_minimum_healthy_percent  = 0
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
