#!/usr/bin/env bash
# Purpose : Validate that architecture documentation exists and contains actual analysis.
# Why     : Ensures architecture docs are comprehensive and not just raw data or stubs.
# How     : Checks for file existence, structure (## headings), content quality, and minimum length.
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

arch_dir=".gobuildme/docs/technical/architecture"
errors=0
warnings=0

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    errors=$((errors+1))
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}" >&2
    warnings=$((warnings+1))
}

log_info() {
    echo -e "${GREEN}✓ $1${NC}"
}

log_check() {
    echo -e "${BLUE}→ $1${NC}"
}

# Check if codebase exists (has code files outside .gobuildme)
has_codebase=false
for ext in php py js ts java go rb cs rs kt swift; do
    if find . -type f -name "*.$ext" ! -path "./.gobuildme/*" ! -path "./node_modules/*" ! -path "./venv/*" ! -path "./vendor/*" | grep -q .; then
        has_codebase=true
        break
    fi
done

if [ "$has_codebase" = false ]; then
    log_info "New/empty project detected - skipping global architecture validation"
    log_info "Architecture documentation not required for projects without existing code"
    exit 0
fi

log_check "Existing codebase detected - validating architecture documentation..."

# Check if architecture directory exists
if [ ! -d "$arch_dir" ]; then
    log_error "Architecture documentation directory not found: $arch_dir"
    log_error "Run '/gbm.architecture' to create comprehensive architecture documentation"
    exit 1
fi

# Required architecture files
required_files=(
    "system-analysis.md"
    "technology-stack.md"
    "security-architecture.md"
    "integration-landscape.md"
)

# Optional architecture files (warnings only)
optional_files=(
    "component-architecture.md"
    "data-architecture.md"
)

log_check "Validating required architecture documentation files..."

validate_file() {
    local file_name=$1
    local file_path="$arch_dir/$file_name"
    local required=$2  # "required" or "optional"

    log_check "Checking $file_name..."

    # Check file exists
    if [ ! -f "$file_path" ]; then
        if [ "$required" = "required" ]; then
            log_error "$file_name not found at $file_path"
        else
            log_warning "$file_name not found (optional, but recommended)"
        fi
        return 1
    fi

    # Check file is not empty
    if [ ! -s "$file_path" ]; then
        log_error "$file_name exists but is empty"
        return 1
    fi

    # Check minimum line count (at least 50 lines for comprehensive analysis)
    line_count=$(wc -l < "$file_path")
    if [ "$line_count" -lt 50 ]; then
        log_warning "$file_name has only $line_count lines (expected at least 50 for comprehensive analysis)"
    fi

    # Check for major sections (## headings)
    section_count=$(grep -c "^## " "$file_path" || true)
    if [ "$section_count" -lt 3 ]; then
        log_error "$file_name lacks proper structure (found $section_count major sections, expected at least 3)"
        return 1
    fi

    # Check for placeholder content
    if grep -qi "TODO\|PLACEHOLDER\|FILL THIS IN\|XXX\|FIXME" "$file_path"; then
        log_warning "$file_name contains placeholder content (TODO/PLACEHOLDER/FIXME markers)"
    fi

    # Check for raw data indicators (shouldn't be present in analysis files)
    if grep -qi "^### Raw Data\|^## Raw Data Collection" "$file_path"; then
        log_error "$file_name appears to contain raw data instead of analysis"
        log_error "This file should contain YOUR architectural analysis, not raw script output"
        return 1
    fi

    # File-specific validation
    case "$file_name" in
        "system-analysis.md")
            # Should contain architectural style/pattern analysis
            if ! grep -qi "architecture\|pattern\|style\|design" "$file_path"; then
                log_warning "$file_name should contain architectural style and pattern analysis"
            fi
            ;;
        "technology-stack.md")
            # Should contain technology decisions and rationale
            if ! grep -qi "framework\|library\|database\|technology" "$file_path"; then
                log_warning "$file_name should document technology stack and decisions"
            fi
            ;;
        "security-architecture.md")
            # Should contain security patterns and mechanisms
            if ! grep -qi "authentication\|authorization\|security\|encryption" "$file_path"; then
                log_warning "$file_name should document security patterns and mechanisms"
            fi
            ;;
        "integration-landscape.md")
            # Should contain integration points and protocols
            if ! grep -qi "integration\|api\|service\|endpoint" "$file_path"; then
                log_warning "$file_name should document integration points and protocols"
            fi
            ;;
    esac

    log_info "$file_name validated successfully ($line_count lines, $section_count sections)"
    return 0
}

# Validate required files
for file in "${required_files[@]}"; do
    validate_file "$file" "required" || true
done

# Validate optional files
for file in "${optional_files[@]}"; do
    validate_file "$file" "optional" || true
done

# Check for data-collection.md (should exist but shouldn't be the only file)
if [ -f "$arch_dir/data-collection.md" ]; then
    log_info "data-collection.md found (raw data from scripts)"

    # Count actual analysis files (not including data-collection.md)
    analysis_file_count=0
    for file in "${required_files[@]}"; do
        if [ -f "$arch_dir/$file" ]; then
            analysis_file_count=$((analysis_file_count+1))
        fi
    done

    if [ "$analysis_file_count" -eq 0 ]; then
        log_error "Only data-collection.md found - AI agent must create actual analysis files"
        log_error "The shell scripts create data-collection.md with RAW DATA only"
        log_error "YOU (AI Agent) must analyze raw data and CREATE comprehensive architecture files"
    fi
fi

# Summary
echo ""
echo "================================"
echo "Architecture Documentation Validation Summary"
echo "================================"
echo "Errors: $errors"
echo "Warnings: $warnings"
echo ""

if [ $errors -gt 0 ]; then
    log_error "Architecture documentation validation failed ($errors error(s), $warnings warning(s))"
    echo ""
    echo "Required Actions:"
    echo "1. Run '/gbm.architecture' to create or update architecture documentation"
    echo "2. Ensure all required files contain comprehensive analysis (not just raw data)"
    echo "3. Verify each file has proper structure with major sections (## headings)"
    echo "4. Confirm files are comprehensive (at least 50 lines with meaningful content)"
    exit 1
elif [ $warnings -gt 0 ]; then
    log_warning "Architecture documentation validation passed with warnings ($warnings warning(s))"
    echo ""
    echo "Recommendations:"
    echo "- Address warnings to improve documentation quality"
    echo "- Remove placeholder content (TODO/FIXME markers)"
    echo "- Add more detail to files with fewer than 50 lines"
    exit 0
else
    log_info "Architecture documentation validation passed successfully!"
    echo ""
    echo "All required architecture documentation files exist and contain comprehensive analysis."
    exit 0
fi
