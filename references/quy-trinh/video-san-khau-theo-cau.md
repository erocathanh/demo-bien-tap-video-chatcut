# Video icon kể chuyện — Remotion dựng hình, ChatCut biên tập (tài liệu kỹ thuật, nhãn nội bộ: quy trình B)

Mỗi câu nói là một cảnh riêng: thẻ nền bo góc, vật minh hoạ bật đúng lúc nói chữ của nó, hết câu thì cắt cứng sang cảnh sau.
Học từ một Short mẫu (luật rút gọn: `tom-tat-luat-mau-07-08.md`).

**Nguyên tắc:** Remotion (bộ dựng video trên máy) chỉ làm **hình + tiếng, KHÔNG phụ đề**. Cắt câu bằng chữ, phụ đề, làm mượt tiếng,
xuất phim đều làm trong ChatCut. Phụ đề chỉ có MỘT lớp, sinh từ bản bóc lời ⇒ sửa được bằng chữ, không bao giờ chồng hai lớp.
(Owner chốt 27/09/2026: «Remotion dựng hình, ChatCut biên tập».)

## Hai nhánh
| nhánh | có gì | dùng khi |
|---|---|---|
| **giọng AI** (mặc định) | một clip có tiếng + cảnh icon, không phụ đề | chưa có video quay mặt — video mẫu trong gói đi nhánh này |
| **có mặt bạn** (nâng cao) | video bạn tự quay đọc kịch bản + các cảnh icon không tiếng | bạn quay được video dọc 1080×1920; gói CHƯA có video quay mặt mẫu |

## Nhánh giọng AI — chạy lại video mẫu (đã chạy thật trên Mac 27/09/2026)
```
1  bash scripts/remotion/render.sh stage-chatcut   ⇒ scripts/remotion/out/video-2-khong-phu-de.mp4 · 1996 khung · có tiếng · không phụ đề
   máy không dựng được (Windows ARM, không cài được bộ dựng) ⇒ dùng bản dựng sẵn assets/nguyen-lieu-video-2/video-2-khong-phu-de.mp4
2  create_project {"compositionWidth":1080,"compositionHeight":1920,"fps":30}   (truyền khổ ngay khi tạo ⇒ khỏi bước đổi khổ)
3  import_media create_session → bash scripts/upload.sh <token> <endpoint> <clip.mp4>            đo: 10 giây
4  edit_item adds [{"type":"video","assetId":A,"fromFrame":0,"trackId":"V1","fit":"cover"}]
5  read_script ⇒ bóc lời có ngay (27 đoạn). Tuỳ chọn: apply_script gạch ~~câu~~ ⇒ hình cắt theo tiếng (cùng một clip)
   đo: gạch câu 7 ⇒ 1996 → 1887 khung, 2 đoạn trên V1
6  edit_captions enable → set_sources {"sources":[{"trackId":"V1"}]} → style + layout (dưới mép thẻ sân khấu) → refresh
     style  {"font":"Be Vietnam Pro","sizePx":56,"fontWeight":"700","color":"#FFFFFF","backgroundColor":"#0B1628","backgroundOpacity":0.9,"backgroundRadius":16}
     layout {"sourceId":"<V1 source>","left":75,"top":1480,"width":930,"height":105}
     (thẻ sân khấu toàn màn kết thúc ở y 1440; kiểu mặc định của ChatCut đặt chữ ở y ~1414 ⇒ chạm thẻ)
7  smooth_audio → submit_export {"format":"video","resolution":"1080p"} → track_export (≥ 10 giây mỗi lần hỏi)
8  curl -fsSL --create-dirs -o "out/<tên>.mp4" "<downloadUrl>" → bash scripts/verify-export.sh out/<tên>.mp4 "" "<câu đã gạch>" "làm thuê cho máy"
```
Câu Whisper nghe đúng để làm đối chứng dương: «làm thuê cho máy». ChatCut nghe sai vài chữ («Cách ba», «giai truyền») — phụ đề
sửa theo thẻ bằng `edit_captions set_card_text` hoặc sửa bản bóc lời bằng `manage_transcript` action `fix`.

## Nhánh có mặt bạn (nâng cao — cần bạn tự quay)
```
1  kịch bản (bảng như dưới) → 2  bạn quay video dọc 1080×1920 đọc đúng kịch bản (mặt + giọng thật)
3  mốc chữ: PYTHONUTF8=1 whisper <video>.mp4 --model small --language vi --word_timestamps True --output_format json
4  kế hoạch hình + icon như nhánh giọng AI
5  props: bash scripts/py.sh scripts/make_stage_props.py <kịch bản> <whisper.json> <kế hoạch> --no-captions --out <props.json>  (không --audio, không --face)
6  render cảnh icon KHÔNG tiếng, không phụ đề; cắt thành từng cảnh theo scenes[].from/to (hoặc cắt bằng split_item trong ChatCut)
   ví dụ đã cắt sẵn: assets/nguyen-lieu-video-2/canh-*.mp4 (4 cảnh không tiếng) + ke-hoach-ghep.json (khung đặt từng cảnh: 0 · 630 · 1314 · 1779)
7  ChatCut: video quay lên V1 → gạch câu TRƯỚC (read_script/apply_script) → find_transcript từng câu → đặt cảnh lên V2 đúng khung
   bố cục toàn màn: cảnh che kín · chia đôi: cropBottom 0.5 + height 960 để mặt hiện nửa dưới
8  phụ đề ChatCut (set_sources V1) → smooth_audio → xuất → verify-export.sh
```
Video quay mặt người thật lên ChatCut ⇒ hỏi chủ video một câu trước khi tải lên.

