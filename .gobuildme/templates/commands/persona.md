---
description: "Set the project default persona or a feature driver persona (with optional participants)."
artifacts:
  - path: "$WORKSPACE_ROOT/.gobuildme/config/personas.yaml"
    description: "Persona configuration file with selected driver persona and participants"
  - path: "$FEATURE_DIR/persona.yaml"
    description: "Feature-specific persona assignment (driver persona and participant list)"
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --paths-only --skip-branch-check
  ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly -SkipBranchCheck
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

The user input to you can be provided directly by the agent or as a command argument — you MUST consider it before proceeding (if not empty).

User input:

$ARGUMENTS

---

## Step 0: Workspace-Aware Path Resolution (MANDATORY)

**Purpose**: In monorepo/workspace environments, personas are shared at WORKSPACE ROOT level.

**Resolve Paths**:
1. **WORKSPACE_ROOT**: Walk up from CWD looking for `.gobuildme/manifest.json` with `"mode": "workspace"` or `"mode": "monorepo"`. The outermost such directory is WORKSPACE_ROOT. If none found, use nearest `.gobuildme/` directory.
2. **GBM_ROOT**: Nearest `.gobuildme/` from CWD (for feature-level artifacts)
3. Environment overrides: `$GOBUILDME_WORKSPACE_ROOT`, `$GOBUILDME_TARGET_ROOT`

**Persona Paths**:
- **Project personas**: `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` (shared across all modules/repos)
- **Persona definitions**: `$WORKSPACE_ROOT/.gobuildme/personas/*.yaml`
- **Feature personas**: `$FEATURE_DIR/persona.yaml` (feature-specific)
- **Constitution**: `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`

---

Accepted inline directives (all optional):
- `scope: project|feature` (default: prompt)
- `persona: <id>` (driver persona id)
- `participants: id1,id2,...` (for feature scope)
- `feature: <slug>` (if not on a feature branch and targeting a specific feature)

Behavior:
1) Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.persona" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2) Run `{SCRIPT}` once and parse JSON for `FEATURE_DIR`, `BRANCH`, `REPO_ROOT` (if available). Use absolute paths.
3) Discover available persona ids in this order:
   - Read `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` → `personas[].id`
   - If missing, list ids by reading filenames under `$WORKSPACE_ROOT/.gobuildme/personas/*.yaml` and extracting each file's `id` field.
4) If `scope` not provided, ASK the user to choose: `project` (set repo default) or `feature` (set current feature driver).
5) If `persona` not provided, ASK the user to choose one of the available ids (single selection).
6) **CRITICAL: Check Constitution Prerequisite**
   Before completing persona setup, check if constitution exists:
   - If scope = project AND constitution missing:
     a) **Check Constitution** (REQUIRED FOR ALL PERSONAS):
        - File: `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`
        - If missing: BLOCK setup and show clear message:
          ```
          ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          ⚠️  Constitution Required
          ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

          Before setting a persona, you must define project governance:

          Missing: $WORKSPACE_ROOT/.gobuildme/memory/constitution.md
          Why: Defines project goals, constraints, quality standards

          ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          🎯 Required Action: Run /gbm.constitution first
          ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

          This establishes the foundation:
          • Project mission and goals
          • Technical constraints and standards
          • Quality bars and compliance requirements
          • Architectural principles

          Constitution guides ALL subsequent work (architecture, testing, etc.)

          After running /gbm.constitution, come back and set your persona.
          ```
        - DO NOT PROCEED until constitution exists

     b) If constitution exists: Proceed with persona setup (architecture will be suggested as next step)
7) If scope = `feature`:
   - Determine feature directory:
     * Prefer `FEATURE_DIR` from script JSON if present.
     * Else if `feature: <slug>` was passed, use `$GBM_ROOT/.gobuildme/specs/<slug>`.
     * If neither exists, ASK the user for the feature slug and derive the path.
   - Optionally parse `participants:` from arguments; if not provided, ASK for zero or more ids (allow skip).
   - Write `$FEATURE_DIR/persona.yaml` with:
     ```yaml
     feature_persona: <id>
     participants: [id1, id2]
     ```
   - Confirm file path and persona selections.
