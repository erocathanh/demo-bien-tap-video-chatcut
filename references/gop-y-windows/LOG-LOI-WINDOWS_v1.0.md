# LOG LỖI WINDOWS — skill `demo-bien-tap-video-chatcut` — v1.0

> Repo: `https://github.com/erocathanh/demo-bien-tap-video-chatcut` · commit `2b39584` · thử ngày 27/09/2026
> Máy thử: Windows 11 Home 10.0.26200 · i9-14900HX · 32 GB · Claude desktop (tab Code) · Git Bash 5.3.9 · PowerShell 5.1
> Cách thử: (1) **chạy thật** từng bước README + Quy trình B trên máy Windows mới (chưa có node/ffmpeg/Python); (2) **13 agent đọc mã** toàn repo theo 6 mảng, mỗi mảng có 1 agent phản biện tìm cách bác bỏ.
> Sổ bấm giờ thô (định dạng giống log Mac, đã sạch tên người dùng — bỏ thẳng vào `references/ban-mau/` được): `dong-ho-cai-may-windows-27-09.log`
> Ký hiệu bằng chứng: 🟢 **CHẠY THẬT** trên Windows · 🟡 **ĐỌC MÃ + phản biện xác nhận** · ⚪ suy luận, chưa chạy được.

---

## 0. Kết luận — đọc 30 giây

- **Demo chính (Quy trình A, ChatCut) chạy trọn trên Windows: phim ra md5 `5656a249` — TRÙNG TỪNG BYTE bản Mac** (ChatCut render trên mây nên đổi máy không đổi byte). Nhưng **phải có người bấm tay 1 lần** vì tải phim có tiếng lên ChatCut hỏng ở cả 2 đường tự động (lỗi plugin, B7).
- **Skill CHẠY ĐƯỢC trên Windows sau khi vá.** Render ra video đúng (PSNR 42–45 dB so với bản mẫu); props sinh ra trùng từng byte bản Mac (sau khi bỏ CR); Whisper nghe ra lời trùng từng dòng log Mac.
- **Nhưng làm đúng README hiện tại thì học viên Windows vấp 7 chỗ chặn đường** (mục 1): bước 1 không có lệnh cài · bước 3 luôn báo `RESULT FAIL` dù video đúng · `python3` trên Windows là "cái vỏ" của Microsoft Store · chữ tiếng Việt làm Python/Whisper chết (Whisper chết **im lặng**, vẫn báo thành công) · `upload.sh` mất `assetId` · Quy trình C hứa "không cần node" là sai · **tải phim có tiếng lên ChatCut hỏng tự động** (lỗi plugin), người dùng phải tự tìm tệp.
- **Một lỗi nặng ở MỌI hệ, kể cả Mac (M13):** bước kiểm «câu đã xoá» không bao giờ bắt được câu demo, vì Whisper viết «buổi hai» thành «buổi 2» ⇒ phim chưa cắt vẫn PASS.
- **Tổng: 7 chặn đường (B) · 14 lớn (M) · 23 nhỏ (m) · 6 lỗi nằm ở plugin ChatCut + 1 chưa xác nhận (P — gửi đội ChatCut).**
- **11 việc sửa trong gói handoff giải quyết phần lớn** (mục 9): `.gitattributes` · bỏ `\r` khi đọc ffprobe · `upload.sh` đọc JSON bằng node + in trọn lỗi · ép UTF-8 cho mọi script Python + Whisper · chọn đúng lệnh Python trên Windows · mục cài Windows trong README (winget + thoát hẳn app) · **bước kiểm máy** (mục 5) · **luật thuyết minh lời thường** (mục 6) · sửa thước «câu đã xoá» · lối vượt cho người dùng khi tải phim hỏng · **đường B mới: Remotion dựng hình, ChatCut biên tập** (M14, tệp `DE-XUAT-DUONG-B-CHATCUT_v1.0.md`).

---

## 1. P0 — CHẶN ĐƯỜNG (làm theo README thì không qua được)

| # | Lỗi (nói thường) | Chỗ trong repo | Bằng chứng | Cách sửa |
|---|---|---|---|---|
| B1 | Bước 1 chỉ có lệnh cho Mac (`brew`, `pip3`). Windows không có lệnh nào ⇒ bước 1 không bao giờ PASS. Không nhắc Python và Pillow dù có 6 script `.py` | `README-CAI-MOI.md:14-25` · `README.md:24` · `SKILL.md:44` | 🟢 máy mới: node/npm/ffmpeg/ffprobe/whisper/brew đều thiếu | Thêm mục **«1W. Windows»**: `winget install -e --id OpenJS.NodeJS.LTS` · `winget install -e --id Gyan.FFmpeg` · `winget install -e --id Python.Python.3.12 --scope user` · `python -m pip install -U openai-whisper pillow` · `setx PYTHONUTF8 1` · rồi **thoát hẳn Claude và mở lại** (xem M1) |
| B2 | Bước 3 `bash render.sh broll` **luôn in `RESULT FAIL`** dù 3 clip đúng. `ffprobe.exe` trả `1080,1920,\r\n`; `tr -d ',\n'` bỏ `\n` nhưng để sót `\r` ⇒ so `"1080x1920\r"` với `"1080x1920"` trượt | `scripts/remotion/render.sh:22` | 🟢 11:40–11:43: 3 dòng `FAIL … size 1080x1920`; đo lại đúng cách: 91/81/70 khung, PSNR 44,4/43,5/42,7 dB. Cũng trượt ở `render.sh stage` | Dòng 22–23: `wh=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of default=nw=1:nk=1 "$f" \| tr -d '\r' \| paste -sd x -)` và `fr=$(… \| tr -d ',\r')`. 🟢 lệnh sửa chạy trên 3 bản render Windows: PASS cả 3, `1080x1920` (sổ bấm giờ «BƯỚC 3b-sửa») |
| B3 | `upload.sh` tải phim lên ChatCut **xong** rồi mới gọi `python3` để in `assetId`. Trên Windows `python3` là stub Store (rc 49) ⇒ phim đã nằm trên máy chủ nhưng script chết, không in `assetId`, tệp tạm không bị xoá | `scripts/upload.sh:35-42` | 🟢 chạy đúng đoạn 35–42 dưới `set -euo pipefail`: «Python was not found…», rc 49 | Thay khối python bằng node (node đã bắt buộc): `node -e 'const d=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));for(const i of d.imports\|\|[]){const r=i.result\|\|{};console.log(r.assetId\|\|"MISSING",r.filename\|\|"?")}' "$out"` + `trap 'rm -f "$out" "$err"' EXIT` ngay sau 2 dòng `mktemp`. 🟢 bản node in đúng `A1 phim.mp4` |
| B4 | **Chữ tiếng Việt làm Python chết trên Windows.** Python mặc định ghi/đọc bằng bảng mã cp1252 khi đầu ra bị chuyển hướng. `make_stage_props.py > props.json` ⇒ `UnicodeEncodeError` (tệp 0 byte). `measure_empty_stage.py` ⇒ `UnicodeDecodeError`. **Whisper chạy 117 giây, trả rc 0 nhưng KHÔNG ghi tệp nào** («Skipping … UnicodeEncodeError») ⇒ `verify-export.sh` báo «whisper produced no text» ⇒ `RESULT FAIL` trên phim ĐÚNG | `scripts/make_stage_props.py:269` · `scripts/measure_empty_stage.py:7` · `scripts/verify-export.sh:67` · `references/quy-trinh/video-san-khau-theo-cau.md:11,16,19` | 🟢 sổ bấm giờ: «T2» (props 0 byte) · «bước 8 measure_empty_stage.py (python.exe)» (UnicodeDecodeError) · «12:01 … whisper» (rc 0, không ghi tệp) · «12:05 … không cờ» (RESULT FAIL trên phim đúng). 🟢 thêm `PYTHONUTF8=1` thì cả 4 chạy đúng (props trùng byte, 0 cảnh vượt 0,6 s, Whisper 190 chữ = Mac, verify PASS + đối chứng âm FAIL đúng) | (a) Trong script: `sys.stdout.reconfigure(encoding="utf-8", newline="\n")` đầu `main()` (thiếu `newline` thì stdout Windows vẫn ghi CRLF); mọi `open()` thêm `encoding="utf-8"`; ghi JSON bằng tham số `--out` với `newline="\n"` thay vì `>`. (b) Trong `verify-export.sh` và mọi lệnh whisper: `PYTHONUTF8=1 whisper …` (hoặc `export PYTHONUTF8=1` đầu script). (c) README Windows: `setx PYTHONUTF8 1` |
| B5 | Tài liệu gọi `python3`. Trên Windows **cài Python xong `python3` VẪN là stub Store** (bộ cài python.org/winget chỉ tạo `python.exe` + `py.exe`) ⇒ mọi lệnh `python3 scripts/…` hỏng. `command -v python3` vẫn báo "có" nên kiểm kiểu đó không bắt được | `references/quy-trinh/video-san-khau-theo-cau.md:16,19,20` · `scripts/upload.sh:35` · shebang 6 tệp `.py` | 🟢 phiên mới (PATH nạp lại): `python → Python312\python.exe` · `python3 → WindowsApps\python3.exe` (rc 49) | Chọn lệnh Python **trong cùng một lệnh Bash** (biến không giữ qua các lần gọi tool): `PY=; for c in python3 python "py -3"; do $c -c "import sys; sys.exit(sys.version_info < (3,8))" >/dev/null 2>&1 && { PY="$c"; break; }; done; [ -n "$PY" ] \|\| { echo "FAIL chưa có Python 3.8+ thật"; exit 1; }` rồi gọi `$PY scripts/…`. Thử `python3` trước để Mac giữ đúng trình có whisper/Pillow; lối tắt Store trả rc 49 nên tự bị loại; KHÔNG loại đường `WindowsApps` (Python cài từ Microsoft Store là Python thật). Tài liệu ghi: macOS `python3` · Windows `python` hoặc `py -3` |
| B7 | **Tải phim CÓ TIẾNG lên ChatCut hỏng trên Windows ở cả 2 đường tự động** (gốc là lỗi plugin — mục 4, P5 + P6). Đường 1 `upload.sh` → helper chết sau 3 s: đường tệp tạm `C:\Users\…` phá cú pháp bộ lọc ffmpeg. Đường 2 loopback → khung trình duyệt của Claude desktop chặn `127.0.0.1`. Clip KHÔNG tiếng (b-roll) thì qua được. Kết cục: 4 tệp được **đăng ký** nhưng phim không có nội dung; người dùng phải tự bấm «Click to relink» và **tự tìm tệp trong hộp chọn của Windows** — Owner đã kẹt đúng ở đây vì không biết tệp nằm trong `%USERPROFILE%\.claude\skills\…` | `scripts/upload.sh:28-31` · `references/mcp-call-sequence.md:14` · `SKILL.md:92` | 🟢 27/09 12:15–12:21: rc 5 + tệp lỗi đầy đủ; loopback 0/4 «ERR_BLOCKED_BY_CLIENT»; chạy lại theo `retry.args` với `TMPDIR=.` ⇒ 3 b-roll OK, phim vẫn lỗi; Owner relink tay ⇒ OK | **Trong repo (làm ngay):** (a) `upload.sh` in TRỌN JSON lỗi của helper, không `tail -5` (đã che nguyên nhân); (b) Windows + video có tiếng ⇒ agent **không để người dùng tự mò**: tự chép tệp ra `Downloads` + đưa đường dẫn vào clipboard, rồi thuyết minh đúng 3 bước bấm (xem mục 6). **Đề xuất của Owner (ghi nhận, đúng hướng):** agent **tự làm, không bắt người dùng bấm** — nhưng «xoá rồi tải lại» bằng chính helper sẽ **lỗi y hệt** (đã thử) ⇒ tự động hoàn toàn chỉ được khi: (1) ChatCut sửa P5 ⇒ agent chạy lại `retry.args` cho đúng mã tệp cũ, **không cần xoá**; hoặc (2) trong lúc chờ, agent tự đẩy tệp qua trình duyệt (vd tool tải tệp của Claude in Chrome trên `app.chatcut.io`, cần Owner duyệt tải lên) rồi **tự xoá bản đăng ký hỏng mà chính nó vừa tạo** để khỏi trùng tệp |
| B6 | Quy trình C hứa **«máy chỉ có ChatCut, chưa có node vẫn chạy được»** — sai. Bước tải lên (`upload.sh`) gọi `node`; helper của plugin cũng là script node; trên Windows còn cần ffmpeg trên PATH (xem mục 4, lỗi plugin) và `python3` (B3) | `references/quy-trinh/ghep-nguyen-lieu-san-chatcut.md:10,12,28` · `README.md:19-20` · `README-CAI-MOI.md:84` · `SKILL.md:169-172` | 🟡 đọc `upload.sh:28`, `upload-media.mjs`, `serve-local-media.mjs` (cả 2 đường tải lên của plugin đều là node). Phản biện xác nhận | Sửa cửa rẽ: **Quy trình C cần node** (không cần Remotion). Máy **không có node** thật ⇒ đường duy nhất: người dùng tự kéo-thả 5 tệp vào `app.chatcut.io` trong khung trình duyệt của Claude desktop, rồi agent ghép bằng MCP. Bỏ `verify-export.sh` ở bước 5 khi máy không có ffmpeg |

