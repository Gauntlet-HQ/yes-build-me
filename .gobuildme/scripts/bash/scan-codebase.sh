#!/usr/bin/env bash
# Purpose : Emit a repository fingerprint to guide planning conversations.
# Why     : Helps `/plan` and `/analyze` steps understand active languages,
#           tooling, and boundaries automatically.
# How     : Collects manifest/config hints, counts file extensions, and outputs
#           JSON or human-readable summaries.
set -euo pipefail

# scan-codebase.sh --json
# Emits a lightweight JSON summary of the repo to guide plan generation.

JSON=false
for arg in "$@"; do
  case "$arg" in
    --json) JSON=true ;;
    --help|-h) echo "Usage: $0 [--json]"; exit 0 ;;
  esac
done

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

# Detect presence helpers
has() { [ -e "$1" ] && echo "$1"; }
has_dir() { [ -d "$1" ] && echo "$1"; }

# Collect signals
files=(
  $(has pyproject.toml)
  $(has requirements.txt)
  $(has poetry.lock)
  $(has uv.lock)
  $(has package.json)
  $(has yarn.lock)
  $(has pnpm-lock.yaml)
  $(has bun.lockb)
  $(has go.mod)
  $(has Cargo.toml)
  $(has Gemfile)
  $(has composer.json)
  $(has build.gradle) $(has build.gradle.kts) $(has pom.xml)
  $(has .pre-commit-config.yaml)
  $(has .editorconfig)
  $(has .flake8) $(has setup.cfg)
  $(has .eslintrc) $(has .eslintrc.js) $(has .eslintrc.cjs) $(has .eslintrc.json) $(has eslint.config.js) $(has eslint.config.mjs) $(has eslint.config.cjs)
  $(has .pylintrc)
  $(has pytest.ini) $(has tox.ini)
  $(has jest.config.js) $(has vitest.config.ts)
  $(has .golangci.yml)
  $(has rustfmt.toml) $(has Clippy.toml)
  $(has .bandit)
  $(has .semgrep.yml) $(has .semgrep.yaml)
  $(has .snyk) $(has snyk.yml)
  $(has .dockerignore) $(has Dockerfile)
  $(has .deepsource.toml)
  $(has .prettierrc) $(has .prettier.config.js)
  $(has .ruff.toml)
  $(has .hadolint.yaml)
  $(has .tflint.hcl)
  $(has docs/ARCHITECTURE.md) $(has ARCHITECTURE.md)
  $(has SECURITY.md) $(has CODE_OF_CONDUCT.md)
  $(has CODEOWNERS)
)

# Languages by extension (top few)
ext_counts=$(find . -type f \
  -not -path './.git/*' \
  -not -path './.venv/*' \
  -not -path './node_modules/*' \
  -not -path './dist/*' \
  -not -path './build/*' \
  -not -path './.gobuildme/*' \
  -name '*.*' | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -n 20)

# Package managers
pkg_mans=()
[ -f package.json ] && pkg_mans+=("node")
[ -f yarn.lock ] && pkg_mans+=("yarn")
[ -f pnpm-lock.yaml ] && pkg_mans+=("pnpm")
[ -f bun.lockb ] && pkg_mans+=("bun")
[ -f pyproject.toml ] && pkg_mans+=("python-pyproject")
[ -f requirements.txt ] && pkg_mans+=("python-pip")
[ -f poetry.lock ] && pkg_mans+=("poetry")
[ -f uv.lock ] && pkg_mans+=("uv")
[ -f go.mod ] && pkg_mans+=("go-mod")
[ -f Cargo.toml ] && pkg_mans+=("cargo")
[ -f Gemfile ] && pkg_mans+=("bundler")
[ -f composer.json ] && pkg_mans+=("composer")
[ -f pom.xml ] && pkg_mans+=("maven")
[ -f build.gradle ] || [ -f build.gradle.kts ] && pkg_mans+=("gradle")

# CI workflows
ci_workflows=$(ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null || true)

# Heuristic boundaries
boundaries=(
  $(has_dir src)
  $(has_dir backend) $(has_dir frontend)
  $(has_dir api)
  $(has_dir cmd) $(has_dir internal) $(has_dir pkg)
  $(has_dir services) $(has_dir models)
)

json_escape() { python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || perl -MJSON::PP -0777 -ne 'print encode_json($_)' 2>/dev/null || sed 's/"/\\"/g'; }

ext_counts_json=$(printf '%s\n' "$ext_counts" | sed 's/^ *//' | awk '{print "[\""$2"\","$1"]"}' | paste -sd, - | sed 's/^/[/' | sed 's/$/]/')
files_json=$(printf '%s\n' "${files[@]}" | sed '/^$/d' | awk '{print "\""$0"\""}' | paste -sd, - | sed 's/^/[/' | sed 's/$/]/')
pkg_mans_json=$(printf '%s\n' "${pkg_mans[@]}" | sed '/^$/d' | awk '{print "\""$0"\""}' | paste -sd, - | sed 's/^/[/' | sed 's/$/]/')
ci_json=$(printf '%s\n' $ci_workflows | sed '/^$/d' | awk '{print "\""$0"\""}' | paste -sd, - | sed 's/^/[/' | sed 's/$/]/')
bound_json=$(printf '%s\n' "${boundaries[@]}" | sed '/^$/d' | awk '{print "\""$0"\""}' | paste -sd, - | sed 's/^/[/' | sed 's/$/]/')

out="{\n  \"repo_root\": \"$repo_root\",\n  \"languages_by_ext\": $ext_counts_json,\n  \"package_managers\": $pkg_mans_json,\n  \"important_files\": $files_json,\n  \"ci_workflows\": $ci_json,\n  \"boundaries\": $bound_json\n}"

if $JSON; then
  printf '%s\n' "$out"
else
  echo "$out" | sed 's/,/\n  /g'
fi
