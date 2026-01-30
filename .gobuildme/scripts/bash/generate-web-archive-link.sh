#!/usr/bin/env bash
set -euo pipefail

# generate-web-archive-link.sh - Generate Web Archive link for URL
# Usage: ./generate-web-archive-link.sh <url>

URL="${1:-}"

if [ -z "$URL" ]; then
  echo "Usage: $0 <url>" >&2
  exit 1
fi

# Generate Web Archive save link
ARCHIVE_SAVE_URL="https://web.archive.org/save/$URL"

# Generate current snapshot link (may not exist yet)
ARCHIVE_SNAPSHOT_URL="https://web.archive.org/web/*/$URL"

echo "save_url=$ARCHIVE_SAVE_URL"
echo "snapshot_url=$ARCHIVE_SNAPSHOT_URL"
