#!/usr/bin/env python3
"""
Generate Presigned URLs for Spec Folder Upload to AWS S3

This script generates presigned URLs for uploading spec folder files to AWS S3,
enabling client-side direct uploads. The URLs allow clients to PUT files directly
to S3 without server-side upload handling.

Target S3 Bucket: Configurable via GBM_S3_BUCKET env var or .gobuildme/config.yaml
S3 Key Pattern: spec-repository/{relative-path-from-spec-folder}/{filename}

Usage:
    python generate_spec_presigned_urls.py /path/to/spec/folder
    python generate_spec_presigned_urls.py /path/to/spec/folder --dry-run
    python generate_spec_presigned_urls.py /path/to/spec/folder --debug
    python generate_spec_presigned_urls.py --help

Requirements:
    - boto3 library installed
    - AWS credentials configured (via ~/.aws/credentials, environment variables, or IAM role)
    - Read access to the local spec folder
    - S3 bucket access permissions

Configuration:
    Settings can be configured via environment variables or .gobuildme/config.yaml.
    Priority order: environment variables > config file > defaults

    Environment Variables:
        GBM_S3_BUCKET       - Override S3 bucket name
        GBM_URL_EXPIRATION  - Override presigned URL expiration (seconds)

    Config File (.gobuildme/config.yaml):
        upload_spec:
          s3_bucket: "my-custom-bucket"
          url_expiration: 7200  # 2 hours in seconds

Output:
    - Presigned URLs printed to stdout (one per line with S3 key reference)
    - JSON file saved to script directory: presigned_urls_output.json
"""

import argparse
import json
import logging
import os
import sys
from pathlib import Path
from typing import Dict, Any

import boto3
from botocore.exceptions import ClientError, NoCredentialsError, TokenRetrievalError

# Configure logging (will be updated based on --debug flag in main())
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)

# Suppress verbose boto3/botocore logging
logging.getLogger("boto3").setLevel(logging.CRITICAL)
logging.getLogger("botocore").setLevel(logging.CRITICAL)
logging.getLogger("urllib3").setLevel(logging.CRITICAL)

# Default values - bucket should be configured via GBM_S3_BUCKET or config.yaml
DEFAULT_S3_BUCKET = "tools-ai-agents-spec-driven-development-gfm"
DEFAULT_URL_EXPIRATION = 3600  # 1 hour in seconds
S3_KEY_PREFIX = "spec-repository"
OUTPUT_JSON_FILENAME = "presigned_urls_output.json"
CONFIG_FILE_PATH = ".gobuildme/config.yaml"


def load_config_from_file() -> Dict[str, Any]:
    """
    Load configuration from .gobuildme/config.yaml if it exists.

    Returns:
        Dictionary with upload_spec configuration, or empty dict if file not found or parsing fails.
        Expected keys: s3_bucket, url_expiration
    """
    config_path = Path(CONFIG_FILE_PATH)

    # Try to find config file relative to current working directory
    if not config_path.exists():
        # Also try relative to repo root (if in subdirectory)
        for parent in Path.cwd().parents:
            potential_config = parent / CONFIG_FILE_PATH
            if potential_config.exists():
                config_path = potential_config
                break

    if not config_path.exists():
        logger.debug(f"Config file not found: {CONFIG_FILE_PATH}")
        return {}

    logger.debug(f"Found config file: {config_path}")

    try:
        # Try to import yaml (optional dependency)
        try:
            import yaml
        except ImportError:
            logger.debug("PyYAML not installed, attempting fallback YAML parsing")
            return _parse_yaml_fallback(config_path)

        with open(config_path, "r") as f:
            config = yaml.safe_load(f)

        if not config or not isinstance(config, dict):
            logger.debug("Config file is empty or invalid")
            return {}

        upload_spec_config = config.get("upload_spec", {})
        if not isinstance(upload_spec_config, dict):
            logger.debug("upload_spec config is not a dictionary")
            return {}

        logger.debug(f"Loaded upload_spec config from file: {upload_spec_config}")
        return upload_spec_config

    except Exception as e:
        logger.debug(f"Failed to parse config file: {e}")
        return {}


