---
description: "Project constitution for YesFundMe"
metadata:
  artifact_type: constitution
  created_timestamp: "2026-01-30T12:00:00Z"
  created_by_git_user: "cesargutierrez"
  input_summary: []
---

# YesFundMe Constitution

## Core Principles

> **Note for AI Agents**: Each principle section is tagged with `<!-- PRINCIPLE: principle-id -->` HTML comments.
> These tags enable machine-readable traceability validation in `/gbm.review`.

<!-- PRINCIPLE: user-first -->
### I. User-First Development
All features must prioritize the end-user experience. Crowdfunding relies on trust—campaign creators and donors must have a seamless, reliable experience. Performance, accessibility, and clear UI feedback are non-negotiable.

<!-- PRINCIPLE: test-first -->
### II. Test-First Development (TDD)
TDD is mandatory: write tests first, watch them fail, then implement. Red-Green-Refactor cycle strictly enforced. Tests document expected behavior and prevent regressions in donation flows and campaign management.

<!-- PRINCIPLE: security-by-design -->
### III. Security by Design
Financial applications demand rigorous security. JWT authentication, password hashing with bcrypt, input validation, and SQL injection prevention are baseline requirements. No shortcuts on auth or data protection.

<!-- PRINCIPLE: simplicity -->
### IV. Simplicity & Maintainability
Start simple, avoid premature optimization. YAGNI principles apply. The monorepo structure should remain clean with clear separation between client, server, and database packages.

<!-- PRINCIPLE: api-contract -->
### V. API Contract Stability
REST API contracts between client and server must be stable and documented. Breaking changes require versioning and migration plans. Frontend and backend can evolve independently within contract boundaries.

## Architectural Principles

### System Architecture Constraints
- [ ] **Monorepo Boundaries**: Maintain clear separation between `packages/client`, `packages/server`, and `packages/database`. No direct imports across package boundaries except through defined APIs.
- [ ] **Data Architecture**: SQLite as single source of truth. All data access through server models. No direct database access from client.
- [ ] **Integration Patterns**: REST API for client-server communication. JSON payloads. JWT tokens for authentication.

### Security Architecture
- [ ] **Authentication & Authorization**: JWT-based authentication. Passwords hashed with bcrypt. Protected routes require valid tokens.
- [ ] **Network Security**: CORS configured for development. Environment-based configuration for production.
- [ ] **Data Protection**: Sensitive data (passwords) never exposed in API responses. Input validation on all endpoints.

### Performance Architecture
- [ ] **Scalability Constraints**: SQLite suitable for development/small deployments. Migration path to PostgreSQL documented for production scale.
- [ ] **Performance Standards**: API response times <500ms. Page interactions feel instant (<100ms perceived latency).

### Code Organization Constraints (LoC Analysis)

```yaml
loc_constraints:
  enabled: false
  mode: warn
  max_loc_per_feature: 1000
  max_files_per_feature: 30
  artifacts:
    - name: "Client Components"
      paths:
        - "packages/client/src/components/**/*"
        - "packages/client/src/pages/**/*"
      max_loc: 600
      description: "React components and pages"

    - name: "Server API"
      paths:
        - "packages/server/routes/**/*"
        - "packages/server/middleware/**/*"
      max_loc: 400
      description: "Express routes and middleware"

    - name: "Data Layer"
      paths:
        - "packages/server/models/**/*"
        - "packages/server/db/**/*"
        - "packages/database/**/*"
      max_loc: 300
      description: "Database models and schema"

  exclude:
    - "**/*_test.*"
    - "**/*.test.*"
    - "**/*.spec.*"
    - "**/node_modules/**/*"
    - "**/*.lock"
    - "**/package-lock.json"

  analysis:
    base_ref: "origin/main"
    output_detail: "summary"
    max_exceeded_display: 5
```

### Workflow Enforcement Settings

```yaml
workflow_enforcement:
  architecture_required_before_request: false
  strict_architecture_personas:
    - architect
    - security_compliance
    - sre
  pr_slicing:
    mode: warn
    thresholds:
      max_loc_estimate: 500
      max_concerns: 1
  tdd_mode: off
```

## Technology Stack
- **Languages & Runtimes**: Node.js 22+, JavaScript (ES Modules)
- **Frameworks & Libraries**: React 19, Vite 7, Express.js 4, TailwindCSS 4, React Router 7
- **Database Technologies**: SQLite (better-sqlite3), with migration path to PostgreSQL

## Development Environment

### How to Run the Application

```bash
# Development server (runs both client and server concurrently)
npm run dev

# Run tests
npm test

# Build for production
npm run build --workspace=@yesfundme/client

# Lint/format check
npm run lint --workspace=@yesfundme/client
```

### Prerequisites
- **Runtime**: Node.js 22+
- **Package Manager**: npm 9+ (npm workspaces)
- **Environment Variables**: See `.env.example`

### Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Set up environment
cp .env.example .env

# 3. Seed the database
npm run seed

