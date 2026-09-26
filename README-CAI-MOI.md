# Cài skill `demo-bien-tap-video-chatcut` trên máy mới — từ số 0

Làm lần lượt từ trên xuống. Mỗi bước có dòng **Kiểm** để biết đã đúng hay chưa. Máy thử: macOS (Apple Silicon hoặc Intel).
Trên Linux các bước giống hệt, chỉ khác lệnh cài (`apt` thay `brew`).

## 0. Giải nén vào chỗ Claude Code đọc skill
```bash
mkdir -p ~/.claude/skills
cd ~/.claude/skills/demo-bien-tap-video-chatcut
```
**Kiểm:** `ls` thấy `SKILL.md  README-CAI-MOI.md  MANIFEST.md  assets  references  scripts`.
Muốn thử mà chưa cài hẳn thì giải nén vào thư mục bất kỳ — mọi script tự tìm đường theo chỗ nó nằm, không cần đường dẫn cố định.

## 1. Công cụ dòng lệnh
```bash
# Homebrew (bỏ qua nếu đã có): https://brew.sh
brew install node ffmpeg        # node ≥ 18 · ffmpeg kèm ffprobe
pip3 install -U openai-whisper  # TUỲ CHỌN — để verify-export nghe lại lời và để lấy mốc từng chữ
```
**Kiểm:**
```bash
node -v        # v18 trở lên
ffprobe -version | head -1
whisper --help | head -1   # nếu đã cài
```

## 2. Claude Code + plugin ChatCut (phần sửa phim bằng sửa chữ)
1. Cài Claude Code: https://docs.claude.com/claude-code — đăng nhập tài khoản của bạn.
2. Nối ChatCut vào Claude Code — chọn MỘT trong hai đường:
   - cài plugin ChatCut trong Claude Code (`/plugin`, tìm «chatcut») — plugin đăng ký máy chủ MCP `plugin:chatcut:chatcut`; hoặc
   - đăng ký thẳng máy chủ MCP ở phạm vi người dùng (lệnh theo tài liệu của plugin ChatCut):
     ```bash
     claude mcp add-json --scope user chatcut '{"type":"http","url":"https://api.chatcut.io/api/external-mcp/mcp","oauth_resource":"https://api.chatcut.io/api/external-mcp/mcp","headers":{"x-chatcut-mcp-client":"claude_code","x-chatcut-mcp-surface":"embedded-preview"}}'
     ```
   Đã có một trong hai thì đừng thêm cái kia (hai bản đăng ký trùng nhau).
3. Gõ `/mcp` → chọn ChatCut → **Authenticate** → đăng nhập tài khoản ChatCut trên trình duyệt (một lần).
4. **Mở một phiên Claude Code MỚI** sau khi cài plugin — phiên mở trước lúc cài KHÔNG thấy tool.

**Kiểm:** trong phiên mới, nhờ Claude «liệt kê dự án ChatCut của tôi» ⇒ ra danh sách (có thể rỗng), không ra lỗi 401.
Đối chứng: ở một phiên đã mở TRƯỚC khi cài plugin, cùng câu đó sẽ không tìm thấy tool — đúng như thế là máy đang nói thật.

## 3. Remotion (phần dựng icon / b-roll động / sân khấu theo câu)
```bash
cd ~/.claude/skills/demo-bien-tap-video-chatcut/scripts/remotion
npm install              # tải remotion 4.0.471 + react 19 — khoảng 1–3 phút, cần mạng
bash render.sh broll     # render 3 clip b-roll động từ 3 ảnh mẫu
```
**Kiểm:** dòng cuối in `RESULT PASS`, và có 3 dòng `PASS broll-N-dong.mp4 1080x1920 frames=91/81/70`.
Lần render đầu tải thêm Chrome headless cho Remotion (tự động) và font Be Vietnam Pro từ Google Fonts — cần mạng.
Muốn thử thêm: `bash render.sh stage` (video 65 giây, khoảng 35 giây render) · `bash render.sh story` · `bash render.sh all`.
Tệp ra nằm ở `scripts/remotion/out/`. So với bản mẫu trong `assets/ban-mau-da-ra/` bằng mắt (render Remotion không trùng md5 từng byte).

## 4. Kiểm bộ đo trên một bản ra có sẵn
```bash
cd ~/.claude/skills/demo-bien-tap-video-chatcut
bash scripts/verify-export.sh assets/ban-mau-da-ra/vsl-chatcut-broll-codex.mp4 46c7b4d5 \
  "Hẹn bạn xem buổi hai" "gửi tặng skill"
```
**Kiểm:** `RESULT PASS` (có whisper thì thêm dòng «removed phrase not heard» và «positive control heard»).
Đối chứng âm: đổi câu thứ ba thành một câu CÒN trong phim, ví dụ `"gửi tặng skill"` ⇒ phải ra `RESULT FAIL`.

## 5. Chạy demo
Mở `SKILL.md`, làm theo mục «① Chuẩn bị» rồi «② Gõ gì». Câu mẫu (thay đường dẫn):
```
Chạy skill demo-bien-tap-video-chatcut. Phim: assets/phim-mau/phim-buoi-1-co-tieng.mp4, tôi đồng ý tải lên ChatCut.
Xoá câu «Hẹn bạn xem buổi hai Bí mật AI cùng Thanh tối mai».
Chèn 3 clip b-roll động trong assets/b-roll/ vào 3 câu «Nạp bản sắc thương hiệu», «Giao AI xử lý tệp», «Phân tích khảo sát».
Xuất 1080×1920 rồi mở phim cho tôi xem.
```

## Thứ KHÔNG có trong gói — bạn tự có
| cần | vì sao | nếu thiếu |
|---|---|---|
| tài khoản ChatCut | phim được tải lên máy chủ của họ để biên tập | không chạy được phần ①–② của SKILL.md; phần Remotion vẫn chạy |
| Claude Code + tài khoản | máy gọi các lệnh | — |
| khoá Codex / Gemini / máy vẽ ảnh | chỉ cần khi muốn VẼ MỚI ảnh b-roll hoặc icon | icon và b-roll mẫu đã vẽ sẵn trong `assets/` — không cần khoá để chạy demo |
| internet | npm install · font · ChatCut | Remotion render lại được khi offline sau lần đầu (font đã tải) — CHƯA đo |

## Lấy gói từ GitHub (từ 26/09/2026)
Kho: `github.com/erocathanh/demo-bien-tap-video-chatcut` (CÔNG KHAI từ 26/09/2026 theo quyết của chủ phim). Phim mẫu có mặt và giọng người thật: chỉ dùng để học, không đăng lại.
```bash
git clone https://github.com/erocathanh/demo-bien-tap-video-chatcut.git ~/.claude/skills/demo-bien-tap-video-chatcut
```
Máy **chỉ có ChatCut, chưa có node/Remotion**: vẫn chạy được demo ngay — đi **Quy trình C** (`references/quy-trinh/ghep-nguyen-lieu-san-chatcut.md`):
nguyên liệu đã dựng sẵn ở `assets/nguyen-lieu-video-2/` (tiếng · 4 cảnh icon · bản render trọn), chỉ tải lên ChatCut và ghép.
Cài Remotion sau (`cd scripts/remotion && npm install`) thì `bash render.sh stage` ra đúng video mẫu 26/09 (md5 `182cc1e4`, tất định giữa các lượt).
