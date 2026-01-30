---
description: Create or update the feature specification from a natural language feature description.
scripts:
  sh: scripts/bash/setup-specify.sh --json "{ARGS}"
  ps: scripts/powershell/setup-specify.ps1 -Json "{ARGS}"
artifacts:
  - path: "$FEATURE_DIR/spec.md"
    description: "Feature specification with requirements, acceptance criteria, and technical constraints. Metadata is automatically recorded for audit trail (created timestamp, author, artifact path)."
---

## Output Style Requirements (MANDATORY)

**Specification Output**:
- 3-5 bullets per section (more only when acceptance criteria require full coverage)
- One-sentence section intros - no multi-paragraph preambles
- Tables for entity attributes, acceptance criteria matrices, and comparisons
- Given-When-Then format for acceptance criteria - keep each AC to 3-5 lines
- No restating the feature description in different words

**Test Specifications**:
- Test case names must be self-documenting (no comments explaining what test does)
- Group related test cases - max 10 per test file section
- Reference AC IDs, don't repeat AC text

**Functional Requirements**:
- Action-first language ("System validates..." not "The system should validate...")
- One requirement per bullet
- Testable and specific (no vague adjectives without quantification)

For complete style guidance, see .gobuildme/templates/_concise-style.md

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

The text the user typed after `/gbm.specify` in the triggering message **is** the feature description. Assume you always have it available in this conversation even if `{ARGS}` appears literally below. Do not ask the user to repeat it unless they provided an empty command.

Given that feature description, do this:

**Script Output Variables**: The `{SCRIPT}` output above provides key paths. Parse and use these values:
- `FEATURE_DIR` - Feature directory path (e.g., `.gobuildme/specs/<feature>/` or `.gobuildme/specs/epics/<epic>/<slice>/`)
- `SPEC_FILE` - Path to spec.md
- `REQUEST_FILE` - Path to request.md

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.specify" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in step 8 for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. **Load Persona Configuration** (with Participants Support):

   **Load feature persona file**:
   - Read `$FEATURE_DIR/persona.yaml`
   - Extract `feature_persona` (driver persona ID)
   - Extract `participants` (list of participant persona IDs, may be empty list or missing field)
   - If file missing, fall back to `default_persona` from `.gobuildme/config/personas.yaml`

   **Build active personas list**:
   - Active personas = [driver] + participants
   - Example: If driver=`backend_engineer` and participants=`[security_compliance, sre]`
   - Then active_personas = `[backend_engineer, security_compliance, sre]`
   - If participants empty or missing: active_personas = [driver] only

   **Merge required sections for /specify**:
   - For each persona in active_personas:
     * Read `.gobuildme/personas/<persona_id>.yaml`
     * Extract `required_sections["/specify"]` (may not exist for all personas)
     * Collect all sections into merged list
   - Ensure ALL merged sections are included as headings in the spec
   - Example merged sections:
     * Backend Engineer: ["API Contracts", "Data Model"]
     * Security: ["Threat Model", "Data Classification"]
     * Result: All 4 sections required in spec

   **Include persona partials**:
   - For each persona in active_personas:
     * If `templates/personas/partials/<persona_id>/specify.md` exists:
       - Include its content under a `### <Persona Name> Considerations` section
   - If no persona files exist, proceed as generalist

   **Error Handling**:
   - If participant persona file missing: Skip with warning, continue with remaining personas
   - If driver persona file missing: Fall back to default_persona
   - If no valid personas found: Proceed as generalist (no persona enforcement)

   **Validation**:
   - Report which personas are active (driver + participants)
   - Show merged required sections grouped by persona
   - Validate final spec contains all merged sections

3. Run the script `{SCRIPT}` from repo root and parse its JSON output for BRANCH_NAME and SPEC_FILE. If a `REQUEST_FILE` exists alongside the spec (created via `/gbm.request`), load it for context. If `$FEATURE_DIR/prd.md` exists, load it and carry over Goals, Non‑Goals, and Success Metrics into the specification (reconcile differences explicitly). All file paths must be absolute.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").
  **IMPORTANT** You must only ever run this script once. The JSON is provided in the terminal as output - always refer to it to get the actual content you're looking for.

