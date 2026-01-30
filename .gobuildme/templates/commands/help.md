---
description: "Show GoBuildMe help - use with topics like '/gbm.help personas' or '/gbm.help qa'"
artifacts:
  - path: "(console output)"
    description: "Display of GoBuildMe help documentation based on requested topic (overview, workflow, personas, qa, commands, etc.)"
---

## Output Style Requirements (MANDATORY)

- Topic header + brief overview; commands as tables; workflow as numbered list
- Show only requested topic section; default overview scannable in 30 seconds
- Error messages: one line + list of valid topics; link to docs for deep dives

You are the GoBuildMe help command. Your job is to provide context-sensitive help based on the user's topic request.

## User Input

The user may provide optional arguments to focus on specific topics:

**Arguments**: $ARGUMENTS

## Your Task

1. **Parse Arguments**: Read `$ARGUMENTS` and extract the topic
   - If empty or whitespace only → show `overview` topic
   - If provided → normalize and match to topic

2. **Normalize Topic**:
   - Convert to lowercase
   - Replace spaces with hyphens
   - Apply alias mapping (see below)

3. **Display Help**: Show the corresponding topic section below

4. **Error Handling**: If topic not found, show error message with available topics

## Alias Mapping

Apply these aliases before matching:
- `qa-workflow` → `qa`
- `test` → `testing`
- `tests` → `testing`
- `gates` → `quality-gates`
- `start` → `getting-started`
- `sdd` → `workflow`
- `constitution-setup` → `constitution`

## Available Topics

- `overview` (default - no arguments)
- `getting-started`
- `workflow`
- `personas`
- `qa`
- `commands`
- `architecture`
- `testing`
- `quality-gates`
- `user-responsibility`

---

# TOPIC: overview

Display this when user provides no arguments or `overview`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 GoBuildMe - Spec-Driven Development Toolkit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Bootstrap AI-powered Spec-Driven Development workflows in any project.

📚 Quick Start: /gbm getting-started
📖 Full Docs: .gobuildme/gobuildme-docs/README.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Help Topics (use: /gbm [topic] or /gbm.help [topic])
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Core:
  getting-started       - Quick start guide for new users
  workflow              - Core SDD workflow (12 steps)
  commands              - All available commands by category
  personas              - All 12 personas (architect, QA, backend, etc.)
  user-responsibility   - Approval model & your responsibilities

Workflows:
  qa                - QA testing workflow (6 steps)
  architecture      - Architecture documentation workflow
  testing           - Testing best practices and workflow
  quality-gates     - Quality gates and validation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Examples
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /gbm getting-started    Show quick start guide
  /gbm personas           Show all 12 personas
  /gbm qa                 Show QA workflow
  /gbm workflow           Show core SDD workflow
  /gbm.help commands      Show all commands

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 First Time Using GoBuildMe?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Start here:
  1. /gbm getting-started    (Read the quick start guide)
  2. /gbm.setup              (Check project status & choose workflow)
  3. /gbm.constitution       (Define project goals, if not done)
  4. Choose your workflow:
     - Quick fix (typo, config):  /gbm.quickfix "description"
     - Small change (3-5 files):  /gbm.lite.request "description"
     - Full feature (6+ files):   /gbm.request "description"

⚠️  Running next command = approval of previous artifact
    /gbm.help user-responsibility for details

More help: /gbm.help getting-started
```

---

# TOPIC: getting-started

Display this when user requests `getting-started` or `start`:

```
🚀 Getting Started with GoBuildMe

GoBuildMe enables AI-powered Spec-Driven Development (SDD). Start with:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Define Project Constitution
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/gbm.constitution

Define mission, technical constraints, quality standards, and principles.
Foundation for all subsequent work.
→ .gobuildme/memory/constitution.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2. Configure Persona (Optional - defaults to Fullstack Engineer)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/gbm.persona

Choose from 12 personas (backend, frontend, QA, architect, etc.)
to customize workflows and validation rules.
→ More: /gbm.help personas

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. Document Architecture (Recommended for existing codebases)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/gbm.architecture

