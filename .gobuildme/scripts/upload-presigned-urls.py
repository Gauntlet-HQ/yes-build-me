#!/usr/bin/env python3
"""
Upload Files to S3 Using Presigned URLs (with Parallel Upload Support)

This script reads a JSON file containing presigned S3 URLs and uploads
the corresponding local files to S3 using HTTP PUT requests. Files are
uploaded in parallel using multiple worker threads for improved performance.

The JSON file should have the format:
{
    "s3-key-path/filename": "https://presigned-url...",
    ...
}

The script extracts the relative file path from the S3 key and locates
the corresponding local file to upload.

Usage:
    python upload_to_presigned_urls.py <json-file> [--spec-dir <path>] [--workers N]
    python upload_to_presigned_urls.py presigned_urls_output.json
    python upload_to_presigned_urls.py presigned_urls_output.json --spec-dir /path/to/specs/AT-201
    python upload_to_presigned_urls.py presigned_urls_output.json --workers 10
    python upload_to_presigned_urls.py presigned_urls_output.json --debug
    python upload_to_presigned_urls.py presigned_urls_output.json --quiet
    python upload_to_presigned_urls.py presigned_urls_output.json --no-progress
    python upload_to_presigned_urls.py --help

Arguments:
    json-file: Path to JSON file containing presigned URLs
    --spec-dir: Base directory containing files to upload (default: .gobuildme/specs)
    --dry-run: Show what would be uploaded without actually uploading
    --debug: Enable DEBUG-level logging for detailed troubleshooting
    --verbose: Show detailed progress information (deprecated, use --debug)
    --workers: Number of parallel upload workers (default: 5)
    --quiet: Suppress progress bar and individual file messages
    --no-progress: Disable progress bar even when tqdm is available
"""

import argparse
import json
import logging
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Dict, Tuple

try:
    import requests
except ImportError:
    print("Error: 'requests' library is required. Install with: pip install requests")
    sys.exit(1)

# Try to import tqdm for progress bar support (optional dependency)
try:
    from tqdm import tqdm

    TQDM_AVAILABLE = True
except ImportError:
    TQDM_AVAILABLE = False

# Configure logging (will be updated based on --debug flag in main())
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)


def parse_arguments() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Upload files to S3 using presigned URLs", formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__
    )
    parser.add_argument("json_file", type=str, help="Path to JSON file containing presigned URLs")
    parser.add_argument(
        "--spec-dir", type=str, default=".gobuildme/specs", help="Base directory containing files to upload (default: .gobuildme/specs)"
    )
    parser.add_argument("--dry-run", action="store_true", help="Show what would be uploaded without actually uploading")
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Enable DEBUG-level logging to show detailed information about file resolution, " "HTTP requests, and upload progress.",
    )
    parser.add_argument("--verbose", action="store_true", help="Show detailed progress information (deprecated, use --debug instead)")
    parser.add_argument("--workers", type=int, default=5, help="Number of parallel upload workers (default: 5)")
    parser.add_argument("--quiet", "-q", action="store_true", help="Suppress progress bar and individual file messages; only show summary")
    parser.add_argument("--no-progress", action="store_true", help="Disable progress bar even when tqdm is available (useful for CI/CD)")

    return parser.parse_args()


def load_presigned_urls(json_file: str) -> Dict[str, str]:
    """Load presigned URLs from JSON file."""
    logger.debug(f"Loading presigned URLs from: {json_file}")
    try:
        with open(json_file, "r") as f:
            urls = json.load(f)
        logger.info(f"Loaded {len(urls)} presigned URLs from {json_file}")
        logger.debug(f"JSON file size: {Path(json_file).stat().st_size} bytes")
        logger.debug(f"S3 keys loaded: {list(urls.keys())[:5]}{'...' if len(urls) > 5 else ''}")
        return urls
    except FileNotFoundError:
        logger.error(f"JSON file not found: {json_file}")
        logger.debug(f"Attempted path: {Path(json_file).resolve()}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in {json_file}: {e}")
        logger.debug(f"JSON decode error details: {e}")
        sys.exit(1)


