#!/usr/bin/env python3
"""Build IconStage props (one stage per spoken sentence, sample-08 layout) from
   (a) the script table (markdown, 5 or 6 columns: # | lời | chữ mở | chữ cần vật | vật gì | sân khấu),
   (b) whisper word timestamps of the voice track (whisper --word_timestamps True --output_format json),
   (c) a visual plan JSON written by the video seat: per row, which layout kind and which icon goes with which word.

Timing rules (sample 08 report, measured 26/09/2026):
  - scene starts a few frames before the first spoken word and HARD-CUTS at the next scene; 3 empty frames between scenes
  - each object pops within +-3 frames of its word (we use 2 frames early); objects in one scene are >= 4 frames apart
    so only one main motion happens at a time; lists pop one after another on a symmetric grid
  - captions are 2-4 word chunks, broken at punctuation, no karaoke
The script text is the truth: whisper mishears words ("ngạp" for "nạp"), so script tokens are aligned to whisper tokens
with difflib and unmatched script tokens get times interpolated from their matched neighbours.

Usage: make_stage_props.py <script.md> <whisper.json> <plan.json> [--audio voice.wav] [--face nen-sach.mp4:150:50% 30%] [--out props.json]
       (without --out the JSON goes to stdout)
"""
import argparse
import difflib
import json
import re
import sys
import unicodedata

FPS = 30
LEAD_SCENE = 4   # scene (stage card) appears this many frames before the first word
LEAD_ITEM = 2    # object pops this many frames before its word (sample: +-3)
MIN_GAP = 4      # frames between two object entrances in one scene
BLANK = 3        # empty frames at the start of every scene after the first (hard cut, sample 08)
CAP_MAX = 3      # words per caption chunk (sample: 2-4)
TAIL = 12        # frames the last scene holds after the last word

# layout constants, % of frame; stage card: full 17-75 % H, split 5-45 % H
BOX = {"full": {"cy": 46, "top": 17, "bot": 75}, "split": {"cy": 25, "top": 5, "bot": 45}}
SIZE_MAIN, SIZE_FLOW = 30, 26


def norm(w):
    w = unicodedata.normalize("NFC", w.lower())
    return re.sub(r"[^\w]", "", w)


def tokens(text):
    return [t for t in re.split(r"\s+", text.strip()) if norm(t)]


def fr(sec):
    return int(round(sec * FPS))


def parse_script(path):
    rows = []
    for line in open(path, encoding="utf-8"):
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 5 or not re.fullmatch(r"\d+", cells[0]):
            continue
        # 6-column table has a full/split column; a 5-column table describes the picture instead,
        # so the layout then comes from the plan (default full)
        last = cells[5] if len(cells) >= 6 else ""
        rows.append({"n": int(cells[0]), "text": cells[1], "open": cells[2], "words": cells[3], "object": cells[4],
                     "stage": "split" if "chia" in last.lower() else "full"})
    if not rows:
        sys.exit("no script rows found (expected a markdown table whose first column is the sentence number)")
    return rows


def whisper_words(path):
    d = json.load(open(path, encoding="utf-8"))
    out = []
    for s in d["segments"]:
        for w in s.get("words", []):
            if norm(w["word"]):
                out.append({"w": norm(w["word"]), "start": w["start"], "end": w["end"]})
    return out


