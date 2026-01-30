#!/usr/bin/env bash
# Purpose: Minimal DevSpace detection emitting JSON booleans.
# Exit code is always 0.

set -euo pipefail

REPO="${GOBUILDME_TARGET_REPO:-}"
for arg in "$@"; do
  case "$arg" in
    --repo=*) REPO="${arg#*=}" ;;
    --repo) shift; REPO="${1:-}" ;;
  esac
done
if [[ -z "$REPO" ]]; then REPO="$(pwd)"; fi

has_cli=false
has_cfg=false
cfg_path=""

if command -v devspace >/dev/null 2>&1; then has_cli=true; fi
for p in devspace.yaml devspace.yml .devspace/devspace.yaml; do
  if [[ -f "$REPO/$p" ]]; then cfg_path="$REPO/$p"; has_cfg=true; break; fi
done

# Escape quotes in path for JSON
cfg_path_escaped=$(printf '%s\n' "$cfg_path" | sed 's/"/\\"/g')
printf '{"has_cli":%s,"has_config":%s,"config_path":"%s"}\n' \
  "$has_cli" "$has_cfg" "$cfg_path_escaped"

exit 0
