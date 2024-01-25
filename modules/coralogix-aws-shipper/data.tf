data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups
  name     = each.key
}
data "aws_s3_bucket" "this" {
  count  = var.s3_bucket_name == null ? 0 : 1
  bucket = var.s3_bucket_name
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
    resources = local.sns_enable ? ["arn:aws:sns:*:*:${data.aws_sns_topic.sns_topic[count.index].name}"] : ["arn:aws:sqs:*:*:${data.aws_sqs_queue.name[count.index].name}"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [data.aws_s3_bucket.this[0].arn]
    }
  }
}

data "aws_iam_policy" "AWSLambdaMSKExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaMSKExecutionRole"
}
