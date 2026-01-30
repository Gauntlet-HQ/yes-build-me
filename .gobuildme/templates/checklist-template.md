# Specification Quality Checklist: [FEATURE NAME]

**Purpose**: Validate specification completeness and quality before proceeding to planning/implementation.
**Created**: [DATE]
**Feature**: [Link to spec.md]

## Content Quality
- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focus on user value and business needs
- [ ] Written for non‑technical stakeholders
- [ ] All mandatory sections completed

## Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable and technology‑agnostic
- [ ] Acceptance scenarios defined (primary/alternate/exception)
- [ ] Edge cases identified
- [ ] Scope clearly bounded

## Quality Dimensions (Sample Items)

Completeness
- [ ] Are error handling requirements defined for all API failure modes? [Gap]
- [ ] Are accessibility requirements specified for interactive UI? [Completeness]

Clarity
- [ ] Is “fast” quantified with specific thresholds? [Clarity, Spec §NFR]
- [ ] Is “prominent” defined with measurable properties? [Ambiguity, Spec §FR]

Consistency
- [ ] Do navigation requirements align across pages? [Consistency]
- [ ] Are component requirements consistent across contexts? [Consistency]

Coverage
- [ ] Are zero‑state scenarios defined? [Coverage, Edge Case]
- [ ] Are partial failure flows specified? [Coverage, Exception]

Traceability
- [ ] ≥80% of items reference Spec/Plan sections or mark [Gap]/[Assumption].

## Domain Sections (add as applicable)

### Security
- [ ] Authentication/Authorization requirements defined and consistent with constitution.
- [ ] Sensitive data handling, retention, and audit requirements specified.

### Performance
- [ ] SLIs/SLOs defined; performance tests planned.

### Accessibility
- [ ] WCAG targets specified; keyboard navigation and semantics covered.

### Observability
- [ ] Logging, metrics, tracing requirements defined for key actions.

---

Checklist IDs: CHK001… (sequential). Add sections or items as needed.
