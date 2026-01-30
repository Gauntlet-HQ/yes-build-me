# YesFundMe Constitution
<!-- A crowdfunding platform for learning full-stack development -->

<!-- IMPORTANT FOR AI AGENTS: This is a TEMPLATE with placeholder values.
     Fields containing text in [BRACKETS] (e.g., [OBSERVABILITY], [PERF_SLOS]) are NOT configured.
     Only enforce sections that have been filled in with actual project values.
     If a field still contains its placeholder, treat it as "not configured" — do NOT generate code for it.
     Sections marked "OPTIONAL" may be removed entirely if not applicable. -->

## Core Principles

> **Note for AI Agents**: Each principle section is tagged with `<!-- PRINCIPLE: principle-id -->` HTML comments.
> These tags enable machine-readable traceability validation in `/gbm.review`.
> When creating your constitution, replace `[principle-N-id]` with a kebab-case identifier (e.g., `library-first`, `test-first`, `simplicity`).
> The `## Constitution Alignment` section in spec.md and plan.md must reference these principle IDs.

<!-- PRINCIPLE: user-first -->
### I. User-First Development
Focus on user experience and accessibility. Features must be intuitive, responsive, and accessible. Test with real users early and often.

<!-- PRINCIPLE: api-first -->
### II. API-First Design
Backend features must expose RESTful APIs. Frontend components consume APIs only - no direct database access. Clear API contracts with validation and error handling.

<!-- PRINCIPLE: test-first -->
### III. Test-First Development (NON-NEGOTIABLE)
TDD mandatory for all features: Write tests → User approves → Tests fail → Implement code. Red-Green-Refactor cycle strictly enforced. No untested code.

<!-- PRINCIPLE: integration-testing -->
### IV. Integration Testing
API endpoints require integration tests. Database interactions must be tested. Component integration with APIs must be verified. Focus on user journeys.

<!-- PRINCIPLE: simplicity -->
### V. Simplicity & Learning
Start simple, YAGNI principles. Code must be readable and well-documented for learning purposes. Prefer clarity over cleverness. Educational value is paramount.

## Architectural Principles
<!-- Lightweight architectural constraints that all features must respect. These are checked during /constitution and guide detailed analysis in /analyze. -->

### System Architecture Constraints
- [ ] **Microservices Boundaries**: [MICROSERVICES_POLICY]
  <!-- Example: Respect existing service boundaries; New services require architecture review; No cross-service database access -->
- [ ] **Data Architecture**: [DATA_ARCHITECTURE_RULES]
  <!-- Example: Single source of truth per domain; Event-driven communication; No shared databases between services -->
- [ ] **Integration Patterns**: [INTEGRATION_CONSTRAINTS]
  <!-- Example: REST APIs for synchronous; Events for async; No direct database coupling; API versioning required -->

### Security Architecture
- [ ] **Authentication & Authorization**: [AUTH_ARCHITECTURE]
  <!-- Example: OAuth 2.0/OIDC required; Role-based access control; No service-to-service passwords -->
- [ ] **Network Security**: [NETWORK_SECURITY_RULES]
  <!-- Example: TLS everywhere; Private subnets for databases; WAF for public endpoints -->
- [ ] **Data Protection**: [DATA_PROTECTION_ARCH]
  <!-- Example: Encryption at rest and in transit; PII tokenization; Audit logging for sensitive operations -->

### Performance Architecture
- [ ] **Scalability Constraints**: [SCALABILITY_RULES]
  <!-- Example: Horizontal scaling preferred; Stateless services; Database read replicas for scaling -->
- [ ] **Caching Strategy**: [CACHING_ARCHITECTURE]
  <!-- OPTIONAL — Remove this line if not applicable to your project. Example: Redis for session data; CDN for static assets; Application-level caching patterns -->
- [ ] **Performance Standards**: [PERFORMANCE_REQUIREMENTS]
  <!-- Example: API response times <200ms; Database queries <100ms; Page load times <2s -->

### Code Organization Constraints (LoC Analysis)
<!-- Lines of Code (LoC) constraints drive manageable PR sizes and focused implementations. -->
<!-- These are ADVISORY by default (warn-only) unless strict_mode is enabled. -->

