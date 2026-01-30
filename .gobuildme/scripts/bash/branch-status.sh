#!/usr/bin/env bash
# Purpose : Provide a quick summary of git branch health for `/review` gating.
# Why     : Helps developers understand divergence and outstanding changes
#           before progressing through the workflow.
# How     : Prints current branch, status, recent commits, and main sync delta.
set -euo pipefail

branch=$(git branch --show-current 2>/dev/null || echo "(no branch)")
echo "Current branch: $branch"
echo "\nGit status:"
git status --porcelain || true

echo "\nRecent commits:"
git log --oneline -5 || true

echo "\nSync with main:"
if git remote get-url origin >/dev/null 2>&1; then
  git fetch origin main >/dev/null 2>&1 || true
  if git show-ref --verify --quiet refs/remotes/origin/main; then
    behind=$(git rev-list --count HEAD..origin/main || echo 0)
    ahead=$(git rev-list --count origin/main..HEAD || echo 0)
    echo "Ahead: $ahead, Behind: $behind"
  else
    echo "No remote-tracking branch origin/main; run 'git fetch origin main' when online."
  fi
else
  echo "No 'origin' remote configured."
fi
