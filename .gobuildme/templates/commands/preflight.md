---
description: "Quick preflight check before formal review: lint, type-check, tests, and coverage validation"
artifacts:
  - path: "(console output)"
    description: "Preflight check summary with lint/type/test/coverage status and findings"
scripts:
  sh: scripts/bash/run-lint.sh
  ps: scripts/powershell/run-lint.ps1
---

## Output Style Requirements (MANDATORY)

**Preflight Check Output**:
- Status summary first: PASS / WARNINGS / FAIL with counts
- Findings as table: severity | file:line | issue | fix
- No explanations of what linting rules do
- Action items numbered, one per line

**Coverage Analysis**:
- Table format: file | current | target | gap
- List only files below threshold
- No prose about coverage importance
For complete style guidance, see .gobuildme/templates/_concise-style.md


1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.preflight" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. Execute the following preflight checks in order and summarize results:

1) **Lint**: run `.gobuildme/scripts/bash/run-lint.sh` and capture warnings/errors.
2) **Type-check**: run `.gobuildme/scripts/bash/run-type-check.sh` and capture issues.
3) **Tests**: run `.gobuildme/scripts/bash/run-tests.sh --json` and parse detected stacks and exit codes.
4) **Coverage**: if coverage reported, compare to plan's threshold; if below, identify weakest areas and propose tests.
5) **Summary**: produce a concise preflight check summary including:
   - ✅ PASS / ⚠️ WARNINGS / ❌ FAIL status for each check
   - Key findings requiring attention
   - Coverage gaps and test suggestions
   - Ready for /gbm.review? (yes/no with blockers)

Rules:
- Don’t block on missing tools; suggest minimal install commands when a category can’t run.
- Respect the repo’s Codebase Profile and Compatibility Constraints.

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
3. Track command complete:
   - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-preflight` (include error details if command failed)
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
   - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Preflight Check Complete**

**If all checks passed (✅):**
→ Ready for `/gbm.review` (comprehensive quality gate)

**If warnings/failures found (⚠️/❌):**
1. Address findings by editing code
2. Re-run `/gbm.preflight` to verify fixes
3. Once clean, proceed to `/gbm.review`

**Quick fixes vs comprehensive review:**
- `/gbm.preflight` = Quick validation (lint, type, tests, coverage)
- `/gbm.review` = Comprehensive gate (architecture, security, conventions, deployment readiness)