```yaml
loc_constraints:
  # Master switch - set to true to enable LoC analysis
  enabled: false

  # Behavior mode: "warn" (advisory) or "strict" (blocking)
  # warn = report violations but allow progression
  # strict = block /gbm.push if limits exceeded
  mode: warn

  # Branch-level aggregate limits (total changes vs base branch)
  max_loc_per_feature: 1000
  max_files_per_feature: 30

  # Artifact definitions with LoC budgets
  # IMPORTANT: First-match-wins ordering - put specific paths before general ones
  artifacts:
    - name: "Authentication"
      paths:
        - "src/auth/**/*"
        - "lib/auth/**/*"
      max_loc: 200
      description: "Auth module should be focused and well-tested"

    - name: "API Layer"
      paths:
        - "src/api/**/*"
        - "src/routes/**/*"
        - "src/controllers/**/*"
      max_loc: 400
      description: "API endpoints with validation and error handling"

    - name: "Database Layer"
      paths:
        - "src/models/**/*"
        - "src/repositories/**/*"
        - "src/db/**/*"
      max_loc: 300
      description: "Data access and ORM models"

    - name: "Business Logic"
      paths:
        - "src/services/**/*"
        - "src/domain/**/*"
      max_loc: 500
      description: "Core business logic and domain services"

    - name: "Frontend Components"
      paths:
        - "src/components/**/*"
        - "src/pages/**/*"
        - "src/views/**/*"
      max_loc: 600
      description: "UI components and pages"

  # Files/patterns excluded from LoC counting (applied BEFORE artifact mapping)
  exclude:
    - "**/*_test.*"
    - "**/*.test.*"
    - "**/*.spec.*"
    - "**/test_*"
    - "**/tests/**/*"
    - "**/__tests__/**/*"
    - "**/migrations/**/*"
    - "**/*.generated.*"
    - "**/*.min.*"
    - "**/vendor/**/*"
    - "**/node_modules/**/*"
    - "**/*.lock"
    - "**/package-lock.json"
    - "**/poetry.lock"
    - "**/go.sum"

  # Analysis configuration
  analysis:
    # Git ref to compare against (override with LOC_ANALYSIS_BASE env var)
    base_ref: "origin/main"

    # Output verbosity: "summary" (top 5 exceeded) or "full" (all artifacts)
    output_detail: "summary"

    # Maximum artifacts to show in exceeded list
    max_exceeded_display: 5
```

**Interpretation Notes**:
- LoC counted via `wc -l` (lines including blanks/comments)
- First path match wins for artifact assignment
- Unmatched files count toward branch totals only
- Tests excluded by default to encourage thorough testing
- Override base ref: `export LOC_ANALYSIS_BASE=origin/develop`

**Integration Points** (post-implementation only):
- `/gbm.review` - Validates LoC constraints during code review
- `/gbm.push` - Blocks push if strict mode and limits exceeded

### Workflow Enforcement Settings
<!-- Configuration flags that control GoBuildMe workflow behavior. -->

```yaml
workflow_enforcement:
  # Architecture prerequisite for /gbm.request (existing codebases)
  # false (default) = soft gate: show warning, allow continue
  # true = strict mode: block /gbm.request until /gbm.architecture is run
  architecture_required_before_request: false

  # Personas that always require architecture before request (regardless of above setting)
  # Useful for roles where architecture context is critical
  strict_architecture_personas:
    - architect
    - security_compliance
    - sre

  # PR Slicing enforcement at /gbm.request
  pr_slicing:
    # Behavior mode: "warn" (advisory) or "strict" (blocking)
    # warn = report oversized scope but allow continuation
    # strict = block /gbm.request if scope exceeds guidelines
    mode: warn

    # Thresholds that trigger warnings/blocks
    thresholds:
      max_loc_estimate: 500
      max_concerns: 1

  # TDD Guardrails - Prevent test modification anti-pattern (v0.10.3+)
  # Controls behavior when AI agents modify test assertions to match code output
  # off = no guardrails (skip all TDD checks)
  # warn = show warning, document rationale, allow proceed (default)
  # strict = block until spec/contract change in PR justifies test modification
  tdd_mode: warn

```

**Behavior**:
- **Default (soft gate)**: `/gbm.request` warns about missing architecture but continues
- **Strict mode**: `/gbm.request` blocks for existing codebases until architecture is documented
- **Persona override**: Listed personas always require architecture regardless of global setting
- Architecture is always mandatory at `/gbm.specify` and `/gbm.plan` (defense in depth)

**TDD Guardrails** (v0.10.3+):
Prevents the anti-pattern where AI agents modify test assertions to match code output instead of fixing code to match test expectations.

