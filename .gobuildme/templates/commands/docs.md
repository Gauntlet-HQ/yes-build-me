---
description: "Create or update developer docs (README, quickstart) for this feature."
artifacts:
  - path: "docs/"
    description: "Generated API documentation and user guides"
scripts:
  sh: scripts/bash/create-docs.sh "$ARGUMENTS"
  ps: scripts/powershell/create-docs.ps1 -Feature "$ARGUMENTS"
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.docs" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. Run {SCRIPT}. It will:
   - Create or update `docs/quickstart.md` from templates when missing
   - Update `README.md` sections (Getting Started / Running tests) if safe
   - Link PRD, spec, plan, and design paths for quick navigation

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
3. Track command complete:
   - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-docs` (include error details if command failed)
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
   - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit documentation files to improve content
- Run `/gbm.document` to regenerate from code
- Re-run `/gbm.docs` to update documentation index

