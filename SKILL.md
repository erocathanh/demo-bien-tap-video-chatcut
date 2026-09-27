---
name: demo-bien-tap-video-chatcut
description: Làm video dọc 1080×1920 bằng cách nói với Claude, cho người mới tinh trên macOS hoặc Windows. Hai video - «Video icon kể chuyện» (giọng đọc + mỗi câu một cảnh icon dựng bằng Remotion, rồi ChatCut bóc lời, thêm phụ đề, xuất) và «Sửa phim bằng sửa chữ» (ChatCut qua MCP - gạch một câu trong bản chữ là phim tự cắt câu đó, chèn b-roll động đúng câu đang nói). Gói tự đủ - phim mẫu, icon, b-roll, bộ dựng Remotion, script tự kiểm máy, hướng dẫn cài Mac/Windows. LUÔN trigger khi người dùng nói "cài skill này và chạy thử", "video icon kể chuyện", "demo tạo video có remotion icon", "tạo video icon", "video icon 3 cấp độ AI", "sửa phim bằng sửa chữ", "demo biên tập video", "demo chatcut", "diễn tập demo chatcut", "demo-bien-tap-video-chatcut", "cài skill chatcut máy mới". KHÔNG dùng cho - sinh video mới bằng máy tạo video, vẽ ảnh bằng ChatCut, OpenChatCut bản nguồn mở.
---

# demo-bien-tap-video-chatcut — làm video bằng cách nói với Claude

> 👤 **Phụ trách:** claude-video-ai-builder · 📅 **Tạo:** 2026-09-25 · 🔄 **Bản:** v3.0
> Mọi đường dẫn tính từ thư mục chứa tệp này (gọi là `$SKILL_DIR`). Người dùng đọc `README.md`; tệp này là việc của Claude.

## 🗣️ Thuyết minh — áp cho MỌI bước (đọc trước tiên)
```text
Trước MỖI bước cài đặt hoặc chạy, nói 1–2 câu LỜI THƯỜNG, đủ 4 ý:
  1. Đang làm gì      (tên việc bằng lời thường, không phải tên lệnh)
  2. Để làm gì        (lợi ích cho người dùng)
  3. Mất bao lâu      (số đo thật ở bảng dưới; chưa đo thì nói «chưa đo»)
  4. Bạn có phải làm gì không (bấm Yes, đăng nhập, thoát app…) — không cần thì nói rõ «bạn không cần làm gì»
Sau MỖI bước: một câu kết quả — «xong» / «chưa xong, vì …, bước tiếp theo là …».
KHÔNG dùng từ chuyên môn (npm, PATH, ffprobe, render, CRLF, MCP, props…). Buộc phải nhắc tên công cụ thì giải thích trong ngoặc
ngay lần đầu, ví dụ «FFmpeg (bộ công cụ đọc và kiểm tra video)».
Bộ kiểm báo lỗi: nói TRƯỚC là video có hỏng hay không, rồi mới nói cách sửa. Không dán nguyên khối log — tóm lại bằng lời, log để trong tệp.
```
Câu mẫu: kiểm máy «Tôi xem máy anh đã đủ đồ nghề làm video chưa. Chỉ xem, không cài gì. Khoảng 10 giây.» ·
cài Node.js «Tôi cài Node.js — phần mềm giúp máy chạy xưởng dựng video. Windows sẽ hỏi quyền, anh bấm Yes. Khoảng 30 giây.» ·
lần dựng đầu «Lần đầu dựng, máy tải thêm một trình duyệt ẩn để vẽ từng khung hình (270 MB, khoảng 2 phút) — lần sau không tải nữa.» ·
bộ kiểm báo sai «Bộ kiểm báo chưa đạt, nhưng phim thật ra đúng — công cụ kiểm đọc nhầm. Tôi đã kiểm lại cách khác: đạt.»

