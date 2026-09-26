import React from "react";
import { Easing, Img, interpolate, random, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";

// Reusable overlay primitives for icon + arrow motion graphics (mau-07 study, 25/09/2026).
// All timings are frame offsets relative to the enclosing <Sequence>.
// Retuned 26/09/2026 from the 30 fps frame study (mau-07-icon-arrow-30fps-v01.md):
//   - group exit = LINEAR fade 15 frames + scale ~1.12 (I01 f53->f68), no ease-in
//   - target icon enters by FADE (ease-out, 21 frames), scale 0.93->1, blur 6->0 over 5 frames, no bounce (I01 Claude)
//   - source icon enters by fade + shrink from 1.2 (~10 frames) with a drift-up tail to 26 frames (I04 PDF)
//   - pop (badges/buttons): spring from 0.2, peak +9-10 % at frame 7-8, settles at 12-13 (sub-C bookmark/Share/FOLLOW)
//   - arrow body drawn LINEAR by path length at ~43 px/frame, chevron head stroked in 2 frames from 90 % of the body,
//     then "boil": shape jitters every 5 frames in an A B A C cycle (+-13 px)
//   - counter card: fade 14 frames + slide UP 130 px over 27 frames (ease-out quad); no punch at the end
// Added 25/09/2026.

const CLAMP = { extrapolateLeft: "clamp" as const, extrapolateRight: "clamp" as const };
const EXIT_SCALE = 0.12; // group exit grows to ~1.12 while fading (measured 1.10-1.15)

// exit envelope shared by every part: linear fade, slight scale-up
const useExit = (f: number, total: number, exitFrames: number) =>
  interpolate(f, [total - exitFrames, total - 1], [0, 1], { ...CLAMP, easing: Easing.linear });

// ---------- IconPop: icon enters (pop | fade | fadeShrink), holds, exits with the group ----------
export type IconPopProps = {
  src: string; // staticFile-relative PNG (transparent)
  x: number; // centre, % of width
  y: number; // centre, % of height
  size: number; // % of width
  mode?: "pop" | "fade" | "fadeShrink"; // default pop
  inFrom?: { dx?: number; dy?: number }; // pop only: slide-in offset in % of frame
  enterFrames?: number; // pop: spring settle (13) · fade: 21 · fadeShrink: 26
  total: number; // frames the icon lives inside its Sequence
  exitFrames?: number; // default 15
  overshoot?: number; // pop only: spring damping, lower = more bounce. default 14 (~+9 %)
};
export const IconPop: React.FC<IconPopProps> = ({ src, x, y, size, mode = "pop", inFrom, enterFrames, total, exitFrames = 15, overshoot = 14 }) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  let scale = 1, opacity = 1, dx = 0, dy = 0, blur = 0;
  if (mode === "pop") {
    // reviewer 26/09 simulated the spring: damping 14 / stiffness 205 / mass 0.7 (no durationInFrames) matches +9 % at f7-8, settle f12-13
    const s = spring({ frame: f, fps, config: { damping: overshoot, stiffness: 205, mass: 0.7 } });
    scale = interpolate(s, [0, 1], [0.2, 1]);
    dx = (inFrom?.dx ?? 0) * (1 - s);
    dy = (inFrom?.dy ?? 0) * (1 - s);
    opacity = Math.min(1, s * 1.4);
  } else if (mode === "fade") {
    const n = enterFrames ?? 21;
    const a = interpolate(f, [3, n - 3], [0, 1], { ...CLAMP, easing: Easing.out(Easing.quad) }); // ghost 3 frames, ~0.12 @4 · 0.56 @8 · 0.72 @10
    opacity = a;
    scale = 0.93 + 0.07 * a;
    blur = 6 * (1 - interpolate(f, [3, 8], [0, 1], CLAMP));
  } else {
    const n = enterFrames ?? 26;
    const e = interpolate(f, [0, n], [0, 1], { ...CLAMP, easing: Easing.out(Easing.cubic) });
    const q = interpolate(f, [0, 10], [0, 1], { ...CLAMP, easing: Easing.out(Easing.quad) }); // fade + shrink done in 10 frames (I04 f599->f609)
    opacity = q;
    scale = 1.2 - 0.2 * q;
    dy = 1.6 * (1 - e); // 30 px at 1920 -> starts lower, drifts up over the 26-frame tail
  }
  const exitT = useExit(f, total, exitFrames);
  return (
    <div
      style={{
        position: "absolute",
        left: `${x - size / 2 + dx}%`,
        top: `calc(${y}% - ${size / 2}vw + ${dy}%)`,
        width: `${size}%`,
        aspectRatio: "1 / 1",
        opacity: opacity * (1 - exitT),
        transform: `scale(${scale * (1 + EXIT_SCALE * exitT)})`,
        transformOrigin: "50% 50%",
        filter: `drop-shadow(0 12px 28px rgba(0,0,0,0.35))${blur > 0.2 ? ` blur(${blur.toFixed(1)}px)` : ""}`,
      }}
    >
      <Img src={staticFile(src)} style={{ width: "100%", height: "100%", objectFit: "contain" }} />
    </div>
  );
};

