#!/usr/bin/env bash
# kiem-may.sh — READ-ONLY machine check for the skill. Installs nothing, changes nothing.
# Usage: bash scripts/kiem-may.sh
# Prints one plain-Vietnamese line per tool, then which videos this machine can make, then the exact install
# commands still needed (lines starting with "CÀI:") so the agent can ask the user ONE grouped question.
# Exit code: 0 = everything needed for both demos is ready · 1 = something required is missing · 2 = only optional items missing.
# Must run on macOS /bin/bash 3.2 and Windows Git Bash: no declare -A, mapfile, ${x,,}, globstar; strip \r from tool output.
set -u
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "$(uname -s)" in
  Darwin) OSN=mac ;;
  MINGW*|MSYS*|CYGWIN*) OSN=win ;;
  *) OSN=linux ;;
esac
ARCH="$(uname -m | tr -d '\r')"
case "$ARCH" in arm64|aarch64) ARCH=arm64 ;; x86_64|amd64) ARCH=x64 ;; esac
# On Windows, Git Bash can report x86_64 on an ARM laptop (emulation); trust the real CPU variable when present.
if [ "$OSN" = win ] && [ "${PROCESSOR_ARCHITEW6432:-${PROCESSOR_ARCHITECTURE:-}}" = "ARM64" ]; then ARCH=arm64; fi

req_missing=0   # something required is missing
opt_missing=0   # only optional things missing
can_edit=1      # «Sửa phim bằng sửa chữ» (ChatCut)
can_icon=1      # «Video icon kể chuyện» (Remotion + ChatCut)
installs=""     # install commands, one per line
restart_needed=0

line() {  # $1 mark  $2 name  $3 found  $4 need  $5 note  (no column padding: printf counts bytes, Vietnamese is multibyte)
  local s="$1 $2"
  [ -n "$3" ] && s="$s $3"
  [ -n "$4" ] && s="$s ($4)"
  printf '%s — %s\n' "$s" "$5"
}
add_install() { installs="${installs}CÀI: $1
"; }
first_line() { head -1 | tr -d '\r'; }
# version compare: vge 18.2.0 18 -> true when $1 >= $2 (numeric, dot-separated)
vge() { awk -v a="$1" -v b="$2" 'BEGIN{n=split(a,x,".");m=split(b,y,".");for(i=1;i<=(n>m?n:m);i++){p=x[i]+0;q=y[i]+0;if(p>q)exit 0;if(p<q)exit 1}exit 0}'; }
exists_glob() { for f in "$@"; do [ -e "$f" ] && return 0; done; return 1; }

echo "KIỂM MÁY — chỉ xem, không cài gì ($OSN, $ARCH)"
# 12. Where the skill lives: OneDrive sync and Vietnamese folder names («Tài liệu») break long builds (m22)
case "$SKILL_DIR" in
  *OneDrive*) line "⚠️" "Chỗ đặt bộ công cụ" "trong OneDrive" "" "OneDrive đồng bộ hàng nghìn tệp của bộ dựng video ⇒ nên chép sang ~/.claude/skills/ (Windows: %USERPROFILE%\\.claude\\skills)" ;;
  *) if printf '%s' "$SKILL_DIR" | LC_ALL=C grep -q '[^ -~]'; then
       line "⚠️" "Chỗ đặt bộ công cụ" "đường dẫn có dấu tiếng Việt" "" "vài công cụ đọc sai đường có dấu ⇒ nên chép sang ~/.claude/skills/"
     else line "✅" "Chỗ đặt bộ công cụ" "" "" "ổn"; fi ;;
esac

echo "────────────────────────────────────────"

# 1. Git + shell
if command -v git >/dev/null 2>&1; then
  line "✅" "Git" "$(git --version | first_line | awk '{print $3}')" "có" "ổn"
else
  line "❌" "Git" "—" "có" "chưa cài"; req_missing=1
  case "$OSN" in win) add_install "winget install -e --accept-source-agreements --accept-package-agreements --id Git.Git" ;; mac) add_install "xcode-select --install" ;; *) add_install "sudo apt install -y git" ;; esac
fi
line "✅" "Bash" "${BASH_VERSION%%(*}" "có" "ổn"

