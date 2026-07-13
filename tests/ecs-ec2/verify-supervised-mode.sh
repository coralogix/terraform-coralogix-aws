#!/usr/bin/env bash
set -euo pipefail

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

INLINE_PLAN="$TMP_DIR/inline.tfplan"
INLINE_JSON="$TMP_DIR/inline.json"
S3_PLAN="$TMP_DIR/s3.tfplan"
S3_JSON="$TMP_DIR/s3.json"

terraform plan -input=false -lock=false -var='health_check_enabled=true' -out="$INLINE_PLAN" >/dev/null
terraform show -json "$INLINE_PLAN" > "$INLINE_JSON"

TASK_ADDRESS='module.ecs-ec2.aws_ecs_task_definition.coralogix_otel_agent[0]'
INLINE_TASK=$(jq -c --arg address "$TASK_ADDRESS" '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == $address)
' "$INLINE_JSON")
INLINE_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$INLINE_TASK")

jq -e '
  any(.[];
    .name == "config-loader"
    and any(.environment[]; .name == "SUPERVISOR_ENABLED" and .value == "true")
    and any(.environment[];
      .name == "COLLECTOR_CONFIG"
      and (.value | contains("receivers:\n  nop:"))
      and (.value | contains("endpoint: \"localhost:13133\""))
      and (.value | contains("traces:"))
      and (.value | contains("metrics:"))
      and (.value | contains("logs:"))
    )
    and any(.environment[]; .name == "SUPERVISOR_CONFIG" and (.value | contains("opamp/v1")))
  )
  and any(.[];
    .name == "coralogix-otel-agent"
    and .image == "cgx.jfrog.io/coralogix-docker-images/coralogix-otel-supervised-cdot:v0.10.0"
    and .privileged == true
    and .healthCheck.command == ["CMD", "/healthcheck"]
    and any(.dependsOn[]; .containerName == "config-loader" and .condition == "SUCCESS")
  )
' <<< "$INLINE_CONTAINERS" >/dev/null

jq -e '
  [.resource_changes[]
    | select(.address | contains("otel_task_role_s3"))
    | select(.change.actions | index("create"))]
  | length == 2
' "$INLINE_JSON" >/dev/null

terraform plan \
  -input=false \
  -lock=false \
  -var='s3_config_bucket=placeholder-bucket' \
  -var='s3_config_key=configs/collector.yaml' \
  -var='s3_supervisor_config_key=configs/supervisor.yaml' \
  -out="$S3_PLAN" >/dev/null
terraform show -json "$S3_PLAN" > "$S3_JSON"

jq -e '
  any(.resource_changes[];
    .address == "module.ecs-ec2.aws_iam_role.otel_task_role_s3[0]"
    and (.change.actions | index("create"))
  )
' "$S3_JSON" >/dev/null

S3_POLICY=$(jq -r '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == "module.ecs-ec2.aws_iam_role_policy.otel_task_role_s3_s3_policy[0]")
  | .values.policy
' "$S3_JSON")

jq -e '
  any(.Statement[];
    (.Action | sort) == (["s3:GetObject", "s3:GetObjectVersion"] | sort)
    and .Resource == "arn:aws:s3:::placeholder-bucket/*"
  )
  and any(.Statement[];
    .Action == ["s3:ListBucket"]
    and .Resource == "arn:aws:s3:::placeholder-bucket"
  )
' <<< "$S3_POLICY" >/dev/null

S3_TASK=$(jq -c --arg address "$TASK_ADDRESS" '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == $address)
' "$S3_JSON")
S3_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$S3_TASK")

jq -e '
  any(.[];
    .name == "config-loader"
    and any(.environment[]; .name == "S3_CONFIG_BUCKET" and .value == "placeholder-bucket")
    and any(.environment[]; .name == "S3_CONFIG_KEY" and .value == "configs/collector.yaml")
    and any(.environment[]; .name == "S3_SUPERVISOR_CONFIG_KEY" and .value == "configs/supervisor.yaml")
    and (.command[0] | startswith("set -e\nif [ -n \"$S3_CONFIG_BUCKET\" ]"))
  )
' <<< "$S3_CONTAINERS" >/dev/null

echo "[PASS] Supervised mode embeds configs by default and prefers configured S3 paths."
