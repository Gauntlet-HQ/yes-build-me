---
description: "Project constitution for YesFundMe"
metadata:
  artifact_type: constitution
  created_timestamp: "2026-01-29T21:40:00-07:00"
  created_by_git_user: "codeshock"
  input_summary: []
---

# YesFundMe Constitution

## Core Principles

> **Note for AI Agents**: Each principle section is tagged with `<!-- PRINCIPLE: principle-id -->` HTML comments.
> These tags enable machine-readable traceability validation in `/gbm.review`.

<!-- PRINCIPLE: component-based -->
### I. Component-Based Architecture
Code is organized into reusable React components on the frontend and modular Express routes/models on the backend. Each component should have a single responsibility and be independently testable.

<!-- PRINCIPLE: api-first -->
### II. API-First Design
All client-server communication goes through well-defined REST API endpoints. The frontend never directly accesses the database. API responses follow consistent JSON structures with proper error handling.

<!-- PRINCIPLE: test-driven -->
### III. Test-Driven Development
Tests should be written alongside features. Unit tests for business logic, integration tests for API endpoints, and component tests for UI. Tests must pass before merging to main.

<!-- PRINCIPLE: security-first -->
### IV. Security First
Authentication via JWT tokens. Passwords hashed with bcrypt. Input validation on both client and server. No secrets in code - use environment variables.

<!-- PRINCIPLE: simplicity -->
### V. Simplicity & Maintainability
Prefer simple, readable code over clever solutions. Use established patterns. Document complex logic. Keep functions small and focused. YAGNI - don't build features until needed.

## Architectural Principles

### System Architecture Constraints
- [ ] **Monorepo Boundaries**: Client, server, and database packages are separate workspaces. No direct imports across package boundaries except through defined APIs.
- [ ] **Data Architecture**: SQLite database with better-sqlite3. Single source of truth. All data access through model layer.
- [ ] **Integration Patterns**: REST APIs for all client-server communication. JSON request/response bodies. JWT Bearer tokens for authentication.

### Security Architecture
- [ ] **Authentication & Authorization**: JWT tokens with 7-day expiry. Password hashing with bcrypt (10 rounds). Protected routes require valid token.
- [ ] **Network Security**: CORS configured for local development. All sensitive operations require authentication.
- [ ] **Data Protection**: Passwords never stored in plain text. Sensitive data not logged.

### Performance Architecture
- [ ] **Scalability Constraints**: SQLite suitable for learning/demo purposes. Stateless API design allows horizontal scaling of server.
- [ ] **Caching Strategy**: No caching layer currently - acceptable for learning project.
- [ ] **Performance Standards**: API responses < 500ms. Page loads < 3s on local development.

### Code Organization Constraints (LoC Analysis)

```yaml
loc_constraints:
  enabled: false
  mode: warn
  max_loc_per_feature: 1000
  max_files_per_feature: 30
  artifacts:
    - name: "Frontend Components"
      paths:
        - "packages/client/src/components/**/*"
        - "packages/client/src/pages/**/*"
      max_loc: 600
      description: "React components and pages"
    - name: "API Routes"
      paths:
        - "packages/server/routes/**/*"
      max_loc: 400
      description: "Express route handlers"
    - name: "Database Layer"
      paths:
        - "packages/server/models/**/*"
        - "packages/database/**/*"
      max_loc: 300
      description: "Database models and schema"
  exclude:
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
  pr_slicing:
    mode: warn
    thresholds:
      max_loc_estimate: 500
      max_concerns: 1
```

## Technology Stack

### Technology Stack
- **Languages & Runtimes**: Node.js 22+, JavaScript (ES Modules)
- **Frameworks & Libraries**: React 19, Vite 7, Tailwind CSS 4, Express.js 4
- **Database Technologies**: SQLite with better-sqlite3

## Development Environment

### How to Run the Application

```bash
# Development server (starts both client and server)
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
- **Package Manager**: npm 10+
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
- **Service Architecture**: Monorepo with client/server/database packages. Client communicates with server via REST API.
- **Layering & Domain Boundaries**: Routes → Models → Database. No business logic in route handlers.
  - **Forbidden couplings**: Client cannot import from server packages. No direct database access from routes.
- **Data Storage & Messaging**: SQLite for all persistent data. No message queue (synchronous operations only).

### Infrastructure & Operations
- **Deployment & Runtime**: Local development only (learning project). Production deployment not configured.
- **Observability Standards**: Console logging for errors. No structured logging or metrics.
- **Performance & SLO Budgets**: N/A for learning project.
- **Compatibility & Migration Policy**: Database schema changes require re-seeding.

## AI-Generated Code & Open Source Licensing

> **Policy Alignment**: This section aligns with the GoFundMe Open Source License Policy.

### Core Principle

**Assume AI-generated code may include OSS.** Any code generated or suggested by AI that introduces or modifies the use of a framework, library, or dependency must be treated as potentially open-source-licensed.

### Quick Reference: Roadmap (Go / Caution / Stop)

| **Go** | **Caution** | **Stop** |
| --- | --- | --- |
| MIT, Apache-2.0, BSD 2/3-Clause | LGPL, GPL with exceptions, EPL-2.0 | AGPL, RPL, **unlisted licenses** |

## Governance

This constitution governs all development on YesFundMe. Changes require documentation and team approval.

## Organizational Rules (Fixed)

<!-- PRINCIPLE: gofundme-engineering-rules -->
### GoFundMe Engineering Rules

The following rules are mandatory for all work under GoFundMe:

- No hardcoding of values in the source code. Configuration and secrets via environment variables.
- No mock data or fake implementations in production code.
- Tests under `tests/` or language-specific test directories.
- Comprehensive test suite required for all changes.
- Security review is non-negotiable.
- Never commit directly to protected branches (`main`, `master`).

<!-- PRINCIPLE: pr-slicing-rules -->
### PR Slicing Rules

- Target 400–500 lines of code per PR maximum
- One concern per PR
- Tests included in same PR
- Main branch must remain deployable after merge

<!-- PRINCIPLE: security-requirements -->
### Security Requirements

- No secrets in source or logs
- Pin dependencies with lockfiles
- Validate inputs and encode outputs
- Follow least-privilege for permissions

**Version**: 1.0.0 | **Ratified**: 2026-01-29 | **Last Amended**: 2026-01-29

## VI. Research and Fact-Checking Standards

> **Last Updated**: 2026-01-29
> **Philosophy**: Correction Over Blocking

### 6.1 Core Principles

1. **Never Block Progression**: Users can always proceed regardless of research quality
2. **Provide Corrections**: For every weak/unverified claim, suggest improvements
3. **Quality Visibility**: Research quality scores visible in review, not used as gates

### 6.4 Citation Format Standards

**Default Format**: APA
**Link Validation**: Recommended
**Archival Requirements**: Recommended

<!-- PRINCIPLE: reliability-observability -->
### Reliability & Observability

For learning projects, basic console logging is acceptable. Production deployments would require structured logging, metrics, and alerting.
