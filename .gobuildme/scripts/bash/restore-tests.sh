#!/usr/bin/env bash
# Purpose: Restore tests from backup (rollback mechanism)
# Why: Provides undo functionality if test generation fails or corrupts tests
# How: Restores from .gobuildme/test-generation-backup/

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/qa-common.sh"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Parse arguments
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BACKUP_DIR=""
LIST_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --backup)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --list)
            LIST_ONLY=true
            shift
            ;;
        --help)
            echo "Usage: restore-tests.sh [OPTIONS]"
            echo ""
            echo "Restore tests from backup (rollback mechanism)"
            echo ""
            echo "Options:"
            echo "  --backup DIR    Restore from specific backup directory"
            echo "  --list          List available backups"
            echo "  --help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  restore-tests.sh                      # Restore from latest backup"
            echo "  restore-tests.sh --list               # List available backups"
            echo "  restore-tests.sh --backup <dir>       # Restore from specific backup"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# List backups if requested
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$LIST_ONLY" = true ]; then
    print_section "📋 Available Backups"

    BACKUP_BASE=".gobuildme/test-generation-backup"

    if [ ! -d "$BACKUP_BASE" ]; then
        print_info "No backups found"
        exit 0
    fi

    BACKUPS=$(find "$BACKUP_BASE" -mindepth 1 -maxdepth 1 -type d | sort -r)

    if [ -z "$BACKUPS" ]; then
        print_info "No backups found"
        exit 0
    fi

    echo "Found backups:"
    echo ""

    echo "$BACKUPS" | while read -r backup; do
        MANIFEST="$backup/manifest.json"
        if [ -f "$MANIFEST" ]; then
            OPERATION=$(grep "\"operation\"" "$MANIFEST" | sed 's/.*"operation":[[:space:]]*"\([^"]*\)".*/\1/')
            TIMESTAMP=$(grep "\"timestamp\"" "$MANIFEST" | sed 's/.*"timestamp":[[:space:]]*"\([^"]*\)".*/\1/')
            echo "  • $backup"
            echo "    Operation: $OPERATION"
            echo "    Timestamp: $TIMESTAMP"
            echo ""
        else
            echo "  • $backup"
            echo "    (No manifest found)"
            echo ""
        fi
    done

    exit 0
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Restore from backup
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_section "🔄 Restore Tests from Backup"

# Determine backup directory
if [ -z "$BACKUP_DIR" ]; then
    print_info "No backup specified, using latest..."
    BACKUP_DIR=$(get_latest_backup)

    if [ -z "$BACKUP_DIR" ]; then
        print_error "No backups found"
        echo ""
        echo "Tip: Run --list to see available backups"
        exit 1
    fi

    print_info "Latest backup: $BACKUP_DIR"
fi

# Confirm restore
echo ""
echo "⚠️  This will replace current tests/ directory with backup"
echo ""

# Check if running in interactive shell
if [ -t 0 ]; then
    read -p "Proceed with restore? [y/N] " confirm
else
    # Non-interactive - require explicit confirmation via environment variable
    if [ "${AUTO_CONFIRM:-false}" = "true" ]; then
        confirm="y"
        echo "Proceed with restore? [y/N] y (auto-confirmed)"
    else
        confirm="n"
        echo "Proceed with restore? [y/N] n (non-interactive, use AUTO_CONFIRM=true to override)"
    fi
fi

echo ""

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    print_info "Restore cancelled"
    exit 0
fi

# Perform restore
if restore_from_backup "$BACKUP_DIR"; then
    print_section "✅ Restore Complete"
    echo "Tests have been restored from backup."
    echo ""
    echo "Backup: $BACKUP_DIR"
    echo ""
    echo "Next steps:"
    echo "  • Review restored tests"
    echo "  • Run tests: /gbm.tests or npm test"
    exit 0
else
    print_section "❌ Restore Failed"
    echo "Failed to restore from backup."
    echo ""
    echo "Backup: $BACKUP_DIR"
    exit 1
fi