8) If scope = `project`:
   - Ensure `.gobuildme/config/personas.yaml` exists; if not, create it with a `personas` registry populated from `.gobuildme/personas/*.yaml`.
   - Set or update `default_persona: <id>`.
   - Confirm file path and default persona.

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
9) Track command complete:
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-persona` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "success|failure" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

Output a short summary that includes:
- Chosen scope and persona id
- Written file path(s)
- Note on how to override per‑command later (future `--persona` CLI flag or updating files directly)

Next Steps (always print at the end, persona-aware):

**Codebase Detection** (MUST determine before showing architecture recommendations):
- **Existing codebase**: Has source code files (*.py, *.js, *.ts, *.go, *.java, *.rb, *.rs, *.cpp, *.cs, etc.) anywhere outside .gobuildme/ and standard config files
- **New codebase**: Only has config files (.gobuildme/, package.json, pyproject.toml, Cargo.toml, go.mod, etc.) but NO source code files
- **Detection method**: Search for code files anywhere in the repo, excluding .gobuildme/, node_modules/, vendor/, .git/, etc.
  Example: `find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.java" -o -name "*.rb" -o -name "*.rs" \) ! -path "./.gobuildme/*" ! -path "./node_modules/*" ! -path "./.git/*" | head -1` (extend with *.cpp, *.cs, *.swift, etc. as needed)
  If this returns any file, it's an existing codebase. Common source directories: src/, app/, lib/, pkg/, cmd/, internal/, components/, pages/, apps/, packages/, services/, backend/, frontend/, server/, client/, api/, modules/, core/
- **CRITICAL**: Only show "/gbm.architecture" recommendation for EXISTING codebases. For NEW codebases, skip directly to /gbm.request.
- **Note**: QA persona REQUIRES an existing codebase (can't test code that doesn't exist).

- If scope = project:
  * If persona = `qa_engineer`:
    - **FIRST**: Check if this is an EXISTING codebase (has source code files using detection method above)
    - **If NEW codebase** (no source code found): STOP HERE with error:
      * Display: "❌ QA Engineer persona requires an existing codebase with source code to test."
      * Display: "No source code files found in this repository."
      * Display: "QA workflow cannot scaffold tests for an empty project."
      * Suggest: "Start with a different persona (e.g., backend_engineer, fullstack_engineer) to build your application first."
      * **DO NOT PROCEED** - skip all steps below and end the command
    - **If EXISTING codebase**: Proceed with ALL of the following QA setup steps:
      * Step 1: Create QA spec directory: `mkdir -p .gobuildme/specs/qa-test-scaffolding`
      * Step 2: Create persona config file `.gobuildme/specs/qa-test-scaffolding/persona.yaml`:
        ```yaml
        feature_persona: qa_engineer
        participants: []
        ```
      * Step 3: Check if user is on a protected branch (main/master/develop/dev/staging/production/prod)
        - If on protected branch: Auto-create and checkout QA branch: `git checkout -b qa-test-scaffolding`, confirm: "✅ Created and switched to branch: qa-test-scaffolding"
        - If already on `qa-test-scaffolding` branch: Confirm: "✅ Already on QA branch: qa-test-scaffolding"
        - If on other branch: Warn and ask to switch (create if user says yes, continue with warning if no)
      * Step 4: Provide QA workflow guidance:
        - "🧪 QA Engineer Persona - Complete Test Generation"
        - "Spec Directory: .gobuildme/specs/qa-test-scaffolding/"
        - If architecture missing: "⚠️ Next: Run /gbm.architecture first (required for existing codebases), then /gbm.qa.scaffold-tests"
        - If architecture exists: "Next: Run /gbm.qa.scaffold-tests to analyze codebase and generate complete test suite."
        - "All QA reports and documentation will be stored in .gobuildme/specs/qa-test-scaffolding/"
        - "Reference: docs/personas/qa-engineer-workflow.md"
      * DO NOT mention /gbm.request or feature development. QA persona is ONLY for testing.
  * If persona = `architect`:
    - Suggest next steps:
      * "📐 Architect Persona - System Design & ADRs"
      * "Next steps:"
      * "  1. /gbm.architecture (Create/update architecture documentation)"
      * "  2. /gbm.specify (Define architecture constraints, NFRs)"
      * "  3. /gbm.clarify (Resolve boundary ambiguities)"
      * "  4. /gbm.plan (Create architecture diagrams, ADRs)"
  * If persona = `backend_engineer`:
    - Suggest next steps:
      * "⚙️ Backend Engineer Persona - API & Services"
      * If EXISTING codebase AND architecture missing: "⚠️ Recommended: Run /gbm.architecture first to document existing tech stack"
      * "Next steps:"
      * "  1. /gbm.request (Define new feature requirements)"
      * "  2. /gbm.specify (Detailed spec with API contracts)"
      * "  3. /gbm.plan (Implementation plan, data migrations)"
      * "  4. /gbm.implement (Write code)"
      * "  5. /gbm.tests (Contract + integration tests)"
  * If persona = `data_engineer`:
    - Suggest next steps:
      * "📊 Data Engineer Persona - Pipelines & Quality"
      * If EXISTING codebase AND architecture missing: "⚠️ Recommended: Run /gbm.architecture first to document existing tech stack"
      * "Next steps:"
      * "  1. /gbm.request (Define data pipeline requirements)"
      * "  2. /gbm.specify (Data sources, SLAs, retention)"
      * "  3. /gbm.plan (Pipeline architecture, DQ rules)"
      * "  4. /gbm.implement (Build pipeline)"
      * "  5. /gbm.tests (Contract tests, DQ checks)"
  * If persona = `security_compliance`:
    - Suggest next steps:
      * "🔒 Security/Compliance Persona - Threat Model & Controls"
      * If EXISTING codebase AND architecture missing: "⚠️ Recommended: Run /gbm.architecture first to document existing tech stack"
      * "Next steps:"
      * "  1. /gbm.specify (Add threat model, data classification)"
      * "  2. /gbm.plan (Security controls, access patterns)"
      * "  3. /gbm.analyze (Security scan, control coverage)"
      * "  4. /gbm.review (Compliance mapping, residual risks)"
  * If persona = `ml_engineer`:
    - Suggest next steps:
      * "🤖 ML Engineer Persona - Model Development"
      * If EXISTING codebase AND architecture missing: "⚠️ Recommended: Run /gbm.architecture first to document existing tech stack"
      * "Next steps:"
      * "  1. /gbm.request (Define ML problem, success metrics)"
      * "  2. /gbm.specify (Model requirements, data needs)"
      * "  3. /gbm.plan (Model architecture, training pipeline)"
      * "  4. /gbm.implement (Train model, serving API)"
      * "  5. /gbm.tests (Model validation, drift detection)"
  * If persona = `frontend_engineer`:
    - Suggest next steps:
      * "🎨 Frontend Engineer Persona - UI Components"
      * If EXISTING codebase AND architecture missing: "⚠️ Recommended: Run /gbm.architecture first to document existing tech stack"
      * "Next steps:"
      * "  1. /gbm.request (Define UI/UX requirements)"
      * "  2. /gbm.specify (Component specs, accessibility)"
      * "  3. /gbm.plan (Component architecture, state)"
      * "  4. /gbm.implement (Build components)"
      * "  5. /gbm.tests (Component + visual tests)"
  * If persona = `fullstack_engineer`:
    - Suggest next steps:
      * "🔄 Fullstack Engineer Persona - End-to-End Features"
      * If EXISTING codebase AND architecture missing: "⚠️ Recommended: Run /gbm.architecture first to document existing tech stack"
      * "Next steps:"
      * "  1. /gbm.request (Define full-stack feature requirements)"
      * "  2. /gbm.specify (UX flows + API contracts)"
      * "  3. /gbm.plan (Backend + frontend implementation)"
      * "  4. /gbm.implement (Build full stack)"
      * "  5. /gbm.tests (Contract + component + E2E tests)"
  * If persona = `sre`:
    - Suggest next steps:
      * "🚨 SRE Persona - Reliability & Observability"
      * If EXISTING codebase AND architecture missing: "⚠️ Recommended: Run /gbm.architecture first to document existing tech stack"
      * "Next steps:"
      * "  1. /gbm.specify (Define SLOs, SLIs, error budgets)"
      * "  2. /gbm.plan (Observability, runbooks, alerts)"
      * "  3. /gbm.analyze (Reliability review, bottlenecks)"
      * "  4. /gbm.review (SLO compliance, incident prep)"
  * If persona = `product_manager`:
    - Suggest next steps:
      * "📋 Product Manager Persona - Requirements & Discovery"
      * "Next steps:"
      * "  1. /gbm.pm.discover (Begin discovery phase)"
      * "  2. /gbm.pm.interview (Conduct user interviews)"
      * "  3. /gbm.pm.prd (Create evidence-based PRD)"
      * "  4. /gbm.specify (Detailed specs with ACs)"
  * If persona = `maintainer`:
    - Suggest next steps:
      * "🔧 Maintainer Persona - Technical Debt & Reviews"
      * If EXISTING codebase AND architecture missing: "⚠️ Recommended: Run /gbm.architecture first to document existing tech stack"
      * "Next steps:"
      * "  1. /gbm.analyze (Assess tech debt, dependencies)"
      * "  2. /gbm.review (Review PRs, enforce quality gates)"
      * "  3. /gbm.push (Final validation before merge)"
  * If persona = `data_scientist`:
    - Suggest next steps:
      * "📈 Data Scientist Persona - Analysis & Experiments"
      * If EXISTING codebase AND architecture missing: "⚠️ Recommended: Run /gbm.architecture first to document existing tech stack"
      * "Next steps:"
      * "  1. /gbm.request (Define analysis question)"
      * "  2. /gbm.specify (Data needs, methodology)"
      * "  3. /gbm.plan (Experiment design, validation)"
      * "  4. /gbm.implement (Run analysis, notebooks)"
      * "  5. /gbm.tests (Statistical validation, reproducibility)"
  * Otherwise (fallback for any other persona):
    - Suggest `/gbm.request` to start a feature with the project default persona.
- If scope = feature: suggest `/gbm.specify` to draft the spec with the selected driver persona.


Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Run `/gbm.persona` again to select or change your persona
- Review persona documentation in `.gobuildme/personas/<persona>.yaml`
- Proceed with your workflow using current persona configuration

