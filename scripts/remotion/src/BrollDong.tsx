import React from "react";
import {
  AbsoluteFill,
  Easing,
  Img,
  interpolate,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

// B-roll dong: turn one still image into a slow-moving clip (Ken Burns style).
// Modes: zoom-in (1.00 -> 1.08), zoom-out (1.08 -> 1.00), pan-up (fixed 1.06 scale, drift 3% upward).
// Opacity dips at both ends over `fadeFrames` frames (default FADE_FRAMES = 5) but never reaches pure
// black (floor FADE_FLOOR). Pass fadeFrames = 0 for a hard cut with no dip at all (needed when the clip is
// placed inside a timeline such as ChatCut, where any dip shows as a dark flash at the join).
// Added 25/09/2026.
export type BrollDongMode = "zoom-in" | "zoom-out" | "pan-up";
export type BrollDongProps = {
  src: string;
  durationInFrames: number;
  mode: BrollDongMode;
  fadeFrames?: number; // optional, default FADE_FRAMES; 0 disables the fade
};

const FADE_FRAMES = 5;
const FADE_FLOOR = 0.15;
const ZOOM_MIN = 1.0;
const ZOOM_MAX = 1.08;
const PAN_SCALE = 1.06;
const PAN_PERCENT = 3; // total vertical drift, in percent of frame height
const DRIFT_PERCENT = 2; // gentle drift added to the zoom modes, in percent of frame height

// smooth ease-in-out so the motion has no visible start or stop
const EASE = Easing.bezier(0.33, 0, 0.67, 1);

export const BrollDong: React.FC<BrollDongProps> = ({ src, mode, fadeFrames }) => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();
  const last = Math.max(1, durationInFrames - 1);

  // 0 -> 1 across the whole clip
  const t = interpolate(frame, [0, last], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: EASE,
  });

  let scale = 1;
  let translateY = 0; // percent of frame height
  if (mode === "zoom-in") {
    scale = interpolate(t, [0, 1], [ZOOM_MIN, ZOOM_MAX]);
    translateY = interpolate(t, [0, 1], [0, -DRIFT_PERCENT]);
  } else if (mode === "zoom-out") {
    scale = interpolate(t, [0, 1], [ZOOM_MAX, ZOOM_MIN]);
    translateY = interpolate(t, [0, 1], [-DRIFT_PERCENT, 0]);
  } else {
    scale = PAN_SCALE;
    translateY = interpolate(t, [0, 1], [PAN_PERCENT / 2, -PAN_PERCENT / 2]);
  }

  // fade in over the first `fade` frames, fade out over the last `fade` frames.
  // fade = 0 must skip interpolate entirely: an empty input range [0, 0] throws in Remotion.
  const fade = Math.max(0, Math.round(fadeFrames ?? FADE_FRAMES));
  let opacity = 1;
  if (fade > 0) {
    const fadeIn = interpolate(frame, [0, fade], [FADE_FLOOR, 1], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    });
    const fadeOut = interpolate(frame, [last - fade, last], [1, FADE_FLOOR], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    });
    opacity = Math.min(fadeIn, fadeOut);
  }

  return (
    <AbsoluteFill style={{ backgroundColor: "#000" }}>
      <AbsoluteFill style={{ opacity }}>
        <Img
          src={staticFile(src)}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            transform: `scale(${scale}) translateY(${translateY}%)`,
            transformOrigin: "50% 50%",
          }}
        />
      </AbsoluteFill>
    </AbsoluteFill>
  );
};

export const brollDongCalc = ({ props }: { props: BrollDongProps }) => {
  return {
    durationInFrames: Math.max(1, Math.round(props.durationInFrames || 1)),
    fps: 30,
    width: 1080,
    height: 1920,
  };
};

export const BROLL_DONG_DEFAULT: BrollDongProps = {
  src: "vsl-broll-1-ban-sac-thuong-hieu.png",
  durationInFrames: 91,
  mode: "zoom-in",
};