| Mode | `/gbm.implement` | `/gbm.review` | Lite/Quickfix |
|------|------------------|---------------|---------------|
| `off` | No guardrails | Skip gate | Silent |
| `warn` (default) | Show warning, allow proceed | Flag for review, allow merge with justification | Silent |
| `strict` | Hard block | Hard block until justified or reverted | Silent |

**Spec/contract changes that justify test modifications**:
- **Spec artifacts**: `request.md`, `spec.md`, `plan.md`, `ADR-*.md` (updated in this PR)
- **API contracts**: `openapi.yaml`, `*.proto`, `*.graphql` (GraphQL schemas)
- **Interface contracts**: Files in `types/`, `interfaces/`, or `contracts/` directories containing `interface` or `type` exports
- **Wrong test exception** (`warn` mode only): Original test was demonstrably wrong - must document the error and correct expected value

**Slice Scope Enforcement** (v0.9.0+):
Validates that PRs only touch files within declared scope and that spec/plan reference constitution principles.

To enable strict mode, add this HTML comment anywhere in this constitution file:
```html
<!-- scope_enforcement: strict -->
```

| Mode | Behavior |
|------|----------|
| **warn** (default) | Reports violations in `/gbm.review` and `ready-to-push.sh` but allows continuation |
| **strict** | Blocks `/gbm.review` and `ready-to-push.sh` if scope violations or missing constitution alignment detected |

**What Gets Validated**:
- **Scope Check**: Files modified must be in `scope.json` allowed_files/patterns
- **Constitution Alignment**: spec.md/plan.md must have `## Constitution Alignment` section referencing `<!-- PRINCIPLE: ... -->` tags
- **Cross-Slice Overlap**: Epic slices must not have conflicting scopes

**Resolving Violations**:
- Update `scope.json` via `/gbm.plan` if changes are intentional
- Add `## Constitution Alignment` section to spec.md/plan.md
- Mark principles as `N/A <principle-id>` if not applicable to the feature

## Educational Goals

This project prioritizes learning and skill development:
- Code must be readable and well-commented for educational purposes
- Features should demonstrate real-world patterns and best practices
- Intentional bugs are acceptable for learning exercises (when documented)
- Documentation must explain "why" not just "what"

## Development Workflow

- All features require a feature branch (no direct commits to main)
- Pull requests require clear description and test evidence
- Code reviews focus on code quality and learning opportunities
- Intentional bugs must be documented in issues and labeled appropriately

## Architecture Baseline
<!-- This section defines the current architecture and technical constraints that features must align with. Fill with concrete values. -->

### Technology Stack
- **Languages & Runtimes**: Node.js 22.x or higher
- **Frameworks & Libraries** (approved): 
  - Frontend: React 19, Vite, Tailwind CSS v4
  - Backend: Express.js 4.x
  - Database: better-sqlite3 12.x
- **Database Technologies**: SQLite with better-sqlite3 (local development focus)

## Development Environment
<!-- This section tells AI agents how to run the application. Fill with concrete commands. -->
<!-- AI agents read this during /gbm.implement orientation to know how to run tests and start the dev server. -->

### How to Run the Application

```bash
# Development server (both frontend and backend)
npm run dev

# Run tests
# (Add test commands when test infrastructure is set up)

# Build for production
npm run build --workspace=@yesfundme/client

# Lint/format check
npm run lint --workspace=@yesfundme/client
```

### Prerequisites
- **Runtime**: Node.js 22.x or higher
- **Package Manager**: npm 10.x or higher
- **Environment Variables**: See `.env.example`
  - `PORT` - Server port (default: 3000)
  - `JWT_SECRET` - Secret key for JWT tokens
  - `DATABASE_PATH` - Path to SQLite database file

### Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Set up environment and database
cp .env.example .env
npm run seed

