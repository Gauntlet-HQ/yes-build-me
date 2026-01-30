---
description: "Validate architecture boundaries and layering constraints."
artifacts:
  - path: ".gobuildme/validation/<feature>/architecture-validation.md"
    description: "Validation report confirming implementation matches architecture specifications"
scripts:
  sh: scripts/bash/validate-architecture.sh
  ps: scripts/powershell/validate-architecture.ps1
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.validate-architecture" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run {SCRIPT}. If Augment CLI is installed, run its validation; also apply heuristic boundary checks (e.g., services must not import api). Fail the gate with a concise report when violations are detected.

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-validate-architecture` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Fix architectural boundary violations in code
- Update `.gobuildme/docs/technical/architecture/` if patterns changed
- Re-run `/gbm.validate-architecture` after fixes to verify compliance

