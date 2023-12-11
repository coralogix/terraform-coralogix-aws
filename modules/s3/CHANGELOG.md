# Changelog

## S3

### 0.0.5 / 15.11.2023
* [Update] Add an option to specify the retention time of the CloudWatch log group that is created by the lambda

### 0.0.4 / 4.10.2023
* [bug_fix] Add secret_manager_enabled variable to allow the use of lambda-SecretLayer in the same run with this module 

### 0.0.3 / 1.10.2023
* [Change] Change SSM option in the integration to Secret Manager.

### 0.0.2 / 16.8.2023
* [Update] Add an option to use an existing secret instead of creating a new one with SSM, and remove ssm_enabled variable.

### 0.0.1 / 8.8.23
* [Update] Add support for govcloud, by adding custom_s3_bucket variable.