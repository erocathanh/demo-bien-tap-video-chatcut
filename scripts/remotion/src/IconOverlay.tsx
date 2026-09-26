import React from "react";
import { AbsoluteFill, OffthreadVideo, Sequence, interpolate, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { ArrowDraw, CounterCard, IconPop } from "./IconOverlayParts";

// IconOverlay — icon + arrow motion-graphics overlay on a talking head (mau-07 redo, Owner 25/09/2026:
// "giao codex vẽ các icon rồi dùng remotion tạo chuyển động của các icon dạng overlay nhưng có các arrow
// chuyển động smooth"). Four beats, 10 s @ 30 fps, 1080x1920. Story = today's real numbers:
// video file -> Claude -> timeline; duration 36,4 -> 32,0 s; transcript strike -> b-roll cards; export -> check, 18 s.
// Frame constants live in BEATS so the 30 fps study can retune them without touching the layout.
// Added 25/09/2026.

export type IconOverlayProps = {
  video: string;
  videoStartFrame: number;
  durationInFrames: number;
  // Optional (added 25/09): frames over which the background softening (blur + dim +
  // gradient) ramps in at the start and back out at the end. 0 (default) = original hard on/off. Use > 0 when the
  // clip is spliced between unsoftened footage, otherwise brightness jumps at both joins (measured 52.7 -> 35.5).
  rampFrames?: number;
};

// ---- timing (frames) — retuned 26/09/2026 from mau-07-icon-arrow-30fps-v01.md (numbers are measured, not guessed) ----
const ICON_ENTER = 13; // pop spring: peak +9-10 % at frame 7-8, settles at 12-13 (sub-C: bookmark / Share / FOLLOW)
const SRC_ENTER = 26; // source icon: fade + shrink from 1.2 done in ~10 frames, drift-up tail to 26 (I04 PDF f599->f625)
const TGT_FADE = 21; // target icon: fade ease-out, scale 0.93->1, blur 6->0 in 5 frames, no bounce (I01 Claude f6->f27)
const ARROW_SPEED = 43; // px of path per frame, linear (I01: +44 42 41 38 35 px/frame, body done in 8 frames)
const ARROW_LAG = 5; // arrow starts 5 frames after the source icon starts moving (I01: slide f2, draw f7)
const ARROW_DONE = ARROW_LAG + 8; // cards/badges land when the arrow finishes (I01: token card f12, arrow done f14)
const BEATS = [
  { from: 0, len: 70 },
  { from: 70, len: 70 },
  { from: 140, len: 70 },
  { from: 210, len: 90 },
];
const SIZE = 27; // icon width, % of frame width (18 read too small at phone size; the studied Short sits ~28)
const EXIT = 15; // group exit: linear fade 15 frames + scale ~1.12 (I01 f53->f68)

// arrow geometry in 1080x1920 space (icon centres: x30%=324, x50%=540, x70%=756, y36%=691, y28%=538, y50%=960)
const ARROW_LR = { d: "M 435 691 Q 540 610 645 691", head: { x: 645, y: 691, angle: 37.6 } };
const ARROW_DOWN = { d: "M 540 612 Q 600 740 540 865", head: { x: 540, y: 865, angle: 115.6 } };
const ARROW_EXPORT = { d: "M 435 691 Q 540 610 645 691", head: { x: 645, y: 691, angle: 37.6 } };

// path length by sampling (M/L/Q/C absolute), so ArrowDraw needs no runtime DOM measurement
export const svgPathLength = (d: string): number => {
  const tk = d.replace(/,/g, " ").match(/[MLCQZ]|-?\d*\.?\d+/gi) ?? [];
  let i = 0, cmd = "", cur: [number, number] = [0, 0], start: [number, number] = [0, 0], total = 0;
  const num = () => parseFloat(tk[i++]);
  const dist = (a: number[], b: number[]) => Math.hypot(a[0] - b[0], a[1] - b[1]);
  const sample = (fn: (t: number) => number[]) => { let prev = fn(0), len = 0; for (let k = 1; k <= 400; k++) { const p = fn(k / 400); len += dist(prev, p); prev = p; } return len; };
  while (i < tk.length) {
    const t = tk[i];
    if (/[MLCQZ]/i.test(t)) { cmd = t.toUpperCase(); i++; if (cmd === "Z") { total += dist(cur, start); cur = start; continue; } }
    if (cmd === "M") { cur = [num(), num()]; start = cur; cmd = "L"; }
    else if (cmd === "L") { const p: [number, number] = [num(), num()]; total += dist(cur, p); cur = p; }
    else if (cmd === "Q") { const p1 = [num(), num()], p2: [number, number] = [num(), num()]; const c0 = cur; total += sample((u) => { const v = 1 - u; return [v * v * c0[0] + 2 * v * u * p1[0] + u * u * p2[0], v * v * c0[1] + 2 * v * u * p1[1] + u * u * p2[1]]; }); cur = p2; }
    else if (cmd === "C") { const p1 = [num(), num()], p2 = [num(), num()], p3: [number, number] = [num(), num()]; const c0 = cur; total += sample((u) => { const v = 1 - u; return [v ** 3 * c0[0] + 3 * v * v * u * p1[0] + 3 * v * u * u * p2[0] + u ** 3 * p3[0], v ** 3 * c0[1] + 3 * v * v * u * p1[1] + 3 * v * u * u * p2[1] + u ** 3 * p3[1]]; }); cur = p3; }
    else { i++; }
  }
  return Math.round(total);
};

const Arrow: React.FC<{ a: { d: string; head: { x: number; y: number; angle: number } }; total: number }> = ({ a, total }) => (
  <ArrowDraw d={a.d} length={svgPathLength(a.d)} speed={ARROW_SPEED} headAt={a.head} total={total} exitFrames={EXIT} />
);

export const IconOverlay: React.FC<IconOverlayProps> = ({ video, videoStartFrame, rampFrames = 0 }) => {
  const [b1, b2, b3, b4] = BEATS;
  const arrowIn = ARROW_LAG; // arrow starts inside a beat
  const targetIn = ARROW_LAG; // target icon fades in alongside the arrow (I01: Claude f6, arrow f7)
  const cardIn = ARROW_DONE;
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();
  // k = 1 means fully softened (original look); ramps from 0 at both clip edges when rampFrames > 0.
  const k =
    rampFrames > 0
      ? Math.min(
          interpolate(frame, [0, rampFrames], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),
          interpolate(frame, [durationInFrames - 1 - rampFrames, durationInFrames - 1], [1, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        )
      : 1;
  const softFilter = rampFrames > 0 ? `blur(${6 * k}px) brightness(${1 - 0.4 * k})` : "blur(6px) brightness(0.6)";
  const softScale = rampFrames > 0 ? `scale(${1 + 0.04 * k})` : "scale(1.04)";
  return (
    <AbsoluteFill style={{ backgroundColor: "#0B1C33" }}>
      {/* talking head, softened so the graphics read (the study's Short does the same) */}
      <AbsoluteFill style={{ filter: softFilter, transform: softScale }}>
        <OffthreadVideo src={staticFile(video)} startFrom={videoStartFrame} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
      </AbsoluteFill>
      <AbsoluteFill
        style={{
          background: "linear-gradient(180deg, rgba(11,28,51,0.35) 0%, rgba(11,28,51,0.15) 50%, rgba(11,28,51,0.45) 100%)",
          opacity: rampFrames > 0 ? k : undefined,
        }}
      />

      {/* beat 1: video file -> Claude */}
      <Sequence from={b1.from} durationInFrames={b1.len}>
        <IconPop src="icons/icon-01-video-file.png" x={26} y={36} size={SIZE} mode="fadeShrink" enterFrames={SRC_ENTER} total={b1.len} exitFrames={EXIT} />
      </Sequence>
      <Sequence from={b1.from + arrowIn} durationInFrames={b1.len - arrowIn}>
        <Arrow a={ARROW_LR} total={b1.len - arrowIn} />
      </Sequence>
      <Sequence from={b1.from + targetIn} durationInFrames={b1.len - targetIn}>
        <IconPop src="icons/icon-02-claude.png" x={74} y={36} size={SIZE} mode="fade" enterFrames={TGT_FADE} total={b1.len - targetIn} exitFrames={EXIT} />
      </Sequence>

      {/* beat 2: Claude -> timeline, duration counts 36,4 -> 32,0 s */}
      <Sequence from={b2.from} durationInFrames={b2.len}>
        <IconPop src="icons/icon-02-claude.png" x={50} y={24} size={SIZE} mode="fadeShrink" enterFrames={SRC_ENTER} total={b2.len} exitFrames={EXIT} />
      </Sequence>
      <Sequence from={b2.from + arrowIn} durationInFrames={b2.len - arrowIn}>
        <Arrow a={ARROW_DOWN} total={b2.len - arrowIn} />
      </Sequence>
      <Sequence from={b2.from + targetIn} durationInFrames={b2.len - targetIn}>
        <IconPop src="icons/icon-03-timeline.png" x={50} y={54} size={SIZE + 4} mode="fade" enterFrames={TGT_FADE} total={b2.len - targetIn} exitFrames={EXIT} />
      </Sequence>
      <Sequence from={b2.from + cardIn} durationInFrames={b2.len - cardIn}>
        <CounterCard label="THỜI LƯỢNG" from={36.4} to={32.0} decimals={1} suffix=" s" barMax={36.4} startFrame={10} countFrames={30} slidePx={40} x={14} y={62} w={72} /* y 66->62: the 130 px slide-up start must clear the caption band (v7 sheet f90 overlapped) */ total={b2.len - cardIn} exitFrames={EXIT} />
      </Sequence>

      {/* beat 3: transcript (one line struck) -> timeline; three b-roll cards */}
      <Sequence from={b3.from} durationInFrames={b3.len}>
        <IconPop src="icons/icon-04-transcript.png" x={26} y={36} size={SIZE} mode="fadeShrink" enterFrames={SRC_ENTER} total={b3.len} exitFrames={EXIT} />
      </Sequence>
      <Sequence from={b3.from + arrowIn} durationInFrames={b3.len - arrowIn}>
        <Arrow a={ARROW_LR} total={b3.len - arrowIn} />
      </Sequence>
      <Sequence from={b3.from + targetIn} durationInFrames={b3.len - targetIn}>
        <IconPop src="icons/icon-03-timeline.png" x={74} y={36} size={SIZE} mode="fade" enterFrames={TGT_FADE} total={b3.len - targetIn} exitFrames={EXIT} />
      </Sequence>
      {[30, 50, 70].map((x, i) => (
        <Sequence key={x} from={b3.from + cardIn + i * 5} durationInFrames={b3.len - cardIn - i * 5}>
          <IconPop src="icons/icon-05-broll-image.png" x={x} y={57} size={13} inFrom={{ dy: 5 }} enterFrames={ICON_ENTER} total={b3.len - cardIn - i * 5} exitFrames={EXIT} />
        </Sequence>
      ))}

      {/* beat 4: export -> check, render 18 s */}
      <Sequence from={b4.from} durationInFrames={b4.len}>
        <IconPop src="icons/icon-06-export.png" x={26} y={36} size={SIZE} mode="fadeShrink" enterFrames={SRC_ENTER} total={b4.len} exitFrames={EXIT} />
      </Sequence>
      <Sequence from={b4.from + arrowIn} durationInFrames={b4.len - arrowIn}>
        <Arrow a={ARROW_EXPORT} total={b4.len - arrowIn} />
      </Sequence>
      <Sequence from={b4.from + targetIn} durationInFrames={b4.len - targetIn}>
        <IconPop src="icons/icon-08-check.png" x={74} y={36} size={SIZE} mode="fade" enterFrames={TGT_FADE} total={b4.len - targetIn} exitFrames={EXIT} />
      </Sequence>
      <Sequence from={b4.from + cardIn} durationInFrames={b4.len - cardIn}>
        <IconPop src="icons/icon-07-clock.png" x={30} y={62} size={14} inFrom={{ dy: 5 }} enterFrames={ICON_ENTER} total={b4.len - cardIn} exitFrames={EXIT} />
      </Sequence>
      <Sequence from={b4.from + cardIn + 4} durationInFrames={b4.len - cardIn - 4}>
        <CounterCard label="RENDER" from={0} to={18} suffix=" s" barMax={30} startFrame={8} countFrames={30} slidePx={40} x={40} y={57} w={46} total={b4.len - cardIn - 4} exitFrames={EXIT} />
      </Sequence>
    </AbsoluteFill>
  );
};

export const iconOverlayCalc = ({ props }: { props: IconOverlayProps }) => ({
  durationInFrames: Math.max(1, Math.round(props.durationInFrames || 300)),
  fps: 30,
  width: 1080,
  height: 1920,
});

export const ICON_OVERLAY_DEFAULT: IconOverlayProps = { video: "head.mp4", videoStartFrame: 300, durationInFrames: 300 };
