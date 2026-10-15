#!/usr/bin/env bash
# Install every skill in this repo (skills/*/SKILL.md) into Claude Code.
# Usage: scripts/install.sh [--project] [--dest DIR] [--dry-run]
#   default : ~/.claude/skills   (available in all projects)
#   --project: ./.claude/skills  (this project only)
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="${HOME}/.claude/skills"
dry=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) dest="$PWD/.claude/skills" ;;
    --dest) dest="$2"; shift ;;
    --dry-run) dry=1 ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

count=0
for dir in "$root"/skills/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  name="$(basename "$dir")"
  if [ "$dry" = 1 ]; then
    echo "would install $name -> $dest/$name"
  else
    mkdir -p "$dest"
    rm -rf "${dest:?}/$name"
    cp -R "${dir%/}" "$dest/$name"
    echo "installed $name -> $dest/$name"
  fi
  count=$((count + 1))
done
echo "$count skill(s) processed. Restart Claude Code (or start a new session) to load them."
