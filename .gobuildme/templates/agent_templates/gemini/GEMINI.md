# Gemini CLI Command Pack

This file accompanies Gemini agent releases created by the GoBuildMe CLI packaging script. It gives teams a quick refresher on how to use the generated TOML command files under `.gemini/commands/`.

## Usage

1. Install the Gemini CLI:
   ```bash
   pip install gemini-cli
   ```
2. Authenticate with your Google account as required by Gemini.
3. From the project root, execute commands with:
   ```bash
   gemini run .gemini/commands/<command>.toml -- "<arguments>"
   ```
4. Pass SDD workflow arguments exactly as they would be supplied to the standard GoBuildMe slash commands.

### Personas
- GoBuildMe supports personas (project default and feature driver). See `AGENTS.md` for ask‑if‑missing prompts in `/constitution` and `/request`. When a persona is set, commands include persona-required sections and partials.

## Folder Structure

- `.gemini/commands/` — TOML command files generated from GoBuildMe templates.
- `.gobuildme/templates/commands/` — Source markdown templates used during packaging (reference only).

Keep this file in packaged archives so users immediately know how to apply the Gemini commands.
