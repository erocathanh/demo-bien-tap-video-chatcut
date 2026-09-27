# ĐỀ XUẤT ĐƯỜNG B MỚI — Remotion dựng hình, ChatCut biên tập — v1.0

> Owner chốt 27/09/2026: **«Remotion dựng hình, ChatCut biên tập»** và **«bước Remotion chưa làm phụ đề; qua ChatCut ghép với video gốc rồi mới làm phụ đề»**.
> Người soạn: agent Windows (PM). Người làm: agent tác giả trên Mac. Quyết định cấu trúc cuối cùng: Owner.

## 1. Vấn đề

- Repo tự giới thiệu là **biên tập video bằng ChatCut**, nhưng Quy trình B hiện chạy trọn trên máy (Remotion → mp4) và **không đụng ChatCut**.
- Phụ đề của B bị **in cứng** trong Remotion ⇒ không sửa được bằng chữ trong ChatCut, và ghép vào ChatCut thì dễ ra 2 lớp chữ (lỗi đã biết số 3).
- Quy trình C (ghép nguyên liệu sẵn trong ChatCut) và mục «Xếp lớp khi ghép clip Remotion vào ChatCut» đã có, nhưng rời rạc, chưa thành các bước của B.

## 2. Sự thật đã kiểm trên Windows 27/09 (🟢 chạy thật)

| Điều cần biết | Kết quả |
|---|---|
| IconStage bỏ phụ đề có cần sửa code không? | **Không.** Chỉ truyền `captions: []` (IconStage.tsx:340 chỉ vẽ khi có phần tử). Render thử: 59 s · 1996 khung · tiếng aac · soát 3 khung không có chữ |
| Repo có video quay mặt Owner nói trước máy quay không? | **Không.** Chỉ có ô webcam Zoom rất nhỏ trong ~3 s đầu `phim-buoi-1-co-tieng.mp4`. Lớp «mặt người» (`nen-sach.mp4`) thực ra là cảnh minh hoạ người ngồi máy tính nhìn từ phía sau |
| ChatCut làm phụ đề + đặt hình đúng khung được không? | **Được** — Quy trình A chạy trọn trên Windows (md5 `5656a249` trùng Mac) + công thức phụ đề chỉ trên b-roll (log mục 10b), soát 12 khung sạch |

## 3. Thiết kế — 2 nhánh

**Nguyên tắc chung:** Remotion chỉ làm **HÌNH** (cảnh icon sân khấu). **Tiếng, cắt câu bằng chữ, phụ đề, xuất phim đều làm trong ChatCut.** Phụ đề chỉ có một lớp, do ChatCut sinh từ bản bóc lời.

### Nhánh B-1 — CÓ video quay mặt Owner (Owner phải quay thêm)

| # | Bước | Làm ở đâu | Ghi chú |
|---|---|---|---|
| 1 | Kịch bản bảng 5–6 cột | máy | như cũ |
| 2 | **Owner quay video dọc 1080×1920 tự đọc kịch bản** | Owner | thay bước TTS; mặt + giọng thật |
| 3 | Mốc chữ: Whisper trên **tiếng của video quay** | máy | `PYTHONUTF8=1` trên Windows (log B4) |
| 4 | Kế hoạch hình + icon | máy | như cũ |
| 5 | Props: `make_stage_props.py` **không** `--audio`, **không** `--face`, **không phụ đề** | máy | thêm cờ `--no-captions` (hoặc ghi `captions: []`) |
| 6 | Render cảnh icon **không tiếng, không phụ đề**; cắt thành 1 tệp/câu theo `scenes[].from/to` | máy | hoặc render 1 tệp rồi cắt bằng `split_item` trong ChatCut |
| 7 | ChatCut: tạo dự án 1080×1920 → tải video quay lên V1 + các cảnh | ChatCut | tối đa 4 tệp/lượt; Windows vướng lỗi plugin P5 với video có tiếng ⇒ relink tay |
| 8 | **Gạch câu bằng chữ TRƯỚC** (`read_script` → `apply_script`) | ChatCut | lỗi đã biết số 4: hình đặt trước sẽ không chạy theo khi cắt |
| 9 | `find_transcript` từng câu → đặt cảnh lên V2 đúng khung | ChatCut | bố cục «full»: cảnh che kín · «split»: `cropBottom: 0.5` + `height: 960` để mặt hiện nửa dưới |
| 10 | Phụ đề ChatCut: `enable` → `set_sources` V1 → `style` / `layout` | ChatCut | một lớp chữ duy nhất, sửa được theo thẻ |
| 11 | `smooth_audio` → `submit_export` → tải về → `verify-export.sh` | ChatCut + máy | soát khung ở mép mỗi cảnh |

