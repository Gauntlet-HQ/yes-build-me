#!/usr/bin/env python3
"""Add artifact declarations to templates that are missing them."""

from pathlib import Path

# Mapping of command to artifact declarations
ARTIFACT_DECLARATIONS = {
    "analyze.md": """artifacts:
  - path: ".gobuildme/analysis/<feature>/consistency-report.md"
    description: "Cross-artifact consistency analysis and quality validation report""",

    "branch-status.md": """artifacts:
  - path: "(console output)"
    description: "Display of current branch status, feature directory location, and prerequisite validation""",

    "checklist.md": """artifacts:
  - path: ".gobuildme/checklists/<feature>/checklist.md"
    description: "Persona-specific quality gate checklist for feature development""",

    "ci-matrix.md": """artifacts:
  - path: ".github/workflows/ci-matrix.yml"
    description: "GitHub Actions CI matrix configuration for running tests across multiple environments""",

    "ci-setup.md": """artifacts:
  - path: ".github/workflows/"
    description: "GitHub Actions workflow configuration files for continuous integration""",

    "preflight.md": """artifacts:
  - path: "(console output)"
    description: "Preflight check summary with lint/type/test/coverage status and findings""",

    "design.md": """artifacts:
  - path: ".gobuildme/specs/<feature>/design.md"
    description: "Detailed design document for the feature (optional, detailed design phase)""",

    "docs.md": """artifacts:
  - path: "docs/"
    description: "Generated API documentation and user guides""",

    "fact-check.md": """artifacts:
  - path: ".gobuildme/analysis/<feature>/fact-check-report.md"
    description: "Validation report checking plan/tasks against specification and architecture""",

    "gbm.md": """artifacts:
  - path: "(help output)"
    description: "Display of available GoBuildMe commands and help information""",

    "help.md": """artifacts:
  - path: "(help output)"
    description: "Display of detailed help documentation for specified topic""",

    "persona.md": """artifacts:
  - path: ".gobuildme/config/personas.yaml"
    description: "Persona configuration file with selected driver persona and participants"
  - path: ".gobuildme/specs/<feature>/persona.yaml"
    description: "Feature-specific persona assignment (driver persona and participant list)""",

    "push.md": """artifacts:
  - path: "(GitHub PR)"
    description: "Pull request created with implementation summary and tracking information""",

    "qa.generate-fixtures.md": """artifacts:
  - path: "tests/fixtures/"
    description: "Test fixture files and sample data for testing the feature""",

    "qa.implement.md": """artifacts:
  - path: "tests/<test-files>"
    description: "Implementation of test cases for the feature (unit, integration, e2e tests)""",

    "qa.plan.md": """artifacts:
  - path: ".gobuildme/qa/<feature>/qa-plan.md"
    description: "Quality assurance testing plan with test scenarios and coverage strategy""",

    "qa.review-tests.md": """artifacts:
  - path: ".gobuildme/qa/<feature>/test-review-report.md"
    description: "Review report validating test coverage and quality standards""",

    "qa.tasks.md": """artifacts:
  - path: ".gobuildme/qa/<feature>/qa-tasks.md"
    description: "Ordered list of QA testing tasks with dependencies and execution sequence""",

    "ready-to-push.md": """artifacts:
  - path: "(validation report)"
    description: "Validation report confirming all requirements met before pushing code""",

    "review.md": """artifacts:
  - path: ".gobuildme/review/<feature>/review-summary.md"
    description: "Code review summary with findings, recommendations, and approval decision""",

    "security-setup.md": """artifacts:
  - path: ".github/workflows/security.yml"
    description: "GitHub Actions security scanning workflows and configurations""",

    "validate-architecture.md": """artifacts:
  - path: ".gobuildme/validation/<feature>/architecture-validation.md"
    description: "Validation report confirming implementation matches architecture specifications""",

    "validate-constitution.md": """artifacts:
  - path: ".gobuildme/validation/<feature>/constitution-validation.md"
    description: "Validation report confirming adherence to project constitution principles""",

    "validate-conventions.md": """artifacts:
  - path: ".gobuildme/validation/<feature>/conventions-validation.md"
    description: "Validation report checking code follows established project conventions""",
}

def add_artifacts_to_template(template_path):
    """Add artifact declarations to a template if missing."""
    with open(template_path, 'r') as f:
        content = f.read()

    # Check if artifacts already declared
    if 'artifacts:' in content:
        return False

    filename = template_path.name
    if filename not in ARTIFACT_DECLARATIONS:
        print(f"⚠️  No artifact declaration for {filename}, skipping")
        return False

    # Find the position to insert artifacts (after description, before scripts)
    # Pattern: find "scripts:" and insert before it

    artifacts_text = ARTIFACT_DECLARATIONS[filename]
    r'\1artifacts:\n  ' + artifacts_text.replace('\n', '\n  ') + '\n\2'

    # Actually, let me do this more carefully with proper YAML formatting
    # Find the line with "scripts:" and insert artifacts before it
    lines = content.split('\n')
    new_lines = []
    inserted = False

    for i, line in enumerate(lines):
        if line.startswith('scripts:') and not inserted:
            # Insert artifacts block before scripts
            new_lines.append(ARTIFACT_DECLARATIONS[filename])
            new_lines.append(line)
            inserted = True
        else:
            new_lines.append(line)

    if not inserted:
        print(f"⚠️  Could not find 'scripts:' line in {filename}")
        return False

    new_content = '\n'.join(new_lines)

    with open(template_path, 'w') as f:
        f.write(new_content)

    print(f"✅ {filename}")
    return True

def main():
    """Main entry point."""
    template_dir = Path("templates/commands")

    print("Adding artifact declarations to templates...\n")

    count = 0
    for template_file in sorted(template_dir.glob("*.md")):
        if add_artifacts_to_template(template_file):
            count += 1

    print(f"\n✅ Added artifacts to {count} templates")

if __name__ == '__main__':
    main()
