#!/usr/bin/env bash
# Purpose : Analyze Lines of Code (LoC) changes against constitution-defined limits
# Why     : Keep feature branches focused, PRs manageable, and implementations well-structured
# How     : Parses loc_constraints from constitution.md, counts changed lines per artifact,
#           and reports violations (advisory by default, blocking in strict mode)
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Resolve repository and feature context
if ! eval "$(get_feature_paths)"; then
    echo "Failed to resolve feature paths" >&2
    exit 1
fi

cd "$REPO_ROOT"

# Configuration
CONSTITUTION_FILE="$REPO_ROOT/.gobuildme/memory/constitution.md"
BASE_REF="${LOC_ANALYSIS_BASE:-origin/main}"
VERBOSE="${LOC_ANALYSIS_VERBOSE:-false}"
SKIP="${LOC_ANALYSIS_SKIP:-false}"

# Skip if requested
if [ "$SKIP" = "true" ]; then
    echo "LoC analysis skipped (LOC_ANALYSIS_SKIP=true)"
    exit 0
fi

# Check if constitution exists
if [ ! -f "$CONSTITUTION_FILE" ]; then
    echo "No constitution file found at $CONSTITUTION_FILE"
    echo "LoC analysis requires constitution.md with loc_constraints section"
    exit 0
fi

# Extract loc_constraints configuration from constitution
# Uses simple grep/sed for bash 3.2 compatibility (no associative arrays)

extract_yaml_value() {
    local key="$1"
    local default="$2"
    grep -E "^[[:space:]]*${key}:" "$CONSTITUTION_FILE" 2>/dev/null | head -1 | sed "s/.*${key}:[[:space:]]*//" | sed 's/[[:space:]]*#.*//' | tr -d '"' || echo "$default"
}

# Check if loc_constraints is enabled
LOC_ENABLED=$(extract_yaml_value "enabled" "false")
if [ "$LOC_ENABLED" != "true" ]; then
    if [ "$VERBOSE" = "true" ]; then
        echo "LoC analysis disabled in constitution (enabled: $LOC_ENABLED)"
    fi
    exit 0
fi

# Get configuration values
LOC_MODE=$(extract_yaml_value "mode" "warn")
MAX_LOC=$(extract_yaml_value "max_loc_per_feature" "1000")
MAX_FILES=$(extract_yaml_value "max_files_per_feature" "30")
BASE_REF_CONFIG=$(extract_yaml_value "base_ref" "origin/main")
OUTPUT_DETAIL=$(extract_yaml_value "output_detail" "summary")
MAX_EXCEEDED=$(extract_yaml_value "max_exceeded_display" "5")

# Override base ref from config if not set via env
if [ -z "${LOC_ANALYSIS_BASE:-}" ]; then
    BASE_REF="$BASE_REF_CONFIG"
fi

# Ensure base ref exists
if ! git rev-parse "$BASE_REF" >/dev/null 2>&1; then
    echo "Warning: Base ref '$BASE_REF' not found. Attempting fetch..."
    git fetch origin "$(echo "$BASE_REF" | sed 's|origin/||')" 2>/dev/null || true
    if ! git rev-parse "$BASE_REF" >/dev/null 2>&1; then
        echo "Warning: Cannot resolve base ref '$BASE_REF'"
        echo "LoC analysis skipped (base ref unresolved)"
        echo "Tip: Set LOC_ANALYSIS_BASE to a valid ref or ensure origin is fetched"
        exit 0
    fi
fi

# Extract exclusion patterns from constitution
extract_exclusions() {
    local in_exclude=false
    local patterns=""
    while IFS= read -r line; do
        if echo "$line" | grep -qE "^[[:space:]]*exclude:"; then
            in_exclude=true
            continue
        fi
        if [ "$in_exclude" = true ]; then
            # Exit if we hit another top-level key
            if echo "$line" | grep -qE "^[[:space:]]{0,3}[a-z_]+:"; then
                break
            fi
            # Extract pattern from list item
            if echo "$line" | grep -qE "^[[:space:]]*-"; then
                local pattern
                pattern=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr -d '"' | tr -d "'")
                if [ -n "$pattern" ]; then
                    patterns="$patterns $pattern"
                fi
            fi
        fi
    done < "$CONSTITUTION_FILE"
    echo "$patterns"
}

