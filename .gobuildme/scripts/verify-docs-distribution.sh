#!/bin/bash
# Verify that only end-user documentation is distributed to target projects

set -e

echo "🔍 Verifying Documentation Distribution"
echo "========================================"
echo ""

# Create test project
TEST_DIR="/tmp/gobuildme-docs-test-$$"
echo "Creating test project in: $TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Initialize project
echo "Running: gobuildme init test-project --ai claude --no-git"
gobuildme init test-project --ai claude --no-git > /dev/null 2>&1

# Check if docs directory exists
DOCS_DIR="$TEST_DIR/test-project/.gobuildme/gobuildme-docs"
if [ ! -d "$DOCS_DIR" ]; then
    echo "❌ ERROR: Documentation directory not found"
    exit 1
fi

echo "✅ Documentation directory created"
echo ""

# Count files
TOTAL_FILES=$(find "$DOCS_DIR" -type f | wc -l | tr -d ' ')
echo "📊 Total files distributed: $TOTAL_FILES"
echo ""

# Expected end-user files
echo "📋 Checking for expected end-user documentation..."
EXPECTED_FILES=(
    "README.md"
    "quickstart.md"
    "installation.md"
    "local-development.md"
    "control-gates.md"
    "personas-detailed-guide.md"
    "testing.md"
    "observability-integration.md"
    "observability-testing.md"
    "observability-troubleshooting.md"
    "projen-user-guide.md"
    "projen-customization.md"
    "handbook/overview.md"
    "handbook/personas.md"
    "handbook/workflow.md"
    "personas/README.md"
    "personas/persona-gates-reference.md"
    "personas/architect-manual.md"
    "personas/product-manager-manual.md"
    "personas/backend-engineer-manual.md"
    "personas/frontend-engineer-manual.md"
    "personas/qa-engineer-manual.md"
    "personas/sre-manual.md"
    "personas/security-compliance-manual.md"
    "personas/maintainer-manual.md"
    "personas/data-engineer-manual.md"
    "personas/ml-engineer-manual.md"
    "personas/data-scientist-manual.md"
    "reference/commands.md"
    "reference/scripts.md"
    "reference/templates.md"
)

MISSING_COUNT=0
for file in "${EXPECTED_FILES[@]}"; do
    if [ ! -f "$DOCS_DIR/$file" ]; then
        echo "  ❌ Missing: $file"
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done

if [ $MISSING_COUNT -eq 0 ]; then
    echo "  ✅ All expected files present (${#EXPECTED_FILES[@]} files)"
else
    echo "  ❌ Missing $MISSING_COUNT files"
fi
echo ""

# Check for dev docs that should NOT be distributed
echo "🚫 Checking for dev documentation (should NOT be present)..."
DEV_FILES=(
    "CONTROL_GATES_ADDITION.md"
    "CONTROL_GATES_HOW_CHECKED.md"
    "PERSONA_GATES_DOCUMENTATION.md"
    "PERSONA_GATES_FINAL_SUMMARY.md"
    "SESSION_COMPLETE_SUMMARY.md"
    "ISSUES_FOUND.md"
    "VERIFICATION_COMPLETE.md"
    "check.md"
    "cli-master-repo-setup.md"
    "coralogix.md"
    "coralogix-imp.md"
    "docfx.json"
    "toc.yml"
    "index.md"
    "projen-architecture.md"
    "projen-plan.md"
)

DEV_FOUND_COUNT=0
for file in "${DEV_FILES[@]}"; do
    if [ -f "$DOCS_DIR/$file" ]; then
        echo "  ❌ Found dev doc: $file"
        DEV_FOUND_COUNT=$((DEV_FOUND_COUNT + 1))
    fi
done

if [ $DEV_FOUND_COUNT -eq 0 ]; then
    echo "  ✅ No dev documentation found (correct)"
else
    echo "  ❌ Found $DEV_FOUND_COUNT dev docs (should be 0)"
fi
echo ""

# Summary
echo "========================================"
echo "📊 Summary"
echo "========================================"
echo "Total files distributed: $TOTAL_FILES"
echo "Expected files: ${#EXPECTED_FILES[@]}"
echo "Missing files: $MISSING_COUNT"
echo "Dev docs found: $DEV_FOUND_COUNT"
echo ""

# Cleanup
echo "🧹 Cleaning up test directory..."
rm -rf "$TEST_DIR"

# Final result
if [ $MISSING_COUNT -eq 0 ] && [ $DEV_FOUND_COUNT -eq 0 ]; then
    echo "✅ VERIFICATION PASSED"
    echo ""
    echo "All end-user documentation is correctly distributed."
    echo "No development documentation is included."
    exit 0
else
    echo "❌ VERIFICATION FAILED"
    echo ""
    if [ $MISSING_COUNT -gt 0 ]; then
        echo "Missing $MISSING_COUNT expected files"
    fi
    if [ $DEV_FOUND_COUNT -gt 0 ]; then
        echo "Found $DEV_FOUND_COUNT dev docs that should not be distributed"
    fi
    exit 1
fi

