# Concise Output Style Guide

> **Purpose**: Master reference for output style across all GoBuildMe command templates.
> **Usage**: Inline the "Standard Inline Block" at the top of each template. Reference this file for full details.

---

## Standard Inline Block

Copy this block to the top of each command template (after frontmatter):

```markdown
<!-- OUTPUT STYLE: 3-5 bullets per section (more if gates require), tables over prose,
     one-sentence intros, no restating instructions. Code: max 1 comment per 10 LOC,
     self-documenting names. See _concise-style.md for details. -->
```

---

## Code Output Guidelines

### Comment Discipline
- **Default target**: Max 1 comment per 10 lines of code
- Prefer self-documenting variable/function names over comments
- No "obvious" comments (e.g., `// increment counter` for `counter++`)
- No redundant docstrings that repeat function signature
- Block comments for complex algorithms only

### Structure
- No boilerplate scaffolding unless required by framework
- Prefer composition over inheritance explanations
- Show minimal viable implementation, not kitchen sink
- One responsibility per function/class

### Examples in Code
- 1-2 examples max per concept
- Use inline comments to explain, not separate blocks
- Reference external docs for comprehensive examples

---

## Markdown/Artifact Guidelines

### Section Structure
- **Guideline**: 3-5 bullets per section (more allowed when gates/requirements demand)
- One-sentence section intros (no multi-paragraph preambles)
- No "restating the instructions" content

### Format Preferences
- Tables over prose for comparisons, matrices, options
- Bullet lists for 3-7 items
- Numbered lists only for sequential steps
- Code blocks for technical details instead of descriptions

### Content Rules
- Action-first language ("Run X" not "You should run X")
- No motivational language ("Let's make this great!")
- No restating what user already knows
- Remove closing boilerplate ("This completes the...")

### Length Guidelines (Advisory)
These are authoring guidelines, not enforced by validation:
- Specification sections: ~50 lines max
- Plan sections: ~40 lines max
- Implementation tasks: ~30 lines per task
- Review findings: ~20 lines per category
- Help topics: ~100 lines per topic
- Persona guidance: ~5-10 lines (reference external for more)

**Enforced**: Total file length >600 lines triggers warning (see Validation section)

---

## Review/Summary Guidelines

### Format
- **Verdict first**: Pass/Fail/Warning at top
- **Bulleted actions**: What to do, not what was found
- **No input restating**: Don't repeat what was submitted

### Structure
```markdown
## Review Summary

**Status**: ✅ PASS | ⚠️ NEEDS ATTENTION | ❌ BLOCKED

### Issues Found
- [Severity] [File:Line] - [Action needed]

### Next Steps
- [Concrete action 1]
- [Concrete action 2]
```

---

## Two-Tier Output Pattern (MANDATORY - Issue #51)

> **Purpose**: Reduce cognitive load by separating summary (CLI) from details (artifacts).

### Tier 1: CLI Output (Summary)
- **Max 5 items per list**; if more: "See `<artifact-path>` for N more"
- **Max 30 lines inline code**; longer code → write to file, show path
- **Never paste raw logs**; redirect to artifact and summarize
- **Status verdict first** (✅/⚠️/❌) for review/analyze commands; progress summary for implement/tests

### Tier 2: Artifact Files (Details)
- Full findings, all context, complete code
- Raw logs, verbose output, full diffs
- Referenced from CLI: "Full details: `<artifact-path>`"

### Enforcement Rule
```
IF list.length > 5 OR code_block.lines > 30 OR output_is_raw_log:
  1. Write full content to detail artifact
  2. Display summary (max 5 items or 30 lines) in CLI
  3. Add: "Full details: `<artifact-path>`"
```

### Detail Artifact Paths by Command

> **Note**: `$FEATURE_DIR` resolves to `.gobuildme/specs/<feature>/` (standalone) or `.gobuildme/specs/epics/<epic>/<slice>/` (sliced).

| Command | Detail Artifact Path |
|---------|---------------------|
| `/gbm.implement` | `$FEATURE_DIR/logs/implementation-details.md` |
| `/gbm.review` | `.gobuildme/review/<feature>/review-details.md` |
| `/gbm.tests` | `.gobuildme/test-results/<feature>/test-output.md` |
| `/gbm.analyze` | `.gobuildme/analysis/<feature>/analysis-details.md` |
| `/gbm.qa.implement` | `$FEATURE_DIR/logs/qa-implementation-details.md` |

### Example Transformation

**Before (verbose CLI output)**:
```
## Test Results
Running tests...
PASS src/auth/login.test.ts (2.3s)
  ✓ should authenticate valid user (45ms)
  ✓ should reject invalid password (12ms)
  ✓ should handle missing email (8ms)
PASS src/auth/logout.test.ts (1.1s)
  ✓ should clear session (23ms)
  ✓ should redirect to login (15ms)
[... 200 more lines of test output ...]
```

