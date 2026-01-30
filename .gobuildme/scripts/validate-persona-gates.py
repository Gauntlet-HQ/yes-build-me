#!/usr/bin/env python3
# fmt: off
"""
Validate that persona quality gates in YAML match documentation.

This script ensures consistency between:
- .gobuildme/personas/*.yaml (source of truth)
- docs/personas-detailed-guide.md
- docs/personas/persona-gates-reference.md
"""

import yaml
import sys
from pathlib import Path
from typing import Dict, List, Tuple

# Color codes for output
RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
RESET = '\033[0m'


def load_persona_yaml(yaml_path: Path) -> Dict:
    """Load and parse a persona YAML file."""
    with open(yaml_path) as f:
        return yaml.safe_load(f)


def extract_gates_from_yaml(persona_data: Dict) -> List[str]:
    """Extract quality gates from persona YAML."""
    return persona_data.get('defaults', {}).get('quality_gates', [])


def check_gates_in_file(file_path: Path, persona_id: str, expected_gates: List[str]) -> Tuple[bool, List[str]]:
    """Check if all expected gates are mentioned in a documentation file."""
    with open(file_path) as f:
        content = f.read()

    missing_gates = []
    for gate in expected_gates:
        # Look for gate name with backticks or as plain text
        if f'`{gate}`' not in content and gate not in content:
            missing_gates.append(gate)

    return len(missing_gates) == 0, missing_gates


def main():
    """Main validation function."""
    repo_root = Path(__file__).parent.parent
    personas_dir = repo_root / '.gobuildme' / 'personas'
    docs_dir = repo_root / 'docs'

    print("🔍 Validating Persona Quality Gates\n")
    print("=" * 60)

    errors = []
    warnings = []
    success_count = 0

    # Get all persona YAML files
    yaml_files = sorted(personas_dir.glob('*.yaml'))

    for yaml_file in yaml_files:
        persona_data = load_persona_yaml(yaml_file)
        persona_id = persona_data['id']
        persona_name = persona_data['name']
        gates = extract_gates_from_yaml(persona_data)

        print(f"\n📋 {persona_name} ({persona_id})")
        print(f"   Gates: {', '.join(gates)}")

        # Check detailed guide
        detailed_guide = docs_dir / 'personas-detailed-guide.md'
        if detailed_guide.exists():
            ok, missing = check_gates_in_file(detailed_guide, persona_id, gates)
            if ok:
                print(f"   {GREEN}✓{RESET} personas-detailed-guide.md")
                success_count += 1
            else:
                msg = f"{persona_name}: Missing gates in personas-detailed-guide.md: {missing}"
                errors.append(msg)
                print(f"   {RED}✗{RESET} personas-detailed-guide.md - Missing: {missing}")

        # Check persona gates reference
        gates_ref = docs_dir / 'personas' / 'persona-gates-reference.md'
        if gates_ref.exists():
            ok, missing = check_gates_in_file(gates_ref, persona_id, gates)
            if ok:
                print(f"   {GREEN}✓{RESET} persona-gates-reference.md")
                success_count += 1
            else:
                msg = f"{persona_name}: Missing gates in persona-gates-reference.md: {missing}"
                errors.append(msg)
                print(f"   {RED}✗{RESET} persona-gates-reference.md - Missing: {missing}")

        # Check persona manual if it exists
        manual_path = docs_dir / 'personas' / f'{persona_id.replace("_", "-")}-manual.md'
        if manual_path.exists():
            ok, missing = check_gates_in_file(manual_path, persona_id, gates)
            if ok:
                print(f"   {GREEN}✓{RESET} {manual_path.name}")
                success_count += 1
            else:
                msg = f"{persona_name}: Missing gates in {manual_path.name}: {missing}"
                warnings.append(msg)
                print(f"   {YELLOW}⚠{RESET} {manual_path.name} - Missing: {missing}")

    # Summary
    print("\n" + "=" * 60)
    print("\n📊 Summary:")
    print(f"   Total checks: {success_count + len(errors) + len(warnings)}")
    print(f"   {GREEN}Passed: {success_count}{RESET}")
    print(f"   {RED}Errors: {len(errors)}{RESET}")
    print(f"   {YELLOW}Warnings: {len(warnings)}{RESET}")

    if errors:
        print(f"\n{RED}❌ ERRORS:{RESET}")
        for error in errors:
            print(f"   - {error}")

    if warnings:
        print(f"\n{YELLOW}⚠️  WARNINGS:{RESET}")
        for warning in warnings:
            print(f"   - {warning}")

    if not errors and not warnings:
        print(f"\n{GREEN}✅ All persona gates are consistent!{RESET}")
        return 0
    elif errors:
        print(f"\n{RED}❌ Validation failed. Please fix errors.{RESET}")
        return 1
    else:
        print(f"\n{YELLOW}⚠️  Validation passed with warnings.{RESET}")
        return 0


if __name__ == '__main__':
    sys.exit(main())

# fmt: on
