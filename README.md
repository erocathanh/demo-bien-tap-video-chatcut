# demo-bien-tap-video-chatcut

Skill cho Claude Code: **biên tập video bằng cách sửa chữ** với ChatCut.io qua MCP — gạch một câu trong bản chữ là phim tự cắt
câu đó, chèn b-roll động đúng câu đang nói, xuất mp4 dọc 1080×1920. Kèm bộ Remotion dựng **icon khớp lời** và **video sân khấu
theo câu**. Gói tự đủ: phim mẫu, icon, b-roll, mini-project Remotion, hướng dẫn cài máy mới.

Số đo thật (25–26/09/2026): phim 36 giây → cắt một câu + chèn 3 b-roll trong **1 phút 30 giây**; video sân khấu 65 giây render 33 giây.

## Cài nhanh
```bash
git clone https://github.com/erocathanh/demo-bien-tap-video-chatcut.git ~/.claude/skills/demo-bien-tap-video-chatcut
cd ~/.claude/skills/demo-bien-tap-video-chatcut/scripts/remotion && npm install
bash render.sh broll          # phải in RESULT PASS
```
Bản này là **v2.2** (26/09/2026). Kho CÔNG KHAI theo quyết của chủ phim (26/09/2026). Phim mẫu có mặt và giọng người thật: dùng để học, **không đăng lại, không cắt ghép đưa lên mạng**.
Hướng dẫn từng bước có dòng «Kiểm»: **[README-CAI-MOI.md](README-CAI-MOI.md)** · cách dùng: **[SKILL.md](SKILL.md)** · danh sách tệp + md5: [MANIFEST.md](MANIFEST.md).

## Chưa cài Remotion? Vẫn demo được
Máy chỉ có Claude Code + ChatCut: đi **Quy trình C** — `references/quy-trinh/ghep-nguyen-lieu-san-chatcut.md` — tải nguyên liệu dựng sẵn
(`assets/nguyen-lieu-video-2/`: tiếng · 4 cảnh icon · bản render trọn) lên ChatCut và ghép, không cần node. Cài Remotion sau cũng được.
Nói với Claude «demo tạo video có remotion icon» (đã cài Remotion) ⇒ `render.sh stage` ra đúng video mẫu 26/09 (md5 `182cc1e4`).

## Cần có
- macOS hoặc Linux · Node ≥ 18 · ffmpeg/ffprobe · Whisper (tuỳ chọn, để kiểm bản ra và lấy mốc từng chữ)
- Claude Code + tài khoản ChatCut (cho phần sửa phim bằng sửa chữ). Phần Remotion chạy không cần ChatCut.
- Không cần khoá API: icon và b-roll đã vẽ sẵn trong `assets/`.

## Trong repo
| thư mục | có gì |
|---|---|
| `assets/` | phim mẫu có tiếng · nền sạch · 3 ảnh + 3 clip b-roll · 38 icon (PNG + SVG) · 5 bản ra mẫu + bảng khung (bản Owner duyệt 26/09: `video-2-tao-lai-ghep-chatcut-v02.mp4`) · `nguyen-lieu-video-2/` nguyên liệu dựng sẵn cho máy chưa có Remotion |
| `references/` | chuỗi lệnh MCP · quy trình · luật rút từ video mẫu · dữ liệu mẫu · số đo |
| `scripts/` | tải lên · kiểm bản xuất · b-roll động · sinh icon SVG · sinh props · bảng khung |
| `scripts/remotion/` | mini-project Remotion 4.0.471 (5 composition) + `render.sh` tự kiểm |

## Giấy phép
© Eroca Thanh. Dùng để học. Phim mẫu có giọng người thật — dùng để học trong lớp, không đăng lại.
