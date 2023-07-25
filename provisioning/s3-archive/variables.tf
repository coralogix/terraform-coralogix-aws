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

variable "log_kms_enalbed" {
  type        = bool
  description = "whether to use KMS for the logs bucket or not"
  default     = false
}

variable "log_kms_arn" {
  type        = string
  description = "The arn for the logs bucket KMS"
  default     = ""
}

variable "metrics_kms_enalbed" {
  type        = bool
  description = "whether to use KMS for the metrics bucket or not"
  default     = false
}

variable "metrics_kms_arn" {
  type        = string
  description = "The arn for the metrics bucket KMS"
  default     = ""
}