# Extract artifact definitions
# Format: name|path1,path2|max_loc
extract_artifacts() {
    local in_artifacts=false
    local in_artifact=false
    local current_name=""
    local current_paths=""
    local current_max=""

    while IFS= read -r line; do
        # Check for artifacts section start
        if echo "$line" | grep -qE "^[[:space:]]*artifacts:"; then
            in_artifacts=true
            continue
        fi

        if [ "$in_artifacts" = true ]; then
            # Exit if we hit another top-level key (not indented enough for artifacts content)
            if echo "$line" | grep -qE "^[[:space:]]{0,3}[a-z_]+:" && ! echo "$line" | grep -qE "^[[:space:]]+-"; then
                # Output last artifact if any
                if [ -n "$current_name" ] && [ -n "$current_paths" ] && [ -n "$current_max" ]; then
                    echo "${current_name}|${current_paths}|${current_max}"
                fi
                break
            fi

            # New artifact entry (starts with -)
            if echo "$line" | grep -qE "^[[:space:]]*-[[:space:]]*name:"; then
                # Output previous artifact if complete
                if [ -n "$current_name" ] && [ -n "$current_paths" ] && [ -n "$current_max" ]; then
                    echo "${current_name}|${current_paths}|${current_max}"
                fi
                current_name=$(echo "$line" | sed 's/.*name:[[:space:]]*//' | tr -d '"' | tr -d "'")
                current_paths=""
                current_max=""
                in_artifact=true
                continue
            fi

            if [ "$in_artifact" = true ]; then
                # Collect paths
                if echo "$line" | grep -qE "^[[:space:]]*-[[:space:]]*\".*\""; then
                    local path
                    path=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr -d '"' | tr -d "'")
                    if [ -z "$current_paths" ]; then
                        current_paths="$path"
                    else
                        current_paths="$current_paths,$path"
                    fi
                fi

                # Get max_loc
                if echo "$line" | grep -qE "^[[:space:]]*max_loc:"; then
                    current_max=$(echo "$line" | sed 's/.*max_loc:[[:space:]]*//' | tr -d '"')
                fi
            fi
        fi
    done < "$CONSTITUTION_FILE"

    # Output last artifact
    if [ -n "$current_name" ] && [ -n "$current_paths" ] && [ -n "$current_max" ]; then
        echo "${current_name}|${current_paths}|${current_max}"
    fi
}

# Convert glob pattern to regex for matching
glob_to_regex() {
    local pattern="$1"
    # Escape special regex chars except * and ?
    pattern=$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\[/\\[/g' | sed 's/\]/\\]/g')
    # Convert ** to match any path
    pattern=$(echo "$pattern" | sed 's/\*\*/DOUBLE_STAR_PLACEHOLDER/g')
    # Convert single * to match within path segment
    pattern=$(echo "$pattern" | sed 's/\*/[^/]*/g')
    # Convert ** placeholder back
    pattern=$(echo "$pattern" | sed 's/DOUBLE_STAR_PLACEHOLDER/.*/g')
    # Anchor at start and allow end match
    echo "^${pattern}$"
}

# Check if file matches any exclusion pattern
is_excluded() {
    local file="$1"
    local exclusions="$2"

    for pattern in $exclusions; do
        local regex
        regex=$(glob_to_regex "$pattern")
        if echo "$file" | grep -qE "$regex" 2>/dev/null; then
            return 0
        fi
    done
    return 1
}

# Find which artifact a file belongs to (first match wins)
find_artifact() {
    local file="$1"
    local artifacts="$2"

    echo "$artifacts" | while IFS='|' read -r name paths max_loc; do
        if [ -z "$name" ]; then continue; fi

        # Check each path pattern
        IFS=',' read -ra path_arr <<< "$paths"
        for pattern in "${path_arr[@]}"; do
            local regex
            regex=$(glob_to_regex "$pattern")
            if echo "$file" | grep -qE "$regex" 2>/dev/null; then
                echo "$name|$max_loc"
                return 0
            fi
        done
    done

    echo "UNMATCHED|0"
}

# Get changed files and their line counts
get_changed_files() {
    git diff --name-only "$BASE_REF"...HEAD 2>/dev/null || git diff --name-only "$BASE_REF" HEAD
}

