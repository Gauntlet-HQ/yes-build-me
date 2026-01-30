---
description: "Template for clarifying a user request and documenting questions/assumptions"
---

# Request

- Date: [YYYY-MM-DD]
- Requester: [Name/Team]
- JIRA: [ABC-123 or link] (optional)
- Feature Branch: `[###-feature-name]`

## Epic & PR Slice (Incremental Delivery)

> **Goal**: Keep this request PR-sized. If this work is part of a larger epic, explicitly scope *this* PR slice and defer the rest.
> See: `.gobuildme/memory/constitution.md` → PR Slicing Rules for guidelines.

- Epic Link: [URL or ticket id] (optional)
- Epic Name: [Name] (optional)
- PR Slice: [standalone | 1/N | 2/N | ...]
- Depends On: [PR URL or branch name] (if this PR requires another to be merged first; repeat line for multiple dependencies)

### This PR Delivers (In-Scope)
- [Deliverable 1]
- [Deliverable 2]

### Deferred to Future PRs (Out of Scope)
- [PR-2: deferred item]
- [PR-3: deferred item]

### Why One PR (required if large scope)
<!-- If this request was flagged as potentially too large, explain why it cannot be reasonably split -->
<!-- Valid: "atomic migration", "tightly coupled changes", "feature flag covers partial state" -->
<!-- Invalid: "faster to do together", "I don't want multiple PRs" -->
[Justification - remove this section if not needed]

## Summary
[Briefly summarize the user request in 2–4 sentences.]

## Goals
- [Goal 1]
- [Goal 2]

## Non-Goals / Out of Scope
- [Explicitly list what is not part of this request]

## Assumptions
- [Assumption 1]
- [Assumption 2]

## Reliability Inputs (SLI/SLO seeds)
- Critical user journeys (names): [cuj-1, cuj-2]
- Latency expectations (e.g., p95 < 200ms for cuj-1): [...]
- Availability expectations (e.g., 99.9% monthly): [...]
- Existing dashboards/runbooks (links): [...]

## Open Questions (to clarify)
- [Question 1]
- [Question 2]

## References
- [JIRA/issue links, specs, design docs]

---
Notes:
- Keep this document focused on understanding the request and its boundaries.
- The `/specify` step will use this file to draft the specification.
