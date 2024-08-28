# msk data stream

The module will create an MSK with the dependency, the MSK will allow Coralogix to send telemetry data to his topics.

The module can run only on the following regions: eu-west-1, eu-north-1, ap-southeast-1, ap-south-1, us-east-2, us-west-2.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.32.0 |

| Variable name | Description | Type | Default | Required | 
|------|-------------|------|------|:--------:|
| aws_region | The AWS region that you want to create the S3 bucket, Must be the same as the AWS region where your [coralogix account](https://coralogix.com/docs/coralogix-domain/) is set. Allowd values: eu-west-1, eu-north-1, ap-southeast-1, ap-south-1, us-east-2, us-west-2, custom | `string` | n/a | :heavy_check_mark: |
| cluster_name | Name for the Cluster that the module will create | `string` | `coralogix-msk-cluster` | |
| vpc_cidr_block | CIDR for the vpc that the module will create, needs to be in the formate `10.0.0.0/20`. In case that you set this variable you will aslo need to set a value to the `subnet_cidr_blocks` variable | `string` | `193.168.0.0/20` | |
| subnet_cidr_blocks | CIDR for the vpc subnets that the module will create. In case that you set this variable you will also need to set a value to the `vpc_cidr_block` variable | `list[string]` | `["10.0.0.0/24", "10.0.1.0/24", "10.0.3.0/24"]` | |
| msk_storage_volume_size | The size of the storage volume for the MSK brokers  | `number` | `1000` | |
| instance_type | The instance type for the MSK brokers | `string` | `kafka.m5.large` | |
