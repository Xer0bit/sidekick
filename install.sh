#!/usr/bin/env bash
# Install the skill for Claude Code: copies this folder's files to ~/.claude/skills/sidekick (override with CLAUDE_SKILLS_DIR).
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/sidekick"
mkdir -p "$DEST"
cp "$HERE/SKILL.md" "$HERE/core-prompt.md" "$HERE/apply.sh" "$DEST/"
chmod +x "$DEST/apply.sh"
echo "installed: $DEST"
echo "use: /sidekick    or    $DEST/apply.sh <agent-prompt-file>"
