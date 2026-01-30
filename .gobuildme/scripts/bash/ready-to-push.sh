#!/usr/bin/env bash
# Purpose : Run the preflight stack before executing `/push`.
# Why     : Ensures developers run the full battery of checks prior to opening
#           a pull request, catching issues locally.
# How     : Sequentially invokes format, lint, type, test, security, and branch
#           status scripts, aggregating their output for review.
set -euo pipefail

echo "== Pre-commit: format =="; .gobuildme/scripts/bash/run-format.sh || true
echo "== Lint =="; .gobuildme/scripts/bash/run-lint.sh || true
echo "== Type check =="; .gobuildme/scripts/bash/run-type-check.sh || true
echo "== Tests =="; .gobuildme/scripts/bash/run-tests.sh || true
echo "== Security =="; .gobuildme/scripts/bash/security-scan.sh || true
echo "== Branch status =="; .gobuildme/scripts/bash/branch-status.sh || true

# Load common.sh and feature paths once for all feature-aware checks
if [ -f .gobuildme/scripts/bash/common.sh ]; then
  # shellcheck disable=SC1091
  source .gobuildme/scripts/bash/common.sh
  eval "$(get_feature_paths)"
  COMMON_LOADED=true
else
  echo "common.sh not found — feature-aware checks will be skipped"
  COMMON_LOADED=false
fi

# Slice scope consistency validation (advisory by default, blocking in strict mode)
echo "== Slice scope validation =="
if [ "$COMMON_LOADED" = true ]; then
  if [ -f "$FEATURE_DIR/scope.json" ]; then
    if [ -f .gobuildme/scripts/bash/validate-slice-consistency.sh ]; then
      # Use CURRENT_BRANCH (not basename of FEATURE_DIR) to avoid ambiguity for epic slices
      VALIDATION_OUTPUT=$(.gobuildme/scripts/bash/validate-slice-consistency.sh --feature "$CURRENT_BRANCH" 2>&1) || VALIDATION_EXIT=$?
      echo "$VALIDATION_OUTPUT"

      # Check enforcement mode from constitution
      ENFORCEMENT_MODE="warn"
      CONST_PATH=$(get_constitution_path 2>/dev/null || echo "")
      if [ -n "$CONST_PATH" ] && [ -f "$CONST_PATH" ]; then
        if grep -q '<!-- scope_enforcement: strict -->' "$CONST_PATH" 2>/dev/null; then
          ENFORCEMENT_MODE="strict"
        fi
      fi

      # In strict mode, non-zero exit blocks push
      if [ "${VALIDATION_EXIT:-0}" -ne 0 ] && [ "$ENFORCEMENT_MODE" = "strict" ]; then
        echo "ERROR: Slice scope violations detected and enforcement mode is strict."
        echo "Fix scope violations before pushing, or update scope.json if changes are intentional."
        exit 1
      fi
    else
      echo "Slice validation script not found — skipping"
    fi
  else
    echo "No scope.json found — slice validation skipped (standalone feature or not yet refined)"
  fi
else
  echo "Skipped (common.sh not loaded)"
fi

# Advisory PRD presence (non-blocking)
echo "== PRD status =="
if [ "$COMMON_LOADED" = true ]; then
  if [ -f "$PRD" ]; then
    echo "PRD found: $PRD"
  else
    echo "PRD not found for current feature ($FEATURE_DIR) — optional unless changing user behavior/commitments."
  fi
else
  echo "Skipped (common.sh not loaded)"
fi

echo "\nAll checks executed. Review outputs above; if clean, you're ready to push."
