#!/usr/bin/env python3
"""
Batch condense Next Steps sections to save tokens while retaining critical information.

This script replaces the verbose Next Steps pattern with a condensed, token-efficient version
that maintains all critical information (review requirements, approval model, options).

Reduces ~195 words to ~100 words (49% reduction).
"""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
COMMANDS_DIR = REPO_ROOT / "templates" / "commands"

# Condensed pattern (token-efficient but complete)
CONDENSED_NEXT_STEPS = '''Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?** Edit artifacts, run `/gbm.clarify`, or `/gbm.help user-responsibility`'''

def condense_file(filepath):
    """
    Replace verbose Next Steps with condensed version.
    Returns (updated, new_content, reason).
    """
    with open(filepath, 'r') as f:
        content = f.read()

    # Pattern to match entire Next Steps block (verbose version)
    # Match from "Next Steps" through various closing patterns
    verbose_pattern = r'''Next Steps \(always print at the end\):

⚠️ \*\*IMPORTANT:.*?(?=\n(?:---|\*\*|###|$|===))'''

    if re.search(verbose_pattern, content, re.DOTALL | re.IGNORECASE):
        new_content = re.sub(
            verbose_pattern,
            CONDENSED_NEXT_STEPS,
            content,
            count=1,
            flags=re.DOTALL | re.IGNORECASE
        )
        return True, new_content, "Condensed verbose pattern"

    # Alternative pattern: match the exact verbose pattern we use
    verbose_pattern2 = r'''Next Steps \(always print at the end\):

⚠️ \*\*Before proceeding, review the generated content:\*\*.*?(?=\n(?:---|$|###))'''

    if re.search(verbose_pattern2, content, re.DOTALL):
        new_content = re.sub(
            verbose_pattern2,
            CONDENSED_NEXT_STEPS,
            content,
            count=1,
            flags=re.DOTALL
        )
        return True, new_content, "Already partial condense, fully condensed"

    return False, content, "No verbose pattern found"

def main():
    """Condense Next Steps in all command templates."""
    print("=" * 70)
    print("CONDENSING Next Steps SECTIONS (Token-Efficient)")
    print("=" * 70)
    print(f"Target directory: {COMMANDS_DIR}\n")

    templates = sorted(COMMANDS_DIR.glob("*.md"))
    condensed = 0
    total = 0

    for filepath in templates:
        filename = filepath.name
        total += 1

        updated, new_content, reason = condense_file(filepath)

        if updated:
            with open(filepath, 'w') as f:
                f.write(new_content)
            condensed += 1
            print(f"✅ {filename:30} - {reason}")
        else:
            print(f"⏭️  {filename:30} - {reason}")

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"Total files checked: {total}")
    print(f"Files condensed: {condensed}")
    print("Token reduction: ~49% per command (195 → 100 words)")
    print(f"Aggregate tokens saved: ~{condensed * 95} words across all files")
    print("=" * 70)

if __name__ == "__main__":
    main()
