# Test ECS/EC2 OTEL collector

## Prerequisites

* ECS cluster on EC2
* AWS profile or `AWS_DEFAULT_REGION`
* S3 bucket with OTEL config (create via `resources/s3`)

## Setup

1. Create S3 resources:
   ```bash
   cd resources/s3
   terraform init
   terraform apply
   ```
2. Copy template and fill values:
   ```bash
   cd ../..
   cp terraform.tfvars.template terraform.tfvars
   # Edit terraform.tfvars: s3_config_bucket, s3_config_key, api_key
   ```

## Run

```bash
terraform init
terraform plan
terraform apply
```

Expected: ECS Service `coralogix-otel-agent-<UUID>` runs as a Daemon; logs/traces/metrics sent to Coralogix.

## Scenarios

| Scenario | Var file | Prerequisite |
|----------|----------|--------------|
| 1. S3 + inline API key | `terraform.tfvars` | `resources/s3` |
| 2. S3 + Secrets Manager (module auto-creates execution role) | `vars/example-secrets-manager.tfvars.template` | `resources/s3`, `resources/parameter-store` |
| 3. Service-only (existing task definition) | `vars/example-service-only.tfvars.template` | Existing task definition ARN. Run `./verify-service-only-mode.sh` to assert no task definition or IAM resources are planned. |
| Custom IAM roles | `vars/example-custom-roles.tfvars.template` | `resources/roles-for-bucket` |

Copy a template to `.tfvars`, fill values, then run:
```bash
cp vars/example-secrets-manager.tfvars.template vars/example-secrets-manager.tfvars
# Edit vars/example-secrets-manager.tfvars
terraform apply -var-file="vars/example-secrets-manager.tfvars"
```

## Cleanup

```bash
terraform destroy
cd resources/s3 && terraform destroy
# If used: cd resources/parameter-store && terraform destroy
# If used: cd resources/roles-for-bucket && terraform destroy
```
