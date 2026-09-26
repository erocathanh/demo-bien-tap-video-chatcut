#!/usr/bin/env bash
# Verify a ChatCut export against expectations, using local tools only.
# Usage: verify-export.sh <export.mp4> [expected_md5] [removed_phrase] [kept_phrase]
#   kept_phrase    optional positive control: text that MUST still be heard; if Whisper misses it,
#                  the removed-phrase check is not trustworthy (the ruler is broken, not the edit)
#   expected_md5   optional: compare byte-for-byte with a known-good render
#   removed_phrase optional: text that must NOT be heard any more (checked with local Whisper)
# Writes a contact sheet next to the file: <name>-contact.png
# Exit code 0 = all checks passed, 1 = at least one check failed.
set -uo pipefail

f="${1:?usage: verify-export.sh <export.mp4> [expected_md5] [removed_phrase]}"
want_md5="${2:-}"
removed="${3:-}"
kept="${4:-}"
fail=0

[ -s "$f" ] || { echo "FAIL file missing or empty: $f"; exit 1; }

md5v=$(if command -v md5 >/dev/null; then md5 -q "$f"; else md5sum "$f" | cut -d" " -f1; fi)
echo "md5        $md5v"
if [ -n "$want_md5" ]; then
  case "$md5v" in
    "$want_md5"*) echo "PASS md5 matches known-good render" ;;
    *) echo "INFO md5 differs from $want_md5 (expected if the edit changed)";;
  esac
fi

w=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$f")
h=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$f")
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
acodec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$f")
echo "size       ${w}x${h} · ${dur}s · audio=${acodec:-NONE}"
if [ "$w" = "1080" ] && [ "$h" = "1920" ]; then echo "PASS vertical 1080x1920"; else echo "FAIL not 1080x1920"; fail=1; fi
if [ -n "$acodec" ]; then echo "PASS has audio"; else echo "FAIL no audio stream"; fail=1; fi

# A 1-second export once reported success in another tool: never trust "done", check length.
if awk -v d="$dur" 'BEGIN{exit !(d < 3)}'; then echo "FAIL duration under 3s"; fail=1; fi

blacks=$(ffmpeg -v info -i "$f" -vf "blackdetect=d=0.03:pix_th=0.1" -an -f null - 2>&1 | grep -c black_start || true)
if [ "$blacks" = "0" ]; then echo "PASS no black frames"; else echo "FAIL $blacks black segment(s)"; fail=1; fi

mean=$(ffmpeg -hide_banner -i "$f" -af volumedetect -f null - 2>&1 | awk '/mean_volume/{print $5}')
echo "loudness   mean ${mean} dB"
if awk -v m="${mean:--99}" 'BEGIN{exit !(m < -40)}'; then echo "FAIL audio nearly silent"; fail=1; fi

# Contact sheet: first frame, 8 evenly spaced frames, last frame. Edges are where cuts break.
base="${f%.*}"
tmp=$(mktemp -d)
i=0
# Use the VIDEO stream length: audio often runs a few ms longer, and seeking past the last frame yields nothing.
vdur=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of csv=p=0 "$f")
for p in 0.00 0.11 0.22 0.33 0.44 0.55 0.66 0.77 0.88 LAST; do
  if [ "$p" = "LAST" ]; then t=$(awk -v d="$vdur" 'BEGIN{printf "%.3f", d-0.1}')
  else t=$(awk -v d="$vdur" -v p="$p" 'BEGIN{printf "%.3f", d*p}'); fi
  ffmpeg -v error -y -ss "$t" -i "$f" -frames:v 1 -vf scale=144:-1 "$tmp/$i.png"
  i=$((i+1))
done
inputs=""; for j in $(seq 0 9); do inputs="$inputs -i $tmp/$j.png"; done
# shellcheck disable=SC2086
ffmpeg -v error -y $inputs -filter_complex hstack=10 "${base}-contact.png" && echo "sheet      ${base}-contact.png (look at it: edges + b-roll placement)"
rm -rf "$tmp"

if [ -n "$removed" ]; then
  if command -v whisper >/dev/null; then
    wd=$(mktemp -d)
    whisper "$f" --model small --language vi --output_format txt --output_dir "$wd" >/dev/null 2>&1
    txt=$(cat "$wd"/*.txt 2>/dev/null)
    rm -rf "$wd"
    norm() { tr '[:upper:]' '[:lower:]' | tr -d '.,?!'; }
    if [ -z "$txt" ]; then echo "FAIL whisper produced no text"; fail=1
    elif printf '%s' "$txt" | norm | grep -qF "$(printf '%s' "$removed" | norm)"; then
      echo "FAIL removed phrase still audible: $removed"; fail=1
    else
      echo "PASS removed phrase not heard (whisper small; it mishears some words, read the text below)"
    fi
    if [ -n "$kept" ]; then
      if printf '%s' "$txt" | norm | grep -qF "$(printf '%s' "$kept" | norm)"; then
        echo "PASS positive control heard: $kept"
      else
        echo "FAIL positive control NOT heard: $kept (whisper ruler unreliable here, check by ear)"; fail=1
      fi
    fi
    printf '%s\n' "$txt" | sed 's/^/  heard: /'
  else
    echo "SKIP whisper not installed; removed-phrase check not run"
  fi
fi

[ "$fail" = "0" ] && echo "RESULT PASS" || echo "RESULT FAIL"
exit "$fail"