4. **Load External References** (if provided in request.md):

   If request.md contains a References section with external URLs:
   - For each external URL (Confluence pages, web documentation, API docs):
     * Use WebFetch tool to retrieve and summarize content
     * Focus on technical details relevant to specification (requirements, constraints, API contracts, integration patterns)
     * Save summary to `$FEATURE_DIR/docs/references/<sanitized-title>.md`
   - Use fetched content to inform:
     * Functional and non-functional requirements
     * API contracts and integration details
     * Technical design decisions and constraints
     * Acceptance criteria
   - If fetch fails for any URL: Note the failure in specification and continue (non-blocking)
   - Skip this step if no external references provided

5. **Load All Available Context** (for specification creation):

   **5a. Feature-Specific Artifacts** (from request phase):
   - `$FEATURE_DIR/request.md` - Original user request, goals, assumptions
   - `$FEATURE_DIR/docs/references/` - External documentation summaries (if any)
     * Confluence pages, technical docs, API specs, design docs
     * Fetched in step 4 via WebFetch
     * Non-blocking if directory doesn't exist or is empty

   **5b. Architecture Documentation** (MANDATORY for existing codebases):

   **Root Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_architecture_dirs()` to get ordered list of architecture directories
   - Search order: module-level first → workspace/monorepo root second
   - Example: In monorepo module, checks `apps/api/.gobuildme/docs/technical/architecture/` then `<root>/.gobuildme/docs/technical/architecture/`

   **Architecture files to load** (from each discovered architecture directory):
   - `system-analysis.md` - Architectural patterns, decisions, integration points
   - `technology-stack.md` - Languages, frameworks, libraries, and approved technologies
   - `security-architecture.md` - Auth patterns, security requirements, compliance constraints
   - `integration-landscape.md` - External service integrations (if exists)

   **BLOCKING**: If codebase exists but no architecture files found in any searched directory → Stop and display: "❌ Architecture required. Run `/gbm.architecture` first."

   **Skip for**: New/empty projects with no existing source code.

   **5c. Governance & Principles** (NON-NEGOTIABLE):

   **Constitution Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_constitution_path()` to get constitution location
   - Constitution is ALWAYS at workspace/monorepo root (not per-module)
   - Single repo: `<repo>/.gobuildme/memory/constitution.md`
   - Monorepo/Workspace: `<root>/.gobuildme/memory/constitution.md`

   - Constitution file contains organizational rules, security requirements, architectural constraints
   - **CRITICAL**: Constitution defines non-negotiable principles for specification
   - Constitutional constraints override user preferences and specification decisions
   - Any specification that conflicts with constitution must be rejected or revised
   - Create/update feature context at `$FEATURE_DIR/docs/technical/architecture/feature-context.md`

   **Usage**:
   - Use request.md goals to inform specification structure
   - Use external references to enhance requirements and acceptance criteria
   - Use architecture patterns to define architectural requirements
   - Use technology stack to specify technology-specific requirements
   - Use security architecture to define security requirements
   - Use constitution to enforce non-negotiable organizational principles

6. **PR Slice Scope Assessment (PR-Friendly Incremental Delivery)**:

   **Goal**: Ensure this spec is PR-sized and slice-scoped (so `/gbm.review` can pass honestly).

   1) **Extract PR slice context** from `$FEATURE_DIR/request.md` if present:
      - Look for `## Epic & PR Slice (Incremental Delivery)` section
      - Capture: Epic Link/Name (optional), PR Slice (`standalone` or `N/M`), In-Scope deliverables, Deferred items
      - If missing: set `PR Slice: standalone` and keep Deferred empty

   2) **If request is clearly too large for one PR**:
      - STOP and propose a PR slicing plan (PR-1/PR-2/PR-3) with explicit scope boundaries
      - Recommend creating separate feature branches/folders per slice (e.g., `slug: <feature>-pr1`)
      - Continue this `/gbm.specify` run ONLY for PR-1 scope (do not spec the whole epic in one slice)

