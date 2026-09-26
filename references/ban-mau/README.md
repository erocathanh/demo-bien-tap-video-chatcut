# Bản mẫu đã ra kết quả — «đúng» trông thế nào

Mọi đường dẫn tính từ thư mục gốc của skill (thư mục chứa `SKILL.md`). Nhận đúng tệp bằng md5 (8 ký tự đầu).

| thứ | tệp | số đo |
|---|---|---|
| phim nguồn (đã tải lên ChatCut) | `assets/phim-mau/phim-buoi-1-co-tieng.mp4` | 36,36 giây · 1080×1920 · md5 `e5d5c6df` |
| nền sạch cùng cảnh, KHÔNG phụ đề | `assets/phim-mau/nen-sach-khong-phu-de.mp4` | 36,43 giây · md5 `7e274d28` |
| phim ngắn 3 câu để thử nhanh | `assets/phim-mau/phim-ngan-10s-3-cau.mp4` | 10,5 giây · md5 `d34e5295` (cắt 10,0–20,5 giây của phim nguồn) |
| **bản ra demo ChatCut (ảnh tĩnh, cũ)** | `assets/ban-mau-da-ra/vsl-chatcut-broll-codex.mp4` | 32,04 giây · md5 **`410e998a`** — hai lượt chạy ra trùng từng byte |
| **bản ra demo ChatCut (3 clip b-roll động)** | `assets/ban-mau-da-ra/dien-tap-broll-dong.mp4` | 32,04 giây · md5 **`a5991648`** · verify-export PASS |
| 3 clip b-roll động (không fade) | `assets/b-roll/broll-{1,2,3}-dong.mp4` | 91 · 81 · 70 khung · md5 `945846a3` · `4ce52276` · `66b145e8` |
| 3 ảnh b-roll (Codex vẽ) | `assets/b-roll/vsl-broll-*.png` | 1080×1920 · 0 chữ, 0 logo |
| phim buổi 1 có icon khớp lời (IconStory) | `assets/ban-mau-da-ra/phim-buoi-1-v8b-icon-khop-loi.mp4` | 36,45 giây · md5 `bbb99d8f` |
| video sân khấu theo câu (IconStage) | `assets/ban-mau-da-ra/video-2-ba-cap-do-ai-v03b.mp4` | 65,34 giây · md5 `a6dbeb1b` · 18 câu |
| bảng khung tương ứng | `assets/ban-mau-da-ra/*-contact.png` · `v03*.png` (1 khung/giây) | mở ra nhìn để biết bố cục đúng |
| ảnh ghép 10 khung bản ra demo | `khung-ban-mau-vsl.png` (thư mục này) | |
| ảnh ghép 3 b-roll | `broll-codex-3-tam.png` (thư mục này) | |
| sổ bấm giờ lượt diễn tập | `dong-ho-dien-tap-25-09.log` (thư mục này) | trọn lượt 1 phút 30 giây |
| sổ bấm giờ cài trên máy mới | `dong-ho-cai-may-moi-26-09.log` (thư mục này) | ghi khi thử gói trên thư mục trống |

⚠️ Phim nguồn là phim **buổi 1 (24/09/2026)**: giọng nói «ở buổi một», dải chữ «BUỔI 1 · 24/09/2026».
Diễn vào ngày khác thì xem mục «Phim nguồn mang ngày cũ» trong `SKILL.md`, đừng chỉ đổi dải chữ.

📌 Render Remotion KHÔNG tất định từng byte (blur, giải mã video): render lại IconStory/IconStage có thể ra md5 khác
mà hình không đổi. So bằng PSNR hoặc mở bảng khung, đừng kết luận «hỏng» chỉ vì md5 khác. Bản ra từ ChatCut thì trùng md5.
