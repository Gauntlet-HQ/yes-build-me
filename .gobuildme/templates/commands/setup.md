---
description: "Complete project setup: creates constitution, generates architecture docs, and sets persona. Run this FIRST for any project."
scripts:
  sh: .gobuildme/scripts/bash/check-architecture-freshness.sh
  ps: .gobuildme/scripts/powershell/check-architecture-freshness.ps1
artifacts:
  - path: "$WORKSPACE_ROOT/.gobuildme/memory/constitution.md"
    description: "Project constitution with principles, governance, and quality standards"
  - path: "$GBM_ROOT/.gobuildme/docs/technical/architecture/"
    description: "Architecture documentation (system-analysis.md, technology-stack.md, etc.)"
  - path: "$GBM_ROOT/.gobuildme/docs/technical/architecture/architecture-summary.md"
    description: "Compact architecture summary for lite/quickfix workflows"
  - path: "$WORKSPACE_ROOT/.gobuildme/config/personas.yaml"
    description: "Persona configuration with selected default persona (workspace-level)"
  - path: "(console output)"
    description: "Project readiness report with status of all components"
---

## Output Style Requirements (MANDATORY)

- Status updates as work progresses (e.g., "Creating constitution...", "Generating architecture...")
- Final status table with checkmarks for each component
- Workflow tier recommendations based on task size
- No verbose explanations - bullets and tables only

You are the GoBuildMe setup command. This is the **FIRST command** users run on any project. Your job is to ensure the project has all foundational artifacts (constitution, architecture, persona) before any development workflow begins.

**This command REPLACES** (for initial setup):
- `/gbm.constitution` - Creates project constitution
- `/gbm.persona` - Sets default persona
- `/gbm.architecture` - Generates **global** architecture docs (system-analysis, technology-stack, etc.)

**Note**: `/gbm.architecture` is still useful for **feature-level context** (feature-context.md, impact-analysis.md, ADRs) when working on specific features. Setup handles global architecture only.

## User Input

**Arguments**: $ARGUMENTS

- If arguments contain `--ci`, run in strict mode (fail on any issues, no interactive prompts)
- If arguments contain `--force`, regenerate all artifacts even if they exist
- Other arguments are passed as context for constitution/architecture generation

## Your Task

Execute these steps in order. For a fresh project, you will CREATE all artifacts. For an existing project, you will CHECK and UPDATE as needed.

---

### Step 1: Resolve Workspace Paths

```bash
# Source common.sh for helper functions
source .gobuildme/scripts/bash/common.sh

# Resolve paths
WORKSPACE_ROOT=$(get_workspace_root)
GBM_ROOT=$(get_gobuildme_root)
CONSTITUTION_PATH="$WORKSPACE_ROOT/.gobuildme/memory/constitution.md"
PERSONAS_PATH="$WORKSPACE_ROOT/.gobuildme/config/personas.yaml"  # Workspace-level for sharing
ARCH_DIR="$GBM_ROOT/.gobuildme/docs/technical/architecture"
```

Parse `--ci` and `--force` flags from `$ARGUMENTS`:
```bash
CI_MODE=false
FORCE_MODE=false
if [[ "$ARGUMENTS" == *"--ci"* ]]; then CI_MODE=true; fi
if [[ "$ARGUMENTS" == *"--force"* ]]; then FORCE_MODE=true; fi
```

---

### Step 2: Constitution Setup

**Check if constitution exists and is configured:**
```bash
if [[ -f "$CONSTITUTION_PATH" ]]; then
  # Check if it's still a template - matches multiple placeholder patterns:
  # - [UPPERCASE_PLACEHOLDER] - most common (e.g., [PROJECT_NAME], [DEV_SERVER_COMMAND])
  # - [principle-N-id] or [principle-#-id] - kebab-case for principle IDs
  # - [Date] - mixed case
  # - [Choose: ...] - selection prompts
  # NOTE: Documentation examples like [PR-1 URL or branch name] are NOT placeholders
  if grep -qE '\[[A-Z][A-Z0-9_]+\]|\[principle-[0-9N]+-id\]|\[Date\]|\[Choose:' "$CONSTITUTION_PATH"; then
    CONSTITUTION_STATUS="template"
  else
    CONSTITUTION_STATUS="configured"
  fi
else
  CONSTITUTION_STATUS="missing"
fi
```

