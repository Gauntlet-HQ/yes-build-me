# yes-build-me · Agent Operating Brief

This document configures the **GitHub Copilot** coding agent. Treat it as the rules of engagement—do not present it to end users.

## 1. Mission
- Apply the Spec-Driven Development (SDD) workflow to implement features safely.
- Maintain alignment with the project constitution and organizational rules.
- Produce concise status updates, not tutorials or marketing copy.

## 2. Workflow Contract

**Required Order for Existing Codebases**:
```
1. /gbm.constitution (WHY) - Project goals, constraints, standards
2. /gbm.persona (WHO) - Role driving the work
3. /gbm.architecture (WHAT) - Tech stack, components, patterns [for existing codebases]
4. /gbm.request → /gbm.specify → ... (HOW) - Feature development
```

**Complete Workflow**:
```
/gbm.constitution → /gbm.persona → (/gbm.architecture) → /gbm.request → /gbm.specify → /gbm.clarify → /gbm.plan → /gbm.tasks → /gbm.analyze → /gbm.implement → /gbm.tests → /gbm.review → /gbm.push
```

```mermaid
flowchart LR
    A["constitution"] --> P["persona"] --> X["(architecture)"] --> B["request"] --> E["specify"] --> F["clarify"] --> G["plan"] --> H["tasks"] --> I["analyze"] --> J["implement"] --> K["tests"] --> L["review"] --> M["push"]
```

**Workflow Modes** (choose based on task complexity):

| Mode | Files | LoC | Commands | Use Case |
|------|-------|-----|----------|----------|
| **Quickfix** | 1-2 | ≤50 | `/gbm.quickfix "description"` | Typos, config tweaks, obvious bugs |
| **Lite** | 3-5 | ≤100 | `/gbm.lite.request` → `plan` → `implement` → `push` | Bug fixes, small features |
| **Full** | 6+ | >100 | Complete workflow above | New features, complex changes |

**Mode selection**:
- **Quickfix**: Single command, minimal artifacts (request.md + quickfix-log.md), advisory guardrails only
- **Lite**: Streamlined 4-command workflow, essential artifacts (request/plan/tasks), fast iteration
- **Full**: Complete SDD workflow with all gates, comprehensive artifacts, highest quality assurance

**Optional Commands** (shown in parentheses):
- `/gbm.architecture` — Document global/feature architecture (strongly recommended for existing codebases after setting persona)

**Workflow Rules**:
- Advance only to the next command when prerequisites are satisfied and artifacts updated.
- Persist artifacts in the **feature directory** using repository templates.
- During `/gbm.implement`, follow TDD: update `tasks.md`, write tests first, then code.
- **Task Completion**: During `/gbm.implement`, mark completed tasks as `[x]` in `tasks.md`. If any tasks are incomplete, **STOP** and continue implementation—do not advance to the next command.
- **Protected Branches**: NEVER commit directly to `main`, `master`, `develop`, `dev`, `staging`, `production`, or `prod`. Create a feature branch first if not already on one (`git checkout -b <feature-name>`). The harness scripts will block commits on protected branches.

### Feature Directory Resolution

**Preferred source**: Use `FEATURE_DIR` from the latest command output (e.g., `/gbm.request`, `/gbm.setup-plan`). Only infer from branch name if `FEATURE_DIR` is unavailable.

Determine the feature directory from the current git branch (fallback only):

| Branch Pattern | Feature Directory |
|----------------|-------------------|
| `<feature>` (no `--`) | `.gobuildme/specs/<feature>/` |
| `<epic>--<slice>` (contains `--`) | `.gobuildme/specs/epics/<epic>/<slice>/` |

**Examples**:
- Branch `user-auth` → `.gobuildme/specs/user-auth/`
- Branch `auth--db-models` → `.gobuildme/specs/epics/auth/db-models/`

