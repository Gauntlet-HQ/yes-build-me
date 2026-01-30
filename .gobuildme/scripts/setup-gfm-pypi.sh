#!/bin/bash
# GoBuildMe Internal PyPI Setup Script
# This script configures pip to use GoFundMe's internal Nexus PyPI repository

set -e

echo "🚀 Setting up GoBuildMe PyPI configuration..."
echo ""

# Create pip directory
mkdir -p ~/.pip
echo "✅ Created ~/.pip directory"

# Create pip configuration
cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://nexus.internal.gfm-ops.com/repository/pypi-releases/simple
extra-index-url = https://pypi.org/simple
EOF
echo "✅ Configured pip to use GoFundMe's internal Nexus PyPI (with PyPI fallback)"

# Detect shell and add alias
SHELL_RC=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "⚠️  Could not detect shell. Please manually add this alias to your shell config:"
    echo "alias pip='python3.11 -m pip'"
    echo ""
fi

if [[ -n "$SHELL_RC" ]]; then
    # Check if alias already exists
    if grep -q "alias pip='python3.11 -m pip'" "$SHELL_RC" 2>/dev/null; then
        echo "✅ pip alias already configured"
    else
        cat >> "$SHELL_RC" << 'EOF'

# GoBuildMe PyPI Configuration
alias pip='python3.11 -m pip'
alias pip3='python3.11 -m pip'
EOF
        echo "✅ Added pip aliases to $SHELL_RC"
    fi
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Reload your shell: source $SHELL_RC"
echo "2. Verify Python 3.11 is installed: python3.11 --version"
echo "3. Install GoBuildMe: pip install gobuildme-cli"
echo ""
echo "Requirements:"
echo "- Python 3.11 or later"
echo "- VPN or internal network access to GoFundMe"
echo ""
