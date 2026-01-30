# Architecture Context Loading - Detailed Reference

> **Purpose**: Complete instructions for loading architecture context before command execution.
> **Used by**: specify.md, plan.md, implement.md, tests.md, review.md

---

## Quick Reference (Inline in Templates)

```markdown
**Architecture Context** (MANDATORY): Load from architecture directories resolved by `get_architecture_dirs()`.
Search order: module-level → workspace/monorepo root.
If missing and codebase exists, run `/gbm.architecture` first.
```

---

## Monorepo/Workspace Support

GoBuildMe supports three deployment models with different architecture loading behavior:

| Model | Architecture Search Order | Constitution Location |
|-------|--------------------------|----------------------|
| Single Repo | `<repo>/.gobuildme/docs/technical/architecture/` | `<repo>/.gobuildme/memory/constitution.md` |
| Monorepo | Module first → repo root | `<repo-root>/.gobuildme/memory/constitution.md` |
| Workspace | Repo first → workspace root | `<workspace-root>/.gobuildme/memory/constitution.md` |

### Root Resolution Functions

**Use these helper functions from `common.sh`/`common.ps1`**:

```bash
# Get architecture directories in search order (module → root)
ARCH_DIRS=$(get_architecture_dirs)

# Get constitution path (always at workspace/monorepo root)
CONSTITUTION_PATH=$(get_constitution_path)

# Get deployment mode: "single" | "monorepo" | "workspace"
MODE=$(get_mode)
```

**Environment Variable Overrides**:
- `GOBUILDME_TARGET_ROOT` — Override nearest `.gobuildme/` (for feature artifacts)
- `GOBUILDME_WORKSPACE_ROOT` — Override workspace root (for constitution)
- `GOBUILDME_MODE` — Force deployment mode

---

## Detailed Steps

### Step 1: Determine If Architecture Is Required

**Architecture REQUIRED when**:
- Codebase exists outside `.gobuildme/` directory
- Any source files present (*.py, *.js, *.ts, *.go, etc.)

**Architecture OPTIONAL when**:
- New/empty project (no existing code)
- Only `.gobuildme/` files exist

### Step 2: Resolve Architecture Directories

**For monorepo/workspace support**:
1. Source `common.sh` (or `common.ps1`)
2. Call `get_architecture_dirs()` to get ordered list of directories
3. Search order: module-level first → workspace/monorepo root second

**Example in monorepo**:
```
CWD: /platform-services/apps/api-service/
Search order:
  1. /platform-services/apps/api-service/.gobuildme/docs/technical/architecture/
  2. /platform-services/.gobuildme/docs/technical/architecture/
```

### Step 3: Verify Architecture Documentation Exists

Check for these files in each architecture directory (in search order):

| File | Contains | Required |
|------|----------|----------|
| system-analysis.md | Architectural style, patterns, decisions | Yes |
| technology-stack.md | Languages, frameworks, dependencies | Yes |
| security-architecture.md | Auth patterns, security controls | Yes |
| integration-landscape.md | External services, APIs | If integrations exist |
| data-architecture.md | Database patterns, data models | If data layer exists |
| feature-context.md | Feature-specific architecture | Per feature |

**Loading priority**: Module-level files override root-level files for the same document.

### Step 4: If Architecture Documentation MISSING

**For existing codebases** (BLOCKING):
1. Stop current command execution
2. Display error: "❌ Architecture documentation required. Run `/gbm.architecture` first."
3. Do not proceed until documentation exists

**For new/empty projects**:
- Skip architecture loading
- Proceed with command

### Step 5: Load Architecture Documentation

Read and internalize from each discovered directory (module → root):
1. **system-analysis.md**: Understand codebase style, patterns, key decisions
2. **technology-stack.md**: Know available technologies and versions
3. **security-architecture.md**: Understand auth/authz patterns
4. **integration-landscape.md**: Know external dependencies
5. **data-architecture.md**: Understand data models and access patterns

### Step 6: Load Constitution (NON-NEGOTIABLE)

**Constitution is ALWAYS at workspace/monorepo root**:
```bash
CONSTITUTION_PATH=$(get_constitution_path)
# Returns: <workspace_root>/.gobuildme/memory/constitution.md
```

- Single repo: `<repo>/.gobuildme/memory/constitution.md`
- Monorepo: `<repo-root>/.gobuildme/memory/constitution.md`
- Workspace: `<workspace-root>/.gobuildme/memory/constitution.md`

**Constitution is never per-module** — all modules/repos share the same constitution.

### Step 7: Load Feature-Specific Context

If working on a feature:
- Check `$FEATURE_DIR/docs/technical/architecture/feature-context.md`
- Load feature-specific patterns and decisions
- Note any deviations from global architecture

### Step 8: Validation

Before proceeding, confirm:
- [ ] All required architecture files loaded (from at least one search path)
- [ ] Patterns and conventions understood
- [ ] Technology constraints noted
- [ ] Security requirements identified
- [ ] Constitution loaded and principles noted

---

## Error Messages

| Condition | Message |
|-----------|---------|
| Missing system-analysis.md (all paths) | "❌ Architecture required: Run `/gbm.architecture` to analyze codebase" |
| Missing technology-stack.md (all paths) | "❌ Tech stack documentation missing: Run `/gbm.architecture`" |
| Feature context missing | "⚠️ Feature architecture not found: Consider running `/gbm.architecture` for this feature" |
| Constitution missing | "❌ Constitution required: Run `/gbm.constitution` to establish project governance" |

---

## Shell Script Integration

Scripts that support architecture loading:
- `scripts/bash/common.sh` — Contains `get_architecture_dirs()`, `get_constitution_path()`
- `scripts/powershell/common.ps1` — PowerShell equivalents
- `scripts/bash/get-architecture-context.sh` — Returns JSON with architecture file paths and status
- `scripts/powershell/get-architecture-context.ps1` — PowerShell equivalent

These scripts return JSON with architecture file paths and status.

---

## Python Integration

For Python harness/verification modules:

```python
from gobuildme_cli.core.roots import (
    get_gobuildme_root,
    get_workspace_root,
    get_architecture_dirs,
    get_constitution_path,
    get_mode,
)

# Get architecture directories in search order
arch_dirs = get_architecture_dirs()

# Get constitution path
constitution_path = get_constitution_path()

# Get deployment mode
mode = get_mode()  # "single" | "monorepo" | "workspace"
```