## Bước 0 — Claude tự làm trước mọi việc
```
1. bash scripts/kiem-may.sh              chỉ đọc, ~10 giây. Mã thoát 0 đủ · 1 thiếu bắt buộc · 2 chỉ thiếu tuỳ chọn.
2. Có dòng «CÀI:» ⇒ hỏi người dùng MỘT câu gom, ví dụ:
     «Máy anh còn thiếu 3 phần mềm (Node.js, FFmpeg, Python), cài khoảng 5 phút. Windows sẽ hỏi quyền — anh bấm Yes. Tôi cài nhé?»
   Chỉ thiếu thứ tuỳ chọn (Whisper, Pillow) ⇒ hỏi có muốn cài không, nói rõ bỏ qua vẫn làm được video.
3. Trong lúc cài: mở bản mẫu cho người dùng xem — «đây là thứ anh sẽ tự làm được sau khoảng 10 phút»
     macOS  open "assets/ban-mau-da-ra/video-2-tao-lai-ghep-chatcut-v02.mp4"
     Windows start "" "$(cygpath -w assets/ban-mau-da-ra/video-2-tao-lai-ghep-chatcut-v02.mp4)"
4. Cài xong mà kiem-may.sh báo «ĐÃ CÀI nhưng cửa sổ Claude này chưa thấy» ⇒ bảo người dùng tắt HẲN Claude, mở lại, gõ «tiếp tục»;
   rồi chạy lại kiem-may.sh.
5. Thiếu plugin ChatCut ⇒ hướng dẫn: /plugin → cài ChatCut → /mcp → ChatCut → Authenticate → mở phiên Claude mới.
6. Bộ dựng video chưa cài ⇒ cd scripts/remotion && npm ci   (lệnh riêng, thời hạn 600000 ms)
   rồi bash scripts/remotion/render.sh broll   (lệnh riêng, thời hạn 600000 ms) ⇒ RESULT PASS.
```
Lệnh cài từng hệ: [README-CAI-MOI-MAC.md](README-CAI-MOI-MAC.md) · [README-CAI-MOI-WINDOWS.md](README-CAI-MOI-WINDOWS.md). Không cài gì khi người dùng chưa đồng ý.

## Nền tảng
| | macOS | Windows 10/11 |
|---|---|---|
| chạy lệnh | Terminal / tool Bash (`/bin/bash` 3.2 là đủ) | Git Bash (tool Bash của Claude Code). Không dùng PowerShell cho lệnh bash |
| gọi Python | `bash scripts/py.sh <script.py> …` (tự chọn Python thật, bật UTF-8) | như Mac — `python3` trên Windows thường chỉ là lối tắt Microsoft Store |
| mở video | `open "<tệp>"` | `start "" "$(cygpath -w "<tệp>")"` |
| khung trình duyệt trong app Claude | Cmd+Shift+B | Ctrl+Shift+B |
| cài xong | thường dùng ngay | **tắt hẳn Claude rồi mở lại** (cửa sổ cũ không thấy phần mềm mới) |
| tải phim có tiếng lên ChatCut | tự động | có thể phải bấm «Click to relink» một lần (lỗi plugin P5) — `upload.sh` tự chép phim ra Downloads + chép đường dẫn, xem mục «Sửa phim bằng sửa chữ» ④ |
| bộ dựng video | Apple Silicon và Intel | chỉ x64 (Windows ARM: không có bộ dựng ⇒ chỉ làm «Sửa phim bằng sửa chữ») |
Mọi script `.sh` chạy được trên cả hai hệ; công cụ trên Windows in xuống dòng kiểu CRLF nên script luôn bỏ ký tự `\r` trước khi so.

## Hai video làm được
| tên | nói với Claude | bản mẫu | thời gian |
|---|---|---|---|
| **Video icon kể chuyện** (mặc định) | «demo tạo video có remotion icon» / «làm video icon kể chuyện» | `assets/ban-mau-da-ra/video-2-tao-lai-ghep-chatcut-v02.mp4` | dựng 30–70 giây + ChatCut khoảng 2–3 phút |
| **Sửa phim bằng sửa chữ** | «demo sửa phim bằng sửa chữ» | `assets/ban-mau-da-ra/dien-tap-broll-dong.mp4` (md5 `5656a249`) | 1 phút 30 giây – 2 phút 17 giây |
| Video icon có mặt bạn (nâng cao) | cần bạn tự quay video dọc đọc kịch bản | — | xem `references/quy-trinh/video-san-khau-theo-cau.md` nhánh «có mặt bạn» |

## 🔴 Ba chốt cứng (mọi video)
1. **Video ĐI LÊN MÁY CHỦ ChatCut.** Video có mặt hoặc giọng người thật ⇒ hỏi chủ video **đúng một câu** trước lượt tải đầu
   (câu lệnh đã có chữ «đồng ý tải lên» thì khỏi hỏi). Video mẫu «Video icon kể chuyện» dùng giọng AI, cảnh minh hoạ nhìn từ phía sau.
