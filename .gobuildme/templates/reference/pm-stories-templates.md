# PM User Stories Templates

Reference templates for `/gbm.pm.stories` artifacts. Use these structures when creating user stories and Jira tickets.

---

## Epic Breakdown Template

```markdown
# Epic: [Epic Name from PRD]

**Description:** [From PRD]
**User Persona:** [Primary persona] | **Business Value:** [Why] | **Priority:** [P0/P1/P2]

---

## Story 1: [Specific, implementable story]

**As a** [persona], **I want to** [action], **So that** [benefit].

**Acceptance Criteria:**
**Given** [precondition], **When** [action], **Then** [outcome].

- [ ] [Criterion 2]
- [ ] [Criterion 3]

| Field | Value |
|-------|-------|
| Story Points | [1/2/3/5/8/13] |
| Dependencies | [List or None] |

**Definition of Done:**
- [ ] Code complete and reviewed
- [ ] Unit tests passing
- [ ] Acceptance criteria validated
- [ ] Ready for QA
```

---

## Story Point Scale

| Points | Size | Duration | Description |
|--------|------|----------|-------------|
| 1 | XS | 1-4 hours | No dependencies, well-understood |
| 2 | S | 4-8 hours | Minimal dependencies, clear requirements |
| 3 | M | 1-2 days | Some dependencies, may need design review |
| 5 | L | 2-3 days | Multiple dependencies, requires coordination |
| 8 | XL | 3-5 days | Significant dependencies, complex logic |
| 13 | XXL | 1+ week | **TOO LARGE - BREAK IT DOWN** |

**Estimation includes:** Coding, testing, code review, documentation. Add 1.2-1.5x buffer for uncertainty.

---

## Jira CSV Import Format

```csv
Issue Type,Summary,Description,Priority,Story Points,Epic Link,Component,Labels,Acceptance Criteria
Epic,"[Epic Name]","[Description]",High,,[Parent],,[feature],
Story,"[Title]","As a [persona], I want [action], so that [benefit]",High,5,[Epic Key],Backend,"feature, api","AC1: [Criterion]"
```

**Import:** Jira → Issues → Import from CSV → Map columns → Review and import

---

## INVEST Quality Criteria

| Criterion | Check |
|-----------|-------|
| **I**ndependent | Can be developed in any order |
| **N**egotiable | Details can be discussed, focuses on "what" not "how" |
| **V**aluable | Delivers user/business value, traces to PRD |
| **E**stimable | Team can estimate, requirements are clear |
| **S**mall | Completable in 1 sprint, ideally 2-5 points |
| **T**estable | Clear acceptance criteria, can verify "done" |

---

## Story Templates by Type

### Backend API Story

```markdown
## Story: [API Endpoint Name]

**As a** [frontend/system], **I want to** [call endpoint], **So that** [display/process data].

**Given** valid auth token, **When** POST /api/v1/[endpoint], **Then** 200 OK with response.

- [ ] 400 for invalid input | 401 for auth failure | 403 for authz | 500 with error
- [ ] Response <500ms at p95 | API documented in OpenAPI

**Contract:** `POST /api/v1/[endpoint]` → `{"id": "uuid", "status": "success"}`

**Points:** 3-5 | **Component:** Backend
```

### Frontend UI Story

```markdown
## Story: [UI Component]

**As a** [persona], **I want to** [interact with component], **So that** [accomplish task].

**Given** on [page], **When** [action], **Then** see [expected state].

- [ ] Matches design mockup | Responsive | Accessible (WCAG 2.1 AA)
- [ ] Loading/error/success states handled

**Design:** [Figma link] | **Points:** 2-5 | **Component:** Frontend
```

### Integration Story

```markdown
## Story: [Integration Name]

**As a** [system], **I want to** [integrate with service], **So that** [sync/trigger].

**Given** [external available], **When** [trigger], **Then** [data correct].

- [ ] Auth working | Data mapping correct | Error handling | Retry logic
- [ ] Webhook handling | Logging | Monitoring alerts

**External System:** [Name] | **Protocol:** [REST/GraphQL/Webhook] | **Points:** 5-8
```

### Database Migration Story

```markdown
## Story: [Database Change]

**As a** [developer], **I want to** [modify schema], **So that** [feature can store data].

**Given** migration applied, **When** app accesses DB, **Then** schema available without data loss.

- [ ] Migration reversible | No data loss | Indexes for performance
- [ ] Tested on staging | Backup taken | Downtime estimated

**Table:** [name] | **Action:** [CREATE/ALTER/DROP] | **Points:** 2-5
```

### Technical Debt Story

```markdown
## Story: [Refactoring Task]

**As a** [engineer], **I want to** [refactor code], **So that** [more maintainable].

**Given** refactoring complete, **When** tested, **Then** all pass AND quality improves.

- [ ] No functional changes | Tests pass | Coverage maintained
- [ ] Performance same or better | Docs updated

**Metrics:** Complexity [Before→After] | Coverage [Before→After] | **Points:** 3-8
```

---

## Sprint Planning

**Capacity:** `(Engineers × Days × Hours) × 0.7` (factor for meetings, review, support)

**Sprint Breakdown:**
- **Goal:** [Specific sprint goal]
- **Stories:** [List with points]
- **Total Points:** [Sum]
- **Dependencies:** [What must be ready]

---

## Definition of Ready / Done

| Definition of Ready | Definition of Done |
|--------------------|-------------------|
| User story clear | Code complete and merged |
| AC defined | Unit tests (≥80% coverage) |
| Dependencies identified | Integration tests passing |
| Story sized | AC validated |
| Design assets available | Code reviewed |
| Technical approach discussed | QA validated |
| No blocking questions | Docs updated, deployed to staging |