Document tech stack, patterns, components, and data flow.
→ More: /gbm.help architecture

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. Start Your First Feature
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/gbm.request → /gbm.specify → /gbm.plan → /gbm.implement → /gbm.tests → /gbm.review

→ More: /gbm.help workflow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resources
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Docs:    .gobuildme/gobuildme-docs/handbook/
Help:    /gbm workflow | /gbm personas | /gbm qa
```

---

# TOPIC: workflow

Display this when user requests `workflow` or `sdd`:

## Instructions to AI Agent

1. Read `.gobuildme/config/personas.yaml` → get `default_persona`
2. Display the generic workflow below
3. Show persona-specific focus from the table
4. Link to persona manual for full details

## Display Content

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Spec-Driven Development Workflow
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Setup (Once per project)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. /gbm.constitution    → Define project goals, constraints, standards
2. /gbm.persona         → Configure your role (optional)
3. /gbm.architecture    → Document tech stack and patterns

Feature Development (Per feature)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 4. /gbm.request    → Capture feature request
 5. /gbm.specify    → Define spec with acceptance criteria
 6. /gbm.clarify    → Resolve ambiguities
 7. /gbm.plan       → Create implementation plan
 8. /gbm.tasks      → Break into task checklist
 9. /gbm.analyze    → Validate technical approach
10. /gbm.implement  → Build feature (TDD)
11. /gbm.tests      → Write tests
12. /gbm.review     → Quality validation
13. /gbm.push       → Final validation and PR

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Persona-Specific Focus
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Each persona customizes the workflow with different:
  • Required sections in /gbm.specify
  • Quality gates in /gbm.plan
  • Coverage thresholds in /gbm.tests

Your Current Persona: [Read from personas.yaml and display here]

Persona Focus Areas:
  backend_engineer     - APIs, databases, migrations (85% coverage)
  frontend_engineer    - UI, accessibility, performance (85% coverage)
  fullstack_engineer   - End-to-end integration (85% coverage)
  qa_engineer          - Test coverage, quality assurance (90%/95%/80%)
  data_engineer        - Pipelines, data quality (80% coverage)
  data_scientist       - Models, experiments, reproducibility (70% coverage)
  ml_engineer          - Model serving, inference (75% coverage)
  sre                  - Observability, runbooks, SLOs (80% coverage)
  security_compliance  - Threat models, compliance (90% coverage)
  architect            - System design, ADRs (no threshold)
  product_manager      - PRD, stakeholder alignment (N/A)
  maintainer           - Release management, PR quality, tech debt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Example: Backend Engineer Workflow
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/gbm.specify → Required: API Contracts, Data Model, Error Handling
/gbm.plan    → Include: OpenAPI spec, migrations, rollback plans
/gbm.tests   → Write: Contract tests, integration tests (85% coverage)
/gbm.review  → Validate: API docs, migration rollbacks, observability

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 More Information
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your Manual:  .gobuildme/gobuildme-docs/personas/[persona]-manual.md
Full Guide:   .gobuildme/gobuildme-docs/handbook/workflow.md
QA Workflow:  /gbm.help qa
All Personas: /gbm.help personas

Complete per-persona workflows: .gobuildme/templates/reference/help-workflows.md
```

---
# TOPIC: personas

Display this when user requests `personas`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👥 GoBuildMe Personas (12 Total)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Persona              Focus Area                         Coverage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
architect            System design, ADRs                   —
backend_engineer     APIs, databases, microservices       85%
frontend_engineer    UI, accessibility, performance       85%
fullstack_engineer   End-to-end features                  85%
data_engineer        Pipelines, ETL, data quality         80%
ml_engineer          ML models, training, serving         75%
qa_engineer          Test scaffolding, automation         90/95/80%
sre                  Reliability, observability, SLOs     80%
security_compliance  Threat modeling, compliance          90%
maintainer           Release management, PR quality        —
product_manager      PRDs, requirements, stories           —
data_scientist       Analysis, experiments                70%

