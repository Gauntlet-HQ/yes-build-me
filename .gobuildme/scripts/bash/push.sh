#!/usr/bin/env bash
# Purpose : Automate the `/push` command by enforcing preflight checks and
#           opening GitHub pull requests.
# Why     : Ensures branches are clean, gated, and properly documented before
#           they leave the feature workflow.
# How     : Parses CLI options, runs review gates, pushes to origin, prepares a
#           contextual PR body, and invokes `gh pr create` with metadata.
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

BASE_BRANCH="main"
DRAFT="false"
LABELS=""
REVIEWERS=""
TEAM_REVIEWERS=""
TITLE=""
BODY_FILE=""
VERIFY="true"
LITE="false"

for arg in "$@"; do
  case "$arg" in
    --base*) BASE_BRANCH="${arg#*=}" ;;
    --draft) DRAFT="true" ;;
    --labels*) LABELS="${arg#*=}" ;;
    --reviewers*) REVIEWERS="${arg#*=}" ;;
    --team-reviewers*) TEAM_REVIEWERS="${arg#*=}" ;;
    --title*) TITLE="${arg#*=}" ;;
    --body-file*) BODY_FILE="${arg#*=}" ;;
    --no-verify) VERIFY="false" ;;
    --lite) LITE="true" ;;
  esac
done

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

# Preconditions
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not inside a git repository." >&2
  exit 1
fi

BRANCH=$(get_current_branch)
if ! check_feature_branch "$BRANCH" "true"; then
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: Working tree is not clean. Commit or stash changes before pushing." >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Error: Remote 'origin' not configured." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: GitHub CLI 'gh' is required. Install: https://cli.github.com/" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Error: 'gh' is not authenticated. Run: gh auth login" >&2
  exit 1
fi

# Preflight checks invoke readiness scripts unless explicitly disabled.
if [[ "$VERIFY" == "true" ]]; then
  if [[ "$LITE" == "true" ]]; then
    # Lite mode: use lightweight preflight, skip comprehensive review
    if [[ -x .gobuildme/scripts/bash/ready-to-push-lite.sh ]]; then
      echo "Running lite preflight: .gobuildme/scripts/bash/ready-to-push-lite.sh"
      .gobuildme/scripts/bash/ready-to-push-lite.sh || {
        echo "Error: Lite preflight checks failed. Fix issues or pass --no-verify to override." >&2
        exit 1
      }
    elif [[ -x .gobuildme/scripts/bash/ready-to-push.sh ]]; then
      echo "Warning: ready-to-push-lite.sh not found; falling back to full preflight." >&2
      .gobuildme/scripts/bash/ready-to-push.sh || {
        echo "Error: Preflight checks failed. Fix issues or pass --no-verify to override." >&2
        exit 1
      }
    else
      echo "Warning: No preflight script found; skipping preflight." >&2
    fi
    echo "ℹ️  Lite mode: skipping comprehensive review"
  else
    # Full mode: run full preflight + comprehensive review
    if [[ -x .gobuildme/scripts/bash/ready-to-push.sh ]]; then
      echo "Running preflight: .gobuildme/scripts/bash/ready-to-push.sh"
      .gobuildme/scripts/bash/ready-to-push.sh || {
        echo "Error: Preflight checks failed. Fix issues or pass --no-verify to override." >&2
        exit 1
      }
    else
      echo "Warning: .gobuildme/scripts/bash/ready-to-push.sh not found; skipping preflight." >&2
    fi

    # Enforce review gating if available
    if [[ -x .gobuildme/scripts/bash/comprehensive-review.sh ]]; then
      echo "Running review gate: .gobuildme/scripts/bash/comprehensive-review.sh"
      .gobuildme/scripts/bash/comprehensive-review.sh >/dev/null || {
        echo "Error: Review gate failed. Resolve blocking issues reported by /review before pushing." >&2
        exit 1
      }
    else
      echo "Warning: .gobuildme/scripts/bash/comprehensive-review.sh not found; skipping review gate." >&2
    fi
  fi
fi

# Ensure upstream tracking branch exists before pushing.
if ! git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
  echo "Pushing branch '$BRANCH' to origin..."
  git push -u origin "$BRANCH"
else
  echo "Pushing latest commits for '$BRANCH'..."
  git push
fi

# Build PR body if not provided
TMP_BODY=""
if [[ -z "$BODY_FILE" ]]; then
  eval $(get_feature_paths)
  TMP_BODY=$(mktemp)
  {
    echo "## Summary"
    if [[ -f "$REQUEST_FILE" ]]; then
      sed -n '1,40p' "$REQUEST_FILE" | sed 's/^/> /'
    elif [[ -f "$FEATURE_SPEC" ]]; then
      sed -n '1,40p' "$FEATURE_SPEC" | sed 's/^/> /'
    else
      echo "> No request/spec found; summarize the change here."
    fi
    echo
    echo "## Plan Highlights"
    if [[ -f "$IMPL_PLAN" ]]; then
      awk '/^## Technical Context/{flag=1;print;next}/^## /{if(flag){exit}}flag' "$IMPL_PLAN" || true
    else
      echo "- See linked plan."
    fi
    echo
    echo "## Files"
    echo "- request: ${REQUEST_FILE:-"(none)"}"
    echo "- spec: ${FEATURE_SPEC:-"(none)"}"
    echo "- plan: ${IMPL_PLAN:-"(none)"}"
    echo
    echo "## Checks"
    echo "- Preflight: $( [[ "$VERIFY" == "true" ]] && echo "passed" || echo "skipped" )"
  } > "$TMP_BODY"
  BODY_FILE="$TMP_BODY"
fi

# Title defaults to "branch → base" when not supplied.
if [[ -z "$TITLE" ]]; then
  TITLE="$BRANCH → $BASE_BRANCH"
fi

set +e
ARGS=(pr create --base "$BASE_BRANCH" --head "$BRANCH" --title "$TITLE")
[[ -n "$BODY_FILE" ]] && ARGS+=(--body-file "$BODY_FILE")
[[ "$DRAFT" == "true" ]] && ARGS+=(--draft)

IFS=',' read -r -a arr <<< "${LABELS,,}"
for l in "${arr[@]}"; do [[ -n "$l" ]] && ARGS+=(--label "$l"); done

IFS=',' read -r -a rarr <<< "$REVIEWERS"
for r in "${rarr[@]}"; do [[ -n "$r" ]] && ARGS+=(--reviewer "$r"); done

IFS=',' read -r -a tarr <<< "$TEAM_REVIEWERS"
for t in "${tarr[@]}"; do [[ -n "$t" ]] && ARGS+=(--team-reviewer "$t"); done

echo "Creating PR: ${ARGS[*]}"
if gh "${ARGS[@]}"; then
  echo "\nNext Steps:"
  echo "- Assign reviewers if not set; monitor CI checks."
  echo "- Optionally run /gbm.preflight for an automated summary."
  exit 0
else
  echo "Error: Failed to create PR." >&2
  exit 1
fi
