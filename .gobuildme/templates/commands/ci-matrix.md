---
description: "Generate an advanced CI matrix workflow with language detection."
artifacts:
  - path: ".github/workflows/ci-matrix.yml"
    description: "GitHub Actions CI matrix configuration for running tests across multiple environments"
scripts:
  sh: scripts/bash/setup-ci-matrix.sh
  ps: scripts/powershell/setup-ci-matrix.ps1
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.ci-matrix" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. Run {SCRIPT} to create `.github/workflows/ci.yml` with:
   - Detect-project job emitting outputs (has-python/node/php/go/rust/java + package manager)
   - Matrixed jobs for Python (3.10–3.12) and Node (16/18/20) across OSes when detected
   - Single-job runs for Go, Rust, Java, PHP when detected

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
3. Track command complete:
   - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-ci-matrix` (include error details if command failed)
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
   - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit CI matrix configuration to adjust test matrix
- Re-run `/gbm.ci-setup` if CI workflow needs changes
- Re-run `/gbm.ci-matrix` to regenerate with updated requirements

