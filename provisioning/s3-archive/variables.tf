variable "coralogix_region" {
  type        = string
  description = "The region that you want to create the buckets in"
}

variable "bypass_valid_region" {
  type        = bool
  description = "Use to bypass the coralogix_region validation"
  default     = false
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