# Chuỗi lệnh MCP đã chạy thật — lượt diễn tập 09:25:44 → 09:27:14 London, 25/09/2026

> Phần MCP **không viết thành script bash được**: lệnh MCP do agent gọi, và chìa OAuth nằm trong Claude Code,
> không nằm trong tệp nào. Tệp này là «script» cho phần đó: đúng thứ tự, đúng tham số, đúng số đo.
> Đổi ba thứ theo phim mới: `projectId` · `assetId` · mốc khung trả về từ `find_transcript`.
> Tên tool đầy đủ có tiền tố `mcp__plugin_chatcut_chatcut__`.

| # | tool | tham số đã dùng | trả về cần giữ | giờ đo |
|---|---|---|---|---|
| 0 | Skill `chatcut:chatcut-plugin-basics-claude` | — | (bắt buộc trước lệnh ChatCut đầu tiên của phiên) | — |
| 1 | `create_project` | `{"name":"dien-tap-demo-25-09"}` | `projectId` · `timelineId` | 09:25:44 |
| 2 | `manage_timelines` | `{"projectId":P,"action":"update","timelineId":T,"width":1080,"height":1920}` | — (🔴 dự án mới mặc định **1920×1080 ngang**) | |
| 3 | `import_media` | `{"projectId":P,"action":"create_session"}` | `token` · `endpoint` (sống 30 phút) | |
| 4 | Bash `bash scripts/upload.sh <token> <endpoint> <phim.mp4> <clip1.mp4> <clip2.mp4> <clip3.mp4>` (v1.4: clip động, 28 giây; ảnh cũ: 10 giây) | tối đa 4 tệp một lệnh | 4 dòng `assetId tên-tệp` | 09:26:12 · **10 giây** |
| 5 | `edit_item` | `{"projectId":P,"adds":[{"type":"video","assetId":PHIM,"fromFrame":0,"trackId":"V1","fit":"cover"}]}` | — | |
| 6 | `read_script` | `{"projectId":P}` | `timelineMd` (bản bóc lời có ngay, **không phải chờ**) | |
| 7 | `apply_script` | `{"projectId":P,"timelineMd":"<bản gạch ~~câu~~>"}` — mẫu: `du-lieu-mau/timeline-gach-cau.md` | báo «36.4s → 32s» | |
| 8 | `find_transcript` ×3 | `{"projectId":P,"query":"<nguyên câu>"}` | `Timeline placement: V1 … 304f → 395f` | |
| 9 | `edit_item` | **từ v1.4 (clip động):** `adds` 3 clip `{"type":"video","assetId":B,"fromFrame":304,"durationInFrames":91,"trackId":"V2","fit":"cover","left":0,"top":0,"width":1080,"height":1920}` — KHÔNG fade. Bản cũ (ảnh tĩnh, trước v1.4): `"type":"image"` + `"fadeIn":0.15,"fadeOut":0.15` | — | |
| 10 | `smooth_audio` | `{"projectId":P}` | 1 chồng tiếng + 2 mờ tiếng · với clip động: báo `skipped 3 no_audio` — ĐÚNG, clip b-roll không có tiếng | |
| 11 | `submit_export` | `{"projectId":P,"format":"video","resolution":"1080p","name":"<tên>.mp4"}` | `renderId` | 09:26:51 |
| 12 | `track_export` | `{"action":"status","projectId":P,"renderIds":R}` — hỏi lại mỗi ≥10 giây | `downloadUrl` (S3, sống **1 ngày**) | render **17,7 giây** |
| 13 | Bash `curl -fsSL --create-dirs -o "out/<tệp>.mp4" "<downloadUrl>"` (`-f`: link hết hạn thì báo lỗi, không lưu tệp rác; PowerShell dùng `curl.exe`) rồi `scripts/verify-export.sh <tệp> 5656a249 "<câu đã xoá>" "<câu phải còn>"` | | `RESULT PASS` | 09:27:14 · **tổng 1 phút 30 giây** |

## Bốn chỗ gõ sai tham số đã cắn (đo 25/09) — đừng mò lại
```
track_progress   bắt buộc "action" (params|status|wait); "assetIds" dạng mảng bị báo «not found».
                 ⇒ KHÔNG cần: kiểm bóc lời bằng browse_assets (transcript.state = "complete").
manage_timelines đổi thời gian đang mở là action "switch", KHÔNG phải "activate".
edit_item        phải bọc trong "adds": [ … ]; gọi với trường phẳng thì trả {"adds":[]} IM LẶNG, không báo lỗi.
find_transcript  bắt buộc "query"; không nhận assetId để đọc cả bản.
```

## Hai thứ KHÔNG ăn — đừng dựa vào
```
sửa [silence=1.1s] → [silence=0.45s] trong timelineMd   ⇒ KHÔNG đổi độ dài (đo: 36,4 → 32,0 đúng bằng câu xoá + khoảng lặng của nó)
bật phụ đề ChatCut trên phim đã in sẵn phụ đề           ⇒ HAI lớp chữ; SRT còn lỗi «ởbuổi» dính chữ
```