---

## 2. P1 — SAI KẾT QUẢ HOẶC PHẢI TỰ VƯỢT

| # | Lỗi (nói thường) | Chỗ trong repo | Bằng chứng | Cách sửa |
|---|---|---|---|---|
| M1 | **Bẫy PATH:** winget cài xong, nhưng cửa sổ Claude đang mở **không thấy** node/ffmpeg/Python (winget in «restart your shell»). `Kiểm: node -v` báo thiếu dù đã cài; dễ rẽ nhầm sang Quy trình C | `README-CAI-MOI.md:20-25,37` · `ghep-nguyen-lieu-san-chatcut.md:12` | 🟢 sau cài: Git Bash `node=MISSING`, PowerShell `node=False`, registry PATH đã có | README: «Cài xong **thoát hẳn Claude** (chuột phải biểu tượng góc phải thanh tác vụ → Quit) rồi mở lại». Bước kiểm máy (mục 5) phải phân biệt **"chưa cài"** với **"đã cài nhưng cửa sổ này chưa thấy"** |
| M2 | `verify-export.sh` báo `FAIL not 1080x1920` với video **có ICC profile** (phim mẫu, mọi bản render Remotion): ffprobe in thêm dấu phẩy cuối `1080,`. Lỗi này **không riêng Windows** — chỉ chưa lộ vì trên Mac mới kiểm bản xuất ChatCut (không có ICC) | `scripts/verify-export.sh:29-30` | 🟢 phim mẫu `phim-buoi-1-co-tieng.mp4` ⇒ `size 1080,x1920,` ⇒ RESULT FAIL; bản render Quy trình B cũng FAIL | Đọc bằng `-of default=nw=1:nk=1` + `tr -d '\r'` cho width, height, duration, codec. 🟢 lệnh sửa ra `1080x1920` trên tệp có ICC (phim mẫu) và không ICC (bản xuất ChatCut) — sổ bấm giờ «BƯỚC 3b-sửa» |
| M3 | Repo **không có `.gitattributes`**. Git for Windows mặc định đổi xuống dòng sang CRLF ⇒ 120 tệp chữ đổi byte ⇒ md5 lệch **119/176 dòng MANIFEST** và 3/10 dòng `MD5.txt` (tách ra — MANIFEST: 116 dòng chỉ do CRLF · 1 dòng `README-CAI-MOI.md` lệch sẵn trên mọi máy (m7) · 2 dòng do chính lượt thử sửa tệp (M8). MD5.txt: 2 dòng do CRLF · 1 dòng `ke-hoach-ghep.json` lệch sẵn (m7)); icon sinh lại trùng byte **0/30**. (Script `.sh` vẫn chạy vì Git Bash 5.3 chịu CRLF — đã thử; bash của WSL/Linux thì không chịu) | gốc repo · `MANIFEST.md` · `assets/nguyen-lieu-video-2/MD5.txt` · `scripts/make_icons_svg*.py:145/158` | 🟢 `git ls-files --eol`: `i/lf w/crlf`; props checkout md5 `97d535bd` ≠ `832a9dbf`; bỏ CR thì khớp. Icon: 0/30 → 30/30 sau khi bỏ CR | Thêm `.gitattributes`, **mỗi mẫu một dòng**: `* text=auto eol=lf` / `*.mp4 binary` / `*.mp3 binary` / `*.wav binary` / `*.png binary` (viết chung một dòng là sai cú pháp, git bỏ cả dòng), rồi `git add .gitattributes && git add --renormalize .` (trên Mac là no-op vì index đã LF). Script Python ghi tệp dùng `open(…, "w", encoding="utf-8", newline="\n")`. README: bản clone cũ phải clone lại |
| M4 | `lam-bang-khung.py` cần **Pillow** mà README không ghi. Font nhãn giây trỏ cứng `/System/Library/Fonts/…` của Mac ⇒ Windows lùi về font mặc định **bé xíu**, bảng khung không đọc được giây | `scripts/lam-bang-khung.py:5,23` · `video-san-khau-theo-cau.md:20` | 🟢 `No module named 'PIL'`; cài Pillow 12.3.0 xong chạy được nhưng nhãn bé (ảnh: `bang-chung/bang-khung-windows.png` · `bang-chung/bang-khung-mac.png` — CHỈ để so cỡ nhãn giây; bản Mac là bảng của video v03b cũ nên nội dung từng khung khác) | README thêm `pip install pillow`. Dòng 23: thử lần lượt Mac → `C:\Windows\Fonts\arialbd.ttf` → `DejaVuSans-Bold.ttf`, cuối cùng `ImageFont.load_default(size=30)` (Pillow ≥ 10.1 nhận `size`) |
| M5 | Lệnh trong README là cú pháp bash. Dán vào **PowerShell 5.1** (cửa sổ mặc định của học viên Windows) thì: `&&` lỗi · `\| head -1` lỗi · `bash` không có (hoặc trỏ vào **WSL** Linux, dùng nhầm `node_modules` Windows) · `~` trong `git clone … ~/.claude/…` không mở rộng · `claude mcp add-json '{…}'` mất hết nháy kép · `npm` bị chặn: «npm.ps1 cannot be loaded because running scripts is disabled» | `README-CAI-MOI.md:7-10,15-25,33,44-47,55-58` · `README.md:11-12` | 🟢 `npm -v` trong PowerShell chính sách mặc định ⇒ bị chặn; `npm.cmd -v` chạy. 🟡 add-json mất nháy: phản biện tái hiện được | Ghi rõ đầu README: **«Mọi lệnh chạy trong Git Bash (tool Bash của Claude Code). Tự gõ tay trên Windows thì mở Git Bash, không dùng PowerShell.»** Nếu giữ PowerShell: dùng `npm.cmd`, `;` thay `&&`, đường dẫn `$env:USERPROFILE\.claude\skills\…` |
| M6 | README hứa `render.sh stage` **ra đúng md5 `182cc1e4`**, «tất định». Trên Windows: 2 lượt trùng nhau (`0f258eae`) nhưng **khác Mac** ⇒ ai kiểm bằng md5 sẽ tưởng hỏng. Video thật ra tương đương: cùng 1996 khung, 66,53 s, PSNR 45,2 dB, 0 khung đen | `README-CAI-MOI.md:86` · `README.md:21` | 🟢 2 lượt render + so PSNR | Đổi thành: «ra video **tương đương** bản mẫu (so số khung + độ dài + PSNR ≥ 40 dB). md5 chỉ trùng trên cùng một máy» |
| M7 | README bước 4 đòi đối chứng âm ra `RESULT FAIL`, nhưng máy **không có Whisper** thì script in `SKIP` và vẫn `RESULT PASS` ⇒ học viên tưởng bộ kiểm hỏng | `README-CAI-MOI.md:59-60` · `scripts/verify-export.sh:85-87` | 🟢 bước 4 lúc chưa có whisper: `SKIP whisper not installed` + `RESULT PASS` | Ghi «đối chứng âm chỉ có ý nghĩa khi đã cài Whisper». Nên cho `verify-export.sh` in `RESULT PASS (chưa kiểm lời — thiếu whisper)` hoặc exit 2 |
| M8 | Làm đúng README thì **repo bị bẩn**: bước 4 ghi đè tệp đã commit `assets/ban-mau-da-ra/vsl-chatcut-broll-codex-contact.png` (992 KB → 441 KB); `npm install` (npm 11) xoá 11 dòng `"peer": true` trong `package-lock.json` ⇒ lần `git pull` cập nhật skill sau sẽ bị chặn | `scripts/verify-export.sh:48,61` · `README-CAI-MOI.md:45,56` | 🟢 `git status`: 2 tệp `M` | `verify-export.sh` ghi ảnh ghép vào thư mục ra riêng (vd `out/` hoặc `--sheet-dir`), không ghi cạnh tệp trong `assets/`. README dùng **`npm ci`** thay `npm install` |
| M9 | **Windows ARM** (laptop Snapdragon / Copilot+ PC): `npm install` qua, nhưng render chắc chắn hỏng — Remotion không có bản `win32-arm64` | `scripts/remotion/package-lock.json:715-787` | 🟡 đọc mã Remotion đã cài: chỉ nhánh x64 | Bước kiểm máy (mục 5) kiểm kiến trúc; ARM ⇒ đi Quy trình C |
| M10 | README cho chọn «MỘT trong hai đường» nối ChatCut; **đường 2** (`claude mcp add-json`, không cài plugin) không có helper tải lên ⇒ `upload.sh` thoát rc 3, demo không tải được phim | `README-CAI-MOI.md:29-35` | 🟡 `upload.sh:15-19` tìm helper trong thư mục cache của plugin | Bỏ đường 2 khỏi README của demo này, hoặc ghi rõ «đường 2 không tải được phim» |
| M11 | `draw-broll.sh` đo cỡ ảnh bằng `sips` (chỉ macOS có) ⇒ Windows/Linux: ảnh đúng vẫn báo FAIL | `scripts/draw-broll.sh:36` | 🟡 `sips` không có trong Git Bash | Đo bằng `ffprobe -v error -show_entries stream=width,height -of default=nw=1:nk=1 … \| tr -d '\r'` |
| M13 | **Bước kiểm «câu đã xoá» MÙ với chính câu demo — mọi hệ, kể cả Mac.** Whisper viết số bằng chữ số: «buổi hai» ⇒ «buổi 2». So chuỗi «hẹn bạn xem buổi hai» không bao giờ khớp ⇒ phim **CHƯA cắt** vẫn được báo `PASS removed phrase not heard`. Đối chứng âm trên Mac dùng câu «gửi tặng skill» (không có số) nên thước đo trông như chạy đúng | `scripts/verify-export.sh:70-74` · `SKILL.md:139-143` · `README-CAI-MOI.md:56-60` | 🟢 27/09: chạy trên phim gốc CHƯA cắt ⇒ heard «Hẹn bạn xem buổi 2, bí mật AI…» mà vẫn `PASS removed phrase not heard` (phát hiện của agent rà sót, Owner-PM chạy lại xác nhận) | `norm()` nối dòng + đổi chữ số thành chữ ở CẢ hai phía trước khi so, bằng `perl -Mutf8 -CSD -0777 …` (bắt buộc `-Mutf8`: thiếu thì «một, bốn, năm…» không bao giờ khớp — phản biện đã thử; câu lệnh đầy đủ ở mục 9 item 9). Thêm đối chứng âm **bằng chính câu demo trên phim gốc chưa cắt** vào README (phải ra FAIL) |
| M12 | `render.sh` không kiểm mã thoát của `npx`: render hỏng mà trong `out/` còn tệp cũ thì vẫn in PASS cho **phim cũ** | `scripts/remotion/render.sh:30-32` | 🟡 đọc mã | `npx … \|\| { echo "FAIL render $1"; fail=1; return; }` và xoá tệp ra cũ trước khi render |
| M14 | **Sai mục tiêu (Owner phát hiện 27/09):** repo là «biên tập video bằng ChatCut» nhưng Quy trình B chạy trọn trên máy (Remotion → mp4), **không đi qua ChatCut**; phụ đề in cứng trong Remotion nên không sửa được bằng chữ và dễ chồng 2 lớp khi ghép | `references/quy-trinh/video-san-khau-theo-cau.md` · `SKILL.md:145-172` · `references/quy-trinh/ghep-nguyen-lieu-san-chatcut.md` | 🟢 Owner chốt hướng «Remotion dựng hình, ChatCut biên tập». 🟢 IconStage bỏ phụ đề chỉ bằng `captions: []` (render thử 59 s, 1996 khung, có tiếng, không chữ — sổ «ĐƯỜNG B MỚI») | Theo `DE-XUAT-DUONG-B-CHATCUT_v1.0.md`: nhánh B-1 (có video quay mặt — Owner phải quay) và B-2 (giọng AI: 1 clip có tiếng không phụ đề → ChatCut gạch câu + phụ đề + xuất); Quy trình C nhập vào B-2 |