def extract_relative_path(s3_key: str) -> str:
    """
    Extract relative file path from S3 key.

    Example:
        spec-repository/AT-201/tasks.md -> AT-201/tasks.md
    """
    parts = s3_key.split("/")
    if len(parts) > 1 and parts[0] == "spec-repository":
        relative_path = "/".join(parts[1:])
        logger.debug("Extracted relative path from S3 key:")
        logger.debug(f"  S3 key: {s3_key}")
        logger.debug(f"  Relative path: {relative_path}")
        return relative_path
    logger.debug(f"S3 key does not start with 'spec-repository/', using as-is: {s3_key}")
    return s3_key


def find_local_file(relative_path: str, spec_dir: str) -> Path:
    """Find the local file corresponding to the S3 key."""
    logger.debug("Finding local file:")
    logger.debug(f"  Relative path: {relative_path}")
    logger.debug(f"  Spec directory: {spec_dir}")

    # Strip the spec ID from the relative path if it's duplicated
    # e.g., if spec_dir ends with "AT-201" and relative_path starts with "AT-201/"
    spec_dir_path = Path(spec_dir)
    spec_id = spec_dir_path.name
    logger.debug(f"  Spec ID: {spec_id}")

    # If relative_path starts with spec_id/, strip it
    original_relative_path = relative_path
    if relative_path.startswith(f"{spec_id}/"):
        relative_path = relative_path[len(spec_id) + 1 :]
        logger.debug(f"  Stripped spec ID from path: {original_relative_path} -> {relative_path}")

    local_path = spec_dir_path / relative_path
    logger.debug(f"  Resolved local path: {local_path}")

    if not local_path.exists():
        logger.debug(f"  File does not exist: {local_path}")
        raise FileNotFoundError(f"Local file not found: {local_path}")

    if not local_path.is_file():
        logger.debug(f"  Path is not a file: {local_path}")
        raise ValueError(f"Path is not a file: {local_path}")

    logger.debug(f"  File found successfully: {local_path.stat().st_size} bytes")
    return local_path


def upload_single_file(
    s3_key: str, presigned_url: str, spec_dir: str, dry_run: bool = False, verbose: bool = False
) -> Tuple[str, bool, str]:
    """
    Upload a single file to S3.

    Returns:
        Tuple of (relative_path: str, success: bool, message: str)
    """
    logger.debug(f"\n{'='*60}")
    logger.debug(f"Processing upload for S3 key: {s3_key}")
    logger.debug(f"{'='*60}")

    relative_path = extract_relative_path(s3_key)

    try:
        # Find local file
        local_file = find_local_file(relative_path, spec_dir)

        logger.debug("Upload configuration:")
        logger.debug(f"  S3 key: {s3_key}")
        logger.debug(f"  Local file: {local_file}")
        logger.debug(f"  Presigned URL: {presigned_url[:100]}...")
        logger.debug(f"  Dry run: {dry_run}")

        # Upload file
        success, message = upload_file(local_file, presigned_url, dry_run)
        logger.debug(f"Upload result: success={success}, message={message}")
        return relative_path, success, message

    except FileNotFoundError as e:
        logger.debug(f"FileNotFoundError: {e}")
        return relative_path, None, f"File not found - {e}"
    except Exception as e:
        logger.debug(f"Unexpected exception: {e}")
        return relative_path, False, f"Unexpected error - {e}"


