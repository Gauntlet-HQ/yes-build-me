---
description: Identify underspecified areas in the current feature spec by inferring answers from available context first, then asking minimal clarification questions (10 absolute maximum, fewer is better) only when inference is impossible.
scripts:
   sh: scripts/bash/check-prerequisites.sh --json --paths-only
   ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
artifacts:
  - path: "$FEATURE_DIR/spec.md"
    description: "Feature specification updated with clarifications, inferences, and resolved ambiguities"
---

## Output Style Requirements (MANDATORY)

**Clarification Output**:
- Questions as numbered list - one question per item
- No preamble before questions - get to the point
- Question format: "Q1: [specific question]?" + "Context: [why this matters in 1 sentence]"
- Inferences as table: area | inference | confidence | source

**Inference Documentation**:
- Table format: decision | inferred value | source document
- One-line rationale per inference
- No lengthy explanations of inference process

**Session Summary**:
- Resolved items as bullet list
- Remaining unknowns as bullet list
- No prose narratives of the clarification session
For complete style guidance, see .gobuildme/templates/_concise-style.md


The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

**Goal**: Detect and reduce ambiguity or missing decision points in the active feature specification by **FIRST inferring answers from available context** (request, architecture docs, additional materials), then asking minimal questions only when inference is impossible. Record all clarifications directly in the spec file.

**CRITICAL PRINCIPLE**: **INFER FIRST, ASK LAST**
- **Primary approach**: Analyze request.md, architecture documentation, constitutional principles, and spec context to infer reasonable answers
- **Secondary approach**: Ask questions ONLY when inference is genuinely impossible or would create significant risk
- **Question limit**: 10 is the ABSOLUTE MAXIMUM - fewer questions is always better
- **Quality over quantity**: One well-inferred answer is better than three questions

**Note**: This clarification workflow is expected to run (and be completed) BEFORE invoking `/gbm.plan`. If the user explicitly states they are skipping clarification (e.g., exploratory spike), you may proceed, but must warn that downstream rework risk increases.

**User Input Processing**:
User input: $ARGUMENTS

- If arguments provided: Use as additional context for clarification focus areas
- If no arguments: Proceed with thorough clarification analysis
- If invalid arguments: Ignore and proceed with standard clarification process

---

## Step 0: Workspace-Aware Path Resolution (from script output)

The script `{SCRIPT}` outputs workspace-aware paths. Parse these from the JSON output:
- `WORKSPACE_ROOT` - Workspace/monorepo root (for constitution, personas)
- `GBM_ROOT` - Nearest `.gobuildme/` (for feature artifacts)
- `CONSTITUTION_PATH` - Path to constitution.md
- `ARCHITECTURE_DIRS` - Colon-separated list of architecture directories (module → root order)

Use these resolved paths for all file access in monorepo/workspace environments.

---

Persona Context (optional, non-breaking):
- If `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` exists, read `default_persona`.
- If a persona id is set and `$WORKSPACE_ROOT/.gobuildme/personas/<id>.yaml` exists:
  * Load `required_sections["/gbm.clarify"]` and ensure those sections are addressed in clarifications.
  * Prefer clarifications that close gaps in that persona's `required_sections` for `/gbm.specify` and `/gbm.plan`.
  * If `$WORKSPACE_ROOT/.gobuildme/templates/personas/partials/<id>/clarify.md` exists, include its content under a `### Persona-Specific Clarifications` section.
- If files are missing, proceed as a generalist.

**Error Handling**:
- If script execution fails: Report error and suggest manual path resolution
- If specification file is missing: Instruct user to run `/gbm.specify` first
- If architecture documentation is missing: Suggest running `/gbm.architecture` first
- If architecture files exist but are empty: Proceed with clarification but note architectural constraints are unknown
- If JSON parsing fails: Abort and instruct user to re-run `/gbm.specify` or verify feature branch environment