# 3. Start development
npm run dev
```

**Why this section matters**: AI agents use this during `/gbm.implement` orientation to:
1. Run smoke tests at session start (catch undocumented bugs)
2. Verify tests pass before declaring victory
3. Know how to start the dev server for manual testing

### System Architecture
- **Service Architecture**: Monorepo with client/server separation. RESTful API communication. JWT-based authentication.
- **Layering & Domain Boundaries**: 
  - Frontend: Components → API Client → Backend APIs
  - Backend: Routes → Middleware → Database
  - **Forbidden couplings**: No direct database access from frontend; No business logic in React components
- **Data Storage & Messaging**: SQLite for all data storage. No external messaging systems (educational simplicity).

### Infrastructure & Operations
- **Deployment & Runtime**: Local development focus. Node.js runtime with npm workspaces. No containerization required for educational simplicity.
- **Performance Standards**: Fast local development iteration. Vite HMR for frontend changes. Nodemon for backend hot reload.

## AI-Generated Code & Open Source Licensing

> **Policy Alignment**: This section aligns with the GoFundMe Open Source License Policy. For complete details, see [OSS Licensing Policy Reference](../.gobuildme/templates/reference/oss-licensing-policy.md).

### Core Principle

**Assume AI-generated code may include OSS.** Any code generated or suggested by AI that introduces or modifies the use of a framework, library, or dependency must be treated as potentially open-source-licensed and subject to the GoFundMe Open Source License Policy.

### Quick Reference: Roadmap (Go / Caution / Stop)

> **Engineering Directors must approve *all* OSS use.**

| **Go** | **Caution** | **Stop** |
| --- | --- | --- |
| **No Legal approval** needed for any use | **Legal approval required** to distribute | **Legal approval required** for any use |
| MIT, Apache-2.0, BSD 2/3-Clause | LGPL, GPL with exceptions, EPL-2.0 | AGPL, RPL, **unlisted licenses** |

**Key rule:** If you cannot confidently map a license to **Go** or **Caution**, treat it as **Stop** until Legal confirms.

### Requirements for AI-Generated Code

When AI suggests code that adds/modifies dependencies:

1. **Identify the license** (LICENSE file, docs, package metadata)
2. **Confirm Roadmap category** (Go / Caution / Stop)
3. **Obtain required approvals**:
   - **Go**: Engineering Director approval
   - **Caution**: Legal approval before distribution
   - **Stop**: Legal approval for any use
4. **Document in PR** with dependency table showing license and Roadmap category
5. **Add to OSS inventory** and maintain attribution

### Escalation

If AI-generated code appears problematic:
1. **Stop usage immediately** (do not merge/deploy)
2. **Document concern** in PR comments
3. **Escalate to Legal** via Legal Intake Form
4. **Do not proceed** until Legal provides guidance

**For complete policy details, usage guidelines, tracking requirements, and remediation playbook, see [OSS Licensing Policy Reference](../.gobuildme/templates/reference/oss-licensing-policy.md).**

## Governance

- Constitution supersedes all other development practices
- All PRs must align with core principles (user-first, API-first, test-first)
- Amendments require clear justification and documentation
- Educational value must be preserved in all changes

## Organizational Rules (Fixed)

<!-- PRINCIPLE: gofundme-engineering-rules -->
### GoFundMe Engineering Rules

The following rules are mandatory for all work under GoFundMe. They are non‑negotiable and must not be removed or weakened by project‑level changes.

- No hardcoding of values in the source code is allowed. Configuration, secrets, and environment values must be injected via appropriate mechanisms.
- No mock data, simulated logic, or fake implementations in production code. All code must interact with real services, APIs, and data sources. Test fixtures and database seeds for development/testing environments are acceptable but must be clearly isolated from production code paths.
- Do not create tests or scripts in the repository root. Place tests under `tests/` (or language‑specific test directories) and automation under `.gobuildme/scripts/` (or language‑specific script directories).
- Always create and run a comprehensive test suite appropriate to the change (unit, integration, end‑to‑end as needed). CI must execute these tests.
- Security review is non‑negotiable. Changes must pass security checks and reviews before merge and release.
- Never commit directly to protected branches (`main`, `master`, `develop`, `dev`, `staging`, `production`, `prod`). Create a feature branch first if not already on one. The harness scripts will block commits on protected branches.

<!-- PRINCIPLE: ai-documentation-research -->
### AI Agent Documentation Research Standards

When creating specs/plans/code using packages, libraries, frameworks, or technologies:

- **Verify before implementing**: Use Context7 MCP server (preferred) or online search (fallback: official docs, version-specific sources) to confirm API signatures, method names, parameters, return types, configuration options
- **Never assume**: No guessing method signatures, package APIs, environment variables, or undocumented behavior. Verify first, not after errors.
- **Document sources**: Cite research in code comments/spec artifacts with version numbers (e.g., `// Context7: axios@1.6.0 AxiosRequestConfig.timeout`)
- **Enforcement**: `/gbm.specify` and `/gbm.plan` must demonstrate research for any third-party packages/libraries/frameworks introduced or modified

<!-- PRINCIPLE: pr-slicing-rules -->
### PR Slicing Rules