def upload_file(local_file: Path, presigned_url: str, dry_run: bool = False) -> Tuple[bool, str]:
    """
    Upload a file to S3 using a presigned URL.

    Returns:
        Tuple of (success: bool, message: str)
    """
    logger.debug(f"Uploading file: {local_file}")

    if dry_run:
        file_size = local_file.stat().st_size
        logger.debug(f"  DRY RUN: Would upload {file_size} bytes")
        return True, f"Would upload {file_size} bytes"

    try:
        # Read file content
        logger.debug("  Reading file content...")
        with open(local_file, "rb") as f:
            file_content = f.read()
        logger.debug(f"  File content read: {len(file_content)} bytes")

        # Upload to S3 using PUT request
        # NOTE: Do NOT add Content-Type or other headers unless they were included
        # when the presigned URL was generated, as they are part of the signature
        logger.debug("  Sending PUT request to S3...")
        logger.debug(f"  Request URL: {presigned_url[:100]}...")
        logger.debug(f"  Request body size: {len(file_content)} bytes")
        logger.debug("  Request timeout: 60 seconds")

        response = requests.put(presigned_url, data=file_content, timeout=60)

        logger.debug(f"  Response status code: {response.status_code}")
        logger.debug(f"  Response headers: {dict(response.headers)}")
        logger.debug(f"  Response body: {response.text[:200] if response.text else '(empty)'}")

        if response.status_code in (200, 204):
            logger.debug("  Upload successful!")
            return True, f"Successfully uploaded {len(file_content)} bytes"
        else:
            logger.debug(f"  Upload failed with status {response.status_code}")
            return False, f"Upload failed with status {response.status_code}: {response.text[:200]}"

    except FileNotFoundError as e:
        logger.debug(f"  FileNotFoundError: {e}")
        return False, f"File not found: {e}"
    except requests.exceptions.RequestException as e:
        logger.debug(f"  RequestException: {e}")
        return False, f"Network error: {e}"
    except Exception as e:
        logger.debug(f"  Unexpected exception: {e}")
        return False, f"Unexpected error: {e}"