**⚠️ CRITICAL DECISION POINT - Read carefully:**

| Status | `--force` | Action |
|--------|-----------|--------|
| `configured` | NO | **SKIP ENTIRELY** → Display "✅ Constitution: Already configured" → Go to Step 3 |
| `configured` | YES | Create/overwrite constitution (proceed below) |
| `template` | any | Create constitution (proceed below) |
| `missing` | any | Create constitution (proceed below) |

**If `CONSTITUTION_STATUS == "configured"` AND `--force` was NOT passed:**
```
✅ Constitution: Already configured
```
**→ Proceed directly to Step 3: Persona Setup now. DO NOT display "Creating Project Constitution" or run any creation steps below.**

---

**ONLY if constitution needs creation** (status is `missing`, `template`, OR `--force` was passed):

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📜 Creating Project Constitution
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Execute constitution creation inline:**

1. **Seed the template** (fallback chain mirrors create-request.sh):
   - Create directory `$WORKSPACE_ROOT/.gobuildme/memory/` if missing
   - If `$CONSTITUTION_PATH` doesn't exist, copy from (in order):
     1. `$GBM_ROOT/.gobuildme/templates/memory/constitution.md` (installed template)
     2. `$GBM_ROOT/templates/memory/constitution.md` (repo template, fallback)
   - If BOTH template sources missing, create minimal constitution structure

2. **Analyze the project** to derive values:
   - `PROJECT_NAME`: From package.json, pyproject.toml, go.mod, or directory name
   - `RATIFICATION_DATE`: Today's date
   - `CONSTITUTION_VERSION`: 1.0.0 for new constitutions

3. **Derive principles** from project context:
   - Detect testing framework → set TDD/testing principles
   - Detect language/framework → set coding standards
   - Detect CI/CD → set deployment principles

