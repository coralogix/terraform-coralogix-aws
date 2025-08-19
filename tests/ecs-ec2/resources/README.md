# Example Terraform Resources for ECS/EC2 OTEL Collector Testing

This directory contains **example Terraform configurations** organized in separate directories for different resource types. Each directory is a self-contained Terraform configuration that can be used independently.

## Directory Structure

```
resources/
├── parameter-store/     # Parameter Store and Secrets Manager resources
│   ├── main.tf
│   └── variables.tf
├── s3/                  # S3 resources
│   ├── main.tf
│   └── variables.tf
└── README.md
```

## Resources Created

### Parameter Store and Secrets Manager Resources (`parameter-store/`)
Creates resources for Parameter Store and Secrets Manager testing:

- **Parameter Store Parameter**: Stores OpenTelemetry configuration
- **Secrets Manager Secret**: Stores API key securely
- **IAM Role**: ECS task execution role with Parameter Store and Secrets Manager permissions

### S3 Resources (`s3/`)
Creates resources for S3 configuration testing:

- **S3 Bucket**: Stores OpenTelemetry configuration files
- **S3 Object**: Configuration file uploaded to the bucket
- **IAM Role**: ECS task execution role with S3 read permissions

## Usage

### Create Parameter Store and Secrets Manager Resources
```bash
cd parameter-store
terraform init
terraform apply
```

### Create S3 Resources
```bash
cd s3
terraform init
terraform apply
```

**Note**: These are example Terraform files. You can modify them to match your specific requirements or create your own resources manually.

## Outputs

### Parameter Store and Secrets Manager Outputs
- `parameter_store_name`: Name of the Parameter Store parameter
- `api_key_secret_arn`: ARN of the Secrets Manager secret
- `task_execution_role_arn`: ARN of the ECS task execution role

### S3 Outputs
- `s3_config_bucket`: Name of the S3 bucket
- `s3_config_key`: Key of the configuration file in S3
- `s3_task_execution_role_arn`: ARN of the S3 task execution role

## Cleanup

To remove resources:

### Parameter Store and Secrets Manager Resources
```bash
cd parameter-store
terraform destroy
```

### S3 Resources
```bash
cd s3
terraform destroy
```

**Note**: This will permanently delete the S3 bucket and all its contents, Parameter Store parameter, Secrets Manager secret, and IAM roles. These are example resources created for testing purposes.