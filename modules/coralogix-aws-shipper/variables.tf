# Coralogix configuration
variable "coralogix_region" {
  description = "The Coralogix location region, possible options are [EU1, EU2, AP1, AP2, AP3, US1, US2]"
  type        = string
  validation {
    condition     = contains(["EU1", "EU2", "AP1", "AP2", "AP3", "US1", "US2", "Custom"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [EU1, EU2, AP1, AP2, AP3, US1, US2, Custom]."
  }
}

variable "custom_domain" {
  description = "Your Custom domain for the Coralogix account."
  type        = string
  default     = ""
}

variable "api_key" {
  description = "Your Coralogix Send Your Data - API Key which is used to validate your authenticity, This value can be a Coralogix API Key or an AWS Secret Manager ARN that holds the API Key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "application_name" {
  description = "The name of your application"
  type        = string
  default     = null
}

variable "subsystem_name" {
  description = "The subsystem name of your application"
  type        = string
  default     = null
}

# Integration S3/CloudTrail/VpcFlow/S3Csv configuration

variable "newline_pattern" {
  description = "The pattern for lines splitting"
  type        = string
  default     = ""
}

variable "blocking_pattern" {
  description = "The pattern for lines blocking"
  type        = string
  default     = ""
}

variable "sampling_rate" {
  description = "Send messages with specific rate"
  type        = number
  default     = 1
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to watch"
  type        = string
  default     = null
}

variable "s3_key_prefix" {
  description = "The AWS S3 path prefix to watch. This value is ignored when the SNSTopicArn parameter is provided."
  type        = string
  default     = null
}

variable "s3_key_suffix" {
  description = "The AWS S3 path suffix to watch. This value is ignored when the SNSTopicArn parameter is provided."
  type        = string
  default     = null
}

variable "cs_delimiter" {
  type        = string
  description = "The delimiter used in the CSV file to process This value is applied when the S3Csv integration type is selected"
  default     = ","
}

variable "custom_csv_header" {
  type        = string
  description = "List separated by cs delimiter of a new headers for your csv, the variable must be with the same delimiter as the cs_delimiter, for example if the cs_delimiter is \";\" then the value of the variable should be name;country;age so the new headers will be name, country, age"
  default     = null
}

variable "integration_info" {
  description = "Values of s3 integraion in case that you want to deploy more than one integration"
  type = map(object({
    s3_key_prefix                    = optional(string)
    s3_key_suffix                    = optional(string)
    application_name                 = string
    subsystem_name                   = string
    integration_type                 = string
    lambda_name                      = optional(string)
    newline_pattern                  = optional(string)
    blocking_pattern                 = optional(string)
    lambda_log_retention             = optional(number)
    api_key                          = string
    store_api_key_in_secrets_manager = optional(bool)
  }))
  default = null
}

# cloudwatch variables

variable "log_groups" {
  description = "The names of the CloudWatch log groups to watch"
  type        = list(string)
  default     = []
}

variable "log_group_prefix" {
  description = "Prefix of the CloudWatch log groups that will trigger the lambda"
  type        = list(string)
  default     = null
}

# kinesis variables 

variable "kinesis_stream_name" {
  description = "The name of Kinesis stream to subscribe to retrieving messages"
  type        = string
  default     = null
}

# MSK variables

variable "msk_cluster_arn" {
  description = "The ARN of the MSK cluster to subscribe to retrieving messages"
  type        = string
  default     = null
}

variable "msk_topic_name" {
  description = "List of names of the Kafka topic used to store records in your Kafka cluster ( [\"topic1\", \"topic2\",])"
  type        = list(any)
  default     = null
}

# Kafka variables

variable "kafka_brokers" {
  description = "Comma Delimited List of Kafka broker to connect to"
  type        = string
  default     = null
}

variable "kafka_topic" {
  description = "The name of the Kafka topic used to store records in your Kafka cluster"
  type        = string
  default     = null
}

variable "kafka_subnets_ids" {
  description = "List of Kafka subnets to use when connecting to Kafka"
  type        = list(string)
  default     = null
}

variable "kafka_security_groups" {
  description = "List of Kafka security groups to use when connecting to Kafka"
  type        = list(string)
  default     = null
}

# sqs variables

variable "sqs_name" {
  description = "The name of the SQS that you want watch"
  type        = string
  default     = null
}

# sns variables

variable "sns_topic_name" {
  description = "The name of your SNS topic"
  type        = string
  default     = ""
}

# vpc variables

variable "subnet_ids" {
  description = "ID of Subnet into which to deploy the integration"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "ID of the SecurityGroup into which to deploy the integration"
  type        = list(string)
  default     = null
}

variable "create_endpoint" {
  description = "Create a VPC endpoint for the lambda function to allow if access to the secret"
  type        = bool
  default     = false
}

# DLQ configuration

variable "enable_dlq" {
  description = "Enable Dead Letter Queue for the Lambda function"
  type        = bool
  default     = false
}

variable "dlq_retry_limit" {
  description = "The maximum number of times to retry the function execution in case of failure"
  type        = number
  default     = 3
}

variable "dlq_retry_delay" {
  description = "The delay in seconds between retries"
  type        = number
  default     = 900
}

variable "dlq_s3_bucket" {
  description = "The S3 bucket to store the DLQ failed messages after retry limit is reached"
  type        = string
  default     = null
}

# Lambda configuration

variable "memory_size" {
  description = "Lambda function memory limit"
  type        = number
  default     = 1024
}

variable "timeout" {
  description = "Lambda function timeout limit"
  type        = number
  default     = 300
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "provided.al2023"
  validation {
    condition     = contains(["provided.al2023", "provided.al2"], var.runtime)
    error_message = "The supported runtime are: [provided.al2023, provided.al2]."
  }
}

variable "cpu_arch" {
  description = "Lambda function CPU architecture"
  type        = string
  default     = "arm64"
  validation {
    condition     = contains(["arm64", "x86_64"], var.cpu_arch)
    error_message = "The CPU architecture must be one of these values: [arm64, x86_64]."
  }
}

variable "source_code_version" {
  description = "The source code for the shipper lambda version, the varible need to be in the formate of x.x.x and is only suppordet since version 1.0.8"
  type        = string
  default     = ""
}

# Integration Generic Config (Optional)

variable "notification_email" {
  description = "Failure notification email address"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "custom_s3_bucket" {
  description = "The name of the s3 bucket to save the lambda zip code in"
  type        = string
  default     = ""
}

variable "govcloud_deployment" {
  description = "Enable if you deploy the integration in govcloud"
  type        = bool
  default     = false
}

variable "lambda_name" {
  type        = string
  description = "The name of the lambda function"
  default     = null
}

variable "log_level" {
  type        = string
  description = "Log level for the Lambda function. Can be one of: INFO, WARN, ERROR, DEBUG"
  default     = "WARN"
  validation {
    condition     = contains(["INFO", "ERROR", "WARN", "DEBUG"], var.log_level)
    error_message = "The log leavel must be one of these values: [DEBUG, WARN, ERROR, INFO]."
  }
}

variable "lambda_log_retention" {
  description = "CloudWatch log retention days for logs generated by the Lambda function"
  type        = number
  default     = 5
}

variable "integration_type" {
  description = "the aws service that send the data to the s3"
  type        = string
  validation {
    condition     = contains(["CloudWatch", "CloudTrail", "VpcFlow", "S3", "S3Csv", "Sns", "Sqs", "Kinesis", "CloudFront", "MSK", "Kafka", "EcrScan", ""], var.integration_type)
    error_message = "The integration type must be: [CloudWatch, CloudTrail, VpcFlow, S3, S3Csv, Sns, Sqs, Kinesis, CloudFront, MSK, Kafka, EcrScan]."
  }
  default = "S3"
}

variable "store_api_key_in_secrets_manager" {
  description = "Store the API key in AWS Secrets Manager. ApiKeys are stored in secret manager \nby default. If this option is set to false, the ApiKey will appear in plain text as an \n environment variable in the lambda function console."
  type        = bool
  default     = true
}

variable "add_metadata" {
  description = "Add metadata to the log message. Expect comma-separated values. Options for S3 are bucket_name,key_name. For CloudWatch stream_name"
  default     = null
  type        = string
}

variable "custom_metadata" {
  default     = null
  description = "Add custom metadata to the log message. Expects comma separated values. Options are key1=value1,key2=value2 "
  type        = string
}

variable "lambda_assume_role_arn" {
  default     = null
  description = "The ARN of the role that the lambda function will assume."
  type        = string
}

variable "execution_role_name" {
  default     = null
  description = "The arn of a user defined role that will be used as the execution role for the lambda function."
  type        = string
}

variable "reserved_concurrent_executions" {
  default     = null
  description = "The number of concurrent executions that are reserved for this function, leave as default to use unreserved account concurrency"
  type        = number
}

# firehose metrics varialbe
variable "telemetry_mode" {
  description = "The telemetry mode for the shipper, i.e metrics or logs"
  type        = string
  default     = "logs"
  validation {
    condition     = contains(["logs", "metrics"], var.telemetry_mode)
    error_message = "The telemetry_mode must be one of these values: [logs, metrics]."
  }
}

variable "include_metric_stream_filter" {
  description = "List of inclusive metric filters. If you specify this parameter, the stream sends only the conditional metric names from the metric namespaces that you specify here. Leave empty to send all metrics"
  type = list(object({
    namespace    = string
    metric_names = list(string)
    })
  )
  default = []
}
