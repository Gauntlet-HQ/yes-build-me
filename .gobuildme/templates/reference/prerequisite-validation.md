# Prerequisite Validation - Detailed Reference

> **Purpose**: Complete validation logic for command prerequisites.
> **Used by**: implement.md, specify.md, plan.md, tests.md, review.md

> **Path Convention**: `$FEATURE_DIR` resolves to `.gobuildme/specs/<feature>/` (standalone) or `.gobuildme/specs/epics/<epic>/<slice>/` (sliced).

---

## Quick Reference (Inline in Templates)

```markdown
**Prerequisites** (BLOCKING): Verify required artifacts exist before proceeding.
If missing, display error with required command and stop.
```

---

## Validation by Command

### /gbm.specify Prerequisites

| Artifact | Path | Error if Missing |
|----------|------|------------------|
| request.md | `$FEATURE_DIR/request.md` | "Run `/gbm.request` first" |

### /gbm.plan Prerequisites

| Artifact | Path | Error if Missing |
|----------|------|------------------|
| spec.md | `$FEATURE_DIR/spec.md` | "Run `/gbm.specify` first" |

### /gbm.implement Prerequisites

| Artifact | Path | Error if Missing |
|----------|------|------------------|
| tasks.md | `$FEATURE_DIR/tasks.md` | "Run `/gbm.tasks` first" |
| plan.md | `$FEATURE_DIR/plan.md` | "Run `/gbm.plan` first" |
| analysis complete | Phase 1 tasks checked | "Run `/gbm.analyze` first" |

### /gbm.tests Prerequisites

| Artifact | Path | Error if Missing |
|----------|------|------------------|
| Implementation complete | Phases 2-7 checked | "Run `/gbm.implement` first" |
| tasks.md | `$FEATURE_DIR/tasks.md` | "Task file missing" |

### /gbm.review Prerequisites

| Artifact | Path | Error if Missing |
|----------|------|------------------|
| Tests complete | Phase 8 checked | "Run `/gbm.tests` first" |
| implementation-docs.md | `$FEATURE_DIR/implementation-docs.md` | "Implementation docs missing" |

---

## Validation Logic

### Standard Check Pattern

```
1. Attempt to read artifact file
2. If file missing or empty:
   - Display error message with ❌ prefix
   - Show required command to generate artifact
   - BLOCK execution (do not proceed)
3. If file exists and valid:
   - Proceed with command
```

### Task Phase Validation

For commands that depend on task completion:

```
1. Load tasks.md
2. Parse task checkboxes for target phase(s)
3. Count checked [x] vs unchecked [ ] tasks
4. If any tasks unchecked in required phases:
   - Display warning with incomplete task count
   - List specific incomplete tasks
   - BLOCK or WARN based on command requirements
```

---

## Error Message Format

```markdown
❌ **Prerequisite missing**: [Artifact name]

**Required action**: Run `[command]` to generate this artifact.

**Why this is needed**: [Brief explanation of dependency]
```

---

## Shell Script Integration

Scripts that support prerequisite validation:
- `scripts/bash/check-prerequisites.sh`
- `scripts/powershell/check-prerequisites.ps1`

These scripts check artifact existence and return status codes.
