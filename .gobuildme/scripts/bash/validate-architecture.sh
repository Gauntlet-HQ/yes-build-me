#!/usr/bin/env bash
# Purpose : Enforce high-level architectural boundaries before implementation.
# Why     : Prevents accidental cross-layer coupling that would violate the
#           agreements captured during `/plan` and `/analyze` stages.
# How     : Runs optional augment validators when available and falls back to
#           heuristics that scan for imports violating service boundaries.
set -euo pipefail

# Always execute from repository root to respect expected directory layout.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

errors=0
# First, defer to Augment's architecture validator if installed.
if command -v augment >/dev/null 2>&1; then
  if augment validate architecture; then :; else errors=$((errors+1)); fi
fi

# Heuristic boundary checks
if [ -d services ] && [ -d api ]; then
  if command -v rg >/dev/null 2>&1; then
    hit=$(rg -n "from\\s+api|import\\s+api" services 2>/dev/null | head -n 1 || true)
  else
    hit=$(grep -REn "from[[:space:]]+api|import[[:space:]]+api" services 2>/dev/null | head -n 1 || true)
  fi
  if [ -n "$hit" ]; then
    echo "Boundary violation: services -> api import detected" >&2
    errors=$((errors+1))
  fi
fi

# Additional boundary checks between frontend and backend layers.
if [ -d frontend ] && [ -d backend ]; then
  if command -v rg >/dev/null 2>&1; then
    hit=$(rg -n "from\\s+backend|import\\s+backend" frontend 2>/dev/null | head -n 1 || true)
  else
    hit=$(grep -REn "from[[:space:]]+backend|import[[:space:]]+backend" frontend 2>/dev/null | head -n 1 || true)
  fi
  if [ -n "$hit" ]; then
    echo "Boundary violation: frontend -> backend import detected" >&2
    errors=$((errors+1))
  fi
fi

# Check for direct database access from presentation layer.
if [ -d controllers ] && [ -d models ]; then
  if command -v rg >/dev/null 2>&1; then
    hit=$(rg -n "SELECT|INSERT|UPDATE|DELETE" controllers --type py --type js --type ts 2>/dev/null | head -n 1 || true)
  else
    hit=$(find controllers -name "*.py" -o -name "*.js" -o -name "*.ts" | xargs grep -l "SELECT\|INSERT\|UPDATE\|DELETE" 2>/dev/null | head -n 1 || true)
  fi
  if [ -n "$hit" ]; then
    echo "Boundary violation: Direct SQL in controllers detected (should use models/services)" >&2
    errors=$((errors+1))
  fi
fi

if [ $errors -gt 0 ]; then
  echo "Architecture validation failed ($errors issue(s))" >&2
  exit 1
fi
echo "Architecture validation passed"
