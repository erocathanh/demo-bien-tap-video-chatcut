#!/usr/bin/env bash
# render.sh — render the sample clips of the skill with the bundled Remotion mini-project.
# Usage (from anywhere):  bash scripts/remotion/render.sh [broll|stage|stage-chatcut|story|all] [out_dir]
#   broll  3 moving b-roll clips from the 3 PNGs (BrollDong, no fade)        ~10 s each   (default: install check)
#   stage  video 2 "3 levels of AI" (IconStage, one stage per sentence)       ~30-70 s, 66.5 s long, 1996 frames
#   stage-chatcut  same video WITHOUT captions, for ChatCut to caption     ~30-70 s, 1996 frames -> out/video-2-khong-phu-de.mp4
#   story  day-1 film icon overlay (IconStory, icons that follow the words)   ~40 s, 36 s long, no audio
# Needs: node >= 18, `npm ci` done once in this folder, ffprobe for the check.
# Works with macOS /bin/bash 3.2 and Windows Git Bash (tools there print CRLF, so every reading strips \r).
# One render at a time: two renders at once in the same folder can corrupt the webpack cache.
# --timeout=120000: a busy or slow machine once hit Remotion's default 28 s delayRender limit on the first stage render.
# The check covers size, frame count and (stage, stage-chatcut) an audio stream. It cannot see whether captions are
# drawn: open the frames to confirm stage-chatcut has none.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WHAT="${1:-broll}"
OUT="${2:-$HERE/out}"
mkdir -p "$OUT"
cd "$HERE"
# A half-finished install (npm cut off by a timeout) leaves node_modules/remotion but no CLI entry point.
if [ ! -d node_modules/remotion ] || [ ! -e node_modules/.bin/remotion ] || [ ! -e node_modules/.package-lock.json ]; then
  echo "FAIL chưa cài xong bộ dựng video. Chạy:  cd \"$HERE\" && npm ci   (một lần, 1–3 phút)"
  exit 3
fi
command -v ffprobe >/dev/null 2>&1 || { echo "FAIL thiếu ffprobe (đi kèm FFmpeg) để kiểm video ra"; exit 3; }

fail=0
check() {  # $1 file  $2 expected frames (0 = skip)  $3 "audio" = must have an audio stream
  local f="$1" want="$2" need_audio="${3:-}"
  if [ ! -s "$f" ]; then echo "FAIL $f not written"; fail=1; return; fi
  local wh fr
  wh=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of default=nw=1:nk=1 "$f" | tr -d '\r' | paste -sd x -)
  fr=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nw=1:nk=1 "$f" | tr -d ',\r')
  if [ "$wh" != "1080x1920" ]; then echo "FAIL $f size $wh"; fail=1; return; fi
  if [ "$want" != 0 ] && [ "$fr" != "$want" ]; then echo "FAIL $f frames $fr != $want"; fail=1; return; fi
  local au=""
  if [ "$need_audio" = audio ]; then
    au=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$f" | tr -d '\r')
    if [ -z "$au" ]; then echo "FAIL $f has no audio stream"; fail=1; return; fi
    au=" audio=$au"
  fi
  echo "PASS $(basename "$f") 1080x1920 frames=$fr$au"
}
render() {  # $1 composition  $2 props  $3 out  $4 expected frames  $5 "audio" to require an audio stream
  local t0
  t0=$(date +%s)
  rm -f "$3"  # never let a stale output from an earlier run pass the check
  if ! npx remotion render src/index.ts "$1" "$3" --props="$2" --public-dir=public --bundle-cache=false --timeout=120000 --log=error; then
    echo "FAIL render $1 (Remotion exited with an error; see the lines above)"
    fail=1
    return
  fi
  echo "render $1 $(( $(date +%s) - t0 ))s"
  check "$3" "$4" "${5:-}"
}
case "$WHAT" in broll|stage|stage-chatcut|story|all) ;; *) echo "usage: render.sh [broll|stage|stage-chatcut|story|all] [out_dir]"; exit 2 ;; esac
if [ "$WHAT" = broll ] || [ "$WHAT" = all ]; then
  render BrollDong props/broll-1.json "$OUT/broll-1-dong.mp4" 91
  render BrollDong props/broll-2.json "$OUT/broll-2-dong.mp4" 81
  render BrollDong props/broll-3.json "$OUT/broll-3-dong.mp4" 70
fi
if [ "$WHAT" = stage ] || [ "$WHAT" = all ]; then
  render IconStage props/iconstage-video-2.json "$OUT/video-2-ba-cap-do-ai.mp4" 1996 audio
fi
if [ "$WHAT" = stage-chatcut ] || [ "$WHAT" = all ]; then
  render IconStage props/iconstage-video-2-khong-phu-de.json "$OUT/video-2-khong-phu-de.mp4" 1996 audio
fi
if [ "$WHAT" = story ] || [ "$WHAT" = all ]; then
  render IconStory props/iconstory-phim-buoi-1.json "$OUT/icon-story-phim-buoi-1.mp4" 1091
fi
[ "$fail" = 0 ] && echo "RESULT PASS" || echo "RESULT FAIL"
exit "$fail"
