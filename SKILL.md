---
name: demo-bien-tap-video-chatcut
description: Diễn trên lớp (hoặc chạy lại) màn BIÊN TẬP VIDEO BẰNG CÁCH SỬA CHỮ với ChatCut.io qua MCP trong Claude Code — nạp một phim nói chuyện dọc 1080×1920, máy bóc lời tiếng Việt, gạch một câu trong bản chữ là phim tự cắt câu đó, chèn b-roll động vào ĐÚNG câu đang nói, xuất mp4 về máy. Kèm bộ Remotion dựng icon khớp lời (IconStory) và video sân khấu theo câu (IconStage). Gói tự đủ - phim mẫu, icon, b-roll, mini-project Remotion, hướng dẫn cài máy mới. Đo thật 25/09/2026 - 1 phút 30 giây cho phim 36 giây, bản ra trùng md5 giữa các lượt. LUÔN trigger khi người dùng nói "demo biên tập video", "demo chatcut", "diễn tập demo chatcut", "sửa phim bằng sửa chữ", "demo-bien-tap-video-chatcut", "icon khớp lời", "video sân khấu theo câu", "demo tạo video có remotion icon", "tạo video icon", "video icon 3 cấp độ AI", "cài skill chatcut máy mới". KHÔNG dùng cho - sinh video mới bằng máy tạo video, vẽ ảnh bằng ChatCut (vẽ bằng Codex hoặc máy vẽ khác), OpenChatCut bản nguồn mở.
---

# demo-bien-tap-video-chatcut — sửa phim bằng cách sửa chữ

> 👤 **Phụ trách:** claude-video-ai-builder · 📅 **Tạo:** 2026-09-25 · 🔄 **Bản:** v2.2
> 📦 Gói tự đủ: giải nén là chạy. Cài trên máy mới: **`README-CAI-MOI.md`**. Danh sách tệp + md5: `MANIFEST.md`.
> Mọi đường dẫn trong tệp này tính từ thư mục chứa `SKILL.md` (gọi là `$SKILL_DIR`).

## Bản đồ thư mục
```
SKILL.md                 tệp này
README-CAI-MOI.md        cài từ số 0: công cụ · ChatCut MCP · Remotion · kiểm có đối chứng
MANIFEST.md              mọi tệp + md5 8 ký tự + cỡ
assets/
  phim-mau/              phim-buoi-1-co-tieng.mp4 (36 s, tệp demo) · nen-sach-khong-phu-de.mp4 · loi.mp3 · phim-ngan-10s-3-cau.mp4
  b-roll/                3 ảnh vẽ sẵn · 3 clip động (không fade) + props · đề vẽ gốc
  icon/                  bo-01-png (8) · bo-02-svg (13) · bo-03-svg (17) + bảng xem
  ban-mau-da-ra/         5 bản ra mẫu + bảng khung — video-2-tao-lai-ghep-chatcut-v02.mp4 = bản Owner duyệt 26/09
  nguyen-lieu-video-2/   nguyên liệu TẠO LẠI 26/09: tiếng · 4 cảnh không tiếng · render trọn · props · whisper · kế hoạch ghép (Quy trình C)
references/
  mcp-call-sequence.md   chuỗi lệnh MCP đúng tham số + chỗ gõ sai đã gặp
  nguon-chatcut-docs.md  trích tài liệu ChatCut về credit và trần 60 phút xuất
  quy-trinh/             A · sửa phim bằng sửa chữ   B · video sân khấu theo câu   luật rút từ 2 Short mẫu
  du-lieu-mau/           timeline đã gạch câu · props mẫu · kế hoạch hình · kịch bản mẫu · whisper mẫu · bộ thử 3 câu
  ban-mau/               README bản mẫu (md5) · ảnh ghép · sổ bấm giờ
scripts/
  upload.sh              tải phim/ảnh lên ChatCut (bọc script của plugin), in assetId
  verify-export.sh       kiểm bản xuất: khổ · tiếng · khung đen · Whisper nghe câu đã xoá + câu phải còn
  check-caption-band.sh  đo overlay có lấn dải phụ đề không (bắt buộc kèm bản đối chứng)
  render-broll-dong.sh   ảnh → clip động (BrollDong, không fade, tự kiểm mép tối)
  draw-broll.sh          vẽ ảnh b-roll bằng codex exec (tuỳ chọn, cần tài khoản Codex)
  make_icons_svg.py · make_icons_svg_set03.py   sinh lại 30 icon SVG (trùng từng byte với assets/icon)
  make_clusters.py       props IconStory (icon khớp lời) từ mốc câu
  make_stage_props.py    props IconStage từ kịch bản + whisper + kế hoạch hình
  measure_empty_stage.py đo thời gian thẻ trống mỗi cảnh
  lam-bang-khung.py · path-length.mjs   bảng khung có nhãn giây · độ dài đường SVG
  remotion/              mini-project Remotion độc lập (npm install) + render.sh + props mẫu + public/
```

