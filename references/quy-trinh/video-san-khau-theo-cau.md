# Quy trình B — video «sân khấu theo câu» (IconStage) từ một kịch bản

Mỗi câu nói là một cảnh riêng: thẻ nền bo góc, vật minh hoạ bật đúng lúc nói chữ của nó, hết câu thì cắt cứng sang cảnh sau.
Học từ một Short mẫu (luật rút gọn: `references/quy-trinh/tom-tat-luat-mau-07-08.md`). Bản ra mẫu:
`assets/ban-mau-da-ra/video-2-ba-cap-do-ai-v03b.mp4` (65 giây, 18 câu).

```
1  KỊCH BẢN      bảng markdown: | # | lời | chữ mở | chữ cần vật | vật gì | (sân khấu) |   ví dụ: references/du-lieu-mau/kich-ban-video-2-da-doc.md
                 17–20 câu · câu ≤ 16 chữ · mỗi câu có ít nhất một danh từ/động từ VẼ ĐƯỢC · 2 lần liệt kê 3–4 mục · 2 câu đối lập
2  TIẾNG         đọc từng câu thành tệp riêng (TTS) → cắt lặng đầu/cuối → nối, nghỉ 0,25 s → chuẩn hoá −16 LUFS
3  MỐC CHỮ       whisper <tiếng>.wav --model small --language vi --word_timestamps True --output_format json
4  KẾ HOẠCH HÌNH mỗi câu: layout (full | split) · kind (stairs | single | grid | flow | contrast) · objects [{word, icon}]
                 · chunks (chia phụ đề 2–4 chữ, giữ từ ghép) · early (vật đầu bật ở chữ đầu câu)
                 ví dụ: references/du-lieu-mau/ke-hoach-hinh-video-2.json
5  ICON          scripts/make_icons_svg.py · make_icons_svg_set03.py (SVG bằng mã, cùng một tay vẽ) hoặc PNG máy vẽ, nền trong
6  PROPS         python3 scripts/make_stage_props.py <kịch bản.md> <whisper.json> <kế hoạch.json> --audio <tiếng> [--face <nền.mp4:khung:vị trí>]
                 chữ KỊCH BẢN là chuẩn; Whisper nghe sai vẫn dóng được (difflib + nội suy). Lệch số chữ trong chunks ⇒ báo lỗi và dừng.
7  RENDER        cd scripts/remotion && npx remotion render src/index.ts IconStage <ra.mp4> --props=<props.json> --public-dir=public --bundle-cache=false
8  KIỂM          khổ 1080×1920 · 0 khung đen · Whisper nghe lại đủ câu · python3 scripts/measure_empty_stage.py <props.json> (thẻ trống ≤ 0,6 s)
                 · bảng khung 1 khung/giây: python3 scripts/lam-bang-khung.py <thư mục khung> <ra> 1 0 <tiền tố> 6 4 0
```

## Số đo bản mẫu (26/09/2026)
18 câu · 190 chữ · tiếng 64,9 s · 68 sự kiện đồ hoạ = 10,4 / 10 giây (mẫu: trung bình 13, dải 7–16) · tối đa 5 vật/cảnh ·
66 cụm phụ đề, 0 cụm vượt ranh cảnh · thẻ trống lâu nhất 0,53 s · render 33 giây trên máy M-series.

## Bẫy đã gặp
- Tự chia phụ đề theo số chữ cắt ngang từ ghép («xử / lý») ⇒ ghi `chunks` bằng tay trong kế hoạch hình.
- Chữ gọi vật nằm cuối câu ⇒ thẻ trống 1,5–2 s ⇒ thêm vật chính bật ở chữ đầu (`early`).
- Icon thân màu kem đặt trên thẻ kem thì biến mất ⇒ icon mặc định có ô nền tối (`card`).
- Hai render song song trong cùng thư mục làm hỏng cache webpack ⇒ một render một lúc, luôn `--bundle-cache=false`.
