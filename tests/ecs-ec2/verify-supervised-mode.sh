#!/usr/bin/env bash
# Verifies that Supervisor mode embeds its default configurations and prefers S3 overrides.
# Contract: Supervisor mode uses the supervised image, a NOP Collector bootstrap config,
# and the embedded Supervisor config unless matching S3 paths are configured. Collector
# mode keeps the custom image entrypoint and receives its configuration through arguments.
#
# Usage: ./verify-supervised-mode.sh
#
# Requires: terraform, jq

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

INLINE_PLAN="$TMP_DIR/inline.tfplan"
INLINE_JSON="$TMP_DIR/inline.json"
S3_PLAN="$TMP_DIR/s3.tfplan"
S3_JSON="$TMP_DIR/s3.json"
COLLECTOR_PLAN="$TMP_DIR/collector.tfplan"
COLLECTOR_JSON="$TMP_DIR/collector.json"

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

echo "[INFO] Verifying Supervisor mode with embedded configurations..."
terraform plan -input=false -lock=false -var='health_check_enabled=true' -out="$INLINE_PLAN" >/dev/null
terraform show -json "$INLINE_PLAN" > "$INLINE_JSON"

TASK_ADDRESS='module.ecs-ec2.aws_ecs_task_definition.coralogix_otel_agent[0]'
INLINE_TASK=$(jq -c --arg address "$TASK_ADDRESS" '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == $address)
' "$INLINE_JSON")
INLINE_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$INLINE_TASK")

if ! jq -e '
  any(.[];
    .name == "config-loader"
    and any(.environment[];
      .name == "COLLECTOR_CONFIG"
      and (.value | contains("receivers:\n  nop:"))
      and (.value | contains("endpoint: \"localhost:13133\""))
      and (.value | contains("traces:"))
      and (.value | contains("metrics:"))
      and (.value | contains("logs:"))
    )
    and any(.environment[];
      .name == "SUPERVISOR_CONFIG"
      and (.value | contains("opamp/v1"))
      and (.value | contains("- /otel-config/collector-config.yaml"))
      and (.value | contains("initial_fallback_configs: []"))
    )
    and any(.mountPoints[]; .containerPath == "/otel-config")
  )
  and any(.[];
    .name == "coralogix-otel-agent"
    and .image == "cgx.jfrog.io/coralogix-docker-images/coralogix-otel-supervised-cdot:v0.10.0"
    and .privileged == true
    and (has("entryPoint") | not)
    and .command == ["--config", "/otel-config/supervisor.yaml"]
    and .healthCheck.command == ["CMD", "/healthcheck"]
    and any(.mountPoints[];
      .containerPath == "/otel-config"
      and .readOnly == true
    )
    and any(.dependsOn[]; .containerName == "config-loader" and .condition == "SUCCESS")
  )
' <<< "$INLINE_CONTAINERS" >/dev/null; then
  fail "Embedded Supervisor mode does not contain the expected NOP config, supervised image, or health check."
fi

if ! jq -e '
  [.resource_changes[]
    | select(.address | contains("otel_task_role_s3"))
    | select(.change.actions | index("create"))]
  | length == 2
' "$INLINE_JSON" >/dev/null; then
  fail "Embedded Supervisor mode does not create the expected task role and S3 policy."
fi

echo "[INFO] Verifying Supervisor mode with S3 configuration overrides..."
terraform plan \
  -input=false \
  -lock=false \
  -var='s3_config_bucket=placeholder-bucket' \
  -var='s3_config_key=configs/collector.yaml' \
  -var='s3_supervisor_config_key=configs/supervisor.yaml' \
  -out="$S3_PLAN" >/dev/null
terraform show -json "$S3_PLAN" > "$S3_JSON"

if ! jq -e '
  any(.resource_changes[];
    .address == "module.ecs-ec2.aws_iam_role.otel_task_role_s3[0]"
    and (.change.actions | index("create"))
  )
' "$S3_JSON" >/dev/null; then
  fail "Supervisor mode with S3 overrides does not create the expected task role."
fi

S3_POLICY=$(jq -r '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == "module.ecs-ec2.aws_iam_role_policy.otel_task_role_s3_s3_policy[0]")
  | .values.policy
' "$S3_JSON")

if ! jq -e '
  any(.Statement[];
    (.Action | sort) == (["s3:GetObject", "s3:GetObjectVersion"] | sort)
    and .Resource == "arn:aws:s3:::placeholder-bucket/*"
  )
  and any(.Statement[];
    .Action == ["s3:ListBucket"]
    and .Resource == "arn:aws:s3:::placeholder-bucket"
  )
' <<< "$S3_POLICY" >/dev/null; then
  fail "The task role policy does not grant the expected read access to the configured S3 bucket."
fi

S3_TASK=$(jq -c --arg address "$TASK_ADDRESS" '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == $address)
' "$S3_JSON")
S3_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$S3_TASK")

if ! jq -e '
  any(.[];
    .name == "config-loader"
    and any(.environment[]; .name == "S3_CONFIG_BUCKET" and .value == "placeholder-bucket")
    and any(.environment[]; .name == "S3_CONFIG_KEY" and .value == "configs/collector.yaml")
    and any(.environment[]; .name == "S3_SUPERVISOR_CONFIG_KEY" and .value == "configs/supervisor.yaml")
    and (.command[0] | contains("/otel-config/collector-config.yaml"))
    and (.command[0] | contains("/otel-config/supervisor.yaml"))
  )
' <<< "$S3_CONTAINERS" >/dev/null; then
  fail "The config loader does not prefer the configured S3 Collector and Supervisor paths."
fi

echo "[INFO] Verifying Supervisor mode with initial fallback configurations..."
FALLBACK_PLAN="$TMP_DIR/fallback.tfplan"
FALLBACK_JSON="$TMP_DIR/fallback.json"
FALLBACK_URL="s3://placeholder-bucket.s3.us-east-1.amazonaws.com/account/group/EMPTY_VERSION/remote/config.yaml"

terraform plan \
  -input=false \
  -lock=false \
  -var='s3_config_bucket=placeholder-bucket' \
  -var="initial_fallback_configs=[\"$FALLBACK_URL\"]" \
  -out="$FALLBACK_PLAN" >/dev/null
terraform show -json "$FALLBACK_PLAN" > "$FALLBACK_JSON"

FALLBACK_TASK=$(jq -c --arg address "$TASK_ADDRESS" '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == $address)
' "$FALLBACK_JSON")
FALLBACK_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$FALLBACK_TASK")

if ! jq -e --arg url "$FALLBACK_URL" '
  any(.[];
    .name == "config-loader"
    and any(.environment[];
      .name == "SUPERVISOR_CONFIG"
      and (.value | contains("initial_fallback_configs:"))
      and (.value | contains($url))
    )
  )
' <<< "$FALLBACK_CONTAINERS" >/dev/null; then
  fail "Supervisor mode with initial_fallback_configs does not embed the expected fallback URLs."
fi

FALLBACK_POLICY=$(jq -r '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == "module.ecs-ec2.aws_iam_role_policy.otel_task_role_s3_s3_policy[0]")
  | .values.policy
' "$FALLBACK_JSON")

if ! jq -e '
  any(.Statement[];
    (.Action | sort) == (["s3:GetObject", "s3:GetObjectVersion"] | sort)
    and .Resource == "arn:aws:s3:::placeholder-bucket/*"
  )
' <<< "$FALLBACK_POLICY" >/dev/null; then
  fail "initial_fallback_configs does not grant the expected S3 read access via s3_config_bucket."
fi

echo "[INFO] Verifying collector mode keeps the image entrypoint..."
terraform plan \
  -input=false \
  -lock=false \
  -var='supervisor_enabled=false' \
  -var='image=example.com/custom-collector' \
  -var='image_version=latest' \
  -var='s3_config_bucket=placeholder-bucket' \
  -var='s3_config_key=configs/collector.yaml' \
  -out="$COLLECTOR_PLAN" >/dev/null
terraform show -json "$COLLECTOR_PLAN" > "$COLLECTOR_JSON"

COLLECTOR_TASK=$(jq -c --arg address "$TASK_ADDRESS" '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == $address)
' "$COLLECTOR_JSON")
COLLECTOR_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$COLLECTOR_TASK")

if ! jq -e '
  length == 2
  and any(.[];
    .name == "config-loader"
    and any(.environment[]; .name == "SUPERVISOR_ENABLED" and .value == "false")
  )
  and any(.[];
    .name == "coralogix-otel-agent"
    and .image == "example.com/custom-collector:latest"
    and (has("entryPoint") | not)
    and .command == ["--config", "s3://placeholder-bucket.s3.us-east-1.amazonaws.com/configs/collector.yaml"]
    and any(.dependsOn[]; .containerName == "config-loader" and .condition == "SUCCESS")
  )
' <<< "$COLLECTOR_CONTAINERS" >/dev/null; then
  fail "Collector mode does not preserve the image entrypoint and S3 configuration argument."
fi

echo "[PASS] Supervised mode embeds configs by default, supports initial_fallback_configs, and prefers configured S3 paths."