def align(rows, ww):
    """Give every script token a (start, end) time; return per-row token lists."""
    script = []
    for r in rows:
        for t in tokens(r["text"]):
            script.append({"row": r["n"], "raw": t, "w": norm(t), "start": None, "end": None})
    sm = difflib.SequenceMatcher(a=[s["w"] for s in script], b=[w["w"] for w in ww], autojunk=False)
    for a, b, n in sm.get_matching_blocks():
        for k in range(n):
            script[a + k]["start"], script[a + k]["end"] = ww[b + k]["start"], ww[b + k]["end"]
    # replace-blocks of equal length (misheard words like "ngạp"/"nạp") take the whisper times one to one
    for tag, a0, a1, b0, b1 in sm.get_opcodes():
        if tag == "replace" and a1 - a0 == b1 - b0:
            for k in range(a1 - a0):
                script[a0 + k]["start"], script[a0 + k]["end"] = ww[b0 + k]["start"], ww[b0 + k]["end"]
    # interpolate the rest between matched neighbours
    known = [i for i, s in enumerate(script) if s["start"] is not None]
    if not known:
        sys.exit("alignment failed: no script word matched the whisper transcript")
    for i, s in enumerate(script):
        if s["start"] is not None:
            continue
        prev = max([k for k in known if k < i], default=None)
        nxt = min([k for k in known if k > i], default=None)
        if prev is None:
            s["start"] = s["end"] = script[nxt]["start"]
        elif nxt is None:
            s["start"] = s["end"] = script[prev]["end"]
        else:
            t0, t1 = script[prev]["end"], script[nxt]["start"]
            f = (i - prev) / (nxt - prev)
            s["start"] = s["end"] = t0 + (t1 - t0) * f
    by_row = {}
    for s in script:
        by_row.setdefault(s["row"], []).append(s)
    unmatched = len(script) - len(known)
    return by_row, unmatched, len(script)


def find_word(toks, phrase):
    """Start time of the first occurrence of `phrase` (one or more words) in the sentence tokens."""
    p = [norm(x) for x in phrase.split() if norm(x)]
    ws = [t["w"] for t in toks]
    for i in range(len(ws) - len(p) + 1):
        if ws[i:i + len(p)] == p:
            return toks[i]["start"]
    raise SystemExit(f"plan word '{phrase}' not found in sentence: {' '.join(t['raw'] for t in toks)}")


def grid_x(i, n, size, gap):
    return 50 + (i - (n - 1) / 2) * (size + gap)


def layout_items(kind, spec, ats, box):
    """Place objects for one scene. `ats` = entrance frame (scene-relative) per object, already spaced."""
    cy, top, bot = box["cy"], box["top"], box["bot"]
    objs = spec.get("objects", [])
    items = []
    if kind == "stairs":
        lvl = spec["level"]
        items.append({"t": "pill", "at": ats[0], "text": spec.get("pill", f"CẤP {lvl}"), "x": 50, "y": top + 5})
        items.append({"t": "stairs", "at": ats[0] + MIN_GAP, "x": 50, "y": bot - 5, "steps": spec.get("steps", 3),
                      "shown": spec.get("shown", lvl), "active": lvl, "w": 64, "ping": True})
        for k, o in enumerate(objs):  # left of the stairs: the lowest step is on the left, so there is room above it
            items.append({"t": "icon", "at": ats[k + 1], "src": o["icon"], "x": 24, "y": top + 14, "size": 20})
    elif kind == "single":
        items.append({"t": "icon", "at": ats[0], "src": objs[0]["icon"], "x": 50, "y": cy - 6, "size": SIZE_MAIN, "motion": "spring"})
        rest = objs[1:]
        size = 18 if len(rest) <= 4 else 16
        for k, o in enumerate(rest):
            items.append({"t": "icon", "at": ats[k + 1], "src": o["icon"], "x": round(grid_x(k, len(rest), size, 3.5), 2),
                          "y": cy + 13, "size": size})
    elif kind == "grid":
        size = 18 if len(objs) <= 4 else 16
        for k, o in enumerate(objs):
            items.append({"t": "icon", "at": ats[k], "src": o["icon"], "x": round(grid_x(k, len(objs), size, 3.5), 2), "y": cy, "size": size})
    elif kind == "flow":
        y = cy
        items.append({"t": "icon", "at": ats[0], "src": objs[0]["icon"], "x": 27, "y": y, "size": SIZE_FLOW})
        targets = objs[1:]
        ypx = 1920 * y / 100
        if len(targets) == 1:
            items.append({"t": "line", "at": ats[1] - 6, "d": f"M 440 {ypx:.0f} Q 540 {ypx - 90:.0f} 640 {ypx:.0f}", "head": True})
            items.append({"t": "icon", "at": ats[1], "src": targets[0]["icon"], "x": 73, "y": y, "size": SIZE_FLOW})
        else:  # one source, two stacked targets, arrows drawn one after the other
            for k, o in enumerate(targets[:2]):
                ty = y - 11 + 22 * k
                typx = 1920 * ty / 100
                items.append({"t": "line", "at": ats[k + 1] - 6, "d": f"M 440 {ypx:.0f} Q 560 {(ypx + typx) / 2:.0f} 650 {typx:.0f}", "head": True})
                items.append({"t": "icon", "at": ats[k + 1], "src": o["icon"], "x": 73, "y": ty, "size": 20})
    elif kind == "contrast":
        a, b = objs[0], objs[1]
        items.append({"t": "icon", "at": ats[0], "src": a["icon"], "x": 50, "y": cy - 12, "size": 26})
        apx, half = 1920 * (cy - 12) / 100, 1080 * 0.26 / 2 + 50
        items.append({"t": "line", "at": ats[1], "d": f"M {540 - half:.0f} {apx + 30:.0f} L {540 + half:.0f} {apx - 30:.0f}", "strike": True})
        items.append({"t": "icon", "at": ats[2], "src": b["icon"], "x": 50, "y": cy + 14, "size": 26, "motion": "spring"})
    else:
        raise SystemExit(f"unknown kind {kind}")
    return items


