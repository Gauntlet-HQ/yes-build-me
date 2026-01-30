---
description: "Discover and document existing codebase architecture for informed scope decisions."
scripts:
  sh: scripts/bash/analyze-architecture.sh
  ps: scripts/powershell/analyze-architecture.ps1
artifacts:
  - path: ".gobuildme/docs/technical/architecture/system-analysis.md"
    description: "System architecture analysis including style, patterns, and design decisions"
  - path: ".gobuildme/docs/technical/architecture/technology-stack.md"
    description: "Technology stack documentation including languages, frameworks, databases, and tools"
  - path: ".gobuildme/docs/technical/architecture/security-architecture.md"
    description: "Security architecture patterns, authentication mechanisms, and security measures"
  - path: ".gobuildme/docs/technical/architecture/integration-landscape.md"
    description: "External service integrations, APIs, and communication protocols"
  - path: ".gobuildme/docs/technical/architecture/component-architecture.md"
    description: "Component interaction diagrams and architectural boundaries"
  - path: ".gobuildme/docs/technical/architecture/data-architecture.md"
    description: "Database patterns, data models, caching strategies, and data flow"
  - path: ".gobuildme/docs/technical/architecture/data-collection.md"
    description: "Raw data collected by scripts (AI agent transforms this into analysis files)"
  - path: ".gobuildme/docs/technical/architecture/.architecture-meta.yaml"
    description: "Metadata for architecture freshness detection (git commit, timestamp)"
  - path: ".gobuildme/docs/technical/architecture/architecture-summary.md"
    description: "Compact architecture summary (≤100 lines) for quickfix/lite workflows"
  - path: "$FEATURE_DIR/docs/technical/architecture/feature-context.md"
    description: "Feature-specific architectural context and integration requirements"
---

## Output Style Requirements (MANDATORY)

**Architecture Documentation Output**:
- 3-5 bullets per section (more only for technology stack inventory)
- Diagrams (mermaid) for component relationships and data flow
- Tables for technology choices, integration points, security controls
- One-sentence rationale per architectural decision
- No general architecture theory - specific to this codebase only

**System Analysis**:
- Style classification in one line
- Pattern list as bullets, not prose
- Decision table: decision | rationale | trade-off

**Technology Stack**:
- Table format: category | technology | version | purpose
- No explanations of what technologies do - assume reader knows

**Entity Catalog**:
- Table format: entity | file | type | key fields | relationships
- One-line business purpose per entity

## Purpose

> **This command discovers and documents EXISTING architecture** — it does not design new architecture.
>
> Use `/gbm.architecture` to understand the current system before scoping new work. This enables:
> - Informed PR slice boundaries aligned with module boundaries
> - Understanding of integration points and dependencies
> - Identification of architectural constraints that affect new features

**When to Run**:
- **Before `/gbm.request`** (recommended for complex codebases): Get the best scope decisions upfront
- **Before `/gbm.specify`** (required): Architecture is mandatory for existing codebases

You are an expert software architect. The `/gbm.architecture` command generates architectural documentation that serves as the foundation for all other GoBuildMe commands.

**Your Role**: Discover, analyze, and document both global system architecture and feature-specific architectural context that other commands (specify, plan, implement, tests, review, etc.) will leverage.

**Architecture Documentation Strategy**:
- **Global Architecture**: System-wide analysis in `.gobuildme/docs/technical/architecture/`
- **Feature Context**: Feature-specific architectural context in `$FEATURE_DIR/docs/technical/architecture/` (uses global architecture as foundation)
- **Smart Updates**: Update global documentation if missing or significantly outdated, always generate feature context
- **Command Integration**: Ensure documentation supports all downstream commands in the SDD workflow

**Analysis Scope:**
- **Architectural Style**: Monolithic, microservices, serverless patterns
- **Technology Stack**: Languages, frameworks, databases, infrastructure
- **Component Architecture**: How major system components interact
- **Data Architecture**: Database patterns, caching, data flow
- **Integration Patterns**: External services, APIs, communication protocols
- **Security Architecture**: Authentication, authorization, security measures
- **Scalability Patterns**: Performance, caching, scaling approaches
- **Deployment Architecture**: Containerization, orchestration, CI/CD

**User Input Processing:**
User input: $ARGUMENTS

- If arguments provided: Use as additional context for architecture analysis
- If no arguments: Proceed with standard architecture analysis
- If invalid arguments: Ignore and proceed with standard analysis

