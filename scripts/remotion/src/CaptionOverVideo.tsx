import React from "react";
import {
  AbsoluteFill,
  OffthreadVideo,
  staticFile,
  useCurrentFrame,
  interpolate,
} from "remotion";

// Phụ đề CHẠY đè lên một VIDEO nền (vd clip người nói Veo/gemini_omni). Chữ nhấn = gold.
export type CaptionWord = { text: string; hot?: boolean; reveal: number };
export type CaptionCue = { from: number; to: number; words: CaptionWord[] };
export type CaptionOverVideoProps = {
  video: string;
  cues: CaptionCue[];
  durationInFrames: number;
};

const GOLD = "#e6b145";
const CREAM = "#ffffff";

const CaptionBar: React.FC<{ cue: CaptionCue; frame: number }> = ({ cue, frame }) => {
  const t = frame - cue.from;
  const appear = interpolate(t, [0, 6], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ justifyContent: "flex-end", alignItems: "center", paddingBottom: 320 }}>
      <div
        style={{
          maxWidth: "86%",
          textAlign: "center",
          background: "rgba(10,25,41,0.58)",
          padding: "20px 34px",
          borderRadius: 22,
          opacity: appear,
          transform: `translateY(${interpolate(appear, [0, 1], [26, 0])}px)`,
        }}
      >
        <span
          style={{
            fontFamily: "Arial, Helvetica, sans-serif",
            fontWeight: 800,
            fontSize: 58,
            lineHeight: 1.28,
            letterSpacing: "-0.5px",
          }}
        >
          {cue.words.map((w, i) => (
            <span
              key={i}
              style={{
                color: w.hot ? GOLD : CREAM,
                opacity: t >= w.reveal ? 1 : 0.22,
                textShadow: "0 3px 10px rgba(0,0,0,0.65)",
                marginRight: 15,
                whiteSpace: "nowrap",
              }}
            >
              {w.text}
            </span>
          ))}
        </span>
      </div>
    </AbsoluteFill>
  );
};

export const CaptionOverVideo: React.FC<CaptionOverVideoProps> = ({ video, cues }) => {
  const frame = useCurrentFrame();
  const active = cues.find((c) => frame >= c.from && frame < c.to);
  return (
    <AbsoluteFill style={{ backgroundColor: "#000" }}>
      <OffthreadVideo
        src={staticFile(video)}
        style={{ width: "100%", height: "100%", objectFit: "cover" }}
      />
      {active ? <CaptionBar cue={active} frame={frame} /> : null}
    </AbsoluteFill>
  );
};

export const captionOverVideoCalc = ({ props }: { props: CaptionOverVideoProps }) => {
  return { durationInFrames: Math.max(1, props.durationInFrames || 1), fps: 30, width: 1080, height: 1920 };
};

export const CAPTION_OVER_VIDEO_DEFAULT: CaptionOverVideoProps = {
  video: "",
  cues: [],
  durationInFrames: 1,
};
