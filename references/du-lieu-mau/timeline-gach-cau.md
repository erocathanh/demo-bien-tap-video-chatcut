# Dữ liệu mẫu — timelineMd đã gạch một câu (đã bỏ tên người thật)

> Rút từ lượt diễn tập 25/09/2026. Tên người nói đã thay bằng `‹người nói›`.
> Ba dòng `script-*` phía trên phải **chép nguyên từ `read_script` của phim mới** — không chép từ đây,
> vì chúng mang dấu phiên bản của đúng dòng thời gian đó.
> Cú pháp gạch: bọc NGUYÊN câu trong `~~ … ~~`, **không sửa chữ** trong câu (sửa chữ là sai luật `apply_script`).

```markdown
# Timeline

<!-- script-stamp: ‹chép từ read_script› -->
<!-- script-lib-stamp: ‹chép từ read_script› -->
<!-- script-timeline: ‹chép từ read_script› -->
<!-- script-track: ‹chép từ read_script› -->

<!-- script:body -->

## V1 <!-- 0–1091f / 36.4s -->

### phim-nguon.mp4 <!-- 0–1091f -->
[s1] Tối nay,
[s2] ở buổi một Bí mật AI,
[s3] ‹người nói› đang cùng bạn gỡ một câu hỏi.
[s4] Có AI rồi,
[s5] vì sao chủ vẫn ôm hết việc?
[s6] Nạp bản sắc thương hiệu để AI hiểu đúng doanh nghiệp.
[s7] Giao AI xử lý tệp và thao tác trên máy tính.
[s8] Tạo bài fanpage và kịch bản bằng một lệnh.
[s9] Phân tích khảo sát,
[s10] xuất báo cáo tổng hợp.
[s11] Tự động hóa việc lập mỗi ngày,
[s12] không phải nhắc.
[s13] ~~Hẹn bạn xem buổi hai Bí mật AI cùng ‹người nói› tối mai.~~
[s14] Bình luận email của bạn dưới bài này,
[s15] ‹người nói› gửi tặng skill vừa làm mẫu.
```

## Ba câu nhận b-roll và mốc khung trả về (sau khi đã cắt s13)
| câu | `find_transcript` trả | ảnh Codex |
|---|---|---|
| s6 «Nạp bản sắc thương hiệu…» | 304f → 395f | `vsl-broll-1-ban-sac-thuong-hieu.png` |
| s7 «Giao AI xử lý tệp…» | 424f → 505f | `vsl-broll-2-ai-thao-tac-may-tinh.png` |
| s9–s10 «Phân tích khảo sát, xuất báo cáo tổng hợp» | 637f → 707f | `vsl-broll-3-bao-cao-tong-hop.png` |

Chọn câu nhận b-roll: câu nêu một VIỆC nhìn thấy được (sổ thương hiệu, máy tính tự xếp tệp, biểu đồ).
Câu hỏi và câu chào thì để mặt người nói.
