# demo-bien-tap-video-chatcut

> 🤖 AI agent: đọc mục **«Dành cho AI agent»** ở cuối tệp này trước khi làm gì khác.

Làm video dọc 1080×1920 bằng cách **nói với Claude**. Bạn không cần biết dựng phim, không cần mở phần mềm nào khác.

| Bạn sẽ làm được | Trông như thế nào (bản mẫu có sẵn trong gói) | Mất bao lâu |
|---|---|---|
| **Video icon kể chuyện** — giọng đọc + mỗi câu một cảnh icon + phụ đề | `assets/ban-mau-da-ra/video-icon-ke-chuyen-chatcut-v3.mp4` (63 giây) | lần sau khoảng 4 phút (dựng 30–70 giây + ChatCut khoảng 3 phút). Lần đầu thêm phần cài đặt — ước 10–15 phút, cộng từ các bước đã đo, **chưa đo trọn một lượt từ máy trống** |
| **Sửa phim bằng sửa chữ** — gạch một câu là phim tự cắt câu đó, chèn hình minh hoạ đúng câu đang nói | `assets/ban-mau-da-ra/dien-tap-broll-dong.mp4` (32 giây) | khoảng 2 phút 17 giây (đo 25/09, Mac) |

## Ba bước

**1. Cài Claude Code** (trợ lý AI chạy trên máy tính của bạn) — làm theo hướng dẫn chính thức: https://docs.claude.com/claude-code
Có tài khoản **ChatCut** (trang biên tập video trên mạng, https://chatcut.io). Tài khoản miễn phí là đủ để thử.

**2. Mở Claude Code và dán đúng câu này:**
```text
Cài skill này và chạy thử cho tôi: https://github.com/erocathanh/demo-bien-tap-video-chatcut
```

**3. Làm theo lời Claude.** Claude tự xem máy bạn còn thiếu gì, hỏi bạn **một lần** trước khi cài, rồi làm tiếp.
Trong lúc chờ, Claude mở bản mẫu cho bạn xem trước. Những việc **bạn phải tự làm** (Claude sẽ nói đúng lúc):
- bấm **Yes / Cho phép** mỗi khi Claude Code hỏi có cho chạy lệnh không, và khi Windows hỏi quyền cài;
- **gõ** hai dòng cài plugin ChatCut mà Claude đưa, rồi gõ `/mcp` → chọn ChatCut → **Authenticate** → đăng nhập ChatCut trên trình duyệt;
- máy **Mac mới chưa có Homebrew**: dán một lệnh vào Terminal và gõ mật khẩu máy (Claude không gõ mật khẩu thay được);
- có thể phải **tắt hẳn Claude rồi mở lại** một lần sau khi cài. Mở lại xong thì **dán lại đúng câu ở bước 2** (dùng Claude Code trong Terminal thì gõ `claude --continue`);
- **Windows:** với video có tiếng, bấm **«Click to relink»** trên trang ChatCut một lần rồi dán đường dẫn Claude đã chép sẵn (lỗi của plugin ChatCut trên Windows).

## Muốn tự làm từng bước?
- Cài đặt bằng tay, có dòng «Kiểm» sau mỗi bước: **[README-CAI-MOI.md](README-CAI-MOI.md)** (dẫn sang bản [macOS](README-CAI-MOI-MAC.md) hoặc [Windows](README-CAI-MOI-WINDOWS.md)).
- Cách Claude làm từng video, số đo, lỗi đã biết: **[SKILL.md](SKILL.md)**. Danh sách tệp kèm mã kiểm (md5): [MANIFEST.md](MANIFEST.md).

## Máy dùng được
macOS (Apple Silicon hoặc Intel) · Windows 10/11 bản x64 · Linux. Windows trên chip ARM (Snapdragon) chỉ làm được «Sửa phim bằng sửa chữ».
Cần khoảng 3 GB đĩa trống và mạng internet. Không cần khoá API nào: icon và hình minh hoạ đã vẽ sẵn trong gói.

## Giấy phép
© Eroca Thanh. Dùng để học. Phim mẫu có giọng người thật — chỉ dùng để học, không đăng lại, không cắt ghép đưa lên mạng.

---

## 🤖 Dành cho AI agent — đọc hết mục này trước khi làm gì khác
Người dùng có thể chỉ gõ «Cài skill này và chạy thử cho tôi» kèm link repo này. Như vậy là đủ:
1. **Tải về đúng chỗ** (lệnh chạy trong tool Bash — trên Windows đó là Git Bash, nên dùng `~`, **không** dùng `%USERPROFILE%`):
   `git clone https://github.com/erocathanh/demo-bien-tap-video-chatcut.git ~/.claude/skills/demo-bien-tap-video-chatcut`
   Trên Windows thư mục đó là `C:\Users\<tên>\.claude\skills\demo-bien-tap-video-chatcut` khi nhìn trong File Explorer. KHÔNG đặt trong OneDrive, Desktop hay Documents.
   Máy không có git thì tải `…/archive/refs/heads/main.zip` và giải nén vào cùng chỗ đó.
2. **Kiểm máy trước mọi việc:** `bash ~/.claude/skills/demo-bien-tap-video-chatcut/scripts/kiem-may.sh` (chỉ đọc, không cài gì). Đọc các dòng `CÀI:` rồi hỏi người dùng **MỘT câu gom**: thiếu mấy thứ, cài mất bao lâu, họ phải bấm gì. Dòng nào ghi «bạn tự dán vào Terminal» thì đưa lệnh cho người dùng, đừng tự chạy. Cài xong nếu script báo «cửa sổ Claude này chưa thấy» thì bảo người dùng tắt hẳn Claude, mở lại, **dán lại câu ban đầu**; rồi chạy lại `kiem-may.sh`.
3. **Nói lời thường** trước và sau mỗi bước: đang làm gì · để làm gì · bao lâu · người dùng có phải bấm gì không. Không dùng từ chuyên môn, không dán log cho người dùng (luật đầy đủ: mục «Thuyết minh» trong `SKILL.md`).
4. **Plugin ChatCut:** chưa có thì đưa người dùng hai dòng để **họ tự gõ**: `/plugin marketplace add ChatCut-Inc/agent-plugin` rồi `/plugin install chatcut@chatcut-inc`, rồi `/mcp` → ChatCut → **Authenticate** và đăng nhập trên trình duyệt. Công cụ ChatCut chưa hiện thì bảo người dùng mở phiên Claude mới và dán lại câu ban đầu.
5. **Lệnh dài** (`npm ci`, lần render đầu tải thêm ~270 MB, `pip install openai-whisper` khoảng 9 phút) chạy với thời hạn **10 phút** (600000 ms) hoặc chạy nền, mỗi lệnh một lần gọi riêng — không gộp bằng `&&`.
6. Trong lúc cài, **mở bản mẫu** `assets/ban-mau-da-ra/video-icon-ke-chuyen-chatcut-v3.mp4` cho người dùng xem trước.
7. Rồi đọc `SKILL.md` từ bước 0 và làm **«Video icon kể chuyện»** (mặc định), hoặc «Sửa phim bằng sửa chữ» nếu người dùng muốn.
