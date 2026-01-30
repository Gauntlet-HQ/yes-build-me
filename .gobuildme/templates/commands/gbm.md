---
description: "Display context-sensitive help for GoBuildMe commands and workflows (alias for /gbm.help)"
artifacts:
  - path: "(console output)"
    description: "Help content displayed in console based on requested topic"
---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide

You are the GoBuildMe help command (alias for `/gbm.help`). Your job is to provide context-sensitive help based on the user's topic request.

## User Input

The user may provide optional arguments to focus on specific topics:

**Arguments**: $ARGUMENTS

## Your Task

This command is an **alias** for `/gbm.help`. Provide the exact same functionality.

1. **Parse Arguments**: Read `$ARGUMENTS` and extract the topic
   - If empty or whitespace only → show `overview` topic
   - If provided → normalize and match to topic

2. **Normalize Topic**:
   - Convert to lowercase
   - Replace spaces with hyphens
   - Apply alias mapping

3. **Display Help**: Show the corresponding topic section

4. **Error Handling**: If topic not found, show error with available topics

## Alias Mapping

Apply these aliases before matching:
- `qa-workflow` → `qa`
- `test` or `tests` → `testing`
- `gates` → `quality-gates`
- `start` → `getting-started`
- `sdd` → `workflow`
- `constitution-setup` → `constitution`

## Available Topics

- `overview` (default)
- `getting-started`
- `workflow`
- `personas`
- `qa`
- `commands`
- `architecture`
- `testing`
- `quality-gates`

## Quick Examples

```
/gbm                     Show overview
/gbm getting-started     Quick start guide
/gbm personas            Show all personas
/gbm qa                  QA workflow
/gbm workflow            Core SDD workflow
/gbm commands            All commands
```

---
## Output Style Requirements (MANDATORY)

- Clear status messages (success/error/warning)
- File paths as inline code, not separate lines
- Error messages: one line + actionable fix
- Tables for structured data, bullets for lists
- See _concise-style.md for full style guide


**IMPORTANT**: For the complete help content for each topic, refer to the `/gbm.help` command template (`templates/commands/help.md`). This command (`/gbm`) should display the exact same content as `/gbm.help` for the requested topic.

The help content sections are:
- overview
- getting-started
- workflow
- personas
- qa
- commands
- architecture
- testing
- quality-gates

Display the appropriate section based on the user's $ARGUMENTS, following the same logic as `/gbm.help`.

---

# TOPIC CONTENT

**NOTE TO AI AGENT**: Since this is an alias, you should use the same help content as defined in `/gbm.help` command. The full content for each topic (overview, getting-started, workflow, personas, qa, commands, architecture, testing, quality-gates) is available in the `help.md` template.

For consistency and to avoid duplication, please display the relevant help section from `/gbm.help` based on the user's requested topic.

If you need the full content, refer to: `templates/commands/help.md`

---

## Quick Reference (Topics)

**Overview** - General GoBuildMe introduction, topic list
**Getting Started** - 4-step setup guide
**Workflow** - 12-step core SDD workflow
**Personas** - All 12 personas with descriptions
**QA** - 6-step QA testing workflow
**Commands** - All available commands by category
**Architecture** - Architecture documentation
**Testing** - Testing best practices
**Quality Gates** - Validation and quality gates

Next Steps (always print at the end):

⚠️ **Before proceeding, review the generated content:**
- Does it align with your requirements?
- Is all necessary information captured?
- Do the decisions sound correct?

**Running the next command = approval + responsibility acceptance.** No confirmation prompt.

**Not ready?**
- Run `/gbm.help getting-started` for detailed workflow guidance
- Run `/gbm` to see this overview again
- Proceed with `/gbm.request` to start your first feature

