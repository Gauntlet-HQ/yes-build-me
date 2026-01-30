# Qwen Code CLI Command Pack

This helper file is bundled with Qwen agent releases produced by the GoBuildMe packaging workflow. It explains how to run the TOML commands that land in `.qwen/commands/`.

## Usage

1. Install the Qwen Code CLI:
   ```bash
   pip install qwen-code
   ```
2. Authenticate with your Alibaba Cloud or Qwen account if prompted.
3. Run a command with:
   ```bash
   qwen run .qwen/commands/<command>.toml -- "<arguments>"
   ```
4. The arguments mirror GoBuildMe slash command usage; supply the same text you would feed to `/request`, `/specify`, etc.

### Personas
- GoBuildMe supports personas (project default and feature driver). See `AGENTS.md` for ask‑if‑missing prompts in `/constitution` and `/request`. When a persona is set, commands include persona-required sections and partials.

## Folder Structure

- `.qwen/commands/` — TOML command files for Qwen Code.
- `.gobuildme/templates/commands/` — Source markdown templates transformed during packaging.

Leave this file inside the distributed archive so teams have immediate instructions after extracting the Qwen bundle.