Execution steps:

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.clarify" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. Run `{SCRIPT}` from repo root **once** (combined `--json --paths-only` mode / `-Json -PathsOnly`). Parse minimal JSON payload fields:
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").
   - `FEATURE_DIR`
   - `FEATURE_SPEC`
   - (Optionally capture `IMPL_PLAN`, `TASKS` for future chained flows.)
   - If JSON parsing fails, abort and instruct user to re-run `/gbm.specify` or verify feature branch environment.

2a. **Prerequisite Validation** (MANDATORY - BLOCKING):

   **CRITICAL**: You MUST verify that the feature specification exists before proceeding with clarification.

   **Check Specification File Exists**:
   - Verify `FEATURE_SPEC` path from JSON output is not empty
   - Attempt to read the specification file at the path
   - If file does not exist or is empty:
     * **BLOCK execution**: Do not proceed with clarification
     * **Error message**: "❌ Prerequisite missing: Feature specification not found"
     * **Required action**: "Run `/gbm.specify` to create the feature specification first"
     * **Exit**: Stop processing and wait for user to run `/gbm.specify`

   **Validate Specification Content**:
   - Verify spec.md contains actual content (not just template placeholders)
   - Check for minimum required sections (e.g., "## Feature Overview", "## Acceptance Criteria")
   - If specification is incomplete or contains only placeholders:
     * **WARNING**: "⚠️ Specification appears incomplete. Consider running `/gbm.specify` again with more detail."
     * **Continue**: Proceed with clarification but note that additional clarifications may be needed

   **Success Path**:
   - If specification exists and has content → Proceed to Context Loading

