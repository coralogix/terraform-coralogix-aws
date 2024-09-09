# Changelog

## v1.0.107
#### **firehose-logs**
### 💡 Enhancements 
- Add AP3 region to the list of regions
- Added custom naming for global resources
- Added ability to import global resources (s3 & iam)
### 🛑 Breaking changes 🛑
- For firehose-logs & firehose-metrics, Update variables: `coralogix_region` values regions from [Europe, Europe2, India, Singapore, US, US2] to [EU1, EU2, AP1, AP2, AP3, US1, US2]

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
