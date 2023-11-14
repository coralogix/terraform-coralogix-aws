# Test ECS/EC2 OTEL collector

## Prereqs

* Setup ECS cluster on EC2.
* Setup AWS profile, or AWS session environment variables including ```AWS_DEFAULT_REGION```.
* Configure file "terraform.tfvars" accordingly from [./terraform.tfvars.template](./terraform.tfvars.template). 
* Edit ```cluster-name``` in  [./ecs-ec2.tf](./ecs-ec2.tf) to match your environment ECS cluster name accordingly.

## Test provisioning ECS/EC2 OTEL collector

```
terraform plan
terraform apply
```

Expected results:
* ECS Service ```coralogix-otel-agent``` runs as a Daemon on every EC2 cluster instance.
* Logs, traces, and metrics, are captured at your Coralogix endpoint.

## Test using custom config file.

To test with an optional custom config file, e.g. [./otel_config_custom.tftpl.yaml](./otel_config_custom.tftpl.yaml):

```
terraform plan -var otel_config_file="$(pwd)/otel_config_custom.tftpl.yaml"
terraform apply -var otel_config_file="$(pwd)/otel_config_custom.tftpl.yaml"
```

Expected results:
* Any logs to application containers are captured at ```Warning``` severity.

## Test custom domain

To test using an optional custom Coralogix domain, such as a [Private Link Endpoint](https://coralogix.com/docs/coralogix-amazon-web-services-aws-privatelink-endpoints/).

```
terraform plan -var custom_domain=your-custom-domain.com -var api_key=your-api-key
terraform apply -var custom_domain=your-custom-domain.com -var api_key=your-api-key
```

Expected results:
* Logs, traces, and metrics, are captured at the specified Coralogix domain.

## Test de-provisioning ECS/EC2 OTEL collector

```
terraform destroy
```

Expected results:
* ECS Service ```coralogix-otel-agent``` is removed from the ECS cluster.
