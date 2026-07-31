#!/usr/bin/env bash
# Verifies profiling daemon task and service planning for collector and Supervisor modes.
# Contract: profiling_enabled creates a bridge-network daemon with kernel mounts and
# profilesSupport. Supervisor mode embeds a profiling-specific Supervisor config with
# separate fallback URLs. Collector mode requires profiling S3 config paths.
#
# Usage: ./verify-profiling-mode.sh
#
# Requires: terraform, jq

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

PROFILE_TASK_ADDRESS='module.ecs-ec2.aws_ecs_task_definition.coralogix_otel_profiling_agent[0]'
PROFILE_SERVICE_ADDRESS='module.ecs-ec2.aws_ecs_service.coralogix_otel_profiling_agent[0]'

echo "[INFO] Verifying profiling collector mode..."
COLLECTOR_PLAN="$TMP_DIR/profiling-collector.tfplan"
COLLECTOR_JSON="$TMP_DIR/profiling-collector.json"

terraform plan \
  -input=false \
  -lock=false \
  -var='supervisor_enabled=false' \
  -var='profiling_enabled=true' \
  -var='image_version=v0.5.10' \
  -var='s3_config_bucket=main-bucket' \
  -var='s3_config_key=configs/collector.yaml' \
  -var='profiling_s3_config_bucket=profiling-bucket' \
  -var='profiling_s3_config_key=configs/profiling.yaml' \
  -var='health_check_enabled=true' \
  -out="$COLLECTOR_PLAN" >/dev/null
terraform show -json "$COLLECTOR_PLAN" > "$COLLECTOR_JSON"

if ! jq -e --arg task "$PROFILE_TASK_ADDRESS" --arg service "$PROFILE_SERVICE_ADDRESS" '
  any(.resource_changes[]; .address == $task and (.change.actions | index("create")))
  and any(.resource_changes[]; .address == $service and (.change.actions | index("create")))
' "$COLLECTOR_JSON" >/dev/null; then
  fail "Profiling collector mode does not create the profiling task definition and service."
fi