7. **Specification Creation with Metadata Frontmatter** (MANDATORY - YOU MUST DO THIS):
   - **CRITICAL**: You must write the actual specification content to SPEC_FILE WITH metadata frontmatter
   - **DO NOT leave the template placeholders** - replace them with real content
   - Load the current SPEC_FILE (it contains the template structure)
   - Transform the user's feature description into a detailed specification with YAML frontmatter:

   **PR Slice Sections (MANDATORY)**:
   - Add a section near the top of `spec.md`:
     * `## Epic & PR Slice Context (Incremental Delivery)`
     * Include: Epic Link/Name (optional), PR Slice (`standalone` or `N/M`), and an explicit “This PR Delivers” list
   - Add: `## Deferred to Future PRs (Out of Scope)`:
     * List deferred scope for PR-2/PR-3 with dependencies
     * **Rule**: Deferred items MUST NOT appear in this slice’s Acceptance Criteria or tasks.md

   **Generate spec.md WITH this metadata frontmatter structure** (ADD TO TOP OF FILE):
   ```markdown
   ---
   description: "[One-line summary of specification]"
   metadata:
     feature_name: "[BRANCH_NAME from step 1, without special chars]"
     artifact_type: specify
     created_timestamp: "[GENERATE: Current date/time in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ]"
     created_by_git_user: "[Run: git config user.name - extract the result here]"
     input_summary:
       - "[Key requirement 1 from specification]"
       - "[Key requirement 2]"
       - "[Key requirement 3]"
       - "[Continue with 5-10 total key requirements/features]"
   ---

   # [Feature Name] Specification

   [Rest of specification content...]
   ```

   **Metadata Field Details:**
   - `feature_name`: Extract from BRANCH_NAME (must match request.md feature_name)
   - `created_timestamp`: Generate current timestamp in ISO 8601 format with Z suffix
   - `created_by_git_user`: Get from `git config user.name` - use the git username
   - `input_summary`: **CRITICAL - Extract 5-10 key points ONLY from the USER INPUT (not from specification content):**
     * Review the user input provided when `/gbm.specify` was invoked (or load from request.md if available)
     * Extract the main requirements/constraints the user explicitly asked for
     * Example: If user specified "API-first design with Pydantic validation" → extract "API-first design with Pydantic validation"
     * Example: If user said "must support keyboard input" → extract "Support keyboard input in addition to button clicks"
     * **IF user provided NO input to specify**: Set `input_summary: []` (empty array) or reference request.md input_summary
     * DO NOT extract from the specification sections you wrote - those are generated content
     * Extract ONLY what the user asked for in their original specify request
     * Match user requirements, not specification details or artifact structure

   **Required Actions:**
   a) **Replace template placeholders**:
      - `[FEATURE NAME]` → actual feature name from user description
      - `[###-feature-name]` → actual BRANCH_NAME from step 1
      - `[DATE]` → current date
      - `$ARGUMENTS` → the user's feature description

   b) **Fill in User Scenarios & Testing section**:
      - Write concrete user scenarios based on the feature description
      - Create realistic acceptance scenarios with Given-When-Then format
      - Identify relevant edge cases

   c) **Generate complete Acceptance Criteria**:
      - **Happy Path Criteria**: Core functionality that must work (AC-001, AC-002, etc.)
      - **Error Handling Criteria**: System behavior when things go wrong (AC-E01, AC-E02, etc.)
      - **Edge Case Criteria**: Boundary conditions and unusual scenarios (AC-B01, AC-B02, etc.)
      - **Performance Criteria**: Non-functional requirements where relevant (AC-P01, AC-P02, etc.)
      - **Security Criteria**: Security and access control requirements where relevant (AC-S01, AC-S02, etc.)
      - Use proper Given-When-Then format for all acceptance criteria
      - Make all acceptance criteria specific, testable, and verifiable

   d) **Generate Test Specifications (MANDATORY - TDD)** ⭐:
      - **CRITICAL**: Test specifications are as important as acceptance criteria
      - **Create test cases from acceptance criteria**: Each AC → 1+ test cases
      - **Define test file organization**: Specify where each test file will live

      **Test Specification Format** (create for each major component):
      ```
      ## Test Specifications

      ### Unit Tests: [Component Name]
      - **Test File**: tests/unit/[path]/test_[component].py
      - **Test Cases**:
        - test_[scenario_name]() - [description matching AC]
        - test_[scenario_name]() - [description matching AC]

      ### Integration Tests: [Feature/Workflow]
      - **Test File**: tests/integration/[path]/test_[feature].py
      - **Test Cases**:
        - test_[workflow_name]() - [description matching user story]
        - test_[error_scenario]() - [description matching AC-E]

      ### Contract Tests: [API Endpoint]
      - **Test File**: tests/api/contracts/test_[endpoint].py
      - **Endpoint**: [METHOD] [PATH]
      - **Test Cases**:
        - test_[success_scenario]() - Status [code], returns [schema]
        - test_[error_scenario]() - Status [code], returns error
      ```

      **Example for User Creation Feature**:
      ```
      ### Unit Tests: User Model
      - **Test File**: tests/unit/models/test_user.py
      - **Test Cases**:
        - test_user_creation_with_valid_data() - Creates User from name+email (AC-001)
        - test_user_email_required() - Throws ValidationError if email missing (AC-E01)
        - test_user_email_validation() - Validates email format (AC-E02)
        - test_user_role_defaults_to_viewer() - Default role is 'viewer' (AC-002)

      ### Integration Tests: User Registration Workflow
      - **Test File**: tests/integration/workflows/test_user_registration.py
      - **Test Cases**:
        - test_user_registration_complete_flow() - User created → email sent → logged
        - test_user_registration_invalid_email_fails() - Invalid email → 400 + error msg
        - test_user_registration_duplicate_email_fails() - Duplicate → conflict error

      ### Contract Tests: POST /api/users
      - **Test File**: tests/api/contracts/test_users_endpoint.py
      - **Endpoint**: POST /api/users
      - **Test Cases**:
        - test_create_user_201() - Status 201, returns user object
        - test_create_user_missing_email_400() - Status 400, returns validation error
        - test_create_user_unauthorized_401() - Status 401 without auth token
      ```

      **Why Test Specs Are MANDATORY**:
      - Prevents agents from writing tests AFTER implementation (not TDD)
      - Makes test-first discipline explicit and enforceable
      - Allows /gbm.plan stage to assign tests as "Phase 1" tasks
      - Ensures test coverage matches acceptance criteria

   e) **Create Functional Requirements**:
      - Extract specific functional requirements from the feature description
      - Ensure each requirement is testable and unambiguous
      - Link requirements to corresponding acceptance criteria

   f) **Fill in Key Entities section** (if applicable):
      - Identify data entities involved in the feature
      - Define entity relationships and attributes

   g) **Use architectural context**:
      - **IMPORTANT**: The data-collection.md file contains RAW DATA only - not final architecture documentation
      - If working with existing codebase: Use YOUR previously created architecture documentation in `.gobuildme/docs/technical/architecture/`
      - If working with new project: Use constitutional principles and the raw data to establish architectural foundation
      - Ensure the specification aligns with architectural patterns (existing or planned)
      - Note any architectural constraints or dependencies

   h) **Save the completed specification** to SPEC_FILE

