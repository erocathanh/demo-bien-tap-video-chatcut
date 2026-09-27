# Cài phần mềm trên macOS

> Bước chung (tải bộ công cụ · kiểm máy · plugin ChatCut · bộ dựng video · kiểm): [README-CAI-MOI.md](README-CAI-MOI.md).
> Tệp này chỉ lo **bước 1 — cài phần mềm còn thiếu** trên Mac. Chạy `bash scripts/kiem-may.sh` trước để biết thiếu gì.

## Cần gì
| phần mềm | để làm gì (nói thường) | bắt buộc? | lệnh cài | thời gian (đo) |
|---|---|---|---|---|
| Homebrew | trình cài phần mềm cho Mac | để cài các thứ dưới | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` — **bạn tự dán vào Terminal** và gõ mật khẩu máy (Claude không gõ mật khẩu thay được) | chưa đo (có sẵn trên máy thử) |
| Git | tải bộ công cụ về máy | bắt buộc | `xcode-select --install` — máy mới hiện hộp thoại cài «Command Line Tools», bấm **Install** | có sẵn trên máy thử |
| Node.js ≥ 18 | chạy xưởng dựng video + công cụ tải phim của ChatCut | bắt buộc | `brew install node` | có sẵn trên máy thử |
| FFmpeg | đọc và kiểm tra video (dài bao lâu, có tiếng không, có khung đen không) | bắt buộc | `brew install ffmpeg` | có sẵn trên máy thử |
| Python 3.8+ | công cụ phụ: chia phụ đề, làm bảng hình | bắt buộc cho «Video icon kể chuyện» | có sẵn, hoặc `brew install python` | có sẵn |
| Pillow | vẽ bảng hình có nhãn giây để soát | tuỳ chọn | `python3 -m pip install pillow` | vài giây |
| Whisper | nghe lại lời trong video để kiểm câu đã xoá (cần Python 3.10–3.13) | tuỳ chọn | `python3 -m pip install -U openai-whisper` — lệnh dài: chạy riêng, thời hạn 10 phút hoặc chạy nền | Windows đo 533 giây; lần dùng đầu tải thêm mô hình ~480 MB |

Máy Mac Intel: plugin ChatCut không kèm sẵn FFmpeg cho máy này ⇒ bắt buộc cài FFmpeg trước khi tải phim.

**Kiểm:** chạy lại `bash scripts/kiem-may.sh` ⇒ các dòng bắt buộc đều ✅.

## Mấy điều riêng của Mac
- Mở video cho người dùng xem: `open "<tệp>.mp4"`.
- Khung trình duyệt trong app Claude (để xem trang ChatCut đổi theo từng bước): **Cmd+Shift+B**.
- Tải bản xuất từ ChatCut: `curl -fsSL --create-dirs -o "out/<tên>.mp4" "<link>"` — link chỉ sống 1 ngày.
- Lệnh chạy được bằng `/bin/bash` có sẵn của Mac (bản 3.2) — không cần cài bash mới.

## Số đo trên Mac (Apple Silicon, 25–26/09/2026)
`npm ci` 10–19 giây (27/09: 10 giây với npm cache TRỐNG) · `render.sh broll` lần đầu 31 giây · `render.sh stage` 29 giây · Whisper 66 giây tiếng: 47 giây ·
`verify-export.sh` có Whisper khoảng 23 giây · «Sửa phim bằng sửa chữ» trọn lượt 2 phút 17 giây (3 clip b-roll động, 25/09; lượt dùng ảnh tĩnh cũ, đã bỏ ở v3.0, là 1 phút 30 giây).
Lượt «như người mới» 27/09 (clone vào thư mục trống → kiểm máy → npm ci → dựng b-roll → bước 4 kèm 2 đối chứng âm): **2 phút**, sổ bấm giờ `references/ban-mau/dong-ho-nguoi-moi-v3-27-09.log`.
