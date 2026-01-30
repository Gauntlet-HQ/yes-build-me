#!/usr/bin/env bash
# Purpose: Validate slice scope consistency and constitution traceability
# Why:     Ensures PRs only touch files within declared scope and features
#          align with constitution principles
# How:     Compares git diff against scope.json/slice-registry allowed paths,
#          validates Constitution Alignment section against PRINCIPLE tags

set -euo pipefail

# =============================================================================
# SETUP
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Options
STRICT_MODE=false
OUTPUT_FORMAT="text"  # text | json
FEATURE_NAME=""
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --strict) STRICT_MODE=true; shift ;;
        --json) OUTPUT_FORMAT="json"; QUIET=true; shift ;;  # JSON mode implies quiet (logs go to report file)
        --feature) FEATURE_NAME="$2"; shift 2 ;;
        --quiet) QUIET=true; shift ;;
        -h|--help)
            echo "Usage: validate-slice-consistency.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --feature NAME    Feature/branch name to validate"
            echo "  --strict          Exit non-zero on any violations"
            echo "  --json            Output results as JSON (implies --quiet)"
            echo "  --quiet           Suppress informational messages"
            echo "  -h, --help        Show this help"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Resolve paths
GBM_ROOT=$(get_gobuildme_root)
if [[ -z "$GBM_ROOT" ]]; then
    echo "ERROR: GoBuildMe not initialized" >&2
    exit 1
fi

# Get feature name from branch if not specified
if [[ -z "$FEATURE_NAME" ]]; then
    FEATURE_NAME=$(get_current_branch)
fi

# Resolve feature directory
FEATURE_DIR=$(get_feature_dir "$FEATURE_NAME" 2>/dev/null) || {
    echo "ERROR: Cannot resolve feature directory for '$FEATURE_NAME'" >&2
    exit 1
}

SCOPE_FILE="$FEATURE_DIR/scope.json"

# =============================================================================
# GLOBALS FOR REPORT OUTPUT
# =============================================================================

SCOPE_STATUS="skip"
SCOPE_PRECISION="unknown"
FILES_CHECKED=0
VIOLATIONS_JSON="[]"

CONSTITUTION_STATUS="skip"
PRINCIPLES_TOTAL=0
PRINCIPLES_ADDRESSED=0
UNREFERENCED_JSON="[]"

OVERLAP_STATUS="skip"
OVERLAPS_JSON="[]"

OVERALL_STATUS="pass"
ENFORCEMENT_MODE="warn"

# Epic/slice context (populated by sync_scope_from_registry)
EPIC_SLUG=""
SLICE_NAME=""
REGISTRY_MODE="local"
MODULE_PATH=""
REPO_PATH=""

# =============================================================================
# DEPENDENCY DETECTION
# =============================================================================

HAS_JQ=$(command -v jq &>/dev/null && echo "true" || echo "false")
HAS_YQ=$(command -v yq &>/dev/null && echo "true" || echo "false")
HAS_PYYAML=$(python3 -c "import yaml" 2>/dev/null && echo "true" || echo "false")

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Log message (respects --quiet)
log() {
    [[ "$QUIET" == "true" ]] || echo "$@"
}

# JSON helper with Python fallback
json_get() {
    local file="$1"
    local key="$2"
    if [[ "$HAS_JQ" == "true" ]]; then
        jq -r ".$key // empty" "$file" 2>/dev/null
    else
        python3 -c "import json; d=json.load(open('$file')); print(d.get('$key', '') if d.get('$key') is not None else '')" 2>/dev/null || echo ""
    fi
}

# JSON array helper
json_get_array() {
    local file="$1"
    local key="$2"
    if [[ "$HAS_JQ" == "true" ]]; then
        jq -r ".$key // [] | .[]" "$file" 2>/dev/null
    else
        python3 -c "
import json
with open('$file') as f:
    d = json.load(f)
for item in d.get('$key', []):
    print(item)
" 2>/dev/null || echo ""
    fi
}

