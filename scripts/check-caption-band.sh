#!/usr/bin/env bash
# Check that an overlay never intrudes into the ChatCut caption band during a time window.
# Usage: check-caption-band.sh <export.mp4> <from_s> <to_s> [band_top] [band_height] [positive_control.mp4]
#   band_top/height: read them from read_captions (layout top=… height=…); default 1414 / 84 (Plain preset, 1080x1920)
#   positive_control.mp4: a render KNOWN to intrude in the same window. If the ruler cannot see that intrusion,
#   it is blind and its PASS on the real file means nothing.
# Method: mean brightness of the band, sampled every frame by timestamp (-ss). Captions alone give a flat line;
# a card sliding through lifts it. FAIL if any sample rises more than THRESH above the window's first sample.
# Measured 25-26/09: v7b intruded (43 -> 74.6), v7c touched (43 -> 46.4), v7d flat (43.2-43.4).
set -uo pipefail

f="${1:?export.mp4}"; from="${2:?from seconds}"; to="${3:?to seconds}"
top="${4:-1414}"; h="${5:-84}"; ctrl="${6:-}"
THRESH=1.5

band() {
  ffmpeg -hide_banner -ss "$2" -i "$1" -vf "crop=1080:${h}:0:${top},signalstats,metadata=print:key=lavfi.signalstats.YAVG" \
    -frames:v 1 -an -f null - 2>&1 | grep -o "YAVG=[0-9.]*" | head -1 | cut -d= -f2
}

scan() { # prints "maxrise at_t"
  local file="$1" base="" max=0 at="" t
  t="$from"
  while awk -v a="$t" -v b="$to" 'BEGIN{exit !(a <= b)}'; do
    v=$(band "$file" "$t")
    [ -z "$v" ] && { echo "ERR no frame at $t"; return 1; }
    [ -z "$base" ] && base="$v"
    rise=$(awk -v v="$v" -v b="$base" 'BEGIN{printf "%.2f", v-b}')
    if awk -v r="$rise" -v m="$max" 'BEGIN{exit !(r > m)}'; then max="$rise"; at="$t"; fi
    t=$(awk -v t="$t" 'BEGIN{printf "%.3f", t+1/30}')
  done
  echo "$max ${at:-none} base=$base"
}

n=$(awk -v a="$from" -v b="$to" 'BEGIN{printf "%d", (b-a)*30+1}')
echo "đo $n khung (mỗi khung một lần gọi ffmpeg) — trên Mac vài giây; trên Windows mỗi lần gọi khởi động chậm hơn, có thể mất vài phút (chưa đo)"

fail=0
if [ -n "$ctrl" ]; then
  read -r cmax cat cbase <<<"$(scan "$ctrl")"
  echo "control   max rise $cmax at ${cat}s ($cbase)"
  if awk -v r="$cmax" -v th="$THRESH" 'BEGIN{exit !(r <= th)}'; then
    echo "FAIL positive control shows no intrusion: ruler is blind for this window/band"; fail=1
  else
    echo "PASS positive control intrusion detected"
  fi
fi
read -r max at base <<<"$(scan "$f")"
echo "file      max rise $max at ${at}s ($base)"
if awk -v r="$max" -v th="$THRESH" 'BEGIN{exit !(r > th)}'; then
  echo "FAIL overlay intrudes into caption band (rise $max > $THRESH at ${at}s)"; fail=1
else
  echo "PASS caption band stays flat (rise <= $THRESH)"
fi
[ "$fail" = "0" ] && echo "RESULT PASS" || echo "RESULT FAIL"
exit "$fail"