## Cài trên máy mới (khoảng 10 phút)
Làm theo **`README-CAI-MOI.md`**: công cụ (node ≥ 18, ffmpeg, whisper tuỳ chọn) → nối ChatCut MCP + Authenticate →
`cd scripts/remotion && npm install && bash render.sh broll` ra `RESULT PASS` → `verify-export.sh` trên bản mẫu ra `RESULT PASS`.

## Gửi học viên
- **Có sẵn trong gói:** phim mẫu, nền sạch, 3 ảnh + 3 clip b-roll, 38 icon, mini-project Remotion, script, bản ra mẫu, số đo.
- **Học viên tự có:** tài khoản ChatCut · Claude Code · internet cho `npm install` và font.
- **Không kèm:** khoá Codex/Gemini/máy vẽ — không cần, vì icon và b-roll đã vẽ sẵn. Chỉ cần khi muốn vẽ mới.
- Phim mẫu có giọng người thật: dùng để học trong lớp, không đăng lại.

## Một câu cho người diễn
**Gõ MỘT câu cho Claude, máy tự làm, khoảng 1 phút 30 giây sau có phim đã cắt một câu và có 3 hình minh hoạ đúng chỗ.**
Không mở trang ChatCut, không bấm gì trong giao diện ChatCut.

## 🔴 Ba chốt cứng — đọc trước khi chạy lệnh đầu tiên
1. **Phim ĐI LÊN MÁY CHỦ ChatCut.** Phim có mặt hoặc giọng người thật ⇒ hỏi chủ phim **đúng một câu** trước lượt tải đầu.
   Câu lệnh đã có chữ «đồng ý tải lên» thì khỏi hỏi lại.
2. **Không gọi nhóm SINH của ChatCut** (`video-gen` · `image-gen` · `voice` · `music` · `digital-human` · `video-translation`) — nhóm đó tốn credit.
   Phần biên tập (tải lên, bóc lời, cắt, xuất) không tốn credit (trích tài liệu: `references/nguon-chatcut-docs.md`).
3. **Phim của người khác không lên ChatCut.** Chỉ dùng phim bạn có quyền.

## ① Chuẩn bị TRƯỚC giờ lên lớp (khoảng 10 phút)
```
[ ] 1. Mở phiên Claude Code MỚI, SAU khi đã nối ChatCut. Phiên mở trước lúc cài KHÔNG thấy tool.
       Kiểm: nhờ Claude liệt kê dự án ChatCut ⇒ ra danh sách, không 401. 401 ⇒ /mcp → ChatCut → Authenticate.
[ ] 2. B-roll: dùng sẵn 3 clip động trong assets/b-roll/ (91 · 81 · 70 khung, không fade).
       Muốn làm từ ảnh khác:  bash scripts/render-broll-dong.sh <ảnh.png> <số khung của câu> <zoom-in|zoom-out|pan-up> <ra.mp4>
       ⇒ RESULT PASS (đúng số khung · 1080×1920 · mép đầu/cuối không tối hơn giữa clip). Số khung lấy từ find_transcript.
       🔴 KHÔNG dùng b-roll có fade: mép tối ~30/255 so với ~120 giữa clip ⇒ nháy tối ở mối nối.
       Muốn vẽ ảnh mới: bash scripts/draw-broll.sh assets/b-roll/de-codex-broll-vsl.txt <thư mục ra> <tên 3 ảnh>
       (cần tài khoản Codex; `codex exec` PHẢI có </dev/null, thiếu thì treo chờ stdin không báo lỗi).
[ ] 3. DIỄN TẬP TRỌN một lượt theo mục ② trên đúng máy sẽ chiếu. Được hai thứ: số giây thật của mạng hôm đó,
       và một tệp mp4 ĐƯỜNG LUI nằm sẵn trên máy. Máy hỏi quyền tool nào thì chọn «đồng ý, không hỏi lại».
[ ] 4. bash scripts/verify-export.sh <bản-diễn-tập>.mp4 5656a249 "<câu đã xoá>" "<một câu phải còn>"  ⇒ RESULT PASS.
       Dùng đúng phim + ba clip của bản mẫu thì md5 ra 5656a249.
[ ] 5. Hạn mức: tài khoản Free có 60 phút xuất trên mây CỘNG DỒN, không reset. Mỗi lượt demo ăn 32 giây.
```