7. **Architecture Compliance Validation** (MANDATORY):
   - **CRITICAL**: You MUST validate architectural compliance before completing the specification

   **Required Validation Steps**:
   a) **Verify architecture documentation and analysis was completed**:
      - **For existing codebases**:
        * **Confirm YOU created global architecture**: `.gobuildme/docs/technical/architecture/system-analysis.md`
        * **If missing**: STOP and run `/gbm.architecture` command first - YOU must create the documentation
        * **Validate YOUR analysis**: Ensure you have full understanding of the system architecture YOU documented
        * **CRITICAL**: Shell scripts only collect raw data - YOU create the actual architecture documentation
      - **For new/empty projects**: Skip global architecture validation (no existing code to analyze)
      - **Confirm feature context exists**: `$FEATURE_DIR/docs/technical/architecture/feature-context.md`

   b) **Validate specification alignment**:
      - **Constitutional compliance**: Ensure all functional requirements respect architectural boundaries defined in the constitution
      - **Architectural boundaries**: Verify that proposed features don't violate forbidden couplings or layering constraints
      - **Technology alignment**: Check that technology choices align with approved frameworks and libraries detected in the analysis
      - **Pattern consistency**: Validate that the specification leverages existing patterns identified in the architecture analysis
      - **Security compliance**: Ensure security requirements align with existing authentication mechanisms found in the analysis

   c) **Check for violations**:
      - **SLO/SLA consistency**: Validate that non-functional requirements are consistent with existing SLO/SLA targets
      - **Dependency validation**: Check that new dependencies are justified and don't conflict with existing architecture
      - **Boundary respect**: Confirm the feature doesn't cross inappropriate architectural boundaries

   d) **Flag issues**: Flag any requirements that might require constitutional amendments or architectural changes

   **If validation fails**: Update the specification to address architectural concerns before proceeding