def _parse_yaml_fallback(config_path: Path) -> Dict[str, Any]:
    """
    Simple fallback YAML parser for basic key-value pairs.
    Only handles the specific upload_spec section we need.

    Args:
        config_path: Path to the YAML config file

    Returns:
        Dictionary with upload_spec configuration
    """
    try:
        with open(config_path, "r") as f:
            content = f.read()

        result = {}
        in_upload_spec = False
        indent_level = 0

        for line in content.split("\n"):
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue

            # Calculate indentation
            current_indent = len(line) - len(line.lstrip())

            # Check if we're entering upload_spec section
            if stripped == "upload_spec:" or stripped.startswith("upload_spec:"):
                in_upload_spec = True
                indent_level = current_indent
                continue

            # Check if we've exited upload_spec section (less or equal indentation)
            if in_upload_spec and current_indent <= indent_level and ":" in stripped:
                key = stripped.split(":")[0].strip()
                if key and not key.startswith("#") and key != "upload_spec":
                    in_upload_spec = False
                    continue

            # Parse key-value pairs within upload_spec
            if in_upload_spec and ":" in stripped:
                key, _, value = stripped.partition(":")
                key = key.strip()
                value = value.strip().strip('"').strip("'")

                # Remove inline comments
                if "#" in value:
                    value = value.split("#")[0].strip().strip('"').strip("'")

                if key == "s3_bucket" and value:
                    result["s3_bucket"] = value
                elif key == "url_expiration" and value:
                    try:
                        result["url_expiration"] = int(value)
                    except ValueError:
                        pass

        logger.debug(f"Fallback YAML parsing result: {result}")
        return result

    except Exception as e:
        logger.debug(f"Fallback YAML parsing failed: {e}")
        return {}


def get_config_value(key: str, env_var: str, default: Any, config: Dict[str, Any]) -> Any:
    """
    Get configuration value with priority: env var > config file > default.

    Args:
        key: Config file key name
        env_var: Environment variable name
        default: Default value
        config: Config dictionary from file

    Returns:
        Configuration value with proper priority
    """
    # Priority 1: Environment variable
    env_value = os.environ.get(env_var)
    if env_value is not None:
        logger.debug(f"Using {key} from environment variable {env_var}: {env_value}")
        return env_value

    # Priority 2: Config file
    if key in config:
        logger.debug(f"Using {key} from config file: {config[key]}")
        return config[key]

    # Priority 3: Default
    logger.debug(f"Using default {key}: {default}")
    return default


# Load configuration with priority: env vars > config file > defaults
_config = load_config_from_file()
S3_BUCKET_NAME = get_config_value("s3_bucket", "GBM_S3_BUCKET", DEFAULT_S3_BUCKET, _config)
_url_exp = get_config_value("url_expiration", "GBM_URL_EXPIRATION", DEFAULT_URL_EXPIRATION, _config)
PRESIGNED_URL_EXPIRATION = int(_url_exp) if isinstance(_url_exp, str) else _url_exp


def get_current_aws_account() -> dict | None:
    """
    Get the current AWS account information.

    Returns:
        Dictionary with Account, UserId, and Arn, or None if unable to retrieve
    """
    try:
        sts_client = boto3.client("sts")
        identity = sts_client.get_caller_identity()
        logger.debug(f"AWS Identity: Account={identity.get('Account')}, UserId={identity.get('UserId')}, Arn={identity.get('Arn')}")
        return identity
    except Exception as e:
        logger.debug(f"Failed to retrieve AWS account information: {e}")
        return None


