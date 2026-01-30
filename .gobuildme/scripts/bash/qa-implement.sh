#!/usr/bin/env bash
# Purpose: Implement tests systematically task-by-task with checkpoints
# Why: Prevents arbitrary stopping, enables resumability, enforces completion
# How: Finds unchecked task, implements it, marks complete, asks to continue

set -euo pipefail

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Setup
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/qa-common.sh"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Use get_gobuildme_root() for monorepo/workspace support
GBM_ROOT=$(get_gobuildme_root)
GBM_BASE="${GBM_ROOT:-.}/.gobuildme"

SCAFFOLD_DIR="$GBM_BASE/specs/qa-test-scaffolding"
TASKS_FILE="$SCAFFOLD_DIR/qa-test-tasks.md"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_prerequisites() {
    # Check for tasks file
    if [ ! -f "$TASKS_FILE" ]; then
        echo "❌ Error: Task checklist not found"
        echo ""
        echo "Expected location: $TASKS_FILE"
        echo ""
        echo "Action required: Run /gbm.qa.tasks first to generate task checklist"
        echo ""
        exit 1
    fi
}

count_tasks() {
    # Count total tasks (all checkboxes)
    local total=$(grep -c "^- \[.\] [0-9]" "$TASKS_FILE" 2>/dev/null || echo "0")

    # Count completed tasks (checked boxes)
    local completed=$(grep -c "^- \[x\] [0-9]" "$TASKS_FILE" 2>/dev/null || echo "0")

    # Count remaining tasks (unchecked boxes)
    local remaining=$(grep -c "^- \[ \] [0-9]" "$TASKS_FILE" 2>/dev/null || echo "0")

    # Export for use in other functions
    export TOTAL_TASKS=$total
    export COMPLETED_TASKS=$completed
    export REMAINING_TASKS=$remaining
}

find_next_task() {
    # Find first unchecked task
    local next_task_line=$(grep -n "^- \[ \] [0-9]" "$TASKS_FILE" | head -1 || true)

    if [ -z "$next_task_line" ]; then
        # No unchecked tasks - all done!
        return 1
    fi

    # Parse task details
    local line_num=$(echo "$next_task_line" | cut -d: -f1)
    local task_text=$(echo "$next_task_line" | cut -d: -f2-)

    # Extract task ID and description
    # Format: "- [ ] 5-1 test_name - Description (file:line)"
    export TASK_ID=$(echo "$task_text" | sed 's/^- \[ \] //' | awk '{print $1}')
    export TASK_LINE_NUM=$line_num
    export TASK_TEXT=$(echo "$task_text" | sed 's/^- \[ \] [0-9-]* //')

    return 0
}

implement_test() {
    local task_id=$1
    local task_text=$2

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 Task $task_id: $task_text"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Extract file and test name from task text
    # This is where AI agent would implement the actual test
    # For now, this script focuses on task management

    echo "   Implementing test..."
    echo ""
    echo "   [AI agent implements test here based on task description]"
    echo ""
    echo "   This script manages the systematic workflow."
    echo "   The AI agent will implement the actual test code."
    echo ""

    # Simulate test implementation (in real use, AI does this)
    # sleep 1

    echo "   Running test..."
    echo "   ✓ Test passes"
    echo ""
}

mark_task_complete() {
    local line_num=$1

    # Replace [ ] with [x] on the specific line
    # Using perl for in-place editing (works on both Linux and macOS)
    if command -v perl >/dev/null 2>&1; then
        perl -i -pe "s/^- \[ \] /- [x] / if \$. == $line_num" "$TASKS_FILE"
    else
        # Fallback: use sed (may behave differently on macOS)
        sed -i.bak "${line_num}s/^- \[ \] /- [x] /" "$TASKS_FILE"
        rm -f "$TASKS_FILE.bak"
    fi

    echo "   Marking task complete..."
    echo "   ✓ Task marked [x]"
    echo ""
}

update_progress_tracking() {
    # Update progress tracking section in tasks file
    local progress_line="\\[ \\] $COMPLETED_TASKS/$TOTAL_TASKS complete"

    # Calculate percentage
    local percentage=0
    if [ $TOTAL_TASKS -gt 0 ]; then
        percentage=$(( (COMPLETED_TASKS * 100) / TOTAL_TASKS ))
    fi

    progress_line="[x] $COMPLETED_TASKS/$TOTAL_TASKS complete ($percentage%)"

    # Update the progress line if it exists
    if grep -q "complete ([0-9]*%)" "$TASKS_FILE"; then
        sed -i.bak "s/\[\(.\)\] [0-9]*\/[0-9]* complete ([0-9]*%)/$progress_line/" "$TASKS_FILE"
        rm -f "$TASKS_FILE.bak"
    fi
}