# Count non-blank, non-comment lines (heuristic)
# Strips:
#   - blank lines
#   - single-line comments: //, #, --, <!--
#   - naive block comments: /* ... */ and triple-quoted Python docstrings (''' ... ''' or """ ... """)
count_lines() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi

    awk '
        BEGIN { in_block = 0; in_py_doc = 0; }

        # Detect start/end of C/JS-style block comments
        /\/\*/ { in_block = 1 }
        /\*\// { if (in_block) { in_block = 0; next } }

        # Detect start/end of Python triple-quoted docstrings (single or double quotes)
        /"""/ {
            if (in_py_doc == 0) { in_py_doc = 1; next }
            else { in_py_doc = 0; next }
        }
        /'''/ {
            if (in_py_doc == 0) { in_py_doc = 1; next }
            else { in_py_doc = 0; next }
        }

        {
            # Skip if inside any block/docstring
            if (in_block || in_py_doc) { next }

            line = $0
            # Trim leading/trailing whitespace
            sub(/^\s+/, "", line); sub(/\s+$/, "", line)
            if (line == "") { next }
            if (line ~ /^\/\//) { next }
            if (line ~ /^#/) { next }
            if (line ~ /^--/) { next }
            if (line ~ /^<!--/) { next }
            count++
        }
        END { print count + 0 }
    ' "$file"
}

# Main analysis
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    LOC ANALYSIS REPORT                        ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║ Branch: $(printf '%-52s' "$CURRENT_BRANCH") ║"
echo "║ Base: $(printf '%-54s' "$BASE_REF") ║"
echo "║ Mode: $(printf '%-54s' "$LOC_MODE ($([ "$LOC_MODE" = "strict" ] && echo "blocking" || echo "advisory"))") ║"
echo "╠══════════════════════════════════════════════════════════════╣"

# Get exclusions and artifacts
EXCLUSIONS=$(extract_exclusions)
ARTIFACTS=$(extract_artifacts)

if [ "$VERBOSE" = "true" ]; then
    echo "║ Exclusions: $(printf '%-48s' "$(echo $EXCLUSIONS | wc -w | tr -d ' ') patterns") ║"
    echo "║ Artifacts: $(printf '%-49s' "$(echo "$ARTIFACTS" | grep -c '|' || echo 0) defined") ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
fi

# Analyze changed files
TOTAL_LOC=0
TOTAL_FILES=0
EXCEEDED_COUNT=0

# Store artifact totals (using temp files for bash 3.2 compatibility)
ARTIFACT_TOTALS_FILE=$(mktemp)
EXCEEDED_FILE=$(mktemp)
trap 'rm -f "$ARTIFACT_TOTALS_FILE" "$EXCEEDED_FILE"' EXIT

# Initialize artifact totals
echo "$ARTIFACTS" | while IFS='|' read -r name paths max_loc; do
    if [ -n "$name" ]; then
        echo "${name}|0|${max_loc}" >> "$ARTIFACT_TOTALS_FILE"
    fi
done

# Process each changed file
for file in $(get_changed_files); do
    # Skip if excluded
    if is_excluded "$file" "$EXCLUSIONS"; then
        if [ "$VERBOSE" = "true" ]; then
            echo "  [excluded] $file"
        fi
        continue
    fi

    # Skip if file doesn't exist (deleted files)
    if [ ! -f "$file" ]; then
        continue
    fi

    # Count lines
    loc=$(count_lines "$file")
    TOTAL_LOC=$((TOTAL_LOC + loc))
    TOTAL_FILES=$((TOTAL_FILES + 1))

    # Find artifact and update totals
    artifact_info=$(find_artifact "$file" "$ARTIFACTS")
    artifact_name=$(echo "$artifact_info" | cut -d'|' -f1)

    if [ "$artifact_name" != "UNMATCHED" ]; then
        # Update artifact total in temp file
        if grep -q "^${artifact_name}|" "$ARTIFACT_TOTALS_FILE" 2>/dev/null; then
            current=$(grep "^${artifact_name}|" "$ARTIFACT_TOTALS_FILE" | cut -d'|' -f2)
            max=$(grep "^${artifact_name}|" "$ARTIFACT_TOTALS_FILE" | cut -d'|' -f3)
            new_total=$((current + loc))
            sed -i.bak "s/^${artifact_name}|.*/${artifact_name}|${new_total}|${max}/" "$ARTIFACT_TOTALS_FILE" 2>/dev/null || \
                sed -i '' "s/^${artifact_name}|.*/${artifact_name}|${new_total}|${max}/" "$ARTIFACT_TOTALS_FILE"
        fi
    fi
done

# Display branch totals
echo "║ BRANCH TOTALS                                                 ║"
echo "║ ────────────────────────────────────────────────────────────── ║"

LOC_STATUS="✓ OK"
LOC_OVER=false
if [ "$TOTAL_LOC" -gt "$MAX_LOC" ]; then
    LOC_STATUS="⚠ OVER"
    LOC_OVER=true
    EXCEEDED_COUNT=$((EXCEEDED_COUNT + 1))
fi
printf "║ Total LoC Changed: %-6d / %-6d limit               %s ║\n" "$TOTAL_LOC" "$MAX_LOC" "$LOC_STATUS"

FILES_STATUS="✓ OK"
FILES_OVER=false
if [ "$TOTAL_FILES" -gt "$MAX_FILES" ]; then
    FILES_STATUS="⚠ OVER"
    FILES_OVER=true
    EXCEEDED_COUNT=$((EXCEEDED_COUNT + 1))
fi
printf "║ Files Changed: %-10d / %-6d limit               %s ║\n" "$TOTAL_FILES" "$MAX_FILES" "$FILES_STATUS"

# Display artifact breakdown
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║ ARTIFACT BREAKDOWN                                            ║"
echo "║ ────────────────────────────────────────────────────────────── ║"

while IFS='|' read -r name total max; do
    if [ -z "$name" ] || [ "$total" = "0" ] && [ "$OUTPUT_DETAIL" != "full" ]; then
        continue
    fi

    status="✓ OK"
    if [ "$total" -gt "$max" ]; then
        status="⚠ OVER"
        over_by=$((total - max))
        echo "${name}|${total}|${max}|${over_by}" >> "$EXCEEDED_FILE"
    fi
    printf "║ %-22s %6d / %-6d LoC               %s ║\n" "$name" "$total" "$max" "$status"
done < "$ARTIFACT_TOTALS_FILE"

# Show exceeded artifacts
if [ -s "$EXCEEDED_FILE" ]; then
    echo "╠══════════════════════════════════════════════════════════════╣"
    exceeded_total=$(wc -l < "$EXCEEDED_FILE" | tr -d ' ')
    printf "║ EXCEEDED LIMITS (%d artifact%s)                                ║\n" "$exceeded_total" "$([ "$exceeded_total" -gt 1 ] && echo "s" || echo " ")"
    echo "║ ────────────────────────────────────────────────────────────── ║"

    count=0
    while IFS='|' read -r name total max over_by; do
        count=$((count + 1))
        if [ "$count" -gt "$MAX_EXCEEDED" ] && [ "$OUTPUT_DETAIL" = "summary" ]; then
            remaining=$((exceeded_total - MAX_EXCEEDED))
            printf "║   ... and %d more exceeded artifacts                         ║\n" "$remaining"
            break
        fi
        printf "║   %s: %d LoC (+%d over limit)\n" "$name" "$total" "$over_by"
    done < "$EXCEEDED_FILE"
fi

echo "╚══════════════════════════════════════════════════════════════╝"

# Determine exit status based on mode
if [ "$LOC_MODE" = "strict" ]; then
    if [ -s "$EXCEEDED_FILE" ] || [ "$LOC_OVER" = "true" ] || [ "$FILES_OVER" = "true" ]; then
        echo ""
        echo "❌ STRICT MODE: LoC limits exceeded. Push blocked."
        echo "   Reduce scope or split into smaller PRs."
        exit 1
    fi
fi

# Advisory mode - always succeed but show status
if [ -s "$EXCEEDED_FILE" ] || [ "$LOC_OVER" = "true" ] || [ "$FILES_OVER" = "true" ]; then
    echo ""
    echo "⚠️  Advisory: Some LoC limits exceeded. Consider splitting for better review quality."
else
    echo ""
    echo "✅ All LoC limits respected."
fi

exit 0
