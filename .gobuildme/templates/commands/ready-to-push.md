---
description: "Run format, lint, type-check, tests, security, and branch checks before pushing."
artifacts:
  - path: "(validation report)"
    description: "Validation report confirming all requirements met before pushing code"
scripts:
  sh: scripts/bash/ready-to-push.sh
  ps: scripts/powershell/ready-to-push.ps1
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.ready-to-push" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

## Task Completion Check (MANDATORY - First Gate)

Before running any other gates, verify all tasks are completed:

1. **Load Tasks File**: Read `$FEATURE_DIR/tasks.md`

2. **Validate Task Completion**:
   - Count total tasks
   - Count completed tasks (marked with `[x]`)
   - Count incomplete tasks (marked with `[ ]`)

3. **Task Completion Gate**:
   - 🟢 **PASS**: All tasks marked as `[x]` → Proceed with other gates
   - 🔴 **FAIL**: Any tasks marked as `[ ]` → **BLOCK** immediately

4. **If Tasks Incomplete**:
   - List incomplete tasks with IDs and descriptions
   - Output: "❌ Ready-to-push blocked: X tasks incomplete. Complete all tasks before pushing."
   - Suggest: "Run /gbm.implement to complete remaining tasks"
   - **DO NOT RUN** other gates until tasks are complete
   - **EXIT** with failure status

5. **Task Completion Report**:
   ```
   ═══════════════════════════════════════════════════════════
   GATE 1: TASK COMPLETION
   ═══════════════════════════════════════════════════════════
   Total Tasks: X
   Completed: Y [x]
   Incomplete: Z [ ]

   Status: [✓ PASS / ✗ FAIL]
   ═══════════════════════════════════════════════════════════
   ```

## Quality Gates (Run Only If Tasks Complete)

Run {SCRIPT} and report a concise gate summary. If any category fails, include the failing command and suggest the minimal fix.

### Step 2: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-ready-to-push` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Fix quality gate violations identified in report
- Run `/gbm.review` or `/gbm.tests` to address specific issues
- Re-run `/gbm.ready-to-push` to verify all gates pass
- Do NOT proceed to `/gbm.push` until ready

