# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`  
**Created**: [DATE]  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## Epic & PR Slice Context (Incremental Delivery)

> **Rule**: This specification is for the current PR slice only. If this work is part of a larger epic, list future PRs explicitly below and keep acceptance criteria here scoped to this slice.

- Epic Link: [URL or ticket id] (optional)
- Epic Name: [Name] (optional)
- PR Slice: [standalone | 1/N | 2/N | ...]
- Depends On: [PR URL or branch name] (if this PR requires another to be merged first; repeat line for multiple dependencies)

### This PR Delivers (In-Scope)
- [Deliverable 1]
- [Deliverable 2]

## Deferred to Future PRs (Out of Scope)

> **Purpose**: Make incremental PRs first-class. These items are explicitly deferred and MUST NOT be included in tasks.md for this slice.

| Future PR | Scope | Dependencies |
|-----------|-------|--------------|
| PR-2 | [Deferred scope] | [Depends on PR-1] |
| PR-3 | [Deferred scope] | [Depends on PR-2] |

## Execution Flow (main)
```
1. Parse user description from Input
   → If empty: ERROR "No feature description provided"
2. Extract key concepts from description
   → Identify: actors, actions, data, constraints
3. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION: specific question]
4. Fill User Scenarios & Testing section
   → If no clear user flow: ERROR "Cannot determine user scenarios"
5. Generate Functional Requirements
   → Each requirement must be testable
   → Mark ambiguous requirements
6. Identify Key Entities (if data involved)
7. Run Review Checklist
   → If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
   → If implementation details found: ERROR "Remove tech details"
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

### Section Requirements
- **Mandatory sections**: Must be completed for every feature (User Scenarios, Requirements, Acceptance Criteria)
- **Optional sections**: Include only when relevant to the feature (Performance Criteria, Security Criteria)
- When a section doesn't apply, remove it entirely (don't leave as "N/A")
- **Acceptance Criteria**: Each functional requirement should have corresponding acceptance criteria

### For AI Generation
When creating this spec from a user prompt:
1. **Mark all ambiguities**: Use [NEEDS CLARIFICATION: specific question] for any assumption you'd need to make
2. **Don't guess**: If the prompt doesn't specify something (e.g., "login system" without auth method), mark it
3. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
4. **Write testable ACs**: Each acceptance criterion should be verifiable with a clear pass/fail outcome
5. **Cover the spectrum**: Include happy path, error handling, and edge cases in acceptance criteria
6. **Common underspecified areas**:
   - User types and permissions
   - Data retention/deletion policies
   - Performance targets and scale
   - Error handling behaviors
   - Integration requirements
   - Security/compliance needs
   - Architecture/compatibility constraints with existing codebase and boundaries
   - Success/failure conditions for each user action

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
[Describe the main user journey in plain language]

### Acceptance Scenarios
1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

### Edge Cases
- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Acceptance Criteria *(mandatory)*

### Happy Path Criteria
*Core functionality that must work for the feature to be considered complete*

- **AC-001**: **Given** [precondition], **When** [user action], **Then** [expected result] **AND** [additional verification]
- **AC-002**: **Given** [precondition], **When** [user action], **Then** [expected result] **AND** [additional verification]
- **AC-003**: **Given** [precondition], **When** [user action], **Then** [expected result] **AND** [additional verification]

### Error Handling Criteria
*System behavior when things go wrong*

- **AC-E01**: **Given** [error condition], **When** [action attempted], **Then** [error handling behavior] **AND** [user feedback provided]
- **AC-E02**: **Given** [invalid input], **When** [user submits], **Then** [validation message shown] **AND** [system state preserved]

### Edge Case Criteria
*Boundary conditions and unusual scenarios*

- **AC-B01**: **Given** [boundary condition], **When** [action performed], **Then** [system handles gracefully] **AND** [appropriate response given]
- **AC-B02**: **Given** [edge case scenario], **When** [user interaction], **Then** [expected behavior] **AND** [no system degradation]

### Performance Criteria *(include if performance is critical)*
*Non-functional acceptance criteria*

- **AC-P01**: **Given** [load condition], **When** [operation performed], **Then** [completes within X seconds] **AND** [system remains responsive]
- **AC-P02**: **Given** [concurrent users], **When** [simultaneous actions], **Then** [system handles load] **AND** [data integrity maintained]

### Security Criteria *(include if security is relevant)*
*Security and access control requirements*

- **AC-S01**: **Given** [unauthorized user], **When** [attempts access], **Then** [access denied] **AND** [security event logged]
- **AC-S02**: **Given** [sensitive data], **When** [displayed/transmitted], **Then** [properly protected] **AND** [audit trail created]

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST [specific capability, e.g., "allow users to create accounts"]
- **FR-002**: System MUST [specific capability, e.g., "validate email addresses"]  
- **FR-003**: Users MUST be able to [key interaction, e.g., "reset their password"]
- **FR-004**: System MUST [data requirement, e.g., "persist user preferences"]
- **FR-005**: System MUST [behavior, e.g., "log all security events"]

*Example of marking unclear requirements:*
- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if feature involves data)*
- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

## Non‑Functional Requirements • SLIs & SLOs *(mandatory for reliability‑sensitive features)*
- Critical user journeys: [list]
- SLIs (availability, latency, correctness, saturation): [define what to measure and how]
- SLOs (targets, windows): [targets like 99.9% over 30d; latency p95 targets]
- Error budget policy and alerting tiers: [multi‑window burn rates]
- Ownership: team, on‑call, dashboards, runbooks
- Source of truth: `slo.yaml` will be added under `.gobuildme/specs/[###-feature-name]/`

---

## Constitution Alignment *(mandatory)*

> **Purpose**: Explicitly document which constitutional principles this feature addresses. This enables traceability validation in `/gbm.review`.

This feature addresses the following constitution principles:

- **test-first**: [Explain how this feature will follow TDD, e.g., "Tests will be written before implementation for all user scenarios"]
- **security-requirements**: [Explain security aspects, e.g., "Input validation for all user-provided data"]
- **library-first**: [Explain library structure, e.g., "Core logic in standalone module, CLI wraps it"]
- **N/A [principle-id]**: [Explain why principle doesn't apply, e.g., "No database interactions in this feature"]

> **Note**:
> - List ALL principles from `constitution.md` (marked with `<!-- PRINCIPLE: ... -->` tags)
> - For each principle, explain how this feature addresses it OR mark as "N/A" with justification
> - The validator checks this section against constitution principles during `/gbm.review`

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

**IMPORTANT**: Mark each item as `[x]` ONLY when verified and completed.

### Content Quality
- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

### Constitution Alignment
- [ ] All constitution principles are addressed (or marked N/A with justification)
- [ ] Each principle reference explains how the feature addresses it
- [ ] No placeholder text remains in Constitution Alignment section

### Acceptance Criteria Quality
- [ ] Each functional requirement has corresponding acceptance criteria
- [ ] All acceptance criteria follow Given-When-Then format
- [ ] Happy path scenarios are covered
- [ ] Error handling criteria are defined
- [ ] Edge cases are addressed
- [ ] Criteria are specific and verifiable (clear pass/fail conditions)
- [ ] Performance criteria included where relevant
- [ ] Security criteria included where relevant

---

## Execution Status
*Updated by main() during processing*

- [ ] User description parsed
- [ ] Key concepts extracted
- [ ] Ambiguities marked
- [ ] User scenarios defined
- [ ] Requirements generated
- [ ] Acceptance criteria defined
- [ ] Entities identified
- [ ] Review checklist passed

---