## ② Gõ gì, theo thứ tự
**Câu duy nhất người diễn gõ** (thay đường dẫn cho đúng máy):
```
Chạy skill demo-bien-tap-video-chatcut. Phim: <đường dẫn>/assets/phim-mau/phim-buoi-1-co-tieng.mp4, tôi đồng ý tải lên ChatCut.
Xoá câu «Hẹn bạn xem buổi hai Bí mật AI cùng Thanh tối mai».
Chèn 3 clip b-roll động trong <đường dẫn>/assets/b-roll/ vào 3 câu «Nạp bản sắc thương hiệu», «Giao AI xử lý tệp», «Phân tích khảo sát».
Xuất 1080×1920 rồi mở phim cho tôi xem.
```
**Máy làm theo đúng chuỗi này** — chi tiết tham số: `references/mcp-call-sequence.md`:
```
1  create_project  →  2  manage_timelines update 1080×1920   (🔴 mặc định là NGANG)
3  import_media create_session  →  4  scripts/upload.sh  (phim + 3 clip, MỘT lệnh)
5  edit_item thêm phim vào V1  →  6  read_script  →  7  apply_script gạch ~~câu~~
8  find_transcript từng câu nhận b-roll  →  9  edit_item 3 CLIP ("type":"video") lên V2 ĐÚNG mốc khung, KHÔNG fade
10 smooth_audio  →  11 submit_export  →  12 track_export (hỏi lại mỗi ≥10 giây)
13 tải về  →  verify-export.sh  →  mở tệp
```
Muốn lớp NHÌN THẤY dòng thời gian đổi theo từng bước: chạy trong app Claude desktop, sau bước 1 mở `browserHandoff.url`
(bản có `editor-boot-token`) trong khung trình duyệt của app (Cmd+Shift+B để hiện khung). Trên Claude Code ở terminal: CHƯA đo.

## ③ Mỗi bước mất bao lâu — số ĐO 25/09/2026
| bước | số đo | ghi chú |
|---|---|---|
| tải phim 36 giây + 3 ảnh | 10 giây · với 3 clip động: 28 giây | |
| bóc lời | có ngay khi đặt phim lên | lượt đầu trong ngày: ≤ 21 giây |
| gạch câu + tra 3 câu + đặt b-roll + làm mượt tiếng | khoảng 39 giây | thời gian agent gọi lệnh |
| render 32 giây phim | 17,7 giây · với 3 clip: 20,5 giây | |
| **TỔNG** | **1 phút 30 giây** · với 3 clip động **2 phút 17 giây** · vừa làm vừa kể **3 phút 30 giây** | |

## ④ Hỏng thì lùi đường nào
| dấu hiệu | lùi thế nào |
|---|---|
| tải lên quá 60 giây chưa xong | dừng, chiếu tệp đường lui đã diễn tập |
| `401` / tool ChatCut biến mất | `/mcp` → Authenticate; trên sân khấu thì chiếu đường lui |
| tool không có trong phiên | phiên mở trước lúc nối ChatCut ⇒ mở phiên mới |
| render quá 60 giây | `track_export` thêm một lần; quá 2 phút thì chiếu đường lui |
| bản xuất ngắn bất thường | `verify-export.sh` báo `FAIL duration` ⇒ không chiếu |
| viền đen hai bên | quên đổi khổ dọc ⇒ `manage_timelines update 1080×1920` rồi xuất lại |
| đường lui cuối cùng | `assets/ban-mau-da-ra/dien-tap-broll-dong.mp4` (md5 `5656a249`) |
Link tải của ChatCut chỉ sống 1 ngày ⇒ luôn tải về máy, đừng chiếu bằng link.

## ⚠️ Lỗi đã biết
```
1  Phim nguồn đã IN SẴN phụ đề ⇒ mép cắt lóe chữ câu đã xoá (1 khung giữa phim · 4–5 khung câu cuối). Tiếng vẫn sạch.
   ChatCut cắt theo TIẾNG, phụ đề in sẵn hiện sớm hơn tiếng. Cách tránh: đưa lên phim CHƯA in phụ đề, cắt xong mới thêm phụ đề.
2  Sửa [silence=…] trong bản chữ KHÔNG đổi độ dài. Rút khoảng lặng: clean_script (CHƯA thử).
3  Bật phụ đề ChatCut trên phim đã in phụ đề ⇒ HAI lớp chữ. Phim nguồn có phụ đề thì ĐỪNG bật edit_captions.
4  B-roll KHÔNG tự chạy theo khi cắt lại A-roll ⇒ luôn cắt A-roll XONG rồi mới find_transcript và đặt b-roll.
5  find_transcript theo asset không khớp câu vắt qua hai đoạn ASR ⇒ tra từng vế ngắn.
```

