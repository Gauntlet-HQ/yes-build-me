#!/usr/bin/env bash
# Purpose : Generate audit trail reports from metadata registry
# Why     : Provides compliance, traceability, and decision documentation
# How     : Reads metadata YAML and generates formatted audit reports

set -euo pipefail

# Colors for output
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
RESET='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${1:-.}"

# Ensure metadata directory exists
METADATA_DIR="$REPO_ROOT/.gobuildme/metadata/specs"
if [[ ! -d "$METADATA_DIR" ]]; then
    echo -e "${RED}Error: Metadata directory not found at $METADATA_DIR${RESET}" >&2
    echo "Run some /gbm commands first to generate metadata." >&2
    exit 1
fi

# Count metadata files
FEATURE_COUNT=$(find "$METADATA_DIR" -maxdepth 1 -name "*.yaml" -type f | wc -l)

if [[ $FEATURE_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}No metadata found. Run /gbm commands to generate audit trail.${RESET}"
    exit 0
fi

# Generate report header
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BLUE}                    AUDIT TRAIL REPORT${RESET}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${RESET}"
echo ""
echo "Repository: $REPO_ROOT"
echo "Generated: $(date)"
echo "Features tracked: $FEATURE_COUNT"
echo ""

# Process each feature's metadata
for metadata_file in "$METADATA_DIR"/*.yaml; do
    [[ -f "$metadata_file" ]] || continue

    feature_name=$(basename "$metadata_file" .yaml)

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}Feature: $feature_name${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""

    # Extract and display user goals if available
    if grep -q "input_summary:" "$metadata_file" 2>/dev/null; then
        echo -e "${YELLOW}User Goals:${RESET}"
        # Use simple line-by-line extraction
        in_input_summary=0
        while IFS= read -r line; do
            if [[ $line =~ ^input_summary: ]]; then
                in_input_summary=1
                continue
            fi
            if [[ $in_input_summary -eq 1 ]]; then
                if [[ $line =~ ^[^[:space:]] ]]; then
                    # End of list
                    break
                fi
                # Extract goal text (trim leading whitespace and list markers)
                goal=$(echo "$line" | sed -e 's/^[[:space:]]*-[[:space:]]*//' -e 's/^[[:space:]]*//')
                if [[ -n "$goal" ]]; then
                    echo "  • $goal"
                fi
            fi
        done < "$metadata_file"
        echo ""
    fi

    # Extract and display stages
    echo -e "${YELLOW}Stages:${RESET}"

    # Use grep to find all stages
    stages=$(grep -E "^  [a-z]+:" "$metadata_file" | sed 's/^[[:space:]]*//; s/:$//' | sort || echo "")

    if [[ -z "$stages" ]]; then
        stages=$(grep -E "^    [a-z]+:" "$metadata_file" | sed 's/^[[:space:]]*//; s/:$//' | sort || echo "")
    fi

    if [[ -z "$stages" ]]; then
        echo "  (No stages recorded)"
    else
        echo "$stages" | while read -r stage; do
            # Extract stage details
            created_at=$(grep -A 3 "^  $stage:" "$metadata_file" 2>/dev/null | grep "created_at:" | sed 's/.*: //' | tr -d '"' || echo "Unknown")
            created_by=$(grep -A 3 "^  $stage:" "$metadata_file" 2>/dev/null | grep "created_by:" | sed 's/.*: //' | tr -d '"' || echo "Unknown")
            artifact=$(grep -A 3 "^  $stage:" "$metadata_file" 2>/dev/null | grep "artifact:" | sed 's/.*: //' | tr -d '"' || echo "Unknown")

            echo "  ${BLUE}$stage${RESET}"
            echo "    Created: $created_at"
            echo "    Author:  $created_by"
            echo "    Artifact: $artifact"
        done
    fi

    echo ""
    echo ""
done

# Summary statistics
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${BLUE}                         SUMMARY${RESET}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${RESET}"
echo ""
echo "Total features: $FEATURE_COUNT"

# Count total stages
total_stages=0
for metadata_file in "$METADATA_DIR"/*.yaml; do
    [[ -f "$metadata_file" ]] || continue
    stages=$(grep -E "^  [a-z_]+:" "$metadata_file" 2>/dev/null | wc -l || echo 0)
    total_stages=$((total_stages + stages))
done
echo "Total stages recorded: $total_stages"

# Calculate average stages per feature
if [[ $FEATURE_COUNT -gt 0 ]]; then
    avg_stages=$((total_stages / FEATURE_COUNT))
    echo "Average stages per feature: $avg_stages"
fi

echo ""
echo -e "${GREEN}✓ Audit report generation complete${RESET}"
echo ""