The following rules govern how features are scoped and split into pull requests. Each `/gbm.request` should map to exactly one PR.

**Quantitative Guidelines** (heuristics, not hard limits):
- Target 400–500 lines of code (LoC) per PR maximum
- Target 20–30 minutes of review time per PR
- Prefer fewer than 30 files changed per PR (assessed at review time, not request time)

**Qualitative Requirements** (mandatory):
- **One concern per PR**: Each PR addresses a single logical concern (feature slice, bug fix, refactor)
- **Clear rollback**: Each PR can be reverted independently without breaking other functionality
- **No hidden dependencies**: If a PR depends on another, document the dependency explicitly in the request
- **Tests included**: Tests for the change must be in the same PR (no "tests in follow-up" promises)
- **Main branch deployable**: After merging, main branch must remain deployable

**Database Migration Rules**:
- Prefer backwards-compatible migrations that work with both old and new code
- Use phased changes when schema changes require code updates:
  1. PR-1: Add new columns/tables (nullable or with defaults)
  2. PR-2: Migrate code to use new schema
  3. PR-3: Remove old columns/tables (optional cleanup)
- Separate migration PRs only when it meaningfully reduces risk

**Dependency Documentation**:
- When a PR cannot stand alone, include in request.md:
  - `Depends On: [PR-1 URL or branch name]` (can list multiple, one per line)
  - Brief explanation of why dependency exists
  - Merge order requirements

**Enforcement Settings**: See the **Workflow Enforcement Settings** section in this file.

**Workflow Integration**:
- `/gbm.request`: Evaluates scope and suggests slicing (warn-by-default)
- `/gbm.review`: Reviewer checks verification matrix covers only in-scope items
- `/gbm.push`: Human verification that deferred items aren't accidentally included

<!-- PRINCIPLE: security-requirements -->
### Security Requirements

The following security practices are mandatory and apply to all services, CLIs, scripts, and workflows:

- Secrets & Config
  - No secrets in source, examples, or logs. Use a secrets manager; never commit `.env` with secrets.
  - Mask secrets in CI logs. Rotate credentials; prefer short‑lived tokens and IAM roles over static keys.
  - Use configuration by environment with secure defaults. Disallow "debug=true" in production.

- Dependency & Supply Chain
  - Pin dependencies (lockfiles) and enable automated updates (Dependabot/Renovate) with SCA gating: block High/Critical vulns.
  - Enable code scanning (Semgrep; CodeQL where applicable) and secrets scanning; CI must fail on critical findings.
  - Produce an SBOM for build artifacts when feasible and sign artifacts/container images.
  - For downloaded tools, verify checksums/signatures; avoid `curl | bash` without verification.

- Data Protection
  - Enforce TLS 1.2+ in transit; encrypt sensitive data at rest using managed KMS.
  - Never log PII, secrets, or tokens. Redact on ingestion; use structured logging with security events and audit trails.

- Application Hardening
  - Validate inputs and encode outputs to prevent injection; validate file paths and sizes.
  - Apply security headers (at minimum: HSTS, CSP, X‑Content‑Type‑Options, Referrer‑Policy, X‑Frame‑Options as relevant).
  - Protect against CSRF/SSRF; restrict CORS origins explicitly (no `*` for credentials).

- Access & Authorization
  - Follow least‑privilege for service accounts and CI permissions; use role‑based access with separation of duties.
  - Require code review by an engineer not authoring the change for security‑sensitive code.

- Incident Preparedness
  - Provide runbooks for security‑relevant components and define alert thresholds; ensure alerts integrate with on‑call.

**Version**: 1.0.0 | **Ratified**: 2026-01-30 | **Last Amended**: 2026-01-30

## VI. Research and Fact-Checking Standards

> **Last Updated**: [Date]
> **Philosophy**: Correction Over Blocking - Fact-checking improves research quality without stopping workflow progression.

### 6.1 Core Principles

1. **Never Block Progression**: Users can always proceed regardless of research quality
2. **Provide Corrections**: For every weak/unverified claim, suggest 3-4 improvement options
3. **Quality Visibility**: Research quality scores visible in review, not used as gates
4. **Persona-Aware**: Critical claims (CVEs, regulations, WCAG) get extra help but still don't block

### 6.2 Quality Scoring System

**Quality Grades** (advisory, not blocking):
- **A (90-100%)**: Excellent - Claims verified with Tier 1 authoritative sources
- **B (80-89%)**: Good - Claims verified with Tier 2 reputable sources
- **C (70-79%)**: Fair - Weak verification, improvement suggestions provided
- **D (0-69%)**: Needs Work - Unverified claims, corrections required for quality

