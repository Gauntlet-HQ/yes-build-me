---
description: "Single-command workflow for trivial fixes (1-2 files, ≤50 LoC)."
scripts:
  sh: .gobuildme/scripts/bash/create-request.sh --json --template .gobuildme/templates/request-quickfix-template.md --branch-prefix quickfix- {ARGS}
  ps: .gobuildme/scripts/powershell/create-request.ps1 -Json -Template .gobuildme/templates/request-quickfix-template.md -BranchPrefix quickfix- {ARGS}
artifacts:
  - path: "$FEATURE_DIR/request.md"
    description: "Minimal quickfix request (3-5 lines)"
  - path: "$FEATURE_DIR/mode.yaml"
    description: "Workflow mode tracking file (mode: quickfix)"
  - path: "$FEATURE_DIR/quickfix-log.md"
    description: "Audit log with changes and PR link (≤20 lines)"
---

## Output Style Requirements (MANDATORY)

- Ultra-compact: request ≤5 lines, log ≤20 lines
- No planning artifacts - direct implementation
- Quick summary when complete
- Architecture summary for context (if available)

You are handling a quickfix - the fastest workflow for trivial changes.

## Quickfix Scope Limits

**SOFT LIMITS** (advisory only - show note but continue):
| Limit | Value | If Exceeded |
|-------|-------|-------------|
| Files changed | 1-2 | → Note: suggest lite for future |
| Lines of code | ≤50 | → Note: suggest lite for future |
| New files created | 0 | → Note: suggest lite for future |

**HARD BLOCKS** (actually prevents commit):
| Change Type | Detection | Escalate To |
|-------------|-----------|-------------|
| Security/Auth | auth/, security/, middleware/auth/, middleware/security/, acl/, rbac/, permissions/ | **Full** |

**Advisory only** (note but proceed):
| Change Type | Detection | Note |
|-------------|-----------|------|
| Dependencies | package.json, requirements.txt, etc. | Consider lite for tracking |
| Schema | migrations/, *.sql, *.prisma | Consider lite for tracking |
| API contracts | openapi.yaml, *.proto, routes/ | Consider lite for tracking |
| Config files | .env*, config/, settings.* | Consider lite for tracking |

**Intentionally NOT used for quickfix** (designed for complex workflows):
- `scope.json` - Quickfix doesn't generate scope manifest (no plan/tasks phase)
- Harness progress tracking - Designed for multi-phase work with participants
- Slice scope validation - Skipped since no scope.json exists

## User Input

**Arguments**: $ARGUMENTS

Parse the fix description. Supports:
- Simple: `/gbm.quickfix "fix typo in README"`
- With slug: `/gbm.quickfix "slug: readme-typo\nFix the typo in the installation section"`

## Your Task

### Step 0: Check Current Branch (Interactive Decision)

First, check if the user is on a non-protected feature branch:

```bash
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
PROTECTED_BRANCHES="main|master|develop|dev|staging|production|prod"
```

**If on a protected branch** (main, master, etc.): Skip to Step 1 - the script will create a quickfix branch automatically.

**If on a non-protected feature branch** (e.g., `feature-xyz`, `qa-test-scaffolding`):

Ask the user:
```
You're currently on branch '$CURRENT_BRANCH'.

Where would you like to apply the quickfix?
  A) Continue on current branch (no new branch) - mixes artifacts with existing feature
  B) Create quickfix-{slug} branch from default branch (clean slate)
  C) Create quickfix-{slug} branch from current branch (Recommended - keeps context, clean artifacts)
```

- **Option A**: Skip branch creation, work directly on current branch (set `GBM_SKIP_BRANCH=true`)
  - ⚠️ **Note**: Artifacts will be stored in `$FEATURE_DIR` using current branch name (e.g., `.gobuildme/specs/feature-xyz/`), not `quickfix-{slug}`
  - ⚠️ **Warning**: If `request.md` already exists for this branch, it will be overwritten. Confirm with user before proceeding.
- **Option B**: First detect the repo's default branch, then checkout and pull:
  ```bash
  # Fallback chain: origin/HEAD → origin/main → origin/master → local main → local master → current
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  FROM_REMOTE=false
  if [[ -z "$DEFAULT_BRANCH" ]]; then
    if git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null; then
      DEFAULT_BRANCH="main"; FROM_REMOTE=true
    elif git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null; then
      DEFAULT_BRANCH="master"; FROM_REMOTE=true
    elif git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
      DEFAULT_BRANCH="main"
    elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
      DEFAULT_BRANCH="master"
    else
      DEFAULT_BRANCH="$CURRENT_BRANCH"
      echo "⚠️  Could not detect default branch, staying on '$CURRENT_BRANCH' (skipping pull)"
    fi
  fi
  if [[ "$DEFAULT_BRANCH" == "$CURRENT_BRANCH" ]]; then
    # Already on target branch, skip checkout and pull to avoid unexpected updates
    :
  elif [[ "$FROM_REMOTE" == "true" ]] && ! git show-ref --verify --quiet "refs/heads/$DEFAULT_BRANCH" 2>/dev/null; then
    # Remote branch exists but no local branch - create tracking branch
    git checkout -B "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH"
  else
    git checkout "$DEFAULT_BRANCH" && git pull
  fi
  ```
  Then proceed to Step 1.