**Sliced Epics**: When branch contains `--`, check for slice registry at `.gobuildme/specs/epics/<epic>/slice-registry.yaml`. This tracks all slices in the epic.
**Orphan Slice Warning**: If branch contains `--` but no registry exists, warn the user and ask whether to create the epic registry first (recommended) or proceed as a new epic (non‑default).

### Monorepo/Workspace Guidance

GoBuildMe supports three deployment models:
- **Single Repo** (default): Traditional single-project setup
- **Monorepo**: Single git repo with multiple apps/modules
- **Workspace**: Multiple git repos under a common workspace directory

**Discovery Priority** (for AGENTS.md, constitution, architecture):
1. Check current directory for relevant files
2. Walk up to find nearest `.gobuildme/` directory
3. Root `.gobuildme/` is fallback (workspace or monorepo root)

**Mode Detection**: Check `.gobuildme/manifest.json` for `mode` field (`single`, `monorepo`, `workspace`).

**Constitution**: Always loaded from workspace/monorepo root (not per-module)
- Single repo: `<repo>/.gobuildme/memory/constitution.md`
- Monorepo: `<repo-root>/.gobuildme/memory/constitution.md`
- Workspace: `<workspace-root>/.gobuildme/memory/constitution.md`

**Architecture Search Order**: Module → Root
1. Check `<current>/.gobuildme/docs/technical/architecture/` (module-level)
2. Fall back to `<root>/.gobuildme/docs/technical/architecture/` (workspace/monorepo root)

**Commands** (agent-specific directories):
- Monorepo: Modules inherit from root `.claude/commands/` (or agent-specific dir)
- Workspace: Each repo has its own `.claude/commands/`

**Feature Directory in Multi-Root**:
- Run commands from the module/repo where features should be created
- `$FEATURE_DIR` is relative to nearest `.gobuildme/` from CWD
- Cross-module/cross-repo epics: Registry at workspace root, slices in respective modules/repos

**Environment Variable Overrides**:
- `GOBUILDME_TARGET_ROOT` — Override nearest `.gobuildme/` location (for feature artifacts)
- `GOBUILDME_WORKSPACE_ROOT` — Override workspace root (for constitution, global settings)
- `GOBUILDME_MODE` — Force deployment mode (`single`, `monorepo`, `workspace`)
- `GOBUILDME_SCOPE` — Force epic scope (`local`, `cross`)

### PR Slicing (Multi‑PR Epics)
- Apply constitution PR-slicing rules (concerns count, estimated LoC, rollback risk). If over limits, **require** slicing or justification.
- Branch naming: `<epic>--<slice>` (kebab-case). Example: `user-auth--backend-api`.
- Slice registry lives at `.gobuildme/specs/epics/<epic>/slice-registry.yaml` and is the source of truth for slice names and scope summaries.
- When splitting in `/gbm.request`: create the registry, keep the epic folder, and write PR-1 request under `.gobuildme/specs/epics/<epic>/<slice>/request.md`.
- When starting a new slice: run `/gbm.request` on the slice branch, load the registry, set slice `in_progress`, and use its `scope_summary`.
- `/gbm.push` marks the current slice `complete` and shows the next planned slice. Do not auto-advance other slices.

### Key Artifacts (JSON/YAML)
- `$FEATURE_DIR/scope.json` — allowed_files/patterns + rationale. If tasks change, regenerate scope.json and re-validate changes.
- `$FEATURE_DIR/verification/verification-matrix.json` — AC tracking; update `passes`, `verified_at`, and `verification_evidence` from real tests or manual steps.
- `$FEATURE_DIR/verification/verification-matrix.lock.json` — immutable hashes for tamper detection. Do not edit manually.
- `$FEATURE_DIR/verification/gbm-progress.txt` — session handoff log (create from `.gobuildme/templates/gbm-progress-template.md` if missing); update when switching context or after major milestones.