2. **Không gọi nhóm SINH của ChatCut** (`video-gen` · `image-gen` · `voice` · `music` · `digital-human` · `video-translation`) — tốn credit.
   Tải lên, bóc lời, cắt, phụ đề, xuất: không tốn credit (`references/nguon-chatcut-docs.md`).
3. **Video của người khác không lên ChatCut.** Chỉ dùng video người dùng có quyền.

---

## Video icon kể chuyện — Remotion dựng hình, ChatCut biên tập
Remotion (bộ dựng video trên máy) chỉ làm **hình + tiếng**, **không phụ đề**. Cắt câu, phụ đề, làm mượt tiếng, xuất đều làm trong ChatCut —
phụ đề chỉ có MỘT lớp, sinh từ bản bóc lời nên sửa được bằng chữ.
```
1  bash scripts/remotion/render.sh stage-chatcut          (thời hạn 600000 ms) ⇒ scripts/remotion/out/video-2-khong-phu-de.mp4
                                                           1996 khung · có tiếng · không chữ phụ đề ⇒ RESULT PASS
   Máy không dựng được (Windows ARM, npm hỏng, không mạng) ⇒ dùng bản dựng sẵn assets/nguyen-lieu-video-2/video-2-khong-phu-de.mp4
2  Skill chatcut:chatcut-plugin-basics-claude (một lần mỗi phiên)
3  create_project → manage_timelines update 1080×1920       (🔴 dự án mới mặc định NGANG)
4  import_media create_session → bash scripts/upload.sh <token> <endpoint> <video-2-khong-phu-de.mp4>
5  edit_item adds [{"type":"video","assetId":A,"fromFrame":0,"trackId":"V1","fit":"cover"}]
6  (tuỳ chọn) read_script → apply_script gạch ~~câu~~ ⇒ hình tự cắt theo tiếng vì hình và tiếng nằm chung một clip
7  edit_captions enable ⇒ set_sources {"sources":[{"trackId":"V1"}]} ⇒ refresh
8  smooth_audio → submit_export {"format":"video","resolution":"1080p"} → track_export (hỏi lại mỗi ≥ 10 giây)
9  curl -fsSL --create-dirs -o "out/<tên>.mp4" "<downloadUrl>"   (link sống 1 ngày)
10 bash scripts/verify-export.sh out/<tên>.mp4 "" "<câu đã xoá, nếu có>" "làm thuê cho máy"  ⇒ RESULT PASS · mở video cho người dùng xem
```
Câu Whisper nghe đúng để làm đối chứng dương: «làm thuê cho máy». Câu dễ gạch khi thử: «Nó giống như việc bạn tự tra cứu thông tin trên mạng».
Tự làm video mới từ kịch bản của mình (TTS → mốc chữ → kế hoạch hình → icon → props → dựng): `references/quy-trinh/video-san-khau-theo-cau.md`.

---

## Sửa phim bằng sửa chữ — ChatCut qua MCP
**Câu người diễn gõ** (thay đường dẫn cho đúng máy):
```
Chạy skill demo-bien-tap-video-chatcut. Phim: <SKILL_DIR>/assets/phim-mau/phim-buoi-1-co-tieng.mp4, tôi đồng ý tải lên ChatCut.
Xoá câu «Hẹn bạn xem buổi hai Bí mật AI cùng Thanh tối mai».
Chèn 3 clip b-roll động trong <SKILL_DIR>/assets/b-roll/ vào 3 câu «Nạp bản sắc thương hiệu», «Giao AI xử lý tệp», «Phân tích khảo sát».
Xuất 1080×1920 rồi mở phim cho tôi xem.
```
**Claude làm đúng chuỗi này** — tham số chi tiết: `references/mcp-call-sequence.md`:
```
1  create_project → 2 manage_timelines update 1080×1920
3  import_media create_session → 4 bash scripts/upload.sh (phim + 3 clip, MỘT lệnh, tối đa 4 tệp)
5  edit_item phim vào V1 → 6 read_script → 7 apply_script gạch ~~câu~~
8  find_transcript từng câu nhận b-roll → 9 edit_item 3 clip ("type":"video") lên V2 ĐÚNG mốc khung, KHÔNG fade
10 smooth_audio → 11 submit_export → 12 track_export → 13 tải về → verify-export.sh → mở video
```
Người dùng NHÌN THẤY dòng thời gian đổi theo từng bước: trong app Claude desktop, sau bước 1 mở `browserHandoff.url` trong khung trình duyệt của app.