## Làm video MỚI từ kịch bản của bạn (nhánh giọng AI)
```
1  KỊCH BẢN      bảng markdown: | # | lời | chữ mở | chữ cần vật | vật gì | (sân khấu) |   ví dụ: references/du-lieu-mau/kich-ban-video-2-da-doc.md
                 17–20 câu · câu ≤ 16 chữ · mỗi câu có ít nhất một danh từ/động từ VẼ ĐƯỢC · 2 lần liệt kê 3–4 mục · 2 câu đối lập
2  TIẾNG         đọc từng câu thành tệp riêng (TTS) → cắt lặng đầu/cuối → nối, nghỉ 0,25 s → chuẩn hoá −16 LUFS
3  MỐC CHỮ       PYTHONUTF8=1 whisper <tiếng>.wav --model small --language vi --word_timestamps True --output_format json
4  KẾ HOẠCH HÌNH mỗi câu: layout (full | split) · kind (stairs | single | grid | flow | contrast) · objects [{word, icon}]
                 · chunks (chia phụ đề 2–4 chữ, giữ từ ghép — chỉ dùng khi dựng bản có phụ đề) · early (vật đầu bật ở chữ đầu câu)
                 ví dụ: references/du-lieu-mau/ke-hoach-hinh-video-2.json
5  ICON          bash scripts/py.sh scripts/make_icons_svg.py <thư mục> · make_icons_svg_set03.py (SVG bằng mã) hoặc PNG máy vẽ, nền trong
6  PROPS         bash scripts/py.sh scripts/make_stage_props.py <kịch bản.md> <whisper.json> <kế hoạch.json> --audio <tiếng> [--face <nền.mp4:khung:vị trí>] --no-captions --out <props.json>
                 chữ KỊCH BẢN là chuẩn; Whisper nghe sai vẫn dóng được (difflib + nội suy). Lệch số chữ trong chunks ⇒ báo lỗi và dừng.
7  DỰNG          cd scripts/remotion && npx remotion render src/index.ts IconStage <ra.mp4> --props=<props.json> --public-dir=public --bundle-cache=false
                 (chép tiếng, nền, icon vào scripts/remotion/public/ trước)
8  KIỂM          khổ 1080×1920 · 0 khung đen · bash scripts/py.sh scripts/measure_empty_stage.py <props.json> (thẻ trống ≤ 0,6 s)
                 · bảng khung 1 khung/giây: bash scripts/py.sh scripts/lam-bang-khung.py <thư mục khung> <ra> 1 0 <tiền tố> 6 4 0
9  CHATCUT       như nhánh giọng AI bước 2–8
```
`scripts/py.sh` tự chọn Python 3.8+ thật (thử `python3`, `python`, `py -3`) và bật UTF-8 — trên Windows `python3` thường chỉ là lối tắt của Microsoft Store.

## Số đo
Video mẫu (26/09/2026): 18 câu · 190 chữ · tiếng 66,4 s · 68 sự kiện đồ hoạ = 10,4 / 10 giây (Short mẫu: trung bình 13, dải 7–16) ·
tối đa 5 vật/cảnh · thẻ trống lâu nhất 0,53 s.
Dựng `stage-chatcut`: Mac Apple Silicon 29 giây · Windows i9 64–70 giây (bản có phụ đề, cùng cỡ). ChatCut (Mac, 27/09): tải 10 giây ·
bóc lời có ngay · xuất trên mây xem sổ bấm giờ `references/ban-mau/`.
So với bản mẫu: **cùng số khung + cùng độ dài + PSNR ≥ 40 dB** là tương đương; md5 bản dựng Remotion chỉ trùng trên cùng một máy
(bản dựng sẵn `video-2-khong-phu-de.mp4`: md5 `b97de04e`, dựng trên macOS 26.5 Apple Silicon).

## Bẫy đã gặp
- Tự chia phụ đề theo số chữ cắt ngang từ ghép («xử / lý») ⇒ ghi `chunks` bằng tay (chỉ khi dựng bản có phụ đề in sẵn).
- Chữ gọi vật nằm cuối câu ⇒ thẻ trống 1,5–2 s ⇒ thêm vật chính bật ở chữ đầu (`early`).
- Icon thân màu kem đặt trên thẻ kem thì biến mất ⇒ icon mặc định có ô nền tối (`card`).
- Hai lần dựng song song trong cùng thư mục làm hỏng bộ nhớ đệm ⇒ một lần một lúc, luôn `--bundle-cache=false`.
- Phụ đề in sẵn trong Remotion + phụ đề ChatCut ⇒ hai lớp chữ ⇒ bản đưa sang ChatCut luôn dựng với `--no-captions` / `stage-chatcut`.