# YAML helper with fallback chain: yq -> Python yaml -> grep
yaml_get() {
    local file="$1"
    local key="$2"
    if [[ "$HAS_YQ" == "true" ]]; then
        yq ".$key" "$file" 2>/dev/null | grep -v '^null$' || echo ""
    elif [[ "$HAS_PYYAML" == "true" ]]; then
        python3 -c "
import yaml
with open('$file') as f:
    d = yaml.safe_load(f)
val = d.get('$key', '') if d else ''
print(val if val is not None else '')
" 2>/dev/null || echo ""
    else
        # Last resort: grep for simple top-level keys
        grep -E "^${key}:" "$file" 2>/dev/null | sed "s/^${key}:[[:space:]]*//" | tr -d '"' || echo ""
    fi
}

# Get base branch for git diff comparison
get_base_branch() {
    local constitution_path
    constitution_path=$(get_constitution_path 2>/dev/null)

    # 1. Check constitution for explicit config
    if [[ -n "$constitution_path" ]] && [[ -f "$constitution_path" ]]; then
        local constitution_branch
        constitution_branch=$(python3 -c "import re,sys; m=re.search(r'<!-- default_branch: (\w+)', open(sys.argv[1]).read()); print(m.group(1) if m else '')" "$constitution_path" 2>/dev/null || echo "")
        if [[ -n "$constitution_branch" ]]; then
            echo "$constitution_branch"
            return
        fi
    fi

    # 2. Try origin/HEAD
    local origin_head
    origin_head=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@')
    if [[ -n "$origin_head" ]]; then
        echo "$origin_head"
        return
    fi

    # 3. Fallback
    echo "main"
}

# Parse epic/slice from branch name (format: <epic>--<slice>)
parse_branch_for_epic() {
    local branch="$1"
    if [[ "$branch" == *"--"* ]]; then
        EPIC_SLUG="${branch%%--*}"
        SLICE_NAME="${branch#*--}"
        return 0
    fi
    return 1  # Not an epic slice branch
}

# Normalize git diff path to scope path format based on registry_mode
normalize_path_for_scope() {
    local file="$1"
    local mode="$2"
    local mod_path="$3"
    local repo_path="$4"

    case "$mode" in
        local)
            # No normalization needed - both repo-relative
            echo "$file"
            ;;
        cross_module)
            # Strip module_path prefix from repo-relative git diff path
            if [[ -n "$mod_path" ]] && [[ "$file" == "$mod_path/"* ]]; then
                echo "${file#$mod_path/}"
            else
                echo "$file"
            fi
            ;;
        cross_repo)
            # Prefix repo_path to repo-relative git diff path
            if [[ -n "$repo_path" ]]; then
                echo "$repo_path/$file"
            else
                echo "$file"
            fi
            ;;
        *)
            echo "$file"
            ;;
    esac
}

# Check if a file path matches allowed scope
# Returns 0 if in scope, 1 if out of scope
is_file_in_scope() {
    local file="$1"
    local scope_file="$2"

    # Use Python for reliable glob matching (pathlib handles ** correctly)
    python3 << EOF
import json
from pathlib import PurePath
import fnmatch

with open('$scope_file') as f:
    scope = json.load(f)

file_path = '$file'

# 1. CHECK EXCLUDES FIRST (explicit deny takes priority)
for pattern in scope.get('excludes', []):
    if fnmatch.fnmatch(file_path, pattern):
        exit(1)  # Explicitly excluded

# 2. CHECK EXPLICIT ALLOWED_FILES
if file_path in scope.get('allowed_files', []):
    exit(0)  # Exact match

# 3. CHECK ALLOWED_PATTERNS (glob matching)
for pattern in scope.get('allowed_patterns', []):
    # Handle ** patterns using PurePath.match
    if '**' in pattern:
        if PurePath(file_path).match(pattern):
            exit(0)
    elif fnmatch.fnmatch(file_path, pattern):
        exit(0)

exit(1)  # Not in any allowed path/pattern
EOF
    return $?
}

# =============================================================================
# SYNC SCOPE FROM REGISTRY
# =============================================================================

