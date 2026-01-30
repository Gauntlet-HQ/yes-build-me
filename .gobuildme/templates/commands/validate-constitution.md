---
description: "Validate project compliance with constitutional principles and requirements."
artifacts:
  - path: ".gobuildme/validation/<feature>/constitution-validation.md"
    description: "Validation report confirming adherence to project constitution principles"
scripts:
  sh: scripts/bash/validate-constitution.sh
  ps: scripts/powershell/validate-constitution.ps1
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

### Step 1: Track command start
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.validate-constitution" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

### Step 2: Run prerequisite script

Run {SCRIPT} to validate that the current project complies with all constitutional principles defined in `$CONSTITUTION_PATH` (or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`).

This command checks:

## Constitutional Principle Validation

1. **Test-First Compliance**
   - Verifies that test files exist in the project
   - Checks for proper test directory structure
   - Validates TDD principle adherence

2. **Library-First Structure**
   - Confirms proper library organization
   - Validates modular architecture
   - Checks for standalone, testable components

3. **CLI Interface Requirements**
   - Verifies CLI entry points exist
   - Validates command-line interface compliance
   - Checks for proper CLI structure

4. **Security Requirements**
   - Scans for hardcoded secrets in code
   - Validates secure configuration practices
   - Checks for security policy compliance

5. **Dependency Management**
   - Verifies dependency pinning (lock files)
   - Validates supply chain security practices
   - Checks for proper dependency management

6. **Architecture Baseline**
   - Validates architectural boundaries
   - Checks layer separation compliance
   - Verifies forbidden coupling rules

## Exit Codes

- **0**: All constitutional requirements met
- **1**: Critical constitutional violations found
- **Warnings**: Non-critical issues that should be addressed

### Step 3: Track command complete
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-validate-constitution` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Fix constitutional violations in code/design/documentation
- Update `$CONSTITUTION_PATH` (or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`) if principles need revision (with team approval)
- Re-run `/gbm.validate-constitution` after fixes to verify compliance

Use this command regularly to ensure ongoing constitutional compliance throughout the development process.
