# Test ECS/EC2 OTEL collector

## Prereqs

* Setup ECS cluster on EC2.
* Setup AWS profile, or AWS session environment variables including ```AWS_DEFAULT_REGION```.
* Copy and configure the terraform.tfvars file:
  ```bash
  cp terraform.tfvars.template terraform.tfvars
  # Edit terraform.tfvars with your actual values
  ```

## Test provisioning ECS/EC2 OTEL collector

```
terraform init
terraform plan
terraform apply
```

**Note**: This uses the values from `terraform.tfvars` file. Make sure you've copied and configured it from the template.

Expected results:
* ECS Service ```coralogix-otel-agent-<UUID>``` runs as a Daemon on every EC2 cluster node.
* Logs, traces, and metrics, are captured at your Coralogix endpoint.

## Test using local custom config file.

To test with an optional local custom config file, e.g. [./local_config.yaml](./local_config.yaml):

```
terraform plan -var="otel_config_file=local_config.yaml"
terraform apply -var="otel_config_file=local_config.yaml"
```

Expected results:
* OTEL_CONFIG environment variable is set to the contents of the local configuration file.

## Test using S3 configuration source.

To test with configuration stored in S3:

### Option 1: Auto-created execution role (recommended)
1. First, create the S3 example resources:
   ```bash
   cd resources/s3
   terraform init
   terraform apply
   ```
2. Note the outputs: `s3_config_bucket` and `s3_config_key`
3. Update [s3_config.vars](./s3_config.vars) with the actual bucket name
4. Test the module:
   ```bash
   cd ../..
   terraform init
   terraform plan -var-file="s3_config.vars"
   terraform apply -var-file="s3_config.vars"
   ```

### Option 2: Custom execution role
1. First, create the S3 example resources:
   ```bash
   cd resources/s3
   terraform init
   terraform apply
   ```
2. Note the outputs: `s3_config_bucket`, `s3_config_key`, and `s3_task_execution_role_arn`
3. Update [s3_config_custom_role.vars](./s3_config_custom_role.vars) with the actual values
4. Test the module:
   ```bash
   cd ../..
   terraform init
   terraform plan -var-file="s3_config_custom_role.vars"
   terraform apply -var-file="s3_config_custom_role.vars"
   ```

Expected results:
* OpenTelemetry Collector uses S3 URI for configuration: `s3://bucket-name.s3.region.amazonaws.com/configs/otel-config.yaml`
* Auto-created IAM role with S3 read permissions (if no custom role provided)
* Custom IAM role used (if provided)

## Test using custom config file from Parameter Store.

To test with configuration stored in Parameter Store:

1. First, create the Parameter Store example resources:
   ```bash
   cd resources/parameter-store
   terraform init
   terraform apply
   ```
2. Note the outputs: `parameter_store_name` and `task_execution_role_arn`
3. Update [ps_config.vars](./ps_config.vars) with the actual actual values
4. Test the module:
   ```bash
   cd ../..
   terraform init
   terraform plan -var-file="ps_config.vars"
   terraform apply -var-file="ps_config.vars"
   ```

Expected results:
* OTEL_CONFIG environment variable is set to the Parameter Store defined above.
* Custom execution role required for parameter store access.

## Test using Secret API Key.

To test with a Secret API Key:
1. First, create the Secrets Manager example resources:
   ```bash
   cd resources/parameter-store
   terraform init
   terraform apply
   ```
2. Note the outputs: `api_key_secret_arn` and `task_execution_role_arn`
3. Update [secret_api_key.vars](./secret_api_key.vars) with the actual secret ARN
4. Test the module:
   ```bash
   cd ../..
   terraform init
   terraform plan -var-file="secret_api_key.vars"
   terraform apply -var-file="secret_api_key.vars"
   ```

Expected results:
* PRIVATE_KEY environment variable is set to the Secret defined above.
* Custom execution role required for secrets manager access.


## Example Resource Cleanup

To clean up example resources:

### S3 Resources
```bash
cd resources/s3
terraform destroy
```

### Parameter Store and Secrets Manager Resources
```bash
cd resources/parameter-store
terraform destroy
```

This will remove:
* S3 bucket and configuration file
* Parameter Store parameter
* Secrets Manager secret
* IAM roles and policies

**Note**: These are example resources created for testing purposes. In production, you would create your own resources with appropriate security configurations.
