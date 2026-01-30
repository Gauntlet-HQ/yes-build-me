#!/usr/bin/env bash
set -euo pipefail

# Validate a feature's slo.yaml against the schema in .gobuildme/templates/config/slo.schema.json
# Usage: .gobuildme/scripts/bash/slo-lint.sh [--strict] [path-to-slo.yaml]

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || cd "$SCRIPT_DIR/../../.." && pwd)

STRICT=false
SLO_FILE=""
if [[ "${1:-}" == "--strict" ]]; then
  STRICT=true
  shift || true
fi
SLO_FILE=${1:-}
if [[ -z "${SLO_FILE}" ]]; then
  # try to find slo.yaml under latest feature folder
  SLO_FILE=$(find "$REPO_ROOT/.gobuildme/specs" -maxdepth 2 -name slo.yaml -print -quit 2>/dev/null || true)
fi

SCHEMA="$REPO_ROOT/.gobuildme/templates/config/slo.schema.json"
[[ -f "$SCHEMA" ]] || SCHEMA="$REPO_ROOT/templates/config/slo.schema.json"

if [[ -z "${SLO_FILE}" || ! -f "$SLO_FILE" ]]; then
  echo "[slo-lint] No slo.yaml found. Provide path or create one from templates/slo-template.yaml" >&2
  if $STRICT; then exit 1; else exit 0; fi
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[slo-lint] jq is required" >&2
  if $STRICT; then exit 1; else exit 0; fi
fi
if ! command -v yq >/dev/null 2>&1; then
  echo "[slo-lint] yq not found; attempting a best-effort conversion via python -c if available" >&2
fi

# Convert YAML to JSON (prefer yq)
if command -v yq >/dev/null 2>&1; then
  SLO_JSON=$(yq -o=json "$SLO_FILE")
else
  python3 - <<'PY' 2>/dev/null || { echo '[slo-lint] cannot convert YAML to JSON'; exit 0; }
import sys, json
try:
    import yaml
except Exception:
    sys.exit(0)
from pathlib import Path
p = Path(sys.argv[1])
data = yaml.safe_load(p.read_text())
print(json.dumps(data))
PY
  exit 0
fi

if [[ ! -f "$SCHEMA" ]]; then
  echo "[slo-lint] schema not found at $SCHEMA; skipping" >&2
  if $STRICT; then exit 1; else exit 0; fi
fi

# Minimal validation (structure checks); full JSON Schema validation would require ajv or jq-schema library.
err=0
echo "$SLO_JSON" | jq -e '.service, .owner.team, .owner.on_call, (.slis|length>0), (.slos|length>0)' >/dev/null || err=1
if [[ $err -ne 0 ]]; then
  echo "[slo-lint] Missing required fields. Expected service, owner.team, owner.on_call, slis, slos." >&2
  exit 1
fi

echo "[slo-lint] OK: $SLO_FILE"
