data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_subnet" "subnet" {
  count = (var.store_api_key_in_secrets_manager || local.api_key_is_arn) && var.subnet_ids != null ? 1 : 0
  id    = var.subnet_ids[0]
}

data "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups
  name     = each.key
}

data "aws_s3_bucket" "this" {
  for_each = local.s3_bucket_names
  bucket   = each.value
}

data "aws_s3_bucket" "dlq_bucket" {
  count  = var.enable_dlq ? 1 : 0
  bucket = var.dlq_s3_bucket
}

data "aws_sns_topic" "sns_topic" {
  count = local.sns_enable ? 1 : 0
  name  = var.sns_topic_name
}

data "aws_sqs_queue" "name" {
  count = var.sqs_name != null ? 1 : 0
  name  = var.sqs_name
}

data "aws_kinesis_stream" "kinesis_stream" {
  count = var.kinesis_stream_name != null ? 1 : 0
  name  = var.kinesis_stream_name
}

data "aws_iam_policy_document" "topic" {
  count = (local.sns_enable || var.sqs_name != null) && local.is_s3_integration ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = local.sns_enable ? ["SNS:Publish"] : ["SQS:SendMessage"]
    resources = local.sns_enable ? ["${local.arn_prefix}:sns:*:*:${data.aws_sns_topic.sns_topic[count.index].name}"] : ["${local.arn_prefix}:sqs:*:*:${data.aws_sqs_queue.name[count.index].name}"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [one(values(data.aws_s3_bucket.this)).arn]
    }
  }
}

data "aws_iam_policy" "AWSLambdaMSKExecutionRole" {
  count = var.msk_cluster_arn != null ? 1 : 0
  arn   = "${local.arn_prefix}:iam::aws:policy/service-role/AWSLambdaMSKExecutionRole"
}

data "aws_iam_role" "LambdaExecutionRole" {
  count = var.execution_role_name != null ? 1 : 0
  name  = var.execution_role_name
}

data "aws_partition" "current" {}