# 2. Node.js
node_path_hint() { [ "$OSN" = win ] && exists_glob "/c/Program Files/nodejs/node.exe"; }
if command -v node >/dev/null 2>&1; then
  nv="$(node -v 2>/dev/null | first_line | tr -d 'v')"
  if vge "$nv" 18; then line "✅" "Node.js" "$nv" "cần ≥ 18" "ổn"
  else line "❌" "Node.js" "$nv" "cần ≥ 18" "bản cũ quá"; req_missing=1; can_icon=0; can_edit=0
    case "$OSN" in win) add_install "winget install -e --accept-source-agreements --accept-package-agreements --id OpenJS.NodeJS.LTS" ;; mac) add_install "brew install node" ;; *) add_install "cài Node.js 18+ (nodejs.org)" ;; esac
  fi
elif node_path_hint; then
  line "⚠️" "Node.js" "đã cài" "cần ≥ 18" "ĐÃ CÀI nhưng cửa sổ Claude này chưa thấy ⇒ thoát hẳn Claude rồi mở lại"; req_missing=1; restart_needed=1; can_icon=0; can_edit=0
else
  line "❌" "Node.js" "—" "cần ≥ 18" "chưa cài (xưởng dựng video + công cụ tải phim của ChatCut cần nó)"; req_missing=1; can_icon=0; can_edit=0
  case "$OSN" in win) add_install "winget install -e --accept-source-agreements --accept-package-agreements --id OpenJS.NodeJS.LTS" ;; mac) add_install "brew install node" ;; *) add_install "cài Node.js 18+ (nodejs.org)" ;; esac
fi

# 3. FFmpeg (ffprobe)
ff_path_hint() { [ "$OSN" = win ] && exists_glob "${LOCALAPPDATA:-/nonexistent}"/Microsoft/WinGet/Packages/Gyan.FFmpeg*/*/bin/ffprobe.exe; }
if command -v ffprobe >/dev/null 2>&1 && command -v ffmpeg >/dev/null 2>&1; then
  line "✅" "FFmpeg" "$(ffprobe -version 2>/dev/null | first_line | awk '{print $3}' | cut -c1-12)" "có" "ổn"
elif ff_path_hint; then
  line "⚠️" "FFmpeg" "đã cài" "có" "ĐÃ CÀI nhưng cửa sổ Claude này chưa thấy ⇒ thoát hẳn Claude rồi mở lại"; req_missing=1; restart_needed=1; can_icon=0
else
  line "❌" "FFmpeg" "—" "có" "chưa cài (đọc và kiểm tra video)"; req_missing=1; can_icon=0
  case "$OSN" in win) add_install "winget install -e --accept-source-agreements --accept-package-agreements --id Gyan.FFmpeg" ;; mac) add_install "brew install ffmpeg" ;; *) add_install "sudo apt install -y ffmpeg" ;; esac
fi

# 4. Python 3.8+ (real one: the Windows Store stub exits 49 and is rejected by running it)
PY=""
for c in python3 python "py -3"; do
  # shellcheck disable=SC2086
  if $c -c "import sys; sys.exit(sys.version_info < (3,8))" >/dev/null 2>&1; then PY="$c"; break; fi
done
py_path_hint() { [ "$OSN" = win ] && exists_glob "${LOCALAPPDATA:-/nonexistent}"/Programs/Python/Python3*/python.exe; }
if [ -n "$PY" ]; then
  # shellcheck disable=SC2086
  pv="$($PY -c 'import sys;print("%d.%d.%d"%sys.version_info[:3])' 2>/dev/null | first_line)"
  note="ổn (lệnh: $PY)"
  if [ "$OSN" = win ] && [ "$PY" != python3 ]; then note="ổn (lệnh: $PY — trên máy này python3 chỉ là lối tắt Store)"; fi
  line "✅" "Python 3" "$pv" "cần ≥ 3.8" "$note"
  if ! vge "$pv" 3.10 || vge "$pv" 3.14; then
    line "➖" "  (Whisper)" "" "3.10–3.13" "bản Python này có thể không cài được Whisper — không ảnh hưởng video"
  fi
elif py_path_hint; then
  line "⚠️" "Python 3" "đã cài" "cần ≥ 3.8" "ĐÃ CÀI nhưng cửa sổ Claude này chưa thấy ⇒ thoát hẳn Claude rồi mở lại"; req_missing=1; restart_needed=1; can_icon=0
