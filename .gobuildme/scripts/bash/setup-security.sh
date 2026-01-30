#!/usr/bin/env bash
# Purpose : Bootstrap a security workflow with optional CodeQL analysis.
# Why     : Gives teams a baseline security posture without hand-curating
#           GitHub Actions YAML every time.
# How     : Generates a security.yml with Semgrep scanning and, if requested,
#           appends a CodeQL job tuned to detected languages.
set -euo pipefail

# Flag to toggle CodeQL job generation.
CODEQL=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --codeql) CODEQL=true; shift ;;
    --help|-h) echo "Usage: $0 [--codeql]"; exit 0 ;;
    *) shift ;;
  esac
done

# Write workflows relative to repository root regardless of invocation path.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"
mkdir -p .github/workflows

# Always emit the Semgrep job since it is fast and language-agnostic.
cat > .github/workflows/security.yml <<'YAML'
name: Security

on:
  push:
    branches: [ main ]
  pull_request:
  schedule:
    - cron: '0 3 * * 1'

jobs:
  semgrep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: returntocorp/semgrep-action@v1
        with:
          config: p/ci
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
YAML

if $CODEQL; then
  # Detect languages for CodeQL (supported: js/ts, python, go, java).
  langs=()
  [ -f package.json ] && langs+=("javascript-typescript")
  { [ -f pyproject.toml ] || [ -f requirements.txt ]; } && langs+=("python")
  [ -f go.mod ] && langs+=("go")
  { [ -f pom.xml ] || [ -f build.gradle ] || [ -f build.gradle.kts ]; } && langs+=("java")
  # Default to javascript-typescript when none detected.
  lang_str=$(IFS=, ; echo "${langs[*]:-javascript-typescript}")

  cat >> .github/workflows/security.yml <<YAML

  codeql:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      actions: read
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: $lang_str
      - uses: github/codeql-action/autobuild@v3
      - uses: github/codeql-action/analyze@v3
        with:
          category: '/language:$lang_str'
YAML
fi

echo "Wrote .github/workflows/security.yml (CodeQL=$CODEQL)"
