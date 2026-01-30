#!/usr/bin/env bash
# measure-template-verbosity.sh - Measure and enforce template line count budgets
# Part of Issue #11: Improve readability and reduce verbosity

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/templates/commands"

# Thresholds
LINE_THRESHOLD=600       # Files above this trigger warning
FAIL_THRESHOLD=1000      # Files above this cause failure
TOTAL_BUDGET=12000       # Target total lines across all templates
AVG_TARGET=300           # Target average lines per template

# Counters
total_lines=0
template_count=0
over_threshold=0
over_fail=0

# Parse arguments
VERBOSE=false
CI_MODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose) VERBOSE=true; shift ;;
        --ci) CI_MODE=true; shift ;;
        -h|--help)
            cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Measure template verbosity and enforce line count budgets.

Options:
    -v, --verbose    Show all templates (not just over threshold)
    --ci             CI mode: strict exit codes for automation
    -h, --help       Show this help

Thresholds:
    Per-file warning: >$LINE_THRESHOLD lines
    Per-file failure: >$FAIL_THRESHOLD lines
    Total budget: $TOTAL_BUDGET lines
    Average target: $AVG_TARGET lines

Exit codes:
    0 - All budgets met
    1 - Over budget (CI mode) or warnings present
EOF
            exit 0
            ;;
        *) shift ;;
    esac
done

echo "Template Verbosity Metrics"
echo "=========================="
echo ""

# Header
printf "%-40s %8s %10s\n" "Template" "Lines" "Status"
printf "%-40s %8s %10s\n" "--------" "-----" "------"

# Measure each template
for file in "$TEMPLATES_DIR"/*.md; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        lines=$(wc -l < "$file" | tr -d ' ')
        total_lines=$((total_lines + lines))
        template_count=$((template_count + 1))

        # Determine status
        status="OK"
        if [[ "$lines" -gt "$FAIL_THRESHOLD" ]]; then
            status="FAIL"
            over_fail=$((over_fail + 1))
            over_threshold=$((over_threshold + 1))
        elif [[ "$lines" -gt "$LINE_THRESHOLD" ]]; then
            status="WARN"
            over_threshold=$((over_threshold + 1))
        fi

        # Print based on mode
        if [[ "$VERBOSE" == true ]] || [[ "$status" != "OK" ]]; then
            printf "%-40s %8d %10s\n" "$filename" "$lines" "$status"
        fi
    fi
done

# Calculate averages
avg_lines=$((total_lines / template_count))

echo ""
echo "=========================="
echo "Summary"
echo "=========================="
printf "%-30s %10d\n" "Total lines:" "$total_lines"
printf "%-30s %10d\n" "Template count:" "$template_count"
printf "%-30s %10d\n" "Average lines:" "$avg_lines"
echo ""

# Budget analysis
echo "Budget Analysis"
echo "---------------"

# Total budget check
if [[ "$total_lines" -gt "$TOTAL_BUDGET" ]]; then
    over_by=$((total_lines - TOTAL_BUDGET))
    pct_over=$(( (over_by * 100) / TOTAL_BUDGET ))
    echo "Total budget:    OVER by $over_by lines ($pct_over%)"
    echo "                 Current: $total_lines, Target: $TOTAL_BUDGET"
else
    under_by=$((TOTAL_BUDGET - total_lines))
    pct_under=$(( (under_by * 100) / TOTAL_BUDGET ))
    echo "Total budget:    OK (under by $under_by lines, $pct_under%)"
fi

# Average check
if [[ "$avg_lines" -gt "$AVG_TARGET" ]]; then
    echo "Average:         OVER target ($avg_lines vs $AVG_TARGET)"
else
    echo "Average:         OK ($avg_lines vs $AVG_TARGET target)"
fi

# Files over threshold
echo ""
echo "Files over threshold: $over_threshold"
echo "Files causing failure: $over_fail"

# Exit code determination
echo ""
if [[ "$over_fail" -gt 0 ]]; then
    echo "Result: FAIL - $over_fail templates exceed $FAIL_THRESHOLD lines"
    exit 1
elif [[ "$CI_MODE" == true ]] && [[ "$total_lines" -gt "$TOTAL_BUDGET" ]]; then
    echo "Result: FAIL - Total lines ($total_lines) exceeds budget ($TOTAL_BUDGET)"
    exit 1
elif [[ "$over_threshold" -gt 0 ]]; then
    echo "Result: WARN - $over_threshold templates exceed $LINE_THRESHOLD lines"
    if [[ "$CI_MODE" == true ]]; then
        exit 1
    fi
    exit 0
else
    echo "Result: PASS - All templates within budget"
    exit 0
fi