else
  line "❌" "Python 3" "—" "cần ≥ 3.8" "chưa cài (công cụ phụ: chia phụ đề, làm bảng hình)"; req_missing=1; can_icon=0
  case "$OSN" in win) add_install "winget install -e --accept-source-agreements --accept-package-agreements --id Python.Python.3.12 --scope user" ;; mac) add_install "brew install python" ;; *) add_install "sudo apt install -y python3 python3-pip" ;; esac
fi

# 5. Pillow + Whisper (optional)
if [ -n "$PY" ]; then
  # shellcheck disable=SC2086
  if plv="$($PY -c 'import PIL;print(PIL.__version__)' 2>/dev/null | first_line)" && [ -n "$plv" ]; then
    line "✅" "Pillow" "$plv" "tuỳ chọn" "ổn (làm bảng hình có nhãn giây)"
  else
    line "➖" "Pillow" "—" "tuỳ chọn" "chưa cài ⇒ chỉ thiếu bảng hình soát khung; video vẫn làm được"; opt_missing=1
    add_install "$PY -m pip install pillow"
  fi
fi
if command -v whisper >/dev/null 2>&1; then
  line "✅" "Whisper" "có" "tuỳ chọn" "ổn (nghe lại lời trong video)"
else
  line "➖" "Whisper" "—" "tuỳ chọn" "chưa cài ⇒ bỏ qua được; chỉ để kiểm lời (cài mất khoảng 9 phút trên máy thử Windows; lần dùng đầu tải thêm mô hình ~480 MB)"; opt_missing=1
  # long install: run it as its own command with a 10-minute limit, or in the background
  # Whisper installs on Python 3.10-3.13 only; on other versions the line above already says so
  [ -n "$PY" ] && vge "$pv" 3.10 && ! vge "$pv" 3.14 && add_install "$PY -m pip install -U openai-whisper   (lâu: khoảng 9 phút — chạy riêng, thời hạn 10 phút hoặc chạy nền)"
fi

# 6. Vietnamese text in Python on Windows
if [ "$OSN" = win ]; then
  if [ "${PYTHONUTF8:-}" = "1" ]; then line "✅" "Chữ tiếng Việt" "PYTHONUTF8=1" "" "ổn"
  else line "⚠️" "Chữ tiếng Việt" "chưa đặt" "PYTHONUTF8=1" "các script của skill tự bật; nên đặt sẵn cho Whisper"; opt_missing=1
    add_install "setx PYTHONUTF8 1"
  fi
fi

# 7. Disk space (>= 3 GB free where the skill lives)
free_kb="$(df -Pk "$SKILL_DIR" 2>/dev/null | awk 'NR==2{print $4}' | tr -d '\r')"
if [ -n "$free_kb" ]; then
  free_gb=$(( free_kb / 1024 / 1024 ))
  if [ "$free_gb" -ge 3 ]; then line "✅" "Ổ đĩa trống" "${free_gb} GB" "cần ≥ 3 GB" "ổn"
  else line "❌" "Ổ đĩa trống" "${free_gb} GB" "cần ≥ 3 GB" "thiếu chỗ cho bộ dựng video"; req_missing=1; can_icon=0; fi
fi

# 8. CPU architecture (Remotion has no Windows ARM build)
if [ "$OSN" = win ] && [ "$ARCH" = arm64 ]; then
  line "❌" "Kiến trúc" "arm64" "x64" "Remotion không chạy trên Windows ARM ⇒ chỉ làm được «Sửa phim bằng sửa chữ»"; can_icon=0; req_missing=1
else
  line "✅" "Kiến trúc" "$ARCH" "" "bộ dựng video chạy được"
fi