def entrance_frames(toks, spec, scene_from, first_allowed):
    """One entrance frame per timed thing, in the order layout_items consumes them."""
    kind = spec["kind"]
    words = [o["word"] for o in spec.get("objects", [])]
    if kind == "stairs":
        words = [spec.get("word", toks[0]["raw"])] + words
    if kind == "contrast":
        words = [words[0], spec["strike_word"], words[1]]
    ats, last = [], first_allowed - MIN_GAP
    for k, w in enumerate(words):
        a = fr(find_word(toks, w)) - LEAD_ITEM - scene_from
        if k == 0 and spec.get("early"):  # main object rides in with the stage at the first word (sample: stage pops at the opening word)
            a = fr(toks[0]["start"]) - LEAD_ITEM - scene_from
        a = max(a, first_allowed, last + MIN_GAP)
        ats.append(a)
        last = a
    return ats


# Vietnamese function words that are good places to START a new chunk (break before them)
BREAK_BEFORE = {"và", "để", "trên", "bằng", "của", "cho", "với", "là", "mà", "thì", "nhưng", "hay", "hoặc", "khi", "rồi", "từ", "ở"}


def caption_chunks(toks):
    """2-4 word chunks: break at punctuation or before a function word; hard limit 4 words."""
    chunks, cur = [], []
    for i, t in enumerate(toks):
        cur.append(t)
        nxt = toks[i + 1]["w"] if i + 1 < len(toks) else None
        punct = re.search(r"[,.:;!?]$", t["raw"])
        soft = len(cur) >= 2 and nxt in BREAK_BEFORE
        if punct or soft or len(cur) >= 4 or (len(cur) >= CAP_MAX and nxt is not None and i + 2 < len(toks)):
            chunks.append(cur)
            cur = []
    if cur:
        if len(cur) == 1 and chunks and len(chunks[-1]) < 4:
            chunks[-1] += cur
        else:
            chunks.append(cur)
    return chunks