# 4. Start development
npm run dev
```

### System Architecture
- **Service Architecture**: Monorepo with npm workspaces. Client (React SPA) communicates with Server (Express REST API).
- **Layering & Domain Boundaries**: Client → API → Models → Database. No cross-layer shortcuts.
  - **Forbidden couplings**: No direct database access from React components. No business logic in route handlers (use models).
- **Data Storage & Messaging**: SQLite for persistence. No message queues (sync REST API).

### Infrastructure & Operations
- **Deployment & Runtime**: Local development with Vite dev server (client) and nodemon (server).

## AI-Generated Code & Open Source Licensing

### Core Principle

**Assume AI-generated code may include OSS.** Any code generated or suggested by AI that introduces or modifies the use of a framework, library, or dependency must be treated as potentially open-source-licensed.

### Quick Reference: Roadmap (Go / Caution / Stop)

| **Go** | **Caution** | **Stop** |
| --- | --- | --- |
| MIT, Apache-2.0, BSD 2/3-Clause | LGPL, GPL with exceptions, EPL-2.0 | AGPL, RPL, **unlisted licenses** |

## Governance

Constitution supersedes all other practices. Amendments require documentation and approval. All PRs must verify compliance with these principles.

## Organizational Rules (Fixed)

<!-- PRINCIPLE: gofundme-engineering-rules -->
### GoFundMe Engineering Rules

The following rules are mandatory for all work under GoFundMe. They are non‑negotiable and must not be removed or weakened by project‑level changes.

- No hardcoding of values in the source code is allowed. Configuration, secrets, and environment values must be injected via appropriate mechanisms.
- No mock data, simulated logic, or fake implementations in production code. All code must interact with real services, APIs, and data sources. Test fixtures and database seeds for development/testing environments are acceptable but must be clearly isolated from production code paths.
- Do not create tests or scripts in the repository root. Place tests under `tests/` (or language‑specific test directories) and automation under `.gobuildme/scripts/` (or language‑specific script directories).
- Always create and run a comprehensive test suite appropriate to the change (unit, integration, end‑to‑end as needed). CI must execute these tests.
- Security review is non‑negotiable. Changes must pass security checks and reviews before merge and release.
- Never commit directly to protected branches (`main`, `master`, `develop`, `dev`, `staging`, `production`, `prod`). Create a feature branch first if not already on one.

<!-- PRINCIPLE: ai-documentation-research -->
### AI Agent Documentation Research Standards

When creating specs/plans/code using packages, libraries, frameworks, or technologies:

- **Verify before implementing**: Use Context7 MCP server (preferred) or online search to confirm API signatures, method names, parameters, return types
- **Never assume**: No guessing method signatures, package APIs, environment variables, or undocumented behavior
- **Document sources**: Cite research in code comments/spec artifacts with version numbers

<!-- PRINCIPLE: pr-slicing-rules -->
### PR Slicing Rules

**Quantitative Guidelines**:
- Target 400–500 lines of code (LoC) per PR maximum
- Prefer fewer than 30 files changed per PR

**Qualitative Requirements**:
- **One concern per PR**: Each PR addresses a single logical concern
- **Clear rollback**: Each PR can be reverted independently
- **Tests included**: Tests for the change must be in the same PR
- **Main branch deployable**: After merging, main branch must remain deployable

<!-- PRINCIPLE: security-requirements -->
### Security Requirements

- Secrets & Config: No secrets in source. Use environment variables.
- Dependency & Supply Chain: Pin dependencies (lockfiles). Enable automated security scanning.
- Data Protection: Never log PII, secrets, or tokens.
- Application Hardening: Validate inputs. Protect against SQL injection, XSS.
- Access & Authorization: JWT tokens with appropriate expiration. Role-based access where applicable.

**Version**: 1.0.0 | **Ratified**: 2026-01-30 | **Last Amended**: 2026-01-30

## VI. Research and Fact-Checking Standards

> **Last Updated**: 2026-01-30
> **Philosophy**: Correction Over Blocking - Fact-checking improves research quality without stopping workflow progression.

### 6.1 Core Principles

1. **Never Block Progression**: Users can always proceed regardless of research quality
2. **Provide Corrections**: For every weak/unverified claim, suggest improvement options
3. **Quality Visibility**: Research quality scores visible in review, not used as gates

### 6.2 Source Authority Tiers

**Tier 1 (Authoritative)** - Score: 100
- **Official Docs**: react.dev, nodejs.org, expressjs.com, vitejs.dev, tailwindcss.com
- **Standards**: w3.org, ietf.org

**Tier 2 (Reputable)** - Score: 70
- **Tech News**: techcrunch.com, arstechnica.com
- **Vendor Blogs**: Official framework blogs

**Tier 3 (Supplementary)** - Score: 40
- **Communities**: stackoverflow.com, dev.to, medium.com

### 6.3 Citation Format Standards

**Default Format**: APA
**Link Validation**: Recommended
**Archival Requirements**: Required for security claims

---

**Configuration Checklist**:
- [x] Source tier domains reviewed and customized
- [x] Citation format selected: APA
- [x] Link validation policy: Recommended
- [x] Archival policy: Required for security claims
