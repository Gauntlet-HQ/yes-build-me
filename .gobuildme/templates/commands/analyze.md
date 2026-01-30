---
description: Perform a non-destructive cross-artifact consistency and quality analysis across spec.md, plan.md, and tasks.md after task generation.
artifacts:
  - path: ".gobuildme/analysis/<feature>/consistency-report.md"
    description: "Cross-artifact consistency analysis and quality validation report"
  - path: ".gobuildme/analysis/<feature>/analysis-details.md"
    description: "Full analysis details: complete cross-references, all findings, verbose checks (Tier 2 detail artifact)"
  - path: "$FEATURE_DIR/validation/slice-consistency-report.json"
    description: "Slice scope and constitution alignment validation results"
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## Output Style Requirements (MANDATORY)

**Analysis Report Output**:
- Status first: CONSISTENT / ISSUES FOUND / CRITICAL at top
- 3-5 bullets per category
- Tables for finding lists: artifact | issue | severity | location
- No restating artifact contents - reference by section

**Consistency Check Format**:
- Table: spec item | plan coverage | tasks coverage | status
- One-line description per inconsistency
- No explanations of why consistency matters

**Remediation Plan**:
- Numbered action items only
- One change per item with specific file and section
- No general advice - specific fixes only

**Two-Tier Output Enforcement (Issue #51)**:
- Do NOT paste full artifact contents, complete cross-reference tables, or verbose analysis to CLI
- Write full analysis to: `.gobuildme/analysis/<feature>/analysis-details.md`
- CLI shows: status verdict + top issues per category + "Full analysis: `<path>`"
- Max 5 issues shown inline; if more → "See `.gobuildme/analysis/<feature>/analysis-details.md` for N more"
- Consistency report (summary) stays concise; verbose cross-references go to detail artifact

For complete style guidance, see `$GBM_ROOT/.gobuildme/templates/_concise-style.md`


The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

---

## Step 0: Workspace-Aware Path Resolution (from script output)

The script `{SCRIPT}` outputs workspace-aware paths. Parse these from the JSON output:
- `WORKSPACE_ROOT` - Workspace/monorepo root (for constitution, personas)
- `GBM_ROOT` - Nearest `.gobuildme/` (for feature artifacts)
- `CONSTITUTION_PATH` - Path to constitution.md
- `ARCHITECTURE_DIRS` - Colon-separated list of architecture directories (module → root order)

Use these resolved paths for all file access in monorepo/workspace environments.

---

Persona Context (optional):
- If `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` exists and a `default_persona` is set with a matching `$WORKSPACE_ROOT/.gobuildme/personas/<id>.yaml`, evaluate persona coverage:
  * For this command: check `required_sections["/gbm.analyze"]` when present.
  * Cross‑artifact sweep: also verify persona `required_sections` for `/gbm.specify`, `/gbm.plan`, `/gbm.tests`, and `/gbm.review` are present in their respective files when available. Report Missing/Partial/Complete. Do not fail CI; warn‑first.
  * If `$GBM_ROOT/.gobuildme/templates/personas/partials/<id>/analyze.md` exists, include its content under a `### Persona-Specific Analysis Checks` section in the report.

Persona Lint (advisory):
- Run `$GBM_ROOT/.gobuildme/scripts/bash/persona-lint.sh --json` (or PowerShell twin) from repo root to gather an advisory JSON of persona section coverage across `request.md`, `spec.md`, and `plan.md`.
- Parse and include its findings in the report. If the script is missing or returns no persona, proceed with the analysis you computed above.
- **Error Tracking**: If the script fails (non-zero exit code), capture the error details (script path, exit code, error message) for inclusion in the telemetry `error` field. The command should continue execution (non-blocking failure).

Goal: Identify inconsistencies, duplications, ambiguities, and underspecified items across the core artifacts (`spec.md`, `plan.md`, `tasks.md`) before implementation. When `$FEATURE_DIR/prd.md` exists, report alignment between PRD Goals/Non‑Goals/Success Metrics and the spec’s requirements/ACs (warn-first). This command MUST run only after `/gbm.tasks` has successfully produced a complete `tasks.md`.

STRICTLY READ-ONLY: Do **not** modify any files. Output a structured analysis report. Offer an optional remediation plan (user must explicitly approve before any follow-up editing commands would be invoked manually).

Constitution Authority: The project constitution (`$CONSTITUTION_PATH` or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`) is **non-negotiable** within this analysis scope. Constitution conflicts are automatically CRITICAL and require adjustment of the spec, plan, or tasks—not dilution, reinterpretation, or silent ignoring of the principle. If a principle itself needs to change, that must occur in a separate, explicit constitution update outside `/gbm.analyze`.

Execution steps:

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.analyze" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. Run `{SCRIPT}` once from repo root and parse JSON for FEATURE_DIR and AVAILABLE_DOCS. Derive absolute paths:
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").
   - SPEC = FEATURE_DIR/spec.md
   - PLAN = FEATURE_DIR/plan.md
   - TASKS = FEATURE_DIR/tasks.md
   Abort with an error message if any required file is missing (instruct the user to run missing prerequisite command).

3. **Load All Available Context** (for consistency analysis):

   **3a. Feature-Specific Artifacts** (REQUIRED for analysis):
   - `$FEATURE_DIR/spec.md` - Feature specification to analyze
     * Parse: Overview/Context, Functional Requirements, Non-Functional Requirements
     * Parse: User Stories, Edge Cases, **Acceptance Criteria** (all categories)
   - `$FEATURE_DIR/plan.md` - Implementation plan to analyze
     * Parse: Architecture/stack choices, Data Model references
     * Parse: Phases, Technical constraints, Technology decisions
   - `$FEATURE_DIR/tasks.md` - Task breakdown to analyze
     * Parse: Task IDs, descriptions, phase grouping
     * Parse: Parallel markers [P], referenced file paths
   - `$FEATURE_DIR/request.md` - Original request (optional, for context)
   - `$FEATURE_DIR/docs/references/` - External documentation summaries (optional, if exists)
     * Confluence pages, technical docs, API specs, design docs
     * Fetched during specify phase via WebFetch
     * Use to validate external documentation was properly incorporated into spec/plan/tasks
   - `$FEATURE_DIR/prd.md` - Product requirements (optional, if exists)
     * When exists: Report alignment between PRD Goals/Non-Goals/Success Metrics and spec requirements/ACs

   **3b. Architecture Documentation** (optional, for validation):
   - Search each directory in `$ARCHITECTURE_DIRS` (module → root order):
     - `system-analysis.md` - Architectural patterns and boundaries (if exists)
     - `technology-stack.md` - Approved technologies (if exists)
     - `security-architecture.md` - Security requirements (if exists)
   - Use for architectural boundary validation if available

   **3c. Governance & Principles** (NON-NEGOTIABLE):
   - `$CONSTITUTION_PATH` (or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`) - Organizational rules, security requirements, architectural constraints
   - **CRITICAL**: Constitution defines non-negotiable principles for validation
   - Constitution conflicts are automatically CRITICAL severity
   - Any spec/plan/task that conflicts with constitution MUST be flagged for adjustment

4. Build internal semantic models:
   - Requirements inventory: Each functional + non-functional requirement with a stable key (derive slug based on imperative phrase; e.g., "User can upload file" -> `user-can-upload-file`).
   - User story/action inventory.
   - Task coverage mapping: Map each task to one or more requirements or stories (inference by keyword / explicit reference patterns like IDs or key phrases).
   - Constitution rule set: Extract principle names and any MUST/SHOULD normative statements.

5. Detection passes:
   A. Duplication detection:
      - Identify near-duplicate requirements. Mark lower-quality phrasing for consolidation.
   B. Ambiguity detection:
      - Flag vague adjectives (fast, scalable, secure, intuitive, robust) lacking measurable criteria.
      - Flag unresolved placeholders (TODO, TKTK, ???, <placeholder>, etc.).
   C. Underspecification:
      - Requirements with verbs but missing object or measurable outcome.
      - User stories missing acceptance criteria alignment.
      - Tasks referencing files or components not defined in spec/plan.
   D. Constitution alignment:
      - Any requirement or plan element conflicting with a MUST principle.
      - Missing mandated sections or quality gates from constitution.
   E. Architecture boundary validation:
      - Tasks that violate architectural layering constraints (e.g., services→api imports)
      - Requirements that cross forbidden coupling boundaries
      - Technology choices not aligned with approved frameworks/libraries
      - Data model changes without proper migration considerations
      - Integration patterns that violate service boundaries
   F. Acceptance Criteria validation:
      - Functional requirements missing corresponding acceptance criteria.
      - Acceptance criteria not following Given-When-Then format.
      - Vague or untestable acceptance criteria (no clear pass/fail conditions).
      - Missing AC categories (Happy Path, Error Handling, Edge Cases where relevant).
      - AC IDs not following naming convention (AC-001, AC-E01, AC-B01, etc.).
      - Duplicate or conflicting acceptance criteria.
   G. Coverage gaps:
      - Requirements with zero associated tasks.
      - Tasks with no mapped requirement/story.
      - Non-functional requirements not reflected in tasks (e.g., performance, security).
      - Acceptance criteria with no corresponding test coverage plan.
   H. Inconsistency:
      - Terminology drift (same concept named differently across files).
      - Data entities referenced in plan but absent in spec (or vice versa).
      - Task ordering contradictions (e.g., integration tasks before foundational setup tasks without dependency note).
      - Conflicting requirements (e.g., one requires to use Next.js while other says to use Vue as the framework).
      - Acceptance criteria contradicting functional requirements.

   I. DevSpace alignment (optional, read-only):
      - If a `devspace.yaml` exists in the target project and DevSpace CLI is available, run `.gobuildme/scripts/bash/devspace-sanity.sh --json`.
      - If executing from a CLI/templates repo, pass `--repo <target-root>` or set `GOBUILDME_TARGET_REPO=/abs/path` so checks run against the target project.
      - When configuration is parseable, compare spec/plan runtime details (service names, ports) with `devspace print config` output and flag mismatches (names case/space differences, duplicate/occupied ports, missing run tasks).
      - This step must not mutate any files; report findings only.
      - **Error Tracking**: If the script fails (exit code != 0):
        * Capture error: `script_errors.append({"script": "devspace-sanity.sh", "exit_code": <code>, "error": "<stderr output>"})`
        * Continue with analysis (DevSpace alignment is optional)

   J. Slice scope consistency (for epic slices):
      - Run `.gobuildme/scripts/bash/validate-slice-consistency.sh --json`
      - Validates three layers:
        * **Scope validation**: Changed files match scope.json allowed_files/patterns
        * **Constitution traceability**: spec.md/plan.md have Constitution Alignment section referencing principles
        * **Cross-slice overlap**: No scope conflicts with other slices in same epic
      - Report validation results per category (scope_check, constitution_check, cross_slice_check)
      - If `scope_precision: coarse` → INFO: "Scope not yet refined, run /gbm.plan" (no file-level validation)
      - If `scope_precision: refined` → Validate all changed files against declared scope
      - **Error Tracking**: If script fails (exit code != 0):
        * Capture error: `script_errors.append({"script": "validate-slice-consistency.sh", "exit_code": <code>, "error": "<stderr output>"})`
        * Continue with analysis (scope validation is advisory in analyze)
      - Severity mapping:
        * Scope violations → MEDIUM (advisory during analysis)
        * Missing Constitution Alignment section → MEDIUM
        * Cross-slice overlaps → HIGH (may indicate planning issue)

6. Severity assignment heuristic:
   - CRITICAL: Violates constitution MUST, missing core spec artifact, requirement with zero coverage that blocks baseline functionality, architectural boundary violations, or functional requirements missing acceptance criteria.
   - HIGH: Duplicate or conflicting requirement, ambiguous security/performance attribute, untestable acceptance criterion, malformed AC format, or tasks that violate architectural layering.
   - MEDIUM: Terminology drift, missing non-functional task coverage, underspecified edge case, minor architectural inconsistencies, or missing AC categories.
   - LOW: Style/wording improvements, minor redundancy not affecting execution order, or AC naming convention issues.

7. Produce a Markdown report (no file writes) with sections:

   ### Specification Analysis Report
   | ID | Category | Severity | Location(s) | Summary | Recommendation |
   |----|----------|----------|-------------|---------|----------------|
   | A1 | Duplication | HIGH | spec.md:L120-134 | Two similar requirements ... | Merge phrasing; keep clearer version |
   (Add one row per finding; generate stable IDs prefixed by category initial.)

   Additional subsections:
   - Coverage Summary Table:
     | Requirement Key | Has Task? | Task IDs | Notes |
   - Constitution Alignment Issues (if any)
   - Unmapped Tasks (if any)
   - Metrics:
     * Total Requirements
     * Total Tasks
     * Coverage % (requirements with >=1 task)
     * Ambiguity Count
     * Duplication Count
     * Critical Issues Count

8. At end of report, output a concise Next Actions block:
   - If CRITICAL issues exist: Recommend resolving before `/gbm.implement`.
   - If only LOW/MEDIUM: User may proceed, but provide improvement suggestions.
   - Provide explicit command suggestions: e.g., "Run /gbm.specify with refinement", "Run /gbm.plan to adjust architecture", "Manually edit tasks.md to add coverage for 'performance-metrics'".

9. Ask the user: "Would you like me to suggest concrete remediation edits for the top N issues?" (Do NOT apply them automatically.)

Behavior rules:
- NEVER modify files.
- NEVER hallucinate missing sections—if absent, report them.
- KEEP findings deterministic: if rerun without changes, produce consistent IDs and counts.
- LIMIT total findings in the main table to 50; aggregate remainder in a summarized overflow note.
- If zero issues found, emit a success report with coverage statistics and proceed recommendation.

Context: {ARGS}

10. **Analysis Task Completion Advisory** (READ-ONLY):
   - Load tasks.md from FEATURE_DIR to identify Phase 1 (Analysis) tasks
   - Find all Analysis tasks (tasks starting with A1, A2, A3, etc.)
   - Report status: "✅ Analysis complete. Recommend marking X Analysis tasks as [x] in tasks.md"

   **Analysis tasks completed by this command**:
   - A1: Fact-check requirements documentation
   - A2: Validate architecture compliance
   - A3: Verify design completeness

   **Advisory Note**: The /gbm.analyze command performs all fact-checking and validation,
   but does NOT modify tasks.md. This is strictly a read-only analysis.

   **User Action Required** (after reviewing the analysis report):
   - Option A: User can manually edit `$FEATURE_DIR/tasks.md` to mark A1/A2/A3 as `[x]`
   - Option B: Run `/gbm.implement` which will mark them as part of the workflow

   **IMPORTANT**: This command is READ-ONLY. The AI agent must NOT modify tasks.md.
   Task marking is user responsibility to maintain non-destructive analysis.

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
11. Track command complete:
    - Prepare results JSON per schema `$GBM_ROOT/.gobuildme/docs/technical/telemetry-schemas.md#gbm-analyze` (include error details if command failed)
    - Run `$GBM_ROOT/.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

## Persona-Aware Next Steps

**Detecting Persona** (always do this):
1. Read: `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` → check `default_persona` field
2. Store the value in variable: `$CURRENT_PERSONA`
3. If file doesn't exist or field not set → `$CURRENT_PERSONA = null`

**Analysis Quality Gates** (check first):
- ✅ No CRITICAL consistency issues found
- ✅ All spec items covered in plan and tasks
- ✅ Constitution compliance validated

**Next Command**: `/gbm.implement` (all personas except qa_engineer)

**Exception**:
- **qa_engineer** → `/gbm.qa.implement` (Test infrastructure and fixtures)

**Focus varies by persona** - See `$GBM_ROOT/.gobuildme/templates/reference/persona-next-steps.md` for detailed guidance per role.

### If $CURRENT_PERSONA = null (no persona set)
**Suggested Action**: Run `/gbm.persona` first to set your role and get personalized guidance

**Generic Next Step**: `/gbm.implement` to begin implementation

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Address CRITICAL issues identified in analysis report first
- Manually edit artifacts based on specific findings (spec.md, plan.md, tasks.md)
- Re-run `/gbm.specify` or `/gbm.plan` if foundational changes needed
- Run `/gbm.clarify` if specification ambiguities remain