---

## 3. P2 — NHỎ HOẶC CHỈ LÀ CÂU CHỮ

| # | Lỗi | Chỗ | Cách sửa |
|---|---|---|---|
| m1 | Phím mở khung trình duyệt chỉ ghi `Cmd+Shift+B` | `SKILL.md:99` | Thêm «Windows: **Ctrl+Shift+B**» (tài liệu Claude desktop), hoặc «bấm thẻ preview trong chat» |
| m2 | «Mở phim cho tôi xem»: không ghi lệnh; `open` không có trên Windows; `start` của Git Bash lấy tham số đầu làm tiêu đề cửa sổ | `SKILL.md:96` · `references/quy-trinh/demo-chatcut-sua-phim-bang-sua-chu.md:21` | Ghi cả 3: macOS `open "<tệp>"` · Git Bash `start "" "$(cygpath -w "<tệp>")"` · PowerShell `Invoke-Item "<tệp>"` |
| m3 | Tải bản xuất bằng `curl -s -o`: trong PowerShell 5.1 `curl` là bí danh của `Invoke-WebRequest` (lỗi tham số); thiếu `-f` nên link hết hạn vẫn lưu ra «.mp4» rác; không nói lưu vào đâu | `references/mcp-call-sequence.md:23` | Git Bash: `curl -fsSL --create-dirs -o "$SKILL_DIR/out/<tên>.mp4" "<url>"` · PowerShell: `curl.exe` |
| m4 | `norm()` dùng `tr '[:upper:]' '[:lower:]'`: GNU `tr` (Git Bash, Linux) chỉ hạ chữ hoa ASCII, không hạ `Đ À Ấ Ư…` ⇒ có thể PASS giả cho câu đã xoá | `scripts/verify-export.sh:70` | dùng chung `norm()` `perl -Mutf8 -CSD …` của M13 / mục 9 item 9 (perl có sẵn trên Mac, Git Bash, Linux) |
| m5 | `$inputs` không có ngoặc kép: thư mục tạm có dấu cách (tên user Windows) ⇒ không ghép được ảnh 10 khung | `scripts/verify-export.sh:59-61` | Dùng mảng bash `inputs+=(-i "$tmp/$j.png")` |
| m6 | `--face` tách bằng `split(":")` ⇒ vỡ khi đường có ký tự ổ đĩa `D:\…`; đường tuyệt đối cũng không dùng được với `staticFile` | `scripts/make_stage_props.py:267` | `rsplit(":", 2)` + chặn đường tuyệt đối/`public/` bằng thông báo rõ |
| m7 | MANIFEST cũ ngay cả trên Mac: md5 `README-CAI-MOI.md` sai, thiếu `README.md`, `ke-hoach-ghep.json` lệch giữa MANIFEST và `MD5.txt`; `MD5.txt` không đúng định dạng `md5sum -c` | `MANIFEST.md:5` · `assets/nguyen-lieu-video-2/MD5.txt:6` | Sinh lại MANIFEST sau commit cuối (sau khi có `.gitattributes`) |
| m8 | Mọi số thời gian chỉ đo trên Mac có npm cache sẵn | `SKILL.md:43,101-108` · `README-CAI-MOI.md:45,50` · `video-san-khau-theo-cau.md:25` | Thêm cột Windows từ mục 8 |
| m9 | Bước 0 bảo «giải nén» nhưng không có lệnh; lệnh `git clone` nằm cuối tệp, sau bước 5 | `README-CAI-MOI.md:6-12,79-86` | Đưa `git clone` lên bước 0 |
| m10 | Rà rò rỉ đường dẫn người dùng chỉ tìm dạng Mac `/Users/…`, bỏ sót `C:\Users\…` và `/c/Users/…` | `references/ban-mau/dong-ho-cai-may-moi-26-09.log:78` | Thêm 2 mẫu Windows vào bước rà |
| m11 | «Giải nén vào thư mục bất kỳ»: đường dài nhất sau `npm install` + Chrome là **222/260 ký tự** (user tên 5 chữ), LongPathsEnabled mặc định tắt ⇒ đặt trong OneDrive/Desktop sâu dễ vượt | `README-CAI-MOI.md:12` | Windows: «để ở `%USERPROFILE%\.claude\skills`, tránh OneDrive/Desktop» |
| m12 | Lần render đầu, Windows Firewall hỏi quyền mạng cho Node.js | `README-CAI-MOI.md:49` | Báo trước: «bấm Cho phép hay Huỷ đều render được» (🟡 nhật ký tường lửa của máy thử có ghi) |
| m13 | Mọi composition (kể cả BrollDong không có chữ) tải font Be Vietnam Pro từ Google Fonts mỗi lần render ⇒ mất mạng là hỏng | `scripts/remotion/src/fonts.ts:5` | Đóng gói `public/fonts/BeVietnamPro-Bold.ttf` (giấy phép OFL) |
| m14 | Composition `IconOverlay` trỏ tới 6 icon PNG + `head.mp4` không có trong `public/` ⇒ mở trong Studio là lỗi, học viên dễ tưởng do Windows | `scripts/remotion/src/IconOverlay.tsx:101` | Ẩn khỏi `Root.tsx` hoặc đóng gói tệp thiếu |
| m15 | `/plugin` tìm «chatcut» không ra nếu chưa thêm marketplace của ChatCut | `README-CAI-MOI.md:30` | Ghi lệnh thêm marketplace trước |
| m16 | `check-caption-band.sh` mở ~7 tiến trình mỗi khung ⇒ ⚪ ước sẽ rất chậm trên Windows (mỗi tiến trình ffmpeg khởi động lâu), dễ tưởng treo — CHƯA đo (script chưa chạy trên Windows) | `scripts/check-caption-band.sh:24` | Báo trước thời gian hoặc gom bằng một lệnh ffmpeg |
| m17 | `verify-export.sh` không kiểm có ffmpeg/ffprobe trước ⇒ máy thiếu công cụ vẫn in «PASS no black frames» giữa một loạt FAIL khó hiểu | `scripts/verify-export.sh:40` | Kiểm `command -v ffprobe ffmpeg` đầu script |
| m18 | Đề vẽ icon bộ 02 trỏ tới thư mục không tồn tại `../icon-set-01/`, đòi PNG trong khi bộ này là SVG | `assets/icon/bo-02-svg/de-ve-icon.txt:4` | Sửa đường và định dạng |
| m19 | `verify-export.sh` giấu hết đầu ra của Whisper: lần đầu tải mô hình `small` (~483 MB) mà không báo gì, trông như treo; lỗi nào cũng chỉ còn «whisper produced no text» | `scripts/verify-export.sh:67` | Ghi đầu ra Whisper vào tệp log, in «lần đầu tải mô hình ~480 MB» khi chưa có `~/.cache/whisper/small.pt`, lỗi thì in 5 dòng cuối log |
| m20 | `render.sh stage` có tới 3 «bản mẫu» mâu thuẫn nhau; 2 tài liệu còn trỏ vào bản v03b cũ (PSNR chỉ 14,5 dB so với bản render hiện tại) | `SKILL.md:151` · `references/quy-trinh/video-san-khau-theo-cau.md:5` · `references/ban-mau/README.md` · `render.sh:41` | Chốt MỘT bản mẫu: `assets/nguyen-lieu-video-2/video-2-tao-lai.mp4` (1996 khung); `render.sh:41` kiểm 1996 khung thay vì 0 |
| m21 | Không có công cụ kiểm MANIFEST; trên Windows cả `md5sum` (tệp CRLF) lẫn `Get-FileHash` (chữ HOA) đều báo lệch hàng loạt | `MANIFEST.md:3` | Thêm `scripts/kiem-manifest.sh` so với nội dung trong git (`git show HEAD:<tệp> \| { if command -v md5 >/dev/null; then md5 -q; else md5sum \| cut -c1-32; fi; }`) — không phụ thuộc CRLF, chạy cả Mac lẫn Git Bash |
| m22 | Desktop/Documents của Windows 11 thường nằm trong OneDrive, Documents có tên tiếng Việt «OneDrive\Tài liệu» ⇒ đặt skill ở đó dễ dính đồng bộ + dấu tiếng Việt trong đường dẫn | `README-CAI-MOI.md:12` | Ghi rõ: chỉ dùng `%USERPROFILE%\.claude\skills\…`; `render.sh`/`verify-export.sh` cảnh báo nếu đường dẫn chứa `OneDrive` |
| m23 | Lệnh gộp `npm install && bash render.sh broll` dễ vượt thời hạn 2 phút mặc định của tool Bash trong Claude Code (đo trên Windows: 30 s + 160 s = 190 s) ⇒ npm bị ngắt giữa chừng, `node_modules` dở dang vẫn lọt qua kiểm của `render.sh` | `SKILL.md:45` · `README-CAI-MOI.md:44-46` · `render.sh:15` | Tách 2 lệnh; dặn Claude chạy với thời hạn 10 phút hoặc chạy nền; `render.sh` kiểm `node_modules/.package-lock.json` + `node_modules/.bin/remotion` |