class ProgressTracker:
    """
    A class to track and display upload progress.

    Supports tqdm progress bar when available and stdout is a TTY,
    falls back to simple text-based progress otherwise.
    """

    def __init__(self, total: int, quiet: bool = False, no_progress: bool = False):
        """
        Initialize the progress tracker.

        Args:
            total: Total number of files to upload
            quiet: If True, suppress all progress output
            no_progress: If True, disable progress bar even if tqdm is available
        """
        self.total = total
        self.completed = 0
        self.quiet = quiet
        self.no_progress = no_progress

        # Determine if we should use tqdm
        self.is_tty = sys.stdout.isatty()
        self.use_tqdm = TQDM_AVAILABLE and self.is_tty and not quiet and not no_progress

        # Calculate fallback progress interval
        # For small counts, print every file; for large counts, print every N files
        if total <= 10:
            self.fallback_interval = 1
        elif total <= 50:
            self.fallback_interval = 5
        else:
            self.fallback_interval = max(5, total // 10)

        self.pbar = None

    def __enter__(self):
        """Start progress tracking."""
        if self.use_tqdm:
            self.pbar = tqdm(
                total=self.total,
                desc="Uploading files",
                unit="file",
                ncols=80,
                bar_format="{desc}: {n_fmt}/{total_fmt} [{bar}] {percentage:3.0f}%",
            )
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Clean up progress tracking."""
        if self.pbar is not None:
            self.pbar.close()
        return False

    def update(self):
        """Update progress after a file completes."""
        self.completed += 1

        if self.quiet:
            return

        if self.use_tqdm:
            self.pbar.update(1)
        elif not self.no_progress:
            # Fallback: print simple text progress at intervals or on last item
            if (self.completed % self.fallback_interval == 0) or (self.completed == self.total):
                # Only print when not in TTY mode or when explicitly using fallback
                if not self.is_tty or not TQDM_AVAILABLE:
                    print(f"Uploading {self.completed}/{self.total}...", file=sys.stderr)


def main():
    """Main execution function."""
    args = parse_arguments()

    # Configure logging level based on --debug or --verbose flag
    if args.debug or args.verbose:
        logger.setLevel(logging.DEBUG)
        # Also update the root logger
        logging.getLogger().setLevel(logging.DEBUG)
        logger.debug("Debug logging enabled")
        if args.verbose and not args.debug:
            logger.warning("--verbose is deprecated, use --debug instead")

    # In quiet mode, suppress INFO-level logging for individual files
    if args.quiet:
        logger.setLevel(logging.WARNING)

    logger.debug("Configuration:")
    logger.debug(f"  JSON file: {args.json_file}")
    logger.debug(f"  Spec directory: {args.spec_dir}")
    logger.debug(f"  Dry run: {args.dry_run}")
    logger.debug(f"  Workers: {args.workers}")
    logger.debug(f"  Quiet: {args.quiet}")
    logger.debug(f"  No progress: {args.no_progress}")
    logger.debug(f"  tqdm available: {TQDM_AVAILABLE}")
    logger.debug(f"  stdout is TTY: {sys.stdout.isatty()}")

    # Load presigned URLs
    presigned_urls = load_presigned_urls(args.json_file)

    # Track results
    total = len(presigned_urls)
    successful = 0
    failed = 0
    skipped = 0

    if not args.quiet:
        logger.info(f"Starting upload of {total} files with {args.workers} parallel workers...")
    logger.debug("Upload statistics:")
    logger.debug(f"  Total files to upload: {total}")
    logger.debug(f"  Parallel workers: {args.workers}")
    logger.debug(f"  Spec directory: {Path(args.spec_dir).resolve()}")

    if args.dry_run:
        if not args.quiet:
            logger.info("DRY RUN MODE - No files will be uploaded")
        logger.debug("  Files will be validated but not uploaded")

    # Process files in parallel
    logger.debug(f"Creating ThreadPoolExecutor with {args.workers} workers...")
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        # Submit all upload tasks
        logger.debug(f"Submitting {total} upload tasks to executor...")
        future_to_s3key = {
            executor.submit(upload_single_file, s3_key, presigned_url, args.spec_dir, args.dry_run, args.verbose): s3_key
            for s3_key, presigned_url in presigned_urls.items()
        }
        logger.debug(f"All {total} tasks submitted. Waiting for completion...")

        # Process completed uploads with progress tracking
        with ProgressTracker(total, args.quiet, args.no_progress) as progress:
            for future in as_completed(future_to_s3key):
                s3_key = future_to_s3key[future]

                try:
                    relative_path, success, message = future.result()
                    logger.debug(f"Task result: relative_path={relative_path}, success={success}, message={message}")

                    if success is True:
                        successful += 1
                        if not args.quiet:
                            logger.info(f"{relative_path}: {message}")
                        logger.debug(f"  Successful uploads so far: {successful}/{progress.completed + 1}")
                    elif success is False:
                        failed += 1
                        logger.error(f"{relative_path}: {message}")
                        logger.debug(f"  Failed uploads so far: {failed}/{progress.completed + 1}")
                    else:  # success is None (skipped)
                        skipped += 1
                        logger.warning(f"{relative_path}: {message}")
                        logger.debug(f"  Skipped uploads so far: {skipped}/{progress.completed + 1}")

                except Exception as e:
                    relative_path = extract_relative_path(s3_key)
                    failed += 1
                    logger.error(f"{relative_path}: Task failed - {e}")
                    logger.debug(f"  Task exception details: {e}")

                progress.update()

    # Print summary (always shown, even in quiet mode)
    logger.debug("All upload tasks completed. Generating summary...")

    # Use print for summary to ensure it's always shown, even in quiet mode
    print("", file=sys.stderr)
    print("=" * 60, file=sys.stderr)
    print("Upload Summary", file=sys.stderr)
    print("=" * 60, file=sys.stderr)
    print(f"Total files: {total}", file=sys.stderr)
    print(f"Successful: {successful}", file=sys.stderr)
    print(f"Failed: {failed}", file=sys.stderr)
    print(f"Skipped: {skipped}", file=sys.stderr)
    print(f"Workers used: {args.workers}", file=sys.stderr)
    print("=" * 60, file=sys.stderr)

    logger.debug("Final statistics:")
    logger.debug(f"  Success rate: {(successful/total*100) if total > 0 else 0:.1f}%")
    logger.debug(f"  Failure rate: {(failed/total*100) if total > 0 else 0:.1f}%")
    logger.debug(f"  Skip rate: {(skipped/total*100) if total > 0 else 0:.1f}%")

    # Exit with appropriate code
    if failed > 0:
        logger.debug("Exiting with code 1 (failures detected)")
        sys.exit(1)
    elif skipped > 0:
        logger.debug("Exiting with code 2 (files skipped)")
        sys.exit(2)
    else:
        logger.debug("Exiting with code 0 (all uploads successful)")
        sys.exit(0)


if __name__ == "__main__":
    main()