# 9. Remotion packages installed for THIS system (not copied from another OS / WSL)
NM="$SKILL_DIR/scripts/remotion/node_modules"
if [ -d "$NM" ]; then
  case "$OSN-$ARCH" in
    mac-arm64) want="compositor-darwin-arm64" ;; mac-x64) want="compositor-darwin-x64" ;;
    win-x64) want="compositor-win32-x64-msvc" ;; linux-x64) want="compositor-linux-x64-gnu" ;; linux-arm64) want="compositor-linux-arm64-gnu" ;;
    *) want="" ;;
  esac
  if [ -n "$want" ] && [ -d "$NM/@remotion/$want" ]; then line "✅" "Bộ dựng video" "đã cài" "" "ổn"
  else line "⚠️" "Bộ dựng video" "sai hệ" "" "thư mục node_modules không phải của máy này ⇒ cài lại: cd scripts/remotion && npm ci"; can_icon=0; req_missing=1; fi
else
  line "➖" "Bộ dựng video" "chưa cài" "" "sẽ cài ở bước sau (npm ci, 1–3 phút)"
fi

# 10. ChatCut plugin
helper="$(ls -d "$HOME"/.claude/plugins/cache/chatcut-inc/chatcut/*/skills/asset-import/scripts/upload-media.mjs 2>/dev/null | tail -1)"
if [ -n "$helper" ]; then
  pver="$(echo "$helper" | sed 's#.*/chatcut/\([^/]*\)/skills/.*#\1#')"
  line "✅" "Plugin ChatCut" "$pver" "" "ổn"
  if [ "$OSN" = win ] && ! command -v ffmpeg >/dev/null 2>&1 && [ ! -d "$(dirname "$helper")/ffmpeg" ]; then
    line "⚠️" "  (tải phim)" "" "" "plugin trên Windows thiếu FFmpeg đi kèm (lỗi plugin P1) ⇒ cần cài FFmpeg"
  fi
else
  line "❌" "Plugin ChatCut" "—" "" "chưa cài ⇒ trong Claude: /plugin marketplace add ChatCut-Inc/agent-plugin, rồi /plugin install chatcut@chatcut-inc, rồi /mcp → Authenticate"; can_edit=0; can_icon=0; req_missing=1
fi

# 11. Line endings (only when the skill is a git clone)
if [ -d "$SKILL_DIR/.git" ] && command -v git >/dev/null 2>&1; then
  if [ -f "$SKILL_DIR/.gitattributes" ]; then line "✅" "Xuống dòng (git)" "LF" "" "ổn"
  else line "⚠️" "Xuống dòng (git)" "$(git -C "$SKILL_DIR" config core.autocrlf | tr -d '\r')" "" "bản tải về cũ, md5 trong MANIFEST có thể lệch ⇒ tải lại bản mới"; opt_missing=1; fi
fi

# 13. macOS: the "brew install" lines need Homebrew, which a new Mac does not have
if [ "$OSN" = mac ] && ! command -v brew >/dev/null 2>&1 && printf '%s' "$installs" | grep -q "brew install"; then
  if exists_glob /opt/homebrew/bin/brew /usr/local/bin/brew; then
    line "⚠️" "Homebrew" "đã cài" "" "ĐÃ CÀI nhưng cửa sổ này chưa thấy ⇒ thoát hẳn Claude rồi mở lại"; restart_needed=1
  else
    line "❌" "Homebrew" "—" "" "chưa cài — các lệnh «brew install» bên dưới cần nó. Cài Homebrew phải do BẠN tự làm: mở Terminal, dán lệnh dưới, gõ mật khẩu máy khi được hỏi (Claude không gõ mật khẩu thay được)"
    req_missing=1
    installs="CÀI (bạn tự dán vào Terminal, gõ mật khẩu máy): /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
$installs"
  fi
fi

echo "────────────────────────────────────────"
v1="được"; [ "$can_edit" = 1 ] || v1="CHƯA"
v2="được"; [ "$can_icon" = 1 ] || v2="CHƯA"
echo "KẾT LUẬN: «Sửa phim bằng sửa chữ»: $v1 · «Video icon kể chuyện»: $v2"
[ "$restart_needed" = 1 ] && echo "LƯU Ý: có phần mềm đã cài nhưng cửa sổ Claude này chưa thấy ⇒ thoát hẳn Claude, mở lại, dán lại đúng câu đã gõ lúc đầu (mở lại cuộc trò chuyện cũ hay mở cuộc mới đều được)."
[ -n "$installs" ] && printf '%s' "$installs"

if [ "$req_missing" = 1 ]; then exit 1; fi
if [ "$opt_missing" = 1 ]; then exit 2; fi
exit 0