Hai phát hiện bị **phản biện bác bỏ** (không đưa vào sửa): «font phụ đề Windows khác Mac» (cả hai đều ra Arial) · «lời dặn mở phiên mới là sai» (đúng cho plugin; chỉ skill mới nạp ngay giữa phiên).

---

## 4. Lỗi nằm ở PLUGIN CHATCUT (gửi đội ChatCut, không sửa trong repo này)

| # | Lỗi | Bằng chứng | Ảnh hưởng tới demo |
|---|---|---|---|
| P1 | Trong cache plugin trên Windows, `skills/asset-import/scripts/ffmpeg` là **tệp chữ 52 byte** (symlink git bị biến thành tệp vì Windows mặc định `core.symlinks=false`) ⇒ helper không tới được bản ffmpeg win32 đi kèm | 🟡 plugin 1.10.14, `upload-media.mjs:269-275` | Máy Windows không có ffmpeg ⇒ tải lên hỏng; phải tự cài ffmpeg |
| P2 | Lỗi thiếu ffmpeg chỉ gợi ý «macOS: brew install ffmpeg» | 🟡 `upload-media.mjs:244` | Học viên Windows không biết cài gì |
| P3 | Helper đăng nhập `login-chatcut.sh` dùng `python3` + `pty` + `/tmp` ⇒ chỉ chạy trên macOS/Linux | 🟡 đọc mã plugin | Đăng nhập trên Windows phải qua `/mcp` → Authenticate (🟢 đã chạy được) |
| P4 | Hướng dẫn plugin dặn `open <url>` (lệnh Mac) | 🟡 plugin basics `SKILL.md:254` | Nhỏ |
| P5 | **Helper tải lên đưa đường Windows vào bộ lọc ffmpeg không thoát ký tự:** `ametadata=print:file=C:\Users\…\chatcut-…-waveform-….txt` ⇒ ffmpeg báo `No option name near 'Users…'` ⇒ **mọi video có tiếng đều tải lên hỏng trên Windows**. Đặt `TMPDIR=.` không cứu được (helper đổi thành đường tuyệt đối). Cách sửa phía ChatCut (🟡 phản biện đã thử với ffmpeg 9.0.2): đổi `\` → `/` rồi bọc giá trị bằng `\'…\'` (vd `ametadata=print:file=\'C:/Users/…/x.txt\'`) hoặc thoát 2 lớp `C\\:/…`; chỉ `\:` một lớp VẪN lỗi; hoặc ghi dạng sóng ra stdout/pipe | 🟢 27/09 12:15:47 (`upload.sh`) và 12:2x (chạy lại `--asset-id`, `TMPDIR=.`) · `upload-media.mjs:1428-1446` | **Chặn** bước 4 của demo trên Windows |
| P6 | Đường «preferred» loopback (`serve-local-media.mjs` + `import_media from_editor/relink_from_editor`) bị **khung trình duyệt tích hợp của Claude desktop chặn** (`ERR_BLOCKED_BY_CLIENT`) — chính thông báo của plugin nói gọi lại cũng lỗi y hệt | 🟢 27/09 12:1x: 0/4 tệp | Không còn đường tự động dự phòng |
| P7 | ⚪ **CHƯA XÁC NHẬN — KHÔNG gửi ChatCut.** Lượt chạy lại `--asset-id` từng in «rc=0» kèm JSON lỗi, nhưng rc đó đo qua lệnh bọc ngoài; đọc mã thấy ngược lại: `upload-media.mjs:2466` in `ok:false` rồi `:2476` `process.exit(1)` | 🟡 đọc mã phản bác; sổ bấm giờ (12:2x) không ghi rc riêng | Cần chạy lại `node upload-media.mjs … --asset-id <id> <phim>; echo rc=$?` mới kết luận |

