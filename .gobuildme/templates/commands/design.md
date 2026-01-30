---
description: "Create a design document for this feature aligned with the codebase profile."
artifacts:
  - path: "$FEATURE_DIR/design.md"
    description: "Concise design document for the feature (optional, detailed design phase)"
scripts:
  sh: scripts/bash/create-design.sh "$ARGUMENTS"
  ps: scripts/powershell/create-design.ps1 -Feature "$ARGUMENTS"
---

## Output Style Requirements (MANDATORY)

**Design Output**:
- 3-5 bullets per section
- Diagrams (mermaid) over prose for system boundaries and data flows
- Tables for interface definitions and risk matrices
- One-sentence rationale per design decision
- No restating PRD or spec content - reference them

**Test Strategy**:
- Table format: test type | scope | coverage target
- No prose explanations of testing philosophy
For complete style guidance, see .gobuildme/templates/_concise-style.md


1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.design" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. Run {SCRIPT}. It will:
   - Load the Codebase Profile (from /gbm.plan step 0 or regenerate via scan-codebase)
   - Read PRD at `$FEATURE_DIR/prd.md` (if present) and spec
   - Create `$FEATURE_DIR/design.md` from `templates/design-template.md`
   - Capture boundaries, data flows, interfaces, risks, and test strategy

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
3. Track command complete:
   - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-design` (include error details if command failed)
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
   - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit design documentation to refine approach
- Run `/gbm.plan` to update technical design first
- Re-run `/gbm.design` with refined specifications

