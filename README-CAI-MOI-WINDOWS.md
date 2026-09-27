# Cài phần mềm trên Windows 10/11

> Bước chung (tải bộ công cụ · kiểm máy · plugin ChatCut · bộ dựng video · kiểm): [README-CAI-MOI.md](README-CAI-MOI.md).
> Tệp này lo **bước 1 — cài phần mềm còn thiếu** trên Windows, và những điều riêng của Windows. Số đo lấy từ máy thử thật ngày 27/09/2026.

## Trước hết: chạy lệnh ở đâu
- Mọi lệnh `bash …` chạy trong **Git Bash** (cửa sổ dòng lệnh đi kèm Git). Claude Code trên Windows tự dùng Git Bash — nhờ Claude chạy là được.
- Lệnh `winget …` và `setx …` chạy được cả trong Git Bash lẫn PowerShell.
- Không dán lệnh bash vào **PowerShell** (cửa sổ xanh mặc định): `&&`, `~`, `head` ở đó không chạy như trên Mac.
- Đặt bộ công cụ ở `%USERPROFILE%\.claude\skills\demo-bien-tap-video-chatcut`. **Không** đặt trong OneDrive, Desktop hay Documents
  (đồng bộ OneDrive + thư mục tên tiếng Việt «Tài liệu» + đường dẫn quá dài dễ gây lỗi).

## Kiểm máy bằng PowerShell (khi chưa có Git Bash)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kiem-may.ps1
```
`Bypass` chỉ áp cho đúng lần chạy này, không đổi cài đặt máy. Kết quả giống `kiem-may.sh`.

## Cần gì
| phần mềm | để làm gì (nói thường) | bắt buộc? | lệnh cài | thời gian (đo 27/09) |
|---|---|---|---|---|
| Git for Windows | tải bộ công cụ + chạy script `.sh` | bắt buộc | `winget install -e --id Git.Git` | có sẵn trên máy thử |
| Node.js ≥ 18 | chạy xưởng dựng video + công cụ tải phim của ChatCut | bắt buộc | `winget install -e --id OpenJS.NodeJS.LTS` | 33 giây (có hộp hỏi quyền — bấm **Yes**) |
| FFmpeg | đọc và kiểm tra video | bắt buộc | `winget install -e --id Gyan.FFmpeg` | 185 giây (tải ~200 MB) |
| Python 3 thật (3.10–3.13) | công cụ phụ: chia phụ đề, làm bảng hình | bắt buộc cho «Video icon kể chuyện» | `winget install -e --id Python.Python.3.12 --scope user` | 80 giây |
| Chữ tiếng Việt cho Python | tránh lỗi khi ghi chữ có dấu | nên có | `setx PYTHONUTF8 1` | tức thì |
| Pillow | vẽ bảng hình có nhãn giây | tuỳ chọn | `python -m pip install pillow` | 10 giây |
| Whisper | nghe lại lời trong video để kiểm câu đã xoá | tuỳ chọn | `python -m pip install -U openai-whisper` | 533 giây (~9 phút, ~1 GB) |

Cần khoảng **3 GB** đĩa trống. Windows trên chip **ARM** (Snapdragon): bộ dựng video không chạy ⇒ chỉ làm được «Sửa phim bằng sửa chữ».

## 🔴 Cài xong phải TẮT HẲN Claude rồi mở lại
Cửa sổ Claude đang mở không «nhìn thấy» phần mềm vừa cài. Chuột phải biểu tượng Claude ở góc phải thanh tác vụ → **Quit**, mở lại, gõ «tiếp tục».
`kiem-may.sh` phân biệt được «chưa cài» (❌) với «đã cài nhưng cửa sổ này chưa thấy» (⚠️).

## Mấy điều riêng của Windows
- `python3` trên Windows thường chỉ là **lối tắt của Microsoft Store**, kể cả khi đã cài Python. Bộ công cụ tự gọi Python qua `bash scripts/py.sh …`.
- Lần render đầu, tường lửa Windows có thể hỏi quyền mạng cho Node.js: bấm **Cho phép** hay **Huỷ** đều render được.
- Mở video cho người dùng xem: Git Bash `start "" "$(cygpath -w "<tệp>.mp4")"` · PowerShell `Invoke-Item "<tệp>.mp4"`.
- Khung trình duyệt trong app Claude: **Ctrl+Shift+B**.
- Tải bản xuất từ ChatCut: Git Bash `curl -fsSL --create-dirs -o "out/<tên>.mp4" "<link>"` · PowerShell dùng `curl.exe` (không phải `curl`).

## Tải phim CÓ TIẾNG lên ChatCut có thể phải bấm tay một lần
Plugin ChatCut bản 1.10.14 có lỗi trên Windows: phim có tiếng tải lên bị hỏng (hình minh hoạ không tiếng thì qua). Khi gặp lỗi này,
`scripts/upload.sh` tự chép phim vào thư mục **Downloads** và chép sẵn đường dẫn vào bộ nhớ tạm. Bạn chỉ cần:
bấm vào thẻ phim có chữ **«Click to relink»** trên trang ChatCut → trong cửa sổ hiện ra bấm ô **File name** → **Ctrl+V** → **Enter**. Xong nhắn «xong».
Lỗi này nằm ở plugin ChatCut (mô tả tiếng Anh ở `references/gop-y-windows/BAO-LOI-CHATCUT_v1.0.md`, **chưa gửi** cho ChatCut). Khi ChatCut sửa thì bước bấm tay này sẽ bỏ.

## Số đo trên Windows (i9-14900HX, máy mới, 27/09/2026)
| việc | Windows | Mac (để so) |
|---|---|---|
| `npm ci` | 30 giây (chưa có npm cache) | 19 giây |
| `render.sh broll` lần đầu | 160 giây (gồm tải trình duyệt ẩn 270 MB) | 31 giây |
| `render.sh stage` | 64–70 giây | 29 giây |
| Whisper 66 giây tiếng | 59 giây | 47 giây |
| `verify-export.sh` có Whisper | 34 giây | khoảng 23 giây |
| «Sửa phim bằng sửa chữ» — render trên mây | 28,9 giây | 17,7–20,5 giây |
| «Sửa phim bằng sửa chữ» — mã kiểm bản ra | `5656a249` — trùng từng byte với Mac | `5656a249` |
