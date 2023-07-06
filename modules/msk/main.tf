terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " < 6.0 , >= 5.0 "
    }
  }
}

locals {
  endpoint_url = {
    "us" = {
      url = "ingress.coralogix.us"
    }
    "singapore" = {
      url = "ingress.coralogixsg.com"
    }
    "ireland" = {
      url = "ingress.coralogix.com"
    }
    "india" = {
      url = "ingress.coralogix.in"
    }
    "stockholm" = {
      url = "ingress.eu2.coralogix.com"
    }
  }
  tags = {
    terraform-module         = "msk-to-coralogix"
    terraform-module-version = "v0.0.1"
    managed-by               = "coralogix-terraform"
  }
  application_name = var.application_name == null ? "coralogix-${var.msk_stream}" : var.application_name
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

resource "aws_iam_role" "role_for_all" {
  name               = "role_for_${var.msk_stream}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "sns_publish_policy" {
  name        = "sns-publish-policy"
  description = "Allows Lambda function to publish to SNS topics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowPublish"
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.sns_topic.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns-publish-attach" {
  role       = aws_iam_role.role_for_all.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

data "aws_iam_policy" "AWSLambdaMSKExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaMSKExecutionRole"
}

data "aws_iam_policy" "SecretsManagerReadWrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "msk-role-policy-attach" {
  role = aws_iam_role.role_for_all.name
  for_each = toset([data.aws_iam_policy.AWSLambdaMSKExecutionRole.arn,
    data.aws_iam_policy.SecretsManagerReadWrite.arn,
    data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  ])
  policy_arn = each.key
}

resource "aws_sns_topic" "sns_topic" {
  display_name = "${module.lambda.lambda_function_name}-failure"
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  depends_on = [aws_sns_topic.sns_topic, module.lambdaSSM, module.lambda]
  count      = var.notification_email != null ? 1 : 0
  topic_arn  = aws_sns_topic.sns_topic.arn
  protocol   = "email"
  endpoint   = var.notification_email
}

resource "random_string" "this" {
  length  = 6
  special = false
}

module "lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.3.1"
  create                 = var.ssm_enable != "True" ? true : false
  function_name          = "Coralogix-MSK-${var.msk_stream}"
  description            = "Send data from Amazon MSK to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.sns_topic.arn
  environment_variables = {
    coralogix_url = var.custom_url != null ? var.custom_url : local.endpoint_url[var.coralogix_region].url
    private_key   = var.private_key
    app_name      = var.application_name
    sub_name      = var.subsystem_name
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.name}"
    key    = "msk.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_description                        = "Role for MSK Lambda Function."
  create_role                             = false
  lambda_role                             = aws_iam_role.role_for_all.arn
  create_current_version_allowed_triggers = false
  create_async_event_config               = true
  attach_async_event_policy               = true
}

module "lambdaSSM" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.3.1"
  create                 = var.ssm_enable == "True" ? true : false
  layers                 = [var.layer_arn]
  function_name          = "Coralogix-MSK-${var.msk_stream}"
  description            = "Send data from Amazon MSK to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.sns_topic.arn
  environment_variables = {
    coralogix_url           = var.custom_url != null ? var.custom_url : local.endpoint_url[var.coralogix_region].url
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/wrapper.sh"
    private_key             = "****"
    app_name                = var.application_name
    sub_name                = var.subsystem_name
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.name}"
    key    = "msk.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_description                        = "Role for MKS Lambda Function."
  create_role                             = false
  lambda_role                             = aws_iam_role.role_for_all.arn
  create_current_version_allowed_triggers = false
  create_async_event_config               = true
  attach_async_event_policy               = true
  attach_policy_statements                = true
  policy_statements = {
    access_secret_policy = {
      effect = "Allow"
      actions = [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecret"
      ]
      resources = ["*"]
    }
  }
}

resource "aws_lambda_event_source_mapping" "msk_event_mapping" {
  count             = var.ssm_enable == "True" ? 0 : 1
  event_source_arn  = var.msk_cluster_arn
  depends_on        = [module.lambda]
  function_name     = module.lambda.lambda_function_name
  starting_position = "LATEST"
  topics            = [var.topic]
}

resource "aws_lambda_event_source_mapping" "msk_event_mapping_ssm" {
  count             = var.ssm_enable == "True" ? 1 : 0
  event_source_arn  = var.msk_cluster_arn
  depends_on        = [module.lambdaSSM]
  function_name     = module.lambdaSSM.lambda_function_name
  starting_position = "LATEST"
  topics            = [var.topic]
}

resource "aws_secretsmanager_secret" "private_key_secret" {
  count       = var.ssm_enable == "True" ? 1 : 0
  depends_on  = [module.lambdaSSM]
  name        = "lambda/coralogix/${data.aws_region.this.name}/${module.lambdaSSM.lambda_function_name}"
  description = "Coralogix Send Your Data key Secret"
}

resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.ssm_enable == "True" ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.private_key_secret]
  secret_id     = aws_secretsmanager_secret.private_key_secret[count.index].id
  secret_string = var.private_key
}
