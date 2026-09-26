# Luật rút từ hai Short mẫu (đo khung 30 fps, 25–26/09/2026) — bản tóm tắt

Hai video mẫu là của người khác nên KHÔNG kèm trong gói; đây chỉ là số đo và luật rút ra.

## Mẫu 07 — icon + mũi tên đè lên người nói (IconOverlay / IconStory)
- Vật nguồn vào bằng mờ + co từ 1,2 (khoảng 10 khung), trôi lên nhẹ; vật đích vào bằng mờ ease-out 21 khung, không nảy.
- Nút/huy hiệu bật lò xo từ 0,2, vượt khoảng 9 % ở khung 7–8, đứng ở khung 12–13.
- Mũi tên vẽ nét TUYẾN TÍNH khoảng 43 px/khung, đầu mũi tên vẽ trong 2 khung từ 90 % thân.
- Cả cụm ra bằng mờ TUYẾN TÍNH 15 khung, phóng nhẹ tới khoảng 1,12.
- Luật đặt icon theo lời: icon bật tối đa 3–5 khung trước chữ của nó; câu chào/mời không cần icon (nghỉ mắt);
  khoảng 2 cụm / 10 giây; không đè dải phụ đề (đo bằng `scripts/check-caption-band.sh`).

## Mẫu 08 — sân khấu theo câu (IconStage)
- 16/19 câu có vật MỚI bật đúng lúc nói; trung bình 13 sự kiện đồ hoạ / 10 giây (dải 7–16); tối đa 5 vật cùng lúc.
- Mỗi câu một «sân khấu»: bật 0,2–0,5 s trước danh từ chính; từng vật bật trong ±3 khung quanh chữ của nó.
- Liệt kê = các vật cùng cỡ xếp lưới đối xứng quanh tâm, mục cũ đứng yên, cách nhau 0,7–1,2 s.
- Vật giữ tới hết câu rồi CẮT CỨNG cả cảnh; nền trống 0,1–0,4 s giữa hai cảnh; rất hiếm khi cross-fade.
- Phụ đề: cụm 2–4 chữ, trắng đậm trên hộp xám mờ, ở 79 % chiều cao (toàn màn) hoặc 60 % (chia đôi), không tô từng chữ.
- Khung chia đôi (nửa dưới là người) chiếm khoảng 21 % thời lượng: câu mở, câu chuyển ý lớn, câu kêu gọi.
- Chuyển động: bật = mờ + phóng cubic-out 6–8 khung (0,62 → 1) · lò xo vượt ≤ 4,5 % (stiffness ≈ 480, damping ≈ 31 —
  mặc định của Remotion vượt khoảng 16 %, quá mềm) · vòng lan cubic-out 24 khung · gạch/nét cubic-out 9 khung ·
  biểu đồ/thanh % chạy tuyến tính · rơi khoảng 60 px/khung, không nảy.
- Không nhạc nền; vài tiếng hiệu ứng ở cú gạch.
