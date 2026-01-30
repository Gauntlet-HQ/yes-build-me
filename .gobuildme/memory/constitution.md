---
description: "Project constitution for YesFundMe"
metadata:
  artifact_type: constitution
  created_timestamp: "2026-01-30T18:20:49Z"
  created_by_git_user: "Nidheesh Puthalath <nputhalath@gofundme.com>"
  input_summary: []
---

# YesFundMe Constitution

## Core Principles

<!-- PRINCIPLE: ship-small -->
### Ship Small, Stay Revertible
- Prefer single-concern PRs with clear rollback.
- Avoid broad refactors mixed with feature work.

<!-- PRINCIPLE: secure-by-default -->
### Secure by Default
- Never hardcode secrets; use `.env` and environment injection.
- Validate inputs at API boundaries; avoid leaking sensitive info in logs/errors.

<!-- PRINCIPLE: test-first -->
### Test-First Where It Matters
- For any bug fix or new behavior, add the minimal test coverage that prevents regressions.
- Don’t “fix” tests to match broken code; fix code to match expected behavior.

<!-- PRINCIPLE: api-contracts -->
### Stable API Contracts
- Backwards compatibility first; if breaking changes are necessary, document them in the request/spec.
- Prefer explicit request/response shapes and consistent error formats.

<!-- PRINCIPLE: simple-ux -->
### Simple UX, Consistent UI
- Keep UI patterns consistent across pages/components.
- Favor clarity over novelty; accessibility is part of correctness.

## Architectural Principles

### System Architecture Constraints
- [ ] **Microservices Boundaries**: Single repo, modular “client/server/database” packages. No new services without an explicit architecture decision record.
- [ ] **Data Architecture**: SQLite is the local source of truth. Data access goes through server models; no client-side direct DB access.
- [ ] **Integration Patterns**: REST JSON API under `/api/*`. No direct cross-package runtime coupling (client should call server via HTTP).

### Security Architecture
- [ ] **Authentication & Authorization**: JWT bearer tokens; protected routes use `authenticateToken` middleware. Ownership checks enforced for campaign edit/delete.
- [ ] **Network Security**: Local dev HTTP. For real deployments: terminate TLS at the edge; restrict CORS explicitly if enabled.
- [ ] **Data Protection**: Passwords stored as bcrypt hashes; never log JWTs or passwords; keep `JWT_SECRET` in environment configuration.

### Performance Architecture
- [ ] **Scalability Constraints**: Single-node app for learning. Keep server stateless aside from SQLite file.
- [ ] **Caching Strategy**: No dedicated cache layer today. Avoid premature caching; prefer correct indexes and bounded pagination.
- [ ] **Performance Standards**: Ensure endpoints are paginated where appropriate; keep response sizes reasonable; avoid N+1 queries in model layer.

## Workflow Enforcement Settings

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

  tdd_mode: warn
```

## Architecture Baseline

### Technology Stack
- **Languages & Runtimes**: Node.js >= 22
- **Frameworks & Libraries**: React 19 (Vite), Express 4, Tailwind CSS 4, React Router 7
- **Database Technologies**: SQLite (via `better-sqlite3`)

### System Architecture
- **Service Architecture**: Modular monorepo (workspace) with a single API server + SPA client.
- **Layering & Domain Boundaries**:
  - Client: UI + routing + auth context
  - Server: Express routes + middleware + models
  - Database: schema + seed scripts
  - **Forbidden couplings**: No SQL in routes; no DB access from client; keep auth logic in middleware.
- **Data Storage & Messaging**: SQLite file DB; synchronous HTTP JSON APIs.

## Development Environment

### How to Run the Application

```bash
# Development server (starts client + server)
npm run dev

# Run tests (not currently configured; add when introducing tests)
npm test

# Build for production (client only)
npm run build --workspace=@yesfundme/client

# Lint/format check (client lint only)
npm run lint --workspace=@yesfundme/client
```

### Prerequisites
- **Runtime**: Node.js 22+
- **Package Manager**: npm
- **Environment Variables**: See `.env.example` (at minimum: `PORT`, `JWT_SECRET`, `DATABASE_PATH`)

### Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Set up environment
cp .env.example .env

# 3. Seed database
npm run seed

# 4. Start development
npm run dev
```

## Governance

- Changes must be reviewable, testable, and reversible.
- Security-sensitive changes must pass security checks and receive appropriate review.
- Never commit directly to protected branches (`main`, `master`, `develop`, `dev`, `staging`, `production`, `prod`).

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

- **Verify before implementing**: Prefer official docs and version-specific sources to confirm API signatures, configuration options, and behavior.
- **Never assume**: No guessing method signatures, environment variables, or undocumented behavior.
- **Document sources**: Cite the source and version when introducing or modifying third-party usage.

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

## Research and Fact-Checking Standards

> **Last Updated**: 2026-01-30
> **Default citation format**: APA
> **Link validation**: Recommended
> **Archival requirements**: Recommended (Required for security-critical claims)

**Version**: 1.0.0 | **Ratified**: 2026-01-30 | **Last Amended**: 2026-01-30

