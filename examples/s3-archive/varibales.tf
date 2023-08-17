variable "coralogix_region" {
  type        = string
  description = "The region that you want to create the buckets in"
}

variable "bypass_valid_region" {
  type        = bool
  description = "Use to bypass the coralogix_region validation"
  default     = false
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
    "ap-south-1"         = "625240141681"
    "us-east-2"          = "625240141681"
    "us-west-2"          = "739076534691"
    "default"            = "625240141681"
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