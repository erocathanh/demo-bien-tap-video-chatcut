#!/usr/bin/env python3
"""Per scene: seconds from the moment the stage card is fully opaque (scene start + blank + 8 frames of the pop-in)
to the moment the first object starts to enter. Usage: measure_empty_stage.py props.json [limit_seconds]"""
import json
import sys

d = json.load(open(sys.argv[1]))
limit = float(sys.argv[2]) if len(sys.argv) > 2 else 0.6
over = 0
for s in d["scenes"]:
    opaque = s.get("blank", 0) + 8
    first = min(i["at"] for i in s["items"])
    gap = max(0, first - opaque) / 30
    flag = "OVER" if gap > limit else "ok"
    over += flag == "OVER"
    print(f"{s['id']:4} {s['from'] / 30:5.1f}s  empty {gap:4.2f}s  {flag}")
print(f"scenes over {limit}s: {over}")
