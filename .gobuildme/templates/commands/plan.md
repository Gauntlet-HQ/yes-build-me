---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/setup-plan.ps1 -Json
artifacts:
  - path: "$FEATURE_DIR/plan.md"
    description: "Implementation plan with technology stack, architecture decisions, and task breakdown approach. Metadata is automatically recorded for audit trail (created timestamp, author, artifact path)."
  - path: "$FEATURE_DIR/research.md"
    description: "Technical research, decisions, constraints, and trade-offs (Phase 0)"
  - path: "$FEATURE_DIR/data-model.md"
    description: "Entity definitions, relationships, and data model design (Phase 1)"
  - path: "$FEATURE_DIR/contracts/"
    description: "API endpoint specifications and contract definitions (Phase 1)"
  - path: "$FEATURE_DIR/quickstart.md"
    description: "Integration scenarios and example usage patterns (Phase 1)"
  - path: "$FEATURE_DIR/scope.json"
    description: "Refined scope definition with allowed_files, allowed_patterns, and scope_precision for enforcement"
---

## Output Style Requirements (MANDATORY)

**Plan Output**:
- 3-5 bullets per section (more only for complete tech stack listings)
- Tables for technology comparisons, architecture decisions, and trade-offs
- One-sentence rationale per decision - no multi-paragraph justifications
- Action-first language in task descriptions

**Research Output** (research.md):
- Pros/cons as bullet tables, not prose
- Decision summary: 1-2 sentences per choice
- Constraints: table format (constraint | impact | mitigation)

**Data Model Output** (data-model.md):
- Entity attributes as tables, not prose
- Relationships as mermaid diagrams where helpful
- One paragraph max per entity description

**Contract Output** (contracts/):
- Request/response examples: minimal viable JSON
- Error cases: table format (status | description | example)
- No redundant schema descriptions when code is self-documenting

**Quickstart Output** (quickstart.md):
- Code examples: minimal working snippets
- Max 2-3 examples per integration scenario
- No step-by-step prose when code is clear

For complete style guidance, see .gobuildme/templates/_concise-style.md

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

Given the implementation details provided as an argument, do this:

**Script Output Variables**: The `{SCRIPT}` output above provides key paths. Parse and use these values:
- `FEATURE_DIR` - Feature directory path (e.g., `.gobuildme/specs/<feature>/` or `.gobuildme/specs/epics/<epic>/<slice>/`)
- `FEATURE_SPEC` - Path to spec.md
- `IMPL_PLAN` - Path to plan.md

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.plan" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
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

   **Merge required sections for /plan**:
   - For each persona in active_personas:
     * Read `.gobuildme/personas/<persona_id>.yaml`
     * Extract `required_sections["/plan"]` (may not exist for all personas)
     * Collect all sections into merged list
   - Ensure ALL merged sections are incorporated into plan.md
   - Example merged sections:
     * Backend Engineer: ["API Contracts", "Data Model & Migrations", "Error Model", "Observability"]
     * Security: ["Threat Model", "Secrets/Keys", "Data Classification", "Access Controls", "Supply Chain"]
     * SRE: ["CI/CD Pipeline", "Environments", "Observability", "Capacity & SLOs", "Rollout/Rollback"]
     * Result: All sections required (note "Observability" from both backend + SRE)

   **Include persona partials**:
   - For each persona in active_personas:
     * If `templates/personas/partials/<persona_id>/plan.md` exists:
       - Include its content under a `### <Persona Name> Considerations` section
   - If no persona files exist, proceed as generalist

   **Error Handling**:
   - If participant persona file missing: Skip with warning, continue with remaining personas
   - If driver persona file missing: Fall back to default_persona
   - If no valid personas found: Proceed as generalist (no persona enforcement)

   **Validation**:
   - Report which personas are active (driver + participants)
   - Show merged required sections grouped by persona
   - Validate final plan contains all merged sections

3. Run `{SCRIPT}` from the repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, FEATURE_DIR, BRANCH. All future file paths must be absolute.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