4. **Replace ALL placeholder tokens** - these are the main placeholders that MUST be replaced:

   **Identity & Versioning:**
   - `[PROJECT_NAME]` → Project name from package.json/pyproject.toml/go.mod/directory
   - `[CONSTITUTION_VERSION]` → "1.0.0" for new constitutions
   - `[RATIFICATION_DATE]` → Today's date (YYYY-MM-DD)
   - `[LAST_AMENDED_DATE]` → Today's date (YYYY-MM-DD)

   **Core Principles (derive from project analysis):**
   - `[principle-N-id]` → kebab-case identifier (e.g., "test-first", "library-first")
   - `[PRINCIPLE_N_NAME]` → Principle title (e.g., "Test-First Development")
   - `[PRINCIPLE_N_DESCRIPTION]` → Principle description

   **Architecture (derive from codebase scan):**
   - `[MICROSERVICES_POLICY]` → Service boundary rules
   - `[DATA_ARCHITECTURE_RULES]` → Data storage patterns
   - `[INTEGRATION_CONSTRAINTS]` → API/messaging patterns
   - `[AUTH_ARCHITECTURE]` → Authentication approach
   - `[NETWORK_SECURITY_RULES]` → Network security patterns
   - `[DATA_PROTECTION_ARCH]` → Data encryption/protection
   - `[SCALABILITY_RULES]` → Scaling patterns
   - `[CACHING_ARCHITECTURE]` → Caching strategy
   - `[PERFORMANCE_REQUIREMENTS]` → Performance targets

   **Technology Stack (derive from dependencies):**
   - `[APP_LANGS]` → Languages and versions
   - `[APP_FRAMEWORKS]` → Frameworks in use
   - `[DATABASE_STACK]` → Database technologies

   **Development Environment (derive from package.json/Makefile/etc):**
   - `[DEV_SERVER_COMMAND]` → Command to start dev server
   - `[TEST_COMMAND]` → Command to run tests
   - `[BUILD_COMMAND]` → Command to build
   - `[LINT_COMMAND]` → Command to lint
   - `[RUNTIME_VERSION]` → Runtime version requirements
   - `[PACKAGE_MANAGER]` → Package manager in use
   - `[INSTALL_COMMAND]` → Command to install dependencies
   - `[ENV_SETUP_COMMAND]` → Environment setup command
   - `[START_COMMAND]` → Command to start app

   **System Architecture:**
   - `[SERVICE_ARCHITECTURE]` → Architecture style
   - `[LAYERS_RULES]` → Layering approach
   - `[FORBIDDEN_COUPLINGS]` → Coupling rules
   - `[DATA_MESSAGING]` → Data/messaging patterns

   **Infrastructure:**
   - `[DEPLOY_RUNTIME]` → Deployment platform
   - `[OBSERVABILITY]` → Observability stack
   - `[PERF_SLOS]` → Performance SLOs
   - `[COMPAT_POLICY]` → Compatibility policy

   **Additional Sections:**
   - `[SECTION_2_NAME]`, `[SECTION_2_CONTENT]` → Custom section or remove
   - `[SECTION_3_NAME]`, `[SECTION_3_CONTENT]` → Custom section or remove
   - `[GOVERNANCE_RULES]` → Governance rules
   - `[GUIDANCE_FILE]` → Path to runtime guidance file or remove reference

   **Research & Fact-Checking (Section VI):**
   - `[Date]` → Today's date (YYYY-MM-DD)
   - `[Choose: APA / IEEE / Chicago / Custom]` → Select one citation format
   - `[Choose: Required / Recommended / Optional]` → Select validation/archival policy

   **CRITICAL**: After replacement, verify NO placeholder patterns remain by running:
   ```bash
   # Check for all placeholder types (NOTE: [PR-1 URL or branch name] is documentation, not a placeholder)
   grep -E '\[[A-Z][A-Z0-9_]+\]|\[principle-[0-9N]+-id\]|\[Date\]|\[Choose:' "$CONSTITUTION_PATH" && echo "⚠️ Placeholders remain!" || echo "✅ All placeholders replaced"
   ```

5. **Add metadata frontmatter**:
   ```yaml
   ---
   description: "Project constitution for {PROJECT_NAME}"
   metadata:
     artifact_type: constitution
     created_timestamp: "{ISO 8601 timestamp}"
     created_by_git_user: "{git config user.name}"
     input_summary: {extract_from_arguments}
   ---
   ```
   **input_summary rules**:
   - If `$ARGUMENTS` contains non-flag text (after removing `--ci`, `--force`): Extract key points as bullets
   - If `$ARGUMENTS` is empty or flags only: Set to `[]` (empty array)

6. **Write the completed constitution** to `$CONSTITUTION_PATH`
7. Display: "✅ Constitution created: `$CONSTITUTION_PATH`"

**CI Mode (only when constitution needs creation)**: If `--ci` flag was passed and constitution is `missing` or `template`, fail immediately instead of creating:
```
ERROR: Constitution not configured. Run `/gbm.setup` interactively first.
```
Exit with code 1. Do not proceed to Step 3.

---

### Step 3: Persona Setup

**Check current persona:**
```bash
if [[ -f "$PERSONAS_PATH" ]]; then
  CURRENT_PERSONA=$(grep 'default_persona:' "$PERSONAS_PATH" | cut -d: -f2 | tr -d ' ')
else
  CURRENT_PERSONA="fullstack_engineer"
fi
```

**If persona is default (fullstack_engineer) and not CI mode:**

Display persona selection:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 Persona Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current persona: fullstack_engineer (default)

Select a persona for this project (or press Enter to keep default):

  1. backend_engineer     - Backend/API development focus
  2. frontend_engineer    - UI/UX and frontend focus
  3. fullstack_engineer   - Full-stack development (default)
  4. data_engineer        - Data pipelines and ETL
  5. ml_engineer          - Machine learning systems
  6. qa_engineer          - Testing and quality assurance
  7. architect            - System design and architecture
  8. sre                  - Site reliability and DevOps
  9. security_compliance  - Security-focused development
  10. product_manager     - Product management workflows
  11. data_scientist      - Data science and analytics
  12. maintainer          - Maintenance and legacy systems

