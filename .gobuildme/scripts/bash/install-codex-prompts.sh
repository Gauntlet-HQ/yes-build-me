#!/usr/bin/env bash
# install-codex-prompts.sh
# Install GoBuildMe prompts to Codex CLI's expected location (~/.codex/prompts/)
#
# Usage:
#   ./scripts/bash/install-codex-prompts.sh         # Interactive mode
#   ./scripts/bash/install-codex-prompts.sh copy    # Copy files
#   ./scripts/bash/install-codex-prompts.sh symlink # Create symlink

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_PROMPTS="$PROJECT_ROOT/.codex/prompts"
HOME_PROMPTS="$HOME/.codex/prompts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
}

# Check if project has .codex/prompts directory
if [[ ! -d "$PROJECT_PROMPTS" ]]; then
    error "No .codex/prompts directory found in project root"
    error "Run 'gobuildme init <project> --ai codex' first"
    exit 1
fi

prompt_count=$(find "$PROJECT_PROMPTS" -name "*.md" -type f | wc -l)
if [[ $prompt_count -eq 0 ]]; then
    error "No prompt files found in $PROJECT_PROMPTS"
    exit 1
fi

info "Found $prompt_count Codex prompt files in project"

# Determine installation method
METHOD="${1:-}"

if [[ -z "$METHOD" ]]; then
    # Interactive mode
    echo ""
    echo "Codex CLI expects prompts in: $HOME_PROMPTS"
    echo "Project prompts are in:       $PROJECT_PROMPTS"
    echo ""
    echo "Choose installation method:"
    echo "  1) Symlink (recommended) - Links home directory to project"
    echo "  2) Copy - Copies files to home directory"
    echo ""
    read -rp "Enter choice (1 or 2): " choice

    case $choice in
        1) METHOD="symlink" ;;
        2) METHOD="copy" ;;
        *)
            error "Invalid choice"
            exit 1
            ;;
    esac
fi

# Validate method
if [[ "$METHOD" != "symlink" && "$METHOD" != "copy" ]]; then
    error "Invalid method: $METHOD (use 'symlink' or 'copy')"
    exit 1
fi

# Check if ~/.codex/prompts already exists
if [[ -e "$HOME_PROMPTS" ]]; then
    warning "~/.codex/prompts already exists"

    if [[ -L "$HOME_PROMPTS" ]]; then
        current_target=$(readlink "$HOME_PROMPTS")
        if [[ "$current_target" == "$PROJECT_PROMPTS" ]]; then
            success "Already linked to this project"
            exit 0
        else
            warning "Currently linked to: $current_target"
        fi
    elif [[ -d "$HOME_PROMPTS" ]]; then
        file_count=$(find "$HOME_PROMPTS" -name "*.md" -type f | wc -l)
        warning "Directory contains $file_count files"
    fi

    echo ""
    read -rp "Overwrite ~/.codex/prompts? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        info "Installation cancelled"
        exit 0
    fi

    # Backup existing
    backup="$HOME/.codex/prompts.backup.$(date +%Y%m%d-%H%M%S)"
    info "Backing up to: $backup"
    mv "$HOME_PROMPTS" "$backup"
    success "Backup created"
fi

# Create parent directory
mkdir -p "$HOME/.codex"

# Install prompts
case $METHOD in
    symlink)
        info "Creating symlink..."
        ln -s "$PROJECT_PROMPTS" "$HOME_PROMPTS"
        success "Symlink created: ~/.codex/prompts -> $PROJECT_PROMPTS"

        echo ""
        info "Note: Symlink points to this project. Switching projects will require:"
        info "  1. Remove symlink: rm ~/.codex/prompts"
        info "  2. Re-run this script from the new project"
        ;;

    copy)
        info "Copying files..."
        cp -r "$PROJECT_PROMPTS" "$HOME_PROMPTS"
        copied_count=$(find "$HOME_PROMPTS" -name "*.md" -type f | wc -l)
        success "Copied $copied_count files to ~/.codex/prompts"

        echo ""
        warning "Files copied. If project prompts change, re-run this script to update"
        ;;
esac

echo ""
success "Installation complete!"
echo ""
info "Test with Codex CLI:"
echo "  codex /gbm"
echo "  codex /gbm.specify"
echo ""