3a. **Prerequisite Validation** (MANDATORY - BLOCKING):

   **CRITICAL**: You MUST verify that feature specification and clarifications are complete before proceeding with implementation planning.

   **Check Specification File Exists**:
   - Verify `FEATURE_SPEC` path from JSON output is not empty
   - Attempt to read the specification file at the path
   - If file does not exist or is empty:
     * **BLOCK execution**: Do not proceed with planning
     * **Error message**: "❌ Prerequisite missing: Feature specification not found"
     * **Required action**: "Run `/gbm.specify` to create the feature specification first"
     * **Exit**: Stop processing and wait for user to run `/gbm.specify`

   **Check Clarifications Completed** (RECOMMENDED):
   - Inspect FEATURE_SPEC for a `## Clarifications` section with at least one `Session` subheading
   - Look for resolved clarifications, answered questions, or inferred decisions
   - If `## Clarifications` section is missing or clearly ambiguous areas remain:
     * **WARNING**: "⚠️ Clarifications missing or incomplete. Running `/gbm.clarify` first will reduce rework risk."
     * **User Decision Required**:
       - Option A (RECOMMENDED): "PAUSE and run `/gbm.clarify` to reduce ambiguity"
       - Option B: "Proceed with planning (user explicitly overrides with 'proceed without clarification')"
     * **If user chooses Option A**: BLOCK and wait for `/gbm.clarify` completion
     * **If user chooses Option B or overrides**: Continue but note that rework risk increases
   - Do not attempt to fabricate clarifications yourself

   **Validate Specification Quality**:
   - Check for vague adjectives ("fast", "reliable", "scalable") without quantification
   - Check for unresolved critical choices (multiple options listed without decision)
   - Check for incomplete acceptance criteria (missing edge cases or error scenarios)
   - If significant quality issues found:
     * **WARNING**: "⚠️ Specification quality issues detected. Consider running `/gbm.clarify` to resolve:"
     * List specific issues found
     * Recommend clarification before proceeding

   **Success Path**:
   - If specification exists and clarifications are complete → Proceed to Load all available context

4. **Load All Available Context** (for implementation planning):

   **4a. Feature-Specific Artifacts** (from request/specify/clarify phases):
   - `$FEATURE_DIR/request.md` - Original user request, assumptions, and initial requirements
   - `$FEATURE_DIR/spec.md` - Complete feature specification (already validated in step 3a)
     * Functional and non-functional requirements
     * User stories and acceptance criteria
     * Success criteria and edge cases
     * Clarifications from clarify phase (if completed)
   - `$FEATURE_DIR/docs/references/` - External documentation summaries (if any)
     * Confluence pages, technical docs, API specs, design docs
     * Fetched during specify phase via WebFetch
     * Non-blocking if directory doesn't exist or is empty

   **4b. Architecture Documentation** (MANDATORY for existing codebases):

   **Root Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_architecture_dirs()` to get ordered list of architecture directories
   - Search order: module-level first → workspace/monorepo root second
   - Example: In monorepo module, checks `apps/api/.gobuildme/docs/technical/architecture/` then `<root>/.gobuildme/docs/technical/architecture/`

   **Architecture files to load** (from each discovered architecture directory):
   - `system-analysis.md` - Architectural patterns, decisions, integration points
   - `technology-stack.md` - Languages, frameworks, libraries, and approved technologies
   - `security-architecture.md` - Auth patterns, security requirements, compliance constraints
   - `integration-landscape.md` - External service integrations (if exists)
   - `$FEATURE_DIR/docs/technical/architecture/feature-context.md` - Feature-specific architectural context (if exists)

   **BLOCKING**: If codebase exists but no architecture files found in any searched directory → Stop and display: "❌ Architecture required. Run `/gbm.architecture` first."

   **4c. Governance & Principles** (NON-NEGOTIABLE):

   **Constitution Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_constitution_path()` to get constitution location
   - Constitution is ALWAYS at workspace/monorepo root (not per-module)
   - Single repo: `<repo>/.gobuildme/memory/constitution.md`
   - Monorepo/Workspace: `<root>/.gobuildme/memory/constitution.md`

   - Constitution file contains organizational rules, security requirements, architectural constraints
   - **CRITICAL**: Constitution defines non-negotiable principles that MUST be enforced
   - Constitutional constraints override user preferences and planning decisions
   - Any plan that conflicts with constitution must be rejected or revised

   **Usage**:
   - **Constitution First**: Constitutional principles are absolute - enforce unconditionally
   - Use architectural constraints to guide technology choices and design decisions
   - Consider architectural boundaries and integration patterns when planning implementation
   - Ensure plan aligns with established architectural patterns and approved technologies
   - Incorporate external references to inform technical decisions and design choices
   - Reject any planning decision that violates constitutional principles

