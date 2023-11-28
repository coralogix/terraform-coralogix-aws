data "aws_region" "current" {}

locals {
  name = "coralogix-monitor-demo"
  coralogix_region_domain_map = {
    "europe"    = "coralogix.com"
    "europe2"   = "eu2.coralogix.com"
    "india"     = "coralogix.in"
    "singapore" = "coralogixsg.com"
    "us"        = "coralogix.us"
    "us2"       = "cx498.coralogix.com"
    "custom"    = null
  }
  coralogix_domain      = coalesce(var.custom_domain, local.coralogix_region_domain_map[lower(var.coralogix_region)])
  otel_config_file_path = coalesce(var.otel_config_file, "${path.module}/otel_ecs_ec2_win.config.yaml")
  otel_config           = templatefile(local.otel_config_file_path, {})
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "${local.name}-ecs-task-execution-role"
  path = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs_awslogs_policy" {
  name = "${local.name}-ecs-awslogs-policy"
  role = aws_iam_role.ecsTaskExecutionRole.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/ecs/*"
      },
    ]
  })
}

resource "aws_ecs_task_definition" "demo_task_definition" {
  family                   = "${local.name}-ec2-windows"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  volume {
    name      = "hostfs"
    host_path = "C:\\"
  }
  tags = {
    "ecs:taskDefinition:createdFrom" = "terraform"
  }
  container_definitions = templatefile("${path.module}/container_definitions.tftpl.json",{
        region           = data.aws_region.current.name
        otel_image       = var.otel_image
        app_image        = var.app_image
        coralogix_domain = local.coralogix_domain,
        application_name = var.application_name,
        subsystem_name   = var.subsystem_name,
        api_key          = var.api_key
        otel_config      = local.otel_config
    }
  )
}

resource "aws_ecs_service" "demo_service" {
  name                               = "${local.name}-service"
  cluster                            = var.ecs_cluster_name
  launch_type                        = "EC2"
  task_definition                    = aws_ecs_task_definition.demo_task_definition.arn
  scheduling_strategy                = "REPLICA"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  desired_count                      = 1
  enable_ecs_managed_tags = true
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
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
  }
}
