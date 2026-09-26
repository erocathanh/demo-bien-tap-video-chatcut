# Quy trình C — ghép NGUYÊN LIỆU SẴN bằng ChatCut (máy KHÔNG có Remotion / node)

> Owner 26/09/2026: «đóng gói và xuất từng nguyên liệu để đưa skill qua máy mới không có remotion thì nó chọn bước dùng
> nguyên liệu … đưa vào chatcut làm tiếp, tránh skill bị dừng vì thiếu nguyên liệu.»
> Nguyên liệu do claude-video-studio-pm tạo lại TỪ ĐẦU ngày 26/09 (TTS Gemini → Whisper → props CÓ mặt người «--face nen-sach.mp4:150:50% 30%» như bản mẫu → render → cắt cảnh), md5 ở `assets/nguyen-lieu-video-2/MD5.txt`.

## Cửa rẽ — máy này có gì?
```
node ≥ 18 + scripts/remotion/node_modules   ⇒ Quy trình B (dựng từ kịch bản, render mới)
KHÔNG có node / npm install hỏng / không mạng ⇒ Quy trình C (tệp này): bỏ bước 2–7, dùng nguyên liệu sẵn, ghép trong ChatCut
```
Kiểm nhanh: `node -v` và `ls scripts/remotion/node_modules/remotion` — thiếu một trong hai ⇒ đi C.

## Nguyên liệu sẵn (`assets/nguyen-lieu-video-2/`)
| tệp | là gì | dùng ở bước |
|---|---|---|
| `kich-ban-18-cau.txt` | 18 câu lời nói (chữ chuẩn) | tra câu khi cần cắt |
| `tieng-video-2-moi.mp3` | tiếng đọc 66,4 s (Gemini TTS, giọng Algieba) | A1 trong ChatCut |
| `tieng-video-2-moi.json` | mốc chữ Whisper (190 chữ) | chỉ để tra; ChatCut tự bóc lại |
| `props-iconstage-moi.json` | props IconStage 18 cảnh, 1996 khung | chỉ khi có Remotion |
| `video-2-tao-lai.mp4` | bản render trọn 66,5 s (có tiếng) | đường lui: tải thẳng lên, không ghép |
| `canh-cap-1-hoi-dap.mp4` · `canh-cap-2-giao-viec.mp4` · `canh-cap-3-tu-chay.mp4` · `canh-ket-lam-chu-may.mp4` | 4 cảnh KHÔNG tiếng, cắt đúng ranh cảnh | V1 trong ChatCut |
| `ke-hoach-ghep.json` | khung đặt từng cảnh: 0 · 630 · 1314 · 1779 (dài 630 · 684 · 465 · 217) | edit_item |

## Chuỗi lệnh (đã chạy thật 26/09, dự án ChatCut `ec0a41e8`)
```
1  create_project  1080×1920 · 30 fps
2  import_media create_session → scripts/upload.sh <token> <endpoint> tieng-video-2-moi.mp3 canh-cap-1… canh-cap-2… canh-cap-3…
   (tối đa 4 tệp / lệnh) → lệnh thứ hai cho canh-ket-lam-chu-may.mp4.  Đo: 5 tệp 12 giây. mp3 được đăng ký thành .ogg — bình thường.
3  edit_item adds, MỘT lệnh, 5 mục:
   {"type":"audio","assetId":TIENG,"fromFrame":0,"trackId":"A1"}
   {"type":"video","assetId":C1,"fromFrame":0,   "durationInFrames":630,"trackId":"V1","fit":"cover"}
   {"type":"video","assetId":C2,"fromFrame":630, "durationInFrames":684,"trackId":"V1","fit":"cover"}
   {"type":"video","assetId":C3,"fromFrame":1314,"durationInFrames":465,"trackId":"V1","fit":"cover"}
   {"type":"video","assetId":C4,"fromFrame":1779,"durationInFrames":217,"trackId":"V1","fit":"cover"}
   (4 clip nối nhau trên V1 không chồng nên gửi cả lô được; A1 tự tạo khi chưa có)
4  (tuỳ chọn) read_script / apply_script trên A1 để cắt câu — cắt tiếng thì CẢNH KHÔNG TỰ CO THEO (lỗi đã biết số 4);
   muốn cắt câu thì cắt TRƯỚC ở bản render trọn `video-2-tao-lai.mp4` như Quy trình A.
5  smooth_audio → submit_export 1080p → track_export (≥10 s/lượt) → tải về → scripts/verify-export.sh <ra.mp4> "" "<câu đã xoá hoặc câu bịa>" "làm thuê cho máy"
```
Câu đối chứng dương Whisper nghe đúng: «làm thuê cho máy». Câu «tra cứu thông tin trên mạng» dùng làm câu-đã-xoá khi có cắt.

## Đường lui ngắn nhất (2 phút)
Không ghép cảnh, chỉ tải `video-2-tao-lai.mp4` lên V1 rồi xuất — vẫn là phim icon đủ tiếng. Dùng khi mạng lớp yếu.

## Muốn làm MỚI trên máy có Remotion
Quy trình B: `references/quy-trinh/video-san-khau-theo-cau.md`. Props mẫu mới: `assets/nguyen-lieu-video-2/props-iconstage-moi.json`
(render lại bằng `npx remotion render src/index.ts IconStage <ra.mp4> --props=<props> --public-dir=public --bundle-cache=false`,
nhớ chép `tieng-video-2-moi.mp3` vào `scripts/remotion/public/` trước).
