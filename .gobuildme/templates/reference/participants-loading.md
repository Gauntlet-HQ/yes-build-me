# Participants Loading Pattern

**Purpose**: Shared logic for loading and merging persona participants across workflow commands.

**Used by**: `/gbm.specify`, `/gbm.plan`, `/gbm.implement`, `/gbm.tests`, `/gbm.review`, `/gbm.push`

---

## When to Use This Pattern

Use this pattern in any command that needs to:
- Load the feature persona (driver)
- Load participant personas
- Merge required sections from all active personas
- Merge quality gates from all active personas
- Apply the highest coverage threshold

---

## Loading Participants (Step Template)

### Step: Load Persona Configuration

**Add this step early in your command workflow** (typically after loading feature directory):

```markdown
X) **Load Persona Configuration** (with Participants Support):

   **Load feature persona file**:
   - Read `$FEATURE_DIR/persona.yaml`
   - Extract `feature_persona` (driver persona ID)
   - Extract `participants` (list of participant persona IDs, may be empty)
   - If file missing, fall back to default persona from `.gobuildme/config/personas.yaml`

   **Build active personas list**:
   - Active personas = [driver] + participants
   - Example: If driver=`backend_engineer` and participants=`[security_compliance, sre]`
   - Then active_personas = `[backend_engineer, security_compliance, sre]`

   **Load all active persona definitions**:
   - For each persona ID in active_personas:
     * Read `.gobuildme/personas/<id>.yaml`
     * Extract persona configuration

   **Store for later use**:
   - `$DRIVER_PERSONA` = feature_persona (e.g., "backend_engineer")
   - `$PARTICIPANTS` = participants list (e.g., ["security_compliance", "sre"])
   - `$ACTIVE_PERSONAS` = combined list (e.g., ["backend_engineer", "security_compliance", "sre"])
```

---

## Merging Required Sections (Command-Specific)

### Pattern: Merge Required Sections for Current Command

**Use this pattern when validating spec/plan/etc. sections**:

```markdown
Y) **Merge Required Sections** (for /<command>):

   **For each active persona**:
   - Read `.gobuildme/personas/<persona_id>.yaml`
   - Extract `required_sections["/<command>"]` (e.g., required_sections["/plan"])
   - Collect all sections into a merged list

   **Example for /gbm.plan**:
   ```yaml
   # backend_engineer.yaml
   required_sections:
     "/plan":
       - "API Contracts"
       - "Data Model & Migrations"

   # security_compliance.yaml
   required_sections:
     "/plan":
       - "Threat Model"
       - "Data Classification"

   # sre.yaml
   required_sections:
     "/plan":
       - "CI/CD Pipeline"
       - "SLOs"
   ```

   **Merged required sections for /plan**:
   - API Contracts (backend)
   - Data Model & Migrations (backend)
   - Threat Model (security)
   - Data Classification (security)
   - CI/CD Pipeline (sre)
   - SLOs (sre)

   **Validation**:
   - Verify ALL merged sections are present in the artifact
   - Report missing sections by persona
   - Block progression if required sections missing
```

---

## Merging Quality Gates

### Pattern: Combine Quality Gates from All Personas

**Use this pattern in /gbm.review and /gbm.push**:

```markdown
Z) **Merge Quality Gates** (from all active personas):

   **For each active persona**:
   - Read `.gobuildme/personas/<persona_id>.yaml`
   - Extract `defaults.quality_gates` list
   - Collect all gates into a merged list

   **Example**:
   ```yaml
   # backend_engineer.yaml
   defaults:
     quality_gates:
       - contracts_present
       - migrations_planned

   # security_compliance.yaml
   defaults:
     quality_gates:
       - threat_model_present
       - data_classification

   # sre.yaml
   defaults:
     quality_gates:
       - slos_defined
       - rollback_plan
   ```

   **Merged quality gates**:
   - contracts_present (backend)
   - migrations_planned (backend)
   - threat_model_present (security)
   - data_classification (security)
   - slos_defined (sre)
   - rollback_plan (sre)

   **Validation**:
   - Verify ALL merged gates pass
   - Report failures by persona and gate
   - Block merge if any gate fails
```

---

## Computing Coverage Threshold

### Pattern: Apply Highest Coverage Threshold

**Use this pattern in /gbm.tests**:

```markdown
W) **Compute Coverage Threshold** (highest wins):

   **For each active persona**:
   - Read `.gobuildme/personas/<persona_id>.yaml`
   - Extract `defaults.coverage_floor` (e.g., 0.85 = 85%)
   - Track the maximum value

   **Example**:
   ```yaml
   # backend_engineer.yaml
   defaults:
     coverage_floor: 0.85  # 85%

   # security_compliance.yaml
   defaults:
     coverage_floor: 0.0   # 0% (security doesn't write code)

   # sre.yaml
   defaults:
     coverage_floor: 0.0   # 0% (SRE focuses on infra)
   ```

   **Effective coverage threshold**:
   - Max(0.85, 0.0, 0.0) = **0.85 (85%)**
   - Apply this threshold to coverage validation

   **If no personas have coverage_floor**:
   - Fall back to constitution default (typically 85%)
   - Or global default: 85%
```

