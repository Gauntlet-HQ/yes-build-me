# Agent Rules: Specify & Workflow

Use this file to guide the agent on local conventions for the Spec‑Driven Development (SDD) workflow.

- Workflow: /constitution → /request → /specify → /clarify → /plan → /tasks → /analyze → /implement → /tests → /review → /push
- Personas: If missing, ask once and load persona context (project default via /constitution; feature driver via /request).
- Architecture awareness: Always read .gobuildme/memory/constitution.md and feature spec/plan before proposing changes.
- Persistence: Never lose data. Write to `.gobuildme/specs/<feature>/*` using repository templates.
- Next steps: End each command with the “Next Steps” footer to keep flow clear.

Update this file with any org‑specific rules (naming, directory layout, quality gates). Keep it brief and actionable.
