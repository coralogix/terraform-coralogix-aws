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

variable "logs_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create for the logs archive (Leave empty if not needed)"
  default     = null
}

variable "metrics_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create for the metrics archive (Leave empty if not needed)"
  default     = null
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

variable "logs_bucket_force_destroy" {
  type        = bool
  description = "force the metrics bucket to destroyed, even if there is data in it"
  default     = false
}

variable "metrics_bucket_force_destroy" {
  type        = bool
  description = "force the metrics bucket to destroyed, even if there is data in it"
  default     = false
}
