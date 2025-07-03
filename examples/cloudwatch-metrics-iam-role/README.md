# cloudwatch-metrics-iam-role

- **Purpose:**
  - Provision an IAM role (with inline policy) to allow Coralogix to collect AWS metrics exposed via CloudWatch.

- **Required Variables:**
  - `coralogix_company_id` – Your Coralogix company ID.
  - `coralogix_region` – AWS region for deployment.
  - `role_name` – Name of the IAM role to create.
  - `external_id_secret` – Prefix of External ID used for `sts:AssumeRole` (formatted as `<external_id_secret>@<coralogix_company_id>`).

- **Module Usage Example:**

  ```hcl
  module "coralogix_role" {
    source = ""coralogix/aws/coralogix//modules/cloudwatch-metrics-iam-role""

    coralogix_company_id = "01234567890"
    coralogix_region     = "us-west-2"
    role_name            = "coralogix-aws-metrics-integration-role"
    external_id          = "c0r4l0g1x"
  }
