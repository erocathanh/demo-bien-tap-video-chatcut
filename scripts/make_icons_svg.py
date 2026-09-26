#!/usr/bin/env python3
"""Draw the 13 flat icons of icon-set-02 as SVG (Owner 26/09/2026: Codex CLI out of quota until 02/10 -> "Em vẽ SVG bằng mã").

Palette = house palette only. Bodies are cream/gold so they read on the navy video band; navy is used for details.
viewBox 0 0 200 200, ~10 % padding, transparent background, no letters or numbers (only the allowed glyphs:
question mark, chevron, check).
Usage: make_icons_svg.py <out_dir>
"""
import os
import sys

N, G, C, T, W = "#0B1C33", "#D4AF37", "#F5F0E6", "#D97757", "#FFFFFF"


def svg(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" width="1254" height="1254">{body}</svg>\n'


def bar(x, y, w, h=8, fill=N, r=4):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}"/>'


ICONS = {}

# 09 speech bubble with a question mark
ICONS["icon-09-question"] = svg(
    f'<path d="M 30 40 Q 30 22 48 22 L 152 22 Q 170 22 170 40 L 170 122 Q 170 140 152 140 L 88 140 L 58 172 L 62 140 L 48 140 Q 30 140 30 122 Z" fill="{C}"/>'
    f'<path d="M 78 66 Q 78 44 100 44 Q 124 44 124 66 Q 124 82 106 90 Q 100 93 100 104" fill="none" stroke="{N}" stroke-width="14" stroke-linecap="round"/>'
    f'<circle cx="100" cy="124" r="9" fill="{N}"/>')

# 10 person holding a tall wobbly stack
ICONS["icon-10-overloaded"] = svg(
    f'<rect x="70" y="18" width="62" height="24" rx="5" fill="{C}" transform="rotate(-6 101 30)"/>'
    f'<rect x="64" y="42" width="70" height="24" rx="5" fill="{G}" transform="rotate(4 99 54)"/>'
    f'<rect x="72" y="66" width="60" height="24" rx="5" fill="{C}" transform="rotate(-3 102 78)"/>'
    f'<rect x="66" y="90" width="68" height="22" rx="5" fill="{G}"/>'
    f'<path d="M 58 118 Q 66 104 74 100 M 142 118 Q 134 104 126 100" stroke="{C}" stroke-width="10" stroke-linecap="round" fill="none"/>'
    f'<circle cx="100" cy="128" r="15" fill="{C}"/>'
    f'<path d="M 66 184 Q 66 146 100 146 Q 134 146 134 184 Z" fill="{C}"/>'
    f'<path d="M 96 150 L 104 150 L 102 176 L 98 176 Z" fill="{N}"/>')

# 11 relaxed robot, empty hands
ICONS["icon-11-robot-idle"] = svg(
    f'<line x1="100" y1="16" x2="100" y2="34" stroke="{G}" stroke-width="7" stroke-linecap="round"/>'
    f'<circle cx="100" cy="14" r="8" fill="{G}"/>'
    f'<rect x="58" y="34" width="84" height="62" rx="18" fill="{C}"/>'
    f'<rect x="68" y="50" width="64" height="26" rx="13" fill="{N}"/>'
    f'<circle cx="86" cy="63" r="6" fill="{G}"/><circle cx="114" cy="63" r="6" fill="{G}"/>'
    f'<rect x="64" y="102" width="72" height="62" rx="14" fill="{C}"/>'
    f'<circle cx="100" cy="126" r="9" fill="{G}"/>'
    f'<rect x="42" y="106" width="16" height="50" rx="8" fill="{C}"/><rect x="142" y="106" width="16" height="50" rx="8" fill="{C}"/>'
    f'<rect x="74" y="164" width="18" height="20" rx="6" fill="{C}"/><rect x="108" y="164" width="18" height="20" rx="6" fill="{C}"/>')

# 12 brand profile card: emblem + swatches + lines
ICONS["icon-12-brand-profile"] = svg(
    f'<rect x="22" y="30" width="156" height="140" rx="18" fill="{C}"/>'
    f'<circle cx="68" cy="78" r="26" fill="{G}"/><circle cx="68" cy="78" r="12" fill="{C}"/>'
    f'{bar(106, 62, 56)}{bar(106, 84, 40)}'
    f'<circle cx="54" cy="136" r="13" fill="{N}"/><circle cx="90" cy="136" r="13" fill="{G}"/><circle cx="126" cy="136" r="13" fill="{T}"/>')


def sheet(x, y, fold=True):
    s = f'<path d="M {x} {y} L {x + 70} {y} L {x + 94} {y + 24} L {x + 94} {y + 118} L {x} {y + 118} Z" fill="{C}"/>'
    if fold:
        s += f'<path d="M {x + 70} {y} L {x + 70} {y + 24} L {x + 94} {y + 24} Z" fill="{N}"/>'
    return s


# 13 fanned stack of three sheets
ICONS["icon-13-file-stack"] = svg(
    f'<g transform="rotate(-12 100 100)">{sheet(38, 44)}</g>'
    f'<g transform="rotate(-4 100 100)">{sheet(50, 40)}</g>'
    f'<g>{sheet(64, 36)}{bar(78, 88, 52, 7)}{bar(78, 106, 40, 7)}{bar(78, 124, 52, 7)}</g>')