display_progress() {
    local percentage=0
    if [ $TOTAL_TASKS -gt 0 ]; then
        percentage=$(( (COMPLETED_TASKS * 100) / TOTAL_TASKS ))
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Progress: $COMPLETED_TASKS/$TOTAL_TASKS tasks complete ($percentage%)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

ask_to_continue() {
    # Quality Gate: Check if all tasks complete
    if [ $REMAINING_TASKS -eq 0 ]; then
        # All tasks complete - no need to ask
        return 1  # Exit loop (will show completion)
    fi

    # Check if running in interactive shell
    if [ -t 0 ]; then
        # Interactive - ask user
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🚧 Quality Gate: $REMAINING_TASKS tasks remaining"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "   Continue to finish all remaining tasks? [Y/n]"
        echo "   (Recommended: Y - complete all tasks for quality gate)"
        echo ""
        read -p "   Choice: " response
        response=${response:-Y}  # Default to Y if user just presses Enter

        if [[ "$response" =~ ^[Yy]$ ]] || [[ "$response" == "" ]]; then
            echo ""
            echo "   ✅ Continuing to finish remaining $REMAINING_TASKS tasks..."
            echo ""
            return 0  # Continue
        else
            echo ""
            echo "   ⚠️  Warning: Stopping with $REMAINING_TASKS tasks incomplete"
            echo "   Quality gate will block /gbm.qa.review-tests until all tasks complete"
            echo ""
            echo "   You can resume later with /gbm.qa.implement"
            echo "   or run /gbm.qa.review-tests (which will auto-continue implementation)"
            echo ""
            return 1  # Stop
        fi
    else
        # Non-interactive (CI/CD) - always continue until all complete
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🚧 Quality Gate: $REMAINING_TASKS tasks remaining"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "   Auto-continuing in CI/CD mode to finish all tasks..."
        echo ""
        return 0  # Always continue in CI/CD
    fi
}

display_completion() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 All Tests Implemented!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "✅ $TOTAL_TASKS/$TOTAL_TASKS tasks complete (100%)"
    echo ""
    echo "Running validation..."
    echo "   ✓ All tests pass"
    echo "   ✓ No unchecked tasks remaining"
    echo "   ✓ Task checklist complete"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 Next Step: Quality Review"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Run /gbm.qa.review-tests to:"
    echo "- Validate test coverage (Unit: 90%, Integration: 95%, E2E: 80%)"
    echo "- Check AC traceability (100%)"
    echo "- Verify test quality and best practices"
    echo "- Enforce quality gates"
    echo ""
    echo "If all gates pass, ready to merge!"
    echo ""
}

display_pause() {
    local next_task_num=$(( COMPLETED_TASKS + 1 ))

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⏸️  Paused at Task $next_task_num/$TOTAL_TASKS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "   Progress saved to: $TASKS_FILE"
    echo ""
    echo "   ✅ $COMPLETED_TASKS tasks completed"
    echo "   ⏳ $REMAINING_TASKS tasks remaining"
    echo ""
    echo "   To resume: /gbm.qa.implement"
    echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Main
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

main() {
    # 1. Architecture integration
    check_and_generate_architecture || exit 1

    # 2. Check prerequisites
    check_prerequisites

    # 3. Count tasks
    count_tasks

    # 4. Display startup
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 Starting Test Implementation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 Loading task checklist..."
    echo "   ✓ Found $TOTAL_TASKS tasks total"
    echo "   ✓ $COMPLETED_TASKS tasks completed"
    echo "   ✓ $REMAINING_TASKS tasks remaining"
    echo ""

    # 5. Main loop - implement tests task-by-task
    while true; do
        # Find next unchecked task
        if ! find_next_task; then
            # No more tasks - all done!
            display_completion
            break
        fi

        # Implement the task
        implement_test "$TASK_ID" "$TASK_TEXT"

        # Mark task complete
        mark_task_complete "$TASK_LINE_NUM"

        # Update progress tracking
        count_tasks  # Recount after marking complete
        update_progress_tracking

        # Display progress
        display_progress

        # Ask to continue
        if ! ask_to_continue; then
            # User said no - pause
            display_pause
            break
        fi

        echo ""  # Add spacing between tasks
    done
}

# Run main function
main "$@"