// ---------- ArrowDraw: SVG path revealed linearly by length; chevron head stroked in at 90 %; boils after ----------
export type ArrowDrawProps = {
  d: string; // SVG path in a 1080x1920 coordinate space
  length: number; // total path length in px (svgPathLength / scripts/path-length.mjs)
  speed?: number; // px of path per frame, linear. default 43 (I01: 44·42·41·38·35)
  drawFrames?: number; // override: frames for the body instead of length/speed
  headFrames?: number; // frames to stroke the chevron, default 2
  stroke?: string; // default white
  width?: number; // px at 1080, default 10.5 (measured 10-11)
  total: number; // frames the arrow lives
  exitFrames?: number; // default 15
  headAt?: { x: number; y: number; angle: number }; // chevron position/rotation (deg) at the path end
  boil?: boolean; // default true: jitter the drawn arrow every 5 frames (A B A C)
};
export const ArrowDraw: React.FC<ArrowDrawProps> = ({ d, length, speed = 43, drawFrames, headFrames = 2, stroke = "#F5F0E6", width = 10.5, total, exitFrames = 15, headAt, boil = true }) => {
  const f = useCurrentFrame();
  const bodyFrames = drawFrames ?? Math.max(3, Math.round(length / speed));
  const body = interpolate(f, [0, bodyFrames], [0, 1], { ...CLAMP, easing: Easing.linear });
  const headStart = Math.max(0, bodyFrames - headFrames); // head begins when the body is ~90 % drawn
  const head = interpolate(f, [headStart, headStart + headFrames], [0, 1], { ...CLAMP, easing: Easing.linear });
  const side = 40; // chevron side length, 2 open sides at ~90 deg
  const hx = side * Math.SQRT1_2, hy = side * Math.SQRT1_2;
  const headPath = `M ${-hx} ${-hy} L 0 0 L ${-hx} ${hy}`;
  const headLen = 2 * side;
  // boil: after the arrow is complete, nudge the whole stroke every 5 frames through shapes A B A C (A = as drawn)
  const done = f >= bodyFrames + headFrames;
  const k = boil && done ? [0, 1, 0, 2][Math.floor((f - (bodyFrames + headFrames) + 3) / 5) % 4] : 0; // A holds 2 frames first, then 5 each
  const jx = k === 0 ? 0 : (k === 1 ? 12 : -13) + (random(`boil-x-${k}`) - 0.5) * 4;
  const jy = k === 0 ? 0 : (k === 1 ? -8 : -9) + (random(`boil-y-${k}`) - 0.5) * 4;
  const exitT = useExit(f, total, exitFrames);
  // scale the arrow around the midpoint between its start and its head during the group exit
  const m = d.match(/-?\d*\.?\d+/g) ?? ["540", "960"];
  const ox = headAt ? (parseFloat(m[0]) + headAt.x) / 2 : 540;
  const oy = headAt ? (parseFloat(m[1]) + headAt.y) / 2 : 960;
  return (
    <svg viewBox="0 0 1080 1920" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", opacity: 1 - exitT }}>
      <g transform={`translate(${ox} ${oy}) scale(${1 + EXIT_SCALE * exitT}) translate(${-ox + jx} ${-oy + jy})`}
        fill="none" stroke={stroke} strokeWidth={width} strokeLinecap="round" strokeLinejoin="round">
        {body > 0 ? <path d={d} strokeDasharray={length} strokeDashoffset={length * (1 - body)} /> : null}
        {headAt ? (
          <g transform={`translate(${headAt.x} ${headAt.y}) rotate(${headAt.angle})`}>
            {head > 0 ? <path d={headPath} strokeDasharray={headLen} strokeDashoffset={headLen * (1 - head)} /> : null}
          </g>
        ) : null}
      </g>
    </svg>
  );
};

