---
description: "Set up a polyglot CI workflow for tests, type checks, linting, and security."
artifacts:
  - path: ".github/workflows/"
    description: "GitHub Actions workflow configuration files for continuous integration"
scripts:
  sh: scripts/bash/setup-ci.sh
  ps: scripts/powershell/setup-ci.ps1
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.ci-setup" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. Run {SCRIPT} from the repo root to generate `.github/workflows/tests.yml` and, if no Makefile exists, copy `templates/Makefile.example` to `Makefile`. The workflow:
   - Detects Python, Node/TypeScript, PHP, Go, Rust, and Java projects
   - Installs toolchains and dependencies per language
   - Runs lint, type checks, tests (with coverage where available), and security scans

   After creation, review and adjust versions or add per-repo specifics as needed.

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
3. Track command complete:
   - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-ci-setup` (include error details if command failed)
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
   - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit CI workflow files to customize configuration
- Run `/gbm.architecture` if architectural changes affect CI
- Re-run `/gbm.ci-setup` to regenerate with updated settings

