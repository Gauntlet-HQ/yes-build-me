
# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `.gobuildme/specs/[###-feature-name]/spec.md`

## Epic & PR Slice Context (Incremental Delivery)

> **Rule**: This plan is for the current PR slice only. If the request represents a larger epic, plan only what will ship in this PR and explicitly defer the rest.

- Epic Link: [URL or ticket id] (optional)
- Epic Name: [Name] (optional)
- PR Slice: [standalone | 1/N | 2/N | ...]

### This PR Delivers (In-Scope)
- [Deliverable 1]
- [Deliverable 2]

### Deferred to Future PRs (Out of Scope)
- [PR-2: deferred item]
- [PR-3: deferred item]

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
2a. Generate or load Codebase Profile
   → Run scripts/bash/analyze-architecture.sh; record `.gobuildme/specs/[###-feature-name]/docs/technical/architecture/data-collection.md` path
3. Fill the Constitution Check and Architecture Alignment Check sections based on the content of the constitution and the current architecture.
4. Evaluate Constitution & Architecture Alignment checks
   → If violations exist: Document in Complexity Tracking
   → Run scripts/bash/validate-architecture.sh; if it fails without justification: ERROR "Fix boundary violations or justify with mitigation"
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command produces Phase 0–1 artifacts and describes Phase 2 (it does not create tasks.md). Downstream execution:
- Phase 2: /tasks command creates tasks.md
- Phase 3–4: Implementation execution (manual or via tools)

## Summary
[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context
**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]
**Affected Modules/Boundaries**: [modules/packages that change; domain boundaries impacted]
**Backward Compatibility & Migrations**: [DB schema compat, API versioning, rollout plan]
**SLO/SLA Targets**: [latency, availability, error budgets relevant to change]
**Deployment/Runtime Constraints**: [container/build system, env/secrets handling, staging/prod parity]
**Coverage Threshold**: [default 85% unless specified here]

## Test Plan (Mandatory for TDD)

**From Spec**: Test specifications defined in spec.md
- **Unit Tests**: [List test files and count]
- **Integration Tests**: [List test files and count]
- **Contract Tests**: [List test files and count]

**Test Technology Stack**:
- **Framework**: [e.g., pytest, jest, XCTest from spec]
- **Fixtures/Factories**: [Factory pattern, fixtures, mocks from spec]
- **Coverage Target**: [85% unless specified in Technical Context]
- **Coverage Tool**: [e.g., pytest-cov, istanbul, xcov]

**Test Execution Order (TDD Phases)**:
1. **Phase A: Test Setup** - Create test files structure (empty tests)
2. **Phase B: RED** - Write tests from test specs (all fail initially)
3. **Phase C: GREEN** - Implement code to pass tests
4. **Phase D: REFACTOR** - Improve code while keeping tests passing

**Test File Structure**:
```
tests/
├── unit/          # Unit tests from test specs
├── integration/   # Integration tests from test specs
├── api/          # Contract tests from test specs
├── fixtures/     # Factories, mocks, test data
└── conftest.py   # Pytest configuration (if applicable)
```

**Test Verification Checkpoints**:
- [ ] All test files created (Phase A)
- [ ] All tests written and running (Phase B - RED)
- [ ] Implementation code written to pass tests (Phase C - GREEN)
- [ ] Refactoring complete, tests still passing (Phase D)
- [ ] Coverage threshold met ([85%] by default)
- [ ] No untested code paths in new implementation

**NOTE**: Test plan is as important as implementation plan. Both come from spec.md before implementation begins.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Confirm the following against `.gobuildme/memory/constitution.md`:

Core GoFundMe Engineering Rules (Fixed)
- [ ] No hardcoded values in source; configuration and secrets injected properly
- [ ] Tests/scripts not created at repo root; correct directories used
- [ ] Comprehensive tests planned and runnable in CI for this change
- [ ] Security review planned for this change

Security Requirements (Fixed)
- [ ] Secrets management in place (no secrets in code/logs; masked in CI; rotation documented)
- [ ] Dependency hygiene: lockfiles present; SCA enabled; High/Critical vulns blocked
- [ ] Code & secret scanning enabled in CI (Semgrep; CodeQL where applicable)
- [ ] SBOM and artifact signing considered/implemented for deliverables
- [ ] TLS enforced; sensitive data encrypted at rest
- [ ] Logging redacts PII/secrets; security events/audit trail defined
- [ ] Input validation & output encoding defined; secure headers and CSRF/SSRF/CORS protections planned
- [ ] Least‑privilege IAM for services and CI; review by non‑author on security‑sensitive changes
- [ ] Runbooks/alerts updated for security‑relevant components

## Architecture Alignment Check
*GATE: Validate design against the current codebase architecture and enforced boundaries.*

Codebase Profile
- [ ] Latest Codebase Profile loaded (path to analysis file recorded)

Compatibility & Boundaries
- [ ] Proposed stack/versions compatible with Architecture Baseline (constitution)
- [ ] Layering/boundaries respected (e.g., services ↛ api; domain boundaries intact)
- [ ] Data model changes evaluated for backward compatibility; migrations planned
- [ ] Existing services/contracts/shared libs reused where applicable

Operational Constraints
- [ ] Performance/SLO budgets upheld or improved; capacity considerations documented
- [ ] Deployment pattern aligns with repo standards; env/secrets follow security policy
- [ ] Observability (logs/metrics/traces) aligns with baseline

## Project Structure

### Documentation (this feature)
```
.gobuildme/specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure]
```

**Structure Decision**: [DEFAULT to Option 1 unless Technical Context indicates web/mobile app]

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.gobuildme/scripts/bash/update-agent-context.sh claude`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each contract → contract test task [P]
- Each entity → model creation task [P] 
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation 
- Dependency order: Models before services before UI
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 25-30 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

---

## Constitution Alignment *(mandatory)*

> **Purpose**: Explicitly document which constitutional principles this implementation plan addresses. This enables traceability validation in `/gbm.review`.

This implementation plan addresses the following constitution principles:

- **test-first**: [Explain TDD approach, e.g., "Contract tests written in Phase 1 before implementation; test specs drive Phase 2 task generation"]
- **security-requirements**: [Explain security measures, e.g., "Input validation defined in data-model.md; secrets handled per constitution policy"]
- **library-first**: [Explain modularity, e.g., "Core logic in src/lib/; CLI in src/cli/ as thin wrapper"]
- **N/A [principle-id]**: [Explain why principle doesn't apply to this implementation plan]

> **Note**:
> - List ALL principles from `constitution.md` (marked with `<!-- PRINCIPLE: ... -->` tags)
> - For each principle, explain how this plan addresses it OR mark as "N/A" with justification
> - The validator checks this section against constitution principles during `/gbm.review`
> - This section complements the Constitution Check (checklist) with explicit traceability

---

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [ ] Phase 0: Research complete (/plan command)
- [ ] Phase 1: Design complete (/plan command)
- [ ] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [ ] Initial Constitution Check: PASS
- [ ] Architecture Alignment Check: PASS
- [ ] Post-Design Constitution Check: PASS
- [ ] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

**Constitution Alignment**:
- [ ] All constitution principles are addressed (or marked N/A with justification)
- [ ] Each principle reference explains how the plan addresses it
- [ ] No placeholder text remains in Constitution Alignment section

---
*Based on Constitution v2.1.1 - See `.gobuildme/memory/constitution.md`*
