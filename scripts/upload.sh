#!/usr/bin/env bash
# Upload up to 4 local media files into a ChatCut project via the plugin's upload helper.
# Usage: upload.sh <token> <endpoint> <file1> [file2 file3 file4]
#   token/endpoint come from MCP: import_media {action:"create_session", projectId}
# Prints one line per file: "<assetId> <filename>", plus elapsed seconds on stderr.
# The token is short-lived (30 min) and is never written to disk by this script.
set -euo pipefail

if [ "$#" -lt 3 ] || [ "$#" -gt 6 ]; then
  echo "usage: upload.sh <token> <endpoint> <file1> [up to 4 files]" >&2
  exit 2
fi
token="$1"; endpoint="$2"; shift 2

helper=$(ls -d "$HOME"/.claude/plugins/cache/chatcut-inc/chatcut/*/skills/asset-import/scripts/upload-media.mjs 2>/dev/null | sort -V | tail -1)
if [ -z "$helper" ]; then
  echo "upload-media.mjs not found: is the chatcut plugin installed?" >&2
  exit 3
fi

for f in "$@"; do
  [ -r "$f" ] || { echo "cannot read: $f" >&2; exit 4; }
done

out=$(mktemp -t chatcut-upload.XXXXXX)
err=$(mktemp -t chatcut-upload-err.XXXXXX)
start=$(date +%s)
if ! node "$helper" --token "$token" --endpoint "$endpoint" "$@" >"$out" 2>"$err"; then
  echo "upload helper failed; last stderr lines:" >&2
  tail -5 "$err" >&2
  exit 5
fi
echo "upload took $(( $(date +%s) - start ))s" >&2

python3 - "$out" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
for imp in d.get("imports", []):
    r = imp.get("result") or {}
    print(r.get("assetId", "MISSING"), r.get("filename", "?"))
PY
rm -f "$out" "$err"