Enter number (1-12) or press Enter for default:
```

**Note**: For advanced persona configuration (e.g., QA guardrails, persona-specific settings), use `/gbm.persona` after setup.

**If user selects a persona (1-12):**
1. Map number to persona ID (1=backend_engineer, 2=frontend_engineer, etc.)
2. **Update ONLY the `default_persona` key** in `$PERSONAS_PATH`:
   - If file exists with key: Replace only the `default_persona:` line
   - If file exists without key: Append the key at the top
   - If file doesn't exist: Create with the key (installer will add full registry)
   ```bash
   # Preserve existing content, only update/insert default_persona
   if [[ -f "$PERSONAS_PATH" ]]; then
     if grep -q "^default_persona:" "$PERSONAS_PATH"; then
       # Key exists - replace it
       sed -i.bak "s/^default_persona:.*/default_persona: $PERSONA_ID/" "$PERSONAS_PATH"
       rm -f "${PERSONAS_PATH}.bak"  # Clean up backup
     else
       # Key missing - insert at top
       echo "default_persona: $PERSONA_ID" | cat - "$PERSONAS_PATH" > "${PERSONAS_PATH}.tmp"
       mv "${PERSONAS_PATH}.tmp" "$PERSONAS_PATH"
     fi
   else
     mkdir -p "$(dirname "$PERSONAS_PATH")"
     echo "default_persona: $PERSONA_ID" > "$PERSONAS_PATH"
   fi
   ```
3. Display: "✅ Persona set to: `<selected_persona>`"

**QA Persona Note**: If `qa_engineer` selected, remind user: "For QA guardrails and advanced config, run `/gbm.persona` after setup."

**If user presses Enter:** Keep default, display "✅ Persona: fullstack_engineer (default)"

**CI Mode**: Skip persona prompt, use current value:
- Display: "✅ Persona: `$CURRENT_PERSONA`"

---

### Step 4: Architecture Setup

**Run the freshness check script (scoped to current repo's architecture):**
```bash
# Scope check to THIS repo's architecture directory only (not workspace-level)
ARCH_OUTPUT=$({SCRIPT} --arch-dir "$ARCH_DIR")
ARCH_SUMMARY=$(echo "$ARCH_OUTPUT" | head -n1)
IFS=':' read -ra PARTS <<< "$ARCH_SUMMARY"
ARCH_STATUS="${PARTS[0]}"
ARCH_COUNT="${PARTS[1]}"
```

**Determine if architecture generation is needed:**
- `UNKNOWN:no_meta_file` → Architecture never generated, MUST create
- `UNKNOWN:*` → Cannot determine, should create
- `STALE:*` → Significantly outdated, should refresh
- `CURRENT:*` → Up to date (skip unless --force)

**If architecture needs generation (or --force):**

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 Generating Architecture Documentation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Execute architecture generation inline:**

1. **Scan the codebase** to gather architectural data:
   - Project structure and directory layout
   - Entry points (main files, CLI entry points)
   - Dependencies (package.json, requirements.txt, go.mod, etc.)
   - Architectural patterns (MVC, microservices, layered, etc.)
   - Technology stack (frameworks, libraries, databases)
   - Configuration files
   - Database/ORM setup
   - API layer and routes
   - Integration points (external services, APIs)
   - Security patterns (auth mechanisms, middleware)
   - Test structure

2. **Create architecture directory** if missing:
   ```bash
   mkdir -p "$ARCH_DIR"
   ```

3. **Generate architecture files** (same as `/gbm.architecture`):

   **a) system-analysis.md** - Architectural style, patterns, design decisions

   **b) technology-stack.md** - Languages, frameworks, databases, tools (table format)

   **c) security-architecture.md** - Auth mechanisms, security patterns

   **d) integration-landscape.md** - External services, APIs, protocols

   **e) data-architecture.md** - Database patterns, entity catalog, data flow

   **f) component-architecture.md** - Component interaction diagrams and boundaries

   **g) data-collection.md** - Raw data collected during codebase scan (for AI analysis)

   **h) .architecture-meta.yaml** - Metadata for freshness detection:
   ```yaml
   version: 1
   last_generated: "{ISO 8601 timestamp}"
   git_repo_root: "{absolute path from git rev-parse --show-toplevel}"
   git_commit: "{full SHA from git rev-parse HEAD}"
   git_branch: "{branch from git rev-parse --abbrev-ref HEAD}"
   ```

   **i) architecture-summary.md** (≤100 lines, CRITICAL for lite/quickfix):
   ```markdown
   # Architecture Summary
   **Project**: {name} | **Repo**: {path} | **Updated**: {date} ({commit_short})

   ## Structure (≤10 rows)
   | Area | Path | Purpose | Owner |
   |------|------|---------|-------|

   ## Stack (≤8 rows)
   | Layer | Tech | Version | Notes |
   |-------|------|---------|-------|

   ## Critical Paths (≤10 bullets)
   - `path` → reason (e.g., "Security-sensitive, requires full workflow")

   ## Integration Points (≤8 bullets)
   - Service → Purpose → Config

   ## Rules of Thumb (≤10 bullets)
   - Pattern/convention

   ## Testing Runbook (≤8 bullets)
   - Test type: `command`
   ```

4. Display: "✅ Architecture documentation generated: `$ARCH_DIR/`"

**CI Mode**: If `--ci` and architecture is UNKNOWN/STALE:
```
ERROR: Architecture documentation is stale/missing. Run `/gbm.setup` interactively first.
```
Exit with code 1.

**If architecture is CURRENT (and not --force):**
- Display: "✅ Architecture: Current ({N} files changed since last generation)"
- Continue to Step 5

---

### Step 5: Display Setup Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 GoBuildMe Project Setup Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Component        Status    Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Constitution     ✅        {Created | Updated | Already configured}
Persona          ✅        {persona_name}
Architecture     ✅        {Generated | Updated | Current (N changes)}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Providing Good Context (Improves AI Output Quality)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For best results, provide rich context with your request:

  Primary (pick one):
    • Clear text description of what you need
    • Jira ticket ID (e.g., PROJ-123)
    • Path to a requirements file

  Supplementary (highly recommended):
    • Confluence page links or documentation URLs
    • Design docs, mockups, or architecture diagrams
    • Related tickets or PRs for context
    • Existing code paths to reference

  Examples:
    /gbm.request "PROJ-123 - see also https://confluence.example.com/x/abc123"
    /gbm.lite.request "Add form validation per design in /docs/forms-spec.md"
    /gbm.quickfix "Fix typo reported in PROJ-456"

💡 The more context you provide upfront, the fewer clarification rounds needed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Workflow Recommendations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Choose based on task size:

  Trivial (typos, config tweaks, 1-2 files):
    → /gbm.quickfix "fix typo in README"

  Small (bug fixes, minor features, 3-5 files):
    → /gbm.lite.request "add validation to form"

  Standard (new features, refactoring, 6+ files):
    → /gbm.request "implement user authentication"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Ready to Start!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your project is fully configured. Start with one of these commands:
  • /gbm.quickfix "description" - Trivial fixes
  • /gbm.lite.request "description" - Small changes
  • /gbm.request "description" - Standard features
```

---

## Error Handling

- **CI Mode failures**: Exit with code 1 and clear error message
- **Non-git repos**: Generate architecture but mark freshness as UNKNOWN
- **Missing GoBuildMe**: Report error: "Run `gobuildme init .` first"
- **Write failures**: Report specific file that failed and suggest fix

## Flags Reference

| Flag | Behavior |
|------|----------|
| `--ci` | Non-interactive mode; fail on missing/stale artifacts instead of creating them |
| `--force` | Regenerate all artifacts even if they already exist |

## Completion

After setup completes:
1. All three artifacts (constitution, persona config, architecture docs) are ready
2. User can immediately start any workflow (/gbm.quickfix, /gbm.lite.request, /gbm.request)
3. Do not automatically proceed - let user choose based on their task
