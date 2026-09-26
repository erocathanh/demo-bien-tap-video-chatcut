import React from "react";
import { AbsoluteFill, Audio, Easing, Img, OffthreadVideo, Sequence, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { beVietnamPro } from "./fonts";

// IconStage — one "stage" per spoken sentence, the layout of sample 08 ("4 Levels To Using Claude", measured 26/09/2026,
// report nghien-cuu/DANG-LAM/mau-08-icon-theo-noi-dung-v01.md). Different from IconStory (overlay on a talking face):
//   - each scene owns the whole frame (layout "full") or the top half with the face in the bottom half ("split")
//   - objects pop within +-3 frames of their word, stay until the sentence ends, then the whole scene HARD-CUTS (M12)
//   - lists are same-size objects on a symmetric row (grid), at most ~5 objects on screen, one main motion at a time
//   - captions are 2-4 word chunks, bold white on a translucent grey box, no karaoke, 79 % H (full) / 60 % H (split)
// Motion recipes M1-M4, M8, M9 from section 3 of the report. Colours live in ONE theme object so the look can switch
// from the house palette to the light sample palette with one prop.
// Added 26/09/2026.

export type StageTheme = {
  bg: string; // radial centre
  bgEdge: string; // radial edge
  card: string; // rounded card behind an icon
  accent: string; // pills, active step, rings
  ink: string; // text on the background
  strike: string;
  capBox: string;
  capText: string;
  stage: string; // the rounded "stage" card that groups a scene's objects (PM 12:12: cream on navy)
  stepIdle: string; // stairs: steps not reached yet
  stepOn: string; // stairs: steps reached (up to the active level)
};

export const THEME_HOUSE: StageTheme = {
  bg: "#15305A",
  bgEdge: "#0B1C33",
  card: "#1B3A66",
  accent: "#D97757",
  ink: "#F5F0E6",
  strike: "#D0312D",
  capBox: "rgba(122,122,122,0.6)",
  capText: "#FFFFFF",
  stage: "#F5F0E6",
  stepIdle: "#3A5A8C",
  stepOn: "#D4AF37",
};

// the sample's own light look (measured by eye on PNG frames, section 4 of the report)
export const THEME_SAMPLE: StageTheme = {
  bg: "#F5F5F7",
  bgEdge: "#E3E3E8",
  card: "#FFFFFF",
  accent: "#D97757",
  ink: "#1F1F1F",
  strike: "#D0312D",
  capBox: "rgba(122,122,122,0.6)",
  capText: "#FFFFFF",
  stage: "#FFFFFF",
  stepIdle: "#E3E3E8",
  stepOn: "#D97757",
};

type Base = { at: number }; // frame offset from the scene start
export type StageIcon = Base & { t: "icon"; src: string; x: number; y: number; size: number; motion?: "pop" | "spring" | "drop"; card?: boolean };
export type StageGrid = { t: "grid"; srcs: string[]; at: number[]; y: number; size: number; gap: number; card?: boolean };
export type StagePill = Base & { t: "pill"; text: string; x: number; y: number };
export type StageLine = Base & { t: "line"; d: string; head?: boolean; strike?: boolean; frames?: number };
export type StageRing = Base & { t: "ring"; x: number; y: number; r0: number; r1: number; frames?: number };
export type StageStairs = Base & { t: "stairs"; x: number; y: number; steps: number; shown: number; active: number; w: number; ping?: boolean };
export type StageItem = StageIcon | StageGrid | StagePill | StageLine | StageRing | StageStairs;

// stage card: cream rounded card behind the objects; defaults 86 % W, full = 58 % H centred at 46 % H (bottom edge 75 % H, clear of the 79 % caption), split = 80 % of the top half
export type StageCardBox = { y?: number; h?: number; w?: number } | false;
export type StageScene = { id: string; from: number; to: number; layout: "full" | "split"; blank?: number; stage?: StageCardBox; items: StageItem[] };
export type StageCaption = { from: number; to: number; text: string };

export type IconStageProps = {
  durationInFrames: number;
  scenes: StageScene[];
  captions: StageCaption[];
  audio?: string; // staticFile-relative voice track
  face?: { video: string; startFrame: number; objectPosition?: string }; // clean clip for split scenes, runs in timeline time; objectPosition picks which band of the 9:16 clip shows in the half-frame (default "50% 50%")
  theme?: StageTheme;
};

const CLAMP = { extrapolateLeft: "clamp" as const, extrapolateRight: "clamp" as const };
const W = 1080;
const H = 1920;

// M1: fade + scale, cubic-out, 8 frames, scale 0.62 -> 1
const k1 = (f: number) => interpolate(f, [0, 8], [0, 1], { ...CLAMP, easing: Easing.out(Easing.cubic) });
// M2: spring with ~4.5 % overshoot, peak ~frame 6 (NOT the Remotion default, which overshoots ~16 %)
const k2 = (f: number, fps: number) => spring({ frame: f, fps, config: { stiffness: 480, damping: 31, mass: 1 } });

const Card: React.FC<{ size: number; theme: StageTheme; children: React.ReactNode }> = ({ size, theme, children }) => (
  <div
    style={{
      width: size,
      height: size,
      borderRadius: size * 0.12,
      background: theme.card,
      boxShadow: "0 10px 40px rgba(0,0,0,0.28)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
    }}
  >
    {children}
  </div>
);

const IconAt: React.FC<{ src: string; x: number; y: number; size: number; f: number; motion: StageIcon["motion"]; card?: boolean; theme: StageTheme }> = ({
  src, x, y, size, f, motion = "pop", card, theme,
}) => {
  const { fps } = useVideoConfig();
  if (f < 0) return null;
  let opacity = 1, scale = 1, dy = 0;
  if (motion === "spring") {
    scale = 0.87 + 0.13 * k2(f, fps);
    opacity = interpolate(f, [0, 3], [0, 1], CLAMP);
  } else if (motion === "drop") {
    // M8: falls ~140 px in 3 frames, fades in while falling, no bounce
    const p = interpolate(f, [0, 3], [0, 1], { ...CLAMP, easing: Easing.in(Easing.quad) });
    opacity = p;
    dy = -140 * (1 - p);
  } else {
    const p = k1(f);
    opacity = p;
    scale = 0.62 + 0.38 * p;
  }
  const px = (size / 100) * W;
  const img = <Img src={staticFile(src)} style={{ width: card ? px * 0.7 : px, height: card ? px * 0.7 : px, objectFit: "contain" }} />;
  return (
    <div
      style={{
        position: "absolute",
        left: (x / 100) * W - px / 2,
        top: (y / 100) * H - px / 2 + dy,
        width: px,
        height: px,
        opacity,
        transform: `scale(${scale})`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      {card ? <Card size={px} theme={theme}>{img}</Card> : img}
    </div>
  );
};

const Pill: React.FC<{ it: StagePill; f: number; theme: StageTheme }> = ({ it, f, theme }) => {
  const { fps } = useVideoConfig();
  if (f < 0) return null;
  const s = k2(f, fps);
  return (
    <div
      style={{
        position: "absolute",
        left: (it.x / 100) * W,
        top: (it.y / 100) * H,
        transform: `translate(-50%, -50%) scale(${0.83 + 0.17 * s})`,
        opacity: interpolate(f, [0, 3], [0, 1], CLAMP),
        background: theme.accent,
        color: "#FFFFFF",
        fontFamily: beVietnamPro,
        fontWeight: 700,
        fontSize: 64,
        letterSpacing: 2,
        padding: "16px 48px",
        borderRadius: 999,
        whiteSpace: "nowrap",
      }}
    >
      {it.text}
    </div>
  );
};

// M4: stroke drawn by dash offset, cubic-out, 9 frames. `strike` = red cross-out; `head` = chevron at the end.
const Line: React.FC<{ it: StageLine; f: number; theme: StageTheme }> = ({ it, f, theme }) => {
  if (f < 0) return null;
  const n = it.frames ?? 9;
  const p = interpolate(f, [0, n], [0, 1], { ...CLAMP, easing: Easing.out(Easing.cubic) });
  const L = 4000; // dash longer than any path on a 1080x1920 frame
  const color = it.strike ? theme.strike : theme.accent;
  const nums = it.d.match(/-?\d+(\.\d+)?/g)?.map(Number) ?? [];
  const [ex, ey, cx, cy] = [nums[nums.length - 2], nums[nums.length - 1], nums[nums.length - 4], nums[nums.length - 3]];
  const ang = Math.atan2(ey - cy, ex - cx);
  const hl = 34;
  const head = `M ${ex - hl * Math.cos(ang - 0.5)} ${ey - hl * Math.sin(ang - 0.5)} L ${ex} ${ey} L ${ex - hl * Math.cos(ang + 0.5)} ${ey - hl * Math.sin(ang + 0.5)}`;
  return (
    <svg width={W} height={H} style={{ position: "absolute", left: 0, top: 0 }}>
      <path d={it.d} fill="none" stroke={color} strokeWidth={it.strike ? 14 : 10} strokeLinecap="round" strokeDasharray={L} strokeDashoffset={L * (1 - p)} pathLength={L} />
      {it.head && p > 0.9 ? <path d={head} fill="none" stroke={color} strokeWidth={10} strokeLinecap="round" strokeLinejoin="round" /> : null}
    </svg>
  );
};

// M3: ring grows r0 -> r1 cubic-out while fading linearly to 0
const Ring: React.FC<{ it: StageRing; f: number; theme: StageTheme }> = ({ it, f, theme }) => {
  const n = it.frames ?? 24;
  if (f < 0 || f > n) return null;
  const p = interpolate(f, [0, n], [0, 1], { ...CLAMP, easing: Easing.out(Easing.cubic) });
  return (
    <svg width={W} height={H} style={{ position: "absolute", left: 0, top: 0 }}>
      <circle cx={(it.x / 100) * W} cy={(it.y / 100) * H} r={it.r0 + (it.r1 - it.r0) * p} stroke={theme.accent} strokeWidth={5} fill="none" opacity={1 - p} />
    </svg>
  );
};

// M9 stairs: `shown` steps rise one after another (1.5 frames apart, M1 each); step `active` (1-based) is the accent
// colour and springs in; steps above `shown` leave an empty slot (the sample's "missing step" before a new level).
const Stairs: React.FC<{ it: StageStairs; f: number; theme: StageTheme }> = ({ it, f, theme }) => {
  const { fps } = useVideoConfig();
  if (f < 0) return null;
  const bw = ((it.w / 100) * W) / it.steps;
  const unit = bw * 0.55;
  const left = (it.x / 100) * W - (bw * it.steps) / 2;
  const base = (it.y / 100) * H;
  return (
    <>
      {Array.from({ length: it.shown }).map((_, i) => {
        const g = f - i * 1.5;
        if (g < 0) return null;
        const active = i + 1 === it.active;
        const reached = i + 1 <= it.active;
        const p = active ? k2(g, fps) : k1(g);
        const h = unit * (i + 1);
        return (
          <div
            key={i}
            style={{
              position: "absolute",
              left: left + i * bw + 4,
              top: base - h,
              width: bw - 8,
              height: h,
              borderRadius: 10,
              background: reached ? theme.stepOn : theme.stepIdle,
              boxShadow: "0 8px 24px rgba(0,0,0,0.25)",
              opacity: Math.min(1, p * 1.5),
              transform: `scaleY(${0.6 + 0.4 * p})`,
              transformOrigin: "50% 100%",
            }}
          />
        );
      })}
      {it.ping && it.active > 0 ? (
        <Ring
          it={{ t: "ring", at: 0, x: ((left + (it.active - 0.5) * bw) / W) * 100, y: ((base - (unit * it.active) / 2) / H) * 100, r0: bw * 0.45, r1: bw * 1.1, frames: 24 }}
          f={f - (it.active - 1) * 1.5 - 8}
          theme={theme}
        />
      ) : null}
    </>
  );
};

const StageCard: React.FC<{ box: { y: number; h: number; w: number }; f: number; theme: StageTheme }> = ({ box, f, theme }) => {
  if (f < 0) return null;
  const p = k1(f);
  const w = (box.w / 100) * W;
  const h = (box.h / 100) * H;
  return (
    <div
      style={{
        position: "absolute",
        left: (W - w) / 2,
        top: (box.y / 100) * H - h / 2,
        width: w,
        height: h,
        borderRadius: 40,
        background: theme.stage,
        boxShadow: "0 18px 50px rgba(0,0,0,0.35)",
        opacity: p,
        transform: `scale(${0.9 + 0.1 * p})`,
      }}
    />
  );
};

const stageBox = (s: StageScene) => {
  if (s.stage === false) return null;
  const d = s.layout === "split" ? { y: 25, h: 40, w: 86 } : { y: 46, h: 58, w: 86 };
  return { ...d, ...(s.stage ?? {}) };
};

const Item: React.FC<{ it: StageItem; f: number; theme: StageTheme }> = ({ it, f, theme }) => {
  switch (it.t) {
    case "icon":
      return <IconAt src={it.src} x={it.x} y={it.y} size={it.size} f={f - it.at} motion={it.motion} card={it.card ?? true} theme={theme} />;
    case "grid": {
      const n = it.srcs.length;
      return (
        <>
          {it.srcs.map((src, i) => (
            <IconAt key={i} src={src} x={50 + (i - (n - 1) / 2) * (it.size + it.gap)} y={it.y} size={it.size} f={f - it.at[i]} motion="pop" card={it.card ?? true} theme={theme} />
          ))}
        </>
      );
    }
    case "pill":
      return <Pill it={it} f={f - it.at} theme={theme} />;
    case "line":
      return <Line it={it} f={f - it.at} theme={theme} />;
    case "ring":
      return <Ring it={it} f={f - it.at} theme={theme} />;
    case "stairs":
      return <Stairs it={it} f={f - it.at} theme={theme} />;
  }
};

const Caption: React.FC<{ cap: StageCaption; frame: number; y: number; theme: StageTheme }> = ({ cap, frame, y, theme }) => {
  const a = interpolate(frame - cap.from, [0, 3], [0, 1], CLAMP); // fade 2-3 frames, no slide, no karaoke
  return (
    <div
      style={{
        position: "absolute",
        left: "50%",
        top: (y / 100) * H,
        transform: "translate(-50%, -50%)",
        opacity: a,
        background: theme.capBox,
        color: theme.capText,
        fontFamily: beVietnamPro,
        fontWeight: 700,
        fontSize: 64,
        lineHeight: 1.2,
        padding: "12px 30px",
        borderRadius: 16,
        whiteSpace: "nowrap", // 2-4 word chunks stay on one line (absolute + translate would otherwise shrink the box to 50 %)
        textAlign: "center",
      }}
    >
      {cap.text}
    </div>
  );
};

export const IconStage: React.FC<IconStageProps> = ({ scenes, captions, audio, face, theme = THEME_HOUSE }) => {
  const frame = useCurrentFrame();
  const scene = scenes.find((s) => frame >= s.from && frame < s.to);
  const cap = captions.find((c) => frame >= c.from && frame < c.to);
  const split = scene?.layout === "split";
  return (
    <AbsoluteFill style={{ background: `radial-gradient(circle at 50% 42%, ${theme.bg} 0%, ${theme.bgEdge} 78%)` }}>
      {audio ? <Audio src={staticFile(audio)} /> : null}
      {face
        ? scenes
            .filter((s) => s.layout === "split")
            .map((s) => (
              <Sequence key={`face-${s.id}`} from={s.from} durationInFrames={s.to - s.from}>
                <div style={{ position: "absolute", left: 0, top: H / 2, width: W, height: H / 2, overflow: "hidden" }}>
                  <OffthreadVideo src={staticFile(face.video)} startFrom={face.startFrame + s.from} muted style={{ width: "100%", height: "100%", objectFit: "cover", objectPosition: face.objectPosition ?? "50% 50%" }} />
                </div>
              </Sequence>
            ))
        : null}
      {scene && stageBox(scene) ? <StageCard box={stageBox(scene)!} f={frame - scene.from - (scene.blank ?? 0)} theme={theme} /> : null}
      {scene && frame - scene.from >= (scene.blank ?? 0)
        ? scene.items.map((it, i) => <Item key={`${scene.id}-${i}`} it={it} f={frame - scene.from} theme={theme} />)
        : null}
      {cap ? <Caption cap={cap} frame={frame} y={split ? 60 : 79} theme={theme} /> : null}
    </AbsoluteFill>
  );
};

export const iconStageCalc = ({ props }: { props: IconStageProps }) => ({
  durationInFrames: Math.max(1, Math.round(props.durationInFrames || 300)),
  fps: 30,
  width: W,
  height: H,
});

export const ICON_STAGE_DEFAULT: IconStageProps = { durationInFrames: 300, scenes: [], captions: [] };
