# GoBuildMe Progress Notes

Feature: {{FEATURE_NAME}}
Persona: {{PERSONA_ID}}
Participants: [{{PARTICIPANT_PERSONAS}}]

## Summary

Total Tasks: {{TOTAL_TASKS}}
Completed: {{COMPLETED_TASKS}}
Remaining: {{REMAINING_TASKS}}
Progress: {{PROGRESS_PERCENTAGE}}%

## Session History

### Session 1 — {{SESSION_TIMESTAMP}}

**Status**: in-progress
**Phase**: {{CURRENT_PHASE}}
**Tasks Completed This Session**: 0

**Issues Encountered**:
- None yet

**Verification Results**:
- Initial session — no verification yet

**Next Steps (Priority Order)**:
1. Review specification and tasks
2. Begin implementation

**Notes for Next Session**:
- Feature work initialized
- Ready to begin implementation

---

<!--
INSTRUCTIONS FOR AI AGENT:

When updating this file at the END of each session:

1. Copy the "Session N" template below and add it at the TOP of Session History
2. Update the Summary section with current counts (use tasks.md checkbox counts)
3. Fill in all session fields accurately
4. BEFORE COMMITTING: Run branch guard to prevent commits to main:
   - Bash: `.gobuildme/scripts/bash/guard-protected-branch.sh --quiet || exit 1`
   - PowerShell: `.gobuildme/scripts/powershell/guard-protected-branch.ps1 -Quiet; if ($LASTEXITCODE -ne 0) { exit 1 }`
5. Commit the updated file (only after branch guard passes)

SESSION TEMPLATE (copy and customize):

### Session N — YYYY-MM-DD HH:MM UTC

**Status**: in-progress | completed | blocked
**Phase**: Analysis | Implementation | Testing | Review | Release
**Tasks Completed This Session**: <count>
- [x] Task <id>: <description>
- [x] Task <id>: <description>

**Issues Encountered**:
- <issue description and resolution>
- <issue description and resolution>

**Verification Results**:
- <how tasks were verified — test results, manual checks, etc.>

**Next Steps (Priority Order)**:
1. Task <id>: <description>
2. Task <id>: <description>
3. Task <id>: <description>

**Notes for Next Session**:
- <important context for the next agent/session>
- <any blockers or dependencies to be aware of>
- <architectural decisions made and why>

---
-->
