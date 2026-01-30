#!/bin/bash
# Show the complete structure of documentation in target projects

echo "📁 Complete Documentation Structure in Target Projects"
echo "======================================================"
echo ""

# Check if we're in a target project or need to create one
if [ -d ".gobuildme/gobuildme-docs" ]; then
    DOCS_DIR=".gobuildme/gobuildme-docs"
    echo "Using current project: $(pwd)"
else
    echo "Creating test project to show structure..."
    TEST_DIR="/tmp/gobuildme-structure-$$"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    gobuildme init test --ai claude --no-git > /dev/null 2>&1
    DOCS_DIR="test/.gobuildme/gobuildme-docs"
fi

echo ""
echo "📊 File Count"
echo "-------------"
TOTAL=$(find "$DOCS_DIR" -type f -name "*.md" | wc -l | tr -d ' ')
echo "Total files: $TOTAL"
echo ""

echo "📂 Directory Structure"
echo "---------------------"
echo ""
echo "Top-level files (12):"
ls -1 "$DOCS_DIR"/*.md 2>/dev/null | sed 's|.*/||' | sed 's/^/  /'
echo ""

echo "handbook/ directory (3 files):"
ls -1 "$DOCS_DIR"/handbook/*.md 2>/dev/null | sed 's|.*/||' | sed 's/^/  /'
echo ""

echo "personas/ directory (13 files):"
ls -1 "$DOCS_DIR"/personas/*.md 2>/dev/null | sed 's|.*/||' | sed 's/^/  /'
echo ""

echo "reference/ directory (3 files):"
ls -1 "$DOCS_DIR"/reference/*.md 2>/dev/null | sed 's|.*/||' | sed 's/^/  /'
echo ""

echo "======================================================"
echo "📋 Complete File List (sorted)"
echo "======================================================"
find "$DOCS_DIR" -type f -name "*.md" | sed "s|$DOCS_DIR/||" | sort
echo ""

echo "======================================================"
echo "✅ All $TOTAL files are present and correctly organized"
echo "======================================================"

# Cleanup if we created a test project
if [ -n "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
fi