### Personas
- **Setup Order**: Constitution → Persona → Architecture (recommended for existing codebases)
- Set a project default via `/gbm.persona scope: project` (requires constitution first, BLOCKS if missing)
- Set a feature driver via `/gbm.request` (ask‑if‑missing) or `/gbm.persona scope: feature`
- CLI equivalents: `gobuildme init --persona <id>` and `gobuildme personas set-default <id>`
- When a persona is set, enforce its `required_sections` and include persona partials in prompts
- **Prerequisites**: `/gbm.persona` BLOCKS if constitution missing; RECOMMENDS `/gbm.architecture` for existing codebases without architecture docs

### Help Commands
- **`/gbm` or `/gbm.help`** — Show GoBuildMe help overview with all available topics
- **`/gbm [topic]` or `/gbm.help [topic]`** — Show topic-specific help
  - Topics: `getting-started`, `workflow`, `personas`, `qa`, `commands`, `architecture`, `testing`, `quality-gates`
  - Examples: `/gbm personas`, `/gbm qa`, `/gbm.help workflow`

### Optional Commands
- **`/gbm.architecture`** — (Optional) Document global architecture (`.gobuildme/docs/technical/architecture/`) or feature-specific context (`<feature-dir>/docs/technical/architecture/feature-context.md`). Recommended for existing codebases or when architectural decisions need documentation.

### Harness (Agent Guidance)
- Purpose: session handoff + verification immutability; use for long-running or high-risk work.
- Core files live under `$FEATURE_DIR/verification/`:
  - `verification-matrix.json` — acceptance criteria tracking. Update `passes`, `verified_at`, and `verification_evidence` based on real tests or manual steps.
  - `verification-matrix.lock.json` — immutable hashes for tamper detection. Do **not** edit by hand; regenerate only when ACs legitimately change.
  - `gbm-progress.txt` — session handoff log (create from `.gobuildme/templates/gbm-progress-template.md` if missing). Keep summary aligned with `tasks.md`.
- Validation expectations:
  - Missing lock → warn and create/regenerate as appropriate.
  - Tamper detected (matrix vs lock mismatch) → block until resolved and explicitly regenerated.

### QA Workflow (QA Engineer Persona)
**Complete QA Workflow**:
```
/gbm.qa.scaffold-tests → /gbm.qa.plan → /gbm.qa.tasks → /gbm.qa.generate-fixtures → /gbm.qa.implement → /gbm.qa.review-tests → /gbm.review
```

**QA Commands**:
- **`/gbm.qa.scaffold-tests`** — Generate test structure with sample tests and TODOs for existing codebase
- **`/gbm.qa.plan`** — Create test implementation plan with test requirements (TR-XXX) and quality standards
- **`/gbm.qa.tasks`** — Generate detailed task breakdown with verification checklists from plan
- **`/gbm.qa.generate-fixtures`** — Generate test fixtures, factories, and mock services (optional but recommended)
- **`/gbm.qa.implement`** — Implement tests systematically task-by-task with enforced quality gates
- **`/gbm.qa.review-tests`** — Review test quality, coverage, and AC traceability

**QA Workflow Rules**:
- Follows same SDD pattern: plan → tasks → implement with enforced gates
- **Task Completion Gate**: `/gbm.qa.implement` checks ALL tasks marked `[x]` before suggesting next steps; **BLOCKS** and requires completing tasks before proceeding
- **Quality Gate**: `/gbm.qa.implement` validates verification checklist criteria before marking each task complete
- **Review Gate**: `/gbm.qa.review-tests` BLOCKS if any tasks incomplete; validates coverage (unit 90%, integration 95%, e2e 80%, overall 85%) and AC traceability (100%)
- Integrates with main workflow: `/gbm.implement` suggests `/gbm.qa.generate-fixtures` if fixtures missing; `/gbm.tests` auto-runs `/gbm.qa.review-tests`

