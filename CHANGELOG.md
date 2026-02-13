# Changelog

## v3.18.0
#### **coralogix-aws-shipper**
### 🐛 Bug Fix 🐛
- Fixed "Invalid count argument" error when providing a custom execution role created in the same Terraform configuration (#294).

### ⚠️ Breaking Change ⚠️
- The `random_string.lambda_role` resource has been renamed to `random_string.id` and no longer uses `count`. On upgrade, Terraform will plan to destroy the old resource and create a new one with a different suffix, triggering replacement of the IAM role (`Coralogix-lambda-role-*`), the DLQ (`coralogix-aws-shipper-dlq-*`), and firehose-related resources if `telemetry_mode = "metrics"`. To preserve the existing suffix and avoid resource churn, run the following state migration **before** applying:
  ```
  terraform state mv 'module.<name>.random_string.lambda_role[0]' 'module.<name>.random_string.id'
  ```

### 💡 Enhancements 💡
- Added `execution_role_arn` and `create_execution_role` variables for providing a custom Lambda execution role without breaking Terraform's plan-time dependency graph.
- Deprecated `execution_role_name` in favor of `execution_role_arn`.

## v3.16.0
#### **ecs-ec2**
### 🔒 Security Enhancements 🔒
- **Separated Execution and Task Roles**: Added `task_role_arn` variable to allow users to specify a dedicated task role separate from the execution role, following the principle of least privilege. This addresses security concerns where using the same IAM role for both execution and task operations could expose broader permissions than necessary at runtime.
- **Auto-created Minimal Task Role for S3**: When using S3 configuration source, the module now automatically creates a minimal task role with S3 read-only permissions if no custom `task_role_arn` is provided. This ensures the container can access the S3 configuration file at runtime while maintaining minimal permissions.
### 💡 Enhancements 💡
- Updated examples and documentation to demonstrate proper separation of execution and task roles for enhanced security.

## v3.15.1
#### **coralogix-aws-shipper**
### 💡 Enhancements 💡
- Added `log_group_filter_pattern` variable to allow customers to specify a filter pattern for CloudWatch log subscription filters. This enables filtering which logs are sent to Coralogix instead of forwarding all log events.

## v3.15.0
#### **firehose-metrics**
### 💡 Enhancements 💡
- Update IAM permissions accordingly to the latest version, featuring "Static Labels"

## v3.14.1
#### **resource-metadata**
### 🔧 Maintenance 🔧
- Update Node.js runtime version to 22.x.

## v3.14.0
#### **Multiple Modules**
### 🔧 Maintenance 🔧
- Migrate AWS provider version to `6.x` for all supported modules.
- Unify `random` provider version to `3.x` for all supported modules.

## v3.13.0
#### **firehose-metrics**
### 🔧 Maintenance 🔧
- Migrate Lambda ZIP package to the common serverless repo bucket `coralogix-serverless-repo`

## v3.12.0
#### **coralogix-aws-shipper**
### 💡 Enhancements 💡
- Added `batch_metrics` and `metrics_batch_max_size` inputs to control the Lambda `BATCH_METRICS` and `METRICS_BATCH_MAX_SIZE` environment variables for Firehose metric batching.

## v3.11.1
#### **coralogix-aws-shipper, resource-metadata**
### 🔧 Maintenance 🔧
### 🛑 Breaking changes 🛑
- Update AWS provider requirement to `>= 6.0` for both modules
  - **coralogix-aws-shipper**: AWS provider requirement updated from `>= 5.32.0` to `>= 6.0`
  - **resource-metadata**: AWS provider requirement updated from `>= 4.15.1, < 6.0` to `>= 6.0`
- **resource-metadata**: Update minimum Terraform version from `>= 0.13.1` to `>= 1.5.7`
- **resource-metadata**: Upgrade `terraform-aws-modules/eventbridge/aws` from v3.17.1 to v4.0.0

## v3.11.0
#### **firehose-metrics**
### Support StaticLabels parameter to match coralogix-aws-metrics integration

## v3.10.9
#### **coralogix-aws-shipper**
### 🔧 Maintenance 🔧
- Upgrade `terraform-aws-modules/lambda/aws` from v7.2.0 to v8.1.2 to eliminate remaining deprecated `data.aws_region.current.name` warnings from external dependency

## v3.10.8
#### **Multiple Modules**
### 🔧 Maintenance 🔧
- **Deprecated Attribute Update**: Replace deprecated `data.aws_region.*.name` with `data.aws_region.*.id` across all modules to eliminate deprecation warnings

## v3.10.7
#### **ecs-ec2**
### Add default values to default_application_name and default_subsystem_name

## v3.10.6
#### **ecs-ec2**
### Update env variable name

## v3.10.5 
#### **coralogix-aws-shipper**
### 💡 Enhancements 💡
- Added variable to disable the creation of `lambda_notification` and `sqs_notification` to manage it outside the module.

## v3.10.4 
#### **coralogix-aws-shipper**
### 💡 Enhancements 💡
- Added `create_sns_topic_policy` variable to allow users to preserve existing SNS topic policies when using SNS-based integrations (S3, CloudTrail, VpcFlow, CloudFront, S3Csv). Set to `false` to prevent the module from overwriting custom SNS topic policies.

## v3.10.3
#### **s3-archive**
### 💡 Enhancements 💡
- Added `logs_bucket_id` and `metrics_bucket_id` outputs.

## v3.10.2
#### **coralogix-aws-shipper**
### 💡 Enhancements 💡
- Added variable to disable the creation of `aws_s3_bucket_notification` to manage it outside the module.

## v3.10.1
#### **ecs-ec2-tail-sampling**
### 💡 Enhancements 💡
- **ecs-ec2-tail-sampling**: Added new ecs-ec2 tail sampling module
## v3.10.0
#### **ecs-ec2**
### 💡 Enhancements 💡
- **S3 Configuration Source**: Added support for using S3 as a configuration source for OpenTelemetry Collector
- **Flexible Execution Role Management**: Added support for both auto-created and custom execution roles for S3 configuration

## v3.9.1
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Fix `invalid value for statement_id` error when S3 bucket names contain dots by sanitizing bucket names in Lambda permission statement IDs in coralogix-aws-shipper
- Replace deprecated `data.aws_region.this.name` with `data.aws_region.this.id` to address deprecation warnings

## v3.9.0
#### **ecs-ec2**
### 💡 Enhancements 💡
- Added support for spanmetrics (enebaled by default) and traces/db configuration options in ECS-EC2 module
- Updated healthcheck configuration to use the correct `/healthcheck` binary path which was added to otel versions v0.4.2+

## v3.8.0
#### **resource-metadata** && **resource-metadata-sqs**
### 🧰 Bug fixes 🧰
- Set the module version to be < 6.0, and the eventbridge module to version `3.17.1`, as there is a conflict between versions
### 💡 Enhancements 💡
- Update coralogix endpoint to the new format `<coralogix env>.coralogix.com`

#### **coralogix-awss-hipper**, **firehose-logs**, **firehose-metrics**
### 💡 Enhancements 💡
- Add new variable `server_side_encryption`, to allow enabling server-side encryption for the Firehose.
- Update coralogix endpoint to the new format `<coralogix env>.coralogix.com`

### **S3-archive**
### 💡 Enhancements 💡
- Update metrics archive role to be `arn:aws:iam::<coralogix_account_id>:role/coralogix-archive-<coralogix_region>` instead of `arn:aws:iam::<coralogix_account_id>:root`, as this role is working for both metrics and logs archive.

### **eventbridge**
### 💡 Enhancements 💡
- Update coralogix endpoint to the new format `<coralogix env>.coralogix.com`

## v3.6.1
#### **lambda-manager**
### 💡 Enhancements 💡
- Update the eventhub rule to only scan log groups of type STANDARD

## v3.6.0
#### **resource-metadata**
### 🔒 Security Enhancements 🔒
- **IAM Policy Security Fix**: Replaced wildcard (`"*"`) permissions in secret access policy with specific ARN-based permissions 
- **Enhanced Secret Manager Support**: Improved IAM policy logic to handle existing secrets referenced by name or full ARN

### 💡 Enhancements 💡
- **Module Architecture Refactor**: Simplified from dual Lambda modules to single conditional Lambda module for better maintainability
- **Enhanced `private_key` Variable**: Now supports multiple input formats:
  - Direct API key (basic usage)
  - API key value for new secret creation
  - Existing secret name or full ARN reference

## v3.5.0
#### **lambda-manager**
### 💡 Enhancements 💡
- Add add_permissions_to_all_log_groups variable, When set to true, grants subscription permissions to the destination for all current and future log groups using a wildcard

## v3.4.0
#### **lambda-manager**
### 💡 Enhancements 💡
- Add  disable_add_permission variable


## v3.4.0
#### **resource-metadata-sqs**
### 💡 Configuration update 💡
- Update the module according to the function's latest release (v0.3.0)

## v3.3.4
#### **coralogix-aws-shipper**, **firehose-metrics**, **firehose-logs**, **ecs-ec2**
### 🧰 Bug fixes 🧰
- Update the required version of the modules:
  - coralogix-aws-shipper: >= 1.7.0
  - firehose-metrics: >= 1.6.0
  - firehose-logs: >= 1.6.0
  - ecs-ec2: >= 1.9.0

## v3.3.3
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Add missing permissions to sns and sqs integrations

## v3.3.2
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Fix an issue with `newline_pattern` variable, which is not showing in the env for the lambda.
#### **lambda-manager**
### 💡 Enhancements 💡
- Add a default value to `logs_filter` to be an empty string

## v3.3.1
#### **lambda-manager**
### 🧰 Bug fixes 🧰
- Add missing permissions to lambda function
### 💡 Enhancements 💡
- Add support for log_group_permissions_prefix variable
#### **firehose-logs**
###  💡 Configuration update 💡
- Update buffering_size to be in line with documentation, use the value of 1MiB.
#### **firehose-metrics**
### 💡 Configuration update 💡
- Update retry_duration to be in line with documentation, use the value of 300 seconds to secure we do not lose the data on any issues.

## v3.3.0
#### **resource-metadata-sqs**
### 💡 Enhancements 💡
- Add support for multi-region and cross-account metadata collection

## v3.2.0
#### **ecs-ec2**
### 💡 Enhancements 💡
- Updated ECS-EC2 default otel config with tarces head sampling
- Updated ECS-EC2 default otel config to use new collector metric config format
- Added a transform to remove unneeded labels from metrics added as of otel v0.119.0

## v3.1.0
#### **coralogix-aws-shipper**
### 💡 Enhancements 💡
- Add variables `sns_topic_filter_policy_scope` and `sns_topic_filter` to allow SNS topic filter for the Lambda subscription

## v3.0.0
#### **ecs-ec2**
### 🛑 Breaking changes 🛑
### 💡 Enhancements 💡
- Added support for Parameter Store for custom configurations.
- Added support for Secret API Key.
- Added Resource Catalog support.
- Added new tests for ECS EC2 integration.
- Added support for AP3 region.

## v2.10.0
#### **coralogix-aws-shipper**
### 💡 Enhancements 💡
- Add support to deploy the integration with multiple S3 buckets

## v2.9.0
#### **cloudwatch-metrics-iam-role**
### 🚀 New components 🚀
- Add new module to collect metrics from AWS services that expose them via AWS CloudWatch

## v2.8.0
#### **coralogix-aws-shipper**
### 🚀 New components 🚀
- Add KMS Key support for S3 Buckets

## v2.7.0
#### **eventbridge**
### 🚀 New components 🚀
- Add support to filter events by detail type

## v2.6.1
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Update resource ARN to be compatible and dynamic according to the AWS region
#### **firehose-metrics**
### 🧰 Bug fixes 🧰
- Update resource ARN to be compatible and dynamic according to the AWS region

## v2.6.0
#### **coralogix-aws-shipper**
### 🚀 New components 🚀
- Add support for ingesting Cloudwatch Stream Metrics via Firehose over PrivateLink for more information refer to [README.md](./modules/coralogix-aws-shipper/README.md#cloudwatch-metrics-stream-via-privatelink-beta)
### 🧰 Bug fixes 🧰
- Update null_resource.s3_bucket_copy resource to delete source code file only if exists
#### **firehose-metrics**
### 🧰 Bug fixes 🧰
- Update null_resource.s3_bucket_copy to skip deleting the bootstrap.zip file if it doesn't exist

## v2.5.0
#### **resource-metadata-sqs**
### 🚀 New components 🚀
- Created [resource-metadata-sqs](./modules/resource-metadata-sqs) module – extended version of the [resource-metadata](./modules/resource-metadata) module, which uses SQS to make the metadata generation process asynchronous in order to handle a large number of resources (source code available [here](https://github.com/coralogix/coralogix-aws-serverless/tree/master/src/resource-metadata-sqs)).

## v2.4.1
#### **firehose-logs**
### 💡 Enhancements 💡
- Added module outputs
#### **firehose-metrics**
### 💡 Enhancements 💡
- Added module output `firehose_stream_arn`
### 🧰 Bug fixes 🧰
– Added missing docs on module outputs
– Add a new variable `custom_s3_bucket` to allow users to deploy the integration in govcloud. specify a custom s3 bucket to save the lambda zip code in

## v2.4.0
#### **firehose-logs**
### 💡 Enhancements 💡
- Added Amazon S3 bucket policies to require encryption during data transit.

## v2.3.4
#### **firehose-logs**
### 🧰 Bug fixes 🧰
- Tag missing for `aws_kinesis_firehose_delivery_stream` resource

## v2.3.3
#### **firehose-metrics**
#### **firehose-logs**
### 🧰 Bug fixes 🧰
- Decouple IAM policy documents from IAM role resource

## v2.3.2
#### **ecs-ec2**
### 🧰 Bug fixes 🧰
- Removed `default` key from `json_parser` operator, because the operator doesn't have this key, and the opentelemetry config failed because of it

## v2.3.1
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Fix issue with local variable `api_key_is_arn` being nonsensitive, for terraform version lower than `1.10.0`

## v2.3.0
#### **coralogix-aws-shipper**
### 💡 Enhancements
- Add new variable `source_code_version`, to allow user to specify the source lambda code version
### 🛑 Breaking changes In the source code 🛑
- updated support for dynamic value allocation of Application and Subsystem names based on internal metadata
- updated how metadata is recorded and propagated throughout the function, including adding more metadata fields and updating the names of others.
    - stream_name --> cw.log.stream
    - bucket_name --> s3.bucket
    - key_name --> s3.object.key
    - topic_name --> kafka.topic
    - log_group_name --> cw.log.group
- Added new syntax for evaluating dynamic allocation fields. `{{ metadata | r'regex' }}`
- Removed dynamic application and sybsustem
- It is still possible to use the old version of the source code by using the new variable: `source_code_version` and spacify version that is older then `1.1.0`

## v2.2.3
#### **firehose-metrics**
#### **firehose-logs**
### 🧰 Bug fixes 🧰
- Added new variable `govcloud_deployment`, when set to true the arn of resource that are being used by the module will start with `arn:aws-us-gov` instead of `arn:aws`

## v2.2.2
#### **coralogix-aws-shipper**
### 💡 Enhancements
- Add `reserved_concurrent_executions` variable to allow user to define lambda Function concurrency.
- Add `execution_role_name` variable, when deffined the lambda will use this role as execution role. The module will add to this variable the necessary permissions to run the lambda.
- Add `lambda_assume_role_arn` variable, when set the lambda will assume this role in the code level.

## v2.1.2
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Add new variable `govcloud_deployment`, when set to true the arn of resource that are being used by the module will start with `arn:aws-us-gov` instead of `arn:aws`
- Add a condition to the `aws_iam_policy.AWSLambdaMSKExecutionRole` block so it will only create it when MSK is enabled

## v2.1.1
#### **S3-archive**
### 🧰 Bug fixes 🧰
- Add `logs_bucket_force_destroy` and `metrics_bucket_force_destroy` variables to allow force destroy the bucekts.

## v2.1.0
#### **firehose-metrics**
### 💡 Enhancements
- Added an option to include metrics from source accounts linked to the monitoring account in the Firehose CloudWatch metric stream.
- Introduced the `include_linked_accounts_metrics` variable to control the inclusion of linked account metrics for Firehose.
- Updated example configurations to demonstrate usage of the `include_linked_accounts_metrics` variable in Firehose metric streams.

## v2.0.1
#### **ecs-ec2**
### 🧰 Bug fixes 🧰
- Fixed ecs-ec2 module, adjusted cdot image command to `--config env:OTEL_CONFIG`
- Removed latest flag from ecs-ec2 module example.
- Removed deprecated logging exporter from ecs-ec2 module otel configs.

### 💡 Enhancements
- Added pprof extension to default ecs-ec2 otel configurations.

## v2.0.0
### 🛑 Breaking changes 🛑
- Remove deprecated modules: cloudwatch-logs, S3 and kinesis

## v1.0.107
#### **firehose-logs & firehose-metrics**
### 💡 Enhancements
- Add AP3 region to the list of regions
- Added custom naming for global resources
- Added ability to import global resources (s3 & iam)
### 🛑 Breaking changes 🛑
- For firehose-logs & firehose-metrics, Update variables: `coralogix_region` values regions from [Europe, Europe2, India, Singapore, US, US2] to [EU1, EU2, AP1, AP2, AP3, US1, US2]
- Update variables: `private_key` renamed to `api_key` with type `string` instead of `any`.

## v1.0.106
#### **msk-data-stream**
### 💡 Enhancements
- Update coralogix role from `arn:aws:iam::<account-id>:role/msk-access-<region>` to  `arn:aws:iam::<account-id>:role/coralogix-archive-<region>`
- allow the module to run in AP3 region

#### **coralogix-aws-shipper**
### 💡 Enhancements
- Allow the module to be deployed in AP3

#### **S3-archive**
### 💡 Enhancements
- Allow the module to be deployed in ap-southeast-3 region


## v1.0.105
#### **firehose-metrics**
### 💡 Enhancements
- Add AP3 region to the list of regions
- Added custom naming for global resources
- Added ability to import global resources (s3 & iam)
### 🛑 Breaking changes 🛑
- Update variables: `private_key` renamed to `api_key` with type `string` instead of `any`.

## v1.0.104
#### **msk-data-stream**
### 🚀 New module 🚀
- Add new module `msk-data-stream`, the module will create msk with public access, and a role to allow coralogix to stream data to his topics.

## v1.0.103
#### **resource-metadata**
### 💡 Enhancements
- Update lambda runtime from nodejs18 to nodejs20
### 🛑 Breaking changes 🛑
- Update variables: `collect_aliases` and `create_secret` to be type `bool` instead of `string`.

## v1.0.102
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Add new parameter runtime, to allow users to specify lambda run time, possible options: `provided.al2023` or `provided.al2`

## v1.0.101
#### **coralogix-aws-shipper**
### 💡 Enhancements
- Allow to specify multiple api_key when using the parameter integration_info
- Remove the creation of an SNS topic for lambda failure in case the user didn't set up notification_email
- Add new variable create_endpoint to allow users to choose if they want to create an endpoint in case they are using a private link and store their ApiKey in secret.
### 🛑 Breaking changes 🛑
when using integration_info varialbe will now need to specify the api_key as parameter in the mapping of integration_info instead of in the modules body itself [example](https://github.com/coralogix/terraform-coralogix-aws/blob/chenglog-update/examples/coralogix-aws-shipper/README.md#use-the-multiple-s3-integrations-at-once-using-the-integration_info-variable)

## v1.0.100
#### **s3-archive**
### 💡 Enhancements
- Add delete permissions to the archive buckets
- replace ap1 region with ap2 in the aws_role_region mapping

## v1.0.99
#### **ecs-ec2**
### 💡 Enhancements
- Added validation using operator route to default otel config for ecs-ec2 config

## v1.0.98
#### **coralogix-aws-shipper**
### 💡 Enhancements
- Add support for DLQ
- Add log_group_prefix variable to avoid limitation of number of log groups
- Update versions for github actions to avoid node.js 16 issue

## v1.0.97
#### firehose-metrics
### 💡 Enhancements
- [cds-1198] set default type parameter to CloudWatch_Metrics_OpenTelemetry070_WithAggregations
- add README description for aggregation

## v1.0.96
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Update the lambda runtime to Amazon 2023, the lambda module version to 7.2 and the terraform version to 5.32

## v1.0.95
### 🚀 New components 🚀
#### **coralogix-aws-shipper**
- Add new variables custom_csv_header and custom_metadata

## v1.0.94
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Update permissions for lambda when using private link

## v1.0.93
#### **coralogix-aws-shipper**
### 🧰 Bug fixes 🧰
- Update permissions for EcrScan integration

## v1.0.93
### 💡 Enhancements
- [cds-1099] set default force_flush_period parameter to 0 for ecs-ec2 otel filelog receiver💡


## v1.0.92
### 💡 Enhancements 💡
- [cds-1099] add recombine operator to default configuration for opentelemetry ecs-ec2 integration

## v1.0.92
### 💡 Enhancements 💡
#### **coralogix-aws-shipper**
- allow MSK integration to get multiple topic names as a trigger

## v1.0.91
### 🚀 New components 🚀
#### **lambda-manager**
- Create lambda-manager module

## v1.0.90
### 💡 Enhancements 💡

- [cds-1050] add support for x86 to template

## v1.0.89
### 💡 Enhancements 💡
- ECS-EC2 module, set log level to warn by default for otel configurations

## v1.0.88
### 🧰 Bug fixes 🧰
#### **ecs-ec2**
- fixes ecs-ec2 bugs from v1.0.87

## v1.0.87
### 💡 Enhancements and Bug fixes 🧰
#### **ecs-ec2**
- ECS CDOT restrict hostfs mount scope security fix; OTEL config batch fix; README improvement.
- ECS CDOT update region codes Terraform interface.

## v1.0.86
### 🚀 New components 🚀
#### **coralogix-aws-shipper**
- Add support for Ecr

## v1.0.85
### 🚀 New components 🚀
#### **coralogix-aws-shipper**
- Add support for MSK and Kafka

## v1.0.84
### 🧰 Bug fixes 🧰
#### **coralogix-aws-shipper**
- Fix a bug that won't allow you to use more than one s3 integration on 1 terraform configuration file

### 💡 Enhancements 💡
#### **coralogix-aws-shipper**
- Split main.tf file, every integration resource will be in its file.

## v1.0.83
### 🚀 New components 🚀
#### **coralogix-aws-shipper**
- Add support for CloudFront Access logs
- Support for adding metadata to logs (bucket_name, key_name, stream_name)

## v1.0.82
### 🧰 Bug fixes 🧰
#### **s3-archive**
- Update the role for the metrics bucket

## v1.0.81
### 🧰 Bug fixes 🧰
#### **ecs-ec2**
- Missing resource instance key

## v1.0.80
### 🚀 New components 🚀
#### **coralogix-aws-shipper**
- Add option to use Kinesis stream

## v1.0.79
### 🧰 Bug fixes 🧰
#### **s3-archive**
- Update the role to the s3 bucket

## v1.0.78
### 🚀 New components 🚀
#### **coralogix-aws-shipper**
- Add option to use Sqs with out without s3 bucket

## v1.0.77
### 🧰 Bug fixes 🧰
#### **coralogix-aws-shipper**
- Allow log group with a dot in the name to be a trigger for lambda
- Add variable lambda_name to allow users to specify the name of the lambda that gets created by the module

## v1.0.76
### 💡 Enhancements 💡
#### **ecs-ec2**
- Use unique resource names - this will allow the deployment of the service multiple times on the same cluster (for configuration tests for example) and to maintain separate definitions within the same account/region
- [optionally] Allow tagging
- [optionally] Reuse task definition for multiple service deployments

## v1.0.75
### 🧰 Bug fixes 🧰
#### **coralogix-aws-shipper**
- Reduce Secret Manage IAM permissions

## v1.0.74
### 🧰 Bug fixes 🧰
#### ֿ**coralogix-aws-shipper**
- Fix bug related to attach_async_event_policy in the lamabda module

## v1.0.73
### 🧰 Bug fixes 🧰
#### ֿ**firehose-logs**
- Fix examples with correct module name and source
#### firehose-metrics
- Fix examples with correct module name and source

## v1.0.72
### 🧰 Bug fixes 🧰
#### **coralogix-aws-shipper**
- Update the Coralogix Region list to be the same as the list in the [website](https://coralogix.com/docs/coralogix-domain/)

## v1.0.71
### 🧰 Bug fixes 🧰
#### **coralogix-aws-shipper**
- Change default loglevel to WARN

## v1.0.70
### 💡 Enhancements 💡
#### **resource-metadata**
- Option to specify a retention time of the CloudWatch log group that is created by the lambdas

## v1.0.69
### 🚀 New components 🚀
#### **coralogix-aws-shipper**
- Add submodule for the coralogix-aws-shipper

## v1.0.68
### 💡 Enhancements 💡
#### **resource-metadata**
- Add lambda function filtering in resource-metadata

## v1.0.67
### 🛑 Breaking changes 🛑
#### **firehose-metrics**
- Remove CloudWatch_Metrics_JSON from metrics integrationTypes

## v1.0.66
### 💡 Enhancements 💡
#### **cloudwatch-logs**
- Refactoring the module to use 'for_each' instead of 'count' to avoid unnecessary changes in terraform plans and applies, when there was any change to the log_groups variable

## v1.0.65
### 💡 Enhancements 💡
#### **s3**
- Option to specify a retention time of the CloudWatch log group that is created by the lambdas

## v1.0.64
### 🚩 Deprecations 🚩
#### **firehose**
- firehose submodule will be deprecated in favor of two separate submodules firehose-metrics and firehose-logs

## v1.0.63
### 🚩 Deprecations 🚩
#### **firehose**
- remove dynamic_metadata_logs, applicationNameDefault and subsystemNameDefault in following the changes made on firehose logs documentation

## v1.0.62
### 🚀 New components 🚀
#### **ecs-ec2**
- Add submodule for the ecs-ec2

## v1.0.61
### 💡 Enhancements 💡
#### **firehose**
- Migrate Lambda transformation runtime

## v1.0.60
### 💡 Enhancements 💡
#### **firehose**
- changed applicationNameDefault and subsystemNameDefault in following the changes made on firehose logs documentation.
- added lambda_processor_enable variable to enable/disable lambda transformation processor

## v1.0.59
### 💡 Enhancements 💡
#### **all**
- add secret_manager_enabled variable to integrations

## v1.0.58
### 💡 Enhancements 💡
#### **firehose**
- Added subsystem value to common attributes of firehose metrics
- Added override_default_tags to allow users to override the default tags we set

## v1.0.57
### 🧰 Bug fixes 🧰
#### **all**
Change the SSM option name to be SM (Secret Manager).

## v1.0.56
### 🧰 Bug fixes 🧰
#### **resource-metadata**
- Remove the IAM role named Default - there is no need for this role and it can cause a conflict.

## v1.0.55
### 🧰 Bug fixes 🧰
#### **s3-archive**
- change coralogix_region to aws_region

### 💡 Enhancements 💡
#### **s3-archive**
- add validation for aws_region variable

## v1.0.54
### 💡 Enhancements 💡
#### **s3-archive**
- Add support to US2 region
- Add option to use custom coralogix arn

## v1.0.53
### 💡 Enhancements 💡
#### **all**
- Add an option for a user to use an existing secret instead of creating a new one with ssm

### 🚩 Deprecations 🚩
#### **all**
- Remove the ssm_enabled variable.

## v1.0.52
### 🧰 Bug fixes 🧰
#### **firehose**
-  fix duplicate IAM issue

## v1.0.51
### 🛑 Breaking changes 🛑
#### **firehose**
- standardizing variable naming and description

## v1.0.50
### 🧰 Bug fixes 🧰
#### **firehose**
- add buffer and cache configurations to fix firehose lag

## v1.0.49
### 🚀 New components 🚀
#### **lambda-secretLayer**
- Add submodule for the lambda-secretLayer

## v1.0.48
### 💡 Enhancements 💡
#### **all**
- Add support for govcloud, by adding custom_s3_bucket variable.


## v1.0.47
### 💡 Enhancements 💡
#### **cloudwatch-logs**
- Add support to use a private link with coralogix by adding subnet_id and security_group_id variable

## v1.0.46
### 🧰 Bug fixes 🧰
#### **all**
- Update examples removing ssm_enable and layer_arn

## v1.0.45
### 💡 Enhancements 💡
#### **all**
- Add new region US2 to the integrations

## v1.0.44
### 🛑 Breaking changes 🛑
#### **s3-archive**
- Change submodule location to be under Provisioning section

## v1.0.43
### 🚀 New components 🚀
#### **s3-archive**
- Add submodule for the s3-archive

## v1.0.42
### 💡 Enhancements 💡
#### **workflow**
- raise semantic-release-action and semantic_version

## v1.0.41
### 🧰 Bug fixes 🧰
#### **firehose**
- update default for integration_type_metrics to be CloudWatch_Metrics_OpenTelemetry070
