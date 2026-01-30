#!/usr/bin/env python3
"""
Apply condensed Next Steps pattern to ALL command templates.
Handles:
1. Commands with old verbose pattern
2. Commands with variant patterns (specific command)
3. Commands with missing Next Steps sections
"""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
COMMANDS_DIR = REPO_ROOT / "templates" / "commands"

CONDENSED_NEXT_STEPS = '''Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?** Edit artifacts, run `/gbm.clarify`, or `/gbm.help user-responsibility`

'''

def get_next_steps_section_bounds(content):
    """Find the exact start and end positions of Next Steps section."""
    pattern = r'Next Steps \(always print at the end\):.*?(?=\n(?:---|\*\*Workflow|$))'
    match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
    if match:
        return match.start(), match.end()
    return None, None

def has_correct_pattern(content):
    """Check if file already has the correct condensed pattern."""
    return "Running the next command = approval + responsibility acceptance" in content

def apply_condensed_pattern(filepath):
    """Apply condensed Next Steps pattern to a command file."""
    with open(filepath, 'r') as f:
        content = f.read()

    # Check if already has correct pattern
    if has_correct_pattern(content):
        return False, "Already has correct condensed pattern"

    start, end = get_next_steps_section_bounds(content)

    if start is not None and end is not None:
        # Replace existing Next Steps section
        content = content[:start] + CONDENSED_NEXT_STEPS + content[end:]
    else:
        # Check if file ends with frontmatter delimiter or has content
        # Find where to insert
        if content.rstrip().endswith('---'):
            # Ends with YAML delimiter - add after it
            content = content.rstrip() + '\n\n' + CONDENSED_NEXT_STEPS
        else:
            # Add at end of file
            if not content.endswith('\n'):
                content += '\n'
            content += '\n' + CONDENSED_NEXT_STEPS

    # Ensure file ends properly
    if not content.endswith('\n'):
        content += '\n'

    with open(filepath, 'w') as f:
        f.write(content)

    return True, "Applied condensed pattern"

def main():
    print("=" * 70)
    print("APPLYING CONDENSED Next Steps PATTERN TO ALL COMMANDS")
    print("=" * 70)

    templates = sorted(COMMANDS_DIR.glob("*.md"))
    updated = 0
    skipped = 0
    errors = 0

    for filepath in templates:
        filename = filepath.name
        try:
            was_updated, message = apply_condensed_pattern(filepath)

            if was_updated:
                updated += 1
                print(f"✅ {filename:30} - {message}")
            else:
                skipped += 1
                print(f"⏭️  {filename:30} - {message}")
        except Exception as e:
            errors += 1
            print(f"❌ {filename:30} - ERROR: {str(e)}")

    print("\n" + "=" * 70)
    print(f"Updated: {updated:2d} files")
    print(f"Skipped: {skipped:2d} files (already correct)")
    print(f"Errors:  {errors:2d} files")
    print(f"Total:   {updated + skipped + errors:2d} files")
    print("=" * 70)

    if errors > 0:
        print("\n⚠️  Some files had errors. Review output above.")
        return 1

    print("\n✅ All commands now have condensed Next Steps pattern!")
    return 0

if __name__ == "__main__":
    exit(main())