3. **Load All Available Context** (for inference and clarification):

   **3a. Feature-Specific Artifacts** (from request/specify phases):
   - `$FEATURE_DIR/request.md` - Original user request and assumptions
   - `$FEATURE_DIR/spec.md` - Current specification (already loaded in step 2a)
   - `$FEATURE_DIR/docs/references/` - External documentation summaries (if any)
     * Confluence pages, technical docs, API specs, design docs
     * Fetched during specify phase via WebFetch
     * Non-blocking if directory doesn't exist or is empty

   **3b. Architecture Documentation** (MANDATORY for existing codebases):
   - Search each directory in `$ARCHITECTURE_DIRS` (module → root order):
     - `system-analysis.md` - Architectural patterns, decisions, integration points
     - `technology-stack.md` - Languages, frameworks, libraries
     - `security-architecture.md` - Auth patterns, security requirements
     - `integration-landscape.md` - External service integrations (if exists)
   - `$FEATURE_DIR/docs/technical/architecture/feature-context.md` - Feature-specific architecture (if exists)

   **BLOCKING**: If codebase exists but architecture files missing → Stop and display: "❌ Architecture required. Run `/gbm.architecture` first."
   - BLOCK if architecture documentation is insufficient or stub files

   **3c. Governance & Principles (NON-NEGOTIABLE)**:
   - `$CONSTITUTION_PATH` (or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`) - Organizational rules, security requirements, architectural constraints
   - **CRITICAL**: Constitution defines non-negotiable principles that MUST be enforced
   - Constitutional constraints override user preferences and clarification answers
   - Any clarification that conflicts with constitution must be rejected

   **Usage**:
   - **Constitution First**: Constitutional principles are absolute - enforce unconditionally
   - Use architectural constraints to inform clarification priorities
   - Consider architectural boundaries and integration points when identifying gaps
   - Ensure clarifications align with established architectural patterns
   - Reject any clarification that violates constitutional principles

4. **Load and Analyze Current Specification**: Perform a structured ambiguity and coverage scan using this taxonomy, including architectural considerations. For each category, mark status: Clear / Partial / Missing / **Inferable**. Produce an internal coverage map used for prioritization (do not output raw map unless no questions will be asked).

   **INFERENCE PROCESS** (MANDATORY for Partial/Missing items):
   - **Constitutional Guidance** (NON-NEGOTIABLE): What non-negotiable constraints are defined in constitution.md? These MUST be enforced unconditionally.
   - **Request Analysis**: What can be inferred from the original request.md and user intent?
   - **External References**: What information is available in fetched external documentation (Confluence, tech docs, API specs)?
   - **Architecture Constraints**: What decisions are constrained by existing architecture patterns?
   - **Industry Standards**: What standard practices apply to this type of feature?
   - **Contextual Clues**: What can be inferred from related specification sections?
   - **Risk Assessment**: What are the consequences of making reasonable assumptions?

   Functional Scope & Behavior:
   - Core user goals & success criteria
   - Explicit out-of-scope declarations
   - User roles / personas differentiation

   Domain & Data Model:
   - Entities, attributes, relationships
   - Identity & uniqueness rules
   - Lifecycle/state transitions
   - Data volume / scale assumptions

   **Architectural Integration & Alignment** (HIGH PRIORITY):
   - How feature integrates with existing system components (from system-analysis.md)
   - Compliance with established architectural patterns (from technology-stack.md)
   - Impact on existing security architecture (from security-architecture.md)
   - Integration with current technology stack and frameworks
   - Alignment with scalability and performance patterns
   - External service integration requirements (from integration-landscape.md)
   - Consistency with feature architecture context (from feature-context.md)

   Interaction & UX Flow:
   - Critical user journeys / sequences
   - Error/empty/loading states
   - Accessibility or localization notes

   Non-Functional Quality Attributes:
   - Performance (latency, throughput targets)
   - Scalability (horizontal/vertical, limits)
   - Reliability & availability (uptime, recovery expectations)
   - Observability (logging, metrics, tracing signals)
   - Security & privacy (authN/Z, data protection, threat assumptions)
   - Compliance / regulatory constraints (if any)

   Integration & External Dependencies:
   - External services/APIs and failure modes
   - Data import/export formats
   - Protocol/versioning assumptions

   Edge Cases & Failure Handling:
   - Negative scenarios
   - Rate limiting / throttling
   - Conflict resolution (e.g., concurrent edits)

   Acceptance Criteria Clarity:
   - Vague or untestable acceptance criteria
   - Missing Given-When-Then structure in ACs
   - Ambiguous success/failure conditions
   - Incomplete AC coverage (missing Happy Path, Error Handling, or Edge Cases)

   Constraints & Tradeoffs:
   - Technical constraints (language, storage, hosting)
   - Explicit tradeoffs or rejected alternatives

   Terminology & Consistency:
   - Canonical glossary terms
   - Avoided synonyms / deprecated terms

   Completion Signals:
   - Acceptance criteria testability
   - Measurable Definition of Done style indicators

   Misc / Placeholders:
   - TODO markers / unresolved decisions
   - Ambiguous adjectives ("robust", "intuitive") lacking quantification

   For each category with Partial or Missing status, **FIRST attempt to infer reasonable answers** from available context:
   - **Request context**: Analyze request.md for implicit requirements and user intent
   - **Architecture context**: Use architectural patterns and constraints to infer technical decisions
   - **Constitutional principles**: Apply project governance and architectural constraints
   - **Domain knowledge**: Use standard industry practices and common patterns
   - **Specification context**: Infer from related sections and existing decisions

   **Only create a question opportunity if**:
   - Inference would create significant implementation risk or ambiguity
   - Multiple reasonable interpretations exist with materially different outcomes
   - The decision fundamentally changes the feature scope or architecture
   - Information is genuinely unknowable from available context

   **Do NOT create questions for**:
   - Information that can be reasonably inferred from context
   - Standard industry practices or common patterns
   - Details better suited for planning phase
   - Preferences that don't materially impact implementation

3. **Generate Minimal Clarification Questions** (10 ABSOLUTE MAXIMUM - FEWER IS BETTER):
   - **INFERENCE FIRST**: Before creating any question, attempt to infer the answer from:
     * Request.md content and user intent
     * Architecture documentation and established patterns
     * Constitutional principles and project constraints
     * Industry standards and common practices
     * Related specification sections and existing decisions

   - **Question Creation Criteria** (VERY RESTRICTIVE):
     * **ONLY ask if**: Inference would create significant risk or multiple materially different outcomes
     * **NEVER ask if**: Answer can be reasonably inferred from available context
     * **NEVER ask if**: Standard industry practice provides clear guidance
     * **NEVER ask if**: Constitutional principles or architecture docs provide constraints

   - **Question Format**: Each question must be answerable with EITHER:
     * Multiple-choice selection (2-5 distinct options), OR
     * Short answer (≤5 words)

   - **Prioritization Rules** (for questions that survive inference filtering):
     * **Highest Priority**: Architectural integration conflicts that can't be inferred
     * **High Priority**: Core functionality ambiguities with multiple valid interpretations
     * **Medium Priority**: Data modeling decisions with significant implementation impact
     * **Low Priority**: UX behavior that affects user experience materially

   - **Quality Criteria**:
     * Each question must have tried and failed inference first
     * Must materially impact implementation or validation strategy
     * Must have multiple reasonable interpretations with different outcomes
     * Must be genuinely unknowable from available context

   - **Stopping Criteria**:
     * **IDEAL**: Zero questions (all answers inferred successfully)
     * **GOOD**: 1-3 questions (only truly unknowable items)
     * **ACCEPTABLE**: 4-7 questions (complex feature with genuine ambiguities)
     * **MAXIMUM**: 10 questions (absolute limit - prefer inference over asking)

5. Sequential questioning loop (interactive):
    - Present EXACTLY ONE question at a time.
    - For multiple‑choice questions render options as a Markdown table:

       | Option | Description |
       |--------|-------------|
       | A | <Option A description> |
       | B | <Option B description> |
       | C | <Option C description> | (add D/E as needed up to 5)
       | Short | Provide a different short answer (<=5 words) | (Include only if free-form alternative is appropriate)

    - For short‑answer style (no meaningful discrete options), output a single line after the question: `Format: Short answer (<=5 words)`.
    - After the user answers:
       * Validate the answer maps to one option or fits the <=5 word constraint.
       * If ambiguous, ask for a quick disambiguation (count still belongs to same question; do not advance).
       * Once satisfactory, record it in working memory (do not yet write to disk) and move to the next queued question.
    - Stop asking further questions when:
       * All critical ambiguities resolved early (remaining queued items become unnecessary), OR
       * User signals completion ("done", "good", "no more"), OR
       * You reach 10 asked questions.
    - Never reveal future queued questions in advance.
    - If no valid questions exist at start, immediately report no critical ambiguities.

6. Integration after EACH accepted answer (incremental update approach):
    - Maintain in-memory representation of the spec (loaded once at start) plus the raw file contents.
    - For the first integrated answer in this session:
       * Ensure a `## Clarifications` section exists (create it just after the highest-level contextual/overview section per the spec template if missing).
       * Under it, create (if not present) a `### Clarification Session` subheading.
    - Append a bullet line immediately after acceptance: `- Q: <question> → A: <final answer>`.
    - Then immediately apply the clarification to the most appropriate section(s):
       * Functional ambiguity → Update or add a bullet in Functional Requirements.
       * User interaction / actor distinction → Update User Stories or Actors subsection (if present) with clarified role, constraint, or scenario.
       * Data shape / entities → Update Data Model (add fields, types, relationships) preserving ordering; note added constraints succinctly.
       * Non-functional constraint → Add/modify measurable criteria in Non-Functional / Quality Attributes section (convert vague adjective to metric or explicit target).
       * Edge case / negative flow → Add a new bullet under Edge Cases / Error Handling (or create such subsection if template provides placeholder for it).
       * Terminology conflict → Normalize term across spec; retain original only if necessary by adding `(formerly referred to as "X")` once.
    - If the clarification invalidates an earlier ambiguous statement, replace that statement instead of duplicating; leave no obsolete contradictory text.
    - Save the spec file AFTER each integration to minimize risk of context loss (atomic overwrite).
    - Preserve formatting: do not reorder unrelated sections; keep heading hierarchy intact.
    - Keep each inserted clarification minimal and testable (avoid narrative drift).

7. **Validation and Quality Assurance**:
   - Ensure each clarification is recorded exactly once in the Clarifications section
   - Verify updated sections resolve the ambiguities they were meant to address
   - Check that no contradictory statements remain in the specification
   - Maintain consistent terminology across all updated sections
   - Preserve Markdown structure and formatting

8. Write the updated spec back to `FEATURE_SPEC`.

9. Report completion (after questioning loop ends or early termination):
   - **Inference Summary**: Number of ambiguities resolved through context analysis (celebrate this!)
   - **Question Summary**: Number of questions asked & answered (fewer is better)
   - Path to updated spec.
   - Sections touched (list names).
   - **Coverage summary table** listing each taxonomy category with Status:
     * **Inferred** (was Partial/Missing, resolved through context analysis - BEST outcome)
     * **Resolved** (was Partial/Missing, addressed through questions)
     * **Clear** (already sufficient)
     * **Deferred** (exceeds question quota or better suited for planning)
     * **Outstanding** (still Partial/Missing but low impact)
   - **Inference Sources**: List key context sources used (request.md, architecture docs, constitutional principles, etc.)
   - If any Outstanding or Deferred remain, recommend whether to proceed to `/gbm.plan` or run `/gbm.clarify` again later post-plan.
   - Suggested next command.

**Behavior Rules**:
- **INFERENCE FIRST**: Always attempt to infer answers from available context before creating questions
- **Successful inference**: If all ambiguities resolved through inference, respond "All ambiguities resolved through context analysis - no questions needed" and suggest proceeding to `/gbm.plan`
- **Minimal questions**: Celebrate when fewer than 10 questions are needed - this indicates good inference work
- **Missing specification**: If specification file is missing, instruct user to run `/gbm.specify` first
- **Question limits**: 10 is the ABSOLUTE MAXIMUM - fewer is always better (clarification retries for a single question do not count as new questions)
- **User termination**: Respect user early termination signals ("stop", "done", "proceed")
- **Full coverage**: If no questions needed due to successful inference, output compact coverage summary highlighting inference successes and suggest advancing to `/gbm.plan`
- **Quota reached**: If approaching 10 questions, prioritize inference over additional questions - flag remaining items as "inferred based on [context source]" rather than asking

Context for prioritization: {ARGS}

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
10. Track command complete and trigger auto-upload:
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-clarify` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/post-command-hook.sh --command "gbm.clarify" --status "success|failure" --command-id "$command_id" --feature-dir "$SPEC_DIR" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - This handles both telemetry tracking AND automatic spec upload (if enabled in manifest)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

## Persona-Aware Next Steps

**Detecting Persona** (always do this):
1. Read: `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` → check `default_persona` field
2. Store the value in variable: `$CURRENT_PERSONA`
3. If file doesn't exist or field not set → `$CURRENT_PERSONA = null`

**All Personas - Next Step**:
- **Primary**: Run `/gbm.plan` to generate the implementation plan
- **Optional**: Run `/gbm.checklist` first to validate specification quality

**For extended guidance**: Read `$GBM_ROOT/.gobuildme/templates/reference/persona-next-steps.md` for detailed focus areas per persona.

## Optional: Spec Repository Upload

After updating `spec.md` with clarifications, you can optionally upload the spec directory:

→ `/gbm.upload-spec` - Upload specs to S3 for cross-project analysis and centralized storage

*Requires AWS credentials. Use `--dry-run` to validate access first.*

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Re-run `/gbm.clarify` with specific questions or areas to address
- Manually edit `$FEATURE_DIR/spec.md` to make adjustments
- Run `/gbm.specify` to rebuild specification from scratch

