---
description: "Implement lite workflow changes with relaxed quality gates."
scripts:
  sh: .gobuildme/scripts/bash/get-feature-mode.sh
  ps: .gobuildme/scripts/powershell/get-feature-mode.ps1
artifacts:
  - path: "(modified source files)"
    description: "Implementation changes for lite workflow"
  - path: "$FEATURE_DIR/tasks.md"
    description: "Updated tasks with completion status"
---

## Output Style Requirements (MANDATORY)

- Progress updates as you work through tasks
- Task completion markers: [x] for done, [ ] for pending
- Brief summary of changes per file
- No verbose explanations - just what was done

You are implementing a lite workflow change. Focus on completing the tasks efficiently with good quality.

## Quality Gates (Relaxed for Lite)

| Gate | Full Workflow | Lite Workflow |
|------|---------------|---------------|
| Linter | Required | Required |
| Type check | Required | Required |
| Tests pass | Required | Required |
| Coverage 85% | Required | **Changed files only** |
| TDD strict | Required | Encouraged, not enforced |
| Documentation | Required | Not required |

## Prerequisites

- `$FEATURE_DIR/plan.md` must exist
- `$FEATURE_DIR/tasks.md` must exist
- `$FEATURE_DIR/mode.yaml` must have `mode: lite`

## Your Task

### Step 1: Verify Mode and Resolve Paths

Run `{SCRIPT} --json` to get mode and all paths. Parse the JSON output:
- `mode` - Workflow mode (must be `lite`)
- `feature_dir` - Resolved feature directory path
- `branch` - Current branch name
- `gbm_root` - GoBuildMe root directory
- `architecture_dirs` - Colon-separated list of architecture directories

If mode is not `lite`, suggest the correct command:
- `full` → `/gbm.implement`
- `quickfix` → `/gbm.quickfix`

Use `feature_dir` from the JSON output for all file operations. This ensures correct path resolution for:
- Epic--slice branches (e.g., `my-epic--my-slice` → `specs/epics/my-epic/my-slice/`)
- Workspace/monorepo environments

### Step 2: Load Plan and Tasks

Read (using `feature_dir` from Step 1):
- `$FEATURE_DIR/plan.md` - Implementation approach
- `$FEATURE_DIR/tasks.md` - Task checklist

### Step 3: Load Architecture Reference

Resolve architecture directories (module → root) and load context if available:

```bash
source .gobuildme/scripts/bash/common.sh
ARCH_DIRS=$(get_architecture_dirs)
```

For each directory in `ARCH_DIRS`:
- Prefer `architecture-summary.md` for quick context
- Optionally skim `system-analysis.md` and `technology-stack.md` for patterns

Follow existing patterns in the codebase.

### Step 4: Implement Tasks

For each task in tasks.md:

1. **Announce task**: "Working on: {task description}"
2. **Implement**: Make the necessary code changes
3. **Mark complete**: Update tasks.md with `[x]`
4. **Brief summary**: "Completed: {what was done}"

**Implementation Guidelines**:
- Follow existing code patterns
- Add tests for new functionality (no formal coverage threshold)
- Run linter/type-check as you go
- Keep changes focused on the task

### Step 5: Post-Implementation Checks (Pre-Commit)

After all tasks complete, run **targeted checks** on your working changes (not full test suite):

```bash
# Lint (required)
npm run lint  # or: ruff check . / go vet ./...

# Type check (required)
npm run type-check  # or: mypy . / go build ./...

# Tests - TARGETED ONLY (changed + related files)
# Node.js/Jest:
npx jest --findRelatedTests src/changed-file.ts --passWithNoTests

# Python:
pytest tests/path/to/related/ --maxfail=3 -q

# Go:
go test ./path/to/changed/package/... -count=1
```

**Required to pass before committing**:
- ✅ Tests on changed/related files pass
- ✅ No linter errors
- ✅ No type errors

**Not required for lite** (different from full workflow):
- Full test suite (only related tests needed)
- Documentation updates
- Coverage thresholds (no 85% gate; ensure changed code is tested)

**Note**: `ready-to-push-lite.sh` runs **after commit** during `/gbm.lite.push` (requires clean tree).

**If checks fail - Loop Enforcement (MANDATORY)**:
| Check | Action |
|-------|--------|
| Tests fail | Fix code (prefer implementation fixes; update tests only if tests are wrong), re-run → **DO NOT proceed until passing** |
| Linter errors | Fix code, re-run linter → **DO NOT proceed until clean** |
| Type errors | Fix types, re-run type-check → **DO NOT proceed until passing** |

**CRITICAL**: Do NOT proceed to Steps 6/7/8 if any check fails. Loop back and fix until all pass:
1. Identify failing check
2. Fix the issue (prefer implementation fixes; update tests only if tests are demonstrably wrong)
3. Re-run the check
4. If still failing → repeat from step 2
5. Only proceed to Step 6 when ALL checks pass

### Step 6: Self-Review

Quickly review your changes:
- [ ] Changes match the plan
- [ ] No debugging code left in
- [ ] Tests cover new functionality
- [ ] Code follows existing patterns

### Step 7: Update Tasks with Results

Update `$FEATURE_DIR/tasks.md` to mark all tasks complete:

```markdown
# Tasks: {feature-name}

- [x] {Task 1: specific action}
- [x] {Task 2: specific action}
- [x] {Task 3: specific action}
- [x] Run tests and fix any failures
- [x] Self-review changes
```

### Step 8: Display Completion Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Lite Implementation Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tasks completed: {N}/{N}
Files changed:   {N}
Tests:           ✅ Passing

Quality checks:
  Linter:        ✅ Passed
  Type check:    ✅ Passed
  Tests:         ✅ Passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Next Steps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Review changes: git diff
2. Commit: git add . && git commit -m "{message}"
3. Push: /gbm.lite.push

⚠️  Running /gbm.lite.push = approval of implementation.
```

## Scope Exceeded During Implementation

If you discover the change is larger than expected:

```
⚠️  Implementation exceeds lite limits

Files changed: {N} (limit: 5)
Lines changed: ~{N} (limit: 100)

Options:
  A. Complete current changes, note scope in PR
  B. Split into multiple lite PRs
  C. Escalate to full workflow

Continuing with current changes. Consider noting scope deviation in PR description.
```

## Error Handling

- **Plan missing**: "Run `/gbm.lite.plan` first"
- **Tasks missing**: "Run `/gbm.lite.plan` first"
- **Tests failing**: Fix code (prefer implementation fixes; update tests only if tests are wrong), re-run tests, **loop until passing**
- **Linter errors**: Fix code issues, re-run linter, **loop until clean**
- **Type errors**: Fix type issues, re-run type-check, **loop until passing**

### Loop Enforcement Rules

**❌ NEVER**:
- Proceed to Steps 6/7/8 with failing checks
- Mark tasks complete when checks fail
- Ask user "Should I continue?" when tests fail
- Suggest `/gbm.lite.push` with failing checks

**✅ ALWAYS**:
- Fix code when tests fail (prefer implementation fixes; update tests only if demonstrably wrong)
- Re-run failed checks after fixes
- Loop until ALL checks pass
- Only proceed to Step 6 when Step 5 checks all pass
