---
description: "Execute the implementation plan by processing and executing all tasks defined in tasks.md. Updates tasks.md to mark implementation tasks (Phases 2-7) as complete."
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
artifacts:
  - path: ".docs/implementations/<feature>/implementation-summary.md"
    description: "Concise implementation documentation with change summary, design decisions, and deployment notes"
  - path: "$FEATURE_DIR/tasks.md"
    description: "Updated task breakdown with completion markers ([x]) for all implemented tasks"
  - path: "$FEATURE_DIR/logs/implementation-details.md"
    description: "Full implementation details: verbose logs, complete diffs, raw command output (Tier 2 detail artifact)"
---

## Output Style Requirements (MANDATORY)

**Code Output**:
- Max 1 comment per 10 lines of code - prefer self-documenting names
- No "obvious" comments (e.g., `// increment counter` for `counter++`)
- No redundant docstrings that repeat function signatures
- No boilerplate scaffolding unless required by framework
- Minimal viable implementation - avoid over-engineering

**Documentation Output**:
- 3-5 bullets per section (more only if gates require)
- One-sentence section intros - no multi-paragraph preambles
- Tables over prose for comparisons and options
- Action-first language ("Run X" not "You should run X")
- No restating instructions or motivational language

**Implementation Summary**:
- Brief descriptions (1-2 sentences per item)
- File changes as table, not prose
- Design decisions: state decision and rationale only
- Deployment notes: actionable steps only

