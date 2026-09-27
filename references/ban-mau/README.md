# Bản mẫu đã ra kết quả — «đúng» trông thế nào

Mọi đường dẫn tính từ thư mục gốc của skill (thư mục chứa `SKILL.md`). Nhận đúng tệp bằng md5 (8 ký tự đầu).

| thứ | tệp | số đo |
|---|---|---|
| phim nguồn (đã tải lên ChatCut) | `assets/phim-mau/phim-buoi-1-co-tieng.mp4` | 36,36 giây · 1080×1920 · md5 `1daf71fd` |
| nền sạch cùng cảnh, KHÔNG phụ đề | `assets/phim-mau/nen-sach-khong-phu-de.mp4` | 36,43 giây · md5 `41bfa445` |
| phim ngắn 3 câu để thử nhanh | `assets/phim-mau/phim-ngan-10s-3-cau.mp4` | 10,5 giây · md5 `d34e5295` (cắt 10,0–20,5 giây của phim nguồn) |
| **bản ra demo ChatCut (ảnh tĩnh, cũ)** | `assets/ban-mau-da-ra/vsl-chatcut-broll-codex.mp4` | 32,04 giây · md5 **`46c7b4d5`** — hai lượt chạy ra trùng từng byte |
| **bản ra demo ChatCut (3 clip b-roll động)** | `assets/ban-mau-da-ra/dien-tap-broll-dong.mp4` | 32,04 giây · md5 **`5656a249`** · verify-export PASS |
| **bản ra demo ChatCut + phụ đề CHỈ trên b-roll** (Windows 27/09) | `assets/ban-mau-da-ra/dien-tap-broll-dong-phu-de-broll.mp4` | 32,04 giây · md5 **`29735955`** · Quy trình A + phụ đề ChatCut chỉ trên b-roll, dựng trên Windows 11 x64 · bảng khung `-contact.png` cùng thư mục |
| 3 clip b-roll động (không fade) | `assets/b-roll/broll-{1,2,3}-dong.mp4` | 91 · 81 · 70 khung · md5 `945846a3` · `4ce52276` · `66b145e8` |
| 3 ảnh b-roll (Codex vẽ) | `assets/b-roll/vsl-broll-*.png` | 1080×1920 · 0 chữ, 0 logo |
| phim buổi 1 có icon khớp lời (IconStory) | `assets/ban-mau-da-ra/phim-buoi-1-v8b-icon-khop-loi.mp4` | 36,45 giây · md5 `65e08c24` |
| video sân khấu theo câu (IconStage) | `assets/ban-mau-da-ra/video-2-ba-cap-do-ai-v03b.mp4` | 65,34 giây · md5 `a6dbeb1b` · 18 câu |
| bảng khung tương ứng | `assets/ban-mau-da-ra/*-contact.png` · `v03*.png` (1 khung/giây) | mở ra nhìn để biết bố cục đúng |
| ảnh ghép 10 khung bản ra demo | `khung-ban-mau-vsl.png` (thư mục này) | |
| ảnh ghép 3 b-roll | `broll-codex-3-tam.png` (thư mục này) | |
| sổ bấm giờ lượt diễn tập | `dong-ho-dien-tap-25-09.log` (thư mục này) | trọn lượt 1 phút 30 giây |
| sổ bấm giờ cài trên máy mới | `dong-ho-cai-may-moi-26-09.log` (thư mục này) | ghi khi thử gói trên thư mục trống |
| sổ bấm giờ cài trên Windows | `dong-ho-cai-may-windows-27-09.log` (thư mục này) | Windows 11 x64 i9, 27/09/2026 — từng bước cài, dựng, tải lên ChatCut, kèm lỗi gặp |
| góp ý từ lượt thử Windows | `references/gop-y-windows/` | nhật ký lỗi (mã B · M · m · P), đề xuất đường B, 4 ảnh bằng chứng |

⚠️ Phim nguồn là phim **buổi 1 (24/09/2026)**: giọng nói «ở buổi một», dải chữ «BUỔI 1 · 24/09/2026».
Diễn vào ngày khác thì xem mục «Phim nguồn mang ngày cũ» trong `SKILL.md`, đừng chỉ đổi dải chữ.

📌 Render Remotion KHÔNG tất định từng byte (blur, giải mã video): render lại IconStory/IconStage có thể ra md5 khác
mà hình không đổi. So bằng PSNR hoặc mở bảng khung, đừng kết luận «hỏng» chỉ vì md5 khác. Bản ra từ ChatCut thì trùng md5.

> 🛡️ 26/09/2026 (claude-video-studio-pm): 3 giây đầu của phim mẫu buổi 1 (tấm mở đầu là ảnh chụp Zoom) có ô chat hiện tên và số điện thoại người tham dự — đã CHE bằng ô đặc ở 6 tệp mp4 (phim mẫu · nền sạch · 3 bản ra · nen-sach trong scripts/remotion/public), số khung và thời lượng giữ nguyên, md5 đổi theo. Bản gốc chưa che chỉ có trên máy Owner (`~/.claude/skills/.backups/demo-chatcut-truoc-che-zoom-20260926-1639/`), KHÔNG có trong gói.
