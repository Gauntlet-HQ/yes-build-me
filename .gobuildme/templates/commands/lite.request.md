---
description: "Capture a lite request for small changes (3-5 files, ≤100 LoC)."
scripts:
  sh: .gobuildme/scripts/bash/create-request.sh --json --template .gobuildme/templates/request-lite-template.md {ARGS}
  ps: .gobuildme/scripts/powershell/create-request.ps1 -Json -Template .gobuildme/templates/request-lite-template.md {ARGS}
artifacts:
  - path: "$FEATURE_DIR/request.md"
    description: "Compact lite request document (3-5 sentences)"
  - path: "$FEATURE_DIR/mode.yaml"
    description: "Workflow mode tracking file (mode: lite)"
---

## Output Style Requirements (MANDATORY)

- Request doc: 3-5 sentences max, no sections - just What/Why/Scope/Files
- No prose explanations - bullets only
- File list: absolute max 5 files
- Total scope: ≤100 lines of code changes

You are handling a lite workflow request. This is for small changes that don't need the full SDD ceremony.

## Lite Workflow Scope Limits

**HARD LIMITS** (if exceeded, suggest full workflow instead):
- Files: 3-5 (use `/gbm.quickfix` for 1-2 files, `/gbm.request` for 6+)
- Lines of code: ≤100
- Complexity: Single concern, no architectural changes
- Dependencies: No new dependencies
- Schema: No database migrations

## User Input

**Arguments**: $ARGUMENTS

Parse the request description from arguments.

## Prerequisites

**CRITICAL**: `/gbm.setup` must have been run first. Setup creates:
- Constitution (project principles)
- Persona configuration
- Architecture documentation

If these don't exist, instruct user: "Run `/gbm.setup` first to initialize the project."

## Your Task

### Step 1: Verify Setup Complete

Before running the setup script, verify prerequisites exist:
```bash
source .gobuildme/scripts/bash/common.sh
CONSTITUTION_PATH=$(get_constitution_path)
ARCH_DIR="$(get_gobuildme_root)/.gobuildme/docs/technical/architecture"

if [[ ! -f "$CONSTITUTION_PATH" ]] || [[ ! -d "$ARCH_DIR" ]]; then
  echo "❌ Project not initialized. Run /gbm.setup first."
  exit 1
fi
```

### Step 2: Run Setup Script

The script `{SCRIPT}` creates:
- Feature directory at `$FEATURE_DIR`
- Feature branch (if on protected branch)
- Seeded request.md from lite template

Parse the JSON output for paths:
```json
{
  "BRANCH_NAME": "feature-name",
  "REQUEST_FILE": "/path/to/request.md",
  "FEATURE_DIR": "/path/to/feature/dir",
  "GBM_ROOT": "/path/to/gobuildme/root",
  "WORKSPACE_ROOT": "/path/to/workspace/root"
}
```

### Step 3: Validate Lite Scope

Before proceeding, mentally estimate:
- How many files will this touch? (Must be 3-5)
- How many lines of code? (Must be ≤100)
- Does it involve new dependencies, schema changes, or architectural decisions?

**If scope is too small** (1-2 files): Suggest `/gbm.quickfix` instead.
**If scope is too large** (6+ files): Suggest `/gbm.request` for full workflow.

### Step 4: Create mode.yaml

Write `$FEATURE_DIR/mode.yaml`:
```yaml
mode: lite
created: "{ISO 8601 timestamp}"
estimated_files: {N}
estimated_loc: {N}
```

### Step 5: Load Architecture as Reference

If architecture docs exist (from `ARCHITECTURE_DIRS` in JSON output), load them as context (but don't validate).

Read architecture summary if available for quick context.

**Optional freshness check (git-tracked)**:
- Run `.gobuildme/scripts/bash/check-architecture-freshness.sh`
- If `STALE:*` → Warn: "Architecture is stale; consider `/gbm.architecture` before proceeding."
- If `UNKNOWN:*` → Warn: "Architecture freshness unknown; continue cautiously."

### Step 6: Fill Request Document

Edit `$FEATURE_DIR/request.md` with a COMPACT request:

**Template** (≤10 lines total):
```markdown
# Lite Request

**What**: {one sentence describing the change}

**Why**: {one sentence explaining the motivation}

**Scope**: 3-5 files, ≤100 lines

**Files likely affected**:
- {file1}
- {file2}
- {file3}
```

**CRITICAL**: Do NOT add additional sections. Keep it minimal.

### Step 7: Display Completion Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Lite Request Created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Branch:     {branch_name}
Request:    {request_file_path}
Mode:       lite (3-5 files, ≤100 LoC)

Estimated scope:
  Files:    {N}
  LoC:      ~{N}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Next Steps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Review request.md - edit if needed
2. Run: /gbm.lite.plan

Lite workflow: request → plan → implement → push (4 commands total)
```

## Scope Escalation

If during request capture you realize scope is larger than expected:

**Escalate to Full Workflow**:
```
⚠️  Scope appears larger than lite limits (3-5 files, ≤100 LoC)

Recommend switching to full workflow:
  → /gbm.request "{same description}"

Continue with lite anyway? The plan step will validate scope again.
```
