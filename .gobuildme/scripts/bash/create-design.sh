#!/usr/bin/env bash
# Purpose : Bootstrap a feature design document aligned with the current branch.
# Why     : Keeps design artifacts colocated with feature specs so teams capture
#           architectural intent before implementation.
# How     : Resolves the feature directory, copies the design template, and
#           reports the generated file path.
set -euo pipefail

# Optional positional argument lets callers override the inferred feature title.
FEATURE_TITLE="${1:-}"
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

BRANCH=$(get_current_branch)
# Normalize the provided title or branch into a stable slug for folder layout.
FEATURE_SLUG=$(echo "${FEATURE_TITLE:-$BRANCH}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g;s/^-//;s/-$//')

FEATURE_DIR="$(get_feature_dir "$REPO_ROOT" "$FEATURE_SLUG")"
mkdir -p "$FEATURE_DIR"
DESIGN_FILE="$FEATURE_DIR/design.md"

# Prefer repository design template when present to keep formatting consistent.
TPL="templates/design-template.md"
if [ -f "$TPL" ]; then
  cp "$TPL" "$DESIGN_FILE"
else
  echo "# Design Document" > "$DESIGN_FILE"
fi

echo "DESIGN: $DESIGN_FILE"