---

## 5. ỨNG DỤNG PHẢI CÀI THÊM + ĐẶC TẢ BƯỚC KIỂM VERSION

### 5.1 Danh sách — những gì máy Windows mới phải cài để chạy trọn skill

| # | Ứng dụng | Để làm gì (nói thường) | Bắt buộc? | Bản tối thiểu | Bản đã thử Windows 27/09 | Bản log Mac 26/09 | Lệnh kiểm version | Cài trên Windows | Cài trên macOS | Thời gian cài (Windows, đo) |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Git for Windows (kèm Git Bash) | tải skill về máy + chạy các script `.sh` | Bắt buộc (Claude Code trên Windows cũng cần) | Windows: Git Bash (đã thử bash 5.3.9) · macOS: `/bin/bash` 3.2 có sẵn là đủ | 2.54.0 · bash 5.3.9 | — (có sẵn) | `git --version` · `bash --version` | `winget install -e --id Git.Git` | có sẵn / `xcode-select --install` | có sẵn trên máy thử |
| 2 | Node.js (kèm npm) | chạy xưởng dựng video Remotion + helper tải phim của ChatCut | **Bắt buộc** (cả Quy trình C) | ≥ 18 | 24.19.0 · npm 11.17.0 | 24.13.0 | `node -v` · `npm.cmd -v` (PowerShell) | `winget install -e --id OpenJS.NodeJS.LTS` (có hộp UAC) | `brew install node` | 33 s |
| 3 | FFmpeg (kèm ffprobe) | đọc/kiểm video: khổ, độ dài, tiếng, khung đen, ảnh ghép | **Bắt buộc** | chưa đo; đã thử 9.0.1 và 9.0.2 | 9.0.2 (Gyan full) | 9.0.1 | `ffprobe -version` (dòng 1) | `winget install -e --id Gyan.FFmpeg` | `brew install ffmpeg` | 185 s (tải ~200 MB) |
| 4 | Python 3 **thật** | chạy 6 script `.py` (props sân khấu, đo thẻ trống, bảng khung, sinh icon) | Bắt buộc cho Quy trình B | 3.10–3.13 (whisper/torch) | 3.12.10 | có (không ghi bản) | Windows: `python --version` (phải chạy được bản ≥ 3.8; lối tắt Store `python3` trả rc 49) · macOS: `python3 --version` | `winget install -e --id Python.Python.3.12 --scope user` | có sẵn / `brew install python` | 80 s |
| 5 | Pillow | vẽ bảng khung có nhãn giây | Bắt buộc cho bước 8 Quy trình B | chưa đo; ≥ 10.1 nếu dùng `load_default(size=)` | 12.3.0 | — | `python -c "import PIL;print(PIL.__version__)"` | `python -m pip install pillow` | `python3 -m pip install pillow` | 10 s |
| 6 | Whisper (openai-whisper + torch) | nghe lại lời trong video: kiểm câu đã xoá, lấy mốc từng chữ | Tuỳ chọn (bắt buộc nếu muốn đối chứng âm / làm tiếng mới) | 20250625 | 20250625 · torch 2.14.0+cpu | có | `whisper --help` (dòng 1) · `python -c "import whisper"` | `python -m pip install -U openai-whisper` | `pip3 install -U openai-whisper` | 533 s (~9 phút) + lần đầu tải mô hình `small` |
| 7 | Chrome Headless Shell | Remotion "chụp" từng khung hình | Tự tải ở lần render đầu | — | 149.0.7790.0 · 270 MB | tự tải | có thư mục `scripts/remotion/node_modules/.remotion/chrome-headless-shell` | tự động | tự động | ước ~128 s (138 s lượt đầu − ~10 s render thường; chưa đo riêng) |
| 8 | Remotion + gói npm | xưởng dựng video | Bắt buộc cho Quy trình B | 4.0.471 (khoá trong lockfile) | 4.0.471 · 185 gói · `node_modules` 713 MB | 185 gói | `node -e "console.log(require('remotion/package.json').version)"` trong `scripts/remotion` | `npm ci` | `npm ci` | 30 s (npm cache trống) |
| 9 | Plugin ChatCut cho Claude Code | biên tập phim trên ChatCut bằng lệnh | Bắt buộc cho Quy trình A/C | chưa đo | 1.10.14 | có | có thư mục `~/.claude/plugins/cache/chatcut-inc/chatcut/<bản>` | `/plugin` → cài chatcut → `/mcp` → Authenticate | như Windows | có sẵn |
| 10 | Codex CLI | vẽ ảnh b-roll mới | Tuỳ chọn | — | chưa thử | — | `codex --version` | — | — | — |

Dung lượng đĩa cần trống: **≥ 3 GB** (node_modules 713 MB + Python/torch ~1–1,5 GB + mô hình Whisper `small` ~0,5 GB + ffmpeg ~0,2 GB).

### 5.2 Đặc tả bước kiểm máy — `scripts/kiem-may.sh` (chạy trong Git Bash / Terminal Mac)

**Mục đích:** chạy **trước** bước 1 của README. Với mỗi ứng dụng ở bảng 5.1, in đúng **một dòng lời thường**, rồi kết luận máy đi được quy trình nào.

**Mẫu đầu ra** (mỗi dòng: trạng thái · tên · bản tìm thấy · bản cần · việc phải làm):
```text
[1] KIỂM MÁY TRƯỚC KHI CÀI — mẫu đầu ra mong muốn
✅ Git Bash      5.3.9    cần ≥ 5      ổn
✅ Node.js       24.19.0  cần ≥ 18     ổn
⚠️ FFmpeg        9.0.2    —            ĐÃ CÀI nhưng cửa sổ Claude này chưa thấy ⇒ thoát hẳn Claude rồi mở lại
❌ Python 3      —        cần 3.10–3.13 chưa cài (lệnh python3 trên máy này chỉ là lối tắt Microsoft Store) ⇒ winget install -e --id Python.Python.3.12 --scope user
➖ Whisper       —        tuỳ chọn     chưa cài ⇒ bỏ qua được; muốn kiểm lời thì cài sau
✅ Chữ tiếng Việt PYTHONUTF8=1           ổn
✅ Ổ đĩa trống   162 GB   cần ≥ 3 GB   ổn
✅ Kiến trúc     x64                    Remotion chạy được
────────────────────────────────────────
KẾT LUẬN: đi được Quy trình A (ChatCut) · CHƯA đi được Quy trình B (thiếu Python) · Quy trình C: được
```

**Luật bắt buộc cho script:**
1. **Chỉ đọc, không cài gì.** In lệnh cài để người dùng/agent chạy sau khi đồng ý.
2. Nhận ra hệ điều hành bằng `uname -s` (`Darwin` · `Linux` · `MINGW*/MSYS*`) và in lệnh cài đúng hệ (winget / brew / apt).
3. Mọi đầu ra của công cụ phải `tr -d '\r'` trước khi so sánh (lỗi B2).
4. **Python:** thử lần lượt `python3`, `python`, `py -3`; chỉ tính là có khi chạy được `-c "import sys; sys.exit(sys.version_info < (3,8))"` (lối tắt Store trả rc 49 nên tự bị loại); đường nằm trong `WindowsApps` chỉ BÁO, không loại (Python cài từ Microsoft Store là Python thật).
5. **Bẫy PATH (M1):** nếu lệnh không có trên PATH nhưng tệp tồn tại ở chỗ cài quen thuộc (`/c/Program Files/nodejs/node.exe`, `$LOCALAPPDATA/Microsoft/WinGet/Packages/Gyan.FFmpeg*/*/bin/ffprobe.exe`, `$LOCALAPPDATA/Programs/Python/Python3*/python.exe`) ⇒ in ⚠️ «đã cài nhưng cửa sổ này chưa thấy — thoát hẳn Claude rồi mở lại», **không** in ❌.
6. So version theo số (`sort -V`), không so chuỗi.
7. Kiểm `PYTHONUTF8=1` trên Windows (lỗi B4); thiếu ⇒ ⚠️ kèm lệnh `setx PYTHONUTF8 1`.
8. Kiểm kiến trúc: `arm64` trên Windows ⇒ ❌ Quy trình B, chỉ còn A/C (lỗi M9).
9. Kiểm `scripts/remotion/node_modules` có gói **đúng hệ đang chạy** (`@remotion/compositor-win32-x64-msvc` trên Windows) — tránh `node_modules` chép từ Mac hoặc cài bằng WSL.
10. Kiểm plugin ChatCut: có thư mục cache + có `upload-media.mjs`; trên Windows cảnh báo lỗi plugin P1 nếu thiếu ffmpeg trên PATH.
11. Kiểm `git config core.autocrlf` + có `.gitattributes` chưa; lệch ⇒ ⚠️ «md5 trong MANIFEST sẽ lệch, clone lại sau khi repo có .gitattributes».
12. Mã thoát: `0` = đủ cho Quy trình B · `1` = thiếu bắt buộc · `2` = chỉ thiếu tuỳ chọn.
13. Có bản PowerShell `scripts/kiem-may.ps1`: lưu **UTF-8 CÓ BOM** (PowerShell 5.1 đọc tệp không BOM theo bảng mã ANSI ⇒ vỡ chữ Việt); dòng đầu `[Console]::OutputEncoding=[Text.Encoding]::UTF8`; không `&&`, gọi `npm.cmd`. README ghi lệnh chạy `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kiem-may.ps1` (Bypass chỉ cho tiến trình đó, không đổi cấu hình máy).
14. `kiem-may.sh` phải chạy được trên `/bin/bash` 3.2 của macOS: không dùng globstar `**`, `declare -A`, `mapfile`, `${x,,}`; agent Mac tự thử bằng `/bin/bash scripts/kiem-may.sh`.