### Nhánh B-2 — CHƯA có video quay mặt (giọng AI như mẫu hiện tại)

| # | Bước | Làm ở đâu | Ghi chú |
|---|---|---|---|
| 1–4 | Kịch bản → TTS → Whisper → kế hoạch hình | máy | như cũ |
| 5 | Props **có** `--audio` (+ `--face` nếu muốn), **`captions: []`** | máy | 🟢 đã thử |
| 6 | Render **một clip có tiếng, không phụ đề** | máy | 🟢 59 s trên Windows |
| 7 | ChatCut: tải 1 clip lên V1 → bóc lời | ChatCut | |
| 8 | Gạch câu bằng chữ → **hình tự cắt theo tiếng** (cùng một clip) | ChatCut | ranh cảnh của IconStage đã khớp đầu câu (cắt cứng) |
| 9 | Phụ đề ChatCut → `smooth_audio` → xuất → kiểm | ChatCut + máy | |

**Quy trình C nhập vào B-2:** máy không có Remotion ⇒ dùng clip B-2 dựng sẵn (đóng gói thêm `assets/nguyen-lieu-video-2/video-2-khong-phu-de.mp4`), bỏ bước 1–6, làm tiếp từ bước 7. Lưu ý: C vẫn cần node (log B6).

## 4. Việc cho agent Mac (item 11 của log mục 9 Part B)

1. `make_stage_props.py`: thêm cờ `--no-captions` (ghi `captions: []`); thêm props mẫu `scripts/remotion/props/iconstage-video-2-khong-phu-de.json`.
2. `render.sh`: thêm đích `stage-chatcut` = render IconStage có tiếng, không phụ đề (kiểm 1996 khung).
3. Đóng gói `assets/nguyen-lieu-video-2/video-2-khong-phu-de.mp4` cho B-2/C; ghi md5 **kèm máy dựng** (md5 Remotion khác nhau giữa máy — log M6).
4. Viết lại `references/quy-trinh/video-san-khau-theo-cau.md` theo 2 nhánh trên; `ghep-nguyen-lieu-san-chatcut.md` đổi thành «B-2 khi máy không có Remotion».
5. `SKILL.md`: câu kích hoạt «demo tạo video có remotion icon» ⇒ chạy B-2 tới hết bước ChatCut; thêm «Một câu cho người diễn» cho B; ghi rõ repo **chưa có video quay mặt Owner** (B-1 cần Owner quay).
6. Dùng lại công thức phụ đề của log mục 10b; không còn phụ đề in cứng ⇒ không còn lỗi 2 lớp chữ ở B.

## 5. Chưa đo / cần Owner quyết

- **Chưa chạy B-2 trên ChatCut:** phải tải clip có tiếng lên (cần Owner duyệt; trên Windows vướng lỗi plugin P5 ⇒ relink tay). Xuất ăn khoảng 66 giây trong hạn mức 60 phút miễn phí; không dùng nhóm sinh nên không tốn credit.
- **B-1 cần Owner quay video** mặt + giọng (dọc 1080×1920, đọc đúng kịch bản 18 câu hoặc kịch bản mới).
- Owner chốt: giữ tên «Quy trình C» hay gộp hẳn vào B-2.
