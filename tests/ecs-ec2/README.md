# Test ECS/EC2 OTEL collector

## Prereqs

* Setup ECS cluster on EC2.
* Setup AWS session environment variables.
* Setup Terraform workspace name(s) for the region(s) tested, i.e.: sg, in, us, us2, eu, eu2. Switch to the desired workspace, e.g. to test in Singapore region:
    ```
    terraform workspace new sg
    terraform workspace select sg
    ```
* Configure file "terraform.tfvars" with your api_keys. See [./terraform.tfvars.template](./terraform.tfvars.template). As this contains your keys, ensure your ```.gitignore``` prevents checking-in .tfvars files.
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
* All logs captured at your Coralogix endpoint are set to ```Warning``` severity.

## Test custom endpoint

To test using an optional custom Coralogix endpoint, such as a [Private Link Endpoint](https://coralogix.com/docs/coralogix-amazon-web-services-aws-privatelink-endpoints/), staging endpoint, or an endpoint different from the AWS region,

```
terraform plan -var coralogix_endpoint=your-custom-endpoint.com
terraform apply -var coralogix_endpoint=your-custom-endpoint.com
```

Expected results:
* Logs, traces, and metrics, are captured at your Coralogix endpoint.

## Test de-provisioning ECS/EC2 OTEL collector

```
terraform destroy
```

Expected results:
* ECS Service ```coralogix-otel-agent``` is removed from the ECS cluster.
