#!/usr/bin/env bash
# Verifies that service-only mode does not plan any task definition or IAM role resources.
# Contract: when task_definition_arn is set, the module creates only the ECS service.
#
# Usage: ./verify-service-only-mode.sh [path-to-service-only.tfvars]
# Default: vars/example-service-only.tfvars (or temp file with placeholder ARN if missing)
#
# Requires: terraform, jq

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VAR_FILE="${1:-vars/example-service-only.tfvars}"
PLAN_FILE="tfplan-service-only"
TEMP_VAR_FILE=""

if [[ ! -f "$VAR_FILE" ]]; then
  echo "[INFO] $VAR_FILE not found; using placeholder config for plan-only verification"
  TEMP_VAR_FILE=$(mktemp)
  cat > "$TEMP_VAR_FILE" << 'EOF'
aws_region       = "us-east-1"
ecs_cluster_name = "test-cluster"
task_definition_arn = "arn:aws:ecs:us-east-1:123456789012:task-definition/coralogix-otel-agent-test:1"
EOF
  VAR_FILE="$TEMP_VAR_FILE"
  trap 'rm -f "$TEMP_VAR_FILE"' EXIT
fi

echo "[INFO] Running terraform plan with $VAR_FILE (service-only mode)..."
terraform plan -var-file="$VAR_FILE" -out="$PLAN_FILE" -input=false

echo "[INFO] Checking plan for task definition and IAM role resource creates..."
CREATES=$(terraform show -json "$PLAN_FILE" | jq -r '
  .resource_changes[]?
  | select(.change.actions[]? == "create")
  | select(
      (.type == "aws_ecs_task_definition") or (.type | startswith("aws_iam_role"))
  )
  | "\(.type): \(.name)"
')

rm -f "$PLAN_FILE"

if [[ -n "$CREATES" ]]; then
  echo "[FAIL] Service-only mode must not create task definition or IAM resources. Found:"
  echo "$CREATES"
  exit 1
fi

echo "[PASS] No task definition or IAM role resources planned for create."
exit 0