---

## Step 0: Workspace-Aware Path Resolution (from script output)

The script `{SCRIPT}` outputs workspace-aware paths. Parse these from the JSON output:
- `WORKSPACE_ROOT` - Workspace/monorepo root (for constitution, personas)
- `GBM_ROOT` - Nearest `.gobuildme/` (for architecture artifacts)
- `FEATURE_DIR` - Feature-specific directory (for feature-context documentation)
- `ARCHITECTURE_DIRS` - Colon-separated list of architecture directories (module → root order)

**Architecture Documentation Location**:
- **Global architecture**: Write to `$GBM_ROOT/.gobuildme/docs/technical/architecture/` (module/repo level)
- **Feature architecture**: Write to `$FEATURE_DIR/docs/technical/architecture/` (feature level)

Use these resolved paths for all file access in monorepo/workspace environments.

---

**Persona Context** (optional, non-breaking):
- If `$WORKSPACE_ROOT/.gobuildme/config/personas.yaml` exists, read `default_persona`.
- If a persona id is set and `$WORKSPACE_ROOT/.gobuildme/personas/<id>.yaml` exists:
  * Load `required_sections["/gbm.architecture"]` and ensure those sections are included in the architecture documentation.
  * If `$GBM_ROOT/.gobuildme/templates/personas/partials/<id>/architecture.md` exists, include its content under a `### Persona-Specific Architecture Considerations` section in the appropriate documentation file.
  * Prioritize architecture aspects relevant to the persona (e.g., API design for backend engineers, component architecture for frontend engineers, deployment for SREs).
- If config or persona files are missing, proceed as a generalist with complete architecture documentation.

**Error Handling:**
- If script execution fails: Report error and suggest manual data collection
- If data-collection.md file is missing: Re-run script or create minimal architecture documentation
- If AI analysis fails: Create basic architecture documentation from available data
- If required directories don't exist: Create them and proceed with analysis

**Process:**
For complete style guidance, see `$GBM_ROOT/.gobuildme/templates/_concise-style.md`


