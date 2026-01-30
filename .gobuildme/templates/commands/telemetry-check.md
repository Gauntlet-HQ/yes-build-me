---
description: "Validate telemetry configuration and test connectivity to the telemetry API"
artifacts:
  - path: "(console output)"
    description: "Telemetry health check report with configuration, connectivity status, and recommendations"
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

# Telemetry Health Check

This command validates your telemetry configuration and tests connectivity to the telemetry API.

## What This Command Does

1. **Configuration Check**:
   - Validates environment variables (`TELEMETRY_ENABLED`, `TELEMETRY_API_URL`, `TELEMETRY_TIMEOUT`)
   - Checks manifest.json telemetry settings
   - Shows configuration source (env var, manifest, or default)

2. **API Connectivity Test**:
   - Tests connection to telemetry API
   - Measures response time
   - Reports any connectivity issues

3. **Script Availability**:
   - Verifies bash telemetry script exists
   - Verifies PowerShell telemetry script exists

4. **Recommendations**:
   - Provides actionable recommendations for any issues found
   - Links to troubleshooting documentation

## Instructions

### Step 1: Run Health Check

Execute the health check command:

**Bash**:
```bash
gobuildme telemetry check
```

**PowerShell**:
```powershell
gobuildme telemetry check
```

### Step 2: Review Output

The command will display:

1. **Configuration** - Current telemetry settings
2. **API Connectivity** - Connection status and response time
3. **Telemetry Scripts** - Script availability
4. **Summary** - Overall health status
5. **Recommendations** - Actions to fix any issues

### Step 3: Test End-to-End Telemetry Flow

Run the telemetry test command:

```bash
gobuildme telemetry test
```

This will test the complete telemetry flow (track-start and track-complete events).

## Expected Output

### ✅ All Checks Passed

**Step 1 - Health Check**:
```
🔍 GoBuildMe Telemetry Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Configuration
┏━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━┓
┃ Setting            ┃ Value                                       ┃ Source  ┃
┡━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━┩
│ TELEMETRY_ENABLED  │ true                                        │ default │
│ TELEMETRY_API_URL  │ https://ai-cli-telemetry.classy-test.org    │ default │
│ TELEMETRY_TIMEOUT  │ 5s                                          │ default │
└────────────────────┴─────────────────────────────────────────────┴─────────┘

2. API Connectivity
   Testing: https://ai-cli-telemetry.classy-test.org
   ✓  Health endpoint is reachable
   Response time: 234ms

   Testing telemetry API...
   ✓  Telemetry API is working

3. Telemetry Scripts
   ✓  Bash script found: .gobuildme/scripts/bash/get-telemetry-context.sh
   ✓  PowerShell script found: .gobuildme/scripts/powershell/get-telemetry-context.ps1

Summary
   ✓  All checks passed!
   Telemetry is fully operational
```

**Step 3 - End-to-End Test**:
```
🧪 Testing Telemetry
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Testing track-start...
   ✓  Track-start successful
   Command ID: fb4ae41e-8c6a-4264-9604-472df7578816

2. Testing track-complete...
   ✓  Track-complete successful

Test complete
```

### ⚠️ Issues Found

If issues are found, the command will show:
- Specific problems detected
- Actionable recommendations to fix them
- Links to troubleshooting documentation

## Common Issues and Solutions

### Issue: Telemetry is Disabled

**Solution**:
```bash
# Enable via CLI
gobuildme config telemetry --enabled

# Or via environment variable
export TELEMETRY_ENABLED=true
```

### Issue: API Not Reachable

**Solutions**:
1. Check network connection
2. Increase timeout: `export TELEMETRY_TIMEOUT=15`
3. Verify firewall/proxy settings
4. For local development: `export TELEMETRY_API_URL=http://localhost:8080`

### Issue: Scripts Not Found

**Solution**:
```bash
# Initialize or update project
gobuildme init --here
```

## Troubleshooting

For detailed troubleshooting, see:
- **[Telemetry Troubleshooting Guide](../../docs/telemetry/troubleshooting.md)**
- **[Telemetry User Guide](../../docs/telemetry/user-guide.md)**
- **[Technical Schemas](../../docs/technical/telemetry-schemas.md)**

## Manual Testing

You can also test telemetry manually:

**Bash**:
```bash
# Test track-start
.gobuildme/scripts/bash/get-telemetry-context.sh \
  --track-start \
  --command-name "gbm.telemetry_check"

# Test track-complete (use command_id from above)
.gobuildme/scripts/bash/get-telemetry-context.sh \
  --track-complete \
  --command-id "<command_id>" \
  --status "success" \
  --results '{"test": "data"}'
```

**PowerShell**:
```powershell
# Test track-start
.\get-telemetry-context.ps1 `
  -TrackStart `
  -CommandName "gbm.telemetry_check"

# Test track-complete (use command_id from above)
.\get-telemetry-context.ps1 `
  -TrackComplete `
  -CommandId "<command_id>" `
  -Status "success" `
  -Results '{"test": "data"}'
```

---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide


**Next Steps**: If all checks pass, your telemetry is working correctly. If issues are found, follow the recommendations provided.