def validate_aws_credentials(s3_client) -> bool:
    """
    Validate AWS credentials by attempting to access the S3 bucket.

    Args:
        s3_client: Boto3 S3 client instance

    Returns:
        True if credentials are valid and bucket is accessible, False otherwise
    """
    try:
        s3_client.head_bucket(Bucket=S3_BUCKET_NAME)
        logger.info(f"AWS credentials validated. Access to bucket '{S3_BUCKET_NAME}' confirmed.")
        return True
    except NoCredentialsError:
        logger.error("AWS credentials not found. Please configure AWS credentials.")
        logger.error("   Options: ~/.aws/credentials, environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY), or IAM role")
        return False
    except TokenRetrievalError:
        logger.error("AWS SSO token has expired or is invalid.")
        logger.error("   Please refresh your SSO session:")
        logger.error("   Run: aws sso login --profile <your-profile>")
        return False
    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        logger.debug(f"ClientError during credential validation: {e}")

        if error_code == "403":
            logger.error(f"Access denied to bucket '{S3_BUCKET_NAME}'.")
            logger.error("   Check IAM permissions for the target AWS account")
            logger.error("   Required permissions: s3:GetBucketLocation, s3:ListBucket, s3:PutObject")
        elif error_code == "404":
            logger.error(f"Bucket '{S3_BUCKET_NAME}' not found.")
            logger.error("   Verify the bucket name is correct in GBM_S3_BUCKET or .gobuildme/config.yaml")
            logger.error("   Or create the bucket in your AWS account")
        else:
            logger.error(f"AWS error: {e}")
        return False
    except Exception as e:
        # Catch any other credential-related errors
        error_msg = str(e).lower()
        if "token" in error_msg or "sso" in error_msg or "expired" in error_msg:
            logger.error("AWS credentials have expired or are invalid.")
            logger.error("   Please refresh your AWS session:")
            logger.error("   Run: aws sso login --profile <your-profile>")
        else:
            logger.error(f"Unexpected error validating credentials: {e}")
        return False


def discover_files(spec_folder: Path) -> list[Path]:
    """
    Recursively discover all files in the spec folder.

    Args:
        spec_folder: Path to the spec folder

    Returns:
        List of Path objects for all files found
    """
    logger.debug(f"Starting file discovery in: {spec_folder}")
    files = []
    try:
        for item in spec_folder.rglob("*"):
            if item.is_file():
                files.append(item)
                logger.debug(f"  Discovered file: {item}")
        logger.info(f"Discovered {len(files)} file(s) in spec folder")
        logger.debug(f"File discovery complete. Total files: {len(files)}")
        return files
    except PermissionError as e:
        logger.error(f"Permission denied while reading folder: {e}")
        sys.exit(1)


def generate_s3_key(file_path: Path, spec_folder: Path) -> str:
    """
    Generate S3 key from file path, preserving directory structure including spec folder name.

    Args:
        file_path: Path to the file
        spec_folder: Path to the spec folder (base directory)

    Returns:
        S3 key string in format: spec-repository/{spec-folder-name}/{relative-path}/{filename}
        Example: spec-repository/AT-201/plan.md
    """
    spec_folder_name = spec_folder.name
    relative_path = file_path.relative_to(spec_folder)
    s3_key = f"{S3_KEY_PREFIX}/{spec_folder_name}/{relative_path.as_posix()}"

    logger.debug("S3 key generation:")
    logger.debug(f"  File path: {file_path}")
    logger.debug(f"  Spec folder: {spec_folder}")
    logger.debug(f"  Spec folder name: {spec_folder_name}")
    logger.debug(f"  Relative path: {relative_path}")
    logger.debug(f"  Generated S3 key: {s3_key}")

    return s3_key


def generate_presigned_url(s3_client, s3_key: str) -> str | None:
    """
    Generate a presigned URL for PUT access to an S3 object.

    Args:
        s3_client: Boto3 S3 client instance
        s3_key: S3 key for the object

    Returns:
        Presigned URL string, or None if generation fails
    """
    logger.debug(f"Generating presigned URL for S3 key: {s3_key}")
    logger.debug(f"  Bucket: {S3_BUCKET_NAME}")
    logger.debug(f"  Expiration: {PRESIGNED_URL_EXPIRATION} seconds")

    try:
        presigned_url = s3_client.generate_presigned_url(
            ClientMethod="put_object", Params={"Bucket": S3_BUCKET_NAME, "Key": s3_key}, ExpiresIn=PRESIGNED_URL_EXPIRATION
        )
        logger.debug(f"  Generated presigned URL: {presigned_url}")
        return presigned_url
    except ClientError as e:
        logger.error(f"Failed to generate presigned URL for '{s3_key}': {e}")
        logger.debug(f"  ClientError details: {e}")
        return None


