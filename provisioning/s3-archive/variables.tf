variable "coralogix_region" {
  type        = string
  description = "The region that you want to create the buckets in"
}

variable "by_pass_valid_rergion" {
  type        = bool
  description = "Use to by pass the coralogix_region"
  default     = false
}

variable "log_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create for the Logs archive (Leave empty if not needed)"
  default     = ""
}

variable "metrics_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create for the metrics archive (Leave empty if not needed)"
  default     = ""
}

variable "log_kms_arn" {
  type        = string
  description = "The arn for the logs bucket KMS"
  default     = ""
}

variable "metrics_kms_arn" {
  type        = string
  description = "The arn for the metrics bucket KMS"
  default     = ""
}