8. **Completion Report** (MANDATORY):
   - **CRITICAL**: You MUST provide a complete status report

   **Required Reporting**:
   a) **Architecture Documentation & Analysis Status**:
      - **For existing codebases**: Report that YOUR created `.gobuildme/docs/technical/architecture/` documentation was used
      - **For new/empty projects**: Report that constitutional principles were used as architectural foundation
      - **Confirm feature context created**: Report path to `$FEATURE_DIR/docs/technical/architecture/feature-context.md`
      - **Architectural understanding**: Report your key architectural findings (style, technology stack, patterns, security)
      - **CRITICAL**: Confirm that YOU (AI Agent) created the architecture documentation, not shell scripts

   b) **Specification Status**:
      - **Confirm specification was written**: Report that SPEC_FILE was updated with actual content (not template)
      - **Template replacement verified**: Confirm all placeholders were replaced with real content
      - **Branch and paths**: Report branch name, spec file path, and readiness for the next phase

   c) **Acceptance Criteria & Test Specifications Summary**:
      - **AC completeness**: Report number of ACs generated by category (Happy Path, Error Handling, Edge Cases, Performance, Security)
      - **Coverage validation**: Confirm each functional requirement has corresponding acceptance criteria
      - **Format compliance**: Verify all ACs follow Given-When-Then format
      - **Test specs completeness**: Report number of test specifications created (unit, integration, contract)
      - **Test coverage**: Confirm each AC has corresponding test case(s)
      - **Test files identified**: List all test files that will be created in the Plan/Implement phases

   d) **Architecture Compliance**:
      - **Constitutional alignment**: Confirm specification aligns with constitutional principles
      - **Architectural concerns**: Highlight any architectural concerns or constitutional conflicts that need resolution
      - **Boundary compliance**: Confirm no forbidden couplings or boundary violations

   e) **Quality Gates**:
      - **Completeness check**: Flag any functional requirements that may need additional acceptance criteria
      - **Clarity validation**: Note any sections that may need clarification in `/gbm.clarify` phase
      - **Test spec completeness**: Flag any acceptance criteria without corresponding test specifications
      - **TDD readiness**: Confirm test specifications are detailed enough to enable test-first implementation
      - **Readiness assessment**: Confirm specification is ready for `/gbm.clarify` phase
      - **CRITICAL**: All checklist items in spec.md start as `[ ]` - mark as `[x]` ONLY when verified

