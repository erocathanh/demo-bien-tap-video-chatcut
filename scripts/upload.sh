#!/usr/bin/env bash
# Upload up to 4 local media files into a ChatCut project via the plugin's upload helper.
# Usage: upload.sh <token> <endpoint> <file1> [file2 file3 file4]
#   token/endpoint come from MCP: import_media {action:"create_session", projectId}
# Prints one line per file: "<assetId> <filename>", plus elapsed seconds on stderr.
# The token is short-lived (30 min) and is never written to disk by this script.
# Needs only node (the helper itself is a node script). Works with macOS /bin/bash 3.2 and Windows Git Bash.
# Exit: 0 ok · 3 missing node/plugin · 4 unreadable file · 5 upload failed · 6 Windows plugin bug P5, user must relink (steps printed)
set -euo pipefail

if [ "$#" -lt 3 ] || [ "$#" -gt 6 ]; then
  echo "usage: upload.sh <token> <endpoint> <file1> [up to 4 files]" >&2
  exit 2
fi
token="$1"; endpoint="$2"; shift 2

os="$(uname -s)"
case "$os" in
  Darwin) plat="darwin" ;;
  MINGW*|MSYS*|CYGWIN*) plat="win32" ;;
  *) plat="linux" ;;
esac
case "$(uname -m)" in
  arm64|aarch64) arch="arm64" ;;
  *) arch="x64" ;;
esac

if ! command -v node >/dev/null 2>&1; then
  echo "Thiếu Node.js — công cụ tải phim của ChatCut chạy bằng Node.js." >&2
  case "$plat" in
    darwin) echo "  Cài:  brew install node" >&2 ;;
    win32)  echo "  Cài:  winget install -e --id OpenJS.NodeJS.LTS   (cài xong thoát hẳn Claude rồi mở lại)" >&2 ;;
    *)      echo "  Cài Node.js 18+ bằng trình quản lý gói của máy" >&2 ;;
  esac
  exit 3
fi

