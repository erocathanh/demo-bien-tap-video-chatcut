import React from "react";
import { AbsoluteFill, OffthreadVideo, Sequence, interpolate, staticFile, useCurrentFrame } from "remotion";
import { ArrowDraw, IconPop } from "./IconOverlayParts";
import { svgPathLength } from "./IconOverlay";

// IconStory — icons that follow the spoken words (Owner 26/09/2026: "icon chuyển động chưa khớp nội dung ...
// chỗ nào câu nào cần icon ... nhịp nhàng không quá nhiều gây rối").
// A clip is a list of clusters, one per sentence that deserves an icon. Each cluster lives [from, to) in
// timeline frames (from = the spoken start of its sentence, measured with ChatCut find_transcript) and holds
// icons / arrows with small delays. Sentences with no cluster leave the picture untouched ("rest for the eye").
// The background is softened only while a cluster is on screen, ramping in/out over rampFrames.
// Motion primitives are reused from IconOverlayParts (tuned on the 30 fps study of mau-07); nothing here edits them.
// Added 26/09/2026.

export type StoryIcon = {
  t: "icon";
  src: string;
  x: number; // centre, % of width
  y: number; // centre, % of height
  size: number; // % of width
  mode?: "pop" | "fade" | "fadeShrink";
  delay?: number; // frames after the cluster starts
};
export type StoryArrow = {
  t: "arrow";
  d: string; // SVG path in 1080x1920 space
  head: { x: number; y: number; angle: number };
  delay?: number;
};
export type StoryItem = StoryIcon | StoryArrow;
export type StoryCluster = { id: string; from: number; to: number; items: StoryItem[] };

export type IconStoryProps = {
  video: string; // clean background (no burned captions), staticFile-relative
  videoStartFrame: number;
  durationInFrames: number;
  clusters: StoryCluster[];
  rampFrames?: number; // background soften ramp per cluster, default 9
  softBlur?: number; // px at full soften, default 3 (IconOverlay uses 6)
  softDim?: number; // brightness drop at full soften, default 0.25 (IconOverlay uses 0.4)
};

const CLAMP = { extrapolateLeft: "clamp" as const, extrapolateRight: "clamp" as const };
const EXIT = 12;

// 0..1: how softened the background is at this frame (max over clusters, each ramping in and out)
const softAt = (frame: number, clusters: StoryCluster[], ramp: number) => {
  let k = 0;
  for (const c of clusters) {
    if (frame < c.from - ramp || frame > c.to + ramp) continue;
    const up = interpolate(frame, [c.from - ramp, c.from], [0, 1], CLAMP);
    const down = interpolate(frame, [c.to, c.to + ramp], [1, 0], CLAMP);
    k = Math.max(k, Math.min(up, down));
  }
  return k;
};

export const IconStory: React.FC<IconStoryProps> = ({
  video,
  videoStartFrame,
  clusters,
  rampFrames = 9,
  softBlur = 3,
  softDim = 0.25,
}) => {
  const frame = useCurrentFrame();
  const k = softAt(frame, clusters, rampFrames);
  return (
    <AbsoluteFill style={{ backgroundColor: "#0B1C33" }}>
      <AbsoluteFill style={{ filter: `blur(${softBlur * k}px) brightness(${1 - softDim * k})` }}>
        <OffthreadVideo src={staticFile(video)} startFrom={videoStartFrame} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
      </AbsoluteFill>
      {clusters.map((c) =>
        c.items.map((it, i) => {
          const delay = it.delay ?? 0;
          const len = Math.max(1, c.to - c.from - delay);
          return (
            <Sequence key={`${c.id}-${i}`} from={c.from + delay} durationInFrames={len}>
              {it.t === "icon" ? (
                <IconPop src={it.src} x={it.x} y={it.y} size={it.size} mode={it.mode ?? "pop"} total={len} exitFrames={EXIT} />
              ) : (
                <ArrowDraw d={it.d} length={svgPathLength(it.d)} headAt={it.head} total={len} exitFrames={EXIT} />
              )}
            </Sequence>
          );
        }),
      )}
    </AbsoluteFill>
  );
};

export const iconStoryCalc = ({ props }: { props: IconStoryProps }) => ({
  durationInFrames: Math.max(1, Math.round(props.durationInFrames || 1091)),
  fps: 30,
  width: 1080,
  height: 1920,
});

export const ICON_STORY_DEFAULT: IconStoryProps = {
  video: "nen-sach.mp4",
  videoStartFrame: 0,
  durationInFrames: 1091,
  clusters: [],
};
