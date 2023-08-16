# Changelog

## cloudwatch-logs

### 0.0.3 / 16.8.2023
* [Update] Add an option to use an existing secret instead of creating a new one with SSM, and remove ssm_enabled variable.

### 0.0.2 / 8.8.23
* [Update] Add support for govcloud, by adding custom_s3_bucket variable.

### 0.0.1 / 3.8.2023
* [Update] Add support to use a private link with coralogix - add subnet_id and security_group_id variable to connect the lambda to vpc.