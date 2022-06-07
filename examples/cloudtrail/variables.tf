variable "coralogix_region" {
  description = "The Coralogix location region, possible options are [Europe, Europe2, India, Singapore, US]"
  type        = string
  default     = "Europe"
}

variable "private_key" {
  description = "The Coralogix private key which is used to validate your authenticity"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to watch"
  type        = string
}
