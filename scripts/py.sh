#!/usr/bin/env bash
# py.sh — run a Python script with a REAL Python 3.8+ and UTF-8 I/O, on macOS, Linux and Windows Git Bash.
# Usage: bash scripts/py.sh <script.py> [args...]
# Why: on Windows `python3` is often the Microsoft Store stub (exit 49) even after Python is installed,
# and Python writes cp1252 by default there, which breaks Vietnamese text. Tries python3 first so macOS keeps
# the interpreter that has whisper/Pillow installed.
set -uo pipefail
export PYTHONUTF8=1
for c in python3 python "py -3"; do
  # shellcheck disable=SC2086
  if $c -c "import sys; sys.exit(sys.version_info < (3,8))" >/dev/null 2>&1; then
    # shellcheck disable=SC2086
    exec $c "$@"
  fi
done
echo "FAIL chưa có Python 3.8+ thật trên máy (lệnh python3 có thể chỉ là lối tắt của Microsoft Store)." >&2
echo "  Windows: winget install -e --accept-source-agreements --accept-package-agreements --id Python.Python.3.12 --scope user   (xong thoát hẳn Claude rồi mở lại)" >&2
echo "  macOS:   brew install python" >&2
exit 1