**Nơi gắn vào:** README-CAI-MOI mục «0.5 Kiểm máy» (sau clone, trước cài) và lặp lại ở cuối mục 1 làm dòng **Kiểm**. SKILL.md mục ① bước 0: agent **tự chạy** `bash scripts/kiem-may.sh` trước mọi việc khác.

---

## 6. ĐỀ XUẤT: LUẬT THUYẾT MINH CHO NGƯỜI KHÔNG RÀNH KỸ THUẬT

**Vấn đề:** hiện skill và README viết cho người đã biết `npm`, `PATH`, `ffprobe`, `render`. Người học nhìn Claude chạy lệnh mà không biết máy đang cài gì, vì sao, bao giờ xong, có phải bấm gì không. Khi bộ kiểm báo `FAIL` oan (lỗi B2, B4), họ hoảng.

**Luật đề xuất — chép vào đầu `SKILL.md` (mục «🗣️ Thuyết minh»):**
```text
[2] LUẬT THUYẾT MINH — dán vào SKILL.md
Trước MỖI bước cài đặt hoặc chạy, agent nói 1–2 câu LỜI THƯỜNG, trả lời đủ 4 ý:
  1. Đang làm gì      (tên việc bằng lời thường, không phải tên lệnh)
  2. Để làm gì        (lợi ích cho người dùng)
  3. Mất bao lâu      (lấy số đo thật của máy cùng loại; chưa đo thì nói «chưa đo»)
  4. Bạn có phải làm gì không (bấm Yes, đăng nhập, thoát app…) — không cần thì nói rõ «bạn không cần làm gì»
Sau MỖI bước: báo 1 câu kết quả — «xong» / «chưa xong, vì …, bước tiếp theo là …».
KHÔNG dùng từ chuyên môn (npm, PATH, ffprobe, render, CRLF, MCP, props…). Buộc phải nhắc tên công cụ
thì kèm lời giải thích trong ngoặc ngay lần đầu, ví dụ «FFmpeg (bộ công cụ đọc và kiểm tra video)».
Khi bộ kiểm báo lỗi: nói lỗi đó có làm hỏng video không, trước khi nói cách sửa.
Không in nguyên khối log cho người dùng — tóm lại bằng lời, log để trong tệp.
```

**Câu mẫu cho từng bước** (agent dùng nguyên văn hoặc sát nghĩa):

| Bước | Câu thuyết minh mẫu |
|---|---|
| Kiểm máy | «Tôi xem máy anh đã có đủ đồ nghề làm video chưa. Chỉ xem, không cài gì. Khoảng 10 giây.» |
| Tải skill | «Tôi tải bộ công cụ làm video về máy anh (khoảng 185 MB, 1–2 phút). Anh không cần làm gì.» |
| Cài Node.js | «Tôi cài Node.js — phần mềm giúp máy chạy được xưởng dựng video. Windows sẽ hiện hộp hỏi quyền, anh bấm **Yes**. Khoảng 30 giây.» |
| Cài FFmpeg | «Tôi cài FFmpeg — bộ công cụ đọc và kiểm tra video (dài bao lâu, có tiếng không, có khung đen không). Khoảng 3 phút.» |
| Cài Python | «Tôi cài Python — mấy công cụ phụ (chia phụ đề, làm bảng hình) cần nó để chạy. Khoảng 1–2 phút.» |
| Cài Whisper | «Tôi cài Whisper — công cụ nghe lại lời nói trong video để chắc câu đã xoá không còn. Khá nặng: khoảng 1 GB, 9 phút. Muốn bỏ qua cũng được, video vẫn làm ra bình thường.» |
| Thoát app | «Máy đã cài xong nhưng cửa sổ Claude này chưa "nhìn thấy" phần mềm mới. Anh tắt **hẳn** Claude (chuột phải biểu tượng góc phải thanh tác vụ → Quit), mở lại, rồi gõ "tiếp tục".» |
| Tải mảnh ghép dựng video | «Tôi tải các mảnh ghép cho xưởng dựng video (khoảng 700 MB, 30 giây đến 3 phút tuỳ mạng). Anh không cần làm gì.» |
| Lần dựng đầu | «Lần đầu dựng, máy tải thêm một trình duyệt ẩn để vẽ từng khung hình (270 MB, khoảng 2 phút) — lần sau không tải nữa. Nếu Windows hỏi quyền mạng, anh bấm Cho phép hay Huỷ đều được.» |
| Tải phim lên ChatCut | «Tôi gửi phim lên máy chủ ChatCut để biên tập. Phim có mặt và giọng người thật — anh đã đồng ý trong câu lệnh. Khoảng 10–30 giây.» |
| Cần người dùng chọn tệp (B7) | «Máy không tự gửi được phim này, cần anh bấm giúp một lần. Tôi đã chép phim vào thư mục **Downloads** và chép sẵn đường dẫn. Anh bấm vào thẻ phim có chữ "Click to relink" → trong cửa sổ hiện ra bấm ô **File name**, nhấn **Ctrl+V**, rồi **Enter**. Xong nhắn "xong".» |
| Kiểm phim ra | «Tôi kiểm phim vừa làm: đúng khổ dọc, có tiếng, không có khung đen, và câu đã xoá không còn nghe thấy.» |
| Bộ kiểm báo sai | «Bộ kiểm báo "chưa đạt", nhưng phim thật ra **đúng** — công cụ kiểm đọc nhầm trên Windows. Tôi đã kiểm lại bằng cách khác: đạt. Lỗi này đã ghi để người làm skill sửa.» |

---

## 7. NHỮNG GÌ ĐÃ CHẠY TỐT TRÊN WINDOWS (giữ nguyên)

- 🟢 **Quy trình A trọn vẹn** (sau khi phim đã lên): bóc lời tiếng Việt đúng 15 câu · `apply_script` gạch câu 36,3 → 32,0 s · `find_transcript` ra đúng 3 mốc khung như Mac · `edit_item` 3 clip lên V2 · `smooth_audio` y số liệu Mac · xuất 28,9 s · **md5 `5656a249` trùng từng byte bản Mac** · `verify-export.sh` + Whisper PASS.
- 🟢 Trình biên tập ChatCut mở và cập nhật trực tiếp trong khung trình duyệt của Claude desktop (khán giả xem được dòng thời gian đổi theo từng bước).
- 🟢 Skill trong `%USERPROFILE%\.claude\skills` được Claude nhận **ngay giữa phiên** sau khi clone.
- 🟢 Plugin ChatCut có sẵn: bấm Authenticate giữa phiên ⇒ 60 tool ChatCut hiện ngay.
- 🟢 `package-lock.json` (tạo trên Mac) có đủ gói Windows x64: `@remotion/compositor-win32-x64-msvc`, `@esbuild/win32-x64`. `npm install` 30 s với cache trống.
- 🟢 npm 11 chặn postinstall của esbuild («allow-scripts») nhưng esbuild vẫn chạy đúng.
- 🟢 Render Remotion trên Windows **đúng**: b-roll PSNR 42,7–44,4 dB; video sân khấu cùng 1996 khung, PSNR 45,2 dB, 0 khung đen; hai lượt trùng md5.
- 🟢 `make_stage_props.py` (khi đã ép UTF-8) ra props **trùng từng byte** bản Mac (bỏ CR) ⇒ thuật toán không lệch giữa các hệ.
- 🟢 Whisper `small` chạy CPU trên Windows ra lời **trùng từng dòng** log Mac.
- 🟢 Git Bash 5.3.9 chịu được script CRLF; `$(…)` tự bỏ cặp `\r\n` cuối ⇒ `verify-export.sh` đọc đúng bản xuất ChatCut (md5 PASS `46c7b4d5`).
- 🟢 Remotion Studio chạy trên Windows và xem được trong khung trình duyệt của Claude desktop (sổ «Remotion Studio»).
- 🟢 Đường dẫn dài nhất 222/260 ký tự — còn dư với tên user ngắn (sổ «BƯỚC 3b-sửa»).

---

## 8. SỐ ĐO — WINDOWS SO VỚI MAC

