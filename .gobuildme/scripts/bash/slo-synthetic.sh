#!/usr/bin/env bash
set -euo pipefail

# Produce a provisional SLI/SLO report for CI from test or synthetic data.
# This is intentionally lightweight and advisory (non-blocking).

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || cd "$SCRIPT_DIR/../../.." && pwd)
OUT_DIR="$REPO_ROOT/.gobuildme/self-driving/logs"
mkdir -p "$OUT_DIR"
REPORT="$OUT_DIR/slo-report.json"

# Heuristic: if a junit xml exists, consider pass rate as a proxy SLI
JUNIT=$(find "$REPO_ROOT" -maxdepth 4 -type f -name 'junit*.xml' -print -quit 2>/dev/null || true)
PASS=0; TOTAL=0
if [[ -n "$JUNIT" ]] && command -v xmllint >/dev/null 2>&1; then
  TOTAL=$(xmllint --xpath 'string(/testsuite/@tests)' "$JUNIT" 2>/dev/null || echo 0)
  FAIL=$(xmllint --xpath 'string(/testsuite/@failures)' "$JUNIT" 2>/dev/null || echo 0)
  SKIP=$(xmllint --xpath 'string(/testsuite/@skipped)' "$JUNIT" 2>/dev/null || echo 0)
  PASS=$(( TOTAL - FAIL - SKIP ))
fi

AVAIL=1.0
if [[ $TOTAL -gt 0 ]]; then
  AVAIL=$(python3 - "$PASS" "$TOTAL" <<'PY'
import sys
p,t = int(sys.argv[1]), int(sys.argv[2])
print(f"{(p/max(t,1)):.4f}")
PY
  ) || AVAIL=1.0
fi

cat > "$REPORT" <<JSON
{
  "provisional": true,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "test_pass": {"passed": $PASS, "total": $TOTAL},
  "heuristic_availability": $AVAIL
}
JSON

echo "[slo-synthetic] Wrote $REPORT"