## 📅 Phim mẫu mang ngày cũ
Phim mẫu là phim **buổi 1 (24/09/2026)**: giọng nói «Tối nay, ở buổi một Bí mật AI», dải chữ «BUỔI 1 · 24/09/2026».
Đừng chỉ đổi dải chữ: giọng vẫn nói buổi 1. Hoặc giới thiệu đúng sự thật («đây là phim buổi trước, giờ ta biên tập lại»),
hoặc che dải chữ, tấm mở đầu **và** gạch luôn câu «Tối nay, ở buổi một…».

## Kiểm sau khi xong — đừng tin lời «xuất xong»
```bash
bash scripts/verify-export.sh <tệp.mp4> [md5-mẫu] "<câu đã xoá>" "<câu phải còn>"
```
Kiểm 1080×1920 · có tiếng · dài hơn 3 giây · 0 khung đen · độ to · Whisper KHÔNG còn nghe câu đã xoá **và vẫn nghe câu phải còn**
(đối chứng dương, vì Whisper small nghe sai vài chữ). In kèm ảnh ghép 10 khung `<tệp>-contact.png` — mở ra nhìn.
🪤 Chọn câu đối chứng dương Whisper đã nghe đúng: «Nạp bản sắc» bị nghe thành «Ngạp» ⇒ FAIL oan. Dùng «gửi tặng skill».

## 🎞️ Phần Remotion — icon khớp lời và sân khấu theo câu
Mini-project: `scripts/remotion/` (5 composition, 1080×1920, 30 khung/giây). Cài: `npm install` một lần. Render mẫu: `bash render.sh [broll|stage|story|all]`.
```
BrollDong      ảnh → clip động (zoom-in · zoom-out · pan-up), fadeFrames 0            props mẫu: scripts/remotion/props/broll-*.json
IconStory      icon + mũi tên đè lên phim, một cụm mỗi câu, nền mờ nhẹ khi có cụm     props: make_clusters.py → props/iconstory-phim-buoi-1.json
IconStage      sân khấu theo câu (thẻ bo góc, lưới, bậc thang, gạch, chia đôi)        props: make_stage_props.py → props/iconstage-video-2.json
               ⭐ `bash render.sh stage` ra ĐÚNG video Owner duyệt 26/09 (tiếng mới, có mặt người); bản cũ: props/iconstage-video-2-v03b-cu.json
IconOverlay    bản overlay đầu tiên (một cụm cố định)                                  giữ để tham khảo
CaptionOverVideo  phụ đề chạy đè lên video nền                                         
```
Quy trình từng bước: `references/quy-trinh/video-san-khau-theo-cau.md`. Luật đo từ Short mẫu: `references/quy-trinh/tom-tat-luat-mau-07-08.md`.

**Xếp lớp khi ghép clip Remotion vào ChatCut** (đo 25/09):
```
V1  phim có tiếng (chỉ lấy tiếng, bị phủ kín)
V2  nền SẠCH cùng cảnh, không phụ đề
V3  clip Remotion KHÔNG phụ đề, đúng khung, decibelAdjustment -60
edit_captions enable ⇒ set_sources {"sources":[{"trackId":"V1"}]} ⇒ refresh   (mặc định nó lấy CẢ ba track)
thêm từng lớp MỘT, không kèm trackId (gửi cả lô trên timeline mới bị «Overlap»)
đo lấn dải phụ đề: bash scripts/check-caption-band.sh <bản ghép> <từ giây> <tới giây> 1414 84 <bản đã biết lấn làm đối chứng>
```
🪤 **Bẫy Remotion:** hai render song song trong cùng thư mục làm hỏng cache webpack («TypeError … reading 'length'») ⇒ một render
một lúc, luôn `--bundle-cache=false`. Render không tất định từng byte ⇒ so PSNR hoặc bảng khung, đừng so md5.

