#!/usr/bin/env bash
# persona-lint.sh — Advisory (exit 0) persona coverage checker
#
# Checks whether persona-required sections exist in feature artifacts.
# Looks at .gobuildme/specs/<feature>/{request.md,spec.md,plan.md}.
#
# Usage:
#   persona-lint.sh [--repo <path>] [--feature <slug>] [--json]
#
# Output:
#   - Human-readable summary by default
#   - JSON when --json is passed
#
# Notes:
#   - Non-destructive; always exits 0. Intended for warn-first flows.

set -euo pipefail

REPO_ROOT="${PWD}"
FEATURE=""
JSON_OUT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_ROOT="$2"; shift 2 ;;
    --feature)
      FEATURE="$2"; shift 2 ;;
    --json)
      JSON_OUT=true; shift ;;
    *) shift ;;
  esac
done

cd "$REPO_ROOT" 2>/dev/null || true

# Locate feature dir
SPECS_ROOT=".gobuildme/specs"
if [[ -n "${FEATURE}" ]]; then
  FEATURE_DIR="$SPECS_ROOT/$FEATURE"
elif [[ -n "${SPECIFY_FEATURE:-}" ]]; then
  FEATURE_DIR="$SPECS_ROOT/$SPECIFY_FEATURE"
else
  # pick the only feature that has spec.md if unambiguous
  count=$(find "$SPECS_ROOT" -maxdepth 2 -type f -name spec.md 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" == "1" ]]; then
    FEATURE_DIR=$(dirname "$(find "$SPECS_ROOT" -maxdepth 2 -type f -name spec.md)")
  else
    FEATURE_DIR=""
  fi
fi

# Determine persona id (feature overrides project default)
PERSONA_ID=""
if [[ -n "$FEATURE_DIR" && -f "$FEATURE_DIR/persona.yaml" ]]; then
  # top-level key only
  PERSONA_ID=$(awk '/^feature_persona:/ {sub(/^feature_persona:[ ]*/, ""); gsub(/"/, ""); print; exit}' "$FEATURE_DIR/persona.yaml")
fi
if [[ -z "$PERSONA_ID" && -f ".gobuildme/config/personas.yaml" ]]; then
  PERSONA_ID=$(awk '/^default_persona:/ {sub(/^default_persona:[ ]*/, ""); gsub(/"/, ""); print; exit}' .gobuildme/config/personas.yaml)
fi

PERSONA_FILE=".gobuildme/personas/${PERSONA_ID}.yaml"
# Note: Associative arrays removed for POSIX sh compatibility
# File mappings are handled via case statement below (lines 108-116)

required_tmp="$(mktemp)"
cleanup(){ rm -f "$required_tmp"; }
trap cleanup EXIT

if [[ -z "$PERSONA_ID" || ! -f "$PERSONA_FILE" ]]; then
  # Nothing to check
  if $JSON_OUT; then
    printf '{"ok":true,"reason":"no-persona","feature":"%s"}\n' "${FEATURE_DIR:-}" || true
  else
    echo "[persona-lint] No persona configured or file missing; skipping."
  fi
  exit 0
fi

# Extract required_sections into lines: <cmd>\t<heading>
awk '
  /^required_sections:/ { inreq=1; next }
  inreq==1 && /^[^ ]/ { inreq=0 }  # stop on next top-level key
  inreq==1 && /^[ ]{2}"\// { 
    # command key like:   "/plan":
    cmd=$0; sub(/^[ ]{2}"/, "", cmd); sub(/":.*/, "", cmd); current=cmd; next
  }
  inreq==1 && /^[ ]{4}- / {
    s=$0; sub(/^[ ]{4}-[ ]*/, "", s)
    print current "\t" s
  }
' "$PERSONA_FILE" > "$required_tmp" || true

checks_json="["
first=true
slug=""
if [[ -n "$FEATURE_DIR" ]]; then slug="$(basename "$FEATURE_DIR")"; fi

while IFS=$'\t' read -r CMD HEAD; do
  [[ -z "$CMD" || -z "$HEAD" ]] && continue
  status="unknown"; target=""
  # Candidate files per command
  candidates=()
  case "$CMD" in
    "/request") candidates+=("$FEATURE_DIR/request.md");;
    "/specify") candidates+=("$FEATURE_DIR/spec.md");;
    "/plan")    candidates+=("$FEATURE_DIR/plan.md");;
    "/prd")     candidates+=("$FEATURE_DIR/prd.md");;
    "/tests")   candidates+=("$FEATURE_DIR/tests.md" "$FEATURE_DIR/plan.md");;
    "/review")  candidates+=("$FEATURE_DIR/plan.md" ".docs/implementations/$slug/implementation-summary.md");;
    *) : ;; # Unknown command; no candidates
  esac
  for f in "${candidates[@]}"; do
    [[ -z "$f" || ! -f "$f" ]] && continue
    if grep -qiF "$HEAD" "$f"; then status="present"; target="$f"; break; else status="missing"; target="$f"; fi
  done
  if $JSON_OUT; then
    $first || checks_json+=" ,"
    first=false
    checks_json+="{\"command\":\"$CMD\",\"heading\":\"$HEAD\",\"file\":\"${target:-}\",\"status\":\"$status\"}"
  else
    printf "%-9s %-10s %s (%s)\n" "$CMD" "$status" "$HEAD" "${target:-N/A}"
  fi
done < "$required_tmp"

if $JSON_OUT; then
  checks_json+="]"
  printf '{"ok":true,"persona":"%s","feature":"%s","checks":%s}\n' "$PERSONA_ID" "${FEATURE_DIR:-}" "$checks_json"
fi

exit 0