Commands: /gbm.persona (set), ls .gobuildme/personas/ (list)
Manuals:  .gobuildme/gobuildme-docs/personas/<name>-manual.md
Docs:     .gobuildme/gobuildme-docs/handbook/personas.md
```

---

# TOPIC: qa

Display this when user requests `qa` or `qa-workflow`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 QA Testing Workflow (6 Steps)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Prerequisites: /gbm.persona (qa_engineer), /gbm.architecture, git checkout -b qa-test-scaffolding

Step  Command                    Output
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1     /gbm.qa.scaffold-tests     Test skeleton files with TODOs
2     /gbm.qa.plan               qa-test-plan.md (TR-XXX requirements)
3     /gbm.qa.tasks              qa-test-tasks.md (task checklist)
4     /gbm.qa.generate-fixtures  tests/fixtures/ (optional but recommended)
5     /gbm.qa.implement          Implements all tests (auto-continues to 100%)
6     /gbm.qa.review-tests       Coverage validation + quality gates

Quality Gates: Unit 90%, Integration 95%, E2E 80%, AC traceability 100%

Docs: .gobuildme/gobuildme-docs/personas/qa-engineer-manual.md
      /gbm.help testing | /gbm.help quality-gates
```

---

# TOPIC: commands

Display this when user requests `commands`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 GoBuildMe Commands
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Setup:       /gbm.setup, /gbm.constitution, /gbm.persona, /gbm.architecture

Workflow Tiers:
  Quickfix (1-2 files, ≤50 LoC):   /gbm.quickfix
  Lite (3-5 files, ≤100 LoC):      /gbm.lite.request → /gbm.lite.plan
                                    → /gbm.lite.implement → /gbm.lite.push
  Full (6+ files, complex):         See "Core Workflow" below

Core Workflow (Feature Development):
  /gbm.request → /gbm.specify → /gbm.clarify → /gbm.plan → /gbm.tasks
  → /gbm.implement → /gbm.tests → /gbm.review → /gbm.push

QA Workflow:
  /gbm.qa.scaffold-tests → /gbm.qa.plan → /gbm.qa.tasks
  → /gbm.qa.generate-fixtures → /gbm.qa.implement → /gbm.qa.review-tests

Validation:  /gbm.validate-constitution, /gbm.validate-architecture,
             /gbm.validate-conventions, /gbm.analyze, /gbm.preflight

Docs:        /gbm.document, /gbm.docs, /gbm.design, /gbm.checklist
CI/CD:       /gbm.ci-setup, /gbm.ci-matrix, /gbm.security-setup
Utilities:   /gbm, /gbm.help [topic], /gbm.branch-status, /gbm.upload-spec

Full reference: .gobuildme/gobuildme-docs/reference/commands.md
```

---

# TOPIC: architecture

Display this when user requests `architecture`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 Architecture Documentation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

When to use: Existing codebases (required), before major features, onboarding
Skip for: New/empty projects (evolve organically)

Command: /gbm.architecture
Output:  .gobuildme/docs/technical/architecture/

Documents: Tech stack, components, patterns, data flow, integrations, infra

Persona Focus Areas:
  Architect:    System design, ADRs, component boundaries
  Backend:      APIs, database schema, service dependencies
  Frontend:     Component architecture, state management
  Fullstack:    End-to-end data flow, API + UI integration
  SRE:          Reliability, observability, SLOs

Best Practices: Document early, keep updated, use diagrams, explain decisions

Guide: .gobuildme/gobuildme-docs/handbook/architecture.md
```

---

# TOPIC: testing

Display this when user requests `testing`, `test`, or `tests`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 Testing Workflows
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Two Testing Approaches
━━━━━━━━━━━━━━━━━━━━━━
Feature Testing (/gbm.tests):
  Use: Testing specific feature after implementation
  Coverage: 70-85% by persona (Backend/Frontend: 85%, ML: 75%, DS: 70%)

QA Workflow (/gbm.qa.*):
  Use: Complete codebase coverage, QA Engineer persona
  Coverage: Unit 90%, Integration 95%, E2E 80%, AC traceability 100%
  More: /gbm.help qa

Test Types & Targets
━━━━━━━━━━━━━━━━━━━━
Unit (90%):        Individual functions, mocked deps, fast/isolated
Integration (95%): Component interactions, real deps, verify contracts
E2E (80%):         Full user flows, browser automation, high confidence
Contract:          API contracts, provider/consumer, prevent breakage
Performance:       Load/stress testing, performance budgets