- **Option C**: Proceed to Step 1 (default behavior - creates `quickfix-{slug}` from current branch)

### Step 1: Run Setup Script

The script `{SCRIPT}` creates:
- Feature directory at `$FEATURE_DIR`:
  - Options B/C: `quickfix-{slug}`
  - Option A: Uses current branch name (e.g., `feature-xyz`)
- Feature branch (if on protected branch or Option B/C selected)
- Seeded request.md from quickfix template

**Note**: If user chose Option A, add `--no-branch` flag (or set `GBM_SKIP_BRANCH=true` before running).

Parse the JSON output for paths. Note the `CONSTITUTION_PATH` for the next step.

### Step 2: Validate Setup Complete (Hard Gate)

**CRITICAL**: `/gbm.setup` must have been run first. Setup creates constitution, persona, and architecture.

Use paths from the JSON output in Step 1:

```bash
# Verify setup has been completed
if [[ ! -f "$CONSTITUTION_PATH" ]]; then
  echo "❌ Project not initialized."
  echo "   Run /gbm.setup first to create constitution, persona, and architecture."
  exit 1
fi

# Architecture is optional for quickfix but should exist from setup
ARCH_DIR="$GBM_ROOT/.gobuildme/docs/technical/architecture"
if [[ ! -d "$ARCH_DIR" ]]; then
  echo "⚠️  Architecture docs not found. Run /gbm.setup to generate them."
  # Non-blocking for quickfix - just warn
fi
```

**If constitution missing**: STOP and instruct user to run `/gbm.setup`.

### Step 3: Create mode.yaml

Write `$FEATURE_DIR/mode.yaml`:
```yaml
mode: quickfix
created: "{ISO 8601 timestamp}"
```

### Step 4: Load Architecture Summary (Non-blocking)

Use `ARCHITECTURE_DIRS` from the JSON output (colon-separated list of directories).

**Find and load architecture summary**:
1. If `ARCHITECTURE_DIRS` is empty: Warn "No architecture directories found" and proceed
2. For each directory in `ARCHITECTURE_DIRS`:
   - Check if `{dir}/architecture-summary.md` exists
   - If found, read it for quick context
3. If no summary found: Warn "No architecture summary found" and proceed with caution

**Read architecture-summary.md for**:
- Project structure
- Critical paths (files requiring full workflow)
- Conventions to follow

**IMPORTANT**: Missing summary is NON-BLOCKING. Proceed with caution.

**Optional freshness check (git-tracked)**:
- Run `.gobuildme/scripts/bash/check-architecture-freshness.sh`
- If `STALE:*` → Warn: "Architecture is stale; consider `/gbm.architecture` before larger changes."
- If `UNKNOWN:*` → Warn: "Architecture freshness unknown; continue cautiously."

### Step 5: Clean Tree Check (HARD GATE)

**CRITICAL**: Before implementing, verify the working tree is clean or only has quickfix-related changes.

```bash
# Check for uncommitted changes
DIRTY_COUNT=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [[ "$DIRTY_COUNT" -gt 0 ]]; then
  # Normalize FEATURE_DIR to repo-relative path for git status comparison
  GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
  FEATURE_DIR_REL="${FEATURE_DIR#$GIT_ROOT/}"

  # Guard against missing/invalid feature dir (avoid false clean)
  if [[ -z "$FEATURE_DIR_REL" ]] || [[ "$FEATURE_DIR_REL" == "." ]]; then
    echo "❌ FEATURE_DIR could not be resolved to a repo-relative path."
    echo "Quickfix requires a valid feature directory to validate scope."
    echo "Re-run Step 1 to resolve FEATURE_DIR, then retry."
    exit 1
  fi

  # Check if changes are ONLY in quickfix directory
  # Note: Also catches unrelated untracked files (removes ^?? exception)
  NON_QUICKFIX_CHANGES=$(git status --porcelain 2>/dev/null | grep -F -v "$FEATURE_DIR_REL" | wc -l | tr -d ' ')
  if [[ "$NON_QUICKFIX_CHANGES" -gt 0 ]]; then
    echo "❌ Working tree has uncommitted or untracked changes unrelated to this quickfix."
    echo ""
    git status --short | grep -v "$FEATURE_DIR_REL" | head -10
    echo ""
    echo "Quickfix requires a clean tree to accurately validate scope limits."
    echo ""
    echo "Options:"
    echo "  A) Stash changes: git stash -m 'WIP before quickfix'"
    echo "  B) Commit changes: git add . && git commit -m 'WIP'"
    echo "  C) Use a clean branch: git checkout -b quickfix-{slug} origin/main"
    echo "  D) Remove untracked files: git clean -fd (CAUTION: deletes files)"
    echo ""
    exit 1
  fi
fi
```