// ---------- CounterCard: card fades + slides up, number counts, bar follows, colour shifts ----------
export type CounterCardProps = {
  label: string; // small caption, e.g. "TOKEN CÒN LẠI"
  from: number; // start value
  to: number; // end value
  startFrame: number; // when counting starts (relative to Sequence)
  countFrames: number; // how long the count takes
  x: number; y: number; w: number; // % of width for x,w · % of height for y (top-left)
  total: number;
  enterFrames?: number; exitFrames?: number; // enter: fade 14 (slide-up tail 27) · exit 15
  suffix?: string; // default "%"
  decimals?: number; // default 0
  barMax?: number; // value that fills the bar; default 100
  slidePx?: number; // slide-up distance at 1920 px height; default 130 (measured), 60 when a caption band sits under the card
};
export const CounterCard: React.FC<CounterCardProps> = ({ label, from, to, startFrame, countFrames, x, y, w, total, enterFrames = 14, exitFrames = 15, suffix = "%", decimals = 0, barMax = 100, slidePx = 130 }) => {
  const f = useCurrentFrame();
  const op = interpolate(f, [0, enterFrames], [0, 1], { ...CLAMP, easing: Easing.out(Easing.quad) });
  const ty = interpolate(f, [0, Math.round(enterFrames * 1.9)], [slidePx, 0], { ...CLAMP, easing: Easing.out(Easing.quad) }); // slide UP, px at 1920
  const raw = interpolate(f, [startFrame, startFrame + countFrames], [from, to], { ...CLAMP, easing: Easing.out(Easing.exp) }); // sample counts exponentially (halves every ~8.5 frames)
  const value = decimals > 0 ? raw.toFixed(decimals).replace(".", ",") : String(Math.round(raw));
  const pct = Math.max(0, Math.min(100, (raw / barMax) * 100));
  // colour: gold while healthy, terracotta when low (the studied card flips at ~33 %)
  const hue = pct > 50 ? "#D4AF37" : pct > 33 ? "#E0955A" : "#D97757";
  const exitT = useExit(f, total, exitFrames);
  return (
    <div style={{ position: "absolute", left: `${x}%`, top: `${y}%`, width: `${w}%`, opacity: op * (1 - exitT),
      transform: `translateY(${ty}px) scale(${1 + EXIT_SCALE * exitT})`, transformOrigin: "50% 50%" }}>
      <div style={{ background: "rgba(245,240,230,0.96)", borderRadius: 26, padding: "26px 34px", boxShadow: "0 18px 50px rgba(0,0,0,0.35)", fontFamily: "Inter, Helvetica, Arial, sans-serif" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
          <div style={{ fontSize: 26, letterSpacing: 2, color: "#0B1C33", opacity: 0.7, fontWeight: 600 }}>{label}</div>
          <div style={{ fontSize: 64, fontWeight: 800, color: hue, fontVariantNumeric: "tabular-nums" }}>{value}{suffix}</div>
        </div>
        <div style={{ height: 18, borderRadius: 9, background: "rgba(11,28,51,0.12)", marginTop: 14, overflow: "hidden" }}>
          <div style={{ width: `${pct}%`, height: "100%", borderRadius: 9, background: hue }} />
        </div>
      </div>
    </div>
  );
};
