#!/usr/bin/env bash
# kiem-manifest.sh — check (or rebuild) MANIFEST.md, the list of every file in the skill with md5 and size.
# Usage:  bash scripts/kiem-manifest.sh            check: every listed file exists and matches, nothing is missing
#         bash scripts/kiem-manifest.sh --write    rebuild MANIFEST.md from the last commit (maintainers only)
# Inside its own git clone it hashes the COMMITTED content (git show HEAD:<file>), so Windows line endings (CRLF)
# in the working folder never cause false mismatches — and a file edited by hand but not committed still passes:
# this checks what you downloaded, not what you changed since (use git status for that).
# Outside git (a zip copy, or a copy inside another repo) it hashes the files on disk.
# Works with macOS /bin/bash 3.2 and Windows Git Bash. Exit: 0 all match · 1 mismatch/missing · 2 usage.
set -uo pipefail
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SKILL_DIR"
MAN=MANIFEST.md

md5_of() {  # reads stdin, prints the 32-char md5
  if command -v md5 >/dev/null 2>&1; then md5 -q; else md5sum | cut -c1-32; fi
}
use_git=0
# git mode only when the skill folder IS the root of its own clone: inside another repo (dotfiles, a project)
# HEAD:<path> would resolve from that repo's root and every file would look missing
if command -v git >/dev/null 2>&1 && git rev-parse --verify -q HEAD >/dev/null 2>&1 \
   && [ -z "$(git rev-parse --show-prefix 2>/dev/null | tr -d '\r')" ]; then use_git=1; fi
hash_file() {  # $1 path -> md5 of committed content (git) or of the file on disk
  if [ "$use_git" = 1 ]; then git show "HEAD:$1" | md5_of; else md5_of <"$1"; fi
}
size_file() {
  if [ "$use_git" = 1 ]; then git cat-file -s "HEAD:$1"; else wc -c <"$1" | tr -d ' \r'; fi
}

if [ "${1:-}" = "--write" ]; then
  [ "$use_git" = 1 ] || { echo "--write needs a git clone with at least one commit"; exit 2; }
  ver=$(sed -n 's/.*🔄 \*\*Bản:\*\* \(v[0-9.]*\).*/\1/p' SKILL.md | head -1)
  tmp="$MAN.tmp"
  {
    echo "# MANIFEST — demo-bien-tap-video-chatcut ${ver:-v?} ($(TZ=Europe/London date '+%Y-%m-%d %H:%M') London)"
    echo
    echo "Băm từ commit \`$(git rev-parse --short HEAD)\` — commit ngay trước commit ghi tệp này (tệp này tự nó không nằm trong danh sách). Kiểm lại: \`bash scripts/kiem-manifest.sh\`"
    echo
    echo "md5(8)    cỡ(byte)  tệp"
    git ls-files | while IFS= read -r f; do
      [ "$f" = "$MAN" ] && continue
      printf '%s %10s  %s\n' "$(hash_file "$f" | cut -c1-8)" "$(size_file "$f")" "$f"
    done
  } >"$tmp" && mv "$tmp" "$MAN"
  echo "wrote $MAN ($(grep -c '^[0-9a-f]\{8\} ' "$MAN") files)"
  exit 0
fi
[ -z "${1:-}" ] || { echo "usage: kiem-manifest.sh [--write]"; exit 2; }
[ -r "$MAN" ] || { echo "FAIL không thấy $MAN"; exit 1; }

ok=0; bad=0; listed=""
# rows look like: "<md5 8> <size>  <path>"; the path may contain spaces
while IFS= read -r line; do
  line="${line%$'\r'}"
  case "$line" in [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]\ *) ;; *) continue ;; esac
  want="${line%% *}"
  f="$(printf '%s\n' "$line" | sed 's/^[0-9a-f]\{8\} *[0-9]* *//')"
  listed="$listed
$f"
  if [ "$use_git" = 1 ]; then
    git cat-file -e "HEAD:$f" 2>/dev/null || { echo "FAIL thiếu: $f"; bad=$((bad+1)); continue; }
  else
    [ -e "$f" ] || { echo "FAIL thiếu: $f"; bad=$((bad+1)); continue; }
  fi
  got="$(hash_file "$f" | cut -c1-8)"
  if [ "$got" = "$want" ]; then ok=$((ok+1)); else echo "FAIL khác md5: $f (danh sách $want, thật $got)"; bad=$((bad+1)); fi
done <"$MAN"

if [ "$use_git" = 1 ]; then
  extra=$(git ls-files | while IFS= read -r f; do
    [ "$f" = "$MAN" ] && continue
    printf '%s\n' "$listed" | grep -qxF -- "$f" || echo "$f"
  done)
  if [ -n "$extra" ]; then
    printf '%s\n' "$extra" | sed 's/^/FAIL có trong kho nhưng không có trong MANIFEST: /'
    bad=$((bad + $(printf '%s\n' "$extra" | wc -l | tr -d ' ')))
  fi
fi

src="tệp trên đĩa"; [ "$use_git" = 1 ] && src="nội dung đã commit"
echo "khớp $ok tệp · lệch $bad (so bằng $src)"
[ "$bad" = 0 ] && { echo "RESULT PASS"; exit 0; }
echo "RESULT FAIL"; exit 1
