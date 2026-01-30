#!/usr/bin/env bash
# Purpose : Initialize GoBuildMe projects entirely offline using cached releases.
# Why     : Enables environments without network access to bootstrap the SDD
#           workflow while staying aligned with the official templates.
# How     : Selects the proper agent/template zip, unpacks it into the target
#           directory, and normalizes legacy folder names.
set -euo pipefail

# Offline initializer for GoBuildMe templates.
# - Uses local release zips from this repo's .genreleases/
# - Unzips into target directory and renames .specify -> .gobuildme
# - No Python, pip, or network required
#
# Usage examples:
#   scripts/bash/offline-init.sh --here --agent copilot --script sh
#   scripts/bash/offline-init.sh --dir /path/to/project --agent windsurf --script sh
#   scripts/bash/offline-init.sh --zip /abs/path/to/gobuildme-template-claude-sh-<ver>.zip --here

REPO_ROOT=$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
GEN_DIR="$REPO_ROOT/.genreleases"

AGENT="copilot"
SCRIPT_VARIANT="sh" # sh|ps
DEST_DIR=""
USE_HERE=false
ZIP_PATH=""
FORCE=false

die() { echo "[offline-init] ERROR: $*" >&2; exit 1; }
info() { echo "[offline-init] $*"; }

usage() {
  cat <<EOF
Offline initializer for GoBuildMe templates (no network).

Options:
  --agent <name>       One of: claude, gemini, copilot, cursor, qwen, opencode,
                       codex, windsurf, kilocode, auggie, roo (default: copilot)
  --script <sh|ps>     Script flavor (default: sh)
  --here               Use current working directory as destination
  --dir <path>         Destination directory (created if missing)
  --zip <path>         Use an explicit template zip path (bypasses agent/script)
  --force              Proceed if .gobuildme already exists (merge/overwrite files)
  -h|--help            Show this help

Examples:
  ${BASH_SOURCE[0]} --here --agent copilot --script sh
  ${BASH_SOURCE[0]} --dir ~/Code/newproj --agent windsurf --script sh
  ${BASH_SOURCE[0]} --zip $GEN_DIR/gobuildme-template-claude-sh-v9.9.8.zip --here
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="${2:-}"; shift 2;;
    --script) SCRIPT_VARIANT="${2:-}"; shift 2;;
    --here) USE_HERE=true; shift;;
    --dir) DEST_DIR="${2:-}"; shift 2;;
    --zip) ZIP_PATH="${2:-}"; shift 2;;
    --force) FORCE=true; shift;;
    -h|--help) usage; exit 0;;
    *) die "Unknown option: $1";;
  esac
done

[[ "$USE_HERE" == true && -n "$DEST_DIR" ]] && die "Use either --here or --dir, not both."
[[ "$USE_HERE" == false && -z "$DEST_DIR" ]] && die "Specify --here or --dir <path>."

if [[ "$USE_HERE" == true ]]; then
  DEST_DIR=$(pwd)
else
  mkdir -p "$DEST_DIR"
  DEST_DIR=$(cd "$DEST_DIR" && pwd)
fi

if [[ -z "$ZIP_PATH" ]]; then
  [[ -d "$GEN_DIR" ]] || die "Missing $GEN_DIR. Run from a gobuildme repo clone."
  case "$SCRIPT_VARIANT" in
    sh|ps) ;; *) die "--script must be 'sh' or 'ps'";;
  esac
  # Prefer gobuildme-template-<agent>-<script>-v*.zip
  CANDIDATES=()
  for zip in "$GEN_DIR"/gobuildme-template-"$AGENT"-"$SCRIPT_VARIANT"-v*.zip; do
    [[ -f "$zip" ]] && CANDIDATES+=("$zip")
  done
  [[ ${#CANDIDATES[@]} -gt 0 ]] || die "No template zips found for agent=$AGENT script=$SCRIPT_VARIANT under $GEN_DIR"
  # Pick the lexicographically last as the newest (version strings are prefixed with 'v')
  # Sort and pick the last one
  ZIP_PATH=$(printf '%s\n' "${CANDIDATES[@]}" | sort | tail -n1)
fi

[[ -f "$ZIP_PATH" ]] || die "Template zip not found: $ZIP_PATH"

info "Using zip: $ZIP_PATH"
info "Destination: $DEST_DIR"

# Safety checks
if [[ -d "$DEST_DIR/.gobuildme" && "$FORCE" != true ]]; then
  die ".gobuildme already exists in $DEST_DIR. Use --force to merge/overwrite."
fi

if command -v unzip >/dev/null 2>&1; then
  :
else
  die "unzip command not found. Please install unzip."
fi

# Unzip into destination
info "Unzipping template..."
unzip -q "$ZIP_PATH" -d "$DEST_DIR"

# Rename legacy .specify -> .gobuildme if present
if [[ -d "$DEST_DIR/.specify" ]]; then
  info "Renaming .specify -> .gobuildme"
  if [[ -d "$DEST_DIR/.gobuildme" ]]; then
    # Merge copy when both exist
    rsync -a "$DEST_DIR/.specify/" "$DEST_DIR/.gobuildme/"
    rm -rf "$DEST_DIR/.specify"
  else
    mv "$DEST_DIR/.specify" "$DEST_DIR/.gobuildme"
  fi
fi

info "Done. Project bootstrap files are in: $DEST_DIR"
echo "Next Steps:"
echo "- /constitution → try: open .gobuildme/templates/commands/constitution.md (or use your agent's prompts) [FIRST]"
echo "- /request → try: open .gobuildme/templates/commands/request.md (or use your agent’s prompts)"
echo "- /specify → write spec.md"
echo "- /plan → generate plan artifacts"
echo "- Tip: commit the generated files and set up CI"
