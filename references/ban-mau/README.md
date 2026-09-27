# Bản mẫu đã ra kết quả — «đúng» trông thế nào

Mọi đường dẫn tính từ thư mục gốc của skill (thư mục chứa `SKILL.md`). Nhận đúng tệp bằng md5 (8 ký tự đầu).

| thứ | tệp | số đo |
|---|---|---|
| **Video icon kể chuyện** — bản mẫu | `assets/ban-mau-da-ra/video-icon-ke-chuyen-chatcut-v3.mp4` | 62,98 giây · md5 **`81da0023`** · Mac 27/09: Remotion dựng hình + tiếng, ChatCut gạch 1 câu, phụ đề, xuất · verify-export PASS · bảng khung `-contact.png` cùng thư mục |
| ↳ nguyên liệu đưa lên ChatCut (không phụ đề) | `assets/nguyen-lieu-video-2/video-2-khong-phu-de.mp4` | 1996 khung · md5 `b97de04e` (dựng trên macOS 26.5 Apple Silicon) |
| ↳ bản `render.sh stage` (phụ đề in sẵn, không qua ChatCut) | `assets/nguyen-lieu-video-2/video-2-tao-lai.mp4` | 1996 khung · so bằng PSNR ≥ 40 dB, không so md5 |
| **Sửa phim bằng sửa chữ** — bản mẫu | `assets/ban-mau-da-ra/dien-tap-broll-dong.mp4` | 32,04 giây · md5 **`5656a249`** · verify-export PASS |
| ↳ biến thể phụ đề CHỈ trên b-roll (Windows 27/09) | `assets/ban-mau-da-ra/dien-tap-broll-dong-phu-de-broll.mp4` | 32,04 giây · md5 **`29735955`** · dựng trên Windows 11 x64 |
| phim nguồn (đã tải lên ChatCut) | `assets/phim-mau/phim-buoi-1-co-tieng.mp4` | 36,36 giây · 1080×1920 · md5 `1daf71fd` |
| nền sạch cùng cảnh, KHÔNG phụ đề | `assets/phim-mau/nen-sach-khong-phu-de.mp4` | 36,43 giây · md5 `41bfa445` |
| phim ngắn 3 câu để thử nhanh | `assets/phim-mau/phim-ngan-10s-3-cau.mp4` | 10,5 giây · md5 `d34e5295` (cắt 10,0–20,5 giây của phim nguồn) |
| 3 clip b-roll động (không fade) | `assets/b-roll/broll-{1,2,3}-dong.mp4` | 91 · 81 · 70 khung · md5 `945846a3` · `4ce52276` · `66b145e8` |
| 3 ảnh b-roll (Codex vẽ) | `assets/b-roll/vsl-broll-*.png` · ảnh ghép `broll-codex-3-tam.png` (thư mục này) | 1080×1920 · 0 chữ, 0 logo |
| phim buổi 1 có icon khớp lời (IconStory, `render.sh story`) | `assets/ban-mau-da-ra/phim-buoi-1-v8b-icon-khop-loi.mp4` | 36,45 giây · md5 `65e08c24` |
| sổ bấm giờ lượt diễn tập | `dong-ho-dien-tap-25-09.log` (thư mục này) | trọn lượt 1 phút 30 giây |
| sổ bấm giờ cài trên máy mới | `dong-ho-cai-may-moi-26-09.log` (thư mục này) | Mac, ghi khi thử gói trên thư mục trống (nhắc tới bản mẫu cũ đã bỏ ở v3.0) |
| sổ bấm giờ cài trên Windows | `dong-ho-cai-may-windows-27-09.log` (thư mục này) | Windows 11 x64 i9, 27/09/2026 — từng bước cài, dựng, tải lên ChatCut, kèm lỗi gặp |
| góp ý từ lượt thử Windows | `references/gop-y-windows/` | nhật ký lỗi (mã B · M · m · P), đề xuất đường B, 4 ảnh bằng chứng, bản báo lỗi tiếng Anh cho ChatCut `BAO-LOI-CHATCUT_v1.0.md` (CHƯA gửi) |

⚠️ Phim nguồn là phim **buổi 1 (24/09/2026)**: giọng nói «ở buổi một», dải chữ «BUỔI 1 · 24/09/2026».
Diễn vào ngày khác thì xem mục «Phim nguồn mang ngày cũ» trong `SKILL.md`, đừng chỉ đổi dải chữ.

📌 Render Remotion KHÔNG tất định từng byte (blur, giải mã video): render lại IconStory/IconStage có thể ra md5 khác
mà hình không đổi. So bằng PSNR hoặc mở bảng khung, đừng kết luận «hỏng» chỉ vì md5 khác. Bản ra từ ChatCut: hai lượt xuất cùng một dòng thời gian từng ra trùng md5 (25/09).

> 🛡️ 26/09/2026 (claude-video-studio-pm): 3 giây đầu của phim mẫu buổi 1 (tấm mở đầu là ảnh chụp Zoom) có ô chat hiện tên và số điện thoại người tham dự — đã CHE bằng ô đặc ở 6 tệp mp4 (phim mẫu · nền sạch · 3 bản ra · nen-sach trong scripts/remotion/public), số khung và thời lượng giữ nguyên, md5 đổi theo. Bản gốc chưa che chỉ có trên máy Owner (`~/.claude/skills/.backups/demo-chatcut-truoc-che-zoom-20260926-1639/`), KHÔNG có trong gói.