9. Track command complete and trigger auto-upload:
   - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-specify` (include error details if command failed)
   - **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
   - Run `.gobuildme/scripts/bash/post-command-hook.sh --command "gbm.specify" --status "success|failure" --command-id "$command_id" --feature-dir "$SPEC_DIR" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
   - This handles both telemetry tracking AND automatic spec upload (if enabled in manifest)
   - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

## Persona-Aware Next Steps

**Detecting Persona** (always do this):
1. Read: `.gobuildme/config/personas.yaml` → check `default_persona` field
2. Store the value in variable: `$CURRENT_PERSONA`
3. If file doesn't exist or field not set → `$CURRENT_PERSONA = null`

**All Personas - Recommended First Step**:
- **Validate Requirements Quality**: Run `/gbm.checklist` to validate specification completeness, clarity, consistency, and coverage

## Next Steps: Review & Approval

⚠️ **IMPORTANT: Before you proceed to clarification, review the generated `spec.md` completely:**
- Does every acceptance criterion match actual requirements?
- Are edge cases and error scenarios covered?
- Are test specifications concrete and testable?

**When you run `/gbm.clarify`, you are confirming:**
> "I have reviewed `spec.md`. It's accurate, complete, and testable. I approve it and accept responsibility for it."

Your action of running the next command = explicit approval. No confirmation prompt will be shown.

**Persona-Specific Review Focus** (all personas → `/gbm.clarify`):

| Persona | Key Review Focus Areas |
|---------|------------------------|
| backend_engineer | API edge cases, auth/authz, SLAs, DB migrations, error handling |
| frontend_engineer | UX states, WCAG compliance, responsive, browser compat, perf budgets |
| fullstack_engineer | E2E edge cases, contracts, state sync, error boundaries, performance |
| qa_engineer | ALL edge cases, test scenarios per AC, boundary conditions, fixtures |
| architect | Architectural ambiguities, NFR thresholds, integration boundaries |
| product_manager | User story scope, success metrics, MVP priority, business rules |
| data_engineer | Schema edge cases, transformation logic, retry/failure, idempotency |
| ml_engineer | Feature engineering, model thresholds, inference latency, versioning |
| sre | SLO thresholds, alerting, disaster recovery, monitoring, capacity |
| security_compliance | Threat model, security controls, compliance gaps, audit logging |
| data_scientist | Metric definitions, statistical methods, sample size, bias control |
| maintainer | Code quality, tech debt, pattern consistency, test coverage, docs |
| null (not set) | Run `/gbm.persona` first to set role and get personalized guidance |

**For extended guidance**: Read `.gobuildme/templates/reference/persona-next-steps.md` for detailed focus areas and quality gate requirements per persona.

Note: The script reuses the latest request-only folder (request.md present; spec.md missing/empty). If none exists, it creates and checks out a new feature branch and initializes the spec file before writing.

## Optional: Spec Repository Upload

After generating `spec.md`, you can optionally upload the spec directory to the centralized repository:

→ `/gbm.upload-spec` - Upload specs to S3 for cross-project analysis and centralized storage

*Requires AWS credentials. Use `--dry-run` to validate access first.*

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Core workflow:**
→ `/gbm.clarify` (if ambiguities exist)
→ `/gbm.plan` (create implementation plan)

**Optional quality gates** (use when needed):
- `/gbm.checklist` — Requirements quality validation ("unit tests for specs")
- `/gbm.fact-check` — Verify research claims and citations
- `/gbm.design` — Create dedicated design doc (for complex features)

**Not ready?**
- Run `/gbm.clarify` to resolve ambiguities and add missing details
- Manually edit `$FEATURE_DIR/spec.md` to refine requirements
- Re-run `/gbm.specify` with better description or additional context
