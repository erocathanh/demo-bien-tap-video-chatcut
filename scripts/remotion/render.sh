#!/usr/bin/env bash
# render.sh — render the sample clips of the skill with the bundled Remotion mini-project.
# Usage (from anywhere):  bash scripts/remotion/render.sh [broll|stage|story|all] [out_dir]
#   broll  3 moving b-roll clips from the 3 PNGs (BrollDong, no fade)        ~10 s each   (default: install check)
#   stage  video 2 "3 levels of AI" (IconStage, one stage per sentence)       ~35 s, 65 s long
#   story  day-1 film icon overlay (IconStory, icons that follow the words)   ~40 s, 36 s long, no audio
# Needs: node >= 18, `npm install` done once in this folder, ffprobe for the check.
# One render at a time: two renders at once in the same folder can corrupt the webpack cache.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WHAT="${1:-broll}"
OUT="${2:-$HERE/out}"
mkdir -p "$OUT"
cd "$HERE"
[ -d node_modules/remotion ] || { echo "FAIL node_modules missing: run  cd \"$HERE\" && npm install"; exit 3; }

fail=0
check() {  # $1 file  $2 expected frames (0 = skip)
  local f="$1" want="$2"
  if [ ! -s "$f" ]; then echo "FAIL $f not written"; fail=1; return; fi
  local wh fr
  wh=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$f" | tr -d ',\n' | sed 's/^\(1080\)/\1x/')
  fr=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of csv=p=0 "$f" | tr -d ',')
  if [ "$wh" != "1080x1920" ]; then echo "FAIL $f size $wh"; fail=1; return; fi
  if [ "$want" != 0 ] && [ "$fr" != "$want" ]; then echo "FAIL $f frames $fr != $want"; fail=1; return; fi
  echo "PASS $(basename "$f") 1080x1920 frames=$fr"
}
render() {  # $1 composition  $2 props  $3 out  $4 expected frames
  local t0=$(date +%s)
  npx remotion render src/index.ts "$1" "$3" --props="$2" --public-dir=public --bundle-cache=false --log=error
  echo "render $1 $(( $(date +%s) - t0 ))s"
  check "$3" "$4"
}
case "$WHAT" in broll|stage|story|all) ;; *) echo "usage: render.sh [broll|stage|story|all] [out_dir]"; exit 2 ;; esac
if [ "$WHAT" = broll ] || [ "$WHAT" = all ]; then
  render BrollDong props/broll-1.json "$OUT/broll-1-dong.mp4" 91
  render BrollDong props/broll-2.json "$OUT/broll-2-dong.mp4" 81
  render BrollDong props/broll-3.json "$OUT/broll-3-dong.mp4" 70
fi
if [ "$WHAT" = stage ] || [ "$WHAT" = all ]; then
  render IconStage props/iconstage-video-2.json "$OUT/video-2-ba-cap-do-ai.mp4" 0
fi
if [ "$WHAT" = story ] || [ "$WHAT" = all ]; then
  render IconStory props/iconstory-phim-buoi-1.json "$OUT/icon-story-phim-buoi-1.mp4" 1091
fi
[ "$fail" = 0 ] && echo "RESULT PASS" || echo "RESULT FAIL"
exit "$fail"