sync_scope_from_registry() {
    local branch
    branch=$(get_current_branch)

    # Try to parse epic/slice from branch name
    if ! parse_branch_for_epic "$branch"; then
        # Not an epic slice branch - check if scope.json has epic_slug
        if [[ -f "$SCOPE_FILE" ]]; then
            local existing_epic
            existing_epic=$(json_get "$SCOPE_FILE" "epic_slug")
            if [[ -z "$existing_epic" ]]; then
                return 0  # Not an epic slice
            fi
            EPIC_SLUG="$existing_epic"
            SLICE_NAME=$(json_get "$SCOPE_FILE" "slice_name")
        else
            return 0  # No scope.json and not epic branch
        fi
    fi

    local workspace_root
    workspace_root=$(get_workspace_root)
    local registry_path="$workspace_root/.gobuildme/specs/epics/$EPIC_SLUG/slice-registry.yaml"

    if [[ ! -f "$registry_path" ]]; then
        log "WARN: Registry not found at $registry_path"
        return 0
    fi

    log "INFO: Loading metadata from registry (epic: $EPIC_SLUG, slice: $SLICE_NAME)"

    # Extract registry mode
    REGISTRY_MODE=$(yaml_get "$registry_path" "mode")
    [[ -z "$REGISTRY_MODE" ]] && REGISTRY_MODE="local"

    # Find this slice in registry and extract metadata
    if [[ "$HAS_YQ" == "true" ]]; then
        MODULE_PATH=$(yq ".slices[] | select(.slice_name == \"$SLICE_NAME\") | .module_path // \"\"" "$registry_path" 2>/dev/null | grep -v '^null$' || echo "")
        REPO_PATH=$(yq ".slices[] | select(.slice_name == \"$SLICE_NAME\") | .repo_path // \"\"" "$registry_path" 2>/dev/null | grep -v '^null$' || echo "")
    elif [[ "$HAS_PYYAML" == "true" ]]; then
        read -r MODULE_PATH REPO_PATH < <(python3 -c "
import yaml
with open('$registry_path') as f:
    d = yaml.safe_load(f)
for s in d.get('slices', []):
    if s.get('slice_name') == '$SLICE_NAME':
        print(s.get('module_path') or '', s.get('repo_path') or '')
        break
else:
    print('', '')
" 2>/dev/null) || { MODULE_PATH=""; REPO_PATH=""; }
    fi
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

validate_slice_scope() {
    local violations=()

    # 1. Sync scope from registry (if epic) - loads metadata
    sync_scope_from_registry

    # 2. Check if scope.json exists
    if [[ ! -f "$SCOPE_FILE" ]]; then
        log "WARN: No scope.json found at $SCOPE_FILE"
        SCOPE_STATUS="skip"
        SCOPE_PRECISION="unknown"
        FILES_CHECKED=0
        VIOLATIONS_JSON="[]"
        return 0
    fi

    # 3. Check scope_precision - coarse scope skips file-level checks
    local scope_precision
    scope_precision=$(json_get "$SCOPE_FILE" "scope_precision")
    SCOPE_PRECISION="${scope_precision:-unknown}"

    if [[ "$scope_precision" == "coarse" ]] || [[ -z "$scope_precision" ]]; then
        log "INFO: Scope is coarse (not yet refined). Run /gbm.plan to refine."
        log "SKIP: File-level scope validation skipped for coarse scope."
        SCOPE_STATUS="skip"
        FILES_CHECKED=0
        VIOLATIONS_JSON="[]"
        return 0
    fi

    # 4. Load registry_mode from scope.json (may have been synced)
    local reg_mode
    reg_mode=$(json_get "$SCOPE_FILE" "registry_mode")
    [[ -n "$reg_mode" ]] && REGISTRY_MODE="$reg_mode"

    local mod_path
    mod_path=$(json_get "$SCOPE_FILE" "module_path")
    [[ -n "$mod_path" ]] && MODULE_PATH="$mod_path"

    local rp
    rp=$(json_get "$SCOPE_FILE" "repo_path")
    [[ -n "$rp" ]] && REPO_PATH="$rp"

    # 5. Get files changed in current branch vs base branch
    local base_branch
    base_branch=$(get_base_branch)
    local changed_files=""

    # Prefer merge-base for accurate diff
    local merge_base
    merge_base=$(git merge-base "origin/$base_branch" HEAD 2>/dev/null || echo "")

    if [[ -n "$merge_base" ]]; then
        changed_files=$(git diff --name-only "$merge_base"..HEAD 2>/dev/null || echo "")
    elif git rev-parse "origin/$base_branch" >/dev/null 2>&1; then
        changed_files=$(git diff --name-only "origin/$base_branch"..HEAD 2>/dev/null || echo "")
    elif git rev-parse "@{upstream}" >/dev/null 2>&1; then
        changed_files=$(git diff --name-only "@{upstream}"..HEAD 2>/dev/null || echo "")
    else
        log "WARN: No origin/$base_branch found, using HEAD~10 fallback"
        changed_files=$(git diff --name-only HEAD~10..HEAD 2>/dev/null || git diff --name-only HEAD 2>/dev/null || echo "")
    fi

    # 6. Filter changed files to only those under module path (if applicable)
    local relevant_files=()
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        # For cross_module, filter to files under module_path
        if [[ "$REGISTRY_MODE" == "cross_module" ]] && [[ -n "$MODULE_PATH" ]]; then
            if [[ "$file" == "$MODULE_PATH/"* ]]; then
                relevant_files+=("$file")
            fi
        else
            relevant_files+=("$file")
        fi
    done <<< "$changed_files"

    # 7. Check each relevant file against allowed paths/patterns
    for file in "${relevant_files[@]}"; do
        [[ -z "$file" ]] && continue
        local normalized_file
        normalized_file=$(normalize_path_for_scope "$file" "$REGISTRY_MODE" "$MODULE_PATH" "$REPO_PATH")

        if ! is_file_in_scope "$normalized_file" "$SCOPE_FILE"; then
            violations+=("$file")
        fi
    done

    # 8. Set output variables
    FILES_CHECKED=${#relevant_files[@]}
    if [[ ${#violations[@]} -gt 0 ]]; then
        SCOPE_STATUS="fail"
        VIOLATIONS_JSON=$(printf '%s\n' "${violations[@]}" | python3 -c "import sys,json; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))")
    else
        SCOPE_STATUS="pass"
        VIOLATIONS_JSON="[]"
    fi

    # 9. Report results
    if [[ ${#violations[@]} -gt 0 ]]; then
        log "SCOPE VIOLATIONS: ${#violations[@]} files outside declared scope"
        for v in "${violations[@]}"; do
            log "  - $v"
        done

        if [[ "$STRICT_MODE" == "true" ]]; then
            return 1
        fi
    else
        log "SCOPE CHECK: PASS - All $FILES_CHECKED relevant files within declared scope"
    fi
}

validate_constitution_alignment() {
    local spec_file="$FEATURE_DIR/spec.md"
    local plan_file="$FEATURE_DIR/plan.md"
    local constitution_path
    constitution_path=$(get_constitution_path)

    if [[ ! -f "$constitution_path" ]]; then
        log "WARN: No constitution found"
        CONSTITUTION_STATUS="skip"
        PRINCIPLES_TOTAL=0
        PRINCIPLES_ADDRESSED=0
        UNREFERENCED_JSON="[]"
        return 0
    fi

    # Extract principle IDs from constitution (HTML comments)
    local principles
    principles=$(python3 -c "import re,sys; print('\n'.join(m.group(1) for m in re.finditer(r'<!-- PRINCIPLE: (\S+)\s*-->', open(sys.argv[1]).read())))" "$constitution_path" 2>/dev/null || echo "")

    if [[ -z "$principles" ]]; then
        log "INFO: Constitution has no machine-readable principle tags"
        CONSTITUTION_STATUS="skip"
        PRINCIPLES_TOTAL=0
        PRINCIPLES_ADDRESSED=0
        UNREFERENCED_JSON="[]"
        return 0
    fi

    # Count total principles
    local principles_array=()
    while IFS= read -r p; do
        [[ -n "$p" ]] && principles_array+=("$p")
    done <<< "$principles"
    PRINCIPLES_TOTAL=${#principles_array[@]}

    # Check for explicit "Constitution Alignment" section in spec/plan
    local has_alignment_section=false
    local addressed_principles=()

    for file in "$spec_file" "$plan_file"; do
        if [[ -f "$file" ]]; then
            # Check for section header
            if grep -q "^## Constitution Alignment" "$file" 2>/dev/null; then
                has_alignment_section=true
                # Extract principle IDs from bullet list (- **principle-id**: ...)
                while IFS= read -r principle_ref; do
                    [[ -n "$principle_ref" ]] && addressed_principles+=("$principle_ref")
                done < <(python3 -c "import re,sys; print('\n'.join(m.group(1) for m in re.finditer(r'^\s*-\s+\*\*([^*]+)\*\*', open(sys.argv[1]).read(), re.MULTILINE)))" "$file" 2>/dev/null || echo "")
            fi
        fi
    done

    if [[ "$has_alignment_section" == "false" ]]; then
        log "WARN: No '## Constitution Alignment' section found in spec.md or plan.md"
        log "TIP: Add a section listing which principles this feature addresses"
        PRINCIPLES_ADDRESSED=0
        UNREFERENCED_JSON=$(printf '%s\n' "${principles_array[@]}" | python3 -c "import sys,json; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))")
        if [[ "$STRICT_MODE" == "true" ]]; then
            log "ERROR: Strict mode requires Constitution Alignment section"
            CONSTITUTION_STATUS="fail"
            return 1
        fi
        CONSTITUTION_STATUS="warn"
        return 0
    fi

    # Find unaddressed principles (excluding N/A marked ones)
    local unreferenced=()
    for principle in "${principles_array[@]}"; do
        local found=false
        for ref in "${addressed_principles[@]}"; do
            # Match principle or "N/A principle"
            if [[ "$ref" == "$principle" ]] || [[ "$ref" == "N/A $principle" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == "false" ]]; then
            unreferenced+=("$principle")
        fi
    done

    # Set output variables
    PRINCIPLES_ADDRESSED=$((PRINCIPLES_TOTAL - ${#unreferenced[@]}))
    if [[ ${#unreferenced[@]} -gt 0 ]]; then
        CONSTITUTION_STATUS="warn"
        UNREFERENCED_JSON=$(printf '%s\n' "${unreferenced[@]}" | python3 -c "import sys,json; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))")
    else
        CONSTITUTION_STATUS="pass"
        UNREFERENCED_JSON="[]"
    fi

    # Report
    if [[ ${#unreferenced[@]} -gt 0 ]]; then
        log "CONSTITUTION COVERAGE: ${#unreferenced[@]} principles not addressed"
        for u in "${unreferenced[@]}"; do
            log "  - $u"
        done
        if [[ "$STRICT_MODE" == "true" ]]; then
            log "ERROR: Strict mode requires all principles to be addressed"
            return 1
        fi
    else
        log "CONSTITUTION COVERAGE: All principles addressed"
    fi
}

validate_cross_slice_overlap() {
    # LIMITATION: Cross-slice overlap detection is LOCAL-ONLY
    # For cross_repo epics, slices in different repositories cannot be compared
    # because their scope.json files are in separate .gobuildme/ directories.
    # This function only checks slices within the same workspace root.
    # Future enhancement: resolve repo_path from registry to access remote scopes.

    if [[ -z "$EPIC_SLUG" ]]; then
        OVERLAP_STATUS="skip"
        OVERLAPS_JSON="[]"
        return 0  # Not part of an epic
    fi

    local workspace_root
    workspace_root=$(get_workspace_root)
    local registry="$workspace_root/.gobuildme/specs/epics/$EPIC_SLUG/slice-registry.yaml"
    local current_slice="$SLICE_NAME"

    if [[ ! -f "$registry" ]]; then
        OVERLAP_STATUS="skip"
        OVERLAPS_JSON="[]"
        return 0
    fi

    log "CROSS-SLICE CHECK: Validating no scope overlap (local workspace only)..."

    local overlaps=()

    # Get all slice names from registry
    local slice_names=""
    if [[ "$HAS_YQ" == "true" ]]; then
        slice_names=$(yq '.slices[].slice_name' "$registry" 2>/dev/null | grep -v '^null$' || echo "")
    elif [[ "$HAS_PYYAML" == "true" ]]; then
        slice_names=$(python3 -c "
import yaml
with open('$registry') as f:
    d = yaml.safe_load(f)
for s in d.get('slices', []):
    print(s.get('slice_name', ''))
" 2>/dev/null || echo "")
    fi

    # If we can't read slice names, skip overlap check
    if [[ -z "$slice_names" ]]; then
        log "WARN: Cannot read slice registry (install yq or PyYAML for overlap detection)"
        OVERLAP_STATUS="skip"
        OVERLAPS_JSON="[]"
        return 0
    fi

    # For each other slice, read its scope.json and compare
    while IFS= read -r other_slice; do
        [[ -z "$other_slice" ]] && continue
        [[ "$other_slice" == "$current_slice" ]] && continue

        local other_scope_file="$workspace_root/.gobuildme/specs/epics/$EPIC_SLUG/$other_slice/scope.json"
        if [[ ! -f "$other_scope_file" ]]; then
            continue  # Other slice doesn't have scope.json yet
        fi

        # Skip coarse slices - only compare refined scopes
        local other_precision
        other_precision=$(json_get "$other_scope_file" "scope_precision")
        if [[ "$other_precision" != "refined" ]]; then
            log "INFO: Skipping coarse slice '$other_slice' in overlap check"
            continue
        fi

        # Compare allowed_files between current and other slice (best-effort)
        local overlap_result
        overlap_result=$(python3 << EOF
import json
try:
    with open("$SCOPE_FILE") as f:
        current = json.load(f)
    with open("$other_scope_file") as f:
        other = json.load(f)

    current_files = set(current.get("allowed_files", []))
    other_files = set(other.get("allowed_files", []))
    overlap = current_files & other_files

    # Pattern overlap: exact string match only (best-effort)
    current_patterns = set(current.get("allowed_patterns", []))
    other_patterns = set(other.get("allowed_patterns", []))
    pattern_overlap = current_patterns & other_patterns

    if overlap or pattern_overlap:
        print(json.dumps({"slice": "$other_slice", "files": list(overlap), "patterns": list(pattern_overlap)}))
except Exception:
    pass
EOF
)
        if [[ -n "$overlap_result" ]]; then
            overlaps+=("$overlap_result")
        fi
    done <<< "$slice_names"

    if [[ ${#overlaps[@]} -gt 0 ]]; then
        log "WARN: Found scope overlap with other slices (best-effort detection):"
        for o in "${overlaps[@]}"; do
            log "  $o"
        done
        OVERLAP_STATUS="warn"
        OVERLAPS_JSON=$(printf '%s\n' "${overlaps[@]}" | python3 -c "import sys,json; print(json.dumps([json.loads(l) for l in sys.stdin if l.strip()]))" 2>/dev/null || echo "[]")
    else
        log "CROSS-SLICE CHECK: No overlaps found"
        OVERLAP_STATUS="pass"
        OVERLAPS_JSON="[]"
    fi
}

# =============================================================================
# REPORT GENERATION
# =============================================================================

build_union_violations() {
    python3 << EOF
import json

scope_violations = $VIOLATIONS_JSON
unreferenced = $UNREFERENCED_JSON
overlaps = $OVERLAPS_JSON

union = []
for v in scope_violations:
    union.append({"type": "scope", "detail": v})
for p in unreferenced:
    union.append({"type": "constitution", "principle": p})
for o in overlaps:
    union.append({"type": "overlap", "detail": o})

print(json.dumps(union))
EOF
}

compute_overall_status() {
    if [[ "$SCOPE_STATUS" == "fail" ]] || [[ "$CONSTITUTION_STATUS" == "fail" ]] || [[ "$OVERLAP_STATUS" == "fail" ]]; then
        echo "fail"
    elif [[ "$SCOPE_STATUS" == "warn" ]] || [[ "$CONSTITUTION_STATUS" == "warn" ]] || [[ "$OVERLAP_STATUS" == "warn" ]]; then
        echo "warn"
    elif [[ "$SCOPE_STATUS" == "skip" ]] && [[ "$CONSTITUTION_STATUS" == "skip" ]] && [[ "$OVERLAP_STATUS" == "skip" ]]; then
        echo "skip"
    else
        echo "pass"
    fi
}

write_validation_report() {
    local output_dir="$FEATURE_DIR/validation"
    mkdir -p "$output_dir"
    local report_file="$output_dir/slice-consistency-report.json"

    # Compute union violations and overall status
    local UNION_VIOLATIONS
    UNION_VIOLATIONS=$(build_union_violations)
    OVERALL_STATUS=$(compute_overall_status)

    # Build JSON report
    local report_json
    report_json=$(python3 << EOF
import json
from datetime import datetime

report = {
    "timestamp": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    "feature": "$FEATURE_NAME",
    "scope_precision": "$SCOPE_PRECISION",
    "enforcement_mode": "$ENFORCEMENT_MODE",
    "overall_status": "$OVERALL_STATUS",
    "violations": $UNION_VIOLATIONS,
    "scope_check": {
        "status": "$SCOPE_STATUS",
        "files_checked": $FILES_CHECKED,
        "violations": $VIOLATIONS_JSON
    },
    "constitution_check": {
        "status": "$CONSTITUTION_STATUS",
        "principles_total": $PRINCIPLES_TOTAL,
        "principles_addressed": $PRINCIPLES_ADDRESSED,
        "unreferenced": $UNREFERENCED_JSON
    },
    "cross_slice_check": {
        "status": "$OVERLAP_STATUS",
        "overlaps": $OVERLAPS_JSON
    }
}

print(json.dumps(report, indent=2))
EOF
)

    # Write to file
    echo "$report_json" > "$report_file"
    log "Validation report written to: $report_file"

    # Output to stdout if JSON mode
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        echo "$report_json"
    fi
}

# =============================================================================
# GET ENFORCEMENT MODE FROM CONSTITUTION
# =============================================================================

get_enforcement_mode() {
    local constitution_path
    constitution_path=$(get_constitution_path)
    if [[ -f "$constitution_path" ]]; then
        local mode
        mode=$(python3 -c "import re,sys; m=re.search(r'<!-- scope_enforcement: (\w+)', open(sys.argv[1]).read()); print(m.group(1) if m else '')" "$constitution_path" 2>/dev/null || echo "")
        if [[ -n "$mode" ]]; then
            echo "$mode"
            return
        fi
    fi
    echo "warn"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

log "=== Slice Consistency Validation ==="
log "Feature: $FEATURE_NAME"
log "Feature Dir: $FEATURE_DIR"

# Get enforcement mode from constitution
ENFORCEMENT_MODE=$(get_enforcement_mode)
if [[ "$ENFORCEMENT_MODE" == "strict" ]]; then
    STRICT_MODE=true
    log "Enforcement Mode: STRICT"
else
    log "Enforcement Mode: WARN"
fi

# Run all validations
EXIT_CODE=0

validate_slice_scope || EXIT_CODE=1
validate_constitution_alignment || EXIT_CODE=1
validate_cross_slice_overlap || EXIT_CODE=1

# Write report (always) and output JSON (if --json flag)
write_validation_report

log "=== Validation Complete ==="

# Compute final status
OVERALL_STATUS=$(compute_overall_status)

# Exit with appropriate code based on enforcement mode
# In STRICT mode: exit non-zero on fail status or validation errors
# In WARN mode: always exit 0 (issues are advisory)
if [[ "$STRICT_MODE" == "true" ]]; then
    if [[ "$OVERALL_STATUS" == "fail" ]] || [[ "$EXIT_CODE" -ne 0 ]]; then
        exit 1
    fi
fi

# Warn mode: exit 0 regardless of violations (they're advisory)
exit 0
