#!/usr/bin/env python3
"""Extract artifact declarations from command templates."""

import yaml
import json
from pathlib import Path
import sys

def extract_frontmatter(content):
    """Extract YAML frontmatter from markdown content."""
    if not content.startswith("---"):
        return None

    # Find the closing ---
    yaml_end = content.find("---", 3)
    if yaml_end == -1:
        return None

    try:
        return yaml.safe_load(content[3:yaml_end])
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}", file=sys.stderr)
        return None

def extract_artifacts():
    """Extract all artifact declarations from command templates."""

    artifacts_map = {}
    templates_dir = Path("templates/commands")

    if not templates_dir.exists():
        print(f"Error: {templates_dir} does not exist", file=sys.stderr)
        return {}

    # Process each template file
    for template_file in sorted(templates_dir.glob("*.md")):
        with open(template_file) as f:
            content = f.read()

        frontmatter = extract_frontmatter(content)
        if not frontmatter:
            continue

        command_name = template_file.stem

        # Extract artifacts if they exist
        if "artifacts" in frontmatter and frontmatter["artifacts"]:
            artifacts_map[command_name] = {
                "creates": frontmatter["artifacts"],
                "description": frontmatter.get("description", "")
            }
        else:
            # Still track commands without artifacts
            artifacts_map[command_name] = {
                "creates": [],
                "description": frontmatter.get("description", "")
            }

        # Look for references to other artifacts in the content
        # Common patterns: .gobuildme/specs/<feature>/... or $FEATURE_DIR/...
        reads = []
        # Map of canonical path -> all search patterns
        # NOTE: Only include patterns with explicit path prefixes to avoid false positives
        # Backtick-wrapped filenames (`spec.md`) are too loose - they appear in prose descriptions
        artifact_patterns = {
            ".gobuildme/memory/constitution.md": [
                ".gobuildme/memory/constitution.md",
            ],
            "$FEATURE_DIR/request.md": [
                "$FEATURE_DIR/request.md",
                ".gobuildme/specs/<feature>/request.md",
            ],
            "$FEATURE_DIR/spec.md": [
                "$FEATURE_DIR/spec.md",
                ".gobuildme/specs/<feature>/spec.md",
            ],
            "$FEATURE_DIR/plan.md": [
                "$FEATURE_DIR/plan.md",
                ".gobuildme/specs/<feature>/plan.md",
            ],
            "$FEATURE_DIR/prd.md": [
                "$FEATURE_DIR/prd.md",
                ".gobuildme/specs/<feature>/prd.md",
            ],
            "$FEATURE_DIR/tasks.md": [
                "$FEATURE_DIR/tasks.md",
                ".gobuildme/specs/<feature>/tasks.md",
            ],
            "$FEATURE_DIR/data-model.md": [
                "$FEATURE_DIR/data-model.md",
                ".gobuildme/specs/<feature>/data-model.md",
            ],
            ".gobuildme/specs/epics/<epic>/slice-registry.yaml": [
                ".gobuildme/specs/epics/<epic>/slice-registry.yaml",
            ],
            ".gobuildme/docs/technical/architecture/": [
                ".gobuildme/docs/technical/architecture/",
            ],
            ".gobuildme/config/personas.yaml": [
                ".gobuildme/config/personas.yaml",
            ],
        }

        for canonical_path, patterns in artifact_patterns.items():
            # Check if any pattern matches in content
            if any(pattern in content for pattern in patterns):
                if canonical_path not in [a.get("path", "") for a in artifacts_map[command_name]["creates"]]:
                    reads.append(canonical_path)

        if reads:
            artifacts_map[command_name]["reads"] = reads

    # Save as JSON
    output_path = Path("docs/artifacts-manifest.json")
    output_path.parent.mkdir(exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(artifacts_map, f, indent=2)

    # Generate markdown reference
    generate_markdown_reference(artifacts_map)

    return artifacts_map

def generate_markdown_reference(artifacts_map):
    """Generate human-readable markdown from artifacts map."""

    output = []
    output.append("# Command Artifact Reference\n\n")
    output.append("*Auto-generated from command template declarations*\n\n")
    output.append(f"**Total Commands**: {len(artifacts_map)}\n\n")

    # Count artifacts
    total_creates = sum(len(info["creates"]) for info in artifacts_map.values())
    output.append(f"**Total Artifacts Created**: {total_creates}\n\n")

    output.append("---\n\n")

    # Commands that create artifacts
    output.append("## Commands and Their Artifacts\n\n")

    for command, info in sorted(artifacts_map.items()):
        if info["creates"] or info.get("reads"):
            output.append(f"### `/gbm.{command}`\n\n")

            if info["description"]:
                output.append(f"*{info['description']}*\n\n")

            if info["creates"]:
                output.append("**Creates:**\n")
                for artifact in info["creates"]:
                    path = artifact.get("path", "")
                    desc = artifact.get("description", "")
                    output.append(f"- `{path}`")
                    if desc:
                        output.append(f" - {desc}")
                    output.append("\n")
                output.append("\n")

            if info.get("reads"):
                output.append("**Reads:**\n")
                for path in info["reads"]:
                    output.append(f"- `{path}`\n")
                output.append("\n")

    # Reverse mapping: artifacts to commands
    output.append("---\n\n")
    output.append("## Artifacts and Their Creators\n\n")

    artifact_creators = {}
    for command, info in artifacts_map.items():
        for artifact in info["creates"]:
            path = artifact.get("path", "")
            if path:
                if path not in artifact_creators:
                    artifact_creators[path] = {
                        "creators": [],
                        "description": artifact.get("description", "")
                    }
                artifact_creators[path]["creators"].append(command)

    for path, info in sorted(artifact_creators.items()):
        output.append(f"### `{path}`\n")
        if info["description"]:
            output.append(f"*{info['description']}*\n")
        output.append(f"**Created by**: `/gbm.{', /gbm.'.join(info['creators'])}`\n\n")

    # Commands without artifacts
    output.append("---\n\n")
    output.append("## Commands Without Artifacts\n\n")

    no_artifacts = [cmd for cmd, info in artifacts_map.items()
                   if not info["creates"] and not info.get("reads")]

    if no_artifacts:
        output.append("These commands perform actions without creating tracked artifacts:\n\n")
        for command in sorted(no_artifacts):
            desc = artifacts_map[command]["description"]
            output.append(f"- `/gbm.{command}`")
            if desc:
                output.append(f" - {desc}")
            output.append("\n")
    else:
        output.append("*All commands either create or read artifacts.*\n")

    # Write to file
    output_path = Path("docs/COMMAND-ARTIFACTS.md")
    with open(output_path, "w") as f:
        f.write("".join(output))

    print(f"✓ Generated {output_path}")

if __name__ == "__main__":
    artifacts = extract_artifacts()
    print(f"✓ Extracted {len(artifacts)} commands to docs/artifacts-manifest.json")
    print("✓ Generated docs/COMMAND-ARTIFACTS.md")
