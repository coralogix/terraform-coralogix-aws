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

# Read back AFTER the staging copy, so the Lambda sees the object that was just written
# rather than the one that was there before.
#
# Its version_id is what makes an upgrade actually redeploy. With the default empty
# source_code_version the staged key never changes, so bucket and key alone give the
# Lambda nothing to react to: Terraform would restage the artifact and leave the
# function running the previous binary. depends_on is what forces the read to happen
# after the copy; it also defers it to apply, so the Lambda's package shows as known
# after apply whenever the copy re-runs.
#
# Buckets without versioning return no version, and the Lambda then behaves as it did
# before -- see the custom_s3_bucket note in README.md.
data "aws_s3_object" "staged_artifact" {
  # Only where the key cannot change on its own. A pinned source_code_version puts the
  # version in the key, so the Lambda already has something to react to and this read
  # would buy nothing -- while still costing the provider identity s3:GetObject on a
  # bucket it may only be permitted to write to.
  count = var.custom_s3_bucket == "" || var.source_code_version != "" ? 0 : 1

  bucket = var.custom_s3_bucket
  key    = local.artifact_key

  depends_on = [null_resource.s3_bucket_copy]
}