PROFILE_TASK=$(jq -c --arg address "$PROFILE_TASK_ADDRESS" '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == $address)
' "$COLLECTOR_JSON")
PROFILE_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$PROFILE_TASK")

if ! jq -e '
  (.values.network_mode == "bridge")
  and any(.values.volume[]; .name == "tracefs" and .host_path == "/sys/kernel/tracing")
  and any(.values.volume[]; .name == "debugfs" and .host_path == "/sys/kernel/debug")
' <<< "$PROFILE_TASK" >/dev/null; then
  fail "Profiling task definition is missing bridge networking or kernel volumes."
fi

if ! jq -e '
  any(.[];
    .name == "profiling-config-loader"
    and any(.environment[]; .name == "PROFILING_S3_CONFIG_BUCKET" and .value == "profiling-bucket")
    and any(.environment[]; .name == "PROFILING_S3_CONFIG_KEY" and .value == "configs/profiling.yaml")
    and (.command[0] | contains("PROFILING_S3_CONFIG_BUCKET"))
  )
  and any(.[];
    .name == "coralogix-otel-profiling-agent"
    and .image == "coralogixrepo/coralogix-otel-collector:v0.5.10"
    and .privileged == true
    and .user == "0"
    and .entryPoint == ["sh", "-c"]
    and (.command[0] | contains("exec /cdot --feature-gates=+service.profilesSupport --config /otel-config/collector-config.yaml"))
    and (.command[0] | contains("mount -t debugfs"))
    and (.command[0] | contains("mount -t tracefs"))
    and any(.mountPoints[]; .containerPath == "/sys/kernel/tracing" and .readOnly == true)
    and any(.mountPoints[]; .containerPath == "/sys/kernel/debug" and .readOnly == true)
    and .healthCheck.command == ["CMD", "/healthcheck"]
    and any(.dependsOn[]; .containerName == "profiling-config-loader" and .condition == "SUCCESS")
  )
' <<< "$PROFILE_CONTAINERS" >/dev/null; then
  fail "Profiling collector mode does not configure the expected loader, mounts, or feature gate."
fi

COLLECTOR_POLICY=$(jq -r '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == "module.ecs-ec2.aws_iam_role_policy.otel_task_role_s3_s3_policy[0]")
  | .values.policy
' "$COLLECTOR_JSON")

if ! jq -e '
  any(.Statement[];
    (.Action | sort) == (["s3:GetObject", "s3:GetObjectVersion"] | sort)
    and (.Resource | sort) == (["arn:aws:s3:::main-bucket/*", "arn:aws:s3:::profiling-bucket/*"] | sort)
  )
  and any(.Statement[];
    .Action == ["s3:ListBucket"]
    and (.Resource | sort) == (["arn:aws:s3:::main-bucket", "arn:aws:s3:::profiling-bucket"] | sort)
  )
' <<< "$COLLECTOR_POLICY" >/dev/null; then
  fail "Profiling collector mode does not grant S3 access to both main and profiling buckets."
fi

echo "[INFO] Verifying profiling Supervisor mode with embedded configs..."
SUPERVISED_PLAN="$TMP_DIR/profiling-supervised.tfplan"
SUPERVISED_JSON="$TMP_DIR/profiling-supervised.json"

terraform plan \
  -input=false \
  -lock=false \
  -var='profiling_enabled=true' \
  -var='health_check_enabled=true' \
  -out="$SUPERVISED_PLAN" >/dev/null
terraform show -json "$SUPERVISED_PLAN" > "$SUPERVISED_JSON"

SUPERVISED_TASK=$(jq -c --arg address "$PROFILE_TASK_ADDRESS" '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == $address)
' "$SUPERVISED_JSON")
SUPERVISED_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$SUPERVISED_TASK")

if ! jq -e '
  any(.[];
    .name == "profiling-config-loader"
    and any(.environment[];
      .name == "COLLECTOR_CONFIG"
      and (.value | contains("receivers:\n  nop:"))
    )
    and any(.environment[];
      .name == "SUPERVISOR_CONFIG"
      and (.value | contains("opamp/v1"))
      and (.value | contains("--feature-gates=+service.profilesSupport"))
      and (.value | contains("initial_fallback_configs: []"))
    )
  )
  and any(.[];
    .name == "coralogix-otel-profiling-agent"
    and .image == "cgx.jfrog.io/coralogix-docker-images/coralogix-otel-supervised-cdot:v0.11.0"
    and (.command[0] | contains("exec /opampsupervisor -config /otel-config/supervisor.yaml"))
    and (.command[0] | contains("mount -t debugfs"))
    and .healthCheck.command == ["CMD", "/healthcheck"]
  )
' <<< "$SUPERVISED_CONTAINERS" >/dev/null; then
  fail "Profiling Supervisor mode does not embed the expected NOP and Supervisor configs."
fi

if ! jq -e '
  [.resource_changes[]
    | select(.address | contains("otel_task_role_s3"))
    | select(.change.actions | index("create"))]
  | length == 2
' "$SUPERVISED_JSON" >/dev/null; then
  fail "Profiling Supervisor mode without S3 does not create the expected task role and S3 policy."
fi

echo "[INFO] Verifying profiling Supervisor fallbacks and S3 override..."
FALLBACK_PLAN="$TMP_DIR/profiling-fallback.tfplan"
FALLBACK_JSON="$TMP_DIR/profiling-fallback.json"
MAIN_FALLBACK="s3://placeholder-bucket.s3.us-east-1.amazonaws.com/account/group/EMPTY_VERSION/main/config.yaml"
PROFILE_FALLBACK="s3://placeholder-bucket.s3.us-east-1.amazonaws.com/account/group/EMPTY_VERSION/profiling/config.yaml"

terraform plan \
  -input=false \
  -lock=false \
  -var='profiling_enabled=true' \
  -var='s3_config_bucket=placeholder-bucket' \
  -var='profiling_s3_config_bucket=profiling-bucket' \
  -var='profiling_s3_config_key=configs/profiling.yaml' \
  -var="initial_fallback_configs=[\"$MAIN_FALLBACK\"]" \
  -var="profiling_initial_fallback_configs=[\"$PROFILE_FALLBACK\"]" \
  -out="$FALLBACK_PLAN" >/dev/null
terraform show -json "$FALLBACK_PLAN" > "$FALLBACK_JSON"

MAIN_TASK=$(jq -c '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == "module.ecs-ec2.aws_ecs_task_definition.coralogix_otel_agent[0]")
' "$FALLBACK_JSON")
MAIN_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$MAIN_TASK")
FALLBACK_PROFILE_TASK=$(jq -c --arg address "$PROFILE_TASK_ADDRESS" '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == $address)
' "$FALLBACK_JSON")
FALLBACK_PROFILE_CONTAINERS=$(jq -r '.values.container_definitions' <<< "$FALLBACK_PROFILE_TASK")

if ! jq -e --arg url "$MAIN_FALLBACK" '
  any(.[];
    .name == "config-loader"
    and any(.environment[];
      .name == "SUPERVISOR_CONFIG"
      and (.value | contains($url))
      and (.value | contains("--feature-gates=+service.profilesSupport"))
    )
  )
' <<< "$MAIN_CONTAINERS" >/dev/null; then
  fail "Main Supervisor config does not embed the main fallback URL."
fi

if ! jq -e --arg main_url "$MAIN_FALLBACK" --arg profile_url "$PROFILE_FALLBACK" '
  any(.[];
    .name == "profiling-config-loader"
    and any(.environment[]; .name == "PROFILING_S3_CONFIG_BUCKET" and .value == "profiling-bucket")
    and any(.environment[];
      .name == "SUPERVISOR_CONFIG"
      and (.value | contains($profile_url))
      and ((.value | contains($main_url)) | not)
    )
  )
' <<< "$FALLBACK_PROFILE_CONTAINERS" >/dev/null; then
  fail "Profiling Supervisor config does not keep fallback URLs separate from the main agent."
fi

FALLBACK_POLICY=$(jq -r '
  .planned_values.root_module.child_modules[].resources[]
  | select(.address == "module.ecs-ec2.aws_iam_role_policy.otel_task_role_s3_s3_policy[0]")
  | .values.policy
' "$FALLBACK_JSON")

if ! jq -e '
  any(.Statement[];
    (.Action | sort) == (["s3:GetObject", "s3:GetObjectVersion"] | sort)
    and (.Resource | sort) == (["arn:aws:s3:::placeholder-bucket/*", "arn:aws:s3:::profiling-bucket/*"] | sort)
  )
' <<< "$FALLBACK_POLICY" >/dev/null; then
  fail "Profiling fallbacks do not grant S3 access to the main and profiling buckets."
fi

echo "[INFO] Verifying profiling_enabled is rejected in service-only mode..."
if terraform plan \
  -input=false \
  -lock=false \
  -var='task_definition_arn=arn:aws:ecs:us-east-1:123456789012:task-definition/coralogix-otel-agent-test:1' \
  -var='profiling_enabled=true' \
  -out="$TMP_DIR/service-only-profiling.tfplan" >/dev/null 2>"$TMP_DIR/service-only-profiling.err"; then
  fail "profiling_enabled with task_definition_arn should fail validation."
fi

if ! grep -q "profiling_enabled cannot be used with task_definition_arn" "$TMP_DIR/service-only-profiling.err"; then
  fail "Service-only profiling rejection did not report the expected validation error."
fi

echo "[PASS] Profiling mode creates the expected daemon, Supervisor wiring, IAM scope, and validations."
