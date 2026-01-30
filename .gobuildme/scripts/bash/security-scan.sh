#!/usr/bin/env bash
# Purpose : Run lightweight dependency and static security checks across stacks.
# Why     : Gives developers a single command to surface known vulnerabilities
#           during Spec-Driven workflows before code reaches review.
# How     : Detects installed security tools per ecosystem and executes them on
#           best-effort basis without failing the entire workflow.
set -euo pipefail

# Run scans from repository root regardless of invocation location.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

# Simple helper to check if an executable is available.
has() { command -v "$1" >/dev/null 2>&1; }

echo "== Security: Python =="
if [ -f pyproject.toml ] || [ -f requirements.txt ]; then
  if has safety; then safety check || true; fi
  if has bandit; then bandit -r . || true; fi
  if has pip-audit; then pip-audit -r requirements.txt 2>/dev/null || pip-audit || true; fi
fi

echo "== Security: Node =="
if [ -f package.json ]; then
  if has npm; then npm audit --audit-level=moderate || true; fi
  if has pnpm; then pnpm audit || true; fi
  if has yarn; then yarn audit || true; fi
fi

echo "== Security: PHP =="
if [ -f composer.json ] && has composer; then
  composer audit || true
fi

echo "== Security: Go =="
if [ -f go.mod ] && has govulncheck; then govulncheck ./... || true; fi

echo "== Security: Rust =="
if [ -f Cargo.toml ] && has cargo-audit; then cargo audit || true; fi

echo "== Security: Semgrep (if configured) =="
# Semgrep requires project-specific rule configuration; detect before running.
if has semgrep && [ -f .semgrep.yml -o -f .semgrep.yaml ]; then semgrep ci || semgrep scan || true; fi
