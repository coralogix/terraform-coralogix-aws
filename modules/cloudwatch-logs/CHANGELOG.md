# Changelog

## cloudwatch-logs

### 0.0.5 / 4.10.2023
* [bug_fix] Add secret_manager_enabled variable to allow the use of lambda-SecretLayer in the same run with this module 

### 0.0.4 / 1.10.2023
* [Change] Change SSM option in the integration to SM - Secret Manager.

### 0.0.3 / 16.8.2023
* [Update] Add an option to use an existing secret instead of creating a new one with SSM, and remove ssm_enabled variable.

### 0.0.2 / 8.8.23
* [Update] Add support for govcloud, by adding custom_s3_bucket variable.

### 0.0.1 / 3.8.2023
* [Update] Add support to use a private link with coralogix - add subnet_id and security_group_id variable to connect the lambda to vpc.
