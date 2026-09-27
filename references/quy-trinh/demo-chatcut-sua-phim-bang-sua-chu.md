# Sửa phim bằng sửa chữ — ChatCut qua MCP (tài liệu kỹ thuật, nhãn nội bộ: quy trình A)

Người dùng gõ MỘT câu cho Claude Code → Claude gọi ChatCut qua MCP → phim dọc được cắt một câu, chèn ba b-roll đúng câu
đang nói, xuất mp4 về máy. Không mở giao diện ChatCut, không bấm gì trong đó.

## Ai làm phần nào
| việc | công cụ | ghi chú |
|---|---|---|
| biên tập bằng chữ (cắt câu, đặt b-roll, xuất) | ChatCut.io qua plugin MCP trong Claude Code | phim ĐI LÊN máy chủ ChatCut; phần biên tập không tốn credit; tài khoản Free có trần 60 phút xuất cộng dồn |
| vẽ ảnh b-roll | Codex (hoặc bất kỳ máy vẽ nào) — VẼ SẴN trước | vẽ tại chỗ mất khoảng 3 phút |
| biến ảnh thành clip động | Remotion `BrollDong` (`scripts/render-broll-dong.sh`) | b-roll là CLIP, không đặt ảnh tĩnh |
| kiểm bản ra | `scripts/verify-export.sh` | khổ · tiếng · khung đen · Whisper nghe câu đã xoá |

## Chuỗi chạy (chi tiết tham số: `references/mcp-call-sequence.md`)
```
0  phiên Claude phải mở SAU khi cài plugin; phiên cũ KHÔNG thấy tool
1  create_project → manage_timelines update 1080×1920 (mặc định là NGANG)
2  import_media create_session → scripts/upload.sh (phim + 3 clip, một lệnh)
3  edit_item thêm phim vào V1 → read_script → apply_script gạch ~~câu~~
4  find_transcript từng câu nhận b-roll → edit_item 3 clip lên V2 đúng khung, không fade
5  smooth_audio → submit_export → track_export → tải về (curl -fsSL --create-dirs -o "out/<tên>.mp4" "<link>") → verify-export.sh → mở xem
   mở xem: macOS open "<tệp>" · Git Bash start "" "$(cygpath -w "<tệp>")" · PowerShell Invoke-Item "<tệp>"
```
Số đo 25/09/2026: trọn lượt **1 phút 30 giây** (ảnh tĩnh) · **2 phút 17 giây** (3 clip động) · vừa làm vừa kể: 3 phút 30 giây.
Người dùng bấm: 1 câu gõ + 1 lần đồng ý tải lên.

## Bẫy đã gặp
1. Phiên đang chạy lúc cắm MCP không thấy tool — mở phiên mới.
2. `codex exec` chạy nền thiếu `</dev/null` ⇒ treo chờ stdin, không báo lỗi. Hết hạn mức ⇒ lỗi nằm ở ĐUÔI log.
3. B-roll có fade ⇒ nháy tối ở mối nối trong ChatCut. Luôn render `fadeFrames=0`.
4. Phim nguồn đã in phụ đề ⇒ mép cắt lóe chữ câu đã xoá 1–5 khung; đừng bật phụ đề ChatCut lên phim đã có phụ đề.
5. Link tải của ChatCut chỉ sống 1 ngày — luôn tải về máy.
6. Câu đối chứng dương cho Whisper: chọn câu Whisper đã nghe đúng (Whisper small nghe «Nạp» thành «Ngạp»).
