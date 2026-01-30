#!/usr/bin/env bash
set -euo pipefail

# verify-url-accessibility.sh - Check if URLs are accessible
# Usage: ./verify-url-accessibility.sh <url>

URL="${1:-}"

if [ -z "$URL" ]; then
  echo "Usage: $0 <url>" >&2
  exit 1
fi

# Use curl to check URL accessibility
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" -L --max-time 10 "$URL" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 400 ]; then
  echo "accessible"
  exit 0
else
  echo "inaccessible (HTTP $HTTP_CODE)"
  exit 1
fi