**Why this matters**: Validation scripts use `git diff` to check file/line counts. Other uncommitted changes pollute these metrics and cause false positives (e.g., "10 files changed" when quickfix only touches 1 file).

**If dirty tree detected**: STOP. Do NOT proceed with "manual workarounds". Clean the tree first using one of the options above.

---

### Step 6: Fill Minimal Request

Edit `$FEATURE_DIR/request.md` with ULTRA-COMPACT content:

```markdown
# Quickfix

**What**: {one sentence}
**Why**: {one sentence}
**File(s)**: {1-2 files}
```

**CRITICAL**: No more than 5 lines total.

### Step 7: Implement the Fix

Make the change directly:
1. Identify the file(s) to modify
2. Make the minimal necessary change
3. Verify the fix works (run tests if applicable)

**Guidelines**:
- Follow existing code patterns
- Keep changes minimal and focused
- No refactoring alongside the fix
- No "while I'm here" changes

**If tests fail after implementing fix**:
1. Identify failing test(s) and root cause
2. Fix the code (prefer implementation fixes; update tests only if tests are demonstrably wrong)
3. Re-run tests
4. Loop until all tests pass
5. Only proceed to Step 8 when tests pass

**CRITICAL**: Do NOT proceed to commit with failing tests. Fix and loop until passing.

### Step 8: Post-Implementation Validation

Run validation script:

```bash
.gobuildme/scripts/bash/validate-quickfix.sh
VALIDATION_EXIT=$?
```

**CRITICAL: Check exit code BEFORE proceeding**:

| Exit Code | Result Pattern | Action |
|-----------|----------------|--------|
| 0 | `VALID:*` or `ADVISORY:*` | ✅ Continue to commit |
| 2 | `BLOCK:security:*` | ❌ **HARD BLOCK**: Security changes require `/gbm.request` (full workflow) - **STOP HERE** |
| 3 | `SKIPPED:no_git` | ⚠️ Warn and continue (not a git repo) |
| 1 or other | Script error | ❌ **HARD BLOCK**: Fix script error before proceeding - **DO NOT BYPASS** |

**Advisory notes (exit 0, informational only)**:
- `ADVISORY:files:*` - File count exceeds limit, note shown
- `ADVISORY:lines:*` - Line count exceeds limit, note shown
- `ADVISORY:new_files:*` - New file count exceeds limit, note shown
- `ADVISORY:dependencies:*` - Dependency file changed, note shown
- `ADVISORY:schema:*` - Schema file changed, note shown
- `ADVISORY:api_contracts:*` - API contract file changed, note shown
- `ADVISORY:config:*` - Config file changed, note shown

**Key principle**: Exit codes 0 (valid/advisory) and 3 (no-git, warning only) allow proceeding. Exit codes 1 (script error) and 2 (security block) are **HARD BLOCKS**.

**❌ NEVER**: Proceed after non-zero exit (except `SKIPPED:no_git`) with "manual validation shows it's fine"
**✅ ALWAYS**: Fix the issue or escalate to lite/full workflow if blocked

### Step 9: Create Quickfix Log

Write `$FEATURE_DIR/quickfix-log.md`:

```markdown
# Quickfix: {slug}

**What**: {one sentence}
**Why**: {one sentence}
**Files**: {comma-separated list}
**Lines changed**: {number}
**PR**: {pending}
**Timestamp**: {ISO 8601}
```

### Step 10: Stage and Commit Changes

Stage and commit the changes before running preflight:

```bash
# Stage changes (including quickfix-log.md)
git add .

# Commit with clear message
git commit -m "fix: {brief description}

Quickfix: {what was fixed}
Files: {file1}, {file2}"
```

### Step 11: Run Lite Preflight Checks

After committing, run essential quality gates:

```bash
.gobuildme/scripts/bash/ready-to-push-lite.sh
PREFLIGHT_EXIT=$?
```

This runs:
- Uncommitted changes check
- Lint check
- Type check
- Tests on changed files only (if test files were modified)

**CRITICAL: Check exit code BEFORE proceeding**:

