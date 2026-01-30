---
description: "End-to-end project review: architecture, conventions, security, tests, and deployment readiness. Updates tasks.md to mark Review phase tasks (RV1-RV4) as complete."
artifacts:
  - path: ".gobuildme/review/<feature>/review-summary.md"
    description: "Concise code review summary with findings, recommendations, and approval decision"
  - path: "$FEATURE_DIR/tasks.md"
    description: "Updated task breakdown with Review phase tasks (RV1-RV4) marked complete"
  - path: ".gobuildme/review/<feature>/review-details.md"
    description: "Full review details: all findings, complete context, code snippets (Tier 2 detail artifact)"
  - path: "$FEATURE_DIR/validation/slice-consistency-report.json"
    description: "Slice scope and constitution alignment validation results"
scripts:
  sh: scripts/bash/comprehensive-review.sh
  ps: scripts/powershell/comprehensive-review.ps1
---

## Output Style Requirements (MANDATORY)

**Review Output**:
- Verdict first: PASS / NEEDS ATTENTION / BLOCKED at top
- 3-5 bullets per category (more only for critical findings)
- Tables for finding lists: severity | file:line | action needed
- No restating what was reviewed - jump to findings

**Finding Format**:
- One-line description with severity prefix
- File path and line number inline
- Action verb (Fix, Add, Remove, Update)
- No explanations of "why this is bad" - link to docs if needed

**Recommendations**:
- Numbered action items only
- One action per item
- No general advice or best practices lectures

