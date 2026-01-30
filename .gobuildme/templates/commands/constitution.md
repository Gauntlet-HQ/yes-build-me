---
description: "Create or update the project constitution with non-negotiable principles, governance rules, and quality standards"
artifacts:
  - path: "$WORKSPACE_ROOT/.gobuildme/memory/constitution.md"
    description: "Project constitution containing principles, governance rules, and quality standards"
scripts:
  sh: scripts/bash/get-telemetry-context.sh
  ps: scripts/powershell/get-telemetry-context.ps1
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

**IMPORTANT**: `/gbm.constitution` is the foundational command that establishes **a set of non-negotiable principles** for your project, including governance rules, architectural principles, and quality standards. It should be run BEFORE any development work begins to ensure all subsequent commands have proper constitutional guidance.

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

---

## Step 0: Workspace-Aware Path Resolution (MANDATORY)

**Purpose**: In monorepo/workspace environments, the constitution lives at the WORKSPACE ROOT, not the nearest `.gobuildme/`.

**Resolve WORKSPACE_ROOT**:
1. Walk up from CWD looking for `.gobuildme/manifest.json` with `"mode": "workspace"` or `"mode": "monorepo"`
2. The outermost such directory is WORKSPACE_ROOT
3. If no workspace/monorepo manifest found, use the nearest `.gobuildme/` as WORKSPACE_ROOT
4. Environment override: If `$GOBUILDME_WORKSPACE_ROOT` is set, use that value

**CONSTITUTION_PATH**: `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`

**CRITICAL**: Constitution is a GLOBAL artifact shared across all modules/repos in a workspace. Always write to WORKSPACE_ROOT, never to a module-level `.gobuildme/`.

---

You are updating the project constitution at `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`. This file is a TEMPLATE containing placeholder tokens in square brackets (e.g. `[PROJECT_NAME]`, `[PRINCIPLE_1_NAME]`). Your job is to (a) collect/derive concrete values for **non-negotiable principles and governance rules**, (b) fill the template precisely, and (c) propagate any amendments across dependent artifacts.

Follow this execution flow:

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.constitution" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. **Load the existing constitution template** at `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`.
   - **Path verification**: Use WORKSPACE_ROOT resolved in Step 0 (not CWD or module path)
   - If the file doesn't exist, this project may not be properly initialized (run `gobuildme init` first)
   - Identify every placeholder token of the form `[ALL_CAPS_IDENTIFIER]`.
   **IMPORTANT**: The user might require less or more principles than the ones used in the template. If a number is specified, respect that - follow the general template. You will update the doc accordingly.

