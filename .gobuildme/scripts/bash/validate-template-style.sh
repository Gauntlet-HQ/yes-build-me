#!/usr/bin/env bash
# validate-template-style.sh - Validate templates follow concise output style guidelines
# Part of Issue #11: Improve readability and reduce verbosity

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/templates/commands"

# Default configuration
VERBOSE=false
CHECK_ONLY=false
TARGET_FILE=""

# Banned terms (verbose language to avoid)
BANNED_TERMS=(
    "comprehensive"
    "exhaustive"
    "in order to"
    "It is recommended that"
    "The following is a list"
    "As previously mentioned"
)

# Allowlist - terms OK in specific contexts
ALLOWLIST=(
    "comprehensive test coverage"
    "comprehensive architecture"
    "comprehensive-review"
)

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [FILE]

Validate templates follow concise output style guidelines.

Options:
    -v, --verbose       Show detailed output
    -c, --check-only    Check without suggestions (exit code only)
    -h, --help          Show this help

If FILE is provided, validates only that file.
Otherwise validates all templates in templates/commands/.

Exit codes:
    0 - All validations passed
    1 - Validation failures found
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose) VERBOSE=true; shift ;;
        -c|--check-only) CHECK_ONLY=true; shift ;;
        -h|--help) usage ;;
        *) TARGET_FILE="$1"; shift ;;
    esac
done

# Counters
TOTAL_FILES=0
PASSED_FILES=0
FAILED_FILES=0
WARNINGS=0

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo "$@"
    fi
}

check_style_block() {
    local file="$1"
    local filename
    filename=$(basename "$file")

    # Skip non-command templates
    if [[ "$filename" == _* ]]; then
        return 0
    fi

    if grep -q "## Output Style Requirements" "$file"; then
        log_verbose "  [PASS] Has Output Style Requirements section"
        return 0
    else
        echo "  [WARN] Missing Output Style Requirements section"
        ((WARNINGS++))
        return 0
    fi
}

check_banned_terms() {
    local file="$1"
    local filename
    filename=$(basename "$file")
    local found_banned=false

    # Skip style guide files (they document banned terms)
    if [[ "$filename" == _* ]]; then
        log_verbose "  [SKIP] Style guide file - banned term checks not applicable"
        return 0
    fi

    for term in "${BANNED_TERMS[@]}"; do
        # Check if term exists but isn't in allowlist context
        if grep -i "$term" "$file" > /dev/null 2>&1; then
            local is_allowed=false
            for allowed in "${ALLOWLIST[@]}"; do
                if grep -i "$allowed" "$file" > /dev/null 2>&1; then
                    # Check if the banned term appears only in allowlisted context
                    local count_banned
                    local count_allowed
                    count_banned=$(grep -ci "$term" "$file" || echo 0)
                    count_allowed=$(grep -ci "$allowed" "$file" || echo 0)
                    if [[ "$count_banned" -le "$count_allowed" ]]; then
                        is_allowed=true
                        break
                    fi
                fi
            done

            if [[ "$is_allowed" == false ]]; then
                echo "  [WARN] Contains banned term: '$term'"
                ((WARNINGS++))
                found_banned=true
            fi
        fi
    done

    if [[ "$found_banned" == false ]]; then
        log_verbose "  [PASS] No banned terms found"
    fi
}

count_metrics() {
    local file="$1"
    local total_lines
    local section_count

    total_lines=$(wc -l < "$file" | tr -d ' ')
    section_count=$(grep -c "^## " "$file" || echo 0)

    log_verbose "  Lines: $total_lines, Sections: $section_count"

    # Check if file is excessively long
    if [[ "$total_lines" -gt 600 ]]; then
        echo "  [WARN] File is $total_lines lines (target: <600)"
        ((WARNINGS++))
    fi
}

validate_file() {
    local file="$1"
    local filename
    filename=$(basename "$file")

    echo "Validating: $filename"
    ((TOTAL_FILES++))

    local file_warnings=$WARNINGS

    check_style_block "$file"
    check_banned_terms "$file"
    count_metrics "$file"

    if [[ $WARNINGS -eq $file_warnings ]]; then
        ((PASSED_FILES++))
        log_verbose "  Result: PASS"
    else
        ((FAILED_FILES++))
        log_verbose "  Result: NEEDS ATTENTION"
    fi

    echo ""
}

# Main execution
echo "Template Style Validation"
echo "========================="
echo ""

if [[ -n "$TARGET_FILE" ]]; then
    if [[ -f "$TARGET_FILE" ]]; then
        validate_file "$TARGET_FILE"
    else
        echo "Error: File not found: $TARGET_FILE"
        exit 1
    fi
else
    # Validate all command templates
    for file in "$TEMPLATES_DIR"/*.md; do
        if [[ -f "$file" ]]; then
            validate_file "$file"
        fi
    done
fi

# Summary
echo "========================="
echo "Summary"
echo "========================="
echo "Total files: $TOTAL_FILES"
echo "Passed: $PASSED_FILES"
echo "Need attention: $FAILED_FILES"
echo "Total warnings: $WARNINGS"

if [[ $WARNINGS -gt 0 ]]; then
    exit 1
else
    echo ""
    echo "All validations passed!"
    exit 0
fi
