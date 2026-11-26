# Sidekick

A system-prompt block that keeps an AI agent on its mission. The agent does what was asked and nothing more, asks one question when a request is unclear, proves its work before it says "done", and reports in a few lines.

It ships as a Claude Code skill, and a small script adds the same block to any agent whose system prompt is a text file (`CLAUDE.md`, `AGENTS.md`, `.claude/agents/*.md`, a `prompt.txt`).

## What it does to an agent

Every message goes through one protocol:

1. **Classify.** Task, question, standing rule or feedback, or unclear. A rule ("from now on...") gets one line, "Understood: ...", and no work.
2. **Contract.** Goal, done-when, what it may touch, what is off-limits.
3. **Clarity gate.** If two competent people would build different things and it cannot look the answer up, it asks one question with a default, then stops.
4. **Authority.** Commit, push, deploy, delete, send and spend need your explicit words for that action. It never routes around a guard or a permission.
5. **Execute.** The smallest change that reaches done-when. Anything else it notices becomes one "Noticed:" line, never an action.
6. **Prove.** Nothing counts as done until it was run, tested or read back. What was not verified is named.
7. **Report.** A fixed format, with length limits:

```
Done: <the result, one line>
Proof: <the evidence, one line>
Needs you: <a decision or action, or "nothing">
```

It also carries short playbooks for four roles: developer and engineer, researcher, business operator, and debugging. The full text is in [`core-prompt.md`](core-prompt.md).

## Install

**Claude Code**

```bash
git clone https://github.com/Xer0bit/sidekick ~/.claude/skills/sidekick
```

Then type `/sidekick` in Claude Code to load the mode for a session.

**Any other agent**

```bash
git clone https://github.com/Xer0bit/sidekick
cd sidekick
./apply.sh /path/to/your/agent-prompt.md
```

`./install.sh` copies the files to `~/.claude/skills/sidekick` if you prefer not to clone there.

## Use

```bash
./apply.sh <prompt-file> --dry-run   # show the diff, write nothing
./apply.sh <prompt-file>             # add or refresh the block
./apply.sh <prompt-file> --remove    # take it out again
```

The block is written between `<!-- sidekick:start -->` and `<!-- sidekick:end -->`. Running the script twice replaces the block, never doubles it. Your own prompt text outside the markers is never touched, and a timestamped backup is kept next to the file.

A system prompt stored in a service or an API cannot be edited by a script. Paste the contents of `core-prompt.md` into it yourself.

## Tested

[`evals/scenarios.md`](evals/scenarios.md) holds nine scenarios: a vague request, a standing rule, a typo fix next to an unrelated bug, a version bump in a git repo, a vague cleanup, a research question, a failing test, a plain question and a business decision. They were run on fresh agents, and the project folders were checked for side effects (changed files, new files, commits). Three scenarios failed on length at first. Hard length budgets fixed them, and they were re-tested on new questions.

Known gaps: the agent sometimes packs two asks into one clarifying question, and a business answer can run a line or a number over its budget.

This is guidance in a prompt, not an enforcement layer. It makes an agent behave better. It does not replace permissions, hooks or review.

## Change it

Edit `core-prompt.md`, run the scenarios on fresh agents, and fix what fails. Re-test with new wording of the same kind of question, because the prompt's own examples get copied.

## Uninstall

```bash
./apply.sh <prompt-file> --remove
rm -rf ~/.claude/skills/sidekick
```

## License

MIT. See [`LICENSE`](LICENSE).