| Exit Code | Failure Type | Action |
|-----------|--------------|--------|
| 0 | None | ✅ Preflight passed - proceed to push |
| 1 | Uncommitted changes | ❌ **HARD BLOCK**: Dirty tree detected - stash/commit unrelated changes first |
| 1 | Lint failure | ❌ **LOOP**: Fix lint issues, amend, re-run |
| 1 | Type check failure | ❌ **LOOP**: Fix type errors, amend, re-run |
| 1 | Test failure | ❌ **LOOP**: Fix test failures, amend, re-run |

**If preflight fails - Loop Enforcement (MANDATORY)**:
1. Check the specific failure type from output
2. **If uncommitted changes**: STOP - this is NOT a loop case. Clean the tree first (stash/commit unrelated changes)
3. **If lint/type/test failure**: Fix the issue
4. Stage changes: `git add .`
5. Amend commit: `git commit --amend --no-edit`
6. Re-run quickfix validation: `.gobuildme/scripts/bash/validate-quickfix.sh` (fixes may change file/line counts)
7. Re-run preflight: `.gobuildme/scripts/bash/ready-to-push-lite.sh`
8. If still failing → repeat from step 3
9. Only proceed to Step 12 when BOTH validations pass (exit 0)

**❌ NEVER**:
- Proceed after exit 1 with "I manually verified tests pass"
- Bypass uncommitted changes check with "those changes are unrelated"
- Skip to push with "the actual quickfix code is fine"

**✅ ALWAYS**:
- Fix issues and loop until exit 0
- Clean tree before proceeding if dirty
- Run BOTH validate-quickfix.sh AND ready-to-push-lite.sh after each fix

**CRITICAL**: Do NOT proceed to push with failing validation or preflight. Fix and loop until both pass with exit code 0.

### Step 12: Push and Create PR

```bash
# Push and create PR
git push -u origin {branch}
gh pr create --title "fix: {description}" --body "Quickfix PR

**What**: {one sentence}
**Files**: {file list}

🔧 Created with /gbm.quickfix"
```

### Step 13: Update Quickfix Log with PR

Update `$FEATURE_DIR/quickfix-log.md` with PR link:

```markdown
**PR**: {PR_URL}
```

### Step 14: Display Completion Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Quickfix Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files:       {file1}, {file2}
Lines:       {N}
PR:          {PR_URL}

Validation:  {if ADVISORY:* was shown: "✅ Completed (advisories noted)" else "✅ Within limits"}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Next Steps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Monitor PR checks
2. Merge when approved

Quickfix workflow complete! 🎉
```

## Slug Guidance

Keep descriptions concise for clean branch names:
- ✅ `/gbm.quickfix "fix typo in README"` → `quickfix-fix-typo-in-readme`
- ✅ `/gbm.quickfix "slug: readme-typo"` → `quickfix-readme-typo`
- ❌ Avoid very long descriptions

## Error Handling

- **Not a git repo**: Warn and proceed without validation
- **Protected branch**: Auto-create feature branch via script
- **PR creation fails**: Show manual `gh pr create` command
- **PR creation fails with GH_HOST error**: If you see "none of the git remotes configured for this repository correspond to the GH_HOST environment variable", run `unset GH_HOST && gh pr create ...` or check if `GH_HOST` is set to a different GitHub instance
- **Security block (BLOCK:security)**: Only case that stops quickfix - guide user to `/gbm.request` (full workflow)
- **Advisory notes**: All other validations (files, lines, deps, schema, API, config) show notes but proceed
- **Tests fail**: Fix code (prefer implementation fixes; update tests only if tests are wrong), re-run tests, **loop until passing**
- **Preflight fails**: Fix issues, amend commit, re-run both validate-quickfix.sh and preflight, **loop until passing**
- **Dirty tree detected**: STOP immediately. Do NOT proceed with manual workarounds. Clean the tree first using stash/commit/branch options
- **Unexpected script errors**: If validate-quickfix.sh fails unexpectedly (syntax errors, unbound variables), run `gobuildme upgrade` to update stale scripts, then retry

### Loop Enforcement Rules

**❌ NEVER**:
- Commit with failing tests
- Push with failing preflight
- Ask user "Should I fix this?" when tests fail
- Skip to "Quickfix Complete" with failing checks

**✅ ALWAYS**:
- Fix code when tests fail (prefer implementation fixes; update tests only if demonstrably wrong)
- Re-run both validate-quickfix.sh and preflight after amending (fixes may change file/line counts)
- Loop until ALL checks pass
- Only proceed to push when tests, validation, and preflight all pass

## Escalation Paths

| From | To | When |
|------|-----|------|
| Quickfix | Lite | Files 3-5, or deps/schema/API touched |
| Quickfix | Full | Security/auth touched, or 6+ files |

To escalate:
```bash
# Preserve changes, convert workflow
/gbm.lite.request "{same description}"  # For lite
/gbm.request "{same description}"        # For full
```
