#!/usr/bin/env bash
# Upload up to 4 local media files into a ChatCut project via the plugin's upload helper.
# Usage: upload.sh <token> <endpoint> <file1> [file2 file3 file4]
#   token/endpoint come from MCP: import_media {action:"create_session", projectId}
# Prints one line per file: "<assetId> <filename>", plus elapsed seconds on stderr.
# The token is short-lived (30 min) and is never written to disk by this script.
# Needs only node (the helper itself is a node script). Works with macOS /bin/bash 3.2 and Windows Git Bash.
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
parse_imports='const fs=require("fs");let t=fs.readFileSync(process.argv[1],"utf8").replace(/^﻿/,"");
const d=JSON.parse(t);for(const i of d.imports||[]){const r=i.result||{};console.log((r.assetId||"MISSING")+" "+(r.filename||"?"))}'

start=$(date +%s)
if ! node "$helper" --token "$token" --endpoint "$endpoint" "$@" >"$out" 2>"$err"; then
  echo "Tải lên ChatCut KHÔNG thành công. Thông báo đầy đủ của công cụ tải:" >&2
  cat "$out" "$err" >&2
  exit 5
fi
echo "upload took $(( $(date +%s) - start ))s" >&2

node -e "$parse_imports" "$out"
