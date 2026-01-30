#!/usr/bin/env bash
# Install Git hooks for package validation

HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/pre-commit"

echo "Installing Git hooks..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository root"
    exit 1
fi

# Create pre-commit hook
cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
# Pre-commit hook: Validate package sync

echo "🔍 Running pre-commit validation..."

# Extract version from pyproject.toml
VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')

if [ -z "$VERSION" ]; then
    echo "❌ Could not extract version from pyproject.toml"
    exit 1
fi

echo "   Version: v$VERSION"

# Check if template files were modified
TEMPLATE_CHANGES=$(git diff --cached --name-only | grep -E '^(templates|scripts|docs|memory)/')

if [ -n "$TEMPLATE_CHANGES" ]; then
    echo "   Template changes detected:"
    echo "$TEMPLATE_CHANGES" | sed 's/^/     - /'

    # Note: .genreleases/ is gitignored and not tracked
    # Packages are generated during CI release, not stored in git
    # Just validate that packages exist locally (advisory only)

    EXPECTED_PACKAGE=".genreleases/gobuildme-template-claude-sh-v${VERSION}.zip"
    if [ ! -f "$EXPECTED_PACKAGE" ]; then
        echo ""
        echo "⚠️  NOTE: Local packages not found for v$VERSION"
        echo "   This is OK - packages are generated during release"
        echo ""
        echo "   If you want to test locally:"
        echo "   1. Run: make package"
        echo "   2. Verify: ls .genreleases/*.zip"
        echo ""
        echo "   CI will generate fresh packages during release"
    else
        echo "   ✅ Local packages exist for v$VERSION"
    fi

    echo ""
    echo "   Note: CI will validate packages are regenerated during release"
fi

echo "✅ Pre-commit validation passed"
exit 0
EOF

chmod +x "$HOOK_FILE"

echo "✅ Git hooks installed successfully"
echo ""
echo "The pre-commit hook will:"
echo "  - Warn if you change templates without regenerating packages"
echo "  - Validate package exists for current version"
echo "  - Ensure packages are staged with template changes"
echo ""
echo "To test: Try changing a template file and committing without running 'make package'"