### ① Chuẩn bị trước giờ lên lớp (khoảng 10 phút)
```
[ ] Phiên Claude MỚI, mở SAU khi đã nối ChatCut. Nhờ Claude liệt kê dự án ChatCut ⇒ ra danh sách, không 401.
[ ] B-roll: dùng sẵn 3 clip trong assets/b-roll/ (91 · 81 · 70 khung, không fade).
    Từ ảnh khác: bash scripts/render-broll-dong.sh <ảnh.png> <số khung của câu> <zoom-in|zoom-out|pan-up> <ra.mp4> ⇒ RESULT PASS
    🔴 KHÔNG dùng b-roll có fade: mép tối ~30/255 so với ~120 giữa clip ⇒ nháy tối ở mối nối.
[ ] DIỄN TẬP trọn một lượt trên đúng máy sẽ chiếu ⇒ số giây thật của mạng hôm đó + một tệp mp4 ĐƯỜNG LUI nằm sẵn.
[ ] bash scripts/verify-export.sh <bản diễn tập>.mp4 5656a249 "Hẹn bạn xem buổi hai" "gửi tặng skill" ⇒ RESULT PASS
[ ] Hạn mức tài khoản Free: 60 phút xuất trên mây CỘNG DỒN, không reset. Mỗi lượt demo ăn 32 giây.
```
### ② Số đo (25–27/09/2026)
| bước | macOS | Windows |
|---|---|---|
| tải phim 36 giây + 3 clip | 28 giây | phim có tiếng: bấm relink tay (lỗi plugin P5) · 3 clip 12 giây |
| bóc lời | có ngay (lượt đầu ≤ 21 giây) | ~8 giây |
| gạch câu + tra 3 câu + đặt b-roll + làm mượt tiếng | ~39 giây | tương đương |
| xuất trên mây | 17,7–20,5 giây | 28,9 giây |
| **tổng** | **1 phút 30 giây – 2 phút 17 giây** · vừa làm vừa kể 3 phút 30 giây | chưa bấm giờ trọn (có bước relink tay) |
| mã kiểm bản ra | `5656a249` | `5656a249` — trùng từng byte |

### ③ Phụ đề ChatCut CHỈ trên đoạn b-roll (đã chạy thật trên Windows 27/09, soát 12 khung mép sạch)
Phim mẫu đã in sẵn phụ đề; b-roll đè lên thì che mất ⇒ bật phụ đề ChatCut rồi CHỈ để hiện ở đoạn b-roll.
Phụ đề ChatCut **không phải đoạn chữ trên dòng thời gian** như CapCut: nó là một lớp tự sinh từ bản bóc lời, bật/tắt bằng nút **CC** ở thanh công cụ,
sửa theo **thẻ** (`read_captions` / `edit_captions`).
```
1  edit_captions enable ⇒ set_sources {"sources":[{"trackId":"V1"}]} ⇒ refresh      (mặc định nó lấy CẢ V1 + V2)
2  đo dải phụ đề in sẵn trên 1 khung gốc: phim mẫu x 75–1000 · y 1255–1360 · chữ ~58 px
3  edit_captions style {"font":"Be Vietnam Pro","sizePx":56,"fontWeight":"700","color":"#FFFFFF","backgroundColor":"#0B1628","backgroundOpacity":0.94,"backgroundRadius":16}
   edit_captions layout {"sourceId":"<V1 source>","left":75,"top":1255,"width":930,"height":105} ⇒ refresh
4  read_captions ⇒ ẩn MỌI thẻ ngoài b-roll, TỪNG thẻ (mỗi lệnh cần revision của lệnh trước):
   set_card_style {"cardId":…,"style":{"opacity":0,"backgroundOpacity":0},"revision":…}
   🪤 chỉ "opacity":0 thì chữ mất nhưng khung nền tối vẫn hiện · ẩn cả lớp rồi bật riêng thẻ bằng opacity 1 KHÔNG ăn
5  thẻ dài hơn câu 0,1–0,4 s ⇒ mép b-roll chồng 2 lớp chữ ⇒ KÉO b-roll khớp mốc thẻ: edit_item fromFrame = đầu thẻ đầu ·
   durationInFrames = cuối thẻ cuối − đầu · playbackRate = số khung clip / durationInFrames (phim mẫu: 301–407 @0,8585 · 421–517 @0,8438 · 635–719 @0,8334)
6  refresh ⇒ preview_timeline soát khung ngay trước/sau mỗi mép b-roll (±2 khung)
```
Bản ra: `assets/ban-mau-da-ra/dien-tap-broll-dong-phu-de-broll.mp4` (md5 `29735955`, 32,04 giây).