**Two-Tier Output Enforcement (Issue #51)**:
- Do NOT paste full code snippets, complete file contents, or verbose analysis to CLI
- Write full findings to: `.gobuildme/review/<feature>/review-details.md`
- CLI shows: top 3 findings per category + "Full details: `<path>`"
- Max 5 items per list; if more → "See `.gobuildme/review/<feature>/review-details.md` for N more"
- Summary artifact (review-summary.md) stays concise; details go to review-details.md

**Persona Context**: Loaded in step 2 with participants support. Multiple personas may be active (driver + participants), and their quality gates are merged.
For complete style guidance, see .gobuildme/templates/_concise-style.md

---

## Step 0: Orientation (MANDATORY — DO THIS FIRST)

Before ANY work, establish context by running these commands:

```bash
# 1. Resolve repo root (works from any subdirectory)
# Try git first, fallback to searching for .gobuildme/manifest.json
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  # Non-git project: search upward for .gobuildme/manifest.json
  dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.gobuildme/manifest.json" ]; then
      REPO_ROOT="$dir"
      break
    fi
    dir=$(dirname "$dir")
  done
fi
[ -z "$REPO_ROOT" ] && REPO_ROOT="$PWD"
cd "$REPO_ROOT"

# 2. Verify GoBuildMe project structure
if [ -d "$REPO_ROOT/.gobuildme/specs/" ]; then
    ls -la "$REPO_ROOT/.gobuildme/specs/"
else
    echo "No specs directory yet (run /gbm.request first)"
fi

# 3. Read progress notes (CRITICAL) — tolerant of missing file
cat "$FEATURE_DIR/verification/gbm-progress.txt" 2>/dev/null || echo "No progress file yet"

# 4. Review git history
if git rev-parse --git-dir >/dev/null 2>&1; then
    git log --oneline -15
else
    echo "Not a git repository - skipping git history"
fi

# 5. Load task status
cat "$FEATURE_DIR/tasks.md" 2>/dev/null | head -100

# 6. Count remaining work
grep -c "^\- \[ \]" "$FEATURE_DIR/tasks.md" 2>/dev/null || echo "0"
```

**DO NOT proceed until you understand**:
- What was completed in previous sessions
- What task you should work on next
- Any blockers or issues to be aware of

**If progress notes exist**: Resume from where the previous session left off.
**If no progress notes**: This is the first session — proceed normally and create progress notes at session end.

---

## Step 0.2: Branch Guard (MANDATORY — Before Any Commits)

**CRITICAL**: GoBuildMe prevents commits to protected branches (main, master, develop, etc.).

Run this check ONCE at session start to confirm you're on a feature branch:

**Bash**:
```bash
# Validate not on protected branch - BLOCKS if on main/master/develop
.gobuildme/scripts/bash/guard-protected-branch.sh
```

**PowerShell**:
```powershell
# Validate not on protected branch - BLOCKS if on main/master/develop
.gobuildme/scripts/powershell/guard-protected-branch.ps1
```

**If this fails**:
1. You are on a protected branch (e.g., `main`)
2. Create a feature branch: `git checkout -b <feature-name>`
3. **DO NOT proceed with review until on a feature branch**

**Why this matters**: The harness system requires commits at session end. Without this guard, commits would land on main.

**Inline usage** (before each commit in this template):
- Bash: `.gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1`
- PowerShell: `.gobuildme/scripts/powershell/guard-protected-branch.ps1 -Quiet; if ($LASTEXITCODE -ne 0) { exit 1 }`

---

## Step 0.5: Immutability Validation (MANDATORY — After Orientation)

**Purpose**: Detect tampering with verification matrix before proceeding with review.

**Check for Verification Matrix** at `$FEATURE_DIR/verification/verification-matrix.json`:

**If verification-matrix.json EXISTS**:

1. **Validate matrix integrity** (choose one method):

   **Option A - Manual validation** (always works):
   - Read `$FEATURE_DIR/verification/verification-matrix.json`
   - Read `$FEATURE_DIR/verification/verification-matrix.lock.json`
   - Compare each item's immutable fields (id, type, description, verification_method)
   - Check for added/deleted items between lock and current matrix
   - Mutable fields (passes, verified_at, verification_evidence) can change

   **Option B - CLI validation** (if gobuildme installed):
   ```bash
   gobuildme harness verify-validate <feature>
   ```

2. **Handle validation result**:

   - **SKIP** (no matrix): Continue with review — verification tracking not enabled for this feature

   - **WARN** (lock file missing): Display warning and suggest creating lock file, but proceed with review
     ```
     ⚠️ WARNING: Lock file missing for verification matrix
     Consider running: gobuildme harness create-lock <feature>
     Proceeding with review...
     ```

   - **PASS** (hashes match): Continue with review
     ```
     ✅ Verification matrix integrity validated
     ```

   - **BLOCK** (tampering detected): **STOP REVIEW IMMEDIATELY**
     ```
     ❌ BLOCKED: Verification matrix tampering detected

     Tampered Items:
       - V1, V2, V3

     To resolve:
       1. Restore original verification matrix values, OR
       2. Re-run /gbm.tasks to regenerate the matrix

     If changes were intentional, regenerate the lock file:
       gobuildme harness regenerate-lock <feature>

     DO NOT PROCEED with review until resolved.
     ```

**If verification-matrix.json DOES NOT EXIST**:
- Skip validation (opt-in feature — backwards compatible)
- Continue with review normally

**Why this gate matters**: Prevents scope drift by ensuring acceptance criteria and verification expectations remain unchanged after initial planning.

---

## Step 0.55: Slice Scope Consistency Validation (MANDATORY — If scope.json Exists)

**Purpose**: Ensure PR only touches files within declared scope and artifacts align with constitution principles.

**Run Slice Consistency Validation**:

```bash
# Check if scope.json exists (scope tracking enabled for this feature)
if [ -f "$FEATURE_DIR/scope.json" ]; then
    .gobuildme/scripts/bash/validate-slice-consistency.sh --json > /tmp/slice-validation.json 2>&1
    SLICE_STATUS=$?
else
    echo "Scope validation skipped (no scope.json)"
    SLICE_STATUS=255  # Skip marker
fi
```

**Handle validation result**:

- **SKIP** (no scope.json): Continue with review — scope tracking not enabled for this feature
  ```
  ℹ️ Scope validation skipped (no scope.json)
  ```

- **SKIP** (scope_precision: coarse): Scope not yet refined, file-level validation skipped
  ```
  ℹ️ Scope is coarse (not yet refined). Run /gbm.plan to refine.
  SKIP: File-level scope validation skipped for coarse scope.
  ```

- **PASS** (all checks pass): Continue with review
  ```
  ✅ Slice Consistency Validation: PASS
     - Scope: X files checked, 0 violations
     - Constitution: Y/Z principles addressed
     - Cross-slice: No overlaps detected
  ```

- **WARN** (non-blocking issues found): Display warnings, continue with review
  ```
  ⚠️ Slice Consistency Validation: WARN

  Warnings:
    - Constitution: Missing alignment for principles: library-first
    - Cross-slice: Potential overlap with slice 'frontend-ui' on src/shared/utils.py

  Advisory: Consider addressing before merge. Proceeding with review...
  ```

- **FAIL** (blocking violations in strict mode): **STOP REVIEW**
  ```
  ❌ BLOCKED: Slice scope violations detected

  Violations:
    - src/payments/handler.py: Outside declared scope
    - src/config/secrets.py: In excludes list

  To resolve:
    1. Update scope.json to include these files (if intentional), OR
    2. Remove out-of-scope changes from this PR
    3. Re-run /gbm.plan to update scope if feature requirements changed

  DO NOT PROCEED with review until resolved.
  ```

**Check enforcement mode** (read `$CONSTITUTION_PATH` or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`):
- **Strict mode** (`<!-- scope_enforcement: strict -->`): FAIL status **BLOCKS** review
- **Default mode** (setting missing or `warn`): FAIL status **WARNS** but continues

**Why this gate matters**: Ensures PRs stay within their declared scope, preventing scope creep and maintaining clear slice boundaries in epics.

---

## Step 0.6: Verification Status Check (MANDATORY — If Matrix Exists)

**Purpose**: Ensure acceptance criteria are verified before review.

**If verification-matrix.json EXISTS** (from Step 0.5):

1. **Count verified ACs**:
   ```bash
   MATRIX_FILE="$FEATURE_DIR/verification/verification-matrix.json"
   # Count verification items by type (more stable than ID prefix)
   TOTAL=$(grep -c '"type": "acceptance_criteria"' "$MATRIX_FILE" 2>/dev/null || echo "0")
   PASSING=$(grep -c '"passes": true' "$MATRIX_FILE" 2>/dev/null || echo "0")
   FAILING=$((TOTAL - PASSING))
   echo "Verification Status: $PASSING/$TOTAL ACs verified ($FAILING unverified)"
   ```

2. **Handle verification status**:

   - **ALL VERIFIED** (PASSING = TOTAL):
     ```
     ✅ Verification Status: X/X ACs verified
     All acceptance criteria have passing tests. Proceeding with review.
     ```

   - **SOME UNVERIFIED** (PASSING < TOTAL):
     ```
     ⚠️  Verification Status: X/Y ACs verified (Z unverified)

     Unverified ACs:
       - AC-001: [description] (test missing or failing)
       - AC-005: [description] (test missing or failing)

     Options:
       1. Return to /gbm.implement to add missing tests
       2. Return to /gbm.tests to update verification matrix
       3. Continue with review (document why ACs are unverified)

     Reason unverified ACs may be acceptable:
       - Deferred to future PR (documented in request.md)
       - Non-functional requirement tested manually
       - Infrastructure constraint (e.g., no prod access for perf tests)
     ```

     **Check enforcement mode** (read `$CONSTITUTION_PATH` or `$WORKSPACE_ROOT/.gobuildme/memory/constitution.md`):
     - **Strict mode** (`verification_required_before_review: true`): **BLOCK** review
     - **Default mode** (setting missing or `false`): **WARN** but continue

**Why this gate matters**: Verification matrix exists to track AC coverage. Unverified ACs during review may indicate incomplete implementation or missing test coverage. This gate surfaces the gap before push.

---

**Script Output Variables**: The `{SCRIPT}` output above provides key paths. Parse and use these values:
- `FEATURE_DIR` - Feature directory path (e.g., `.gobuildme/specs/<feature>/` or `.gobuildme/specs/epics/<epic>/<slice>/`)
- `AVAILABLE_DOCS` - List of available documentation files in the feature directory

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.review" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - **CRITICAL**: Capture the JSON output and extract the `command_id` field. Store this value - you MUST use it in the final step for track-complete.
   - Example: If output is `{"command_id": "abc-123", ...}`, store `command_id = "abc-123"`
   - Initialize error tracking: `script_errors = []`

2. **Load Persona Configuration** (with Participants Support):

   **Load feature persona file**:
   - Read `$FEATURE_DIR/persona.yaml`
   - Extract `feature_persona` (driver persona ID)
   - Extract `participants` (list of participant persona IDs, may be empty list or missing field)
   - If file missing, fall back to `default_persona` from `.gobuildme/config/personas.yaml`

   **Build active personas list**:
   - Active personas = [driver] + participants
   - Example: If driver=`backend_engineer` and participants=`[security_compliance, sre]`
   - Then active_personas = `[backend_engineer, security_compliance, sre]`
   - If participants empty or missing: active_personas = [driver] only

   **Merge quality gates for /review**:
   - For each persona in active_personas:
     * Read `.gobuildme/personas/<persona_id>.yaml`
     * Extract `defaults.quality_gates` list (may not exist for all personas)
     * Collect all gates into a merged list
   - Ensure ALL merged gates are validated during review
   - Example merged quality gates:
     * Backend Engineer: ["contracts_present", "migrations_planned"]
     * Security: ["threat_model_present", "data_classification"]
     * SRE: ["slos_defined", "rollback_plan"]
     * Result: All 6 persona gates must pass + standard gates

   **Include persona partials**:
   - For each persona in active_personas:
     * If `templates/personas/partials/<persona_id>/review.md` exists:
       - Include its content under a `### <Persona Name> Review Criteria` section
   - If no persona files exist, proceed as generalist

   **Error Handling**:
   - If participant persona file missing: Skip with warning, continue with remaining personas
   - If driver persona file missing: Fall back to default_persona
   - If no valid personas found: Proceed with standard quality gates only

   **Validation**:
   - Report which personas are active (driver + participants)
   - Show merged quality gates grouped by persona
   - All merged gates must pass for review to succeed

3. **Load All Available Context** (for comprehensive review):

   **3a. Feature-Specific Artifacts** (from complete workflow):
   - `$FEATURE_DIR/request.md` - Original user request and goals
   - `$FEATURE_DIR/spec.md` - Feature specification with acceptance criteria
   - `$FEATURE_DIR/plan.md` - Implementation plan and technology decisions
   - `$FEATURE_DIR/tasks.md` - Task breakdown and completion status
   - `$FEATURE_DIR/docs/references/` - External documentation summaries (if exists)
   - `.gobuildme/test-results/quality-review.md` - Test quality review results (if exists)
   - `.docs/implementations/<feature>/implementation-summary.md` - Implementation documentation (if exists)

   **3b. Architecture Documentation** (MANDATORY for existing codebases):

   **Root Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_architecture_dirs()` to get ordered list of architecture directories
   - Search order: module-level first → workspace/monorepo root second
   - Example: In monorepo module, checks `apps/api/.gobuildme/docs/technical/architecture/` then `<root>/.gobuildme/docs/technical/architecture/`

   **Architecture files to load** (from each discovered architecture directory):
   - `system-analysis.md` - Architectural patterns, boundaries, layering rules
   - `technology-stack.md` - Languages, frameworks, libraries, and approved technologies
   - `security-architecture.md` - Auth patterns, security requirements, compliance constraints
   - `integration-landscape.md` - External service integrations (if exists)
   - `$FEATURE_DIR/docs/technical/architecture/feature-context.md` - Feature-specific architectural context (if exists)

   **BLOCKING**: If codebase exists but no architecture files found in any searched directory → Stop and display: "❌ Architecture required. Run `/gbm.architecture` first."

   **Skip for**: New/empty projects with no existing source code.

   **3c. Governance & Principles** (NON-NEGOTIABLE):

   **Constitution Resolution** (for monorepo/workspace support):
   - Source `common.sh` and call `get_constitution_path()` to get constitution location
   - Constitution is ALWAYS at workspace/monorepo root (not per-module)

   - Constitution file contains organizational rules, security requirements, compliance constraints
   - **CRITICAL**: Constitution defines non-negotiable principles for review validation
   - Constitutional violations are automatically CRITICAL severity
   - Any implementation that conflicts with constitution must be flagged for revision

   **3d. OSS Licensing Policy** (MANDATORY for AI-generated code):
   - `.gobuildme/templates/reference/oss-licensing-policy.md` - Complete OSS licensing requirements
   - **CRITICAL**: Validates AI-generated code complies with Go/Caution/Stop roadmap
   - Required for any changes that add/modify dependencies via AI assistance
   - Constitution references this policy - both must be enforced together

   **Usage**:
   - Validate implementation against specification acceptance criteria
   - Check architectural compliance with documented patterns
   - Verify technology choices match approved technology stack
   - Validate security implementation follows security architecture
   - Ensure constitutional principles are enforced throughout implementation
   - **Validate OSS licensing compliance for AI-generated code and dependencies**

4. Perform end-to-end project review. Execute {SCRIPT} to systematically check all project aspects:

## Architecture-Aware Review Categories

5. **Architecture & Structure Compliance**
   - **Global Architecture Alignment**: Validate implementation follows global architectural patterns
   - **Feature Architecture Compliance**: Ensure feature implementation matches feature architecture context
   - **Technology Stack Consistency**: Verify use of technologies and frameworks from documented stack
   - **Security Architecture Compliance**: Validate security implementation follows security architecture patterns
   - **Integration Point Validation**: Check integration with existing system components
   - **Architectural Boundary Validation**: Ensure layer separation and dependencies respect boundaries
   - **Pattern Adherence**: Verify implementation follows established architectural patterns (MVC, microservices, etc.)
   - **Constitutional Compliance**: Verify compliance with project constitution and architectural principles
   - **Anti-Pattern Detection**: Check for architectural anti-patterns and violations
   - **Coupling Analysis**: Validate that changes respect forbidden couplings and maintain loose coupling

6. **Code Quality & Conventions**
   - Format validation (non-mutating)
   - Linting with detailed error analysis
   - Style guide adherence
   - Type checking thoroughness

7. **Testing & Coverage**
   - Test suite execution with stack detection
   - Coverage analysis and gap identification
   - **Quality Review Integration**: Check if `.gobuildme/test-results/quality-review.md` exists
     * If exists: Load and validate quality review results
     * Check `quality_review_passed=true` status
     * If quality review failed: Report issues and require fixes before proceeding
     * If missing: Suggest running `/gbm.tests` which auto-runs quality review
   - Test quality assessment (structure, TODOs, patterns)
   - **Acceptance Criteria validation**: Verify all ACs have corresponding tests
   - **AC implementation coverage**: Ensure implemented features satisfy all acceptance criteria
   - **AC traceability**: Verify 100% AC coverage (from quality review)

8. **Security & Compliance**
   - Security vulnerability scanning
   - Dependency security audit
   - Secrets and sensitive data detection
   - **OSS Licensing Compliance** (CRITICAL for AI-generated code):
     * Load OSS licensing policy from `.gobuildme/templates/reference/oss-licensing-policy.md`
     * **Check for new/modified dependencies**: Scan package manifests (package.json, requirements.txt, pom.xml, go.mod, etc.)
     * **Verify license documentation**: For each new/modified dependency, confirm:
       - [ ] License identified (MIT, Apache-2.0, GPL, etc.)
       - [ ] Roadmap category confirmed (Go / Caution / Stop)
       - [ ] Required approvals obtained:
         * Go: Engineering Director approval documented
         * Caution: Legal approval for distribution (if applicable)
         * Stop: Legal approval for any use
       - [ ] PR description includes OSS dependency table
       - [ ] Dependencies added to OSS inventory
       - [ ] Attribution preserved (license headers, NOTICE files)
     * **Validate against Roadmap**:
       - 🟢 **Go licenses** (MIT, Apache-2.0, BSD): Verify Engineering Director approval
       - 🟡 **Caution licenses** (LGPL, GPL with exceptions): Require Legal approval if distributed
       - 🔴 **Stop licenses** (AGPL, unlisted): Require Legal approval for any use
     * **Flag violations**:
       - CRITICAL: Stop-category dependency without Legal approval
       - CRITICAL: Caution-category dependency distributed without Legal approval
       - CRITICAL: Unlisted license (treat as Stop by default)
       - WARNING: Go-category dependency without Engineering Director approval
       - WARNING: Missing OSS dependency documentation in PR
     * **Escalation**: If non-compliant dependency found, recommend Legal Intake Form submission

9. **CI/CD & Deployment**
   - Branch status and merge readiness
   - CI workflow validation
   - Build and deployment checks
   - DevSpace sanity (optional): If the target project has `devspace.yml|yaml` and the CLI is present, run `devspace print config` (from the target repo root) to validate configuration shape; flag duplicate or conflicting ports. If running from a templates repo, set `GOBUILDME_TARGET_REPO` or pass `--repo <path>` to `.gobuildme/scripts/*/devspace-sanity.*`. Do not mutate config or cluster settings.

10. **Documentation & Maintenance**
   - Documentation completeness
   - Code comments and clarity
   - Changelog and version consistency

11. **Research Quality Assessment** (if applicable)
   - **Check for Research Files**: Look for `$FEATURE_DIR/research/` directory
   - **Fact-Check Results**: If `fact-check-report.md` exists, load and assess research quality
   - **Quality Score Review**: Report overall research quality score (A/B/C/D)
   - **Source Authority**: Validate that claims use Tier 1-2 authoritative sources
   - **Citation Quality**: Check that citations are properly formatted and traceable
   - **Advisory Status**: Research quality is informational only, does not block deployment
   - **Recommendation**: Display research quality in PR description for stakeholder visibility
   - **If No Fact-Check Results**: Suggest running `/gbm.fact-check` on research files to verify quality

12. **Lines of Code (LoC) Analysis** (if enabled in constitution)
   - Run `.gobuildme/scripts/bash/loc-analysis.sh` (or PowerShell twin) from repo root
   - **If `loc_constraints.enabled: true` in constitution**:
     * Report branch-level LoC totals vs. configured limits
     * Report artifact-level LoC breakdown vs. per-artifact limits
     * Flag exceeded limits based on mode (warn vs. strict)
   - **If `loc_constraints.enabled: false` or section missing**: Skip with note
   - **LoC Quality Gate** (based on mode):
     * `mode: warn` → Advisory only (🟡 Warning if exceeded)
     * `mode: strict` → Blocking (🔴 Fail if exceeded)
   - **Error Tracking**: If script fails, capture error but continue with review
   - **Include LoC summary in Review Output**:
     * Branch LoC: X / Y limit (status)
     * Files Changed: X / Y limit (status)
     * Exceeded Artifacts: list or "None"
   - **Recommendation**: If limits exceeded, suggest splitting into smaller PRs

## Review Output

The review generates:
- Executive summary with overall project health score
- Category-wise detailed findings with severity levels
- Actionable remediation plan with priorities
- Blocking issues that prevent deployment
- Recommendations for long-term maintainability

## Quality Gates

Each category must pass quality gates:
- 🟢 **Pass**: No issues or acceptable risk level
- 🟡 **Warning**: Issues present but not blocking
- 🔴 **Fail**: Critical issues that must be resolved

Review fails if any category shows 🔴 status.



## Task Completion Validation (MANDATORY)

Before proceeding with the review, you MUST validate that all tasks are completed:

12. **Load Tasks File**: Read `$FEATURE_DIR/tasks.md`

13. **Check Task Completion**: Verify all tasks are marked as complete with `[x]`
   - Count total tasks
   - Count completed tasks (marked with `[x]`)
   - Count incomplete tasks (marked with `[ ]`)
   - Identify which specific tasks are incomplete

14. **Task Completion Gate**:
   - 🟢 **PASS**: All tasks marked as `[x]` → Proceed with review
   - 🔴 **FAIL**: Any tasks marked as `[ ]` → **BLOCK** and require completion

15. **If Tasks Incomplete**:
   - List all incomplete tasks with their IDs and descriptions
   - Suggest running `/gbm.implement` to complete remaining tasks
   - **DO NOT PROCEED** with the review until all tasks are completed
   - Output clear message: "❌ Review blocked: X tasks incomplete. Complete all tasks before running /gbm.review"

16. **Task Completion Report**:
   ```
   Task Completion Status:
   ✓ Total Tasks: X
   ✓ Completed: Y [x]
   ✗ Incomplete: Z [ ]

   Status: [PASS/FAIL]
   ```

## Implementation Documentation Validation (MANDATORY)

As part of the full review, you MUST validate the implementation documentation:

1. **Check Documentation Exists**: Verify `.docs/implementations/<feature>/implementation-summary.md` exists and is complete

2. **Validate Documentation Quality**:
   - **Completeness**: All required sections are filled with meaningful content (not just placeholders)
   - **Accuracy**: Documentation reflects the actual implementation (cross-reference with git diff)
   - **Traceability**: Links to original request, tickets, and related documents are valid
   - **Actionability**: Deployment and rollback instructions are clear and executable

3. **Documentation Review Checklist**:
   **IMPORTANT**: Mark each item as `[x]` ONLY when verified and completed.

   - [ ] **Request Summary**: Contains ticket references and stakeholder information
   - [ ] **Implementation Scope**: Clearly defines what was/wasn't implemented
   - [ ] **Design Decisions**: Documents architectural and technical choices made
   - [ ] **Architecture Impact**: Describes effects on global and feature architecture
   - [ ] **Files Changed**: Accurate list of created/modified/deleted files
   - [ ] **Testing Approach**: Documents test strategy and actual coverage
   - [ ] **Dependencies**: Lists new/updated dependencies with versions
   - [ ] **Configuration**: Documents environment variables and config changes
   - [ ] **Deployment Notes**: Includes migration steps and verification procedures
   - [ ] **Known Issues**: Documents limitations and technical debt

4. **Documentation Quality Gates**:
   - 🔴 **CRITICAL**: Missing `.docs/implementations/<feature>/implementation-summary.md` → Must create before proceeding
   - 🔴 **CRITICAL**: Empty or placeholder sections → Must complete with actual content
   - 🟡 **WARNING**: Incomplete deployment notes → Should add detailed steps
   - 🟡 **WARNING**: Missing ticket references → Should link to original request sources
   - 🟡 **WARNING**: Missing cross-references to planning docs → Should link to `$FEATURE_DIR/` documents

5. **Mark Review Phase Tasks Complete** (MANDATORY):
   - Load tasks.md from FEATURE_DIR
   - Find all Phase 9 (Review) tasks (tasks starting with RV1, RV2, RV3, RV4)
   - Mark each Review task as complete by changing `[ ]` to `[x]`
   - Save updated tasks.md
   - Report: "✅ Marked X Review tasks complete in tasks.md"

   **Review tasks to mark complete**:
   - RV1: Fact-check architecture compliance review
   - RV2: Fact-check requirements coverage
   - RV3: Fact-check code quality standards
   - RV4: Fact-check documentation completeness

   **Why mark these complete**: The /gbm.review command performs all fact-checking, code review,
   architecture validation, and quality checks, so these tasks are inherently completed by running
   this command successfully.

## Persona-Aware Review Focus Areas

**Detecting Persona** (always do this):
1. Read: `.gobuildme/config/personas.yaml` → check `default_persona` field
2. Store the value in variable: `$CURRENT_PERSONA`
3. If file doesn't exist or field not set → `$CURRENT_PERSONA = null`

**All Personas - Recommended First Step**:
- **Review Quality Gates**: Assess whether all quality gates passed (architecture, code quality, testing, security, documentation). If any gates failed, address issues before proceeding.

**Standard Next Step** (for most personas):
- **If quality gates PASS**: Run `/gbm.push` to create pull request
- **If quality gates FAIL**: Return to `/gbm.implement` to address review findings

**Persona-Specific Review Focus Areas**:

**architect**: Ensure all architectural boundary violations are resolved · Verify non-functional requirements (NFRs) are met and validated · Confirm architectural patterns are consistently applied · Validate ADRs reflect actual implementation · Review architecture compliance report for residual risks

**backend_engineer**: Resolve API contract violations or inconsistencies · Address performance budget issues or latency concerns · Fix data model or migration safety issues · Ensure observability (metrics, logs, traces) is properly instrumented · Verify error handling patterns are complete and consistent

**frontend_engineer**: Address accessibility (WCAG 2.1 AA) violations or gaps · Fix performance budget failures (LCP, FID, CLS thresholds) · Resolve UX flow issues or incomplete state handling · Ensure responsive behavior works across all required breakpoints · Verify browser compatibility and cross-browser testing results

**fullstack_engineer**: Resolve API/UI integration issues or contract mismatches · Address end-to-end performance concerns (API latency + UI rendering) · Fix data model changes that impact UI behavior or state synchronization · Ensure error boundaries properly handle API errors in UI · Verify observability spans both frontend and backend layers

**qa_engineer**: Address acceptance criteria (AC) coverage gaps or missing tests · Fix failing tests or flaky test issues · Resolve test quality issues (incomplete TODOs, poor patterns, missing assertions) · Ensure non-functional tests (performance, security, load) are complete · Verify AC traceability matrix shows 100% coverage before pushing

**Exception**: If test gaps remain, return to `/gbm.tests` instead of `/gbm.implement`

**data_engineer**: Resolve data contract violations or schema drift issues · Address data quality rule failures or validation gaps · Fix freshness/latency SLA issues identified in monitoring · Ensure backfill/reprocessing strategy is safe and idempotent · Verify lineage, metadata, and runbooks are complete and accurate

**data_scientist**: Address statistical validity concerns or experimental design flaws · Resolve metric definition inconsistencies or calculation errors · Fix reproducibility issues (missing seeds, data snapshots, environment specs) · Ensure hypothesis testing results are properly documented with uncertainty · Verify bias considerations and caveats are clearly communicated

**Exception**: If methodology issues found, return to `/gbm.analyze` instead of `/gbm.implement`

**ml_engineer**: Resolve training/serving skew or feature parity issues · Address offline/online evaluation metric regressions · Fix model reproducibility issues (missing lineage, versions, artifacts) · Ensure drift/skew monitoring and alerting is properly configured · Verify rollback and canary deployment strategy is safe and tested

**sre**: Resolve CI/CD pipeline failures or environment drift issues · Address missing or incomplete runbooks and on-call documentation · Fix SLO/alert configuration issues or noisy/absent alerts · Ensure rollout/rollback procedures are safe and tested · Verify capacity planning and resource estimates are accurate

**security_compliance**: Resolve security vulnerabilities or dependency audit failures · Address secrets detection issues or sensitive data leaks · Fix authentication/authorization gaps or access control issues · Ensure threat model reflects actual implementation and controls · Verify compliance mapping and residual risk documentation is complete

**product_manager**: Ensure implementation matches acceptance criteria and user stories · Verify success metrics and measurement approach are ready for production · Confirm business requirements and constraints are fully addressed · Review risk assessment and ensure mitigation strategies are in place · Validate stakeholder sign-off is obtained before pushing to production

**Exception**: If scope issues found, return to `/gbm.specify` instead of `/gbm.implement`

**maintainer**: Resolve CI failures, flaky tests, or build issues before merge · Ensure release notes, version bumps, and changelog are complete · Address code quality issues (linting, formatting, type checking) · Verify ownership metadata (CODEOWNERS, issue labels) is updated · Confirm PR checklist items are satisfied and reviewers are assigned

**No persona set** ($CURRENT_PERSONA = null):
- Suggested: Run `/gbm.persona` first to set your role and get personalized guidance
- Default: Follow the standard next step above

$ARGUMENTS

- **CRITICAL**: Use the EXACT `command_id` value you captured in step 1. Do NOT use a placeholder or fake UUID.
17. Track command complete and trigger auto-upload:
    - Prepare results JSON per schema `docs/technical/telemetry-schemas.md#gbm-review` (include error details if command failed)
    - Run `.gobuildme/scripts/bash/post-command-hook.sh --command "gbm.review" --status "success|failure" --command-id "$command_id" --feature-dir "$SPEC_DIR" --results "$results_json" --quiet` from repo root (add `--error "$error_msg"` if failures occurred)
    - This handles both telemetry tracking AND automatic spec upload (if enabled in manifest)
    - If track-complete fails with "Command ID not found", you used the wrong command_id. Go back and check step 1 output.

## Persona-Aware Next Steps

**Detecting Persona** (always do this):
1. Read: `.gobuildme/config/personas.yaml` → check `default_persona` field
2. Store the value in variable: `$CURRENT_PERSONA`
3. If file doesn't exist or field not set → `$CURRENT_PERSONA = null`

**Review Quality Gates** (check first):
- ✅ All review checklists completed
- ✅ No blocking issues remaining
- ✅ Documentation updated

**Next Command**: `/gbm.push` (all personas)

**Focus varies by persona** - See `.gobuildme/templates/reference/persona-next-steps.md` for detailed guidance:
- Engineers: Merge readiness, deployment validation, build/asset optimization
- Data roles: Pipeline/model deployment, reproducibility validation
- QA: Final test validation, regression checks
- SRE/Security: Monitoring, rollback plans, security audit
- Architect/PM/Maintainer: Architecture compliance, stakeholder approval, release management

### If $CURRENT_PERSONA = null (no persona set)
**Suggested Action**: Run `/gbm.persona` first to set your role and get personalized guidance

**Generic Next Step**: `/gbm.push` to prepare for deployment

## Optional: Spec Repository Upload

After updating `tasks.md` with Review phase completion markers (RV1-RV4), you can optionally upload the spec directory:

→ `/gbm.upload-spec` - Upload specs to S3 for cross-project analysis and centralized storage

*Requires AWS credentials. Use `--dry-run` to validate access first.*

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Address review findings by editing code/tests/docs
- Re-run `/gbm.implement` or `/gbm.tests` if major issues found
- Review the generated review report for specific action items
- Re-run `/gbm.review` after fixes to verify improvements

---

## Final Step: Clean State Validation & Progress Notes (MANDATORY)

Before ending this session, you MUST ensure clean state AND update progress notes.

### Part 1: Clean State Checklist (REQUIRED before stopping)

```bash
# 1. Check for uncommitted changes
echo "=== Git Status ==="
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "❌ UNCOMMITTED CHANGES - commit or stash before stopping"
    git status --short
else
    echo "✓ Clean - no uncommitted changes"
fi

# 2. Verify review findings are documented
echo "=== Review Status ==="
if [ -f "$REPO_ROOT/.gobuildme/review/<feature>/review-summary.md" ]; then
    echo "✓ Review summary exists"
else
    echo "⚠️ Review summary not found - ensure review findings are documented"
fi
```

### ❌ NEVER end session with:
- Uncommitted changes
- Undocumented review findings
- Outdated progress notes

### ✅ ALWAYS end session with:
- Clean `git status`
- Review summary documented
- Progress notes capturing session work

---

### Part 2: Update Progress Notes

1. **Create or Update Progress File** at `$FEATURE_DIR/verification/gbm-progress.txt`:
   - If file doesn't exist: Create it using the template at `.gobuildme/templates/gbm-progress-template.md`
     * Replace placeholders: `{{FEATURE_NAME}}`, `{{PERSONA_ID}}`, `{{PARTICIPANT_PERSONAS}}`
     * Set initial task counts from tasks.md
   - Add new session entry at TOP of Session History section (follow template instructions)
   - Update Summary section with current task counts

2. **Session Entry Content** (add for each session):
   - Session number and timestamp
   - Status (in-progress, completed, blocked)
   - Current phase (Review)
   - Tasks completed this session (RV1-RV4 review tasks)
   - Issues encountered and resolutions
   - Verification results (review findings, quality gates passed/failed)
   - Next steps in priority order
   - Notes for next session (important context)

3. **Commit Progress Notes** (with branch guard):
   ```bash
   # Verify not on protected branch before committing
   .gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1
   git add $FEATURE_DIR/verification/gbm-progress.txt
   git commit -m "chore(<feature>): update progress notes - session N"
   ```

**Why this matters**: Progress notes enable the next agent/session to resume exactly where you left off without wasting tokens rediscovering state.