5. **Plan Generation with Metadata Frontmatter** (MANDATORY):
   - When creating plan.md, ADD this YAML frontmatter structure at the top:

   ```markdown
   ---
   description: "[One-line summary of technical approach/implementation plan]"
   metadata:
     feature_name: "[BRANCH_NAME from specification, without special chars]"
     artifact_type: plan
     created_timestamp: "[GENERATE: Current date/time in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ]"
     created_by_git_user: "[Run: git config user.name - extract the result here]"
     input_summary:
       - "[Key architectural decision 1]"
       - "[Key technical approach 1]"
       - "[Technology choice 1]"
       - "[Continue with 5-10 total key decisions/approaches]"
   ---

	   # [Feature Name] Technical Plan

	   [Rest of plan content...]
	   ```

   **PR Slice Sections (MANDATORY — PR-Friendly Incremental Delivery)**:
   - Ensure `plan.md` includes an explicit slice-scoped section near the top:
     * `## Epic & PR Slice Context (Incremental Delivery)`
     * Include: Epic Link/Name (optional), PR Slice (`standalone` or `N/M`), and “This PR Delivers”
   - Add: `## Deferred to Future PRs (Out of Scope)`:
     * List PR-2/PR-3 scope (high level) and dependencies
     * **Rule**: Do NOT plan implementation details for deferred work in this slice’s plan/tasks
   - If the spec/request indicates multiple PR slices, this plan MUST describe PR-1 only (slice-scoped).

   **Metadata Field Details:**
   - `feature_name`: Extract from BRANCH_NAME (must match request.md and specify.md)
   - `created_timestamp`: Generate current timestamp in ISO 8601 format with Z suffix
   - `created_by_git_user`: Get from `git config user.name` - use the git username
   - `input_summary`: **CRITICAL - Extract 5-10 key points ONLY from the USER INPUT (not from plan content):**
     * Review the user input provided when `/gbm.plan` was invoked (or load from spec.md/request.md)
     * Extract the main planning constraints/directions the user specified
     * Example: If user said "use FastAPI for backend" → extract "Use FastAPI for backend implementation"
     * Example: If user specified "vanilla JavaScript only" → extract "Vanilla JavaScript frontend (no frameworks)"
     * **IF user provided NO input to plan**: Set `input_summary: []` (empty array) or reference spec.md input_summary
     * DO NOT extract from the plan sections you wrote - those are generated content
     * Extract ONLY what the user explicitly asked for in their plan request
     * Match user input, not architectural content or design decisions you created

6. Generate or load the Codebase Profile before Phase 0:
   - Run `scripts/bash/analyze-architecture.sh` from repo root.
   - Record the `$FEATURE_DIR/docs/technical/architecture/data-collection.md` file path and reference it in the plan's Architecture Alignment Check.

7. Validate architecture boundaries prior to design commitments:
   - Run `scripts/bash/validate-architecture.sh`.
   - If validation fails, either (a) revise the approach to comply, or (b) document justification + mitigation in "Complexity Tracking" and stop if risks are unacceptable.

8. DevSpace context (optional, non-destructive):
   - If the target project contains `devspace.yaml|yml` and the DevSpace CLI is installed, run `.gobuildme/scripts/bash/devspace-sanity.sh --json`.
   - If you are executing from a CLI/templates repo (not the target project root), provide the target path via `--repo <path>` or `GOBUILDME_TARGET_REPO=/abs/path`.
   - If `has_cli=true` and `has_config=true`, also run `devspace print config` and list:
     * available profiles
     * services/components and exposed ports
     * sync paths of interest
   - Record any detected runtime details in the plan's Research/Quickstart sections for awareness. Do not modify `devspace.yaml`.

