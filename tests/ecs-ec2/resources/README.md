# Example Terraform Resources for ECS/EC2 OTEL Collector Testing

This directory contains **example Terraform configurations** for different resource types. Each subdirectory is a self-contained Terraform configuration.

## Directory Structure

```
resources/
├── parameter-store/     # Secrets Manager + execution role (for API key from secret)
├── roles-for-bucket/    # Custom execution + task roles for an existing S3 bucket
├── s3/                  # S3 bucket + config upload + execution role
└── README.md
```

## Resources Created

### Secrets Manager (`parameter-store/`)
For tests that use API key from Secrets Manager instead of env var:

- **Secrets Manager Secret**: Stores API key
- **IAM Role**: ECS task execution role with Secrets Manager + S3 read permissions

Pass `s3_config_bucket_arn` when applying to grant S3 access for config.

### Custom Roles (`roles-for-bucket/`)
For tests that use custom IAM roles (e.g. existing bucket):

- **Execution Role**: For ECS task execution (pull image, secrets)
- **Task Role**: For container runtime (S3 config read)

### S3 (`s3/`)
Creates S3 bucket and uploads config:

- **S3 Bucket**: Stores OTEL config
- **S3 Object**: Config file uploaded
- **IAM Role**: ECS task execution role with S3 read permissions

## Usage

### Create Secrets Manager Resources
```bash
cd parameter-store
terraform init
terraform apply -var="api_key=YOUR_KEY" -var="s3_config_bucket_arn=arn:aws:s3:::YOUR_BUCKET"
```

### Create Custom Roles for Existing Bucket
```bash
cd roles-for-bucket
terraform init
terraform apply -var="bucket_name=YOUR_BUCKET"
```

### Create S3 Resources
```bash
cd s3
terraform init
terraform apply
```

**Note**: These are example Terraform files. You can modify them to match your specific requirements or create your own resources manually.

## Outputs

### Parameter Store and Secrets Manager
- `api_key_secret_arn`: ARN of the Secrets Manager secret
- `task_execution_role_arn`: ARN of the ECS task execution role

### S3
- `s3_config_bucket`: Name of the S3 bucket
- `s3_config_key`: Key of the configuration file in S3
- `s3_task_execution_role_arn`: ARN of the ECS task execution role (when `create_task_role`)

### Roles for Bucket
- `execution_role_arn`: ARN of the execution role
- `task_role_arn`: ARN of the task role

## Cleanup

```bash
cd parameter-store && terraform destroy
cd roles-for-bucket && terraform destroy
cd s3 && terraform destroy
```

**Note**: This will permanently delete the S3 bucket and contents, Secrets Manager secret, and IAM roles.