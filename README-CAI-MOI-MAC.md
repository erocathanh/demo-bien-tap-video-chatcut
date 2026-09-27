# Cài phần mềm trên macOS

> Bước chung (tải bộ công cụ · kiểm máy · plugin ChatCut · bộ dựng video · kiểm): [README-CAI-MOI.md](README-CAI-MOI.md).
> Tệp này chỉ lo **bước 1 — cài phần mềm còn thiếu** trên Mac. Chạy `bash scripts/kiem-may.sh` trước để biết thiếu gì.

## Cần gì
| phần mềm | để làm gì (nói thường) | bắt buộc? | lệnh cài | thời gian (đo) |
|---|---|---|---|---|
| Homebrew | trình cài phần mềm cho Mac | để cài các thứ dưới | theo https://brew.sh | vài phút |
| Git | tải bộ công cụ về máy | bắt buộc | `xcode-select --install` (thường đã có) | có sẵn trên máy thử |
| Node.js ≥ 18 | chạy xưởng dựng video + công cụ tải phim của ChatCut | bắt buộc | `brew install node` | có sẵn trên máy thử |
| FFmpeg | đọc và kiểm tra video (dài bao lâu, có tiếng không, có khung đen không) | bắt buộc | `brew install ffmpeg` | có sẵn trên máy thử |
| Python 3.8+ | công cụ phụ: chia phụ đề, làm bảng hình | bắt buộc cho «Video icon kể chuyện» | có sẵn, hoặc `brew install python` | có sẵn |
| Pillow | vẽ bảng hình có nhãn giây để soát | tuỳ chọn | `python3 -m pip install pillow` | vài giây |
| Whisper | nghe lại lời trong video để kiểm câu đã xoá | tuỳ chọn | `python3 -m pip install -U openai-whisper` | vài phút + lần đầu tải mô hình ~480 MB |

Máy Mac Intel: plugin ChatCut không kèm sẵn FFmpeg cho máy này ⇒ bắt buộc cài FFmpeg trước khi tải phim.

**Kiểm:** chạy lại `bash scripts/kiem-may.sh` ⇒ các dòng bắt buộc đều ✅.

## Mấy điều riêng của Mac
- Mở video cho người dùng xem: `open "<tệp>.mp4"`.
- Khung trình duyệt trong app Claude (để xem trang ChatCut đổi theo từng bước): **Cmd+Shift+B**.
- Tải bản xuất từ ChatCut: `curl -fsSL --create-dirs -o "out/<tên>.mp4" "<link>"` — link chỉ sống 1 ngày.
- Lệnh chạy được bằng `/bin/bash` có sẵn của Mac (bản 3.2) — không cần cài bash mới.

## Số đo trên Mac (Apple Silicon, 25–26/09/2026)
`npm ci` 19 giây (npm cache sẵn) · `render.sh broll` lần đầu 31 giây · `render.sh stage` 29 giây · Whisper 66 giây tiếng: 47 giây ·
`verify-export.sh` có Whisper khoảng 23 giây · «Sửa phim bằng sửa chữ» trọn lượt 1 phút 30 giây – 2 phút 17 giây.
