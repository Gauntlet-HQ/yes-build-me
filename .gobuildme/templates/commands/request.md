---
description: "Capture and clarify a feature request, creating the initial request document with goals and assumptions"
artifacts:
  - path: "$FEATURE_DIR/request.md"
    description: "Feature request document with goals, non-goals, assumptions, and open questions"
  - path: "$FEATURE_DIR/persona.yaml"
    description: "Feature persona assignment (driver persona and participant list)"
  - path: ".gobuildme/specs/epics/<epic>/slice-registry.yaml"
    description: "PR slice registry tracking all slices within an epic (created when splitting)"
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

The user input after `/gbm.request` is the raw request to clarify. If the text includes a JIRA key (e.g., ABC-123) or a ticket URL, incorporate it.

## CRITICAL: Input Validation Gate

**Before proceeding with ANY work, validate that sufficient input was provided:**

1. **Check for empty/insufficient input**:
   - If `$ARGUMENTS` is empty, contains only whitespace, or contains only a persona name with no actual request
   - If the input is too vague to determine what feature to build (e.g., just "something", "a feature", "help me")

2. **If input is insufficient, STOP and ask for clarification**:
   - DO NOT invent or hallucinate features
   - DO NOT proceed based on assumptions about what the user might want
   - DO NOT use the persona to guess what kind of feature to create

   Instead, respond with:
   ```
   ❌ **Insufficient input for /gbm.request**

   I need more information to create a meaningful feature request. Please provide:
   - What problem are you trying to solve?
   - What should this feature do?
   - Any specific requirements or constraints?

   Example usage:
   - `/gbm.request Add user authentication with OAuth support`
   - `/gbm.request PROJ-123 https://jira.example.com/browse/PROJ-123`
   - `/gbm.request Build a REST API for inventory management`

   Please re-run `/gbm.request` with a description of what you want to build.
   ```

3. **Only proceed if input clearly describes**:
   - A problem to solve, OR
   - A feature to build, OR
   - A ticket reference with context

---

## Step 0: Workspace-Aware Path Resolution (from script output)

The script `{SCRIPT}` outputs workspace-aware paths. Parse these from the JSON output:
- `WORKSPACE_ROOT` - Workspace/monorepo root (for constitution, personas)
- `GBM_ROOT` - Nearest `.gobuildme/` (for feature artifacts, specs)
- `FEATURE_DIR` - Feature-specific directory (absolute path)
- `CONSTITUTION_PATH` - Path to constitution.md
- `ARCHITECTURE_DIRS` - Colon-separated list of architecture directories (module → root order)
- `MODE` - Deployment mode: "single" | "monorepo" | "workspace"

**Path Usage**:
- **Persona config**: `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` (shared across modules/repos)
- **Persona definitions**: `$WORKSPACE_ROOT/.gobuildme/personas/<id>.yaml`
- **Constitution**: `$CONSTITUTION_PATH` (or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`)
- **Architecture docs**: Search each directory in `$ARCHITECTURE_DIRS` (module → root order)
- **Feature artifacts**: `$FEATURE_DIR/` (absolute path, already includes full path to feature)
- **Slice registries** (cross-repo coordination):
  - `$REGISTRY_ROOT` = where the registry lives (for cross-repo lookup)
    * `mode: local` / `mode: cross_module`: `$REGISTRY_ROOT = $GBM_ROOT`
    * `mode: cross_repo`: `$REGISTRY_ROOT = $WORKSPACE_ROOT`
  - Registry path: `$REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml`
- **Slice artifacts** (request.md, spec.md, etc.):
  - Always in the REPO where the slice belongs: `$GBM_ROOT/.gobuildme/specs/epics/<epic>/<slice>/`
  - For `cross_repo`: `request_path` in registry includes repo prefix (e.g., `api-repo/.gobuildme/specs/...`)

Use these resolved paths for all file access in monorepo/workspace environments.

---

## Git Repository Check (Greenfield Projects)

**Before creating any feature branches or artifacts, verify git is available and initialized:**

1. **Check if git is installed**: Run `which git 2>/dev/null || where git 2>nul`
   - **If git is NOT installed**: Display warning and skip git operations:
     ```
     ⚠️ **Git Not Found**

     Git is not installed on this system. Branch-based PR workflows require git.
     Skipping git initialization. Install git to enable PR workflow features.
     ```
     Continue with request creation (git operations are optional).

2. **Check for .git directory**: Run `git rev-parse --git-dir 2>/dev/null`

3. **If git is NOT initialized** (command fails or no .git directory):
   - Display warning and **ask for confirmation**:
     ```
     ⚠️ **No Git Repository Found**

     This appears to be a new project without git initialized.
     Git is required for branch-based PR workflows.

     Would you like me to initialize git? [Y/n]
     ```
   - **If user confirms (Y or Enter)**: Run `git init`
   - **If `.gobuildme/` exists**: Ask "Commit GoBuildMe framework files? [Y/n]"
     - If confirmed: `git add .gobuildme/ && git commit -m "chore: initialize GoBuildMe SDD framework"`
     - **Note**: This initial commit is allowed on main/master for greenfield projects only.
   - **If user declines**: Warn that branch-based workflows will not work, but continue

4. **If git IS initialized but no commits exist**:
   - Check if `.gobuildme/` exists
   - If yes, ask: "Create initial commit with GoBuildMe framework? [Y/n]"
   - If confirmed: `git add .gobuildme/ && git commit -m "chore: initialize GoBuildMe SDD framework"`
   - **Note**: This initial commit is allowed on main/master for greenfield projects only.

