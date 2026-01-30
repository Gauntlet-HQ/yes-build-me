---
description: Create or update implementation documentation for the current feature, including concise change summary and deployment notes.
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --paths-only
  ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
artifacts:
  - path: ".docs/implementations/<feature>/implementation-summary.md"
    description: "Concise implementation documentation with change summary, design decisions, and deployment notes"
---

## Output Style Requirements (MANDATORY)

**Documentation Output**:
- 3-5 bullets per section (more only for file lists or deployment steps)
- One-sentence section intros - no multi-paragraph overviews
- Tables for file changes, dependencies, and configuration items
- Action-first language in deployment notes ("Run X" not "You should run X")
- No restating information from spec.md or plan.md - reference them

**Request Summary**:
- Ticket reference as link, not prose
- 3-5 bullets for requirements, no full restatement

**Files Modified/Created**:
- Table format: file | change type | brief description
- No explanations of what the code does - that's in the code

**Deployment Notes**:
- Numbered steps only
- One action per step
- No explanatory prose between steps
For complete style guidance, see .gobuildme/templates/_concise-style.md


The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

**Goal**: Create concise implementation documentation that captures all changes, design decisions, and deployment requirements for the current feature implementation.

**User Input Processing**:
- If arguments provided: Use as focus areas for documentation (e.g., "focus on security changes", "update deployment notes")
- If no arguments: Create complete implementation documentation
- If "update" specified: Update existing implementation-summary.md with new information

**Error Handling**:
- If script execution fails: Report error and suggest manual path resolution
- If not on feature branch: Instruct user to switch to feature branch first
- If no implementation exists: Suggest running `/gbm.implement` first
- If JSON parsing fails: Abort and instruct user to verify feature branch environment

Execution steps:

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.document" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. Run `{SCRIPT}` from repo root **once** and parse JSON payload fields:
   - `FEATURE_DIR`
   - `FEATURE_SPEC`
   - If JSON parsing fails, abort and instruct user to verify feature branch environment.

3. **Architecture Context Loading** (MANDATORY):

   Load architecture from `.gobuildme/docs/technical/architecture/`. If missing and codebase exists, run `/gbm.architecture` first.
   Load constitution at `$CONSTITUTION_PATH` (or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`) for architectural principles.
   Load feature context for documentation accuracy.

   **Required files**: `system-analysis.md`, `technology-stack.md`, `security-architecture.md`

   **BLOCKING**: If codebase exists but architecture files missing → Stop and display: "❌ Architecture required. Run `/gbm.architecture` first."

4. **Load Implementation Context**:
   - **REQUIRED**: Read `request.md` for original requirements and ticket references
   - **REQUIRED**: Read `spec.md` for detailed specifications and acceptance criteria
   - **REQUIRED**: Read `plan.md` for implementation approach and technical decisions
   - **REQUIRED**: Read `tasks.md` for completed task breakdown
   - **IF EXISTS**: Read existing `.docs/implementations/<feature>/implementation-summary.md` for updates
   - **IF EXISTS**: Read `data-model.md`, `contracts/`, `research.md`, `quickstart.md`

5. **Analyze Implementation Changes**:
   - **Git Analysis**: Use `git diff --name-status origin/main...HEAD` to identify changed files
   - **Dependency Analysis**: Check for changes in package.json, requirements.txt, go.mod, etc.
   - **Configuration Analysis**: Identify environment variable changes and config file modifications
   - **Database Analysis**: Check for migration files or schema changes
   - **Test Analysis**: Identify test files created or modified

6. **Create Implementation Documentation** (MANDATORY):
   
   **Use Template**: Load `templates/implementation-summary-template.md` as the base structure
   
   **Required Content Generation**:
   
   a) **Request Summary**:
      - Extract ticket references from request.md
      - Identify stakeholders and business priority
      - Summarize core requirements and additional context
   
   b) **Implementation Scope & Changes**:
      - Document what was implemented vs. out of scope
      - Categorize changes (new features, bug fixes, refactoring, etc.)
      - Cross-reference with completed tasks from tasks.md
   
   c) **Design Decisions Made**:
      - Extract architectural decisions from plan.md and implementation
      - Document technology choices and rationale
      - Record pattern implementations and trade-offs considered
   
   d) **Architecture Impact**:
      - Analyze impact on global architecture
      - Document component integration changes
      - Assess security and performance implications
   
   e) **Files Modified/Created**:
      - Use git diff to generate accurate file lists
      - Categorize as new, modified, deleted, or configuration files
      - Include brief description of changes for key files
   
   f) **Testing Approach**:
      - Document test strategy from plan.md
      - Report actual test coverage achieved
      - List test files created or modified
   
   g) **Dependencies & External Changes**:
      - List new dependencies added with versions
      - Document updated dependencies
      - Record external service integrations or API changes
   
   h) **Configuration & Environment Changes**:
      - Document new environment variables required
      - List configuration file changes
      - Record database schema changes or migrations
   
   i) **Migration & Deployment Notes**:
      - Provide step-by-step deployment instructions
      - Document migration requirements and rollback plan
      - Include post-deployment verification steps
   
   j) **Known Issues & Limitations**:
      - Document current limitations and known issues
      - Identify technical debt introduced
      - Suggest future improvements

7. **Quality Validation**:
   - **Completeness Check**: Ensure all sections have meaningful content (not placeholders)
   - **Accuracy Validation**: Cross-reference documentation with actual implementation
   - **Traceability Verification**: Validate links to request, tickets, and related documents
   - **Actionability Review**: Ensure deployment instructions are clear and executable

8. **Save Documentation**:
   - **Create Directory**: Ensure `.docs/implementations/<feature>/` directory exists using `mkdir -p .docs/implementations/<feature>/`
   - **Write File**: Write the completed implementation summary to `.docs/implementations/<feature>/implementation-summary.md`

9. **Report Completion**:
   - Path to created/updated implementation documentation
   - Summary of key changes documented
   - Validation status of all required sections
   - Suggestions for any missing or incomplete information

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
10. Track command complete:
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-document` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

**Behavior Rules**:
- **Template Usage**: Always use the implementation-summary-template.md as the base structure
- **Content Quality**: Replace all placeholders with actual implementation details
- **Git Integration**: Use git commands to accurately capture file changes
- **Cross-Reference**: Validate information against existing specification documents
- **Completeness**: Ensure all sections are filled with meaningful, actionable content

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit generated documentation to improve clarity
- Run `/gbm.implement` if code changes affect documentation
- Re-run `/gbm.document` to regenerate from updated code

