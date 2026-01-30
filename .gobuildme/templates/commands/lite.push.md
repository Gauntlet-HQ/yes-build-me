---
description: "Push lite workflow changes with minimal review (skips comprehensive review)."
scripts:
  sh: .gobuildme/scripts/bash/push.sh --lite {ARGS}
  ps: .gobuildme/scripts/powershell/push.ps1 -Lite {ARGS}
artifacts:
  - path: "(GitHub PR)"
    description: "Pull request for lite workflow changes"
---

## Output Style Requirements (MANDATORY)

- Quick preflight status (pass/fail for each check)
- PR creation confirmation with link
- No verbose explanations

You are pushing a lite workflow change. This uses the `--lite` flag to skip comprehensive review while still running essential quality checks.

## What --lite Does

| Check | Regular Push | --lite Push |
|-------|--------------|-------------|
| `ready-to-push.sh` | ✅ Runs | ❌ Skipped |
| `ready-to-push-lite.sh` | ❌ Skipped | ✅ Runs |
| `comprehensive-review.sh` | ✅ Runs | ❌ Skipped |

**`ready-to-push-lite.sh` includes** (lighter checks for lite workflow):
- Lint check
- Type check
- Tests related to changed source files (using framework-specific discovery)
- Tests from changed test files

**Intentionally skipped for lite**:
- Slice scope validation (no `scope.json` - lite workflow doesn't generate it)
- Harness progress tracking (designed for complex multi-phase work, not lite)

**`ready-to-push.sh` includes** (full preflight, skipped for lite):
- Code formatting
- Linting
- Type checking
- Full test suite
- Security scan
- Branch status

**`comprehensive-review.sh` includes** (skipped for lite):
- Full AI-assisted code review
- Architecture compliance check
- Documentation completeness
- Breaking change detection

## Prerequisites

- All tasks in `$FEATURE_DIR/tasks.md` must be `[x]` complete
- Working tree must be clean (all changes committed)
- `$FEATURE_DIR/mode.yaml` must have `mode: lite`

## Your Task

### Step 1: Resolve Feature Directory and Verify Prerequisites

First, resolve the feature directory from the current branch:
```bash
# Source common functions
source .gobuildme/scripts/bash/common.sh

# Get current branch and resolve feature directory
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
FEATURE_DIR=$(get_feature_dir "$BRANCH")

if [[ -z "$FEATURE_DIR" ]] || [[ ! -d "$FEATURE_DIR" ]]; then
  echo "❌ Could not resolve feature directory from branch '$BRANCH'"
  echo "   Ensure you're on a feature branch with a spec directory."
  exit 1
fi
```

Then verify mode and prerequisites:
```bash
# Verify mode
MODE=$(.gobuildme/scripts/bash/get-feature-mode.sh)
if [[ "$MODE" != "lite" ]]; then
  echo "This feature uses $MODE workflow. Use /gbm.push instead."
  exit 1
fi

# Check tasks complete
if [[ -f "$FEATURE_DIR/tasks.md" ]]; then
  INCOMPLETE=$(grep -c '^\- \[ \]' "$FEATURE_DIR/tasks.md" || echo 0)
  if [[ "$INCOMPLETE" -gt 0 ]]; then
    echo "⚠️  $INCOMPLETE tasks incomplete. Complete tasks before pushing."
    exit 1
  fi
fi

# Check clean working tree
if [[ -n "$(git status --porcelain)" ]]; then
  echo "⚠️  Working tree not clean. Commit or stash changes first."
  exit 1
fi
```

### Step 2: Run Push Script

The script `{SCRIPT}` will:
1. Run `ready-to-push-lite.sh` (lint, type-check, tests on changed files)
2. Skip `comprehensive-review.sh` (due to --lite flag)
3. Push branch to origin
4. Create PR with auto-generated body

### Step 3: Handle Preflight Results

**If preflight passes**:
- Continue to PR creation
- Include lite workflow note in PR body

**If preflight fails**:
- Show which check failed
- Suggest fix action
- Do NOT create PR

### Step 4: Create PR with Lite Context

PR body template for lite workflow:

```markdown
## Summary

> {First 3-4 lines of request.md}

## Lite Workflow

This PR was created using lite workflow (3-5 files, ≤100 LoC).
- Skipped comprehensive review
- Passed: lint, type-check, related tests

## Files Changed

- {file1}
- {file2}
- {file3}

## Checklist

- [x] Tests pass
- [x] Linter clean
- [x] Self-reviewed
```

### Step 5: Display Completion Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Lite Push Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Preflight checks:
  Lint:          ✅ Passed
  Type check:    ✅ Passed
  Tests:         ✅ Passed (related tests)

PR created: {PR_URL}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Next Steps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Add reviewers to PR
2. Monitor CI checks
3. Merge when approved

Lite workflow complete! 🎉
```

## Error Handling

- **Tasks incomplete**: "Complete all tasks before pushing. Run `/gbm.lite.implement` to continue."
- **Working tree dirty**: "Commit or stash changes first."
- **Preflight failed**: Show specific failure and suggest fix.
- **PR creation failed**: Show error and suggest manual `gh pr create`.

## Escalation

If reviewers request significant changes that exceed lite scope:

```
⚠️  PR feedback suggests larger scope needed

Consider:
1. Address feedback in follow-up lite PRs
2. Convert to full workflow for thorough review

To convert:
  cp $FEATURE_DIR/request.md $FEATURE_DIR/request-backup.md
  /gbm.request "{original description}"
```