5. **For PR slices** (when request involves multiple PRs - template guidance only, no CLI blocking):
   - Each PR slice should have its own branch using `<epic>--<slice>` pattern (double-dash separator)
   - Branch naming convention: `<epic>--<slice-name>`, e.g., `user-auth--backend-api`, `user-auth--ui-layer`
   - Slice folders are created under `specs/epics/<epic>/<slice>/`
   - When suggesting PR slices, also specify the branch commands:
     ```
     Suggested PR workflow:
     1. Create branch: `git checkout -b user-auth--backend-api` → /gbm.request
     2. After PR-1 merged: `git checkout -b user-auth--ui-layer` → /gbm.request
     ```

## Protected Branch Warning (MANDATORY - Before Any Work)

**Check if currently on a protected branch** (main, master, develop, etc.):

```bash
# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
echo "Current branch: $CURRENT_BRANCH"
```

**If on a protected branch** (main, master, develop, dev, staging, production, prod):

```
⚠️ **Warning: You are on protected branch '$CURRENT_BRANCH'**

The GoBuildMe workflow requires a feature branch for implementation.
Commits to protected branches are BLOCKED by the harness system.

**Action Required**: Create a feature branch now or after the request is captured.

Options:
1. Create branch now: `git checkout -b <feature-name>`
2. Continue to capture the request, then create branch before /gbm.implement

If you continue on '$CURRENT_BRANCH', you MUST create a feature branch
before running /gbm.implement, /gbm.tests, or /gbm.review.
```

**Display this warning prominently** - do not silently continue. The user needs to understand that implementation on protected branches will fail.

---

Do this:

1) Track command start:
   - Run `$GBM_ROOT/.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.request" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2) Persona (ask-if-missing; non-breaking):
   - Using the slug from user input (e.g., `slug:my-feature`) or derived from request text, if `$FEATURE_DIR/persona.yaml` is missing:
     * Discover available persona ids from `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` → `personas[].id` (fallback: scan `$WORKSPACE_ROOT/.gobuildme/personas/*.yaml`).
     * Preselect `default_persona` from `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` if present; otherwise ASK the user to choose a driver persona id.
     * ASK for optional participants (0..N ids; allow skip).
     * Write `$FEATURE_DIR/persona.yaml` with:
       ```yaml
       feature_persona: <id>
       participants: [id1, id2]
       ```
   - When a persona is determined (driver or default), enforce `required_sections["/request"]` from the persona file and include `$GBM_ROOT/.gobuildme/templates/personas/partials/<id>/request.md` if present.
   - If the user declines selection, proceed as generalist and remind they can run `/gbm.persona` later to set it.

3) **Architecture Check (Existing Codebases)**:

   **Purpose**: Ensure architecture is documented before scoping requests, so PR slice boundaries align with system structure.

   **Repo Root Resolution**: Run checks from repo root. Use `git rev-parse --show-toplevel` or search upward for `.gobuildme/manifest.json` to find it.

   a) **Detect if this is an existing codebase** (file-based detection):
      - **Existing codebase**: Has source code files (`*.py`, `*.js`, `*.ts`, `*.go`, `*.java`, `*.rb`, `*.rs`, `*.cpp`, `*.cs`, `*.swift`, etc.) anywhere outside `.gobuildme/` and standard config files
      - **New codebase**: Only has config files (`.gobuildme/`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc.) but NO source code files
      - **Detection method**: Search for code files anywhere in repo, excluding standard directories:
        ```bash
        find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.java" -o -name "*.rb" -o -name "*.rs" -o -name "*.cpp" -o -name "*.cs" -o -name "*.swift" \) ! -path "./.gobuildme/*" ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./vendor/*" | head -1
        ```
      - If source code files found: treat as **existing codebase** (continue check)
      - If no source code files: treat as **new project** (skip architecture check)

   b) **Check for architecture documentation** (existing codebases only):
      - Search each directory in `$ARCHITECTURE_DIRS` for `system-analysis.md`
      - If architecture exists: Load it for scope-informed request (note key modules, boundaries, integrations)

   c) **If architecture is missing**, check enforcement mode:
      - Read `$CONSTITUTION_PATH` (or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`) for `workflow_enforcement` settings
      - **If constitution.md is missing**: treat as soft gate (default behavior)
      - Check if current persona is in `strict_architecture_personas` list (architect, security_compliance, sre by default)
      - **Strict mode** (`architecture_required_before_request: true` OR persona in strict list):
        ```
        ❌ **Architecture Required**

        This codebase has existing source code but no architecture documentation.
        Architecture must be documented before creating requests.

        Reason: [strict mode enabled globally | persona '<persona>' requires architecture]

        Run: `/gbm.architecture`

        This ensures PR slice boundaries align with module boundaries and integration points.
        To adjust: Edit `workflow_enforcement` in `$CONSTITUTION_PATH`
        ```
        **STOP** - do not proceed until `/gbm.architecture` is run.

      - **Default mode** (soft gate - setting missing or `false`):
        Display warning but **continue**:
        ```
        ⚠️  **Architecture Recommended**

        This codebase has existing source code but no architecture documentation.
        For better PR slice boundaries, consider running `/gbm.architecture` first.

        Benefits:
        - Understand module boundaries before scoping
        - Identify integration points that may affect slicing
        - Document system patterns for informed decisions

        Continuing without architecture... (specify/plan will require it later)
        ```

   d) **If architecture exists**, use it to inform scope assessment:
      - Note key modules/services from `system-analysis.md`
      - Note external integrations from `integration-landscape.md` (if exists)
      - Use this context when proposing PR slices in step 5c (Epic & PR Slice section)

4) Run `{SCRIPT}` from repo root and parse its JSON for `BRANCH_NAME`, `REQUEST_FILE`, `SPEC_FILE`, and `FEATURE_DIR`.
   - If the user supplied an explicit `slug:`/`branch:` override, the script already honored it. Strip that directive from the narrative so it doesn't persist in the saved request.
   - Otherwise, surface the auto-generated `BRANCH_NAME` as the suggested feature name and invite the user to reply with `slug: <override>` if they prefer something else.
   - Use absolute paths for all file references.

   **Deployment Mode Detection** (for monorepo/workspace support):
   - Source common.sh and call `get_mode()` to determine deployment mode: "single" | "monorepo" | "workspace"
   - Store result in `$DEPLOYMENT_MODE` for use in slice registry creation
   - Call `get_epic_scope()` to get default epic scope: "local" | "cross_module" | "cross_repo"
   - Store result in `$EPIC_SCOPE` for use in scope selection
   - **At workspace root** (`is_at_workspace_root` returns true): Always use cross-repo scope
   - **In monorepo module**: May prompt for cross-module scope (see Step 5)

   **Check for existing slice registry** (continuing an epic):

   **Detection Flow** (before REQUEST_FILE is created):
   1. Get branch name / feature slug (e.g., `my-epic--ui-layer`)
   2. If branch contains `--`: Parse into `<epic>` and `<slice>` parts
      - epic_part = everything before first `--`
      - slice_part = everything after first `--`
      - Normalize both to kebab-case lowercase
   3. Check for existing registry (search both locations for cross-repo support):
      - First: `$GBM_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml`
      - If not found and `$WORKSPACE_ROOT != $GBM_ROOT`: also check `$WORKSPACE_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml`
      - Set `$REGISTRY_ROOT` to whichever location has the registry (for subsequent operations)
   4. If registry exists, verify `<slice>` is listed in the slices array
   5. **If match found** (continuing an existing epic):
      * Load the matching registry and read `mode` field
      * **Determine artifact location** (based on registry mode):
        - If `mode: cross_repo`:
          * **VERIFY REPO MATCH** (required before creating artifacts):
            1. Get current repo identifiers: Call `get_repo_identifiers()` from common.sh
            2. Extract `current_repo_path` from the result
            3. Read slice's `repo_path` from registry entry
            4. **Handle missing/null repo_path** (backward compatibility for older registries):
               - If `slice.repo_path` is null or missing:
                 ```
                 ⚠️ **Slice Missing repo_path (Legacy Registry)**

                 This slice was created before repo_path tracking was added.
                 Current repo: <current_repo_path>

                 Options:
                 A) Assign this slice to current repo: Set repo_path = <current_repo_path>
                 B) Cancel: Switch to correct repo first, then re-run /gbm.request

                 Choice [A/B]: ___
                 ```
               - If user chooses A: Update slice's repo identifiers in registry:
                 * Set `repo_path` = current_repo_path
                 * Set `repo_slug` = current_repo_slug (from get_repo_identifiers())
                 * Set `repo_git_url` = current_repo_git_url (if available, else null)
                 * Continue with artifact creation
               - If user chooses B: Stop and let user switch repos
            5. Compare: `current_repo_path == slice.repo_path`
            6. **If mismatch, BLOCK** and display:
               ```
               ❌ **Wrong Repo for This Slice**

               You are in repo: <current_repo_path>
               This slice belongs to: <slice.repo_path>

               **To proceed:**
               1. Switch to the correct repo: `cd ../<slice.repo_path>`
               2. Re-run `/gbm.request` from that repo

               Epic: <epic>
               Slice: <slice_name>
               Registry: $REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml
               ```
               Do NOT create artifacts - user must switch repos first.
          * If repo matches (or user assigned current repo): Continue with artifact creation
          * Set feature_dir = `$GBM_ROOT/.gobuildme/specs/epics/<epic>/<slice_name>/` (repo's .gobuildme/)
          * Set request_path in registry = `<repo_path>/.gobuildme/specs/epics/<epic>/<slice_name>/request.md`
        - Otherwise (`mode: local` or `mode: cross_module`):
          * Set feature_dir = `$REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/<slice_name>/`
          * Set request_path in registry = `.gobuildme/specs/epics/<epic>/<slice_name>/request.md`
      * Set REQUEST_FILE = `<feature_dir>/request.md`
      * Update slice: `status: planned` → `status: in_progress`, set `request_path`
      * Display: `📋 Continuing epic: <epic> (slice: <slice_name>, N of M)`
      * Skip Step 5 PR Scope Evaluation (scope already defined in registry)
      * Proceed directly to Step 6 with scope from registry's `scope_summary`

   5b. **If registry EXISTS but slice NOT found** (adding new slice to existing epic):
      * Display:
        ```
        📋 **Adding New Slice to Epic**

        Epic: <epic> (registry found at <registry_path>)
        New slice: <slice> (not yet in registry)
        Existing slices: <list slice_name from each existing slice>
        ```

      * **Cross-Slice Overlap Check** (MANDATORY):
        - Read `scope_summary` from each existing slice in registry
        - Compare against the new slice's intended scope (from user request)
        - **Best-effort detection**: Check for obvious keyword overlap in scope_summary
          - Extract key nouns from each scope_summary (e.g., "API endpoints", "user auth", "database models")
          - If new slice scope_summary shares 2+ key nouns with an existing slice → potential overlap
        - **If potential overlap detected**:
          ```
          ⚠️ **Potential Scope Overlap Detected**

          Your new slice may overlap with existing slice(s):

          | Existing Slice | Scope Summary | Overlap Keywords |
          |----------------|---------------|------------------|
          | <slice_name>   | <scope_summary> | <shared keywords> |

          Options:
          A) Adjust scope: Narrow this slice's focus to avoid overlap
          B) Continue: Proceed if overlap is intentional (different aspects of same area)
          C) Cancel: Re-evaluate epic structure before adding slice
          ```
          - If user chooses A: Ask for refined scope description
          - If user chooses B: Proceed with warning recorded
          - If user chooses C: Stop and suggest running `/gbm.request` on a different branch

        - **If no overlap detected**: Proceed to add slice

      * **Add new slice to existing registry**:
        - Read total_slices from registry, increment by 1
        - Read `mode` field from registry
        - Generate new slice ID: `pr<N>` where N = new total_slices
        - Prompt user: "Brief scope summary for this slice (1-2 sentences):"
        - **Determine artifact location and request_path** (based on registry mode):
          * If `mode: cross_repo`:
            - **GUARD: Check if at workspace root** (`$GBM_ROOT == $WORKSPACE_ROOT`):
              * If at workspace root, **STOP** and display:
                ```
                ❌ **Cannot Create Slice Artifacts at Workspace Root**

                Cross-repo slices require artifacts in each repo's own .gobuildme/ directory.
                You are currently at the workspace root, not inside a specific repo.

                **To proceed:**
                1. Switch to the target repo for this slice: `cd <repo_path>`
                2. Re-run `/gbm.request` from within that repo

                Epic: <epic>
                New slice: <slice>
                Registry: $REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml
                ```
              * Do NOT create slice folder or request.md - user must switch repos first
            - If inside a repo (`$GBM_ROOT != $WORKSPACE_ROOT`):
              * Get current repo_path via `get_repo_identifiers()` from common.sh
              * Artifact folder: `$GBM_ROOT/.gobuildme/specs/epics/<epic>/<slice>/` (repo's .gobuildme/)
              * request_path for registry: `<current_repo_path>/.gobuildme/specs/epics/<epic>/<slice>/request.md`
          * Otherwise (`mode: local` or `mode: cross_module`):
            - Artifact folder: `$REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/<slice>/`
            - request_path for registry: `.gobuildme/specs/epics/<epic>/<slice>/request.md`
        - Add slice entry to registry:
          ```yaml
          - id: pr<N>
            slice_name: <slice>
            scope_summary: "<user-provided scope summary>"
            status: in_progress
            depends_on: <ask: "Does this depend on another slice? (enter slice ID like 'pr1' or 'null')">
            request_path: <request_path determined above>
            constitution_refs: []  # Populated in /gbm.plan
            # Include module_path/repo_path if mode is cross_module/cross_repo
          ```
        - Update `total_slices` in registry
        - Create slice folder at determined artifact location
        - Set REQUEST_FILE = `<artifact folder>/request.md`
        - Display: `✅ Added slice '<slice>' to epic '<epic>' (PR-<N> of <total>)`

      * Proceed to Step 6 with the new slice scope

   6. **If branch has `--` but NO registry found** (orphan slice branch):
      * Display warning:
        ```
        ⚠️ **Orphan Slice Branch Detected**

        Branch `<branch>` uses `--` separator (epic--slice pattern) but no slice registry exists.
        This may indicate:
        - You created the branch manually before running /gbm.request on the epic root
        - The registry was deleted or never created

        **To fix**: Create the epic registry first:
        1. Checkout epic root branch: `git checkout -b <epic>` (or checkout if exists)
        2. Run `/gbm.request` with the full scope to create the slice registry
        3. Then: `git checkout <epic>--<slice>` and run `/gbm.request` again

        **To continue anyway**: Treating this as a NEW epic with first slice `<slice>`.
        A new registry will be created if PR splitting occurs in Step 5.
        ```
      * Continue with normal flow (Step 5) - user can still proceed
   7. **If branch has NO `--`**: Continue with normal flow (Step 5) - standalone feature

   **Example (local/cross_module mode)**: Branch `user-auth--ui-layer`
   - Parses branch: epic = `user-auth`, slice = `ui-layer`
   - Checks for registry: First `$GBM_ROOT/...`, then `$WORKSPACE_ROOT/...` if different
   - Registry found at `$REGISTRY_ROOT/.gobuildme/specs/epics/user-auth/slice-registry.yaml`
   - Registry has `epic_slug: user-auth`, `mode: local`, and slice with `slice_name: ui-layer`
   - Match found → Sets feature_dir to `$REGISTRY_ROOT/.gobuildme/specs/epics/user-auth/ui-layer/`

   **Example (cross_repo mode)**: Branch `user-auth--ui-layer` (in `ui-repo`)
   - Parses branch: epic = `user-auth`, slice = `ui-layer`
   - Registry found at `$WORKSPACE_ROOT/.gobuildme/specs/epics/user-auth/slice-registry.yaml`
   - Registry has `mode: cross_repo` and slice with `slice_name: ui-layer`, `repo_path: ui-repo`
   - **Repo verification**: Current repo = `ui-repo`, slice repo_path = `ui-repo` → Match ✓
   - Match found → Sets feature_dir to `$GBM_ROOT/.gobuildme/specs/epics/user-auth/ui-layer/` (repo's .gobuildme/)
   - Sets request_path in registry to `ui-repo/.gobuildme/specs/epics/user-auth/ui-layer/request.md`

5) **PR Scope Evaluation (MANDATORY - BEFORE WRITING request.md)**:

   **⚠️ CRITICAL: Perform this evaluation BEFORE creating request.md. If strict mode triggers, STOP here.**

   **Step A: Count distinct concerns** (mark [x] for all that apply):
   - [ ] Backend API/endpoints
   - [ ] Frontend UI components
   - [ ] Database/data models
   - [ ] Business logic/services
   - [ ] External integrations
   - [ ] Authentication/authorization
   - [ ] Theming/styling
   - [ ] Other: ___

   **Concern count = number of [x] items**

   **Step B: Estimate LoC** (calculate based on goals):
   | Component Type | Typical LoC | Your Estimate |
   |----------------|-------------|---------------|
   | REST API endpoint | 50-100 per endpoint | |
   | Frontend page/component | 100-200 per page | |
   | Database model | 30-50 per model | |
   | Service layer | 50-100 per service | |
   | UI theming | 50-100 | |
   | Tests | 50-100% of impl | |

   **Total estimated LoC = sum of estimates**

   **Step C: Display Scope Assessment** (MANDATORY - ALWAYS DISPLAY):
   ```
   ┌─────────────────────────────────────────────────┐
   │ 📊 PR Scope Assessment                          │
   ├─────────────────────────────────────────────────┤
   │ Concerns: [N] (guideline: ≤2)                   │
   │ Est. LoC: [N] (guideline: <500)                 │
   │ Status:   [✅ Within guidelines | ⚠️ Exceeds]   │
   └─────────────────────────────────────────────────┘
   ```

   **Step D: If scope exceeds guidelines** (concerns > 2 OR LoC > 500):

   Check enforcement mode in `$CONSTITUTION_PATH`:
   - Read `workflow_enforcement.pr_slicing.mode` (default: `warn`)

   **Strict mode** (`mode: strict`):
   ```
   ❌ **Scope Exceeds PR Slicing Guidelines - STOPPING**

   This request is too large for a single PR:
   - Concerns: [N] (guideline: ≤2)
   - Est. LoC: [N] (guideline: <500)

   REQUIRED: Split into smaller requests using epic--slice pattern:
   1. `git checkout -b <epic>--backend-api` then `/gbm.request` - [First slice: e.g., "Backend API only"]
   2. `git checkout -b <epic>--ui-layer` then `/gbm.request` - [Second slice: e.g., "Frontend UI"]
   3. `git checkout -b <epic>--polish` then `/gbm.request` - [Third slice: e.g., "Theming & polish"]
   ```
   **STOP HERE** - do not proceed to step 6. Wait for user to provide smaller scope.

   **Warn mode** (default):
   ```
   ⚠️  **Large Request - Consider Splitting**

   This request exceeds PR slicing guidelines:
   - Concerns: [N] (guideline: ≤2)
   - Est. LoC: [N] (guideline: <500)

   Recommended PR slices:
   1. PR-1: [First slice description]
   2. PR-2: [Second slice description]
   3. PR-3: [Third slice description]

   Options:
   A) Split now: Create slice registry and continue with PR-1 scope only
   B) Continue: Provide justification why this cannot be split
   ```
   **If user chooses Option A (Split now)**:

   1. **Epic slug**: Use current feature slug as epic slug
      - Example: `my-feature` stays `my-feature`

   2. **Derive descriptive slice names from scope summaries**:
      - Convert each scope_summary from Step 5D to kebab-case slice name
      - Example: "Backend API only - FastAPI setup..." → `backend-api`
      - Example: "Frontend UI - HTML layout..." → `frontend-ui`
      - **Collision Handling**: If two summaries normalize to same name, append numeric suffix: `backend-api`, `backend-api-2`

   3. **Determine Registry Root** (based on deployment mode from Step 4):

      **Scope Detection for Registry**:
      - **Single repo mode** (`$DEPLOYMENT_MODE == "single"`):
        * Registry root: `$GBM_ROOT` (same as workspace root in single repo)
        * Set `mode: local`, no module/repo fields
      - **Monorepo mode** (`$DEPLOYMENT_MODE == "monorepo"`):
        * Registry root: `$GBM_ROOT` (monorepo root has unified .gobuildme/)
        * If at monorepo root OR user confirms cross-module epic: Set `mode: cross_module`
        * If in a module and user wants local epic: Set `mode: local`
        * For cross-module: Add `module_path` field to each slice (relative path to module)
      - **Workspace mode** (`$DEPLOYMENT_MODE == "workspace"`):
        * If at workspace root: Registry root = `$WORKSPACE_ROOT`, set `mode: cross_repo`
        * If in a repo: Prompt "Does this feature span multiple repos? (y/N)"
          - Yes → Registry root = `$WORKSPACE_ROOT`, set `mode: cross_repo`
          - No → Registry root = `$GBM_ROOT`, set `mode: local`
        * For cross-repo: Add `repo_path`, `repo_slug`, `repo_git_url` fields (only for current slice; others stay null)
      - **GOBUILDME_SCOPE override**: If `$GOBUILDME_SCOPE=cross` is set, skip prompting and use cross scope

      Let `$REGISTRY_ROOT` = determined root above (either `$GBM_ROOT` or `$WORKSPACE_ROOT`).

   4. **Create epics folder** (if not exists): `$REGISTRY_ROOT/.gobuildme/specs/epics/`

   5. **Create Slice Registry** at `$REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml`:

      **Registry Schema** (extended for monorepo/workspace):
      ```yaml
      # NOTE: This example shows registry AFTER artifacts are created (from inside a repo).
      # When created at workspace root, PR-1's request_path will be null until user
      # runs /gbm.request from the target repo.
      epic_slug: <epic>
      total_slices: N  # Count of recommended slices from Step 5D
      created_at: "<ISO-8601>"
      created_by: "<git config user.name>"
      mode: local | cross_module | cross_repo  # NEW: Epic scope type
      slices:
        - id: pr1
          slice_name: <first-slice-name>  # Descriptive kebab-case name
          scope_summary: "[First slice description from Step 5D]"
          status: in_progress
          depends_on: null
          # NOTE: request_path format depends on mode:
          # - local/cross_module: .gobuildme/specs/epics/<epic>/<slice>/request.md
          # - cross_repo: <repo_path>/.gobuildme/specs/epics/<epic>/<slice>/request.md
          # - At workspace root: null until /gbm.request runs from target repo
          request_path: .gobuildme/specs/epics/<epic>/<first-slice-name>/request.md
          constitution_refs: []  # Principle IDs from constitution (populated in /gbm.plan)
          # MONOREPO ONLY (mode: cross_module) - relative path to module:
          module_path: apps/api-service  # or null for root-level slice
          # WORKSPACE ONLY (mode: cross_repo) - repo identification:
          repo_path: api-repo           # Relative path from workspace root
          repo_slug: api-repo           # Stable identifier (survives repo rename)
          repo_git_url: git@github.com:org/api-repo.git  # Fallback for repo ID
        - id: pr2
          slice_name: <second-slice-name>
          scope_summary: "[Second slice description from Step 5D]"
          status: planned
          depends_on: pr1
          request_path: null  # Set when slice becomes in_progress
          constitution_refs: []  # Populated in /gbm.plan
          # NOTE: repo fields are NULL until user runs /gbm.request from target repo
          module_path: null    # Set when /gbm.request runs from target module
          repo_path: null      # Set when /gbm.request runs from target repo
          repo_slug: null      # Set when /gbm.request runs from target repo
          repo_git_url: null   # Set when /gbm.request runs from target repo
        # ... additional slices from Step 5D
      ```

      **Populating Repo Identifiers** (for cross-repo slices ONLY):
      - Only include these fields when `mode: cross_repo`
      - For local epics, omit module_path/repo_path fields entirely
      - **Principle**: Only populate repo_path for the CURRENT slice (PR-1). Leave other slices' repo_path null until the user runs /gbm.request from each target repo.
      - **How to get repo identifiers depends on current location**:
        * **If inside a repo** (`$GBM_ROOT != $WORKSPACE_ROOT`):
          - Call `get_repo_identifiers()` from common.sh to get current repo's `repo_slug`, `repo_git_url`, `repo_path`
          - **ONLY set these fields for the CURRENT slice (PR-1)** - the slice being created now
          - **Leave other slices' repo fields null** with comment: `# Set when /gbm.request runs from target repo`
          - Display note:
            ```
            📋 **Cross-Repo Epic Created**

            Slice 1 (<first-slice-name>) assigned to current repo: <repo_path>
            Other slices have repo_path: null (will be set when you run /gbm.request from each target repo)

            To continue with slice 2:
            1. cd ../<target-repo-for-slice-2>
            2. git checkout -b <epic>--<slice-2-name>
            3. Run /gbm.request
            ```
        * **If at workspace root** (`$GBM_ROOT == $WORKSPACE_ROOT`):
          - **Cannot auto-detect repo** - prompt user for PR-1's target repo:
            ```
            📋 **Cross-Repo Epic: Specify First Slice's Repo**

            Which repo should slice 1 (<first-slice-name>) belong to?
            → Target repo (relative path from workspace root, e.g., "api-repo"): ___
            ```
          - Set repo_path for PR-1 only from user input
          - Derive repo_slug from repo_path (last path component)
          - Leave repo_git_url null (populated when user runs /gbm.request from that repo)
          - **Leave other slices' repo fields null** - will be set when each repo runs /gbm.request
          - **NOTE**: request_path remains null for ALL slices (including PR-1) until user runs /gbm.request from target repo

   6. **Create PR-1 folder** (NESTED under epic):
      - **Determine artifact location** (based on mode set in step 5.3):
        * If `mode: cross_repo`:
          - **GUARD: Check if at workspace root** (`$GBM_ROOT == $WORKSPACE_ROOT`):
            * If at workspace root, **STOP** and display:
              ```
              ❌ **Cannot Create Slice Artifacts at Workspace Root**

              Cross-repo slices require artifacts in each repo's own .gobuildme/ directory.
              You are currently at the workspace root, not inside a specific repo.

              **To proceed:**
              1. Switch to the target repo: `cd <repo_path>` (e.g., `cd api-repo`)
              2. Re-run `/gbm.request` from within that repo

              Registry created at: $REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml
              First slice target repo: <first-slice-repo_path from registry>
              ```
            * Do NOT create slice folder or request.md - user must switch repos first
          - If inside a repo (`$GBM_ROOT != $WORKSPACE_ROOT`):
            * Artifact folder: `$GBM_ROOT/.gobuildme/specs/epics/<epic>/<first-slice-name>/`
            * request_path for registry: `<repo_path>/.gobuildme/specs/epics/<epic>/<first-slice-name>/request.md`
        * Otherwise (`mode: local` or `mode: cross_module`):
          - Artifact folder: `$REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/<first-slice-name>/`
          - request_path for registry: `.gobuildme/specs/epics/<epic>/<first-slice-name>/request.md`
      - Set REQUEST_FILE to `<artifact folder>/request.md`
      - Update slice entry's `request_path` in registry with determined path
      - Proceed to Step 6 with PR-1 scope only

   7. **Display registry location**:
      ```
      📋 Slice registry created: $REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml
         Tracking N slices for epic: <epic>
         First slice: <first-slice-name>
      ```

   **IMPORTANT - Registry vs Artifacts**:
   - **Registry**: Lives at `$REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml`
   - **Artifacts**: For `cross_repo` mode, each slice's artifacts live in that repo's `$GBM_ROOT/.gobuildme/`
   - /gbm.request NEVER writes to `<epic root>/request.md` - only to slice folders
   - The epic root folder only contains `slice-registry.yaml` (not artifacts)

   **If user chooses Option B (Continue)**: Require "Why One PR" justification (will be captured in request.md). Proceed to Step 6 without registry.

   **Greenfield example**: "full-stack app with API + UI + theming" = 4+ concerns, 700+ LoC → MUST trigger warning.

6) **Write the actual request content with metadata frontmatter** (MANDATORY - YOU MUST DO THIS):
   - **CRITICAL**: Generate request.md with YAML frontmatter containing metadata
   - **DO NOT leave any template placeholders** - replace them with actual information
   - Open `REQUEST_FILE` and write the complete request with this exact structure:

   ```markdown
   ---
   description: "[One-line summary of the feature]"
   metadata:
     feature_name: "[BRANCH_NAME from step 1, without any slashes or special chars]"
     artifact_type: request
     # ONLY include epic_slug and slice_name when this is part of a multi-slice epic:
     # epic_slug: "<epic>"           # Epic folder name (for push to find registry)
     # slice_name: "<slice_name>"    # Slice folder name (for display purposes)
     created_timestamp: "[GENERATE: Current date/time in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ]"
     created_by_git_user: "[Run: git config user.name - extract the result here]"
     input_summary:
       - "[Key goal 1 from user request]"
       - "[Key goal 2]"
       - "[Key goal 3]"
       - "[Continue with 5-10 total key goals extracted from the request]"
   ---

   # Request

   [Rest of the request content here - see detailed instructions below]
   ```

   **Metadata Field Details:**
   - `feature_name`: Extract from BRANCH_NAME (e.g., if BRANCH_NAME is "auth-v2", use "auth-v2")
   - `epic_slug`: **ONLY for multi-slice epics** - The epic folder name under `specs/epics/` (used by `/gbm.push` to find registry)
   - `slice_name`: **ONLY for multi-slice epics** - The slice folder name under `specs/epics/<epic>/` (for display purposes)
   - `created_timestamp`: Generate current timestamp in ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)
   - `created_by_git_user`: Get from `git config user.name` - use the git username (not email)
   - `input_summary`: **CRITICAL - Extract 5-10 key points ONLY from the USER REQUEST input (not from artifact content):**
     * Review the original user input after `/gbm.request` command
     * Extract the main goals/requirements the user explicitly mentioned
     * Example: If user said "build task manager with tagging support" → extract "Provide tagging functionality for task organization"
     * Example: If user said "simple HTML interface" → extract "Simple, intuitive HTML-based user interface"
     * **IF user provided NO input**: This should NOT happen - the validation gate above should have blocked execution. If you reach this point with empty input, STOP and ask for clarification.
     * DO NOT extract from the ## Goals section you wrote - that's artifact content
     * Extract ONLY what the user asked for in their original input
     * Match user intent, not specification details

   **Required Actions:**
   a) **Fill in metadata frontmatter** (CRITICAL):
      - `description`: One-line summary of what the feature does
      - `feature_name`: Extracted from BRANCH_NAME
      - `created_timestamp`: Current ISO 8601 format
      - `created_by_git_user`: From git config
      - `input_summary`: Key goals extracted below (step c)

   b) **Fill in Summary section**:
      - Write 2-4 sentences summarizing the user's request in plain language
      - Use the exact text the user provided after `/gbm.request`

   c) **Add Epic & PR Slice Context (PR-Friendly Incremental Delivery)**:
      - Add a section in request.md:
        * `## Epic & PR Slice (Incremental Delivery)`
        * Include: Epic Link (optional), Epic Name (optional), PR Slice (`standalone` or `N/M`), Depends On (if this PR requires another)
        * Include two explicit lists:
          - `This PR Delivers (In-Scope)`
          - `Deferred to Future PRs (Out of Scope)`
      **MUTUAL EXCLUSION RULE (MANDATORY)**:
      - `PR Slice: standalone` and `Deferred to Future PRs` with items are **mutually exclusive**
      - If you identify work to defer → you MUST use `PR Slice: 1/N` and create epic structure (Step 5A-5G)
      - If user insists on "single PR" → `Deferred to Future PRs` MUST be empty or contain only "None - standalone feature"

      **Decision Logic**:
      - **Truly standalone** (no future PRs planned): Set `PR Slice: standalone`, leave Deferred empty
      - **Has deferred work** (PR-2, PR-3 identified): Set `PR Slice: 1/N`, create epic + slice-registry.yaml via Step 5A-5G
      - **User insists single PR but scope is large**: Require "Why One PR" justification AND remove deferred items (include all work in scope)

      **⛔ HARD STOP GATE (before writing request.md)**:
      Before finalizing request.md, verify:
      ```
      IF (Deferred contains PR-2, PR-3, or similar future PR references)
        AND (PR Slice = "standalone" OR no epic structure exists)
      THEN:
        ❌ STOP - DO NOT WRITE request.md
        → Go back to Step 5A-5G and create epic + slice-registry.yaml first
        → Change PR Slice to "1/N"
        → Only then proceed to write request.md
      ```
      This gate prevents the contradictory state where deferred PRs exist without epic tracking.

      - **Tip**: For multi-slice epics, use `<epic>--<slice>` branch naming (e.g., `git checkout -b user-auth--backend-api`) and run `/gbm.request`. The slice registry will track all slices.

      **Include PR Scope Assessment (MANDATORY)**:
      - Copy the scope assessment box from step 5 into request.md under this section
      - This persists the scope evaluation for audit trail and future reference
      - Example in request.md:
        ```markdown
        ## Epic & PR Slice (Incremental Delivery)

        | Field | Value |
        |-------|-------|
        | Epic Link | (none) |
        | PR Slice | standalone |
        | Depends On | (none) |

        ### PR Scope Assessment
        - **Concerns**: 2 (Backend API, Database models)
        - **Est. LoC**: 350
        - **Status**: ✅ Within guidelines

        ### This PR Delivers (In-Scope)
        - [items]

        ### Deferred to Future PRs (Out of Scope)
        - None - standalone feature
        ```

      **Example for multi-slice epic (has deferred work)**:
        ```markdown
        ## Epic & PR Slice (Incremental Delivery)

        | Field | Value |
        |-------|-------|
        | Epic Link | (none) |
        | PR Slice | 1/3 |
        | Depends On | (none) |

        ### This PR Delivers (In-Scope)
        - Backend API implementation

        ### Deferred to Future PRs (Out of Scope)
        - PR-2: Frontend UI implementation
        - PR-3: Integration tests and polish
        ```
        Note: When PR Slice is `1/N`, an epic structure with slice-registry.yaml MUST be created.

      **If scope exceeded guidelines in step 5** and user chose to continue:
      - Include "Why One PR" justification in request.md:
        ```markdown
        ### Why One PR (Justification)
        [User's justification for not splitting - e.g., "atomic migration", "tightly coupled"]
        ```

      **If part of multi-slice epic** (slice registry was created in Step 5):
      - Include Slice Registry reference in request.md:
        ```markdown
        ### Slice Registry
        - **Registry**: `$REGISTRY_ROOT/.gobuildme/specs/epics/<epic>/slice-registry.yaml`
        - **This Slice**: <slice_name> (PR-N of M)
        - **Next Slice**: <next_slice_name> (<scope summary from registry>)
        ```

   d) **Create User Goals list** (IMPORTANT - automatically extracted for audit trail):
      - Extract 5-10 specific, measurable goals from the user's request
      - These goals MUST also appear in the `input_summary` array in frontmatter
      - Format in markdown as: ## Goals followed by bullet points (- [goal description])
      - Focus on WHAT the user wants to achieve, not HOW
      - Examples:
        * Enable users to sign in with email/password
        * Support OAuth with Google and GitHub
        * Implement MFA for sensitive operations
        * Support 100K concurrent users
      - Make sure goals are specific and avoid vague statements like "make it secure" or "improve performance"
      - DO NOT include: API keys, secrets, internal IPs, or personal information (emails, phone numbers)

   e) **Define Non-Goals**:
      - Explicitly list what is NOT part of this request
      - Help scope the feature appropriately

   f) **List Assumptions**:
      - Document any assumptions you're making about the request
      - Note technical or business assumptions

   g) **Generate Open Questions**:
      - Create targeted clarifying questions that resolve ambiguities
      - Focus on questions that would help create a better specification

   h) **Gather References**:
      - Ask user: "Do you have any technical documentation, Confluence pages, design docs, or API documentation I should reference?"
      - Record all provided URLs in the References section:
        * Confluence pages
        * JIRA/ticket links
        * API documentation
        * Design documents
        * Internal wikis or technical docs
      - Do NOT fetch content at this stage - just record the references
      - The specify phase will load and process these documents

7) **Save the completed request** to REQUEST_FILE. Print its path and the branch name.

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
8) Track command complete and trigger auto-upload:
   - Prepare results JSON per schema `$GBM_ROOT/.gobuildme/docs/technical/telemetry-schemas.md#gbm-request` (include error details if command failed)
   - Run `$GBM_ROOT/.gobuildme/scripts/bash/post-command-hook.sh --command "gbm.request" --status "success|failure" --command-id "$command_id" --feature-dir "$SPEC_DIR" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
   - This handles both telemetry tracking AND automatic spec upload (if enabled in manifest)
   - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

## Optional: Spec Repository Upload

After creating `request.md` and `persona.yaml`, you can optionally upload the spec directory:

→ `/gbm.upload-spec` - Upload specs to S3 for cross-project analysis and centralized storage

*Requires AWS credentials. Use `--dry-run` to validate access first.*

Next Steps (always print at the end, persona-aware):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit `$FEATURE_DIR/request.md` to refine description
- Provide additional context, constraints, or requirements
- Re-run `/gbm.request` with a more detailed description

---

**Recommended Next Steps:**

1) **Load context**:
   - Persona: `$FEATURE_DIR/persona.yaml` → `feature_persona`
   - Architecture: Search `$ARCHITECTURE_DIRS` for architecture docs (checked in step 3)

2) **Next command**:
   - **Product Manager** → Consider `/gbm.pm.discover` for user research, then `/gbm.specify`
   - **All other personas** → `/gbm.specify` then continue SDD workflow

3) **Specify focus by persona** (lookup driver persona, show relevant focus):
   | Persona | Key sections in /gbm.specify |
   |---------|------------------------------|
   | Backend/Fullstack | API contracts, data model, migrations |
   | Frontend | Components, state management, UX flows |
   | Data Engineer | Data sources, SLAs, retention, DQ rules |
   | ML Engineer | Model requirements, training data, metrics |
   | Data Scientist | Analysis methodology, validation approach |
   | Architect | Architectural constraints, NFRs, quality attributes |
   | Security / Compliance | Threat model, data classification, compliance |
   | SRE | SLOs, SLIs, error budgets, observability |
   | Maintainer | Technical debt, refactoring goals |

   **Note**: QA Engineer persona typically uses `/gbm.qa.scaffold-tests` workflow, not `/gbm.request`.
   If QA is driver for a testing-focused feature, specify test coverage requirements.

4) **Output example** (lookup persona, show appropriate guidance):
   ```
   📋 Feature Request Created

   Feature: user-authentication
   Persona: backend_engineer
   File: .gobuildme/specs/user-authentication/request.md

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Next: /gbm.architecture (existing codebase, docs missing)
   Then: /gbm.specify (API contracts, data model)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