def test_s3_upload(s3_client, spec_folder: Path) -> bool:
    """
    Test S3 upload permissions by uploading and deleting a test file.

    Args:
        s3_client: Boto3 S3 client instance
        spec_folder: Path to the spec folder (used to generate proper test key)

    Returns:
        True if test upload succeeds, False otherwise
    """
    spec_folder_name = spec_folder.name
    test_key = f"{S3_KEY_PREFIX}/{spec_folder_name}/.dry-run-test"
    test_content = b"This is a test file for dry-run validation"

    logger.debug("Dry-run test configuration:")
    logger.debug(f"  Spec folder: {spec_folder}")
    logger.debug(f"  Spec folder name: {spec_folder_name}")
    logger.debug(f"  Test S3 key: {test_key}")
    logger.debug(f"  Test content size: {len(test_content)} bytes")

    try:
        # Test PUT operation
        logger.info(f"Testing upload permissions with test file: {test_key}")
        s3_client.put_object(Bucket=S3_BUCKET_NAME, Key=test_key, Body=test_content)
        logger.info("Test upload successful")

        # Clean up test file
        logger.info("Cleaning up test file...")
        s3_client.delete_object(Bucket=S3_BUCKET_NAME, Key=test_key)
        logger.info("Test file deleted successfully")

        return True
    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "403":
            logger.error("Upload permission denied. Check IAM permissions for PUT operations.")
        else:
            logger.error(f"Test upload failed: {e}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error during test upload: {e}")
        return False


