#!/usr/bin/env bash
# Draw b-roll stills with Codex CLI (house rule: images go to Codex, not to ChatCut's image-gen).
# Usage: draw-broll.sh <prompt.txt> <out_dir> <expected1.png> [expected2.png ...]
#        draw-broll.sh --check-only <out_dir> <expected1.png> [...]   # only verify existing files
# Measured 25/09/2026: 3 images, files appear after ~1-1.5 min, codex exits after ~3 min.
# Run this BEFORE class. Drawing live on stage is too slow.
# This script is rung 2 of the fallback ladder (SKILL.md section 1.3); rung 1 is the Codex seat in the ChatGPT app.
set -uo pipefail

check_only=0
if [ "${1:-}" = "--check-only" ]; then check_only=1; shift; else prompt="${1:?prompt file}"; shift; fi
out="${1:?out dir}"; shift
[ "$#" -ge 1 ] || { echo "list the expected png names" >&2; exit 2; }
mkdir -p "$out"

if [ "$check_only" = "0" ]; then
  [ -r "$prompt" ] || { echo "cannot read prompt: $prompt" >&2; exit 2; }
  start=$(date +%s)
  # </dev/null is required: launched from a background task, codex prints
  # "Reading additional input from stdin..." and waits forever at 0% CPU (measured 25/09: stuck 8 min, no error).
  ( cd "$out" && codex exec --skip-git-repo-check --sandbox workspace-write -m gpt-6-astra "$(cat "$prompt")" </dev/null ) > "$out/codex-out.txt" 2>&1
  rc=$?
  echo "codex rc=$rc after $(( $(date +%s) - start ))s (log: $out/codex-out.txt)"
  # Read the TAIL: the head of the log is the prompt echoed back and can contain any word.
  if tail -40 "$out/codex-out.txt" | grep -qiE "usage limit|hit your usage"; then
    echo "FAIL codex usage limit reached. Next rung of the fallback ladder in SKILL.md section 1.3:"
    echo "     the Codex seat in the ChatGPT app (not hit by the CLI limit on 25/09), or Owner pastes the prompt into GPT."
    echo "     Do NOT fall back to another tool on the same OpenAI account: it is out of quota too."
  fi
fi

fail=0
for name in "$@"; do
  p="$out/$name"
  if [ ! -s "$p" ]; then echo "FAIL missing $name"; fail=1; continue; fi
  w=$(sips -g pixelWidth "$p" | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$p" | awk '/pixelHeight/{print $2}')
  if [ "$w" = "1080" ] && [ "$h" = "1920" ]; then echo "PASS $name ${w}x${h}"
  else echo "FAIL $name is ${w}x${h}, expected 1080x1920"; fail=1; fi
done
echo "Now LOOK at every image: no letters, no numbers, no logos. Codex sometimes bakes text in anyway."
[ "$fail" = "0" ] && echo "RESULT PASS" || echo "RESULT FAIL"
exit "$fail"
