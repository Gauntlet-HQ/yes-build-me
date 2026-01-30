#!/usr/bin/env bash
# Purpose: Validate OpenTelemetry + Coralogix observability setup in a target repo (advisory only)
# Behavior: Non-destructive; always exits 0. Prints human output or JSON summary.
# Usage: observability-sanity.sh [--repo <path>] [--json]

set -euo pipefail

JSON=false
TARGET_REPO=""

print_help() {
  cat << 'EOF'
Usage: observability-sanity.sh [--repo <path>] [--json]

Checks (non-destructive):
  - OTel Collector config presence (.gobuildme/observability/collector/otel-collector.yaml)
  - Required env placeholders in collector config (CORALOGIX_* keys)
  - Environment variables documentation (.gobuildme/observability/ENV_VARS.md)
  - SLO files present; count Coralogix-based SLIs (backend: coralogix)
  - Presence of alert definitions in SLOs

Notes:
  - Exit code is always 0 (advisory). Intended for CI and local validation.
  - You can also set GOBUILDME_TARGET_REPO to point at a target repository.
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=true; shift ;;
    --repo) TARGET_REPO="${2:-}"; shift 2 ;;
    --repo=*) TARGET_REPO="${1#*=}"; shift ;;
    --help|-h) print_help; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; print_help; exit 0 ;;
  esac
done

# Resolve target repo
if [[ -z "$TARGET_REPO" && -n "${GOBUILDME_TARGET_REPO:-}" ]]; then
  TARGET_REPO="$GOBUILDME_TARGET_REPO"
fi
if [[ -z "$TARGET_REPO" ]]; then
  TARGET_REPO="$(pwd)"
fi

# Initialize results
has_collector=false
collector_path=""
collector_has_key=false
collector_has_domain=false
has_env_doc=false
slo_count=0
coralogix_slis=0
alerts_files=0

# Check collector config
collector_path="$TARGET_REPO/.gobuildme/observability/collector/otel-collector.yaml"
if [[ -f "$collector_path" ]]; then
  has_collector=true
  if grep -q 'CORALOGIX_PRIVATE_KEY' "$collector_path" 2>/dev/null; then collector_has_key=true; fi
  if grep -q 'CORALOGIX_DOMAIN' "$collector_path" 2>/dev/null; then collector_has_domain=true; fi
fi

# Check env doc
env_doc="$TARGET_REPO/.gobuildme/observability/ENV_VARS.md"
[[ -f "$env_doc" ]] && has_env_doc=true

# SLO scan
if [[ -d "$TARGET_REPO/.gobuildme/specs" ]]; then
  slo_tmp=$(mktemp)
  find "$TARGET_REPO/.gobuildme/specs" -maxdepth 2 -name slo.yaml -print0 2>/dev/null > "$slo_tmp" || true
  while IFS= read -r -d '' f; do
    ((slo_count++))
    if grep -Eq '\bbackend:\s*coralogix\b' "$f" 2>/dev/null; then ((coralogix_slis++)); fi
    if grep -q '^alerts:' "$f" 2>/dev/null; then ((alerts_files++)); fi
  done < "$slo_tmp"
  rm -f "$slo_tmp"
fi

# Output
if $JSON; then
  printf '{"target":"%s","collector":%s,"collector_path":"%s","collector_has_key":%s,"collector_has_domain":%s,"has_env_doc":%s,"slo_files":%d,"coralogix_slis":%d,"alerts_files":%d}\n' \
    "$TARGET_REPO" \
    "$([[ $has_collector == true ]] && echo true || echo false)" \
    "$collector_path" \
    "$([[ $collector_has_key == true ]] && echo true || echo false)" \
    "$([[ $collector_has_domain == true ]] && echo true || echo false)" \
    "$([[ $has_env_doc == true ]] && echo true || echo false)" \
    "$slo_count" "$coralogix_slis" "$alerts_files"
else
  echo "🔍 Observability Sanity Check"
  echo "Target: $TARGET_REPO"
  echo
  if $has_collector; then echo "✓ Collector config: $collector_path"; else echo "⚠️ Collector config not found"; fi
  if $has_collector; then
    echo "  - CORALOGIX_PRIVATE_KEY placeholder: $($collector_has_key && echo OK || echo MISSING)"
    echo "  - CORALOGIX_DOMAIN placeholder: $($collector_has_domain && echo OK || echo MISSING)"
  fi
  echo "$( $has_env_doc && echo '✓' || echo '⚠️' ) ENV_VARS.md present"
  if (( slo_count > 0 )); then
    echo "✓ SLO files found: $slo_count"
    echo "  - Coralogix-based SLIs: $coralogix_slis"
    echo "  - SLO files with alerts: $alerts_files"
  else
    echo "⚠️ No SLO files found under .gobuildme/specs"
  fi
  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Advisory check complete (exit code always 0)"
fi

exit 0