Best Practices
━━━━━━━━━━━━━━
• AAA Pattern: Arrange → Act → Assert
• Independence: No shared state, idempotent
• Clear Assertions: Descriptive failures, test behavior not impl
• Mocking: External deps only, realistic data
• Cleanup: Release resources, reset state

📖 Docs: .gobuildme/gobuildme-docs/handbook/testing.md
Related: /gbm.help qa, /gbm.help quality-gates
```

---

# TOPIC: quality-gates

Display this when user requests `quality-gates` or `gates`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚦 Quality Gates & Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GoBuildMe enforces gates at multiple checkpoints to ensure work
meets standards before advancing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Gate Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Gate 1 - /gbm.specify: Persona-required sections present
Gate 2 - /gbm.implement: ALL tasks marked [x] (100%)
Gate 3 - /gbm.tests: Coverage meets persona threshold
Gate 4 - /gbm.review: All quality checks pass
Gate 5 - /gbm.push: Pre-merge validation (CI, conflicts, etc.)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Coverage Thresholds by Persona
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  QA Engineer:              90%/95%/80% (unit/integration/E2E)
  Security Compliance:      90%
  Backend/Frontend/Full:    85%
  Maintainer:               85%
  Data Engineer:            80%
  SRE:                      80%
  ML Engineer:              75%
  Data Scientist:           70%
  Architect/PM:             No threshold

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
QA-Specific Gates
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/gbm.qa.implement: 100% task completion (auto-continues)
/gbm.qa.review-tests: 90%/95%/80% coverage + 100% AC traceability

More: /gbm.help qa

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 More Information
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Docs:     .gobuildme/gobuildme-docs/reference/quality-gates.md
Help:     /gbm.help workflow | /gbm.help testing
```

---

# TOPIC: user-responsibility

Display this when user requests `user-responsibility` or matches `tos`, `terms`, `approval`, `responsibility`, `check`, `review`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 User Responsibility & Approval Model
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GoBuildMe uses implicit approval through action:
  • Command generates artifact (spec.md, plan.md, code)
  • You review the artifact
  • Running next command = approval + responsibility acceptance

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Approval Flow
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Run command        → /gbm.specify "Build feature"
2. Review artifact    → cat $FEATURE_DIR/spec.md
3. Decide:
   ✅ Approve   → Run next command (/gbm.clarify)
   ❌ Reject    → Edit artifact or re-run command
   ❓ Clarify   → Run /gbm.clarify for improvements

Running next command = "I reviewed and approve this artifact"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Your Responsibilities
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

By running each command, you accept responsibility for:
  ✓ Accuracy - Spec matches actual requirements
  ✓ Completeness - Edge cases captured
  ✓ Technical Fit - Approach works in your codebase
  ✓ Security - Meets compliance standards
  ✓ Quality - Coverage thresholds met

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
If You Disagree
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Option 1: Edit manually → vim artifact.md → /gbm.clarify
Option 2: Re-run       → /gbm.specify "Better description"
Option 3: Ask agent    → /gbm.clarify "Add requirements..."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Liability
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You accept: Artifact accuracy, code correctness, security compliance
Not liable: GoBuildMe contributors for approved artifacts

You are the domain expert. Your approval is final.

More: README "User Responsibility" section | /gbm.help workflow
```

---

# ERROR: Topic Not Found

Display this when topic doesn't match any section:

```
❌ Topic not found: {topic}

Available topics:
  Core:
    getting-started       - Quick start guide
    workflow              - Core SDD workflow
    commands              - All commands
    personas              - All 12 personas
    user-responsibility   - Approval model & best practices

  Workflows:
    qa                    - QA testing workflow
    architecture          - Architecture docs
    testing               - Testing best practices
    quality-gates         - Quality validation

Examples:
  /gbm                     Show overview
  /gbm getting-started     Quick start guide
  /gbm.help personas       Show all personas
  /gbm.help qa             QA workflow

Tip: Try '/gbm' for overview and topic list
```
