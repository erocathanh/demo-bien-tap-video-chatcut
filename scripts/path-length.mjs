#!/usr/bin/env node
// path-length.mjs — total length of an SVG path (M/L/C/Q/Z, absolute coords) by dense sampling.
// Usage: node scripts/path-length.mjs "M 300 500 C 400 300, 600 300, 700 500"
// Needed by ArrowDraw (strokeDasharray/strokeDashoffset reveal). Added 25/09/2026.

const d = process.argv[2];
if (!d) { console.error("usage: path-length.mjs \"<svg path d>\""); process.exit(2); }

const tokens = d.replace(/,/g, " ").match(/[MLCQZ]|-?\d*\.?\d+(?:e-?\d+)?/gi) ?? [];
let i = 0, cmd = "", cur = [0, 0], start = [0, 0], total = 0;
const num = () => parseFloat(tokens[i++]);
const dist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
const bez = (p0, p1, p2, p3, t) => {
  const u = 1 - t;
  return [
    u * u * u * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t * t * t * p3[0],
    u * u * u * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t * t * t * p3[1],
  ];
};
const quad = (p0, p1, p2, t) => {
  const u = 1 - t;
  return [u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0], u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]];
};
const sample = (fn) => { let prev = fn(0), len = 0; for (let k = 1; k <= 400; k++) { const p = fn(k / 400); len += dist(prev, p); prev = p; } return len; };

while (i < tokens.length) {
  const t = tokens[i];
  if (/[MLCQZ]/i.test(t)) { cmd = t.toUpperCase(); i++; if (cmd === "Z") { total += dist(cur, start); cur = start; continue; } }
  if (cmd === "M") { cur = [num(), num()]; start = cur; cmd = "L"; }
  else if (cmd === "L") { const p = [num(), num()]; total += dist(cur, p); cur = p; }
  else if (cmd === "C") { const p1 = [num(), num()], p2 = [num(), num()], p3 = [num(), num()]; const c0 = cur; total += sample((tt) => bez(c0, p1, p2, p3, tt)); cur = p3; }
  else if (cmd === "Q") { const p1 = [num(), num()], p2 = [num(), num()]; const c0 = cur; total += sample((tt) => quad(c0, p1, p2, tt)); cur = p2; }
  else { i++; }
}
console.log(Math.round(total));