| Việc | Mac 25–26/09 (Apple Silicon, npm cache sẵn; Quy trình A đo 25/09) | Windows 27/09 (i9-14900HX, máy mới) |
|---|---|---|
| Cài node | có sẵn | 33 s (winget + UAC) |
| Cài ffmpeg | có sẵn | 185 s |
| Cài Python | có sẵn | 80 s |
| Cài Whisper | có sẵn | 533 s |
| `npm install` | 19 s | 30 s (cache trống) |
| `render.sh broll` lượt đầu | 22 s + 5 s + 4 s = 31 s | 138 s + 10 s + 10 s (160 s tính cả bước kiểm; gồm tải Chrome 270 MB) |
| `render.sh stage` (65 s phim) | 29 s | 64 s · 70 s |
| Quy trình B bước 7 render | 33 s | 66 s |
| Whisper `small` 66 s tiếng | 47 s | 59 s (lượt có mô hình sẵn) |
| `verify-export.sh` có Whisper | ~23 s | 34 s (lượt Quy trình A) |
| md5 `render.sh stage` | `182cc1e4` | `0f258eae` (2 lượt trùng nhau) |
| **Quy trình A** — tải phim + 3 clip lên ChatCut | 10 s (ảnh) · 28 s (clip động) | **hỏng tự động** (B7): helper 3 s lỗi · loopback lỗi · b-roll tải lại 12 s · phim: Owner relink tay (chưa bấm giờ) |
| Quy trình A — bóc lời tiếng Việt | ≤ 21 s | ~8 s (ChatCut báo ETA 6 s) |
| Quy trình A — gạch câu | 36,36 → 32,0 s | 36,36 → 32,0 s (trùng) |
| Quy trình A — mốc 3 b-roll | 304→395 · … | 304→395 · 424→505 · 637→707 (trùng) |
| Quy trình A — render trên mây | 17,7 s (ảnh) · 20,5 s (clip) | 28,9 s |
| Quy trình A — tải về + `verify-export.sh` có Whisper | ~23 s | 2 s + 34 s |
| **Quy trình A — md5 bản ra** | `5656a249` | **`5656a249` — trùng từng byte** |

---

## 9. GÓI HANDOFF

### Part A — kiểm trước khi giao (Owner chạy thử trên Mac, chỉ đọc, không sửa gì; repo trên Mac nằm chỗ khác thì đổi dòng `cd`)

```bash
: '[A1] PRE-FLIGHT — đếm đúng những chỗ log này nêu, trước khi giao sửa'
cd "$HOME/.claude/skills/demo-bien-tap-video-chatcut" && git status --short && git log --oneline -1 && echo "--- .gitattributes:" && (ls .gitattributes 2>/dev/null || echo "CHƯA CÓ") && echo "--- chỗ gọi python3:" && grep -rn "python3" --include="*.sh" --include="*.md" --include="*.py" . | grep -v node_modules | wc -l && echo "--- render.sh dòng 22:" && sed -n '22p' scripts/remotion/render.sh && echo "--- open() thiếu encoding:" && grep -n "open(" scripts/*.py | grep -v "encoding=" && echo "--- font Mac cứng:" && grep -n "/System/Library" scripts/*.py && echo "--- chữ Windows trong tài liệu:" && grep -rln -i "windows\|winget\|git bash" --include="*.md" . | grep -v node_modules | wc -l
```

### Part B — lệnh cho AI code (Cursor / Claude Code)

