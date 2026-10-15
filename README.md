# skills-hub
CLAUDE SKILLS

## Skills
- `model-orchestrator` - route tasks to Haiku / Sonnet / Opus (Opus needs confirmation)
- `registry-skills` - `/registry-skills` installs every skill in this repo
- `mkdocs-documentation` - add MkDocs pages, scaffold MkDocs, host docs (local / Docker / GitHub Pages)

## Install
First time (bootstrap):

```bash
git clone https://github.com/AJustiago/skills-hub.git
cd skills-hub
./scripts/install.sh            # all projects  -> ~/.claude/skills
./scripts/install.sh --project  # this project  -> ./.claude/skills
```

Restart Claude Code, then:

- `/registry-skills` - install/update all skills from this repo later
- `/model-orchestrator` - use the model router (also triggers automatically)

New skills: add `skills/<name>/SKILL.md`, push, then run `/registry-skills`.
