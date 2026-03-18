# Test ECS/EC2 Windows OTEL collector

## Prereqs

* An existing ECS cluster with **Windows** EC2 capacity (e.g. `WINDOWS_SERVER_2022_CORE`).
* AWS profile or environment variables (e.g. `AWS_DEFAULT_REGION`) set.
* Copy and configure tfvars:
  ```bash
  cp terraform.tfvars.template terraform.tfvars
  # Edit terraform.tfvars with your values (ecs_cluster_name, api_key, optional subnet_ids/security_group_ids)
  ```

## Validate and plan

Without a Windows cluster you can still validate and plan; the test uses default VPC subnets and default security group when `subnet_ids` and `security_group_ids` are not set:

```bash
terraform init
terraform validate
terraform plan
```

For **apply** you must have a Windows ECS cluster. Optionally set `subnet_ids` and `security_group_ids` in `terraform.tfvars` to match the subnets and security group used by your Windows container instances.

## Apply (requires Windows ECS cluster)

```bash
terraform apply
```

Expected:

* ECS service `coralogix-otel-agent-<suffix>` runs as a Daemon on each Windows EC2 instance.
* Logs go to CloudWatch; telemetry is sent to Coralogix.

## Optional: S3 config

1. Create S3 resources (reuse `../ecs-ec2/resources/s3` or your own bucket/key).
2. Set in a var file (e.g. `s3_config.vars`):
   - `config_source = "s3"`
   - `s3_config_bucket` / `s3_config_key`
3. Run:
   ```bash
   terraform plan -var-file="s3_config.vars"
   terraform apply -var-file="s3_config.vars"
   ```

## Optional: Parameter Store / Secrets Manager

Same pattern as the [ecs-ec2 test](../ecs-ec2/README.md): create parameter-store (or secret) resources, then pass `config_source`, `custom_config_parameter_store_name` (or `use_api_key_secret`, `api_key_secret_arn`) and `task_execution_role_arn` via a var file.

## Cleanup

```bash
terraform destroy
```
