#!/usr/bin/env bash
# Put the sidekick block into an agent's system prompt file, or take it out. Safe to run twice: the block is replaced, never doubled.
#   apply.sh <prompt-file>             add or refresh the block (shows the diff, keeps a timestamped backup)
#   apply.sh <prompt-file> --remove    take the block out again
#   apply.sh <prompt-file> --dry-run   show the diff only, write nothing
# Works on any text file an agent reads as its system prompt: CLAUDE.md, AGENTS.md, .claude/agents/*.md, a prompt.txt.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
BLOCK="$HERE/core-prompt.md"
START='<!-- sidekick:start -->'
END='<!-- sidekick:end -->'

f=${1:?usage: apply.sh <prompt-file> [--remove] [--dry-run]}; shift
remove=0; dry=0
for a in "$@"; do
  case $a in --remove) remove=1 ;; --dry-run) dry=1 ;; *) echo "apply.sh: unknown option $a" >&2; exit 2 ;; esac
done
[ -f "$f" ] || { echo "apply.sh: no such file: $f" >&2; exit 1; }
[ -s "$BLOCK" ] || { echo "apply.sh: missing $BLOCK" >&2; exit 1; }

tmp=$(mktemp)
# Everything except an existing block, with trailing blank lines dropped.
awk -v s="$START" -v e="$END" '$0==s{skip=1} !skip{print} $0==e{skip=0}' "$f" | awk 'NF{for(i=0;i<b;i++)print ""; b=0; print; next}{b++}' > "$tmp"
if [ "$remove" = 0 ]; then
  { cat "$tmp"; [ -s "$tmp" ] && printf '\n'; cat "$BLOCK"; } > "$tmp.new"
  mv "$tmp.new" "$tmp"
fi

if cmp -s "$f" "$tmp"; then echo "no change"; rm -f "$tmp"; exit 0; fi
diff -u "$f" "$tmp" || true
if [ "$dry" = 1 ]; then rm -f "$tmp"; echo "(dry run: nothing written)"; exit 0; fi
cp -p "$f" "$f.bak-$(date +%Y%m%d%H%M%S)"
cat "$tmp" > "$f"
rm -f "$tmp"
echo "updated $f (backup kept next to it)"
