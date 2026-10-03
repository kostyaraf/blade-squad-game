#!/bin/zsh
# usage: run_codex.sh <name> <prompt-file>
WT=/Users/hropl/pr/mypr/PB3-wt
exec codex exec -m gpt-6.1-sol -c model_reasoning_effort=high --dangerously-bypass-approvals-and-sandbox \
  -C $WT/$1 -o $WT/$1.last.md "$(cat $2)" < /dev/null > $WT/$1.log 2>&1