### ④ Hỏng thì làm gì
| dấu hiệu | nói với người dùng / làm gì |
|---|---|
| Windows: tải phim có tiếng báo lỗi «No option name near» | «Máy không tự gửi được phim này, cần anh bấm giúp một lần.» `upload.sh` đã chép phim vào Downloads và chép đường dẫn; hướng dẫn: bấm thẻ phim «Click to relink» → ô **File name** → **Ctrl+V** → **Enter** → nhắn «xong» |
| tải lên quá 60 giây | dừng, chiếu tệp đường lui đã diễn tập |
| `401` / công cụ ChatCut biến mất | `/mcp` → Authenticate; trên sân khấu thì chiếu đường lui |
| xuất quá 60 giây | `track_export` thêm một lần; quá 2 phút thì chiếu đường lui |
| bản xuất ngắn bất thường | `verify-export.sh` báo `FAIL duration` ⇒ không chiếu |
| viền đen hai bên | quên đổi khổ dọc ⇒ `manage_timelines update 1080×1920` rồi xuất lại |
| đường lui cuối cùng | `assets/ban-mau-da-ra/dien-tap-broll-dong.mp4` |

### ⑤ Lỗi đã biết
```
1  Phim nguồn đã IN SẴN phụ đề ⇒ mép cắt lóe chữ câu đã xoá (1 khung giữa phim · 4–5 khung câu cuối). Tiếng vẫn sạch.
   ChatCut cắt theo TIẾNG, phụ đề in sẵn hiện sớm hơn tiếng. Tránh: đưa lên video CHƯA in phụ đề, phụ đề làm trong ChatCut (như «Video icon kể chuyện»).
2  Sửa [silence=…] trong bản chữ KHÔNG đổi độ dài. Rút khoảng lặng: clean_script (CHƯA thử).
3  Bật phụ đề ChatCut trên phim đã in phụ đề ⇒ HAI lớp chữ ⇒ dùng công thức ③ (chỉ trên b-roll) hoặc đừng bật.
4  B-roll KHÔNG tự chạy theo khi cắt lại phim chính ⇒ cắt XONG rồi mới find_transcript và đặt b-roll.
5  find_transcript theo asset không khớp câu vắt qua hai đoạn bóc lời ⇒ tra từng vế ngắn.
6  Bóc lời dính chữ «ởbuổi» ⇒ manage_transcript action "fix" nếu thẻ đó cần hiện.
```
**Phim mẫu mang ngày cũ** (buổi 1, 24/09/2026 — giọng nói «Tối nay, ở buổi một»): đừng chỉ đổi dải chữ. Giới thiệu đúng sự thật
(«đây là phim buổi trước, giờ ta biên tập lại»), hoặc che dải chữ, tấm mở đầu **và** gạch luôn câu «Tối nay, ở buổi một…».

---

## Kiểm sau khi xong — đừng tin lời «xuất xong»
```bash
bash scripts/verify-export.sh <tệp.mp4> [md5-mẫu] "<câu đã xoá>" "<câu phải còn>"
```
Kiểm 1080×1920 · có tiếng · dài hơn 3 giây · 0 khung đen · độ to · Whisper (công cụ nghe lại lời) KHÔNG còn nghe câu đã xoá **và vẫn nghe câu phải còn**.
Chữ số và chữ viết được so ngang nhau («buổi 2» = «buổi hai»). Ảnh ghép 10 khung ghi cạnh tệp, hoặc vào `out/` khi tệp nằm trong `assets/` — mở ra nhìn.
Thiếu Whisper ⇒ `RESULT PASS (speech not checked: whisper missing)`. Lần đầu Whisper tải mô hình ~480 MB; nhật ký Whisper ghi ra tệp, lỗi thì in 5 dòng cuối.
Đối chứng âm (chạy trên phim CHƯA cắt, phải ra `FAIL removed phrase still audible`): xem `README-CAI-MOI.md` bước 4.
So video dựng bằng Remotion với bản mẫu: **cùng số khung + cùng độ dài + PSNR ≥ 40 dB** là tương đương. md5 chỉ trùng trên cùng một máy.