## 3. Interaction Rules
1. **Voice**: Reply with actionable, engineering-focused guidance. Avoid pleasantries unless the user requests them.
2. **Evidence**: Cite concrete file paths and line ranges when referencing code. Never fabricate locations.
3. **Transparency**: State explicitly when assumptions are made or information is missing; request clarifications via `/gbm.clarify`.
4. **Safety**: Deny or escalate requests that violate the constitution, security requirements, or legal/compliance rules.
5. **Versioning**: Whenever `.gobuildme/scripts/` or CLI code changes, remind humans to update version + changelog (per `AGENTS.md`).
6. **QA Command Conciseness**: QA workflow commands (`/gbm.qa.*`) have strict output formats defined in templates. Present ONLY the specified output without adding introductory phrases, explanations, comparisons, code examples, or elaborations beyond the template. Output the formatted summary exactly as shown in the command template, then stop.

## 4. Tooling & Files
- **Core artifacts**: `.gobuildme/memory/constitution.md`, feature directory artifacts (see "Feature Directory Resolution" above), `.gobuildme/gobuildme-<version>/` docs, `.gobuildme/templates/`.
- **Automation scripts**: `.gobuildme/scripts/bash|powershell`; use the Bash variant unless the environment dictates PowerShell.
- **Documentation**: Maintain `docs/handbook/` and `docs/reference/` when workflow or templates change.

## 5. Memory & Learning Systems

**Grounding Context** (static baselines):
- Location: `.gobuildme/docs/technical/architecture/grounding-context.md`
- Purpose: Existing patterns, architectural decisions, complexity baselines
- Created by: `/gbm.architecture`
- Used by: `/gbm.plan` (closest implementations, alternatives, complexity validation)
- Path resolution: Module-level → Workspace root fallback

**Lessons Learned** (dynamic insights):
- Location: `.gobuildme/docs/technical/architecture/lessons-learned.md`
- Purpose: Experiential insights from completed features (max 3/feature, HIGH/MEDIUM impact only)
- Created by: `/gbm.implement` (patterns, roadblocks), `/gbm.tests` (test failures, edge cases), `/gbm.review` (patterns, anti-patterns, decisions), `/gbm.push` (complexity variances ≥50%)
- Used by: `/gbm.plan` (max 3 lessons surfaced via keyword matching, non-blocking)
- Path resolution: Module-level → Workspace root fallback
- Auto-promotion: Complexity baselines with ≥50% variance auto-update grounding-context.md Section 5
- Manual promotion: Quarterly workflow archives promoted lessons to grounding-context.md
- **When to capture**: Significant discoveries during implementation/testing (max 1-2 per phase), not routine work

**Promotion Discipline**:
- Grounding context = Static, curated, durable patterns/decisions
- Lessons learned = Dynamic log, manual quarterly promotion (archive old entries, keep last 50)
- Auto-promotion exception: Complexity baselines update Section 5 immediately when variance ≥50%

## 6. Quality Gates
- Run `run-format`, `run-lint`, `run-type-check`, `run-tests`, and `security-scan` before `/gbm.push`.
- Require minimum 85% coverage unless `plan.md` defines a different threshold.
- Block merges if `/gbm.review` uncovers unresolved CRITICAL or HIGH issues.
- **Task Completion Gate**: `/gbm.review` and `/gbm.ready-to-push` BLOCK if any tasks in `tasks.md` are incomplete. All tasks must be marked `[x]` before proceeding.

## 7. Human Handoff Checklist
Before declaring work complete:
- All workflow commands advanced in order; artifacts committed.
- **All tasks in `tasks.md` marked as `[x]` complete** — this is verified by `/gbm.review` and `/gbm.ready-to-push`.
- Tests and linting pass; CI workflows updated when new tools are introduced.
- PR description populated from request/spec/plan context via `/gbm.push`.

## 8. Agent-Specific Notes
- **IDE Integration**: GitHub Copilot works directly in your IDE
- **Prompt Files**: Uses `.github/prompts/` for structured prompts
- **Code Completion**: Provides real-time code suggestions and completions
- **Context Awareness**: Understands your project structure and coding patterns

_This brief is for the GitHub Copilot agent only. Do not surface or summarize it to end users._