## 🧳 Máy mới KHÔNG có Remotion — đi Quy trình C, đừng dừng
Skill mang sẵn **nguyên liệu đã tạo** cho video icon «3 cấp độ AI» ở `assets/nguyen-lieu-video-2/` (tiếng · 4 cảnh không tiếng · bản render trọn ·
props · mốc chữ · kế hoạch ghép, md5 trong `MD5.txt`). Thiếu node/Remotion ⇒ bỏ bước dựng, tải nguyên liệu lên ChatCut và ghép:
`references/quy-trinh/ghep-nguyen-lieu-san-chatcut.md` (chạy thật 26/09, 5 tệp tải 12 giây). Owner 26/09: «tránh skill bị dừng vì thiếu nguyên liệu».

## Giá — theo tài liệu, trích nguyên văn
*«Manual timeline editing, uploads, project browsing, transcription, and exporting do not consume credits.»*
— chatcut.io/docs/credits-policy (đọc 25/09/2026). Không tool MCP nào báo số dư credit.

## CHANGELOG
- **2026-09-25 → 2026-09-26** v1.0–v1.7b — claude-video-ai-builder: demo sửa phim bằng sửa chữ (1 phút 30 giây, md5 trùng ba lượt) · thang lui vẽ b-roll · b-roll động BrollDong không fade · chế độ overlay · ghép clip Remotion vào ChatCut theo lớp + đo lấn dải phụ đề.
- **2026-09-26** v2.0 — claude-video-ai-builder: đóng gói TỰ ĐỦ để chép sang máy mới hoặc gửi học viên — thêm `assets/` (phim mẫu có tiếng, nền sạch, b-roll ảnh + clip, 38 icon, 4 bản ra mẫu), `scripts/remotion/` (mini-project 5 composition + render.sh tự kiểm), `README-CAI-MOI.md`, `MANIFEST.md`, `references/quy-trinh/`; mọi đường dẫn tương đối (0 đường dẫn máy riêng); script sinh icon, props IconStory/IconStage và đo thẻ trống đi kèm. Thử trên thư mục trống: sổ `references/ban-mau/dong-ho-cai-may-moi-26-09.log`.
- **2026-09-26** v2.1 — claude-video-studio-pm (Owner lệnh trực tiếp: «đóng gói và xuất từng nguyên liệu … máy mới không có remotion thì chọn bước dùng nguyên liệu … đưa vào chatcut làm tiếp»): tạo lại video icon TỪ ĐẦU (TTS Gemini 32 s → Whisper 47 s → props 18 cảnh → render 29 s → cắt 4 cảnh) rồi ghép trong ChatCut (dự án ec0a41e8); đóng gói 10 tệp vào `assets/nguyen-lieu-video-2/` + `references/quy-trinh/ghep-nguyen-lieu-san-chatcut.md` (Quy trình C) + mục «Máy mới KHÔNG có Remotion». Chưa đụng mã Remotion; builder giữ quyền nghề. Đề nghị builder: `ICON_STAGE_DEFAULT` nạp props mẫu để Remotion Studio hiện cảnh thật thay vì sân khấu trống.
- **2026-09-26** v2.2 — claude-video-studio-pm (Owner: «đóng gói nguyên liệu từng asset đầy đủ … chỉ có chatcut thì vẫn chạy demo được … chạy skill nói demo tạo video có remotion icon thì sẽ chạy ra video mới … đóng gói và upload github»): props mặc định IconStage = bản tạo lại 26/09 (bản cũ giữ ở props/iconstage-video-2-v03b-cu.json); Root.tsx nạp JSON đó làm defaultProps để Remotion Studio hiện cảnh thật (tsconfig thêm resolveJsonModule); thêm câu kích hoạt «demo tạo video có remotion icon»; bản Owner duyệt vào assets/ban-mau-da-ra/; đẩy GitHub (riêng tư) — xem README-CAI-MOI.md. 🛡️ Trước khi đẩy: người rà độc lập phát hiện 3 s đầu phim mẫu buổi 1 (ảnh chụp Zoom) lộ tên + số điện thoại người tham dự ⇒ đã che ô chat Zoom bằng ô đặc ở 6 mp4 (số khung giữ nguyên), chạy lại demo trên phim đã che để lấy bản mẫu mới (md5 `5656a249`), làm lại 4 bảng khung, sửa md5 trong SKILL/README/ban-mau/mcp-call-sequence, MANIFEST sinh lại; lịch sử git làm mới để không còn bản chưa che.
- **2026-09-26** v2.2a — claude-video-ai-builder: soi 2 chỗ PM sửa (Root.tsx nạp props mẫu · tsconfig resolveJsonModule): đúng hướng; thay `as any` bằng `as IconStageProps` để còn kiểm kiểu (tsc rc 0; đối chứng ép sai kiểu ⇒ tsc báo lỗi).