9. Execute the implementation plan template:
   - Load `templates/plan-template.md` (already copied to IMPL_PLAN path)
   - Set Input path to FEATURE_SPEC
   - Run the Execution Flow (main) function steps 1-9
   - The template is self-contained and executable
   - Follow error handling and gate checks as specified, including the Architecture Alignment Check
   - Let the template guide artifact generation in $FEATURE_DIR:
     * Phase 0 generates research.md
     * Phase 1 generates data-model.md, contracts/, quickstart.md
     * Phase 2 DESCRIBES the task generation approach; tasks.md is created by `/gbm.tasks`
   - Incorporate user-provided details from arguments into Technical Context: {ARGS}
   - Update Progress Tracking as you complete each phase
   - **CRITICAL**: All checklist items in plan.md start as `[ ]` - mark as `[x]` ONLY when actually completed

9a. **Scope Refinement** (MANDATORY for epic slices, recommended for all features):

   **Purpose**: Refine scope from coarse (scope_summary) to file-level (allowed_files/allowed_patterns) based on the implementation plan. This enables scope enforcement during implementation.

   **Step 1: Extract planned files from plan.md**:
   - Scan the generated plan.md for file paths mentioned in:
     * "Files to Create/Modify" sections
     * Data model definitions (e.g., `src/models/user.py`)
     * API contract definitions (e.g., `src/api/endpoints/auth.py`)
     * Test file references (e.g., `tests/test_auth.py`)
   - Group extracted paths into:
     * `allowed_files`: Exact file paths explicitly mentioned
     * `allowed_patterns`: Directories that will contain multiple related files (e.g., `src/auth/**/*.py`)

   **Step 2: Check if this is an epic slice**:
   - Read `$FEATURE_DIR/request.md` frontmatter for `epic_slug` and `slice_name`
   - If present: This is an epic slice → load registry for mode/module_path/repo_path
   - If absent: This is a standalone feature → use local mode

   **Step 3: Load registry metadata** (for epic slices only):
   - **Locate registry** (search both locations for cross-repo support):
     * First: `$GBM_ROOT/.gobuildme/specs/epics/<epic_slug>/slice-registry.yaml`
     * If not found and `$WORKSPACE_ROOT != $GBM_ROOT`: also check `$WORKSPACE_ROOT/.gobuildme/specs/epics/<epic_slug>/slice-registry.yaml`
     * Set `$REGISTRY_ROOT` to whichever location has the registry
   - Read registry at `$REGISTRY_ROOT/.gobuildme/specs/epics/<epic_slug>/slice-registry.yaml`
   - Extract: `mode`, current slice's `module_path` or `repo_path`
   - These determine path format for scope.json

   **Step 4: Generate scope.json**:
   - Create/update `$FEATURE_DIR/scope.json` with the following structure:

   ```json
   {
     "feature": "<branch_name or epic--slice>",
     "created_at": "<ISO 8601 timestamp>",
     "updated_at": "<ISO 8601 timestamp>",

     "allowed_files": [
       "src/auth/handler.py",
       "src/models/user.py",
       "tests/test_auth.py"
     ],
     "allowed_patterns": [
       "src/auth/**/*.py",
       "tests/auth/**/*.py"
     ],
     "excludes": [
       "**/*.lock",
       "**/.env*",
       "**/secrets/**"
     ],
     "touched_files": [],

     "scope_source": "plan",
     "scope_precision": "refined",

     "slice_name": "<slice_name or null>",
     "epic_slug": "<epic_slug or null>",
     "registry_mode": "<local|cross_module|cross_repo>",
     "module_path": "<module path or null>",
     "repo_path": "<repo path or null>",

     "violations": [],
     "last_validated": null
   }
   ```

   **Path Format Rules** (based on registry_mode):
   - `local`: Repo-relative paths (e.g., `src/auth/handler.py`)
   - `cross_module`: Module-relative paths (e.g., `src/handler.py` within `apps/api-service`)
   - `cross_repo`: Workspace-relative paths (e.g., `api-repo/src/handler.py`)

   **Step 5: Populate excludes** (standard exclusions):
   - Always include:
     * `**/*.lock` (lock files)
     * `**/.env*` (environment files)
     * `**/secrets/**` (secrets directories)
   - Add any slice-specific exclusions from spec.md "Non-Goals" section

   **Step 6: Display scope summary**:
   ```
   📋 **Scope Refined**

   | Field | Value |
   |-------|-------|
   | Scope Source | plan |
   | Scope Precision | refined |
   | Allowed Files | <count> files |
   | Allowed Patterns | <count> patterns |
   | Excludes | <count> patterns |

   Scope file: $FEATURE_DIR/scope.json
   ```

   **Step 7: Cross-slice overlap check** (for epic slices only):
   - If this is an epic slice (epic_slug is set):
     * Read scope.json from other slices in the same epic
     * Only compare slices where `scope_precision == "refined"`
     * Check for exact file matches in `allowed_files`
     * Check for pattern overlap (best-effort string equality)
   - If overlap detected:
     ```
     ⚠️ **Potential Scope Overlap Detected**

     This slice's scope may overlap with:
     | Slice | Overlapping Files/Patterns |
     |-------|---------------------------|
     | <slice_name> | <overlapping items> |

     Review and adjust scope if this overlap is unintentional.
     ```

   **Step 8: Update constitution_refs in slice registry** (for epic slices only):
   - If `epic_slug` is set:
     * Parse the **Constitution Alignment** section in the generated `plan.md`
     * Extract principle IDs (the bold IDs in `- **principle-id**:` lines)
     * Filter out entries starting with "N/A " (not applicable principles)
     * Update the current slice in the registry at `$REGISTRY_ROOT` (determined in Step 3):
       - Set `constitution_refs` to the extracted list
     * If no principles listed: set `constitution_refs: []`

   **Implementation** (bash with yq/Python fallback):
   ```bash
   # Extract epic_slug and slice_name from request.md frontmatter (under metadata:)
   # Note: Fields are indented and may be quoted, so use Python for reliable YAML parsing
   read -r EPIC_SLUG SLICE_NAME < <(python3 -c "
import yaml, sys
try:
    with open('$FEATURE_DIR/request.md') as f:
        content = f.read()
    # Extract YAML frontmatter between --- markers
    if content.startswith('---'):
        end = content.find('---', 3)
        if end > 0:
            fm = yaml.safe_load(content[3:end])
            meta = fm.get('metadata', {}) if fm else {}
            print(meta.get('epic_slug', ''), meta.get('slice_name', ''))
            sys.exit(0)
    print('', '')
except Exception:
    print('', '')
" 2>/dev/null)

   if [[ -n "$EPIC_SLUG" && -n "$SLICE_NAME" ]]; then
     # Search both locations for cross-repo support
     REGISTRY="$GBM_ROOT/.gobuildme/specs/epics/$EPIC_SLUG/slice-registry.yaml"
     if [[ ! -f "$REGISTRY" && "$WORKSPACE_ROOT" != "$GBM_ROOT" ]]; then
       REGISTRY="$WORKSPACE_ROOT/.gobuildme/specs/epics/$EPIC_SLUG/slice-registry.yaml"
     fi
     if [[ -f "$REGISTRY" ]]; then
       # Extract principle IDs from the Constitution Alignment section in plan.md
       REFS=$(awk '/^## Constitution Alignment/{flag=1;next}/^## /{flag=0}flag' "$FEATURE_DIR/plan.md" \
         | grep -oP '^- \*\*\K[^*]+(?=\*\*)' \
         | grep -v '^N/A ' \
         | tr -d '\r' \
         | sort -u)

       # Convert to JSON array
       REFS_JSON=$(printf '%s\n' "$REFS" | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))')

       if command -v yq >/dev/null 2>&1; then
         SLICE_NAME="$SLICE_NAME" REFS_JSON="$REFS_JSON" \
           yq -i '.slices[] |= (select(.slice_name == env(SLICE_NAME)) | .constitution_refs = (env(REFS_JSON) | fromjson))' \
           "$REGISTRY"
       else
         REGISTRY="$REGISTRY" SLICE_NAME="$SLICE_NAME" REFS_JSON="$REFS_JSON" python3 - <<'PY'
   import json, os, yaml
   reg = os.environ["REGISTRY"]
   slice_name = os.environ["SLICE_NAME"]
   refs = json.loads(os.environ["REFS_JSON"])
   with open(reg) as f:
       data = yaml.safe_load(f)
   for s in data.get("slices", []):
       if s.get("slice_name") == slice_name:
           s["constitution_refs"] = refs
           break
   with open(reg, "w") as f:
       yaml.safe_dump(data, f, sort_keys=False)
   PY
       fi

       echo "✅ Updated constitution_refs for slice '$SLICE_NAME' in $REGISTRY"
     else
       echo "⚠️ Registry not found at $REGISTRY; skipping constitution_refs update."
     fi
   fi
   ```