2a. **Constitution Update with Metadata Frontmatter** (MANDATORY):
   - When updating constitution.md, ADD this YAML frontmatter structure at the top:

   ```markdown
   ---
   description: "[One-line summary of project principles and governance]"
   metadata:
     artifact_type: constitution
     created_timestamp: "[GENERATE: Current date/time in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ]"
     created_by_git_user: "[Run: git config user.name - extract the result here]"
     input_summary:
       - "[Key principle 1 from constitution]"
       - "[Key principle 2]"
       - "[Key governance principle]"
       - "[Continue with 5-10 total key principles/values]"
   ---

   # Project Constitution

   [Rest of constitution content...]
   ```

   **Metadata Field Details:**
   - **NOTE**: Constitution has NO `feature_name` (it's global project governance, not feature-specific)
   - `created_timestamp`: Generate current timestamp in ISO 8601 format with Z suffix
   - `created_by_git_user`: Get from `git config user.name` - use the git username
   - `input_summary`: **CRITICAL - Extract 5-10 key points ONLY from the USER INPUT (not from constitution content):**
     * Review the user input provided when `/gbm.constitution` was invoked
     * Extract the main principles/values the user explicitly specified
     * Example: If user said "mandatory Test-Driven Development" → extract "Test-Driven Development mandatory for all features"
     * Example: If user specified "API-first design approach" → extract "API-First Design with REST APIs and Pydantic validation"
     * **IF user provided NO input to constitution (empty $ARGUMENTS)**: Set `input_summary: []` (empty array) - CRITICAL!
       - This is the most common case: user runs `/gbm.constitution` with no arguments, triggering template-based generation
       - Empty input_summary correctly indicates the constitution was generated, not user-requested
     * DO NOT extract from the constitution sections you wrote - those are generated content
     * Extract ONLY what the user explicitly asked for or implied in their constitution request
     * Match user intent/principles, not the detailed constitution document structure

3. Collect/derive values for placeholders:
   - If user input (conversation) supplies a value, use it.
   - Otherwise infer from existing repo context (README, docs, prior constitution versions if embedded).
   - For governance dates: `RATIFICATION_DATE` is the original adoption date (if unknown ask or mark TODO), `LAST_AMENDED_DATE` is today if changes are made, otherwise keep previous.
   - `CONSTITUTION_VERSION` must increment according to semantic versioning rules:
     * MAJOR: Backward incompatible governance/principle removals or redefinitions.
     * MINOR: New principle/section added or materially expanded guidance.
     * PATCH: Clarifications, wording, typo fixes, non-semantic refinements.
   - If version bump type ambiguous, propose reasoning before finalizing.

4. Draft the updated constitution content:
   - Replace every placeholder with concrete text (no bracketed tokens left except intentionally retained template slots that the project has chosen not to define yet—explicitly justify any left).
   - Preserve heading hierarchy and comments can be removed once replaced unless they still add clarifying guidance.
   - Ensure each Principle section: succinct name line, paragraph (or bullet list) capturing non‑negotiable rules, explicit rationale if not obvious.
   - Ensure Governance section lists amendment procedure, versioning policy, and compliance review expectations.
   - **LoC Analysis section**: Review "Code Organization Constraints (LoC Analysis)":
     * Set `loc_constraints.enabled` to true/false
     * Adjust branch/artifact limits and exclusions to fit your codebase
     * Leave disabled if you do not want LoC analysis
   - Preserve the section titled "Organizational Rules (Fixed)" verbatim, including its subsections "GoFundMe Engineering Rules" and "Security Requirements". Do not rename, delete, weaken, or reword these rules; they are mandatory organizational requirements.

5. Consistency propagation checklist (convert prior checklist into active validations):
   - Read `templates/plan-template.md` and ensure any "Constitution Check" or rules align with updated principles.
   - Read `templates/spec-template.md` for scope/requirements alignment—update if constitution adds/removes mandatory sections or constraints.
   - Read `templates/tasks-template.md` and ensure task categorization reflects new or removed principle-driven task types (e.g., observability, versioning, testing discipline).
   - **IMPORTANT - Testing Principles**: Ensure constitution includes explicit testing principles:
     * **TDD Requirement**: Is Test-Driven Development mandatory, recommended, or optional?
     * **Test Coverage Target**: What's the minimum coverage threshold (default: 85%)?
     * **Test Types Required**: Which types are required (unit, integration, contract/API tests)?
     * **Test Framework**: Which test framework(s) are approved?
     * **Test Organization**: Where should test files live (tests/unit/, tests/integration/, etc.)?
   - Read each command file in `templates/commands/*.md` (including this one) to verify no outdated references (agent-specific names like CLAUDE only) remain when generic guidance is required.
   - Read any runtime guidance docs (e.g., `README.md`, `docs/quickstart.md`, or agent-specific guidance files if present). Update references to principles changed.

6. Produce a Sync Impact Report (prepend as an HTML comment at top of the constitution file after update):
   - Version change: old → new
   - List of modified principles (old title → new title if renamed)
   - Added sections
   - Removed sections
   - Templates requiring updates (✅ updated / ⚠ pending) with file paths
   - Follow-up TODOs if any placeholders intentionally deferred.

7. Validation before final output:
   - No remaining unexplained bracket tokens.
   - Version line matches report.
   - Dates ISO format YYYY-MM-DD.
   - Principles are declarative, testable, non-negotiable, and free of vague language ("should" → replace with MUST/SHOULD rationale where appropriate).

8. **Write the completed constitution** back to `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md` (overwrite).
   - **CRITICAL**: Write to WORKSPACE_ROOT, not CWD or module path
   - Create the `$WORKSPACE_ROOT/.gobuildme/memory/` directory if it doesn't exist
   - Overwrite the existing file with the completed constitution

9. Output a final summary to the user with:
   - New version and bump rationale.
   - Any files flagged for manual follow-up.
   - Suggested commit message (e.g., `docs: amend constitution to vX.Y.Z (principle additions + governance update)`).
   - Reminder to review and, if desired, configure the **Code Organization Constraints (LoC Analysis)** section in `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md` (enable/disable, adjust limits, update exclusions and artifact budgets).

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
10. Track command complete:
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-constitution` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Next Steps (always print at the end):

⚠️ **Before proceeding, review the constitution:**
- Does it capture your project's core principles?
- Are the quality standards appropriate?
- Do the governance rules make sense?

**Constitution as Foundation**: This document establishes non-negotiable principles that guide all future development decisions.

**Ready to start?**
- `/gbm.persona` - Set your role (architect, backend engineer, QA, etc.)
- `/gbm.architecture` - Analyze existing codebase (if applicable)
- `/gbm.request` - Capture your first feature request

**Not ready?** Edit `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md` directly, or run `/gbm.help constitution`
