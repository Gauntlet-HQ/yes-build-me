#!/usr/bin/env bash
# Purpose: Scaffold OpenTelemetry + Coralogix observability files into a target repo (non-destructive)
# Usage: scaffold-observability.sh --repo <path> [--with-ci]
# Notes: Copies templates from this repo (or packaged .gobuildme/templates) into the target.

set -euo pipefail

TARGET_REPO=""
WITH_CI=false

print_help(){
  cat << 'EOF'
Usage: scaffold-observability.sh --repo <path> [--with-ci]

Creates (if missing):
  .gobuildme/observability/collector/otel-collector.yaml
  .gobuildme/observability/ENV_VARS.md
  .gobuildme/observability/instrumentation/README.md
  .gobuildme/observability/alerts/README.md

Optional:
  --with-ci  Install templates/github-workflows/observability-ci.yml into \
            .github/workflows/observability-ci.yml if missing
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) TARGET_REPO="${2:-}"; shift 2 ;;
    --repo=*) TARGET_REPO="${1#*=}"; shift ;;
    --with-ci) WITH_CI=true; shift ;;
    --help|-h) print_help; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; print_help; exit 1 ;;
  esac
done

if [[ -z "$TARGET_REPO" ]]; then
  echo "ERROR: --repo <path> is required" >&2
  print_help
  exit 1
fi

if [[ ! -d "$TARGET_REPO" ]]; then
  echo "ERROR: target repo not found: $TARGET_REPO" >&2
  exit 1
fi

# Locate template roots relative to this script's repository
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT=$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || (cd "$SCRIPT_DIR/../../.." && pwd))

# Prefer packaged templates if present; fallback to source templates
TPL_COLLECTOR="$SRC_ROOT/.gobuildme/templates/observability/otel-collector.yaml"
[[ -f "$TPL_COLLECTOR" ]] || TPL_COLLECTOR="$SRC_ROOT/templates/observability/otel-collector.yaml"

TPL_CI="$SRC_ROOT/.gobuildme/templates/github-workflows/observability-ci.yml"
[[ -f "$TPL_CI" ]] || TPL_CI="$SRC_ROOT/templates/github-workflows/observability-ci.yml"

if [[ ! -f "$TPL_COLLECTOR" ]]; then
  echo "ERROR: collector template not found (expected at $SRC_ROOT/.gobuildme/templates/observability/ or $SRC_ROOT/templates/observability/)" >&2
  exit 1
fi

# Create directory structure
OBS_DIR="$TARGET_REPO/.gobuildme/observability"
mkdir -p "$OBS_DIR/collector" "$OBS_DIR/instrumentation" "$OBS_DIR/alerts"

# Copy collector template (non-destructive)
COLLECTOR_DST="$OBS_DIR/collector/otel-collector.yaml"
if [[ -f "$COLLECTOR_DST" ]]; then
  echo "⚠️  Collector config already exists, skipping: $COLLECTOR_DST"
else
  cp "$TPL_COLLECTOR" "$COLLECTOR_DST"
  echo "✓ Created: $COLLECTOR_DST"
fi

# ENV_VARS.md (create if missing)
ENV_DOC="$OBS_DIR/ENV_VARS.md"
if [[ ! -f "$ENV_DOC" ]]; then
  cat > "$ENV_DOC" <<'MD'
# Observability Environment Variables

This document lists environment variables required for OpenTelemetry and Coralogix integration.

## Coralogix (required)
- `CORALOGIX_PRIVATE_KEY` — Coralogix API key (secret, per environment)
- `CORALOGIX_DOMAIN` — US region domain (e.g., `cx498.coralogix.com`)
- `CORALOGIX_APP` — Application name (environment: `production`, `staging`, `dev`, `lab`, `ops`)
- `CORALOGIX_SUBSYSTEM` — Subsystem name (service/domain identifier, lowercase)

## OpenTelemetry (application → Collector)
- `OTEL_EXPORTER_OTLP_ENDPOINT` — Collector endpoint (e.g., `http://otel-collector:4317`)
- `OTEL_RESOURCE_ATTRIBUTES` — Comma-separated attributes:
  - `service.name=<service-name>`
  - `deployment.environment=<env>`
  - `cx.application.name=<app-name>`
  - `cx.subsystem.name=<subsystem-name>`
  - Optional: `service.namespace`, `team`, `owner`, `cost_center`

## PagerDuty (optional)
- `PAGERDUTY_INTEGRATION_KEY_<SERVICE>` — PagerDuty events integration key
- `PAGERDUTY_USER_API_KEY` — For MCP (prefer read-only)
- `PAGERDUTY_API_HOST` — Custom PD API host (if applicable)

## Naming conventions
- **Application** (environment): `production`, `staging`, `dev`, `lab`, `ops` (lowercase)
- **Subsystem** (service/domain): lowercase; no env suffix; RUM subsystem is `cx_rum`