---

## Implementation Checklist

When adding participants support to a command:

### 1. Load Participants (Early Step)
- [ ] Add "Load Persona Configuration" step after feature directory detection
- [ ] Extract driver persona and participants from `$FEATURE_DIR/persona.yaml`
- [ ] Build `$ACTIVE_PERSONAS` list (driver + participants)
- [ ] Load all persona YAML files

### 2. Merge Required Sections (Validation Step)
- [ ] Identify which command you're in (e.g., `/plan`, `/specify`)
- [ ] For each active persona, load `required_sections["/<command>"]`
- [ ] Merge all sections into single list
- [ ] Validate artifact contains ALL merged sections
- [ ] Report missing sections grouped by persona

### 3. Merge Quality Gates (For /review and /push)
- [ ] For each active persona, load `defaults.quality_gates`
- [ ] Merge all gates into single list
- [ ] Validate ALL gates pass
- [ ] Report failures grouped by persona and gate

### 4. Apply Coverage Threshold (For /tests)
- [ ] For each active persona, load `defaults.coverage_floor`
- [ ] Compute `max(all coverage_floor values)`
- [ ] Apply highest threshold to coverage validation
- [ ] Report which persona set the threshold

### 5. Update Command Output
- [ ] Show active personas in command output
- [ ] Display merged requirements grouped by persona
- [ ] Show which persona contributed each requirement
- [ ] Report validation results per persona

---

## Example: Full Integration in /gbm.plan

```markdown
## /gbm.plan Command Flow with Participants

1) Track command start (telemetry)

2) **Load Persona Configuration** (with Participants):
   - Read `$FEATURE_DIR/persona.yaml`
   - Driver: backend_engineer
   - Participants: [security_compliance, sre]
   - Active personas: [backend_engineer, security_compliance, sre]

3) Load feature directory and spec.md

4) **Merge Required Sections for /plan**:
   - Backend Engineer requires:
     * API Contracts
     * Data Model & Migrations
   - Security requires:
     * Threat Model
     * Data Classification
   - SRE requires:
     * CI/CD Pipeline
     * SLOs
   - **Total required sections: 6**

5) Generate plan.md based on spec

6) **Validate Plan Contains All Required Sections**:
   - ✓ API Contracts (backend)
   - ✓ Data Model & Migrations (backend)
   - ✓ Threat Model (security)
   - ✓ Data Classification (security)
   - ✓ CI/CD Pipeline (sre)
   - ✗ SLOs (sre) - **MISSING**

   **Result**: BLOCKED - Missing 1 required section (SRE: SLOs)

7) If validation passes, write plan.md and continue
   If validation fails, show missing sections and stop

8) Track command complete (telemetry)
```

---

## Error Handling

### Persona File Missing

```markdown
**If `.gobuildme/personas/<persona_id>.yaml` not found**:
- Check if persona exists in `.gobuildme/config/personas.yaml`
- If yes: Copy from templates (`templates/personas/definitions/<id>.yaml`)
- If no: ERROR - Invalid persona ID in participants list
- Suggest valid persona IDs from config
```

### Empty Participants List

```markdown
**If `participants: []` or participants field missing**:
- Active personas = [driver] only
- No merging needed, use driver requirements only
- This is valid - participants are optional
```

### Persona Without Required Sections

```markdown
**If persona YAML missing `required_sections["/<command>"]`**:
- Skip this persona for section merging
- This is valid - not all personas contribute to all commands
- Example: Product Manager has no required sections for /implement
```

---

## Testing Your Implementation

### Test Case 1: Single Persona (No Participants)
```yaml
# persona.yaml
feature_persona: backend_engineer
participants: []
```
- Expected: Only backend_engineer requirements enforced
- Coverage threshold: 85% (backend default)

### Test Case 2: Multiple Participants
```yaml
# persona.yaml
feature_persona: backend_engineer
participants: [security_compliance, sre]
```
- Expected: Requirements from all 3 personas merged
- Coverage threshold: 85% (highest of 85%, 0%, 0%)

### Test Case 3: Participant Without Requirements for Command
```yaml
# persona.yaml
feature_persona: backend_engineer
participants: [product_manager]
```
- Expected: Only backend requirements (product_manager has no /plan requirements)
- Coverage threshold: 85% (product_manager has 0%)

---

## References

- **Persona Definitions**: `templates/personas/definitions/*.yaml`
- **Control Gates Documentation**: `docs/reference/control-gates.md` (lines 1648-1774)
- **Issue #18**: https://github.com/gofundme/gobuildme/issues/18
