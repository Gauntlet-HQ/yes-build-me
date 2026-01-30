#!/usr/bin/env python3
"""
Clean up duplicate Next Steps sections.
Remove old verbose pattern that appears after condensed version.
"""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
COMMANDS_DIR = REPO_ROOT / "templates" / "commands"

def cleanup_file(filepath):
    """Remove duplicate old verbose Next Steps section."""
    with open(filepath, 'r') as f:
        content = f.read()

    # Pattern to match old verbose "Your action of running..." section
    old_verbose = r"\*\*When you run the next command, you are confirming:\*\*.*?(?=\n(?:---|Use this|$))"

    matches = list(re.finditer(old_verbose, content, re.DOTALL | re.IGNORECASE))

    if len(matches) > 0:
        # Remove old verbose sections, keeping only the condensed one
        # Start from the end to avoid index shifts
        for match in reversed(matches):
            content = content[:match.start()] + content[match.end():]

        return True, content
    return False, content

def main():
    print("=" * 70)
    print("CLEANING UP DUPLICATE Next Steps SECTIONS")
    print("=" * 70)

    templates = sorted(COMMANDS_DIR.glob("*.md"))
    cleaned = 0

    for filepath in templates:
        filename = filepath.name
        updated, new_content = cleanup_file(filepath)

        if updated:
            with open(filepath, 'w') as f:
                f.write(new_content)
            cleaned += 1
            print(f"✅ {filename:30} - Removed duplicate old verbose sections")

    print("\n" + "=" * 70)
    print(f"Cleaned: {cleaned} files")
    print("=" * 70)

if __name__ == "__main__":
    main()
