# Cài bằng tay — phần chung cho mọi máy

> Thường bạn **không cần** đọc tệp này: dán câu trong `README.md` là Claude tự làm hết. Tệp này dành cho ai muốn tự làm
> từng bước, hoặc cho Claude tra khi có bước hỏng. Mỗi bước có dòng **Kiểm** để biết đã đúng chưa.

**Làm theo hệ máy của bạn:** 👉 **[macOS](README-CAI-MOI-MAC.md)** · 👉 **[Windows](README-CAI-MOI-WINDOWS.md)**
Hai tệp đó lo phần cài phần mềm (bước 1). Các bước dưới đây giống nhau trên mọi máy.
Trên Windows, mọi lệnh ở đây chạy trong **Git Bash** (cửa sổ dòng lệnh đi kèm Git — Claude Code trên Windows cũng dùng nó), không dùng PowerShell.

## 0. Tải bộ công cụ về đúng chỗ
```bash
git clone https://github.com/erocathanh/demo-bien-tap-video-chatcut.git ~/.claude/skills/demo-bien-tap-video-chatcut
cd ~/.claude/skills/demo-bien-tap-video-chatcut
```
**Kiểm:** `ls` thấy `SKILL.md  README.md  MANIFEST.md  assets  references  scripts`.
Đã có bản cũ (trước v3.0) thì xoá thư mục cũ rồi tải lại — bản cũ trên Windows mang kiểu xuống dòng khác làm lệch mã kiểm.

## 0.5 Kiểm máy — chỉ xem, không cài gì
```bash
bash scripts/kiem-may.sh
```
In một dòng cho mỗi phần mềm (✅ có · ⚠️ đã cài nhưng cửa sổ này chưa thấy · ❌ thiếu · ➖ tuỳ chọn), kết luận máy làm được video nào,
và các dòng `CÀI:` là lệnh cài còn thiếu. **Kiểm:** mã thoát 0 = đủ hết · 1 = thiếu thứ bắt buộc · 2 = chỉ thiếu thứ tuỳ chọn.

## 1. Cài phần mềm còn thiếu
Theo tệp của hệ máy: [macOS](README-CAI-MOI-MAC.md) · [Windows](README-CAI-MOI-WINDOWS.md). Xong chạy lại `bash scripts/kiem-may.sh`.

## 2. Plugin ChatCut (để Claude điều khiển trang biên tập ChatCut)
1. Trong Claude Code gõ `/plugin`, tìm và cài **ChatCut** (nếu không thấy, thêm kho plugin của ChatCut theo hướng dẫn trên chatcut.io rồi tìm lại).
2. Gõ `/mcp` → chọn ChatCut → **Authenticate** → đăng nhập ChatCut trên trình duyệt (một lần).
3. **Mở một phiên Claude Code MỚI** — phiên mở trước lúc cài plugin không thấy công cụ ChatCut.

**Kiểm:** trong phiên mới, nhờ Claude «liệt kê dự án ChatCut của tôi» ⇒ ra danh sách (có thể rỗng), không báo lỗi 401.
⚠️ Chỉ dùng plugin. Đăng ký ChatCut bằng lệnh `claude mcp add-json` thì biên tập được nhưng **không tải phim lên được** (thiếu công cụ tải của plugin).

## 3. Bộ dựng video (Remotion)
Hai lệnh, chạy **riêng từng lệnh**. Nhờ Claude chạy thì dặn thời hạn 10 phút — lần đầu có thể quá 2 phút mặc định.
```bash
cd ~/.claude/skills/demo-bien-tap-video-chatcut/scripts/remotion
npm ci
```
```bash
cd ~/.claude/skills/demo-bien-tap-video-chatcut/scripts/remotion
bash render.sh broll
```
**Kiểm:** dòng cuối `RESULT PASS`, có 3 dòng `PASS broll-N-dong.mp4 1080x1920 frames=91/81/70`.
Lần render đầu tự tải thêm một trình duyệt ẩn (~270 MB) và phông chữ tiếng Việt — cần mạng. Lần sau không tải nữa.
Dùng `npm ci` chứ không `npm install`: `npm ci` cài đúng bản đã khoá và không sửa tệp nào của bộ công cụ.

## 4. Kiểm bộ kiểm — có cả đối chứng âm
```bash
cd ~/.claude/skills/demo-bien-tap-video-chatcut
bash scripts/verify-export.sh assets/ban-mau-da-ra/dien-tap-broll-dong.mp4 5656a249 "Hẹn bạn xem buổi hai" "gửi tặng skill"
```
**Kiểm:** `RESULT PASS`. Đã cài Whisper (công cụ nghe lại lời) thì có thêm «removed phrase not heard» và «positive control heard».

Đối chứng âm — chạy trên phim **CHƯA cắt**, câu «đã xoá» thật ra vẫn còn ⇒ **phải** ra `FAIL removed phrase still audible`:
```bash
bash scripts/verify-export.sh assets/phim-mau/phim-buoi-1-co-tieng.mp4 "" "Hẹn bạn xem buổi hai" "gửi tặng skill"
bash scripts/verify-export.sh assets/phim-mau/phim-buoi-1-co-tieng.mp4 "" "Tối nay, ở buổi một" "gửi tặng skill"
```
Hai lệnh này chỉ có nghĩa khi đã cài Whisper; thiếu Whisper thì bộ kiểm in `RESULT PASS (speech not checked: whisper missing)`.
Lần đầu Whisper tải mô hình khoảng 480 MB. Ảnh ghép khung hình của bước này ghi vào thư mục `out/`, không đụng tệp nào của bộ công cụ.
**Kiểm cuối:** `git status --short` không in dòng nào.

## 5. Làm video
Mở `SKILL.md`, bắt đầu từ bước 0. Hoặc nói với Claude: «làm Video icon kể chuyện» / «demo sửa phim bằng sửa chữ».

## Thứ KHÔNG có trong gói — bạn tự có
| cần | vì sao | nếu thiếu |
|---|---|---|
| tài khoản ChatCut | video được tải lên trang ChatCut để cắt, thêm phụ đề và xuất | chỉ dựng được phần hình icon trên máy |
| Claude Code + tài khoản | Claude gọi mọi lệnh | — |
| khoá Codex / Gemini / máy vẽ ảnh | chỉ cần khi muốn VẼ MỚI hình minh hoạ | icon và hình mẫu đã vẽ sẵn trong `assets/` |
| internet | tải bộ dựng · phông chữ · ChatCut | — |
