#!/usr/bin/env python3
# Build 5x4 contact sheets from khung/k%04d.png (2 fps) with a seconds label per tile.
# ffmpeg on this machine has no drawtext filter, so we label with Pillow instead.
import glob, os, sys
from PIL import Image, ImageDraw, ImageFont

# Windows: stdout/stderr default to cp1252 and CRLF; force UTF-8 and LF so output is identical on every OS.
sys.stdout.reconfigure(encoding="utf-8", newline="\n")
sys.stderr.reconfigure(encoding="utf-8")

src_dir = sys.argv[1]
out_dir = sys.argv[2]
fps = float(sys.argv[3]) if len(sys.argv) > 3 else 2.0
offset = float(sys.argv[4]) if len(sys.argv) > 4 else 0.0
prefix = sys.argv[5] if len(sys.argv) > 5 else "bang"
# optional: cols rows (default 5x4); 6 5 gives 30 tiles = one second per sheet at 30 fps
cols = int(sys.argv[6]) if len(sys.argv) > 6 else 5
rows = int(sys.argv[7]) if len(sys.argv) > 7 else 4
# optional: label decimals (default 1; use 2 or 3 at 30 fps so neighbouring tiles differ)
decimals = int(sys.argv[8]) if len(sys.argv) > 8 else 1
tile_w, tile_h = 270, 480
pad = 6
os.makedirs(out_dir, exist_ok=True)

frames = sorted(glob.glob(os.path.join(src_dir, "k*.png")) + glob.glob(os.path.join(src_dir, "k*.jpg")))
# Seconds label font: macOS -> Windows -> Linux; last resort Pillow's own font at the same size (Pillow >= 10.1).
font = None
for cand in ("/System/Library/Fonts/Supplemental/Arial Bold.ttf", r"C:\Windows\Fonts\arialbd.ttf",
             "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", "DejaVuSans-Bold.ttf"):
    try:
        font = ImageFont.truetype(cand, 30)
        break
    except Exception:
        pass
if font is None:
    try:
        font = ImageFont.load_default(size=30)
    except TypeError:  # Pillow < 10.1 has no size argument
        font = ImageFont.load_default()

per_sheet = cols * rows
sheet_no = 0
for start in range(0, len(frames), per_sheet):
    chunk = frames[start:start + per_sheet]
    sheet_no += 1
    W = cols * tile_w + (cols + 1) * pad
    H = rows * tile_h + (rows + 1) * pad
    sheet = Image.new("RGB", (W, H), (255, 255, 255))
    draw = ImageDraw.Draw(sheet)
    for i, fp in enumerate(chunk):
        idx = start + i
        t = offset + idx / fps
        im = Image.open(fp).convert("RGB").resize((tile_w, tile_h))
        r, c = divmod(i, cols)
        x = pad + c * (tile_w + pad)
        y = pad + r * (tile_h + pad)
        sheet.paste(im, (x, y))
        label = f"{t:.{decimals}f}s" if decimals <= 1 else f"{t:.{decimals}f}s f{idx}"
        bbox = draw.textbbox((0, 0), label, font=font)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        draw.rectangle([x + 6, y + 6, x + 6 + tw + 12, y + 6 + th + 12], fill=(0, 0, 0))
        draw.text((x + 12, y + 8), label, font=font, fill=(255, 230, 0))
    first_t = offset + start / fps
    last_t = offset + (start + len(chunk) - 1) / fps
    out = os.path.join(out_dir, f"{prefix}{sheet_no:02d}_{first_t:05.1f}s-{last_t:05.1f}s.png")
    sheet.save(out)
    print(out)
