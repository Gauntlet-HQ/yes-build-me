---
description: "Generate security workflows (Semgrep, optional CodeQL)."
artifacts:
  - path: ".github/workflows/security.yml"
    description: "GitHub Actions security scanning workflows and configurations"
scripts:
  sh: scripts/bash/setup-security.sh
  ps: scripts/powershell/setup-security.ps1
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.security-setup" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run {SCRIPT} with optional flags:
- `--codeql` (bash) or `-CodeQL` (PowerShell) to include a CodeQL job with detected languages.

The workflow is written to `.github/workflows/security.yml` and includes:
- Semgrep CI rules (requires `SEMGREP_APP_TOKEN` in repo secrets for full SaaS integration; otherwise runs locally).
- Optional CodeQL init/autobuild/analyze steps.

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-security-setup` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit security configuration files to adjust settings
- Run `/gbm.architecture` to update security architecture documentation
- Re-run `/gbm.security-setup` to regenerate security tools