# 14 laptop with a white arrow cursor
ICONS["icon-14-laptop-cursor"] = svg(
    f'<rect x="36" y="40" width="128" height="88" rx="10" fill="{C}"/>'
    f'<rect x="46" y="50" width="108" height="68" rx="5" fill="{N}"/>'
    f'<path d="M 18 136 L 182 136 L 170 158 L 30 158 Z" fill="{C}"/>'
    f'<rect x="84" y="140" width="32" height="6" rx="3" fill="{G}"/>'
    f'<path d="M 92 62 L 92 104 L 102 94 L 110 110 L 118 106 L 110 90 L 124 90 Z" fill="{W}"/>')

# 15 command window: prompt chevron + underscore only
ICONS["icon-15-command"] = svg(
    f'<rect x="20" y="38" width="160" height="124" rx="16" fill="{C}"/>'
    f'<rect x="28" y="62" width="144" height="92" rx="10" fill="{N}"/>'
    f'<circle cx="40" cy="50" r="5" fill="{T}"/><circle cx="56" cy="50" r="5" fill="{G}"/><circle cx="72" cy="50" r="5" fill="{N}"/>'
    f'<path d="M 52 88 L 76 108 L 52 128" fill="none" stroke="{G}" stroke-width="12" stroke-linecap="round" stroke-linejoin="round"/>'
    f'<rect x="88" y="120" width="44" height="10" rx="5" fill="{G}"/>')

# 16 social post card: avatar, image block, two bars
ICONS["icon-16-fanpage-post"] = svg(
    f'<rect x="30" y="20" width="140" height="160" rx="16" fill="{C}"/>'
    f'<circle cx="56" cy="46" r="12" fill="{N}"/>{bar(76, 38, 60, 7)}{bar(76, 50, 36, 6)}'
    f'<rect x="44" y="68" width="112" height="62" rx="8" fill="{G}"/>'
    f'<path d="M 58 120 L 82 94 L 100 112 L 114 100 L 142 120 Z" fill="{C}" opacity="0.9"/>'
    f'{bar(44, 142, 104, 8)}{bar(44, 158, 70, 8)}')

# 17 script page with a clapper-board glyph
ICONS["icon-17-script-page"] = svg(
    f'<rect x="40" y="18" width="120" height="164" rx="12" fill="{C}"/>'
    f'<rect x="58" y="46" width="84" height="30" rx="4" fill="{N}"/>'
    f'<path d="M 58 32 L 142 26 L 144 40 L 60 46 Z" fill="{N}"/>'
    f'<path d="M 72 31 L 82 44 M 94 29 L 104 42 M 116 27 L 126 40" stroke="{G}" stroke-width="6"/>'
    f'{bar(58, 94, 84)}{bar(58, 114, 66)}{bar(58, 134, 84)}{bar(58, 154, 50)}')

# 18 bar chart: four rising gold bars on a cream baseline
ICONS["icon-18-bar-chart"] = svg(
    f'<rect x="30" y="118" width="26" height="46" rx="6" fill="{G}"/>'
    f'<rect x="66" y="92" width="26" height="72" rx="6" fill="{G}"/>'
    f'<rect x="102" y="64" width="26" height="100" rx="6" fill="{G}"/>'
    f'<rect x="138" y="34" width="26" height="130" rx="6" fill="{G}"/>'
    f'<rect x="22" y="168" width="156" height="10" rx="5" fill="{C}"/>')

# 19 report sheet with a pie chart
ICONS["icon-19-report"] = svg(
    f'<rect x="40" y="18" width="120" height="164" rx="12" fill="{C}"/>'
    f'<circle cx="80" cy="66" r="26" fill="{G}"/>'
    f'<path d="M 80 66 L 80 40 A 26 26 0 0 1 104 76 Z" fill="{T}"/>'
    f'{bar(114, 52, 30)}{bar(114, 70, 22)}'
    f'{bar(58, 112, 84)}{bar(58, 132, 66)}{bar(58, 152, 84)}')

# 20 weekly calendar: 7 empty cells in one row (cell centres x = 25 + 25 i, y = 125)
cells = "".join(f'<rect x="{15 + 25 * i}" y="115" width="20" height="20" rx="5" fill="none" stroke="{N}" stroke-width="3.5"/>' for i in range(7))
ICONS["icon-20-calendar"] = svg(
    f'<rect x="8" y="58" width="184" height="96" rx="16" fill="{C}"/>'
    f'<path d="M 8 74 Q 8 58 24 58 L 176 58 Q 192 58 192 74 L 192 98 L 8 98 Z" fill="{G}"/>'
    f'<rect x="48" y="46" width="10" height="26" rx="5" fill="{N}"/><rect x="142" y="46" width="10" height="26" rx="5" fill="{N}"/>'
    f'{cells}')

# 21 gift box with ribbon and bow
ICONS["icon-21-gift"] = svg(
    f'<rect x="34" y="84" width="132" height="90" rx="10" fill="{T}"/>'
    f'<rect x="26" y="64" width="148" height="30" rx="8" fill="{T}"/>'
    f'<rect x="90" y="64" width="20" height="110" fill="{G}"/>'
    f'<rect x="26" y="74" width="148" height="10" fill="{G}"/>'
    f'<path d="M 100 64 Q 70 20 56 44 Q 48 62 100 64 Z" fill="{G}"/>'
    f'<path d="M 100 64 Q 130 20 144 44 Q 152 62 100 64 Z" fill="{G}"/>'
    f'<circle cx="100" cy="62" r="9" fill="{G}"/>')

if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for name, text in ICONS.items():
        with open(os.path.join(out, name + ".svg"), "w") as fh:
            fh.write(text)
    print(f"wrote {len(ICONS)} svg to {out}")