```text
[B1] AI-READ — WINDOWS COMPATIBILITY PATCH for skill demo-bien-tap-video-chatcut (base commit 2b39584)

ROLE: You are the code engineer. Implement ONLY the items below. Do not refactor, rename, or reformat anything else.
Do not change Remotion compositions, visual timing rules, or the ChatCut MCP call sequence. Source of truth for every
item: LOG-LOI-WINDOWS_v1.0.md (IDs B1..B7, M1..M14, m1..m23; P1..P7 are ChatCut plugin bugs - report only, do not patch). All shell scripts must keep working on macOS (BSD tools)
AND on Windows Git Bash (MSYS2, native node.exe/ffprobe.exe/python.exe that print CRLF).

P0 — must ship together:
1. Add .gitattributes at repo root, ONE pattern per line (5 lines): `* text=auto eol=lf`, `*.mp4 binary`, `*.mp3 binary`,
   `*.wav binary`, `*.png binary`. `git add .gitattributes`, then `git add --renormalize .` (expect a no-op on macOS: the
   index at 2b39584 is already LF; only Windows checkouts change). Do NOT regenerate MANIFEST.md / MD5.txt here: that is
   the separate LAST commit (LENH prompt [1] step 9), because MANIFEST lists SKILL.md, README-CAI-MOI.md and every script.
2. scripts/remotion/render.sh check(): read width/height with
   `ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of default=nw=1:nk=1 "$f" | tr -d '\r' | paste -sd x -`
   and frames with `... | tr -d ',\r'`. Also fail when `npx remotion render` exits non-zero and delete the old output
   before rendering (M12). Acceptance: `bash render.sh broll` prints RESULT PASS on Windows Git Bash and on macOS.
3. scripts/verify-export.sh: read width, height, duration, codec with `-of default=nw=1:nk=1` + `tr -d '\r'`
   (fixes trailing comma on ICC-profile files, M2). Export PYTHONUTF8=1 before calling whisper (B4). Check ffmpeg/ffprobe
   exist at start (m17). Build ffmpeg inputs with a bash array (m5). Lowercase and normalise numbers with
   the norm() of item 9 (m4). Write the contact sheet to a separate output dir (default: "$(dirname "$f")"
   unless the file is inside assets/, then "$SKILL_DIR/out/") so README step 4 never overwrites tracked files (M8); define
   SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)", `mkdir -p "$SKILL_DIR/out"`, add `/out/` to the root .gitignore (today only
   scripts/remotion/out/ is ignored) and update SKILL.md:142. Acceptance: after README steps 3-4, `git status --short` is empty.
   When whisper is missing print "RESULT PASS (speech not checked: whisper missing)" (M7).
   Acceptance: on assets/phim-mau/phim-buoi-1-co-tieng.mp4 prints "PASS vertical 1080x1920".
4. scripts/upload.sh: replace the python3 heredoc with a node one-liner that parses the helper JSON (strip a leading BOM);
   add `trap 'rm -f "$out" "$err"' EXIT` right after mktemp; before calling the helper, hard-check only `node` (exit 3 with a
   plain-Vietnamese hint: macOS `brew install node` · Windows `winget install -e --id OpenJS.NodeJS.LTS`). Do NOT hard-fail
   on ffmpeg: the helper uses its bundled ffmpeg on darwin-arm64 and win32-x64; only WARN when ffmpeg is not on PATH AND
   (Windows and the plugin's scripts/ffmpeg is a plain file - plugin bug P1) or the platform has no bundle (Intel Mac,
   Linux). Print the helper's JSON "message" on failure.
5. Python scripts (make_stage_props.py, measure_empty_stage.py, make_clusters.py, lam-bang-khung.py,
   make_icons_svg.py, make_icons_svg_set03.py): every open() gets encoding="utf-8" (writers also newline="\n");
   call sys.stdout.reconfigure(encoding="utf-8", newline="\n") and sys.stderr.reconfigure(encoding="utf-8") at start
   (newline is required: without it Windows stdout still writes CRLF);
   make_stage_props.py and make_clusters.py get an --out PATH option (keep stdout as default).
   make_stage_props.py --face: parse with rsplit(":", 2) and reject absolute paths / "public/" prefix with a clear error (m6).
   lam-bang-khung.py: font fallback list macOS -> C:\Windows\Fonts\arialbd.ttf -> DejaVuSans-Bold.ttf -> ImageFont.load_default(size=30).
   Acceptance: regenerated icons are byte-identical to git HEAD on Windows; props from the sample inputs md5 832a9dbf.
6. Docs: never call bare `python3`. Use a resolver in the SAME shell command:
   `PY=; for c in python3 python "py -3"; do $c -c "import sys; sys.exit(sys.version_info < (3,8))" >/dev/null 2>&1 && { PY="$c"; break; }; done; [ -n "$PY" ] || { echo "FAIL chưa có Python 3.8+ thật"; exit 1; }`
   (python3 first so macOS keeps the interpreter that has whisper/Pillow; the Store stub fails the check with rc 49). Update references/quy-trinh/video-san-khau-theo-cau.md steps 3, 6, 8.
7. New scripts/kiem-may.sh (+ scripts/kiem-may.ps1): READ-ONLY machine check exactly per section 5.2 of the log
   (14 rules, plain-Vietnamese one-line output per tool, exit codes 0/1/2). Wire it as README-CAI-MOI step 0.5 and
   SKILL.md section ① step 0.
8. README-CAI-MOI.md / README.md / SKILL.md: add a Windows section (winget commands from section 5.1, `setx PYTHONUTF8 1`,
   "quit Claude completely and reopen" after installs, "run every .sh in Git Bash", npm ci instead of npm install,
   Ctrl+Shift+B, open/start/Invoke-Item, curl -fsSL --create-dirs), fix Quy trinh C gate ("needs node, not Remotion";
   no-node path = drag files into app.chatcut.io in the Claude desktop browser pane), replace the md5 182cc1e4 promise
   with "equivalent: same frame count + duration + PSNR >= 40 dB", move git clone to step 0, add the Windows timing
   column from section 8, add the plain-language narration rule of section 6 to the top of SKILL.md.

9. scripts/verify-export.sh removed-phrase check (M13, ALL platforms): whisper writes numbers as digits ("buổi hai" -> "buổi 2"),
   so the demo's own removed phrase never matches and an UNCUT film passes. Use this norm() on BOTH sides:
   norm() { perl -Mutf8 -CSD -0777 -pe '$_=lc; tr/\r\n.,?!/ /; s/\b10\b/mười/g; s/\b0\b/không/g; s/\b1\b/một/g; s/\b2\b/hai/g; s/\b3\b/ba/g; s/\b4\b/bốn/g; s/\b5\b/năm/g; s/\b6\b/sáu/g; s/\b7\b/bảy/g; s/\b8\b/tám/g; s/\b9\b/chín/g; s/\s+/ /g; s/^ | $//g'; }
   -Mutf8 is REQUIRED (without it the non-ASCII number words never match). Self-test:
   [ "$(printf 'Ở buổi 1,' | norm)" = "$(printf 'ở buổi một' | norm)" ]. Add to README step 4 a
   negative control that runs the demo phrase on the uncut film assets/phim-mau/phim-buoi-1-co-tieng.mp4 and must print
   "FAIL removed phrase still audible"; add a second one with "Tối nay, ở buổi một" (tests a non-ASCII number word). Also log whisper output to a file and announce the first ~480 MB model download (m19).
10. scripts/upload.sh + SKILL.md for Windows upload failure (B7): print the helper's FULL JSON error (not tail -5); detect the
   ChatCut plugin Windows bug (ffmpeg "No option name near" in the waveform step) and, instead of leaving the user to search
   a file dialog, copy the file to the user's Downloads folder, put its full path on the clipboard (PowerShell Set-Clipboard),
   and print the exact 3 plain-language clicks for "Click to relink" (section 6 row "Cần người dùng chọn tệp").
   Windows only (MINGW*/MSYS*): the helper writes progress lines AND the final failure JSON to STDERR ($err); take the
   first line of $err starting with `{` and parse it with node. Copy with `cp -n` into "$(cygpath -u "$USERPROFILE")/Downloads/"
   (never overwrite; same name with a different md5 -> <name>-chatcut.<ext>) and put the WINDOWS path on the clipboard:
   powershell.exe -NoProfile -Command "Set-Clipboard -Value '$(cygpath -w "$dst")'". Skip this block on macOS/Linux.
   Do NOT delete or re-upload assets automatically: the same helper fails the same way (tested). Leave a TODO to switch to an
   automatic retry (helper retry.args, same assetId, no delete) once ChatCut fixes plugin bug P5.

11. Route B redesign (M14, Owner decision 27/09 "Remotion dựng hình, ChatCut biên tập"): implement section 4 of
   DE-XUAT-DUONG-B-CHATCUT_v1.0.md (6 sub-items). Keep the Remotion compositions; only props/flags, a render.sh target,
   docs and one packaged clip change.

P1/P2: items M9, M10, M11, m1-m3, m8-m23 as described in the log, only if trivial; otherwise list them as TODO.

OUTPUT: one commit per numbered item, message in English. Final report: files changed, what each change fixes (log ID),
what you deliberately did not touch, tests you ran (macOS) and tests that still need a Windows run.
```

---

## 10b. KINH NGHIỆM MỚI NÊN ĐƯA VÀO SKILL — phụ đề ChatCut CHỈ ở đoạn b-roll (chạy thật 27/09 trên dự án `dien-tap-windows-27-09`, Owner giao — sổ bấm giờ «PHỤ ĐỀ CHATCUT CHỈ TRÊN B-ROLL»)

**Bối cảnh:** phim nền đã in sẵn phụ đề; 3 clip b-roll đè lên thì che mất phụ đề gốc. SKILL.md hiện chỉ dặn «phim có phụ đề thì ĐỪNG bật edit_captions» (lỗi đã biết số 3) — đúng nhưng thiếu cách xử lý đoạn b-roll.

```text
[3] CÔNG THỨC — phụ đề ChatCut chỉ hiện trên b-roll (đã chạy thật, soát 12 khung sạch)
1  edit_captions enable                       ⇒ mặc định lấy CẢ V1 + V2 (đúng cảnh báo repo)
2  edit_captions set_sources {"sources":[{"trackId":"V1"}]} ⇒ refresh
3  đo dải phụ đề in sẵn trên 1 khung gốc (ffmpeg crop + lưới): phim mẫu = x 75–1000 · y 1255–1360 · chữ ~58 px
4  edit_captions style  {"font":"Be Vietnam Pro","sizePx":56,"fontWeight":"700","color":"#FFFFFF",
                          "backgroundColor":"#0B1628","backgroundOpacity":0.94,"backgroundRadius":16}
   edit_captions layout {"sourceId":"<V1 source>","left":75,"top":1255,"width":930,"height":105} ⇒ refresh
5  read_captions ⇒ ẩn MỌI thẻ ngoài b-roll, TỪNG thẻ một (mỗi lệnh cần revision của lệnh trước):
   set_card_style {"cardId":…,"style":{"opacity":0,"backgroundOpacity":0},"revision":…}
   🪤 chỉ "opacity":0 thì CHỈ chữ mất, khung nền tối vẫn hiện
   🪤 ẩn cả lớp (style opacity 0) rồi bật riêng thẻ bằng opacity 1 KHÔNG ăn: ChatCut coi 1 là mặc định (changes: [])
6  thẻ phụ đề kéo dài hơn câu ~0,1–0,4 s ⇒ ở mép b-roll bị CHỒNG 2 lớp chữ (soát thấy ở khung 302 · 400 · 712)
   cue_override không chỉnh được thời gian thẻ ⇒ KÉO b-roll khớp mốc thẻ thay vì ngược lại:
   edit_item updates: fromFrame = đầu thẻ đầu · durationInFrames = cuối thẻ cuối − đầu · playbackRate = số khung clip / durationInFrames
   (phim mẫu: 301–407 @0,8585 · 421–517 @0,8438 · 635–719 @0,8334 — zoom chậm nên không lộ)
7  refresh ⇒ preview_timeline soát khung ngay trước/sau mỗi mép b-roll (±2 khung)
```

**Khác CapCut (Owner hỏi):** phụ đề ChatCut **không phải đoạn chữ nằm trên dòng thời gian**. Nó là một lớp tự sinh từ bản bóc lời, bật/tắt bằng nút **CC ON** ở thanh công cụ dòng thời gian; sửa theo **thẻ** (lệnh `read_captions` / `edit_captions`) hoặc tab TRANSCRIPT. SKILL nên nói trước điều này, kẻo người quen CapCut tưởng phụ đề chưa được thêm.

**Lỗi bóc lời gặp lại:** thẻ «ởbuổi một Bí mật AI» dính chữ (repo đã ghi ở `mcp-call-sequence.md:37`) — sửa bằng `manage_transcript` action `fix` nếu thẻ đó cần hiện.

**Bản ra đã xuất (27/09, render trên mây 20,8 s):** `windows/ban-mau-da-ra/dien-tap-broll-dong-phu-de-broll.mp4` · md5 `29735955` · 14.955.307 byte · 960 khung / 32,04 s · `verify-export.sh` RESULT PASS (câu đã xoá dùng cụm không số «Hẹn bạn xem» để tránh M13) · soát 12 khung trên chính tệp mp4 (`windows/bang-chung/phu-de-broll-12-khung-mep.png`): mép b-roll sạch. Đề xuất chỗ đặt trong repo gốc: `assets/ban-mau-da-ra/` (cùng `-contact.png`) + 1 dòng md5 trong `references/ban-mau/README.md`.

**Vẫn thấy lỗi đã biết số 1 của repo:** khung ~850 (ngay sau chỗ cắt câu) phụ đề in sẵn lóe chữ «tối mai!» của câu đã xoá — bản Mac `5656a249` cũng có. Hướng có thể thử (CHƯA làm): bật lại thẻ phụ đề ChatCut đầu câu 14 (khung 844–869) với nền đủ rộng để che dải gốc trong vài khung đó.

---

## 10. TRẠNG THÁI MÁY THỬ SAU ĐỢT TEST + VIỆC CÒN LẠI

- **Đã cài thêm trên máy Windows** (bằng winget/pip, có đồng ý của Owner): Node.js 24.19.0 · FFmpeg 9.0.2 · Python 3.12.10 · openai-whisper 20250625 + torch 2.14.0 CPU · Pillow 12.3.0 · `node_modules` của skill (713 MB) · Chrome Headless Shell 270 MB · mô hình Whisper `small`.
- **Repo clone trên máy thử đang bẩn 2 tệp** do làm đúng README: `assets/ban-mau-da-ra/vsl-chatcut-broll-codex-contact.png` · `scripts/remotion/package-lock.json`. **Chưa khôi phục** — cần chữ "yes" của Owner để chạy `git checkout -- <2 tệp>`.
- **Quy trình A đã chạy trên Windows** (Owner duyệt «yes» 27/09): dự án ChatCut `dien-tap-windows-27-09` (`bda39c6b…`) · bản ra `xem-ket-qua/quy-trinh-a-windows.mp4` (md5 `5656a249`). Tốn khoảng 32 giây trong hạn mức 60 phút xuất miễn phí; không gọi tool sinh (không tốn credit). Có 1 bản chép phim mẫu trong thư mục Downloads của máy thử (để Owner chọn tệp khi relink).
- **Bản có phụ đề ChatCut trên b-roll đã xuất** (Owner giao 27/09): md5 `29735955`, ăn thêm khoảng 32 giây hạn mức xuất; không gọi tool sinh.
- **Đường B mới (M14):** đã render thử B-2 (IconStage có tiếng, không phụ đề) — 59 s; **CHƯA chạy phần ChatCut của B** (cần Owner duyệt tải lên).
- **Gửi agent Mac:** repo công khai `github.com/ocathanh/demo-bien-tap-video-chatcut-windows` (lịch sử gốc tới `2b39584` + thư mục `windows/`).
- **Chưa chạy trên Windows:** Quy trình C · `check-caption-band.sh` · `draw-broll.sh` (cần Codex) · `make_clusters.py` + `render.sh story`.
- **Việc tiếp theo (Owner đã giao):** cài giọng đọc tiếng Việt → làm video mới kể hành trình cài đặt này theo khuôn IconStage.
