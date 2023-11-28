# Demonstration/Example deployment of ECS EC2 Open Telemetry Agent for Windows

## Usage

To run this example you need to save this code in Terraform file, and change the values according to your settings.

For parameter details, see [ECS EC2 Windows demo module README](../../modules/ecs-ec2-windows/README.md)

```hcl
module "ecs_ec2_windows_demo" {
  source            = "../../modules/ecs-ec2-windows"
  ecs_cluster_name  = var.ecs_cluster_name
  coralogix_region  = "Singapore"
  api_key           = var.api_key
  security_group_id = var.security_group_id
  subnet_ids        = var.subnet_ids
}
```

now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.