def main():
    """Main execution function."""
    parser = argparse.ArgumentParser(
        description="Generate presigned URLs for uploading spec folder files to AWS S3",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Test connectivity and permissions (dry-run)
  python generate_spec_presigned_urls.py /path/to/spec/folder --dry-run

  # Generate presigned URLs for a spec folder
  python generate_spec_presigned_urls.py /path/to/spec/folder
  python generate_spec_presigned_urls.py .gobuildme/specs/my-feature

  # Enable debug logging to see detailed information
  python generate_spec_presigned_urls.py /path/to/spec/folder --debug
  python generate_spec_presigned_urls.py /path/to/spec/folder --dry-run --debug

Output:
  - Presigned URLs printed to stdout
  - JSON file saved to: presigned_urls_output.json
        """,
    )
    parser.add_argument("spec_folder", type=str, help="Path to the spec folder containing files to upload")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Test connectivity, permissions, and upload without generating presigned URLs. "
        "Performs validation checks and attempts a test upload to verify S3 access.",
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Enable DEBUG-level logging to show detailed information about file discovery, "
        "S3 key generation, and presigned URL creation.",
    )

    args = parser.parse_args()

    # Configure logging level based on --debug flag
    if args.debug:
        logger.setLevel(logging.DEBUG)
        # Also update the root logger
        logging.getLogger().setLevel(logging.DEBUG)
        logger.debug("Debug logging enabled")

    # Validate spec folder path
    spec_folder = Path(args.spec_folder).resolve()
    if not spec_folder.exists():
        logger.error(f"Spec folder does not exist: {spec_folder}")
        sys.exit(1)

    if not spec_folder.is_dir():
        logger.error(f"Path is not a directory: {spec_folder}")
        sys.exit(1)

    logger.info(f"Generating presigned URLs for spec folder: {spec_folder}")
    logger.debug(f"Spec folder name: {spec_folder.name}")
    logger.debug(f"Target S3 bucket: {S3_BUCKET_NAME}")
    logger.debug(f"S3 key prefix: {S3_KEY_PREFIX}")
    logger.debug(f"Presigned URL expiration: {PRESIGNED_URL_EXPIRATION} seconds")

    # Initialize S3 client
    try:
        s3_client = boto3.client("s3")
    except NoCredentialsError:
        logger.error("AWS credentials not found. Please configure AWS credentials.")
        logger.error("   Options: ~/.aws/credentials, environment variables, or IAM role")
        sys.exit(1)
    except Exception as e:
        error_msg = str(e).lower()
        if "token" in error_msg or "sso" in error_msg or "expired" in error_msg:
            logger.error("AWS credentials have expired or are invalid.")
            logger.error("   Please refresh your AWS session:")
            logger.error("   Run: aws sso login --profile <your-profile>")
        else:
            logger.error(f"Failed to initialize S3 client: {e}")
        sys.exit(1)

    # Get and log AWS account information
    aws_identity = get_current_aws_account()
    if aws_identity:
        logger.debug(f"Current AWS account: {aws_identity.get('Account')}")
        logger.debug(f"AWS ARN: {aws_identity.get('Arn')}")

    # Validate AWS credentials
    # if not validate_aws_credentials(s3_client):
    #     sys.exit(1)

    # Dry-run mode: test upload permissions and exit
    if args.dry_run:
        logger.info("\n" + "=" * 60)
        logger.info("DRY-RUN MODE: Testing connectivity and permissions")
        logger.info("=" * 60)

        # Test upload permissions
        if test_s3_upload(s3_client, spec_folder):
            logger.info("\n" + "=" * 60)
            logger.info("DRY-RUN SUCCESSFUL")
            logger.info("  - AWS credentials: Valid")
            logger.info(f"  - Bucket access: Confirmed ({S3_BUCKET_NAME})")
            logger.info("  - Upload permissions: Verified")
            logger.info("=" * 60)
            sys.exit(0)
        else:
            logger.error("\n" + "=" * 60)
            logger.error("DRY-RUN FAILED")
            logger.error("  - Upload permissions test failed")
            logger.error("  - Check IAM permissions for PUT/DELETE operations")
            logger.error("=" * 60)
            sys.exit(1)

    # Discover all files in spec folder
    files = discover_files(spec_folder)
    if not files:
        logger.warning("No files found in spec folder")
        sys.exit(0)

    # Generate presigned URLs
    logger.debug(f"Starting presigned URL generation for {len(files)} files")
    presigned_urls: Dict[str, str] = {}
    failed_count = 0

    for idx, file_path in enumerate(files, 1):
        logger.debug(f"\nProcessing file {idx}/{len(files)}: {file_path}")
        s3_key = generate_s3_key(file_path, spec_folder)
        logger.info(f"Generating presigned URL for {s3_key}...")

        presigned_url = generate_presigned_url(s3_client, s3_key)
        if presigned_url:
            presigned_urls[s3_key] = presigned_url
            print(f"{s3_key} -> {presigned_url}")
            logger.debug(f"  Successfully generated presigned URL for {s3_key}")
        else:
            failed_count += 1
            logger.debug(f"  Failed to generate presigned URL for {s3_key}")

    # Save presigned URLs to JSON file
    script_dir = Path(__file__).parent
    output_file = script_dir / OUTPUT_JSON_FILENAME

    logger.debug(f"Saving presigned URLs to JSON file: {output_file}")
    logger.debug(f"Total URLs to save: {len(presigned_urls)}")

    try:
        with open(output_file, "w") as f:
            json.dump(presigned_urls, f, indent=2)
        logger.info(f"Presigned URLs saved to: {output_file}")
        logger.debug(f"JSON file size: {output_file.stat().st_size} bytes")
    except IOError as e:
        logger.error(f"Failed to save JSON output file: {e}")
        logger.debug(f"IOError details: {e}")
        sys.exit(1)

    # Summary
    logger.info(f"\n{'='*60}")
    logger.info("Summary:")
    logger.info(f"  Total files: {len(files)}")
    logger.info(f"  Successful: {len(presigned_urls)}")
    logger.info(f"  Failed: {failed_count}")
    logger.info(f"  Expiration: {PRESIGNED_URL_EXPIRATION} seconds (1 hour)")
    logger.info(f"  Output file: {output_file}")
    logger.info(f"{'='*60}")

    if failed_count > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
