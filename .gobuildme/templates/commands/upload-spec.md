---
description: "Upload specification files to S3 for centralized storage and analysis with telemetry tracking."
artifacts:
  - path: "(S3 bucket)"
    description: "Specification files uploaded to s3://<configured-bucket>/spec-repository/<feature>/"
scripts:
  sh: scripts/bash/upload-spec.sh {ARGS}
  ps: scripts/powershell/upload-spec.ps1 {ARGS}
---

## Output Style Requirements (MANDATORY)

**Upload Summary Output**:
- Summary table: files processed, successful, failed, skipped
- S3 location as single line
- Errors only shown if failures occurred
- No verbose logging unless --verbose flag passed

**Status Indicators**:
- ✅ Success: All files uploaded
- ⚠️ Partial: Some files uploaded, some failed
- ❌ Failure: No files uploaded or validation failed

**Available Flags**:
- `--dry-run`: Validate credentials and list files without uploading
- `--verbose` or `-v`: Show detailed progress information
- `--help` or `-h`: Show help message

**Environment Variables** (optional overrides):
- `GBM_S3_BUCKET`: Override default S3 bucket
- `AWS_PROFILE`: AWS profile to use for credentials

For complete style guidance, see .gobuildme/templates/_concise-style.md

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

Goal: Upload the current specification folder to AWS S3 for centralized storage, enabling cross-project analysis, metrics tracking, and spec repository management. This command generates presigned URLs for secure upload and tracks the operation via telemetry.

STRICTLY NON-DESTRUCTIVE: Do **not** modify any local files. Only upload files to S3.

Execution steps:

1. Track command start:
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-start --command-name "gbm.upload_spec" --feature-dir "$FEATURE_DIR" --parameters '{"arguments": $ARGUMENTS}' --quiet` from repo root.
   - Parse JSON output and store `command_id`
   - Initialize error tracking: `upload_errors = []`

2. Determine specification directory:
   - If user provided a spec path in $ARGUMENTS, use that path
   - Otherwise, run `.gobuildme/scripts/bash/check-prerequisites.sh --json --paths-only` from repo root
   - Parse JSON output to get `FEATURE_DIR` (the current spec directory)
   - Validate that the directory exists and contains spec files
   - If no spec directory found, report error and exit

3. Validate AWS credentials and connectivity:
   - Run `.gobuildme/scripts/bash/upload-spec.sh "$SPEC_DIR" --dry-run` from repo root (or use the script directly)
   - This performs a test upload to verify:
     * AWS credentials are valid
     * S3 bucket is accessible
     * Upload permissions are configured correctly
   - If dry-run fails:
     * Capture error: `upload_errors.append({"stage": "validation", "error": "<stderr output>"})`
     * Report error to user with actionable guidance (check AWS credentials, SSO login, etc.)
     * Skip to step 7 (track completion with failure status)

4. Generate presigned URLs:
   - Run `.gobuildme/scripts/generate-spec-presigned-urls.py "$SPEC_DIR"` from repo root
   - This script:
     * Discovers all files in the spec directory recursively
     * Generates presigned S3 URLs for each file
     * Saves URLs to `.gobuildme/scripts/presigned_urls_output.json`
     * Outputs URL mappings to stdout
   - If generation fails:
     * Capture error: `upload_errors.append({"stage": "url_generation", "error": "<stderr output>"})`
     * Skip to step 7 (track completion with failure status)
   - Parse output to count total files to upload

5. Upload files to S3:
   - Run `.gobuildme/scripts/upload-presigned-urls.py .gobuildme/scripts/presigned_urls_output.json --spec-dir "$SPEC_DIR"` from repo root
   - This script:
     * Reads presigned URLs from JSON file
     * Uploads files in parallel (default 5 workers)
     * Reports progress for each file
     * Returns exit code 0 on success, 1 on failures, 2 on skipped files
   - Monitor output for:
     * Successful uploads (✅)
     * Failed uploads (❌)
     * Skipped files (⚠️)
   - If upload fails:
     * Capture error: `upload_errors.append({"stage": "upload", "error": "<stderr output>"})`
     * Continue to step 6 to report partial results

6. Report upload results:
   - Parse upload script output to extract:
     * Total files processed
     * Successful uploads
     * Failed uploads
     * Skipped files
   - Display summary table:
     ```
     ### Specification Upload Summary
     | Metric | Count |
     |--------|-------|
     | Total Files | <count> |
     | Successful | <count> |
     | Failed | <count> |
     | Skipped | <count> |
     ```
   - If any failures occurred, list failed files with error messages
   - Report S3 location: `s3://<configured-bucket>/spec-repository/<spec-folder-name>/`

7. Track command complete:
   - Prepare results JSON per schema `.gobuildme/docs/technical/telemetry-schemas.md#gbm-upload-spec`:
     ```json
     {
       "spec_id": "<spec-folder-name>",
       "total_files": <integer>,
       "successful_uploads": <integer>,
       "failed_uploads": <integer>,
       "skipped_files": <integer>,
       "s3_location": "s3://<configured-bucket>/spec-repository/<spec-folder-name>/",
       "upload_errors": <array of error objects>,
       "overall_status": "success" | "partial_success" | "failure"
     }
     ```
   - Determine status:
     * "success": All files uploaded successfully (failed_uploads == 0)
     * "partial_success": Some files uploaded (successful_uploads > 0 && failed_uploads > 0)
     * "failure": No files uploaded or validation failed (successful_uploads == 0)
   - Run `.gobuildme/scripts/bash/get-telemetry-context.sh --track-complete --command-id "$command_id" --status "<success|failure>" --results "$results_json" --quiet` from repo root
   - Add `--error "$error_msg"` if status is "failure"

8. Provide next actions:
   - If upload successful (🟢 status):
     * "Specification uploaded successfully to S3"
     * "Files are now available for centralized analysis and metrics tracking"
     * Suggest next steps based on workflow context (e.g., `/gbm.analyze`, `/gbm.implement`)
   - If partial success (🟡 status):
     * "Specification partially uploaded - some files failed"
     * "Review failed files and retry upload if needed"
     * List failed files with error details
   - If upload failed (🔴 status):
     * "Specification upload failed"
     * Provide troubleshooting guidance based on error type:
       - AWS credentials: "Run: aws sso login --profile <your-profile>"
       - Bucket access: "Check IAM permissions for S3 bucket access"
       - Network issues: "Verify network connectivity and retry"

Behavior rules:
- NEVER modify local spec files
- NEVER delete or overwrite existing S3 files (uploads are additive)
- ALWAYS validate AWS credentials before attempting upload
- ALWAYS report detailed error messages for troubleshooting
- KEEP output concise but informative
- If zero files found in spec directory, report warning and exit gracefully

Context: $ARGUMENTS

Next Steps (always print at the end):
- If upload successful (🟢 status): Specification is now available in S3 for analysis. Continue with workflow.
- If upload failed (🔴 status): Review error messages, fix issues (AWS credentials, permissions, network), and retry.
- If partial success (🟡 status): Review failed files, address issues, and re-run upload for failed files only.