1. Track command start:
   - Run `$GBM_ROOT/.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.architecture" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. **Architecture Documentation Check** (MANDATORY):
   - Check for existing architecture documentation in each directory listed in `$ARCHITECTURE_DIRS` (module → root order)
   - Determine if documentation needs refresh based on significant codebase changes
   - Identify current branch context (main branch = global focus, feature branch = global + feature context)

3. **Data Collection** (MANDATORY):
   - Run `{SCRIPT}` from the repository root to collect raw architectural data
   - The script generates structured data for AI agent analysis
   - Data includes: project structure, technology indicators, patterns, security/integration signals

4. **AI Agent Architectural Analysis** (MANDATORY):

   - **Step 1: Scan Codebase** (Foundation for all analysis):
   Fully scan of the codebase and read and analyze all the files to gather all the information needed to generate the architecture documentation.
     * **Project Structure**: Identify directory layout, module organization, separation of concerns
     * **Entry Points**: Locate main application files, startup scripts, CLI entry points
     * **Dependencies**: Analyze package.json, requirements.txt, pom.xml, go.mod, Cargo.toml, etc.
     * **Architectural Patterns**: Detect MVC, microservices, layered architecture, domain-driven design
     * **Technology Stack**: Identify frameworks, libraries, build tools, runtime environment
     * **Components/Modules**: Map major components, their responsibilities, and interactions
     * **Configuration**: Locate and analyze config files (env vars, yaml, json, ini)
     * **Database/ORM**: Identify database connections, migration scripts, ORM setup
     * **API Layer**: Find API routes, controllers, endpoint definitions
     * **Integration Points**: Detect external service calls, message queues, webhooks, database connections, etc. to identify all the integration points in the codebase.
     * **Security Patterns**: Identify auth mechanisms, middleware, security headers
     * **Test Structure**: Locate test directories, test frameworks, coverage setup
     * **Build/Deploy**: Analyze CI/CD configs, Dockerfiles, deployment scripts

   - **Step 2**: Read and analyze the data-collection.md file generated by the script (cross-reference with codebase scan)
   - **Step 3**: Load raw data from `$FEATURE_DIR/docs/technical/architecture/data-collection.md` (enrich with scan findings)
   - **Step 4**: Transform raw data into structured architectural understanding using AI intelligence + codebase scan insights
   - **Step 5**: Generate strategic insights with business-focused architectural analysis based on actual code patterns
   - **Step 6**: Focus on high-level patterns discovered in scan: architectural style, technology decisions, component relationships
   - **Step 7**: Identify architectural risks and opportunities from codebase scan: security concerns, performance bottlenecks, integration challenges
   - **Step 8**: **Entity Discovery** (CRITICAL for QA workflow independence) - Use codebase scan to locate all entities:
     * Use your knowledge of the codebase and also scan the codebase for entity/model definitions based on detected language and the language-specific patterns:
       - **Python**: SQLAlchemy models (`class.*\(.*Base\)`, `__tablename__`), Django models (`class.*\(models\.Model\)`), Pydantic models
       - **JavaScript/TypeScript**: Mongoose schemas, Sequelize models, TypeORM entities, Prisma schemas
       - **PHP**: Eloquent models (Laravel), Doctrine entities
       - **Java/Kotlin**: JPA entities (`@Entity`), Hibernate entities
       - **Go**: Struct definitions with GORM tags
       - **Ruby**: ActiveRecord models
       - **C#**: Entity Framework models
     * Extract entity information:
       - Entity name and file location
       - Fields/properties with types
       - Relationships (foreign keys, associations)
       - Validation rules
       - Business purpose (infer from name and context)
     * Document ALL entities in complete catalog for QA fixture generation

5. **Global Architecture Documentation Generation** (MANDATORY):
   - **CRITICAL**: You must create these files using AI analysis + codebase scan insights, not just copy raw data
   - **System Analysis**: Create/update `$GBM_ROOT/.gobuildme/docs/technical/architecture/system-analysis.md` with full architectural overview based on actual codebase structure
   - **Technology Stack**: Create/update `$GBM_ROOT/.gobuildme/docs/technical/architecture/technology-stack.md` with technology decisions, rationale, and actual usage patterns from scan
   - **Security Architecture**: Create/update `$GBM_ROOT/.gobuildme/docs/technical/architecture/security-architecture.md` with security patterns discovered in codebase and requirements
   - **Integration Landscape**: Create/update `$GBM_ROOT/.gobuildme/docs/technical/architecture/integration-landscape.md` with integration points found in scan and protocols
   - **Data Architecture**: Create/update `$GBM_ROOT/.gobuildme/docs/technical/architecture/data-architecture.md` with:
     * **Database patterns**: Database design patterns, normalization approach, indexing strategy
     * **Entity Catalog**: Complete list of ALL entities/models in codebase with:
       - Entity name and location (file path)
       - Entity type (database model, API resource, domain entity, DTO)
       - Primary fields and data types
       - Relationships to other entities (one-to-many, many-to-many, etc.)
       - Business purpose (what the entity represents)
     * **Caching strategies**: Cache layers, invalidation strategies, cache keys
     * **Data flow**: How data moves through the system
     * **Data validation**: Validation rules and constraints
   - **Architectural Decisions**: Document ADRs in `$GBM_ROOT/.gobuildme/docs/technical/architecture/architectural-decisions/` with decision rationale

6. **Architecture Metadata & Summary Generation** (MANDATORY for lite/quickfix workflows):

   **a) Create `.architecture-meta.yaml`** in `$GBM_ROOT/.gobuildme/docs/technical/architecture/`:
   ```yaml
   version: 1
   last_generated: "{current ISO 8601 timestamp}"
   git_repo_root: "{absolute path to git root from `git rev-parse --show-toplevel`}"
   git_commit: "{full commit SHA from `git rev-parse HEAD`}"
   git_branch: "{current branch from `git rev-parse --abbrev-ref HEAD`}"
   ```

   **b) Create `architecture-summary.md`** in `$GBM_ROOT/.gobuildme/docs/technical/architecture/` (≤100 lines HARD CAP):
   ```markdown
   # Architecture Summary
   **Project**: {project name} | **Repo**: {repo path} | **Updated**: {date} ({commit_short})

   ## Structure (≤10 rows)
   | Area | Path | Purpose | Owner |
   |------|------|---------|-------|
   | {area} | {path} | {purpose} | {team/layer} |

   ## Stack (≤8 rows)
   | Layer | Tech | Version | Notes |
   |-------|------|---------|-------|
   | {layer} | {tech} | {version} | {notes} |

   ## Critical Paths (≤10 bullets)
   - `{path}` → {reason it's critical, e.g., "Security-sensitive, requires full workflow"}

   ## Integration Points (≤8 bullets)
   - {Service} → {Purpose} → {Key config/env var}

   ## Rules of Thumb (≤10 bullets)
   - {Pattern/convention, e.g., "Services throw, controllers catch"}

   ## Testing Runbook (≤8 bullets)
   - {Test type}: `{command}`
   ```

   **Summary Requirements**:
   - **HARD CAP**: 100 lines total (Structure ≤10 rows, Stack ≤8 rows, each bullet section ≤10 items)
   - **Information-dense**: Tables and bullets only, no prose
   - **Actionable**: Enough context for quickfix/lite workflows to make informed decisions
   - **Critical Paths**: Files/directories that should NOT be touched by quickfix (require full workflow)

7. **Feature-Specific Context** (If on feature branch):
   - **CRITICAL**: You must create these files using AI analysis + codebase scan insights of how the feature fits into the overall architecture
   - **Feature Architecture Context**: Create/update `$FEATURE_DIR/docs/technical/architecture/feature-context.md` with feature-specific considerations based on actual codebase patterns
   - **Architectural Impact Analysis**: Create/update `$FEATURE_DIR/docs/technical/architecture/impact-analysis.md` with impact assessment on existing architecture discovered in scan
   - **Feature-Specific Decisions**: Create/update `$FEATURE_DIR/docs/technical/architecture/decisions.md` with feature-specific architectural decisions aligned with scanned patterns
   - **Integration Points**: Document in feature-context.md how feature integrates with existing components and services found in codebase scan

8. **Validation and Quality Assurance** (MANDATORY):
   - **File Existence Check**: Verify all required architecture files were created (including `.architecture-meta.yaml` and `architecture-summary.md`)
   - **Content Quality Check**: Ensure files contain meaningful architectural insights, not just raw data
   - **Consistency Check**: Verify feature-specific context aligns with global architecture
   - **Integration Readiness**: Confirm documentation format is compatible with downstream commands
   - **Completeness Check**: Ensure all architectural aspects from the scope are covered

9. **Architecture Accuracy Guidelines** (CRITICAL):

   **Authentication Classification:**
   - **Identity PROVIDERS** = WHO authenticates (Okta, Auth0, Keycloak, internal user service)
   - **Authentication METHODS** = HOW users authenticate (Password, Magic Links, MFA, SSO, OAuth flow)
   - **CRITICAL**: Magic Links is a METHOD, not a provider. List it under authentication methods, NOT identity providers.
   - Example: "Auth0 (provider) with Magic Link + Password methods" - NOT "Magic Links (Identity Provider)"

   **Data Storage Documentation:**
   - Only list databases the app connects to DIRECTLY
   - Check dependencies for database drivers (psycopg2, mysql2, mongoose, pg, typeorm, prisma)
   - If NO database drivers found: Document as "API-based persistence" or "Data persisted via [Service] API"
   - Example: "Data persisted via Classy APIv2" NOT "PostgreSQL (via API)" - the app doesn't connect to PostgreSQL directly
   - When unsure: Trace data persistence code to verify actual connection vs API call

   **Accuracy Checklist (Human Review Recommended):**
   - [ ] Identity Providers are actual providers (not methods or protocols)
   - [ ] Databases listed only if app has direct connection (drivers in dependencies)
   - [ ] Each listed integration is actually USED in code (not just referenced)
   - [ ] Versions match dependency files (package.json, requirements.txt, composer.json)
   - [ ] Architectural style matches actual codebase structure

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
10. Track command complete and trigger auto-upload:
   - Prepare results JSON per schema `$GBM_ROOT/.gobuildme/docs/technical/telemetry-schemas.md#gbm-architecture` (include error details if command failed)
   - Run `$GBM_ROOT/.gobuildme/scripts/bash/post-command-hook.sh --command "gbm.architecture" --status "success|failure" --command-id "$command_id" --feature-dir "$SPEC_DIR" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
   - This handles both telemetry tracking AND automatic spec upload (if enabled in manifest)
   - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

**Global Architecture Documentation Output:**
- **System Analysis**: Information-dense architectural documentation covering style, patterns, and design decisions
- **Technology Stack**: Information-dense technology stack with rationale for choices
- **Security Architecture**: Authentication mechanisms, authorization patterns, security boundaries
- **Integration Landscape**: External services, APIs, communication protocols, data flows
- **Component Architecture**: Major system components and their relationships
- **Data Architecture**: Database patterns, caching strategies, data flow analysis
- **Scalability Patterns**: Performance optimizations, scaling approaches, resilience patterns
- **Deployment Architecture**: Containerization, orchestration, CI/CD, operational patterns

**Feature-Specific Architecture Context Output:**
- **Feature Architecture Context**: How the feature aligns with global architecture
- **Architectural Impact Analysis**: Changes the feature will make to system architecture
- **Integration Requirements**: How the feature integrates with existing components
- **Security Considerations**: Security implications specific to the feature

**Command Integration Benefits:**
- **`/gbm.specify`**: Uses architecture context to create architecturally-aligned specifications
- **`/gbm.plan`**: Incorporates architectural constraints and patterns into implementation plans
- **`/gbm.implement`**: Generates code following established architectural patterns
- **`/gbm.tests`**: Creates tests that validate architectural boundaries and integration points
- **`/gbm.review`**: Reviews code for architectural compliance and pattern adherence
- **`/gbm.push`**: Validates architectural compliance before deployment

**Completion Report** (MANDATORY - Use this exact format):

## Architecture Analysis Complete

### Global Architecture Documentation
- **Status**: ✅ Created/Updated | ❌ Failed | ⚠️ Partial
- **System Analysis**: Path to system-analysis.md
- **Technology Stack**: Path to technology-stack.md
- **Security Architecture**: Path to security-architecture.md
- **Integration Landscape**: Path to integration-landscape.md
- **Architecture Meta**: Path to .architecture-meta.yaml (for freshness detection)
- **Architecture Summary**: Path to architecture-summary.md (for lite/quickfix workflows)

### Feature-Specific Context (if on feature branch)
- **Status**: ✅ Created | ❌ Failed | ⚠️ Partial | N/A (main branch)
- **Feature Context**: Path to feature-context.md
- **Impact Analysis**: Path to impact-analysis.md
- **Feature Decisions**: Path to decisions.md

### Key Architectural Insights
- **Primary Architecture Pattern**: [e.g., MVC, Microservices, Layered]
- **Technology Stack**: [e.g., Laravel/PHP, React/TypeScript, MySQL]
- **Critical Integration Points**: [e.g., Payment Gateway, Auth Service]
- **Security Approach**: [e.g., JWT + OAuth2, RBAC]
- **Scalability Considerations**: [e.g., Horizontal scaling, Caching strategy]

### Command Integration Status
- **Ready for /gbm.specify**: ✅ Yes | ❌ No - [reason]
- **Ready for /gbm.plan**: ✅ Yes | ❌ No - [reason]
- **Ready for /gbm.implement**: ✅ Yes | ❌ No - [reason]

**Next Steps** (always print at the end):
- **For New Features** (most common): Use `/gbm.request` to capture feature requests, then `/gbm.specify` to create specifications with architectural context
- **For Existing Feature Work**: If already on a feature branch with request.md, use `/gbm.specify` to create detailed specifications
- **For Implementation Planning**: Use `/gbm.plan` to create implementation plans respecting architectural constraints
- **For Architecture Validation**: Use `/gbm.review` with architecture validation focus to enforce architectural boundaries
- **For Architecture Updates**: Re-run `/gbm.architecture` when significant architectural changes occur
- **Optional - Verify Architecture Claims**: If architecture documentation includes technical claims (performance, scalability, framework capabilities), run `/gbm.fact-check $GBM_ROOT/.gobuildme/docs/technical/architecture/system-analysis.md` to verify authoritative sources

**Recommended Workflow After Architecture**:
- Constitution (WHY) → Persona (WHO) → Architecture (WHAT) → **Request (CAPTURE)** → Specify (DETAIL) → Plan (HOW)

## Optional: Architecture Repository Upload

After generating architecture documentation, you can optionally upload the docs to the centralized repository:

→ `/gbm.upload-spec` - Upload architecture docs to S3 for cross-project analysis

*Requires AWS credentials. Use `--dry-run` to validate access first.*

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Manually edit architecture documentation in `$GBM_ROOT/.gobuildme/docs/technical/architecture/`
- Re-run `/gbm.architecture` to regenerate from updated codebase
- Run `/gbm.validate-architecture` to check boundary compliance