**Progression Policy**:
- ✅ Users may proceed at any quality level
- 📊 Quality tracked in `/gbm.review` and `/gbm.checklist`
- 💡 Recommendations provided, never mandates
- 🎯 Persona-critical claims get extra correction assistance

### 6.3 Source Authority Tiers

Configure your project's source authority standards:

**Tier 1 (Authoritative)** - Score: 100
- **Market Research**: gartner.com, forrester.com, idc.com, mckinsey.com
- **Government**: *.gov, nist.gov, sec.gov, irs.gov
- **Standards**: ieee.org, ietf.org, w3.org, iso.org
- **Official Docs**: docs.microsoft.com, cloud.google.com, aws.amazon.com, react.dev, nodejs.org
- **Academic**: *.edu, arxiv.org, acm.org

**Tier 2 (Reputable)** - Score: 70
- **Tech News**: techcrunch.com, arstechnica.com, theverge.com
- **Vendor Blogs**: aws.amazon.com/blogs, cloud.google.com/blog
- **Industry Pubs**: infoq.com, thenewstack.io, devops.com

**Tier 3 (Supplementary)** - Score: 40
- **Communities**: stackoverflow.com, dev.to, medium.com
- **Individual Blogs**: *.github.io, *.netlify.app
- **Note**: Acceptable for non-critical claims

**Prohibited** - Score: 0
- reddit.com, quora.com (unless primary source for sentiment)
- AI-generated content without human verification
- Unattributed claims

### 6.4 Citation Format Standards

**Default Format**: [Choose: APA / IEEE / Chicago / Custom]
- Most projects: APA
- Technical projects: IEEE
- Academic projects: Chicago

**Link Validation**: [Choose: Required / Recommended / Optional]
- Default: Recommended

**Archival Requirements**: [Choose: Required / Recommended / Optional]
- Critical claims: Required
- Pricing data: Required (changes frequently)
- Regulatory: Required (regulations update)

### 6.5 Workflow Integration

**Recommended After**:
- `/gbm.pm.research` - Always recommended
- `/gbm.architecture` - Optional but recommended
- `/gbm.security.audit` - Critical for security claims

**Usage**:
```bash
# Manual fact-check (recommended)
/gbm.fact-check <source-file>

# Review corrections
cat .gobuildme/specs/<feature>/fact-check-report.md

# Apply corrections (user choice)
cp <source>-verified.md <source>.md
```

### 6.6 Persona-Specific Requirements

Personas may define critical claim types requiring 100% verification:

**Example**:
- `security_compliance`: CVE data, regulatory claims (100% required)
- `maintainer`: CVE data, license compatibility (100% required)
- `frontend_engineer`: WCAG accessibility claims (100% required)

**Note**: Even 100% requirements don't block - system provides extra correction help.

---

**Configuration Checklist** (Fill in for your project):
- [ ] Source tier domains reviewed and customized
- [ ] Citation format selected: ___
- [ ] Link validation policy: ___
- [ ] Archival policy: ___
- [ ] Persona requirements defined (if applicable)

---

<!-- PRINCIPLE: reliability-observability -->
### Reliability & Observability
<!-- OPTIONAL SECTION — Remove this entire section if your project does not have formal SLO/SLI requirements. -->
<!-- If removed, AI agents will NOT enforce observability or reliability requirements. -->

> **Note**: This section is **optional**. Remove it entirely for projects without production reliability requirements.

The organization treats reliability as a first‑class, measurable objective across all services and features.

- Global SLO Policy
  - Default availability target: 99.9% monthly; latency targets are feature‑specific and must be stated explicitly.
  - Error budget burn policy: multi‑window, multi‑burn‑rate alerts (e.g., 2% in 1h, 5% in 6h) must page on sustained burn.
  - Measurement window: rolling 28–30 days unless otherwise justified.
- Minimum SLI Set (per feature)
  - Availability (success rate) for critical user journeys.
  - Latency (P50/P95) for key endpoints or flows.
  - Correctness (e.g., non‑error business validations) where applicable.
  - Saturation (resource exhaustion) when the journey is capacity‑sensitive.
- Ownership & Runbooks
  - Each feature must declare an owner team, on‑call rotation, dashboards, and runbook links.
- Source of Truth
  - Every new or changed feature must include a machine‑readable `slo.yaml` under its feature folder and pass schema linting in CI.
