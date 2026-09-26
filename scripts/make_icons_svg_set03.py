#!/usr/bin/env python3
"""Draw icons 22-38 for video 2 as SVG, same hand as icon-set-02 (make_icons_svg.py next to this script).

House palette only; bodies cream/gold with navy details, 200x200 viewBox, transparent background, no letters or numbers.
These sit on a navy tile on the cream stage card (IconStage card=true), so cream bodies read well.
Usage: make_icons_svg_set03.py <out_dir>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_icons_svg import C, G, N, T, W, bar, svg  # noqa: E402

ICONS = {}


def bubble(x, y, w, h, fill, tail_left=True):
    tx = x + 24 if tail_left else x + w - 24
    d = -1 if tail_left else 1
    return (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="18" fill="{fill}"/>'
            f'<path d="M {tx - 10 * d} {y + h - 2} L {tx + 18 * d} {y + h + 22} L {tx + 14 * d} {y + h - 2} Z" fill="{fill}"/>')


# 22 business owner: head + shoulders with a tie
ICONS["icon-22-owner"] = svg(
    f'<circle cx="100" cy="62" r="32" fill="{C}"/>'
    f'<path d="M 38 184 Q 38 112 100 112 Q 162 112 162 184 Z" fill="{C}"/>'
    f'<path d="M 92 114 L 108 114 L 104 128 L 112 168 L 100 180 L 88 168 L 96 128 Z" fill="{G}"/>'
    f'<path d="M 78 114 L 100 140 L 122 114" fill="none" stroke="{N}" stroke-width="5" stroke-linejoin="round"/>')

# 23 chat bubble with a question mark
ICONS["icon-23-chat-question"] = svg(
    bubble(24, 36, 152, 108, C)
    + f'<path d="M 82 72 Q 82 54 100 54 Q 120 54 120 72 Q 120 84 106 90 Q 100 93 100 102" fill="none" stroke="{N}" stroke-width="12" stroke-linecap="round"/>'
    f'<circle cx="100" cy="122" r="8" fill="{N}"/>')

# 24 answer bubble: gold bubble (right tail) with three text bars
ICONS["icon-24-chat-answer"] = svg(
    bubble(24, 36, 152, 108, G, tail_left=False) + bar(46, 62, 108, 10) + bar(46, 84, 90, 10) + bar(46, 106, 60, 10))

# 25 magnifier over a page
ICONS["icon-25-search"] = svg(
    f'<rect x="30" y="24" width="104" height="136" rx="12" fill="{C}"/>'
    + bar(48, 48, 66) + bar(48, 68, 50) + bar(48, 88, 60)
    + f'<circle cx="122" cy="118" r="34" fill="{N}" stroke="{G}" stroke-width="12"/>'
    f'<line x1="146" y1="142" x2="176" y2="172" stroke="{G}" stroke-width="16" stroke-linecap="round"/>')

# 26 globe
ICONS["icon-26-globe"] = svg(
    f'<circle cx="100" cy="100" r="72" fill="{C}"/>'
    f'<ellipse cx="100" cy="100" rx="32" ry="72" fill="none" stroke="{N}" stroke-width="6"/>'
    f'<line x1="28" y1="100" x2="172" y2="100" stroke="{N}" stroke-width="6"/>'
    f'<path d="M 40 64 Q 100 80 160 64 M 40 136 Q 100 120 160 136" fill="none" stroke="{N}" stroke-width="6"/>'
    f'<circle cx="100" cy="100" r="72" fill="none" stroke="{G}" stroke-width="8"/>')

# 27 task board: three columns with cards
cols = ""
for i, n in enumerate((3, 2, 1)):
    x = 30 + i * 50
    cols += f'<rect x="{x}" y="46" width="40" height="120" rx="8" fill="{N}" opacity="0.18"/>'
    for k in range(n):
        cols += f'<rect x="{x + 5}" y="{54 + k * 36}" width="30" height="28" rx="5" fill="{G if i == 2 else N}"/>'
ICONS["icon-27-task-board"] = svg(f'<rect x="20" y="26" width="160" height="152" rx="16" fill="{C}"/>{cols}')

# 28 keyboard
keys = ""
for r in range(3):
    for c in range(6 - (1 if r == 2 else 0)):
        keys += f'<rect x="{34 + c * 23 + (11 if r == 2 else 0)}" y="{70 + r * 22}" width="18" height="16" rx="4" fill="{N}"/>'
ICONS["icon-28-keyboard"] = svg(
    f'<rect x="20" y="54" width="160" height="104" rx="14" fill="{C}"/>{keys}'
    f'<rect x="60" y="136" width="80" height="12" rx="5" fill="{G}"/>')

# 29 conveyor belt with two boxes and gears
ICONS["icon-29-conveyor"] = svg(
    f'<rect x="56" y="62" width="34" height="34" rx="5" fill="{G}"/><rect x="112" y="62" width="34" height="34" rx="5" fill="{T}"/>'
    f'<rect x="20" y="104" width="160" height="40" rx="20" fill="{C}"/>'
    + "".join(f'<circle cx="{44 + 37 * i}" cy="124" r="11" fill="{N}"/><circle cx="{44 + 37 * i}" cy="124" r="4" fill="{C}"/>' for i in range(4))
    + f'<rect x="36" y="150" width="10" height="26" fill="{C}"/><rect x="154" y="150" width="10" height="26" fill="{C}"/>')


def gear(cx, cy, r, teeth, fill, hole):
    import math
    pts = []
    for i in range(teeth * 2):
        a = math.pi * i / teeth
        rr = r if i % 2 == 0 else r * 0.78
        for da in (-0.12, 0.12):
            pts.append(f"{cx + rr * math.cos(a + da):.1f},{cy + rr * math.sin(a + da):.1f}")
    return f'<polygon points="{" ".join(pts)}" fill="{fill}"/><circle cx="{cx}" cy="{cy}" r="{hole}" fill="{N}"/>'


# 30 gear pair
ICONS["icon-30-gear"] = svg(gear(84, 104, 58, 10, G, 20) + gear(150, 58, 30, 8, C, 10))

# 31 loop: two curved arrows chasing each other
ICONS["icon-31-loop"] = svg(
    f'<path d="M 40 100 A 60 60 0 0 1 150 66" fill="none" stroke="{G}" stroke-width="18" stroke-linecap="round"/>'
    f'<path d="M 132 44 L 162 64 L 130 84 Z" fill="{G}"/>'
    f'<path d="M 160 100 A 60 60 0 0 1 50 134" fill="none" stroke="{C}" stroke-width="18" stroke-linecap="round"/>'
    f'<path d="M 68 156 L 38 136 L 70 116 Z" fill="{C}"/>')

# 32 email envelope
ICONS["icon-32-email"] = svg(
    f'<rect x="22" y="46" width="156" height="108" rx="12" fill="{C}"/>'
    f'<path d="M 28 54 L 100 110 L 172 54" fill="none" stroke="{N}" stroke-width="8" stroke-linejoin="round"/>'
    f'<path d="M 28 148 L 80 100 M 172 148 L 120 100" stroke="{N}" stroke-width="6"/>')

# 33 message: two stacked bubbles
ICONS["icon-33-message"] = svg(
    bubble(20, 28, 120, 66, C) + bar(40, 52, 76, 9)
    + bubble(62, 108, 118, 58, G, tail_left=False) + bar(80, 130, 80, 9))

# 34 task card with a check box
ICONS["icon-34-task-card"] = svg(
    f'<rect x="30" y="30" width="140" height="140" rx="16" fill="{C}"/>'
    f'<rect x="48" y="52" width="30" height="30" rx="7" fill="none" stroke="{N}" stroke-width="6"/>'
    f'<path d="M 54 67 L 62 75 L 76 58" fill="none" stroke="{T}" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>'
    + bar(90, 58, 60) + bar(90, 74, 42) + bar(48, 110, 104) + bar(48, 130, 80))

# 35 relaxed person: head, arms behind the head
ICONS["icon-35-relax"] = svg(
    f'<circle cx="100" cy="70" r="28" fill="{C}"/>'
    f'<path d="M 72 70 Q 50 40 64 30 M 128 70 Q 150 40 136 30" fill="none" stroke="{C}" stroke-width="12" stroke-linecap="round"/>'
    f'<path d="M 44 182 Q 44 112 100 112 Q 156 112 156 182 Z" fill="{C}"/>'
    f'<path d="M 86 76 Q 100 88 114 76" fill="none" stroke="{N}" stroke-width="5" stroke-linecap="round"/>'
    f'<circle cx="90" cy="64" r="4" fill="{N}"/><circle cx="110" cy="64" r="4" fill="{N}"/>')

# 36 dashboard: panel with a gauge, bars and a status light
ICONS["icon-36-dashboard"] = svg(
    f'<rect x="18" y="34" width="164" height="132" rx="16" fill="{C}"/>'
    f'<path d="M 38 124 A 42 42 0 0 1 122 124" fill="none" stroke="{N}" stroke-width="12" stroke-linecap="round"/>'
    f'<path d="M 38 124 A 42 42 0 0 1 104 90" fill="none" stroke="{G}" stroke-width="12" stroke-linecap="round"/>'
    f'<line x1="80" y1="124" x2="100" y2="96" stroke="{N}" stroke-width="6" stroke-linecap="round"/><circle cx="80" cy="124" r="7" fill="{N}"/>'
    f'<rect x="136" y="100" width="12" height="40" rx="4" fill="{G}"/><rect x="154" y="84" width="12" height="56" rx="4" fill="{T}"/>'
    f'<circle cx="152" cy="58" r="9" fill="{T}"/>' + bar(38, 150, 70, 6))

# 37 broken chain: two links pulled apart with a small spark gap
ICONS["icon-37-chain-broken"] = svg(
    f'<rect x="18" y="74" width="74" height="44" rx="22" fill="none" stroke="{C}" stroke-width="14" transform="rotate(-14 55 96)"/>'
    f'<rect x="108" y="82" width="74" height="44" rx="22" fill="none" stroke="{C}" stroke-width="14" transform="rotate(-14 145 104)"/>'
    f'<path d="M 100 56 L 96 76 M 118 64 L 108 80 M 82 62 L 88 80" stroke="{G}" stroke-width="7" stroke-linecap="round"/>'
    f'<path d="M 100 150 L 104 130 M 82 142 L 92 126 M 118 144 L 112 126" stroke="{G}" stroke-width="7" stroke-linecap="round"/>')

# 38 phone showing a follow button (plus sign) and a heart
ICONS["icon-38-follow"] = svg(
    f'<rect x="50" y="14" width="100" height="172" rx="18" fill="{C}"/>'
    f'<rect x="60" y="32" width="80" height="120" rx="8" fill="{N}"/>'
    f'<circle cx="100" cy="72" r="18" fill="{C}"/>'
    f'<rect x="72" y="108" width="56" height="26" rx="13" fill="{T}"/>'
    f'<path d="M 100 113 L 100 129 M 92 121 L 108 121" stroke="{W}" stroke-width="5" stroke-linecap="round"/>'
    f'<rect x="88" y="164" width="24" height="7" rx="3" fill="{N}"/>')

if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for name, text in ICONS.items():
        with open(os.path.join(out, name + ".svg"), "w") as fh:
            fh.write(text)
    print(f"wrote {len(ICONS)} svg to {out}")