**After (two-tier)**:
```
## Test Results
✅ 45/45 passing | Coverage: 87%

| Suite | Tests | Time |
|-------|-------|------|
| auth | 12/12 | 3.4s |
| api | 18/18 | 5.2s |
| utils | 15/15 | 1.1s |

Full output: `.gobuildme/test-results/<feature>/test-output.md`
```

---

## Word Choice

### Avoid → Prefer
- "comprehensive" → Context-specific replacement:
  - Reports/documentation: "complete yet concise"
  - Architectural documentation: "information-dense"
  - Lists/catalogs: "complete"
  - Test coverage: "comprehensive test coverage" (allowed - measurable metric)
- "detailed" → "thorough" or remove
- "exhaustive" → remove
- "in order to" → "to"
- "It is recommended that" → "Recommend:"
- "The following is a list" → just use the list
- "As previously mentioned" → remove and restructure

### Preferred Terms (Issue #11 - Verbosity Reduction)
Use these precise terms that combine completeness with conciseness:
- **"Complete yet concise"** - For reports, validation results, summaries
  - Example: "Complete yet concise validation report"
  - Explicitly states both completeness and brevity goals
- **"Information-dense"** - For documentation, analysis, architecture
  - Example: "Information-dense architectural documentation"
  - Emphasizes efficient use of space without sacrificing content
- **"Thorough"** - For processes, testing, research activities
  - Example: "thorough testing", "thorough research"
  - Describes process quality, not output verbosity

### Allowed in Context
These terms are OK when technically accurate:
- "comprehensive test coverage" (measurable metric)
- "comprehensive-review" (script filename reference)
- "detailed error message" (specific requirement)

---

## Validation

### What Gets Checked
The validator enforces three rules:

| Check | Severity | Description |
|-------|----------|-------------|
| Output Style section | WARN | Templates should have `## Output Style Requirements` |
| Banned terms | WARN | Verbose phrases without allowlisted context |
| File length | WARN | Files >600 lines need condensation |

**Not enforced by validator** (authoring guidelines only):
- Section bullet counts
- Per-section length limits
- Metrics thresholds

### Line Budget Thresholds

Separate budget script with CI integration:

| Threshold | Level | Description |
|-----------|-------|-------------|
| >600 lines | WARN | Individual template needs condensation |
| >1000 lines | FAIL | Individual template must be split/condensed |
| >12000 total | FAIL | Total across all templates exceeds budget |
| >300 avg | WARN | Average per template is too high |

### Run Validation
```bash
# Style validation
scripts/bash/validate-template-style.sh         # All templates
scripts/bash/validate-template-style.sh FILE    # Single file
scripts/bash/validate-template-style.sh -v      # Verbose

# Budget validation
scripts/bash/measure-template-verbosity.sh      # Summary report
scripts/bash/measure-template-verbosity.sh --ci # With exit codes for CI
```

### Banned Terms & Allowlist
**Banned**: comprehensive, exhaustive, "in order to", "It is recommended that", "The following is a list", "As previously mentioned"

**Allowed in context**: "comprehensive test coverage", "comprehensive architecture"

### Scope
- Checked: All `.md` in `templates/commands/` except `_*.md`
- Exempt from Output Style section: utility commands (ci-*, validate-*, branch-status, etc.)

---

## Examples

### Before (Verbose)
```markdown
## Architecture Context Loading

To ensure that your implementation follows the established architectural
patterns and conventions of the codebase, you must first load and understand the
comprehensive architectural documentation. This is a mandatory step that cannot
be skipped. The following steps outline the process:

**Step 1: Verify Architecture Documentation Exists**
First, you need to check if the architecture documentation exists...
[... 40 more lines ...]
```

### After (Concise)
```markdown
## Architecture Context Loading

Load architecture from `.gobuildme/docs/technical/architecture/`. If missing, run `/gbm.architecture` first.

**Required files**:
- system-analysis.md (patterns, decisions)
- technology-stack.md (languages, frameworks)
- security-architecture.md (auth patterns)

**Validation**: Proceed only when all files loaded.
```

---

### Before (Verbose Persona Guidance)
```markdown
### If $CURRENT_PERSONA = "backend_engineer"
**Next Command**: `/gbm.tests`

**What to Focus On**:
- Write contract tests for all API endpoints to ensure they conform to specifications
- Write integration tests for database operations including CRUD and transactions
- Test error handling and edge cases thoroughly
- Achieve 85% code coverage as a minimum threshold
- Focus on API contracts, business logic correctness, and database integration
- Ensure all async operations are properly tested
- Validate input sanitization and output formatting
- Test authentication and authorization flows
```

### After (Concise)
```markdown
### backend_engineer
**Next**: `/gbm.tests`
**Focus**: API contracts, DB operations, error handling (85% coverage target)
```

---

## Changelog

- 2025-11-21: Initial version for Issue #11
