#!/usr/bin/env python3
# fmt: off
"""
Record command execution metadata for audit trail.

This script is called by shell scripts after artifacts are created.
It extracts metadata (User Goals, etc.) and records them in a central registry.

Usage:
    python3 scripts/record-metadata.py \\
        --feature-name "authentication" \\
        --command "request" \\
        --artifact-path ".gobuildme/specs/authentication/request.md" \\
        --created-by "alice.smith"
"""

import sys
import json
import logging
from pathlib import Path
from argparse import ArgumentParser
from typing import Optional

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)


def record_metadata(
    repo_root: Path,
    feature_name: str,
    command_name: str,
    artifact_path: str,
    created_by: str
) -> bool:
    """
    Record command execution metadata.

    Args:
        repo_root: Root directory of the repository
        feature_name: Feature name (e.g., 'authentication')
        command_name: Command that ran (e.g., 'request', 'specify', 'plan', 'tasks')
        artifact_path: Relative path to created artifact
        created_by: Username of who ran the command

    Returns:
        True if recorded successfully, False otherwise
    """
    try:
        # Import MetadataManager from the installed gobuildme package
        # This allows the script to work both in gobuildme repo and in target projects
        from gobuildme_cli.metadata import MetadataManager

        metadata_manager = MetadataManager(repo_root)

        # For request command, extract user goals from the request.md file
        input_summary = None
        if command_name == "request":
            artifact_path_obj = repo_root / artifact_path
            input_summary = metadata_manager.extract_user_goals_from_request(artifact_path_obj)

            if input_summary:
                logger.info(f"Extracted {len(input_summary)} user goals from request")

        # Record the command execution
        success = metadata_manager.record_command_execution(
            feature_name=feature_name,
            command_name=command_name,
            artifact_path=artifact_path,
            created_by=created_by,
            input_summary=input_summary
        )

        if success:
            metadata_file = repo_root / ".gobuildme" / "metadata" / "specs" / f"{feature_name}.yaml"
            logger.info(f"Recorded metadata: {metadata_file}")
            return True
        else:
            logger.warning(f"Failed to record metadata for {feature_name}/{command_name}")
            return False

    except ImportError as e:
        logger.warning(f"Could not import gobuildme_cli: {e}")
        logger.warning("Metadata recording skipped (gobuildme package not installed)")
        return False
    except Exception as e:
        logger.error(f"Error recording metadata: {e}")
        return False


def get_created_by(override: Optional[str] = None) -> str:
    """
    Get the username for who created the artifact.

    Args:
        override: Optional override value (command-line provided)

    Returns:
        Username string
    """
    if override:
        return override

    try:
        from gobuildme_cli.utils.git import get_git_user
        return get_git_user()
    except Exception:
        return "[unknown]"


def main():
    """Main entry point."""
    parser = ArgumentParser(description="Record command execution metadata for audit trail")
    parser.add_argument(
        "--feature-name",
        required=True,
        help="Feature name (e.g., 'authentication')"
    )
    parser.add_argument(
        "--command",
        required=True,
        help="Command name (e.g., 'request', 'specify', 'plan', 'tasks')"
    )
    parser.add_argument(
        "--artifact-path",
        required=True,
        help="Relative path to created artifact"
    )
    parser.add_argument(
        "--created-by",
        default=None,
        help="Username of who ran the command (defaults to git user.name)"
    )
    parser.add_argument(
        "--repo-root",
        default=".",
        help="Repository root directory (defaults to current directory)"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output result as JSON"
    )

    args = parser.parse_args()

    # Get repository root
    repo_root = Path(args.repo_root).resolve()

    # Get created_by (use provided value or get from git)
    created_by = get_created_by(args.created_by)

    # Record metadata
    success = record_metadata(
        repo_root=repo_root,
        feature_name=args.feature_name,
        command_name=args.command,
        artifact_path=args.artifact_path,
        created_by=created_by
    )

    # Output result
    if args.json:
        result = {
            "success": success,
            "feature": args.feature_name,
            "command": args.command,
            "artifact": args.artifact_path,
            "created_by": created_by
        }
        print(json.dumps(result))

    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()

# fmt: on