def main():
    sys.stdout.reconfigure(encoding="utf-8", newline="\n")  # Windows: cp1252 + CRLF by default
    sys.stderr.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("script")
    ap.add_argument("whisper")
    ap.add_argument("plan")
    ap.add_argument("--audio")
    ap.add_argument("--face", help="video:startFrame:objectPosition (video relative to the Remotion public/ folder)")
    ap.add_argument("--out", help="write the props JSON to this file (UTF-8, LF) instead of stdout")
    a = ap.parse_args()

    rows = parse_script(a.script)
    ww = whisper_words(a.whisper)
    by_row, unmatched, total = align(rows, ww)
    plan = json.load(open(a.plan, encoding="utf-8"))["rows"]

    starts = [fr(by_row[r["n"]][0]["start"]) for r in rows]
    end_all = fr(by_row[rows[-1]["n"]][-1]["end"]) + TAIL
    scenes, captions, report = [], [], []
    for i, r in enumerate(rows):
        toks = by_row[r["n"]]
        s_from = 0 if i == 0 else starts[i] - LEAD_SCENE
        s_to = (starts[i + 1] - LEAD_SCENE) if i + 1 < len(rows) else end_all
        blank = 0 if i == 0 else BLANK
        spec = plan[str(r["n"])]
        r["stage"] = spec.get("layout", r["stage"])
        box = BOX[r["stage"]]
        ats = entrance_frames(toks, spec, s_from, blank + 1)
        items = layout_items(spec["kind"], spec, ats, box)
        scenes.append({"id": f"c{r['n']}", "from": s_from, "to": s_to, "layout": r["stage"], "blank": blank, "items": items})
        chunks = caption_chunks(toks)
        if spec.get("chunks"):  # manual chunking of the approved words (no new words): list of word counts per chunk
            counts = spec["chunks"]
            if sum(counts) != len(toks):
                raise SystemExit(f"row {r['n']}: chunks {counts} sum to {sum(counts)}, sentence has {len(toks)} words")
            chunks, k = [], 0
            for n in counts:
                chunks.append(toks[k:k + n])
                k += n
        for c in chunks:
            captions.append({"from": max(fr(c[0]["start"]), s_from), "text": " ".join(t["raw"] for t in c).rstrip(",.;:"), "cut": s_to})
        report.append(f"# c{r['n']} {r['stage']:5} {s_from}-{s_to} ({(s_to - s_from) / FPS:.1f}s) {spec['kind']:8} items={len(items)} ats={ats}")
    for k, c in enumerate(captions):  # each chunk lasts until the next one starts (or the end)
        c["to"] = min(captions[k + 1]["from"] if k + 1 < len(captions) else end_all, c.pop("cut"))  # never spill into the next scene
    props = {"durationInFrames": end_all, "scenes": scenes, "captions": captions}
    if a.audio:
        props["audio"] = a.audio
    if a.face:
        parts = a.face.rsplit(":", 2)  # rsplit: a Windows drive letter "D:" must not split the video name
        if len(parts) != 3 or not parts[1].isdigit():
            sys.exit(f"--face must be video:startFrame:objectPosition, got {a.face!r}")
        v, sf, pos = parts
        if v.startswith(("/", "\\")) or re.match(r"^[A-Za-z]:", v) or v.replace("\\", "/").startswith("public/"):
            sys.exit(f"--face video must be a name relative to the Remotion public/ folder (e.g. nen-sach.mp4), got {v!r}")
        props["face"] = {"video": v, "startFrame": int(sf), "objectPosition": pos}
    text = json.dumps(props, ensure_ascii=False, indent=1) + "\n"
    if a.out:
        with open(a.out, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(text)
    else:
        sys.stdout.write(text)
    events = sum(len(s["items"]) for s in scenes) + len(scenes)
    print("\n".join(report), file=sys.stderr)
    print(f"# sentences={len(rows)} · script words={total} · aligned by interpolation={unmatched} · "
          f"graphic events={events} ({events / (end_all / FPS) * 10:.1f} per 10 s, sample 08 = 13) · captions={len(captions)}",
          file=sys.stderr)


if __name__ == "__main__":
    main()
