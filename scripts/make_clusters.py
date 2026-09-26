#!/usr/bin/env python3
"""Build IconStory props (clusters) for the day-1 film from measured sentence times.

Sentence times are SOURCE seconds measured with ChatCut find_transcript on asset 5f0aa744
(uncut film bimatai-buoi-1-short-LOP-20260924-151108.mp4, 36.36 s), 26/09/2026.
Icons sit in the empty navy band under the picture (y 55-72 %), clear of the ChatCut caption band (73.6-78 %).
Usage: make_clusters.py > props-v8.json
"""
import json
import math

FPS = 30
LEAD = 3    # icon may enter up to 3 frames before the word (PM rule: at most ~5)
HOLD = 8    # keep the cluster a little after the sentence ends

# id: (start_s, end_s, what the words say)
SENT = {
    "s3":    (3.380, 5.070, "Thanh đang cùng bạn gỡ một câu hỏi"),
    "s4_5":  (6.051, 8.991, "Có AI rồi, vì sao chủ vẫn ôm hết việc?"),
    "s6":    (10.120, 13.171, "Nạp bản sắc thương hiệu để AI hiểu đúng doanh nghiệp"),
    "s7":    (14.120, 16.840, "Giao AI xử lý tệp và thao tác trên máy tính"),
    "s8":    (17.891, 20.351, "Tạo bài fanpage và kịch bản bằng một lệnh"),
    "s9_10": (21.230, 23.571, "Phân tích khảo sát, xuất báo cáo tổng hợp"),
    "s11_12": (24.591, 27.031, "Tự động hoá việc lặp mỗi ngày, không phải nhắc"),
    # s1-2 greeting and s13 invitation (28.145-31.330): NO icon, rest for the eye
    "s14_15": (32.460, 36.120, "Bình luận email của bạn dưới bài này, Thanh gửi tặng skill"),
}
LAST_FRAME = 1091


def fr(sec):
    return int(round(sec * FPS))


def span(key):
    a, b, _ = SENT[key]
    return max(0, fr(a) - LEAD), min(LAST_FRAME, fr(b) + HOLD)


def head_angle(x0, y0, cx, cy, x1, y1):
    # tangent at the end of a quadratic Bezier = control -> end
    return round(math.degrees(math.atan2(y1 - cy, x1 - cx)), 1)


def arrow(x0, y0, cx, cy, x1, y1, delay):
    return {"t": "arrow", "d": f"M {x0} {y0} Q {cx} {cy} {x1} {y1}",
            "head": {"x": x1, "y": y1, "angle": head_angle(x0, y0, cx, cy, x1, y1)}, "delay": delay}


SVG_SET = {f"icon-{n:02d}" for n in range(9, 22)}  # icon-set-02 is drawn as SVG by make_icons_svg.py (Owner 26/09)


def icon(src, x, y, size, mode="pop", delay=0):
    if src[:7] in SVG_SET:
        src = src.replace(".png", ".svg")
    return {"t": "icon", "src": f"icons/{src}", "x": x, "y": y, "size": size, "mode": mode, "delay": delay}


BAND_Y = 60.0          # % of height (PM 26/09: bigger icons, bottom edge >= 60 px above the caption band at 1414)
Y_PX = int(1920 * BAND_Y / 100)


def flow(src, dst, key):
    """source -> arrow -> target, the 'A leads to B' sentence."""
    f, t = span(key)
    return {"id": key, "from": f, "to": t, "items": [
        icon(src, 22, BAND_Y, 25, "fadeShrink", 0),
        arrow(385, Y_PX, 540, Y_PX - 80, 695, Y_PX, 5),
        icon(dst, 78, BAND_Y, 25, "fade", 13),
    ]}


clusters = []
f, t = span("s3")
clusters.append({"id": "s3", "from": f, "to": t, "items": [icon("icon-09-question.png", 50, 60, 15, "pop", 0)]})
f, t = span("s4_5")
clusters.append({"id": "s4_5", "from": f, "to": t, "items": [
    icon("icon-10-overloaded.png", 30, BAND_Y, 25, "pop", 0),
    icon("icon-11-robot-idle.png", 70, BAND_Y, 22, "pop", 30),  # robot pops on "vì sao chủ vẫn ôm..."
]})
clusters.append(flow("icon-12-brand-profile.png", "icon-02-claude.png", "s6"))
clusters.append(flow("icon-13-file-stack.png", "icon-14-laptop-cursor.png", "s7"))
f, t = span("s8")
clusters.append({"id": "s8", "from": f, "to": t, "items": [
    # the one cluster allowed 2 targets ("bằng một lệnh"): arrows drawn one AFTER the other, targets >= 5 frames apart
    icon("icon-15-command.png", 22, BAND_Y, 24, "fadeShrink", 0),
    arrow(380, 1130, 560, 1000, 722, 989, 5),
    icon("icon-16-fanpage-post.png", 78, 51.5, 20, "fade", 16),
    arrow(380, 1175, 560, 1260, 722, 1219, 18),
    icon("icon-17-script-page.png", 78, 63.5, 20, "fade", 29),
]})
clusters.append(flow("icon-18-bar-chart.png", "icon-19-report.png", "s9_10"))
f, t = span("s11_12")
cal = [icon("icon-20-calendar.png", 50, 58, 30, "pop", 0)]
for i in range(7):  # ticks pop one after another, 6 frames apart, across the calendar cells (x/y tuned to the drawn icon)
    # calendar: size 30 % at (50 %, 58 %) -> 324 px, scale 1.62 per viewBox unit; cell centres (25 + 25 i, 125)
    cal.append(icon("icon-08-check.png", round(38.75 + 3.75 * i, 2), 60.11, 3.4, "pop", 10 + 6 * i))
clusters.append({"id": "s11_12", "from": f, "to": t, "items": cal})
f, t = span("s14_15")
clusters.append({"id": "s14_15", "from": f, "to": t, "items": [
    icon("icon-21-gift.png", 30, BAND_Y, 22, "pop", 0),
    arrow(700, 1040, 735, 1190, 700, 1340, 4),  # CTA: arrow points DOWN to the comments (Owner rule 25/09)
]})

props = {"video": "nen-sach.mp4", "videoStartFrame": 0, "durationInFrames": LAST_FRAME,
         "rampFrames": 9, "softBlur": 3, "softDim": 0.25, "clusters": clusters}

if __name__ == "__main__":
    print(json.dumps(props, ensure_ascii=False, indent=1))
    import sys
    rest = [(0, clusters[0]["from"]), (clusters[-2]["to"], clusters[-1]["from"])]
    per10 = len(clusters) / (LAST_FRAME / FPS) * 10
    print(f"# clusters={len(clusters)} · per 10 s={per10:.2f} · rests(frames)={rest}", file=sys.stderr)
