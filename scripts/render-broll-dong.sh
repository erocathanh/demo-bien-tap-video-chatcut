#!/usr/bin/env bash
# Turn one Codex still into a slow-moving b-roll clip with the Remotion composition BrollDong.
# Usage: render-broll-dong.sh <image.png> <frames> <zoom-in|zoom-out|pan-up> <out.mp4>
#   frames = length of the sentence on the ChatCut timeline (from find_transcript, e.g. 304f -> 395f = 91)
# Always renders with fadeFrames=0: a fade dips the first/last frames to ~30/255 brightness
# (measured 25/09 on the faded version), which flashes dark at the join inside ChatCut.
# Owner rule 25/09/2026 12:1x: still images are not used as b-roll any more, only moving clips.
set -euo pipefail

img="${1:?image.png}"; frames="${2:?frames}"; mode="${3:?zoom-in|zoom-out|pan-up}"; out="${4:?out.mp4}"
case "$mode" in zoom-in|zoom-out|pan-up) ;; *) echo "mode must be zoom-in, zoom-out or pan-up" >&2; exit 2;; esac
[ -r "$img" ] || { echo "cannot read image: $img" >&2; exit 2; }
# Remotion project: the mini-project bundled next to this script (override with REMOTION_PROJ=<folder>)
proj="${REMOTION_PROJ:-$(cd "$(dirname "$0")" && pwd)/remotion}"
[ -f "$proj/src/BrollDong.tsx" ] || { echo "composition missing: $proj/src/BrollDong.tsx" >&2; exit 3; }
[ -d "$proj/node_modules/remotion" ] || { echo "run once: cd \"$proj\" && npm install" >&2; exit 3; }
md5of() { if command -v md5 >/dev/null; then md5 -q "$1"; else md5sum "$1" | cut -d" " -f1; fi; }

img_abs=$(cd "$(dirname "$img")" && pwd)/$(basename "$img")
out_abs=$(mkdir -p "$(dirname "$out")" && cd "$(dirname "$out")" && pwd)/$(basename "$out")
props=$(mktemp -t broll-dong-props.XXXXXX)
printf '{"src":"%s","durationInFrames":%d,"mode":"%s","fadeFrames":0}\n' "$(basename "$img")" "$frames" "$mode" > "$props"

start=$(date +%s)
# --public-dir points at the image folder so staticFile(src) resolves without copying into public/.
( cd "$proj" && npx remotion render src/index.ts BrollDong "$out_abs" --props="$props" --public-dir="$(dirname "$img_abs")" --bundle-cache=false --log=error )
echo "rendered $(basename "$out") in $(( $(date +%s) - start ))s"

n=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of csv=p=0 "$out_abs" | tr -d ,)
w=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$out_abs" | tr -d ,)
h=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$out_abs" | tr -d ,)
yavg() { ffmpeg -hide_banner -i "$out_abs" -vf "select=eq(n\,$1),signalstats,metadata=print:key=lavfi.signalstats.YAVG" -an -f null - 2>&1 | grep -o "YAVG=[0-9.]*" | head -1 | cut -d= -f2; }
first=$(yavg 0); mid=$(yavg $((n/2))); last=$(yavg $((n-1)))
echo "frames $n (asked $frames) · ${w}x${h} · brightness first $first · mid $mid · last $last · md5 $(md5of "$out_abs")"
fail=0
[ "$n" = "$frames" ] || { echo "FAIL frame count"; fail=1; }
[ "$w" = "1080" ] && [ "$h" = "1920" ] || { echo "FAIL size"; fail=1; }
# Edge frames must not be much darker than the middle: that is the fade flash.
awk -v a="$first" -v b="$last" -v m="$mid" 'BEGIN{exit !((a < m*0.7) || (b < m*0.7))}' && { echo "FAIL dark edge frame (fade left on?)"; fail=1; }
rm -f "$props"
[ "$fail" = "0" ] && echo "RESULT PASS" || echo "RESULT FAIL"
exit "$fail"