## Bộ dựng Remotion (`scripts/remotion/`, 4.0.471, 1080×1920, 30 khung/giây)
```
BrollDong         ảnh → clip động (zoom-in · zoom-out · pan-up), không fade      render.sh broll
IconStage         sân khấu theo câu (thẻ bo góc, lưới, bậc thang, gạch, chia đôi)  render.sh stage (có phụ đề in sẵn) · stage-chatcut (không phụ đề, cho ChatCut)
IconStory         icon + mũi tên đè lên phim, một cụm mỗi câu                     render.sh story
CaptionOverVideo  phụ đề chạy đè lên video nền                                    
```
`render.sh` tự kiểm khổ 1080×1920 và số khung; Remotion lỗi ⇒ `RESULT FAIL` (không để tệp cũ qua mặt).
🪤 Hai lần dựng song song trong cùng thư mục làm hỏng bộ nhớ đệm ⇒ một lần một lúc, luôn `--bundle-cache=false`.

## Bản đồ thư mục
```
README.md · README-CAI-MOI.md (+ -MAC · -WINDOWS)   cho người dùng
SKILL.md                 tệp này · MANIFEST.md mọi tệp + md5 8 ký tự + cỡ
assets/  phim-mau/ (phim buổi 1 có tiếng · nền sạch · phim ngắn 10 s) · b-roll/ (3 ảnh + 3 clip) · icon/ (38 icon)
         ban-mau-da-ra/ (bản ra mẫu + bảng khung) · nguyen-lieu-video-2/ (video icon dựng sẵn, có và không phụ đề + props + mốc chữ)
references/  mcp-call-sequence.md · nguon-chatcut-docs.md · quy-trinh/ · du-lieu-mau/ · ban-mau/ (md5, sổ bấm giờ) · gop-y-windows/ (lượt thử Windows 27/09)
scripts/  kiem-may.sh (+ .ps1) · py.sh · upload.sh · verify-export.sh · render-broll-dong.sh · check-caption-band.sh · draw-broll.sh ·
          make_stage_props.py · make_clusters.py · measure_empty_stage.py · make_icons_svg*.py · lam-bang-khung.py · path-length.mjs · remotion/
```

## Giá — theo tài liệu, trích nguyên văn
*«Manual timeline editing, uploads, project browsing, transcription, and exporting do not consume credits.»* — chatcut.io/docs/credits-policy (đọc 25/09/2026).

## CHANGELOG
- **2026-09-25 → 26** v1.0–v2.2a — claude-video-ai-builder, claude-video-studio-pm: demo «Sửa phim bằng sửa chữ» (1 phút 30 giây, md5 trùng giữa các lượt) · b-roll động · Remotion icon khớp lời + sân khấu theo câu · gói tự đủ · nguyên liệu dựng sẵn · che ô chat Zoom (tên + số điện thoại người tham dự) ở 3 giây đầu phim mẫu. Lịch sử chi tiết: git log.
- **2026-09-27** v3.0 — claude-video-ai-builder (Owner: «xem như ta build mới» cho người mới tinh; PM claude-video-studio-pm soi): làm lại cho người mới tinh trên macOS + Windows, dựa trên **lượt cài và chạy thật trên Windows 11 ngày 27/09/2026** (log `references/gop-y-windows/LOG-LOI-WINDOWS_v1.0.md`). README một câu + khối «Dành cho AI agent» · bước 0 tự kiểm máy (`kiem-may.sh`/`.ps1`) và hỏi MỘT câu gom · luật thuyết minh lời thường · tài liệu cài tách Mac/Windows · «Video icon kể chuyện» đi qua ChatCut (Remotion không phụ đề, ChatCut làm phụ đề một lớp) · bỏ tên «Quy trình C», bỏ đường nối ChatCut bằng `add-json`, gỡ `IconOverlay` khỏi Root · mỗi video MỘT bản mẫu · mã lỗi đã sửa: B1–B6 · M1–M8 · M10–M14 · m1–m6 · m8–m11 · m14 · m17 · m19–m23 (B7 chỉ có lối vượt, chờ ChatCut sửa P5; P1–P6 báo đội ChatCut).
