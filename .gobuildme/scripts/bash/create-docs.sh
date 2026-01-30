#!/usr/bin/env bash
# Purpose : Ensure baseline documentation artifacts exist for new features.
# Why     : Gives contributors quickstart guidance and keeps the README linked
#           to deeper docs during early project bootstrapping.
# How     : Seeds docs/quickstart.md from templates and appends a README section
#           when absent.
set -euo pipefail

FEATURE_TITLE="${1:-}"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

# Resolve feature paths using common helpers (if available)
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common.sh" ]; then
  # shellcheck disable=SC1090
  source "$SCRIPT_DIR/common.sh"
  eval "$(get_feature_paths)"
fi

# Ensure quickstart
if [ ! -f docs/quickstart.md ]; then
  mkdir -p docs
  if [ -f templates/quickstart-template.md ]; then
    cp templates/quickstart-template.md docs/quickstart.md
  else
    echo "# Quickstart" > docs/quickstart.md
  fi
  echo "Created docs/quickstart.md"
fi

# Light README updates (only append links if not present)
README=README.md
if [ -f "$README" ]; then
  if ! grep -q "Quickstart" "$README"; then
    printf "\n## Quickstart\nSee docs/quickstart.md\n" >> "$README"
    echo "Updated README.md with Quickstart section"
  fi

  # Insert Feature Docs Index (idempotent)
  if ! grep -q "gobuildme:feature-docs-index" "$README"; then
    {
      echo ""
      echo "<!-- gobuildme:feature-docs-index -->"
      echo "## Feature Docs Index"
      if [ -n "${FEATURE_DIR:-}" ]; then
        [ -f "$FEATURE_DIR/prd.md" ] && echo "- PRD: \\`$FEATURE_DIR/prd.md\\`"
        [ -f "$FEATURE_DIR/request.md" ] && echo "- Request: \\`$FEATURE_DIR/request.md\\`"
        [ -f "$FEATURE_DIR/spec.md" ] && echo "- Spec: \\`$FEATURE_DIR/spec.md\\`"
        [ -f "$FEATURE_DIR/plan.md" ] && echo "- Plan: \\`$FEATURE_DIR/plan.md\\`"
        [ -f "$FEATURE_DIR/tasks.md" ] && echo "- Tasks: \\`$FEATURE_DIR/tasks.md\\`"
        [ -f "$FEATURE_DIR/design.md" ] && echo "- Design: \\`$FEATURE_DIR/design.md\\`"
      else
        echo "- Run /request or /specify to initialize a feature directory."
      fi
    } >> "$README"
    echo "Updated README.md with Feature Docs Index"
  fi
fi

echo "DOCS: updated"
