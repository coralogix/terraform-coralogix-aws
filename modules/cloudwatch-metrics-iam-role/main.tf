terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

locals {
  coralogix_environment = {
    dev = {
      id          = "233273809180"
      role_suffix = "dev01"
    },
    staging = {
      id          = "233221153619"
      role_suffix = "stg1"
    },
    EU1 = {
      id          = "625240141681"
      role_suffix = "eu1"
    },
    EU2 = {
      id          = "625240141681"
      role_suffix = "eu2"
    },
    AP1 = {
      id          = "625240141681"
      role_suffix = "ap1"
    },
    AP2 = {
      id          = "625240141681"
      role_suffix = "ap2"
    },
    AP3 = {
      id          = "025066248247"
      role_suffix = "ap3"
    },
    US1 = {
      id          = "625240141681"
      role_suffix = "us1"
    },
    US2 = {
      id          = "739076534691"
      role_suffix = "us2"
    },
  }

  # Determine the Coralogix caller AWS Account ID:
  effective_aws_account_id = var.custom_coralogix_region != "" ? var.custom_coralogix_region : local.coralogix_environment[var.coralogix_region].id

  # Retrieve the Coralogix AWS IAM Role suffix based on the region mapping:
  effective_role_suffix = lower(local.coralogix_environment[var.coralogix_region].role_suffix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${local.effective_aws_account_id}:role/coralogix-ingestion-${local.effective_role_suffix}"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "${var.external_id_secret}@${var.coralogix_company_id}"
          }
        }
      }
    ]
  })

  inline_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "tag:GetResources",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "apigateway:GET",
          "autoscaling:DescribeAutoScalingGroups",
          "aps:ListWorkspaces",
          "dms:DescribeReplicationInstances",
          "dms:DescribeReplicationTasks",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeSpotFleetRequests",
          "ec2:DescribeInstanceTypes",
          "storagegateway:ListGateways",
          "storagegateway:ListTagsForResource",
          "rds:DescribeDbInstances",
          "rds:DescribeReservedDbInstances",
          "rds:ListTagsForResource",
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "ecs:ListServices",
          "ecs:DescribeServices",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances",
          "elasticache:DescribeCacheClusters",
          "elasticache:ListTagsForResource"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  description        = "AWS IAM Role to allow Coralogix to collect metrics"
  assume_role_policy = local.assume_role_policy
}

resource "aws_iam_role_policy" "this" {
  name   = "CoralogixMetricsPolicy"
  role   = aws_iam_role.this.id
  policy = local.inline_policy
}
