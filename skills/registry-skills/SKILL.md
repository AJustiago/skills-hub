---
name: registry-skills
description: Install or update every skill from the skills-hub repo (AJustiago/skills-hub) into Claude Code in one step. Use when the user runs /registry-skills or asks to install, sync, or update all skills from the repo.
disable-model-invocation: true
---

# Registry Skills

Install all skills from the skills-hub repo into Claude Code.

## Arguments
- (none): install globally to `~/.claude/skills`
- `project`: install to `./.claude/skills` (this project only)
- `repo=<owner/name>`: use another repo (default `AJustiago/skills-hub`)

## Steps
1. If the current working directory already contains `scripts/install.sh` and `skills/`, use it as the source. Otherwise clone into a fresh empty temp directory:
   `git clone --depth 1 https://github.com/<repo>.git <tmpdir>/skills-hub`
2. Preview: `bash <src>/scripts/install.sh --dry-run [--project]`
3. Install: `bash <src>/scripts/install.sh [--project]`
   Existing skills with the same name are overwritten (updated).
4. Report the list of installed skills and the destination, and tell the user to start a new session or restart Claude Code so the skills load.

## Rules
- Only copy directories under `skills/` that contain a `SKILL.md`.
- Do not run any other script from the cloned repo.
- If the clone fails (private repo / no network), tell the user and suggest running `scripts/install.sh` manually after cloning.