**Two-Tier Output Enforcement (Issue #51)**:
- **Progress summary first**: "X/Y tasks complete" or "Phase N: status" before any details
- Do NOT paste raw logs, full diffs, or verbose command output to CLI
- Write verbose details to: `$FEATURE_DIR/logs/implementation-details.md`
- CLI shows: progress summary + task table + "Full details: `<path>`"
- Max 5 items per list; if more → "See `$FEATURE_DIR/logs/implementation-details.md` for N more"
- Max 30 lines inline code; longer → write to file and reference path

## Artifact Organization Strategy

**Development vs. Public Documentation**:

The GoBuildMe workflow organizes artifacts into two distinct locations:
For complete style guidance, see .gobuildme/templates/_concise-style.md


1. **`$FEATURE_DIR/`** — Internal Development Artifacts
   - `request.md` — Feature request and scope
   - `spec.md` — Detailed specifications and acceptance criteria
   - `plan.md` — Implementation plan and technology decisions
   - `tasks.md` — Task breakdown with completion tracking
   - `docs/technical/architecture/` — Feature-specific architecture context
   - These artifacts are used during development for reference and validation

2. **`.docs/implementations/<feature>/`** — Public Implementation Documentation
   - `implementation-summary.md` — Concise change documentation for PR/release
   - This artifact is PUBLIC-FACING (included in PR description, release notes, etc.)
   - Separated from internal development artifacts to keep user-facing docs organized
   - Easier for stakeholders/users to find what changed and why

**Why This Split?**
- **Clarity**: Internal specs stay in `.gobuildme/` (tool-managed); public docs in `.docs/` (user-accessible)
- **Scope**: Stakeholders don't need to see all internal development decisions, just final outcome
- **Reuse**: Implementation summary becomes release notes and PR documentation
- **Scalability**: As `.docs/` grows with user guides, examples, APIs, the implementations remain in a logical subsection

The `/gbm.implement` command creates both: internal task tracking updates AND the public implementation summary.

---

## Step 0: Orientation (MANDATORY — DO THIS FIRST)

Before ANY work, establish context by running these commands:

```bash
# 1. Resolve repo root (works from any subdirectory)
# Try git first, fallback to searching for .gobuildme/manifest.json
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  # Non-git project: search upward for .gobuildme/manifest.json
  dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.gobuildme/manifest.json" ]; then
      REPO_ROOT="$dir"
      break
    fi
    dir=$(dirname "$dir")
  done
fi
[ -z "$REPO_ROOT" ] && REPO_ROOT="$PWD"
cd "$REPO_ROOT"

# 2. Verify GoBuildMe project structure
if [ -d "$REPO_ROOT/.gobuildme/specs/" ]; then
    ls -la "$REPO_ROOT/.gobuildme/specs/"
else
    echo "No specs directory yet (run /gbm.request first)"
fi

# 3. Read progress notes (CRITICAL) — tolerant of missing file
cat "$FEATURE_DIR/verification/gbm-progress.txt" 2>/dev/null || echo "No progress file yet"

# 4. Review git history
if git rev-parse --git-dir >/dev/null 2>&1; then
    git log --oneline -15
else
    echo "Not a git repository - skipping git history"
fi

# 5. Load task status
cat "$FEATURE_DIR/tasks.md" 2>/dev/null | head -100

# 6. Count remaining work
grep -c "^\- \[ \]" "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0"
```

**DO NOT proceed until you understand**:
- What was completed in previous sessions
- What task you should work on next
- Any blockers or issues to be aware of

**If progress notes exist**: Resume from where the previous session left off.
**If no progress notes**: This is the first session — proceed normally and create progress notes at session end.

---

## Step 0.1: Feature Focus (MANDATORY — After Orientation)

**CRITICAL**: Work on ONE feature per session. Do not switch features mid-session.

1. **Identify current feature** from command context or progress notes:
   ```bash
   # Feature should be clear from:
   ls "$REPO_ROOT/.gobuildme/specs/"
   cat "$FEATURE_DIR/verification/gbm-progress.txt" 2>/dev/null | head -5
   ```

2. **Confirm feature scope**:
   - Read `$FEATURE_DIR/request.md` for scope
   - Read `$FEATURE_DIR/tasks.md` for remaining work
   - Count tasks: `grep -c "^- \[ \]" "$FEATURE_DIR/tasks.md"`

3. **DO NOT work on other features**:
   - If you notice issues in other features, document them but don't fix
   - Stay focused on the current feature until all tasks complete
   - Only switch features after explicit user request

**Why this matters**: Prevents scope creep and premature victory declarations.

---

## Step 0.2: Branch Guard (MANDATORY — Before Any Commits)

**CRITICAL**: GoBuildMe prevents commits to protected branches (main, master, develop, etc.).

Run this check ONCE at session start to confirm you're on a feature branch:

**Bash**:
```bash
# Validate not on protected branch - BLOCKS if on main/master/develop
.gobuildme/scripts/bash/guard-protected-branch.sh
```

**PowerShell**:
```powershell
# Validate not on protected branch - BLOCKS if on main/master/develop
.gobuildme/scripts/powershell/guard-protected-branch.ps1
```

**If this fails**:
1. You are on a protected branch (e.g., `main`)
2. Create a feature branch: `git checkout -b <feature-name>`
3. **DO NOT proceed with implementation until on a feature branch**

**Why this matters**: The harness system requires frequent commits. Without this guard, commits would land on main, causing the issues users reported.

**Inline usage** (before each commit in this template):
- Bash: `.gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1`
- PowerShell: `.gobuildme/scripts/powershell/guard-protected-branch.ps1 -Quiet; if ($LASTEXITCODE -ne 0) { exit 1 }`

---

## Step 0.5: Smoke Test (MANDATORY — Before Starting Work)

**Purpose**: Catch undocumented bugs from previous sessions before starting new work.

Run a quick health check:

```bash
# 1. Load dev environment commands from constitution (if exists)
# Source common.sh for workspace-aware path resolution
source "$REPO_ROOT/.gobuildme/scripts/bash/common.sh" 2>/dev/null || true
CONSTITUTION_PATH=$(get_constitution_path 2>/dev/null || echo "$REPO_ROOT/.gobuildme/memory/constitution.md")
if [ -f "$CONSTITUTION_PATH" ]; then
    echo "=== Dev Environment ==="
    grep -A 15 "## Development Environment" "$CONSTITUTION_PATH" 2>/dev/null || echo "No dev environment section"
fi

# 2. Detect and run project test command
if [ -f "$REPO_ROOT/package.json" ]; then
    echo "Running: npm test"
    npm test --passWithNoTests 2>/dev/null || echo "⚠️ Tests may be failing"
elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
    echo "Running: pytest collection check"
    pytest --co -q 2>/dev/null || echo "⚠️ Test collection may have issues"
elif [ -f "$REPO_ROOT/Makefile" ] && grep -q "^test:" "$REPO_ROOT/Makefile"; then
    echo "Running: make test"
    make test 2>/dev/null || echo "⚠️ Tests may be failing"
else
    echo "No standard test command detected - verify manually if needed"
fi
```

**If tests FAIL at session START**:
1. **DO NOT** proceed with new feature work
2. Check git log for recent changes that may have broken tests
3. Read progress notes for any documented issues
4. Fix the regression FIRST, then continue with planned work
5. Document the fix in progress notes

**If tests PASS**: Proceed with implementation.

**Why this matters**: Prevents building on broken foundation. Catches issues early when they're easier to fix.

---

The user input can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

**Script Output Variables**: The `{SCRIPT}` output above provides key paths. Parse and use these values:
- `FEATURE_DIR` - Feature directory path (e.g., `.gobuildme/specs/<feature>/` or `.gobuildme/specs/epics/<epic>/<slice>/`)
- `AVAILABLE_DOCS` - List of available documentation files in the feature directory

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.implement" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
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

   **Include persona partials** (if applicable):
   - For each persona in active_personas:
     * If `templates/personas/partials/<persona_id>/implement.md` exists:
       - Include its content under a `### <Persona Name> Implementation Guidelines` section
   - If no persona files exist, proceed as generalist

   **Error Handling**:
   - If participant persona file missing: Skip with warning, continue with remaining personas
   - If driver persona file missing: Fall back to default_persona
   - If no valid personas found: Proceed as generalist (no persona-specific guidance)

   **Note**: Implementation command doesn't merge required_sections or quality_gates.
   - Participants primarily affect next-step recommendations and implementation focus areas
   - Quality gates are enforced during /gbm.review and /gbm.push

3. Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

4. **Prerequisite Validation** (MANDATORY - BLOCKING):

   **CRITICAL**: You MUST verify that all prerequisite artifacts exist and prerequisite commands have been completed before proceeding with implementation.

   **Check Tasks File Exists**:
   - Verify `tasks.md` exists in FEATURE_DIR (from JSON output or AVAILABLE_DOCS)
   - Attempt to read the tasks file at `$FEATURE_DIR/tasks.md`
   - If file does not exist or is empty:
     * **BLOCK execution**: Do not proceed with implementation
     * **Error message**: "❌ Prerequisite missing: Task breakdown not found"
     * **Required action**: "Run `/gbm.tasks` to generate the task breakdown first"
     * **Exit**: Stop processing and wait for user to run `/gbm.tasks`

   **Check Implementation Plan Exists**:
   - Verify `plan.md` exists in FEATURE_DIR (from AVAILABLE_DOCS)
   - Attempt to read the plan file at `$FEATURE_DIR/plan.md`
   - If file does not exist or is empty:
     * **BLOCK execution**: Do not proceed with implementation
     * **Error message**: "❌ Prerequisite missing: Implementation plan not found"
     * **Required action**: "Run `/gbm.plan` to create the implementation plan first"
     * **Exit**: Stop processing and wait for user to run `/gbm.plan`

   **Check Analysis Completion** (RECOMMENDED):
   - Read `tasks.md` to check if Phase 1 (Analysis) tasks are marked complete
   - Look for Analysis phase tasks (A1, A2, A3) and verify they are marked `[x]` not `[ ]`
   - If Analysis tasks are incomplete:
     * **WARNING**: "⚠️ Phase 1 Analysis tasks incomplete. Running `/gbm.analyze` first ensures consistency."
     * **Recommendation**: "Run `/gbm.analyze` to validate plan artifacts before implementation"
     * **User Decision Required**:
       - Option A (RECOMMENDED): "PAUSE and run `/gbm.analyze` to validate artifacts"
       - Option B: "Proceed with implementation (user explicitly overrides)"
     * **If user chooses Option A**: BLOCK and wait for `/gbm.analyze` completion
     * **If user chooses Option B or overrides**: Continue but note validation risk

   **Validate Task Quality**:
   - Check if tasks.md has actual implementation tasks (not just placeholders)
   - Verify tasks have file paths and specific descriptions
   - Check for task dependency markers and parallel execution flags [P]
   - If tasks appear to be generic templates without specifics:
     * **WARNING**: "⚠️ Tasks appear incomplete. Consider regenerating with `/gbm.tasks`"
     * Recommend task refinement before proceeding

   **Success Path**:
   - If tasks.md, plan.md exist and analysis is complete → Proceed to Architecture Context Loading

5. **Load All Available Context** (for implementation):

   **5a. Feature-Specific Artifacts** (from request/specify/clarify/plan/tasks phases):
   - `$FEATURE_DIR/tasks.md` - **REQUIRED** - Complete task list and execution plan
   - `$FEATURE_DIR/plan.md` - **REQUIRED** - Tech stack, architecture, and file structure
   - `$FEATURE_DIR/spec.md` - Feature specification with requirements and acceptance criteria
   - `$FEATURE_DIR/request.md` - Original user request and assumptions (for context)
   - `$FEATURE_DIR/data-model.md` - Entity definitions and relationships (if exists)
   - `$FEATURE_DIR/contracts/` - API specifications and test requirements (if exists)
   - `$FEATURE_DIR/research.md` - Technical decisions and constraints (if exists)
   - `$FEATURE_DIR/quickstart.md` - Integration scenarios (if exists)
   - `$FEATURE_DIR/docs/references/` - External documentation summaries (if exists)
     * Confluence pages, technical docs, API specs, design docs
     * Fetched during specify phase via WebFetch
     * Non-blocking if directory doesn't exist or is empty

   **5b. Architecture Documentation** (MANDATORY for existing codebases):

   **Root Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_architecture_dirs()` to get ordered list of architecture directories
   - Search order: module-level first → workspace/monorepo root second
   - Example: In monorepo module, checks `apps/api/.gobuildme/docs/technical/architecture/` then `<root>/.gobuildme/docs/technical/architecture/`

   **Architecture files to load** (from each discovered architecture directory):
   - `system-analysis.md` - Architectural patterns, decisions, architectural style
   - `technology-stack.md` - Languages, frameworks, libraries, and versions
   - `security-architecture.md` - Auth patterns, security controls, security requirements
   - `integration-landscape.md` - External service integrations (if exists)
   - `$FEATURE_DIR/docs/technical/architecture/feature-context.md` - Feature-specific architectural context (if exists)

   **BLOCKING**: If codebase exists but no architecture files found in any searched directory:
   - Stop execution
   - Display: "❌ Architecture documentation required. Run `/gbm.architecture` first."
   - Do not proceed until documentation exists

   **Skip for**: New/empty projects with no existing source code.

   **5c. Governance & Principles** (NON-NEGOTIABLE):

   **Constitution Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_constitution_path()` to get constitution location
   - Constitution is ALWAYS at workspace/monorepo root (not per-module)

   - Constitution file contains organizational rules, security requirements, architectural constraints
   - **CRITICAL**: Constitution defines non-negotiable principles that MUST be enforced during implementation
   - Constitutional constraints override user preferences and implementation decisions
   - Any implementation that conflicts with constitution must be rejected or revised

6. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

6a. **Verify Ignore Files** (MANDATORY):
   - **REQUIRED**: Run the ignore file verification script to automatically detect and create missing ignore files
   - **Script**: Run `.gobuildme/scripts/bash/verify-ignore-files.sh` (bash) or `.gobuildme/scripts/powershell/verify-ignore-files.ps1` (PowerShell)

   **What the script does**:
   - **Technology Detection**: Automatically detects project technologies (Node.js, Python, Java, C#, Go, Docker, Terraform, Helm)
   - **Ignore File Creation**: Creates missing ignore files with appropriate patterns for detected stack
   - **Preservation**: Only creates files that don't exist - never overwrites existing ignore files

   **Supported Ignore Files**:
   - `.gitignore` - Version control (always created if Git repo detected)
   - `.dockerignore` - Container builds (if Dockerfile detected)
   - `.eslintignore` - JavaScript linting (if `.eslintrc*` detected; for `eslint.config.*` flat configs, use built-in `ignores` array instead)
   - `.prettierignore` - Code formatting (if Prettier config detected)
   - `.npmignore` - npm publishing (if publishable package.json detected)
   - `.terraformignore` - Infrastructure as Code (if *.tf files detected)
   - `.helmignore` - Kubernetes Helm charts (if Chart.yaml detected)

   **Technology-Specific Patterns**:
   - **Node.js/JavaScript**: `node_modules/`, `dist/`, `build/`, `.npm`, `.eslintcache`, `*.log`
   - **Python**: `__pycache__/`, `*.pyc`, `venv/`, `.pytest_cache/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `.gradle/`, `*.jar`, `*.war`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `.vs/`, `packages/`
   - **Go**: `vendor/`, `*.exe`, `*.test`, `*.out`, `go.work`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.swp`, `.vscode/`, `.idea/`, `.env*`

   **Manual Override**: If the script doesn't detect technologies correctly, you can manually create ignore files with appropriate patterns

---

## CRITICAL: Single-Task Execution Policy

### Rule: ONE TASK → ONE COMMIT → VERIFY → REPEAT

You MUST follow this atomic execution pattern for EACH task:

1. **SELECT**: Pick exactly ONE task from tasks.md
   - Announce: "Working on Task X.Y: <description>"
   - DO NOT plan to do multiple tasks at once

2. **IMPLEMENT**: Complete only this task
   - Write tests first (TDD)
   - Implement the feature
   - Make tests pass

3. **VERIFY**: Run verification for THIS task only
   - All tests pass
   - Linter passes
   - Type check passes (if applicable)

4. **COMMIT**: Create atomic commit (with branch guard)
   ```bash
   # Verify not on protected branch (Step 0.2 should have already validated this)
   .gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1
   git add -A
   git commit -m "feat(<feature>): task X.Y - <description>"
   ```

5. **UPDATE**: Mark task complete in tasks.md
   - Change `- [ ]` to `- [x]`

6. **CHECK CONTEXT**: Before starting next task
   - If conversation is getting long (>50 exchanges), update progress notes and STOP
   - If unsure, err on the side of stopping with clean state

### ❌ NEVER DO THIS:
- "I'll implement tasks 1-5 in this session"
- "Let me batch these related tasks together"
- "I'll commit everything at the end"

### ✅ ALWAYS DO THIS:
- "Starting Task 2.1: Create user model"
- "Task 2.1 complete. Committing now."
- "Checking context usage... proceeding to Task 2.2"

**Why this matters**: Each task completion = working commit = safe rollback point. If context exhausts, code is in clean state.

---

## CRITICAL: Scope Enforcement (Prevents Unrelated Changes)

### Rule: ONLY modify files listed in scope.json (preferred) or explicitly mentioned in tasks.md/plan.md (fallback)

**Before modifying ANY file, verify it's in scope:**

1. **Load scope.json and understand path normalization** (do this once at start):
   - If `scope.json` exists, it is the single source of truth.
   - Do NOT re-derive scope from regex when scope.json is present.
   - **Path Format**: scope.json paths follow the format specified by `registry_mode`:
     * `local`: Repo-relative paths (e.g., `src/auth/handler.py`)
     * `cross_module`: Module-relative paths (e.g., `src/handler.py` within `apps/api-service`)
     * `cross_repo`: Workspace-relative paths (e.g., `api-repo/src/handler.py`)

   ```bash
   SCOPE_JSON="$FEATURE_DIR/scope.json"
   export SCOPE_JSON
   if [ -f "$SCOPE_JSON" ] && command -v python3 >/dev/null 2>&1; then
     python3 - <<'PY'
import json, os
path = os.environ["SCOPE_JSON"]
with open(path) as f:
  data = json.load(f)

# Display scope configuration
files = sorted(set(data.get("allowed_files", [])))
patterns = sorted(set(data.get("allowed_patterns", [])))
excludes = sorted(set(data.get("excludes", [])))

# Path normalization context
registry_mode = data.get("registry_mode", "local")
module_path = data.get("module_path")
repo_path = data.get("repo_path")
scope_precision = data.get("scope_precision", "unknown")

print(f"Scope Configuration:")
print(f"  Registry Mode: {registry_mode}")
print(f"  Scope Precision: {scope_precision}")
if module_path:
    print(f"  Module Path: {module_path}")
if repo_path:
    print(f"  Repo Path: {repo_path}")
print(f"\nAllowed files ({len(files)}):")
for f in files[:10]:  # Show first 10
    print(f"  {f}")
if len(files) > 10:
    print(f"  ... and {len(files) - 10} more")
print(f"\nAllowed patterns ({len(patterns)}):")
print("\n".join(f"  {p}" for p in patterns))
print(f"\nExcludes ({len(excludes)}):")
print("\n".join(f"  {e}" for e in excludes))
PY
   elif [ -f "$SCOPE_JSON" ]; then
     echo "⚠️ scope.json present but python3 not available. Falling back to tasks.md/plan.md extraction."
   else
     echo "⚠️ scope.json not found. Falling back to tasks.md/plan.md extraction."
   fi
   if [ ! -f "$SCOPE_JSON" ] || ! command -v python3 >/dev/null 2>&1; then
     # Extract file paths from tasks.md and plan.md (inline or backticked)
     # Covers: web (ts/js/vue/svelte), backend (py/go/java/rb/rs/kt), config (yaml/json/toml),
     # scripts (sh/ps1), data (sql/prisma/graphql), infra (tf/hcl/dockerfile), docs (md/mdx)
     # Also handles: @ in paths (src/@types/), files without extensions (Dockerfile, Makefile)
     ALLOWED_FILES=$(grep -ohE '([A-Za-z0-9_@./-]+\.(ts|tsx|js|jsx|vue|svelte|py|go|java|kt|rb|rs|md|mdx|yaml|yml|json|sh|ps1|toml|sql|prisma|proto|graphql|tf|hcl|css|scss|html|dockerfile|containerfile|env|env\.[a-z]+))' \
       "$FEATURE_DIR/tasks.md" \
       "$FEATURE_DIR/plan.md" 2>/dev/null | \
       tr -d '`' | sort -u)
     # Also extract extensionless files (Dockerfile, Makefile, etc.)
     EXTENSIONLESS=$(grep -ohE '\b(Dockerfile|Containerfile|Makefile|Gemfile|Procfile|Brewfile)\b' \
       "$FEATURE_DIR/tasks.md" \
       "$FEATURE_DIR/plan.md" 2>/dev/null | sort -u)
     ALLOWED_FILES=$(printf "%s\n%s" "$ALLOWED_FILES" "$EXTENSIONLESS" | grep -v '^$' | sort -u)
     echo "Allowed files for this feature:"
     echo "$ALLOWED_FILES"
     if [ -z "$ALLOWED_FILES" ]; then
       echo "⚠️ No file paths detected. Add explicit paths to tasks.md before editing."
     fi
   fi
   ```

2. **Before each file modification, check scope**:
   - If scope.json exists: is the file in `allowed_files` or matching `allowed_patterns`? → ✅ Proceed
   - If scope.json is missing: is the file listed in tasks.md or plan.md? → ✅ Proceed
   - Is this a NEW file explicitly required by a task? → ✅ Proceed
   - Is this a configuration file for a dependency being added? → ✅ Proceed with warning
   - Is this an unrelated file? → ❌ **DO NOT MODIFY**

3. **If you find yourself wanting to modify an unrelated file**:
   - **STOP** - this is scope creep
   - Ask yourself: "Is this required for the current feature?"
   - If truly needed, add it to tasks.md AND update scope.json first, then modify
   - If it's a "nice to have" improvement, **defer it** to a future task

### Pre-Commit Scope Check (MANDATORY)

Before EVERY commit, run:
```bash
# Show what's about to be committed
git diff --staged --name-only

# If scope.json exists, validate staged files against it AND track touched_files
SCOPE_JSON="$FEATURE_DIR/scope.json"
export SCOPE_JSON
if [ -f "$SCOPE_JSON" ] && command -v python3 >/dev/null 2>&1; then
  python3 - <<'PY'
import json, os, subprocess, sys
from pathlib import Path
from datetime import datetime

with open(os.environ["SCOPE_JSON"]) as f:
  scope = json.load(f)

allowed = set(scope.get("allowed_files", []))
patterns = scope.get("allowed_patterns", [])
excludes = scope.get("excludes", [])

# Path normalization based on registry_mode
registry_mode = scope.get("registry_mode", "local")
module_path = scope.get("module_path")
repo_path = scope.get("repo_path")

def normalize_path(file_path):
    """Normalize git diff path (repo-relative) to scope path format."""
    if registry_mode == "cross_module" and module_path:
        # Strip module_path prefix from repo-relative path
        if file_path.startswith(module_path + "/"):
            return file_path[len(module_path) + 1:]
    elif registry_mode == "cross_repo" and repo_path:
        # Prefix repo_path to repo-relative path
        return f"{repo_path}/{file_path}"
    # local mode: no normalization needed
    return file_path

def is_excluded(path):
    """Check if path matches any exclude pattern."""
    p = Path(path)
    return any(p.match(pattern) for pattern in excludes)

def matches(path):
    """Check if path matches any allowed pattern."""
    p = Path(path)
    return any(p.match(pattern) for pattern in patterns)

staged = subprocess.check_output(["git", "diff", "--staged", "--name-only"], text=True).splitlines()
staged = [f for f in staged if f]  # Filter empty lines

violations = []
in_scope_files = []

for file in staged:
    normalized = normalize_path(file)

    # Check excludes first (explicit deny takes priority)
    if is_excluded(normalized):
        violations.append(f"{file} (excluded by pattern)")
        continue

    # Check allowed_files and allowed_patterns
    if normalized in allowed or matches(normalized):
        in_scope_files.append(file)
    else:
        violations.append(file)

# Update touched_files in scope.json
existing_touched = set(scope.get("touched_files", []))
new_touched = existing_touched.union(set(in_scope_files))
scope["touched_files"] = sorted(list(new_touched))
scope["updated_at"] = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

# Record violations if any
if violations:
    existing_violations = scope.get("violations", [])
    for v in violations:
        if v not in existing_violations:
            existing_violations.append(v)
    scope["violations"] = existing_violations
    scope["last_validated"] = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

# Write updated scope.json
with open(os.environ["SCOPE_JSON"], 'w') as f:
    json.dump(scope, f, indent=2)

if violations:
    print("⚠️ Out-of-scope files in commit:")
    print("\n".join(f"  {v}" for v in violations))
    print(f"\nℹ️  {len(in_scope_files)} files are in scope, {len(violations)} files are out of scope")
    print("Updated scope.json with touched_files and violations.")
    sys.exit(1)
else:
    print(f"✅ All {len(in_scope_files)} staged files are within scope")
    print("Updated scope.json with touched_files.")
PY
elif [ -f "$SCOPE_JSON" ]; then
  echo "⚠️ scope.json present but python3 not available. Manually verify staged files against scope.json."
else
  # Compare against allowed files - any unexpected files?
  # If YES: Unstage them with `git reset HEAD <file>`
  true
fi
```

### ❌ SCOPE VIOLATIONS (Never do these):
- "While I'm here, let me also refactor this other file..."
- "I noticed a bug in an unrelated file, let me fix it..."
- "This import isn't being used, let me clean it up..."
- Modifying files not listed in scope.json (or tasks.md/plan.md if scope.json is missing)

### ✅ STAYING IN SCOPE:
- Only modify files listed in scope.json (or tasks.md if scope.json is missing)
- Create only files explicitly required by tasks
- If you must touch an unrelated file, document WHY in the commit message
- Defer "improvements" to separate features

**Why this matters**: Unrelated changes cause review confusion, increase merge conflicts, and make rollbacks harder. Stay focused on the feature at hand.

---

## CRITICAL: Validation Gates (Must Pass Before Marking Complete)

### Rule: Run lint + tests BEFORE marking any task complete (with TDD exceptions)

**Identify if task is in RED phase**: A task is in RED phase if it's from the "Test Files" or "Testing" phase in tasks.md, AND you're writing tests BEFORE implementation exists.

**After completing each task, BEFORE marking it `[x]`:**

1. **Determine phase type**:
   - **RED phase task** (writing tests before implementation): Go to step 2a
   - **GREEN/REFACTOR phase task** (implementation or refactoring): Go to step 2b

2a. **RED phase validation** (test-writing tasks only):
   - Run the smallest relevant test command for the file(s) you just wrote
   - **Expected outcome**: tests fail for the right reasons (missing implementation)
   - Record the expected failure in progress notes
   - ✅ Tests failing as expected → Mark task complete, proceed to GREEN phase
   - ❌ Tests passing → Something is wrong (implementation exists or test is trivial)

2b. **GREEN/REFACTOR phase validation** (implementation tasks):
   - Run the linter:
     ```bash
     # Detect and run project linter
     if [ -f "$REPO_ROOT/package.json" ]; then
         npm run lint 2>/dev/null || npx eslint . 2>/dev/null || echo "⚠️ No linter configured"
     elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
         ruff check . 2>/dev/null || python -m flake8 . 2>/dev/null || echo "⚠️ No linter configured"
     elif [ -f "$REPO_ROOT/go.mod" ]; then
         golangci-lint run 2>/dev/null || go vet ./... 2>/dev/null || echo "⚠️ No linter configured"
     fi
     ```
   - 🟢 **Linter passes** → Continue to step 3
   - 🔴 **Linter fails** → Fix issues, do NOT mark task complete

3. **Run the tests** (GREEN/REFACTOR phase only):
   ```bash
   # Detect and run project tests
   if [ -f "$REPO_ROOT/package.json" ]; then
       npm test
   elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
       pytest
   elif [ -f "$REPO_ROOT/go.mod" ]; then
       go test ./...
   elif [ -f "$REPO_ROOT/Makefile" ] && grep -q "^test:" "$REPO_ROOT/Makefile"; then
       make test
   fi
   ```
   - 🟢 **Tests pass** → Continue to step 4
   - 🔴 **Tests fail** → Fix implementation, do NOT mark task complete

4. **Only then mark the task complete**:
   - Update tasks.md: `[ ]` → `[x]`
   - Commit with appropriate state (RED: failing tests, GREEN/REFACTOR: passing)

### ❌ NEVER mark a task complete if:
- GREEN/REFACTOR task with linter failing
- GREEN/REFACTOR task with tests failing
- You haven't run the required checks for this task
- You're planning to "fix it later"

### ✅ Marking complete is OK when:
- RED phase: Tests fail for the right reasons (missing implementation)
- GREEN phase: Lint passes AND tests pass
- REFACTOR phase: Lint passes AND tests pass

**Why this matters**: This prevents "implementation complete but broken" scenarios while respecting the TDD cycle where RED phase tasks intentionally have failing tests.

---

7. **Execute implementation following the task plan with MANDATORY TDD discipline**:
   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order, parallel tasks [P] can run together
   - **MANDATORY TDD Execution**: RED → GREEN → REFACTOR cycle (not code-first)

   **RED Phase (Create Tests)** - From tasks.md Test Files Phase:
   - [ ] Create all test files with empty test cases
   - [ ] Write test code from test specifications in spec.md
   - [ ] Run tests - **EXPECT FAILURES (RED)** - this is correct for TDD
   - [ ] All tests fail because implementation doesn't exist yet - **THIS IS EXPECTED**
   - [ ] Do NOT implement code during this phase
   - [ ] Block if: Test tasks skipped or tests not created first

   **GREEN Phase (Implement Code)** - From tasks.md Implementation Phase:
   - [ ] Write implementation code to pass RED tests
   - [ ] Run tests after each component - **WATCH FOR RED → GREEN transition**
   - [ ] When test passes (GREEN), move to next component
   - [ ] Block if: Code written without corresponding tests passing
   - [ ] Block if: Tests modified to pass code (wrong direction - should be tests → code)
   - [ ] Never skip a failing test - debug implementation until it passes
   - [ ] **Update Verification Matrix** (if exists): When tests pass for an AC, update the corresponding verification item:
     * Set `"passes": true`
     * Set `"verified_at": "<ISO-8601-timestamp>"`
     * Set `"verification_evidence": "test_name (test_file.py) PASSED"`

   **REFACTOR Phase** - From tasks.md Refactoring Phase:
   - [ ] Improve code quality while keeping tests GREEN
   - [ ] Extract common patterns, optimize, improve readability
   - [ ] After each refactoring change, run tests
   - [ ] Block if: Tests fail after refactoring (revert refactoring)
   - [ ] Keep tests passing at all times during refactoring

   **Coverage Checkpoint** (during and after implementation):
   - [ ] Run coverage tool (pytest --cov, etc.)
   - [ ] Verify coverage ≥ 85% (or project threshold)
   - [ ] Block if: Code with 0% coverage (no tests)
   - [ ] Add missing tests if coverage drops below threshold

   **Additional TDD Rules**:
   - **Test fixtures (RECOMMENDED)**: Before starting TDD, check if test fixtures exist:
     * If `tests/fixtures/` directory is missing or empty, suggest running `/gbm.qa.generate-fixtures`
     * This auto-generates fixtures, factories, and mocks based on data-model.md and architecture
     * Fixtures make TDD faster and more consistent
     * User can skip if they prefer manual fixture creation
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Hierarchical task execution**: Complete parent tasks by finishing all their subtasks (1-1, 1-2 before marking 1 complete)
   - **Validation checkpoints**: Verify each phase completion before proceeding
   - **Inner loop runtime (optional)**: If DevSpace is detected (`devspace.yaml` present and CLI installed), prefer `devspace dev` for the inner loop and `devspace run <task>` when defined (e.g., `devspace run test`). Keep host fallbacks available.

5a. **Task Completion Tracking** (MANDATORY):
   - **After each task completion**: Update `$FEATURE_DIR/tasks.md` to mark the task as complete
   - **Change task marker**: `[ ]` → `[x]` for completed tasks
   - **Update immediately**: Mark tasks complete as soon as they're done, not at the end
   - **Verify completion**: Ensure the task marker is updated in the file
   - **Track progress**: Maintain accurate task completion status throughout implementation

   Example:
   ```markdown
   Before: - [ ] 1.1: Create User model with fields
   After:  - [x] 1.1: Create User model with fields
   ```

5b. **Command Execution Rules** (CRITICAL):
   **WHEN tasks.md specifies a command to execute, you MUST follow these rules:**

   ❌ **NEVER SUBSTITUTE COMMANDS**:
   - If task says: `./gradlew graphql-experience:test` → Run EXACTLY that command
   - **DO NOT** run: `./gradlew graphql-experience:compileKotlin` (compilation ≠ tests)
   - **DO NOT** run: `./gradlew build` (build ≠ tests)
   - **DO NOT** run: `./gradlew check` (unless specifically requested)

   ✅ **EXECUTE EXACT COMMANDS**:
   - Copy command from tasks.md character-for-character
   - Run the command as specified (no modifications)
   - Verify command output shows expected behavior

   🔍 **VERIFY COMMAND EXECUTION**:
   - **For test commands**: Verify output shows "X tests passed" or "X tests ran"
   - **For compilation**: Verify output shows "BUILD SUCCESSFUL" or "compilation complete"
   - **For build commands**: Verify artifacts are created
   - If command output doesn't match expected behavior → task is NOT complete

   ⛔ **CRITICAL BLOCKING RULE**:
   - **NEVER** mark a task complete if you ran a different command than specified
   - **NEVER** mark tests as passing if you only ran compilation
   - **NEVER** substitute `compileKotlin` for `test` or vice versa

   Examples of FORBIDDEN substitutions:
   - Task: "Run `npm test`" → You run: `npm build` ❌ **WRONG**
   - Task: "Run `./gradlew test`" → You run: `./gradlew compileJava` ❌ **WRONG**
   - Task: "Run `pytest tests/`" → You run: `python -m py_compile` ❌ **WRONG**

   **If you cannot run the exact command specified**, you MUST:
   1. Report: "Cannot execute command: [reason]"
   2. Ask user for guidance
   3. Do NOT mark task as complete
   4. Do NOT substitute with a different command

8. **Architecture-Aware Implementation Rules** (MANDATORY):
   - **Follow architectural patterns**: Implement code following established architectural patterns from global documentation
   - **Use technology stack**: Use technologies and frameworks from documented technology stack
   - **Respect security architecture**: Implement authentication and authorization following security architecture patterns
   - **Implement integration points**: Create integration code consistent with integration landscape
   - **Validate architectural boundaries**: Ensure code respects architectural boundaries and layering rules

   Validation cadence (non-destructive):
   - Run `scripts/bash/validate-architecture.sh` (or PowerShell twin) at phase boundaries (after Setup, Core, Integration) and before finalizing the feature.
   - If validation fails, fix violations or adjust design and re-run validation before proceeding.

   **Standard Implementation Rules**:
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: Write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

   **Architecture-Specific Implementation**:
   - **Pattern implementation**: Follow MVC, microservices, or other architectural patterns
   - **Security implementation**: Implement JWT, OAuth, RBAC, or other security patterns
   - **Integration implementation**: Follow established integration patterns and protocols
   - **Technology alignment**: Use frameworks and libraries consistent with technology stack

9. **Progress tracking, TDD blockers, and error handling**:
   - Report progress after each completed task
   - **TDD BLOCKER: Test failures are RED phase - expected and required**
     * RED phase: Tests MUST fail initially (implementation doesn't exist)
     * Not a failure condition - this is correct TDD behavior
     * Problem: Tests passing in RED phase (indicates test is wrong, not implementation)
   - **TDD BLOCKER: Code written without tests passing is BLOCKED**
     * Never implement code before tests exist for it
     * Never skip tests by modifying them to match broken code
     * Always implement code to pass tests, not tests to pass code
   - **TDD BLOCKER: Coverage below threshold is BLOCKED**
     * Verify coverage ≥ 85% (or project threshold)
     * Code with 0% coverage indicates missing tests
     * Add tests before proceeding, don't reduce coverage requirement
   - **TDD BLOCKER: Test failures in GREEN/REFACTOR phase**
     * If tests fail during GREEN phase, debug implementation (not tests)
     * If tests fail during REFACTOR phase, revert refactoring change
     * Tests must stay GREEN after each change
   - Halt execution if any non-parallel task fails (unless it's expected RED)
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **Task completion**: See step 6a for task tracking requirements

---

## Context Management: Proactive Session Boundaries

### Context Warning Signs

Monitor for these indicators during implementation:

| Warning Sign | Action |
|--------------|--------|
| >30 exchanges in conversation | Consider wrapping up current task |
| >50 tool calls made | Update progress notes, evaluate stopping |
| Complex debugging taking >10 exchanges | Commit current state, document issue |
| Feeling "rushed" or "behind" | STOP - this is context pressure |

### Proactive Checkpoints

After completing each task, ask yourself:

1. "Is this a good stopping point?" (Yes = clean commit exists)
2. "Could another agent resume from here?" (Yes = progress notes are current)
3. "Am I trying to rush to finish?" (Yes = STOP NOW)

### Early Exit Protocol

If context is running low:

1. **COMMIT** current work (even if incomplete)
   ```bash
   # Verify not on protected branch before committing
   .gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1
   git add -A
   git commit -m "wip(<feature>): partial progress on task X.Y"
   ```

2. **UPDATE** progress notes with detailed next steps
   - What was attempted
   - Where you got stuck (if applicable)
   - Exact next action for resuming agent

3. **STOP** cleanly
   - Do NOT try to squeeze in "one more task"
   - Better to stop early with clean state than crash mid-task

### ❌ NEVER:
- Push through when context feels limited
- Leave uncommitted changes when stopping
- Assume "I can finish quickly"

### ✅ ALWAYS:
- Err on the side of stopping early
- Leave clear breadcrumbs for next session
- Commit, commit, commit

---

10. Completion validation:
   - Verify all required tasks are completed
   - Check that implemented features match the original specification
   - Validate that tests pass and coverage meets requirements
   - Confirm the implementation follows the technical plan
   - Report final status with summary of completed work

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/gbm.tasks` first to regenerate the task list.

## Implementation Documentation (MANDATORY)

After completing all implementation tasks, you MUST create concise implementation documentation:

1. **Create Implementation Summary**: Generate `.docs/implementations/<feature>/implementation-summary.md` using the template at `templates/implementation-summary-template.md`

2. **Required Documentation Content**:
   - **Request Summary**: Extract from request.md with ticket references and stakeholder information
   - **Implementation Scope**: Document what was implemented vs. what was out of scope
   - **Design Decisions**: Record all architectural and technical decisions made during implementation
   - **Architecture Impact**: Document how the implementation affects global and feature architecture
   - **Files Changed**: List all files created, modified, or deleted (use `git diff --name-status` to generate)
   - **Testing Approach**: Document test strategy and coverage achieved
   - **Dependencies**: List any new or updated dependencies
   - **Configuration Changes**: Document environment variables, config files, database changes
   - **Deployment Notes**: Include migration steps, rollback plan, and verification steps
   - **Known Issues**: Document any limitations, known issues, or technical debt introduced
   - **Cross-References**: Link to planning documents in `$FEATURE_DIR/` for development context

3. **Auto-Generated Content**: Where possible, auto-populate sections using:
   - Git diff for file changes: `git diff --name-status origin/main...HEAD`
   - Package.json/requirements.txt changes for dependencies
   - Environment variable references from code
   - Test file locations and coverage reports

4. **Quality Validation**: Ensure the documentation is:
   - Complete (all sections filled with meaningful content)
   - Accurate (reflects actual implementation)
   - Actionable (provides clear deployment and rollback instructions)
   - Traceable (links to original request, tickets, and related documents)

5. **Directory Creation**: Ensure the documentation directory exists:
   - Create `.docs/implementations/<feature>/` directory if it doesn't exist
   - Use `mkdir -p .docs/implementations/<feature>/` to create the full path

## Task Completion Check (MANDATORY - Before Finishing)

**CRITICAL**: Before suggesting next steps, you MUST verify ALL victory conditions are met:

### Victory Conditions (ALL must pass)

| Condition | Check | Required |
|-----------|-------|----------|
| All tasks complete | `grep -c "^- \[ \]" tasks.md` | 0 |
| All tests pass | Run project test command | Exit 0 |
| No uncommitted changes | `git status --porcelain` | Empty |
| Verification matrix (if exists) | All `passes: true` | Strict mode only* |

*Verification matrix enforcement:
- **Strict mode** (`verification_required_before_review: true` in constitution): All ACs must be verified
- **Default mode**: Warn if unverified, but allow proceeding (manual/deferred ACs may remain `passes: false`)

### Check 1: Tasks.md Completion

```bash
# Count incomplete tasks
INCOMPLETE=$(grep -c "^- \[ \]" "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0")
echo "Incomplete tasks: $INCOMPLETE"
```

- 🟢 **INCOMPLETE = 0**: Proceed to Check 2
- 🔴 **INCOMPLETE > 0**: **CONTINUE IMPLEMENTATION** (do not proceed)

### Check 2: Verification Matrix (if exists)

```bash
# Check if verification matrix exists and has failing items
MATRIX_FILE="$FEATURE_DIR/verification/verification-matrix.json"
if [ -f "$MATRIX_FILE" ]; then
    # Count verification items by type (more stable than ID prefix)
    TOTAL=$(grep -c '"type": "acceptance_criteria"' "$MATRIX_FILE" 2>/dev/null || echo "0")
    PASSING=$(grep -c '"passes": true' "$MATRIX_FILE" 2>/dev/null || echo "0")
    FAILING=$((TOTAL - PASSING))
    echo "Verification matrix: $PASSING/$TOTAL ACs verified ($FAILING unverified)"
fi
```

- 🟢 **No matrix OR all pass**: Proceed to Check 3
- 🟡 **Some unverified** (FAILING > 0):
  1. For each unverified item, find the corresponding test
  2. If test passes: Update `"passes": true` and `"verified_at"` timestamp
  3. If test doesn't exist or fails: AC isn't verified yet

  **Check enforcement mode** (read `$CONSTITUTION_PATH` or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`):
  - **Strict mode** (`verification_required_before_review: true`): Must update matrix before proceeding
  - **Default mode** (setting missing or `false`): Warn but allow proceeding
    - Manual ACs or deferred items may remain `passes: false` with documented reason

  4. If matrix updated: Commit (with branch guard):
     ```bash
     .gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1
     git commit -m "chore(<feature>): update verification matrix"
     ```

### Check 3: Git Status Clean

```bash
# Check for uncommitted changes
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "❌ Uncommitted changes exist"
    git status --short
fi
```

- 🟢 **Clean**: Proceed to Check 4
- 🔴 **Dirty**: Commit changes before declaring done

### Check 4: Tests Pass

```bash
# Run project tests
if [ -f "$REPO_ROOT/package.json" ]; then
    npm test
elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
    pytest
elif [ -f "$REPO_ROOT/Makefile" ] && grep -q "^test:" "$REPO_ROOT/Makefile"; then
    make test
fi
```

- 🟢 **Tests pass**: ALL VICTORY CONDITIONS MET
- 🔴 **Tests fail**: Fix before declaring done

### Victory Gate Decision

**If ANY check fails**:
- **DO NOT STOP** or suggest next steps
- **DO NOT** suggest `/gbm.tests` or any other command
- List what's blocking
- **CONTINUE** until all checks pass

**If ALL checks pass**:
- Print victory report
- Proceed to next steps

### Task Completion Report (print before next steps):

```
═══════════════════════════════════════════════════════════
VICTORY CHECK
═══════════════════════════════════════════════════════════
Tasks:       X/Y complete
Matrix:      [✓ All pass / N/A / ❌ X failing]
Git Status:  [✓ Clean / ❌ Uncommitted changes]
Tests:       [✓ Pass / ❌ Failing]

Status: [✓ ALL VICTORY CONDITIONS MET / ❌ CONTINUE]
═══════════════════════════════════════════════════════════
```

### ❌ NEVER say:
- "Implementation is complete" (when checks fail)
- "I've finished the feature" (without running victory check)
- "Ready for review" (when any condition fails)

### ✅ ALWAYS:
- Run all victory checks before declaring done
- List what's blocking if incomplete
- Be explicit: "X tasks remain, continuing..." or "All victory conditions met"

**IMPORTANT**: This check prevents AI agents from stopping prematurely. You MUST continue until ALL victory conditions pass.

---

## Architecture Documentation Update (MANDATORY after Victory Check)

**Purpose**: Keep architecture documentation in sync with implementation changes. This prevents stale docs that mislead future developers.

### Step 1: Detect Architectural Changes

After victory check passes, analyze the files changed in this implementation:

```bash
# Get all files changed in this feature branch (with fallback if no remote)
BASE_BRANCH=${BASE_BRANCH:-main}
CHANGED_FILES=$(git diff --name-only "origin/${BASE_BRANCH}...HEAD" 2>/dev/null || \
                git diff --name-only "${BASE_BRANCH}...HEAD" 2>/dev/null || \
                git diff --name-only HEAD~10...HEAD 2>/dev/null || \
                echo "")
echo "Files changed in this implementation:"
echo "$CHANGED_FILES"
```

### Step 2: Map Changes to Architecture Docs

| If changed files include... | Update this doc |
|-----------------------------|-----------------|
| `migrations/`, `models/`, `schema/`, `**/entities/`, `*.prisma`, `*.sql` | `data-architecture.md` |
| `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`, `Gemfile` | `technology-stack.md` |
| `routes/`, `controllers/`, `api/`, `endpoints/`, `**/handlers/`, `*.graphql` | `component-architecture.md` |
| `auth/`, `security/`, `**/middleware/auth*`, `**/guards/`, `*.pem`, `*.key` | `security-architecture.md` |
| `services/`, `clients/`, `integrations/`, `**/external/`, `**/adapters/` | `integration-landscape.md` |

### Step 3: Update Affected Documentation

For EACH architecture doc that needs updating:

1. **Read the existing doc**: `.gobuildme/docs/technical/architecture/<doc-name>.md`

2. **Identify what changed**:
   - New entities/tables added? → Add to entity catalog
   - Dependency versions changed? → Update technology stack table
   - New API endpoints? → Add to component diagram/list
   - New integrations? → Add to integration landscape

3. **Update the specific section** (preserve rest of doc):
   ```markdown
   <!-- Example: Updating technology-stack.md for OpenSearch upgrade -->
   | Search Engine | OpenSearch | 2.5+ | Full-text search, analytics |

   <!-- Example: Updating data-architecture.md for new model -->
   | UserPreferences | src/models/user_preferences.py | Database Model | user_id, theme, notifications | belongs_to User |
   ```

4. **Add change note** at bottom of updated doc:
   ```markdown
   ---
   *Last updated: <date> - Updated <section> for <feature-name> implementation*
   ```

### Step 4: Commit Architecture Updates

```bash
# Verify not on protected branch before committing
.gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1

# Stage architecture doc changes
git add .gobuildme/docs/technical/architecture/

# Commit separately from implementation
git commit -m "docs(architecture): update <doc-names> for <feature>"
```

### Architecture Update Checklist

Before proceeding to next steps, verify:

- [ ] Identified all architecture docs affected by implementation
- [ ] Updated each affected doc with specific changes (not full rewrite)
- [ ] Preserved existing content in docs (only modified relevant sections)
- [ ] Committed architecture updates

### ❌ DON'T skip architecture updates if:
- You added new database tables or columns
- You upgraded dependency versions
- You added new API endpoints
- You integrated new external services
- You modified authentication/authorization

### ✅ OK to skip architecture updates if:
- Changes were purely internal refactoring (no new entities, deps, or APIs)
- Bug fixes that don't change documented behavior
- Test-only changes

**Why this matters**: Stale architecture docs caused confusion in Issue #51. Keeping docs in sync ensures future developers (and AI agents) have accurate context.

---

## Persona-Aware Next Steps (only print if ALL tasks complete)

**Detecting Persona** (always do this):
1. Read: `.gobuildme/config/personas.yaml` → check `default_persona` field
2. Store the value in variable: `$CURRENT_PERSONA`
3. If file doesn't exist or field not set → `$CURRENT_PERSONA = null`

**All Personas - REQUIRED First Step**:
- **Create Implementation Documentation**: Generate `.docs/implementations/<feature>/implementation-summary.md` with concise change documentation

**Persona-Specific Next Command** (display based on $CURRENT_PERSONA):

| Persona | Next Command | Key Focus |
|---------|--------------|-----------|
| backend_engineer | /gbm.tests | API contracts, DB ops, 85% coverage |
| frontend_engineer | /gbm.tests | Component tests, a11y, visual regression |
| fullstack_engineer | /gbm.tests | E2E flows, API+UI integration |
| qa_engineer | /gbm.qa.review-tests | Coverage gaps, edge cases |
| data_engineer | /gbm.tests | Pipeline tests, data validation |
| data_scientist | /gbm.tests | Model validation, metrics |
| ml_engineer | /gbm.tests | Model tests, inference validation |
| sre | /gbm.tests | Reliability tests, chaos scenarios |
| security_compliance | /gbm.tests | Security tests, compliance validation |
| architect | /gbm.analyze | ADRs, boundary checks, NFR validation |
| product_manager | /gbm.review | Acceptance validation, stakeholder review |
| maintainer | /gbm.review | PR quality, tech debt assessment |

**For extended guidance**: Read `.gobuildme/templates/reference/persona-next-steps.md` for detailed focus areas, quality gate requirements, and remediation steps per persona.

### If $CURRENT_PERSONA = null (no persona set)
**Suggested Action**: Run `/gbm.persona` first to set your role and get personalized guidance

**Generic Next Step**: `/gbm.tests` to run test suite and validate implementation

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. DO NOT use a placeholder or fake UUID.
11. Track command complete and trigger auto-upload:
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-implement` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/post-command-hook.sh --command "gbm.implement" --status "success|failure" --command-id "$command_id" --feature-dir "$SPEC_DIR" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - This handles both telemetry tracking AND automatic spec upload (if enabled in manifest)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

## Optional: Spec Repository Upload

After updating `tasks.md` with implementation completion markers, you can optionally upload the spec directory:

→ `/gbm.upload-spec` - Upload specs to S3 for cross-project analysis and centralized storage

*Requires AWS credentials. Use `--dry-run` to validate access first.*

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Core workflow:**
→ `/gbm.tests` (validate implementation - Phase 8)

**Optional preflight check:**
- `/gbm.preflight` — Quick validation (lint, type, tests pass) before running full test suite

**Not ready?**
- Manually edit implementation code to fix specific issues
- Re-run `/gbm.tasks` if task breakdown needs revision
- Run `/gbm.analyze` to identify consistency issues first
- Re-run `/gbm.implement` for specific tasks that need rework

---

## Final Step: Clean State Validation & Progress Notes (MANDATORY)

Before ending this session, you MUST ensure clean state AND update progress notes.

### Part 1: Clean State Checklist (REQUIRED before stopping)

```bash
# 1. Check for uncommitted changes
echo "=== Git Status ==="
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "❌ UNCOMMITTED CHANGES - commit or stash before stopping"
    git status --short
else
    echo "✓ Clean - no uncommitted changes"
fi

# 2. Check tests pass
echo "=== Test Status ==="
if [ -f "$REPO_ROOT/package.json" ]; then
    npm test --passWithNoTests && echo "✓ Tests pass" || echo "❌ Tests failing"
elif [ -f "$REPO_ROOT/pyproject.toml" ]; then
    pytest -q && echo "✓ Tests pass" || echo "❌ Tests failing"
elif [ -f "$REPO_ROOT/Makefile" ] && grep -q "^test:" "$REPO_ROOT/Makefile"; then
    make test && echo "✓ Tests pass" || echo "❌ Tests failing"
fi

# 3. Verify tasks.md is up to date
echo "=== Tasks Status ==="
INCOMPLETE=$(grep -c "^- \[ \]" "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0")
COMPLETE=$(grep -c "^- \[x\]" "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0")
echo "Complete: $COMPLETE, Incomplete: $INCOMPLETE"
```

### ❌ NEVER end session with:
- Uncommitted changes (`git status` shows modified files)
- Failing tests
- tasks.md checkboxes not matching actual completion
- Empty or outdated progress notes

### ✅ ALWAYS end session with:
- Clean `git status`
- All tests passing
- tasks.md updated
- Progress notes capturing session work

---

### Part 2: Update Progress Notes

**CLI Shortcut** (if `gobuildme` CLI is available):
```bash
# Create new progress file (first session only)
gobuildme harness progress-seed <feature> <persona> [participants...]

# Update summary from tasks.md (subsequent sessions)
gobuildme harness progress-update <feature>
```

**Manual Method** (if CLI not available):

1. **Create or Update Progress File** at `$FEATURE_DIR/verification/gbm-progress.txt`:
   - If file doesn't exist: Create it using the template at `.gobuildme/templates/gbm-progress-template.md`
     * Replace placeholders: `{{FEATURE_NAME}}`, `{{PERSONA_ID}}`, `{{PARTICIPANT_PERSONAS}}`
     * Set initial task counts from tasks.md
   - Add new session entry at TOP of Session History section (follow template instructions)
   - Update Summary section with current task counts

2. **Session Entry Content** (add for each session):
   - Session number and timestamp
   - Status (in-progress, completed, blocked)
   - Current phase
   - Tasks completed this session (with IDs)
   - Issues encountered and resolutions
   - Verification results (how tasks were verified)
   - Next steps in priority order
   - Notes for next session (important context)

3. **Commit Progress Notes** (with branch guard):
   ```bash
   # Verify not on protected branch before committing
   .gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1
   git add $FEATURE_DIR/verification/gbm-progress.txt
   git commit -m "chore(<feature>): update progress notes - session N"
   ```

**Why this matters**: Progress notes enable the next agent/session to resume exactly where you left off without wasting tokens rediscovering state.