## Examples

### Kubernetes
```yaml
env:
  - name: CORALOGIX_PRIVATE_KEY
    valueFrom:
      secretKeyRef:
        name: coralogix-secrets
        key: private-key
  - name: CORALOGIX_DOMAIN
    value: "cx498.coralogix.com"
  - name: CORALOGIX_APP
    value: "production"
  - name: CORALOGIX_SUBSYSTEM
    value: "payment-processor"
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://otel-collector:4317"
  - name: OTEL_RESOURCE_ATTRIBUTES
    value: "service.name=payment-processor,deployment.environment=production,cx.application.name=production,cx.subsystem.name=payment-processor,team=payments"
```

### ECS Task Definition
```json
{
  "environment": [
    {"name": "CORALOGIX_DOMAIN", "value": "cx498.coralogix.com"},
    {"name": "CORALOGIX_APP", "value": "production"},
    {"name": "CORALOGIX_SUBSYSTEM", "value": "apiv2-svc"},
    {"name": "OTEL_EXPORTER_OTLP_ENDPOINT", "value": "http://localhost:4317"}
  ],
  "secrets": [
    {"name": "CORALOGIX_PRIVATE_KEY", "valueFrom": "arn:aws:secretsmanager:..."}
  ]
}
```

## Security notes
- Never commit secrets to VCS; use a secret store (AWS Secrets Manager, Vault, GitHub Actions secrets)
- Rotate `CORALOGIX_PRIVATE_KEY` regularly; scope access minimally
MD
  echo "✓ Created: $ENV_DOC"
else
  echo "⚠️  Exists, skipping: $ENV_DOC"
fi

# Instrumentation README
INST_README="$OBS_DIR/instrumentation/README.md"
if [[ ! -f "$INST_README" ]]; then
  cat > "$INST_README" <<'MD'
# Instrumentation Examples

Use the language-specific guidance in docs/coralogix.md.

Covered runtimes:
- Java (auto-instrumentation)
- Node.js (SDK + auto-instrumentations)
- Python (opentelemetry-instrument)
- Go (SDK)
- PHP (extension + SDK)
- NGINX (OTel module)
- AWS Lambda (Coralogix layer)

## Local testing
```bash
# Run a local collector
export CORALOGIX_PRIVATE_KEY=your-key
export CORALOGIX_DOMAIN=cx498.coralogix.com
export CORALOGIX_APP=dev
export CORALOGIX_SUBSYSTEM=local-test

otelcol --config .gobuildme/observability/collector/otel-collector.yaml

# Run your app with OTLP
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_RESOURCE_ATTRIBUTES="service.name=my-service,deployment.environment=dev,cx.application.name=dev,cx.subsystem.name=my-service"
<your-app-command>
```
MD
  echo "✓ Created: $INST_README"
else
  echo "⚠️  Exists, skipping: $INST_README"
fi

# Alerts README
ALERTS_README="$OBS_DIR/alerts/README.md"
if [[ ! -f "$ALERTS_README" ]]; then
  cat > "$ALERTS_README" <<'MD'
# Alert Definitions (Coralogix → PagerDuty)

## Migration checklist
1) Export priority New Relic alerts
2) Recreate in Coralogix (error rate, 5xx ratio, p95/p99 latency, saturation)
3) Configure PagerDuty integration keys per service
4) Test in staging before production

## PagerDuty mapping
- `page` → P1 severity
- `warn` → P2 severity
- Consider Event Orchestration for dedupe/enrichment

## SLO burn-rate alerts
- Use multi-window policies (e.g., 1h + 6h) where applicable
MD
  echo "✓ Created: $ALERTS_README"
else
  echo "⚠️  Exists, skipping: $ALERTS_README"
fi

# Optional: install CI workflow
if $WITH_CI; then
  if [[ -f "$TPL_CI" ]]; then
    mkdir -p "$TARGET_REPO/.github/workflows"
    CI_DST="$TARGET_REPO/.github/workflows/observability-ci.yml"
    if [[ -f "$CI_DST" ]]; then
      echo "⚠️  CI workflow already exists, skipping: $CI_DST"
    else
      cp "$TPL_CI" "$CI_DST"
      echo "✓ Installed CI workflow: $CI_DST"
    fi
  else
    echo "⚠️  CI template not found under templates/github-workflows, skipping"
  fi
fi

# Summary
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Observability scaffolding complete for: $TARGET_REPO"
echo
echo "Next steps:"
echo "  1) Review: $OBS_DIR/ENV_VARS.md"
echo "  2) Configure: $OBS_DIR/collector/otel-collector.yaml"
echo "  3) Instrument your application (see docs/coralogix.md)"
echo "  4) Validate: .gobuildme/scripts/bash/observability-sanity.sh --repo $TARGET_REPO"

