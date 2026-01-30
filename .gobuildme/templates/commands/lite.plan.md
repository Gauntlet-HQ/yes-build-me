---
description: "Create compact implementation plan and tasks for lite workflow."
scripts:
  sh: .gobuildme/scripts/bash/get-feature-mode.sh
  ps: .gobuildme/scripts/powershell/get-feature-mode.ps1
artifacts:
  - path: "$FEATURE_DIR/plan.md"
    description: "Compact implementation plan (≤50 lines)"
  - path: "$FEATURE_DIR/tasks.md"
    description: "Task checklist (≤5 tasks)"
---

## Output Style Requirements (MANDATORY)

- plan.md: ≤50 lines total - Summary, Files, Approach, Notes sections only
- tasks.md: ≤5 tasks, single flat list, no phases
- No prose - bullets only
- One-line descriptions per file/task

You are creating a compact plan for a lite workflow change.

## Prerequisites

- `$FEATURE_DIR/request.md` must exist
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
- `full` → `/gbm.plan`
- `quickfix` → No plan needed, use `/gbm.quickfix` directly

Use `feature_dir` from the JSON output for all file operations. This ensures correct path resolution for:
- Epic--slice branches (e.g., `my-epic--my-slice` → `specs/epics/my-epic/my-slice/`)
- Workspace/monorepo environments

### Step 2: Read Request

Read `$FEATURE_DIR/request.md` (using `feature_dir` from Step 1) to understand:
- What change is being made
- Why it's needed
- Which files are likely affected

### Step 3: Load Architecture Reference (Non-blocking)

Resolve architecture directories (module → root) and load context if available:

```bash
source .gobuildme/scripts/bash/common.sh
ARCH_DIRS=$(get_architecture_dirs)
```

For each directory in `ARCH_DIRS`:
- Prefer `architecture-summary.md` for quick context
- Optionally skim `system-analysis.md` and `technology-stack.md` for patterns

Use architecture to inform:
- File locations
- Existing patterns to follow
- Integration points

**IMPORTANT**: For lite workflow, architecture is reference only - don't validate against it.

### Step 4: Create plan.md (≤50 lines)

Write `$FEATURE_DIR/plan.md` using this EXACT template:

```markdown
# Lite Plan: {feature-name}

## Change Summary
{2-3 sentences describing the change}

## Files to Modify
- `path/to/file1.ts` - {one-line description}
- `path/to/file2.ts` - {one-line description}
- `path/to/file3.ts` - {one-line description}

## Approach
- {Step 1: specific action}
- {Step 2: specific action}
- {Step 3: specific action}

## Risks/Notes
- {Risk or note 1, or "None"}
```

**HARD LIMIT**: ≤50 lines total. Do NOT add additional sections.

### Step 5: Create tasks.md (≤5 tasks)

Write `$FEATURE_DIR/tasks.md` using this EXACT template:

```markdown
# Tasks: {feature-name}

- [ ] {Task 1: specific action}
- [ ] {Task 2: specific action}
- [ ] {Task 3: specific action}
- [ ] Run tests and fix any failures
- [ ] Self-review changes
```

**HARD LIMITS**:
- Maximum 5 tasks
- Single flat list (no phases, no nesting)
- No sub-tasks
- Must include "Run tests" task

**NOTE**: Lite workflow intentionally does NOT generate `scope.json`. This is by design:
- Lite changes are small (3-5 files) - explicit scope tracking adds overhead without proportional benefit
- Slice scope validation is skipped during `/gbm.lite.push` (no scope.json present)
- If stricter scope tracking is needed, use full workflow (`/gbm.plan` → `/gbm.tasks`)

### Step 6: Validate Scope

Count files in plan. If more than 5 files:

```
⚠️  Plan exceeds lite workflow limits

Files in plan: {N} (limit: 5)

Options:
  A. Reduce scope - remove less critical files
  B. Escalate to full workflow: /gbm.plan
  C. Continue anyway (not recommended)

Recommendation: [A or B based on analysis]
```

### Step 7: Display Completion Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Lite Plan Created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Plan:       {plan_file_path} (lines: {N}/50)
Tasks:      {tasks_file_path} (tasks: {N}/5)
Files:      {N}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Next Steps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Review plan.md and tasks.md
2. Run: /gbm.lite.implement

⚠️  Running next command = approval of this plan.
```

## Error Handling

- **Request missing**: "Run `/gbm.lite.request` first to create request.md"
- **Wrong mode**: "This feature uses {mode} workflow. Use `/gbm.{mode}.plan` instead."
- **Scope exceeded**: Offer escalation to full workflow
