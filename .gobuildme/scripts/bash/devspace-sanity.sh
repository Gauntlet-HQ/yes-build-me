#!/usr/bin/env bash
# Purpose: Non-destructive DevSpace sanity checks (optional advisory).
# Behavior: Never mutates cluster or devspace.yaml. Always exits 0.

set -euo pipefail

JSON=false
REPO=""
for arg in "$@"; do
    case "$arg" in
        --json) JSON=true ;;
        --repo=*) REPO="${arg#*=}" ;;
        --repo) shift; REPO="${1:-}" ;;
        --help|-h)
      cat << 'EOF'
Usage: devspace-sanity.sh [--json]

Checks (non-destructive):
  - DevSpace CLI presence
  - devspace.yaml presence (repo root or .devspace/devspace.yaml)
  - 'devspace --version' and 'devspace print config' basic validation (no cluster ops)

Exit code is always 0. Intended for advisory checks in templates/CI.
  --repo <path>     Run checks against target repo at <path> (defaults to CWD or $GOBUILDME_TARGET_REPO)
EOF
      exit 0
      ;;
    esac
done

has_cli=false
has_cfg=false
cli_version=""
cfg_path=""
print_ok=false

# Resolve target repo path
if [[ -z "$REPO" && -n "${GOBUILDME_TARGET_REPO:-}" ]]; then
  REPO="$GOBUILDME_TARGET_REPO"
fi
if [[ -z "$REPO" ]]; then
  REPO="$(pwd)"
fi

if command -v devspace >/dev/null 2>&1; then
  has_cli=true
  set +e
  cli_version=$(devspace --version 2>/dev/null | head -n1)
  set -e
fi

for p in devspace.yaml devspace.yml .devspace/devspace.yaml; do
  if [[ -f "$REPO/$p" ]]; then cfg_path="$REPO/$p"; has_cfg=true; break; fi
done

if $has_cli && $has_cfg; then
  set +e
  ( cd "$REPO" && devspace print config >/dev/null 2>&1 )
  rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then print_ok=true; fi
fi

if $JSON; then
  # Escape quotes in version and path for JSON
  cli_version_escaped=$(printf '%s\n' "$cli_version" | sed 's/"/\\"/g')
  cfg_path_escaped=$(printf '%s\n' "$cfg_path" | sed 's/"/\\"/g')
  printf '{"has_cli":%s,"has_config":%s,"cli_version":"%s","config_path":"%s","print_config_ok":%s}\n' \
    "$has_cli" "$has_cfg" "$cli_version_escaped" "$cfg_path_escaped" "$print_ok"
else
  echo "DevSpace CLI: $($has_cli && echo present || echo missing)" $([ -n "$cli_version" ] && printf "(%s)" "$cli_version" || printf "")
  echo "DevSpace config: $($has_cfg && echo found || echo missing)" $([ -n "$cfg_path" ] && printf "(%s)" "$cfg_path" || printf "")
  if $has_cli && $has_cfg; then
    if $print_ok; then echo "Config parse: OK"; else echo "Config parse: WARNING (devspace print config failed)"; fi
  fi
fi

exit 0
