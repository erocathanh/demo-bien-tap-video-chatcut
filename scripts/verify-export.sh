#!/usr/bin/env bash
# Verify a ChatCut export against expectations, using local tools only.
# Usage: verify-export.sh <export.mp4> [expected_md5] [removed_phrase] [kept_phrase]
#   kept_phrase    optional positive control: text that MUST still be heard; if Whisper misses it,
#                  the removed-phrase check is not trustworthy (the ruler is broken, not the edit)
#   expected_md5   optional: compare byte-for-byte with a known-good render
#   removed_phrase optional: text that must NOT be heard any more (checked with local Whisper)
# Writes a contact sheet <name>-contact.png next to the file, or into <skill>/out/ when the file sits inside
# the skill's assets/ (so running the README checks never overwrites a tracked file).
# Exit code 0 = all checks passed, 1 = at least one check failed.
# Works with macOS /bin/bash 3.2 and Windows Git Bash (tools there print CRLF, so every reading strips \r).
set -uo pipefail
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export PYTHONUTF8=1  # Windows: without it whisper cannot write Vietnamese text and exits 0 with no file

f="${1:?usage: verify-export.sh <export.mp4> [expected_md5] [removed_phrase]}"
want_md5="${2:-}"
removed="${3:-}"
kept="${4:-}"
fail=0

[ -s "$f" ] || { echo "FAIL file missing or empty: $f"; exit 1; }
for tool in ffprobe ffmpeg; do
  command -v "$tool" >/dev/null 2>&1 || { echo "FAIL thiếu $tool (bộ FFmpeg) — chưa kiểm được video. Cài FFmpeg rồi chạy lại."; exit 1; }
done
probe() {  # $1 stream selector ("" for container)  $2 entry  -> one value, no CR, no trailing comma
  if [ -n "$1" ]; then ffprobe -v error -select_streams "$1" -show_entries "$2" -of default=nw=1:nk=1 "$f"
  else ffprobe -v error -show_entries "$2" -of default=nw=1:nk=1 "$f"; fi | tr -d '\r' | head -1
}

md5v=$(if command -v md5 >/dev/null; then md5 -q "$f"; else md5sum "$f" | cut -d" " -f1; fi)
echo "md5        $md5v"
if [ -n "$want_md5" ]; then
  case "$md5v" in
    "$want_md5"*) echo "PASS md5 matches known-good render" ;;
    *) echo "INFO md5 differs from $want_md5 (expected if the edit changed)";;
  esac
fi

w=$(probe v:0 stream=width)
h=$(probe v:0 stream=height)
dur=$(probe "" format=duration)
acodec=$(probe a:0 stream=codec_name)
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
fabs="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
case "$fabs" in
  "$SKILL_DIR"/assets/*) sheet_dir="$SKILL_DIR/out" ;;
  *) sheet_dir="$(dirname "$fabs")" ;;
esac
mkdir -p "$sheet_dir"
name="$(basename "$f")"
sheet="$sheet_dir/${name%.*}-contact.png"
tmp=$(mktemp -d)
i=0
# Use the VIDEO stream length: audio often runs a few ms longer, and seeking past the last frame yields nothing.
vdur=$(probe v:0 stream=duration)
for p in 0.00 0.11 0.22 0.33 0.44 0.55 0.66 0.77 0.88 LAST; do
  if [ "$p" = "LAST" ]; then t=$(awk -v d="$vdur" 'BEGIN{printf "%.3f", d-0.1}')
  else t=$(awk -v d="$vdur" -v p="$p" 'BEGIN{printf "%.3f", d*p}'); fi
  ffmpeg -v error -y -ss "$t" -i "$f" -frames:v 1 -vf scale=144:-1 "$tmp/$i.png"
  i=$((i+1))
done
inputs=(); for j in 0 1 2 3 4 5 6 7 8 9; do inputs+=(-i "$tmp/$j.png"); done
ffmpeg -v error -y "${inputs[@]}" -filter_complex hstack=10 "$sheet" && echo "sheet      $sheet (look at it: edges + b-roll placement)"
rm -rf "$tmp"

# Normalise text before comparing: lowercase (Vietnamese capitals too — GNU tr only lowers ASCII), punctuation and
# newlines to spaces, and digits 0-10 to Vietnamese words on BOTH sides, because whisper writes «buổi hai» as «buổi 2».
# -Mutf8 is required: without it the non-ASCII number words (một, bốn, năm…) never match.
norm() { perl -Mutf8 -CSD -0777 -pe '$_=lc; tr/\r\n.,?!:;"/ /; s/\b10\b/mười/g; s/\b0\b/không/g; s/\b1\b/một/g; s/\b2\b/hai/g; s/\b3\b/ba/g; s/\b4\b/bốn/g; s/\b5\b/năm/g; s/\b6\b/sáu/g; s/\b7\b/bảy/g; s/\b8\b/tám/g; s/\b9\b/chín/g; s/\s+/ /g; s/^ | $//g'; }
if [ "$(printf 'Ở buổi 1,' | norm)" != "$(printf 'ở buổi một' | norm)" ] || [ "$(printf 'Buổi 2.' | norm)" != "buổi hai" ]; then
  echo "FAIL text normaliser self-test (perl -Mutf8) — the removed-phrase check cannot be trusted on this machine"; fail=1
fi

if [ -n "$removed" ]; then
  if command -v whisper >/dev/null; then
    wd=$(mktemp -d)
    wlog="$sheet_dir/${name%.*}-whisper.log"
    if [ ! -f "$HOME/.cache/whisper/small.pt" ]; then
      echo "INFO lần đầu: Whisper tải mô hình «small» khoảng 480 MB — có thể mất vài phút, không phải bị treo"
    fi
    whisper "$f" --model small --language vi --output_format txt --output_dir "$wd" >"$wlog" 2>&1
    wrc=$?
    txt=$(cat "$wd"/*.txt 2>/dev/null | tr -d '\r')
    rm -rf "$wd"
    if [ -z "$txt" ]; then
      echo "FAIL whisper produced no text (exit $wrc) — last lines of $wlog:"; tail -5 "$wlog" | sed 's/^/  /'; fail=1
    elif printf '%s' "$txt" | norm | grep -qF "$(printf '%s' "$removed" | norm)"; then
      echo "FAIL removed phrase still audible: $removed"; fail=1
    else
      echo "PASS removed phrase not heard (whisper small; it mishears some words, read the text below)"
    fi
    if [ -n "$txt" ] && [ -n "$kept" ]; then
      if printf '%s' "$txt" | norm | grep -qF "$(printf '%s' "$kept" | norm)"; then
        echo "PASS positive control heard: $kept"
      else
        echo "FAIL positive control NOT heard: $kept (whisper ruler unreliable here, check by ear)"; fail=1
      fi
    fi
    printf '%s\n' "$txt" | sed 's/^/  heard: /'
  else
    echo "SKIP whisper not installed; removed-phrase check not run"
    speech_skipped=1
  fi
fi

if [ "$fail" != "0" ]; then echo "RESULT FAIL"
elif [ "${speech_skipped:-0}" = "1" ]; then echo "RESULT PASS (speech not checked: whisper missing)"
else echo "RESULT PASS"; fi
exit "$fail"
