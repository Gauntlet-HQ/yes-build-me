#!/usr/bin/env python3
"""
Update all command templates with the new user responsibility/approval Next Steps pattern.

IMPROVED VERSION:
- Robust multiline pattern matching
- Validates that replacement doesn't create duplicates
- Better detection of already-updated files
- Post-replacement validation
"""

import re
from pathlib import Path

# Get repo root
REPO_ROOT = Path(__file__).parent.parent
COMMANDS_DIR = REPO_ROOT / "templates" / "commands"

# Already updated commands
ALREADY_UPDATED = {
    "request.md",
    "specify.md",
    "clarify.md",
    "help.md",
}

# Generic Next Steps template (CONDENSED & TOKEN-EFFICIENT)
GENERIC_NEXT_STEPS = '''Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?** Edit artifacts, run `/gbm.clarify`, or `/gbm.help user-responsibility`'''

def is_already_updated(content):
    """
    Check if file already has the new pattern.
    More robust than keyword checking.
    """
    # Look for the complete pattern signature
    if "Running the next command = approval" in content:
        return True
    # Check for old verbose pattern
    if "Your action of running the next command = explicit approval" in content:
        return True
    return False

def validate_no_duplication(content):
    """
    Validate that Next Steps appears exactly once.
    Prevents duplication issues.
    """
    count = content.count("Next Steps (always print at the end):")
    return count == 1

def update_command_file(filepath):
    """
    Update a command file's Next Steps section. Returns tuple (updated, new_content).

    Uses multiline regex and validates replacement to prevent duplication.
    """
    with open(filepath, 'r') as f:
        content = f.read()

    # Skip if already has new pattern
    if is_already_updated(content):
        print("  ⏭️  SKIP: Already has new pattern")
        return False, content

    # Multiline pattern to match entire Next Steps block
    # This captures from "Next Steps" through either another section or end of file
    pattern = r'Next Steps \(always print at the end\):.*?(?=\n(?:---|\*\*|#|$))'

    match = re.search(pattern, content, re.DOTALL)

    if match:
        # Create new content with replacement
        new_content = content[:match.start()] + GENERIC_NEXT_STEPS + "\n\n" + content[match.end():]

        # Validate no duplication occurred
        if not validate_no_duplication(new_content):
            print("  ❌ ERROR: Replacement created duplication, skipping")
            return False, content

        print("  ✅ Updated with condensed Next Steps (token-efficient)")
        return True, new_content

    # Check if file has Next Steps but pattern didn't match
    if "Next Steps" in content or "next steps" in content.lower():
        if "Persona" in content or "persona" in content:
            print("  ⚠️  COMPLEX: Has persona-specific next steps (manual review)")
            return False, content
        else:
            print("  ⚠️  HAS Next Steps but pattern not recognized (manual review)")
            return False, content

    print("  ℹ️  No Next Steps section found")
    return False, content

def main():
    """Update all command templates."""
    print(f"Updating command templates in {COMMANDS_DIR}\n")

    command_files = sorted(COMMANDS_DIR.glob("*.md"))
    updated = 0
    total = 0

    for filepath in command_files:
        filename = filepath.name

        # Skip already updated files
        if filename in ALREADY_UPDATED:
            print(f"✓ {filename} - already updated")
            continue

        total += 1
        print(f"\n{filename}")

        try:
            was_updated, new_content = update_command_file(filepath)
            if was_updated:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                updated += 1
        except Exception as e:
            print(f"  ❌ ERROR: {e}")

    print(f"\n\n{'='*60}")
    print(f"Summary: Updated {updated} files out of {total} needing updates")
    print(f"Already updated: {len(ALREADY_UPDATED)}")
    print(f"Total command files: {len(command_files)}")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