helper=$(ls -d "$HOME"/.claude/plugins/cache/chatcut-inc/chatcut/*/skills/asset-import/scripts/upload-media.mjs 2>/dev/null | sort -V | tail -1 || true)
if [ -z "$helper" ]; then
  echo "Không thấy công cụ tải phim của plugin ChatCut (upload-media.mjs). Plugin ChatCut đã cài chưa?" >&2
  exit 3
fi

# The helper ships its own ffmpeg for darwin-arm64 and win32-x64 only. Warn (do not stop) when it may be missing.
if ! command -v ffmpeg >/dev/null 2>&1; then
  bundle="$(dirname "$helper")/ffmpeg"
  if [ "$plat" = "win32" ] && [ ! -d "$bundle" ]; then
    echo "CẢNH BÁO: máy chưa có FFmpeg và bản FFmpeg đi kèm plugin bị hỏng trên Windows (lỗi plugin P1)." >&2
    echo "  Cài:  winget install -e --id Gyan.FFmpeg   rồi thoát hẳn Claude và mở lại" >&2
  elif [ "$plat-$arch" != "darwin-arm64" ] && [ "$plat-$arch" != "win32-x64" ]; then
    echo "CẢNH BÁO: máy chưa có FFmpeg và plugin không kèm FFmpeg cho máy này ($plat-$arch). Nên cài FFmpeg trước." >&2
  fi
fi

for f in "$@"; do
  [ -r "$f" ] || { echo "Không đọc được tệp: $f" >&2; exit 4; }
done

out=$(mktemp -t chatcut-upload.XXXXXX)
err=$(mktemp -t chatcut-upload-err.XXXXXX)
trap 'rm -f "$out" "$err"' EXIT

# Reads the helper's JSON (from a file) and prints "<assetId> <filename>" per import; strips a leading BOM.
parse_imports='const fs=require("fs");let t=fs.readFileSync(process.argv[1],"utf8").replace(/^\uFEFF/,"");
const d=JSON.parse(t);for(const i of d.imports||[]){const r=i.result||{};console.log((r.assetId||"MISSING")+" "+(r.filename||"?"))}'

# Windows only — ChatCut plugin bug P5 (1.10.14): the helper puts the Windows temp path unescaped into an ffmpeg
# filter, so every video WITH AUDIO fails to upload ("No option name near ..."). The asset is registered but empty.
# Instead of leaving the user to hunt for the file in a Windows file dialog: copy each video to Downloads (never
# overwrite), put its Windows path on the clipboard, and print the 3 clicks for "Click to relink".
# Deleting and re-uploading does not help (same helper, same failure — tested 27/09/2026).
# TODO: once ChatCut fixes P5, retry automatically with the helper's retry.args (same assetId, no delete).
relink_fallback() {
  local dl first="" f base ext dst
  dl="$(cygpath -u "$USERPROFILE")/Downloads"
  mkdir -p "$dl"
  for f in "$@"; do
    case "$f" in *.mp4|*.MP4|*.mov|*.MOV|*.m4v|*.webm) ;; *) continue ;; esac
    # only videos WITH audio hit P5; silent b-roll clips upload fine (skip them when ffprobe can tell)
    if command -v ffprobe >/dev/null 2>&1 && [ -z "$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of default=nw=1:nk=1 "$f" 2>/dev/null | tr -d '\r')" ]; then
      continue
    fi
    base="$(basename "$f")"; ext="${base##*.}"; dst="$dl/$base"
    if [ -e "$dst" ] && ! cmp -s "$f" "$dst"; then dst="$dl/${base%.*}-chatcut.$ext"; fi
    if [ -e "$dst" ]; then echo "  Phim đã có sẵn trong Downloads: $(basename "$dst") — không chép đè." >&2
    else cp -n "$f" "$dst" && echo "  Đã chép phim vào Downloads: $(basename "$dst")" >&2; fi
    [ -z "$first" ] && first="$dst"
  done
  [ -n "$first" ] || return 1
  powershell.exe -NoProfile -Command "Set-Clipboard -Value '$(cygpath -w "$first")'" >/dev/null 2>&1 \
    && echo "  Đường dẫn phim đã nằm sẵn trong bộ nhớ tạm (clipboard)." >&2
  cat >&2 <<'TXT'

Máy không tự gửi được phim này lên ChatCut (lỗi của plugin ChatCut trên Windows), cần bạn bấm giúp một lần:
  1. Trên trang ChatCut, bấm vào thẻ phim có chữ «Click to relink».
  2. Trong cửa sổ chọn tệp hiện ra, bấm vào ô «File name», nhấn Ctrl+V.
  3. Nhấn Enter. Xong thì nhắn «xong» cho Claude.
TXT
  return 0
}

start=$(date +%s)
if ! node "$helper" --token "$token" --endpoint "$endpoint" "$@" >"$out" 2>"$err"; then
  echo "Tải lên ChatCut KHÔNG thành công. Thông báo đầy đủ của công cụ tải:" >&2
  cat "$out" "$err" >&2
  if [ "$plat" = "win32" ]; then
    # the helper writes progress lines and the final failure JSON to stderr; take the first line that starts with {
    msg="$(grep -m1 '^{' "$err" | node -e 'let t="";process.stdin.on("data",c=>t+=c).on("end",()=>{try{const d=JSON.parse(t.replace(/^\uFEFF/,""));console.log(d.message||d.error||"")}catch(e){console.log("")}})' 2>/dev/null || true)"
    if printf '%s\n' "$msg" "$(cat "$err")" | grep -q "No option name near"; then
      relink_fallback "$@"
      exit 6
    fi
  fi
  exit 5
fi
echo "upload took $(( $(date +%s) - start ))s" >&2

node -e "$parse_imports" "$out"