10. Verify execution completed:
   - Check Progress Tracking shows all phases complete
   - Ensure all required artifacts were generated
   - Confirm no ERROR states in execution
   - Verify scope.json was created with `scope_precision: refined`

11. Report results with branch name, file paths, and generated artifacts.

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
12. Track command complete and trigger auto-upload:
   - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-plan` (include error details if command failed)
   - Run `.gobuildme/scripts/bash/post-command-hook.sh --command "gbm.plan" --status "success|failure" --command-id "$command_id" --feature-dir "$SPEC_DIR" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
   - This handles both telemetry tracking AND automatic spec upload (if enabled in manifest)
   - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

## Persona-Aware Next Steps

**Detecting Persona** (always do this):
1. Read: `.gobuildme/config/personas.yaml` → check `default_persona` field
2. Store the value in variable: `$CURRENT_PERSONA`
3. If file doesn't exist or field not set → `$CURRENT_PERSONA = null`

**All Personas - Recommended First Step**:
- **Validate Plan Quality**: Run `/gbm.checklist` to validate technical decisions, completeness, and consistency

**Persona-Specific Next Steps** (display based on $CURRENT_PERSONA):

| Persona | Next Command | Then | Task Focus |
|---------|--------------|------|------------|
| backend_engineer | /gbm.tasks | /gbm.analyze | APIs, DB ops, migrations, TDD |
| frontend_engineer | /gbm.tasks | /gbm.analyze | Components, a11y, responsive, perf |
| fullstack_engineer | /gbm.tasks | /gbm.analyze | API+UI, integration points |
| qa_engineer | /gbm.qa.tasks | /gbm.qa.generate-fixtures | Tests by type (unit/int/E2E) |
| data_engineer | /gbm.tasks | /gbm.analyze | Pipelines, data quality, orchestration |
| data_scientist | /gbm.tasks | /gbm.analyze | Analysis, statistical tests, viz |
| ml_engineer | /gbm.tasks | /gbm.analyze | Training, serving, versioning |
| sre | /gbm.tasks | /gbm.analyze | SLOs, monitoring, chaos tests |
| security_compliance | /gbm.tasks | /gbm.analyze | Auth, controls, compliance tests |
| architect | /gbm.tasks | /gbm.analyze | ADRs, boundary checks, NFR validation |
| product_manager | /gbm.pm.handoff | — | Hand off to engineering team |
| maintainer | /gbm.tasks | /gbm.analyze | Regression tests, compatibility, tech debt |
| null (not set) | /gbm.persona | /gbm.tasks | Set role first |

**For extended guidance**: Read `.gobuildme/templates/reference/persona-next-steps.md` for detailed focus areas and quality gate requirements per persona.

Use absolute paths with the repository root for all file operations to avoid path issues.

## Optional: Spec Repository Upload

After generating plan artifacts (`plan.md`, `data-model.md`, etc.), you can optionally upload the spec directory:

→ `/gbm.upload-spec` - Upload specs to S3 for cross-project analysis and centralized storage

*Requires AWS credentials. Use `--dry-run` to validate access first.*

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Run `/gbm.clarify` to resolve specification ambiguities first
- Manually edit `$FEATURE_DIR/plan.md` to adjust technical decisions
- Re-run `/gbm.plan` with refined approach or different technology choices
