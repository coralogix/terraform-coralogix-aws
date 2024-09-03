variable "aws_region" {
  type        = string
  description = "The AWS region that you want to create the S3 bucket, Must be the same as the AWS region where your coralogix account is set"
  default     = ""
  validation {
    condition     = contains(["eu-west-1", "eu-north-1", "ap-southeast-1", "ap-southeast-3", "ap-south-1", "us-east-2", "us-west-2", ""], var.aws_region)
    error_message = "The aws region must be one of these values: [eu-west-1, eu-north-1, ap-southeast-1, ap-southeast-3, ap-south-1, us-east-2, us-west-2]."
  }
}

variable "bypass_valid_region" {
  type        = string
  description = "Use to bypass the aws_region validation, enter the AWS region that you want to create the S3 bucket in. When using this variable leave aws_region empty"
  default     = ""
}

variable "custom_coralogix_arn" {
  type        = string
  description = "In case that you want to use a custom coralogix arn enter the aws account id that you want to use"
  default     = ""
}

variable "coralogix_arn_mapping" {
  type = map(string)
  default = {
    "eu-west-1"          = "625240141681"
    "eu-north-1"         = "625240141681"
    "ap-southeast-1"     = "625240141681"
    "ap-southeast-3"     = "025066248247"
    "ap-south-1"         = "625240141681"
    "us-east-2"          = "625240141681"
    "us-west-2"          = "739076534691"
    ""                   = "625240141681"
  }
}

variable "logs_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create for the logs archive (Leave empty if not needed)"
  default     = ""
}

variable "metrics_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create for the metrics archive (Leave empty if not needed)"
  default     = ""
}

variable "logs_kms_arn" {
  type        = string
  description = "The arn for the logs bucket KMS"
  default     = ""
}

variable "metrics_kms_arn" {
  type        = string
  description = "The arn for the metrics bucket KMS"
  default     = ""
}

variable "aws_role_region"  {
  type = map
  default = {
      "eu-west-1"="eu1"
      "eu-north-1"="eu2"
      "ap-southeast-1"="ap2"
      "ap-south-1"="ap1"
      "us-east-2"="us1"
      "us-west-2"="us2"
      "ap-southeast-3"="ap3"
    }
  }
  