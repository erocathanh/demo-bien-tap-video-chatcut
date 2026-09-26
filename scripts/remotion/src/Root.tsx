import { Composition } from "remotion";
import { BrollDong, brollDongCalc, BROLL_DONG_DEFAULT } from "./BrollDong";
import { CaptionOverVideo, captionOverVideoCalc, CAPTION_OVER_VIDEO_DEFAULT } from "./CaptionOverVideo";
import { IconOverlay, iconOverlayCalc, ICON_OVERLAY_DEFAULT } from "./IconOverlay";
import { IconStory, iconStoryCalc, ICON_STORY_DEFAULT } from "./IconStory";
import { IconStage, iconStageCalc } from "./IconStage";
// default props = the 26/09 rebuilt sample, so Remotion Studio shows real scenes instead of an empty stage
import iconStageSample from "../props/iconstage-video-2.json";

// Minimal root for the skill package: only the compositions the skill uses. All are 1080x1920 at 30 fps;
// duration comes from calculateMetadata (props.durationInFrames).
const V = { fps: 30, width: 1080, height: 1920 };

export const RemotionRoot: React.FC = () => (
  <>
    <Composition id="BrollDong" component={BrollDong} durationInFrames={91} {...V} defaultProps={BROLL_DONG_DEFAULT} calculateMetadata={brollDongCalc} />
    <Composition id="CaptionOverVideo" component={CaptionOverVideo} durationInFrames={480} {...V} defaultProps={CAPTION_OVER_VIDEO_DEFAULT} calculateMetadata={captionOverVideoCalc} />
    <Composition id="IconOverlay" component={IconOverlay} durationInFrames={300} {...V} defaultProps={ICON_OVERLAY_DEFAULT} calculateMetadata={iconOverlayCalc} />
    <Composition id="IconStory" component={IconStory} durationInFrames={1091} {...V} defaultProps={ICON_STORY_DEFAULT} calculateMetadata={iconStoryCalc} />
    <Composition id="IconStage" component={IconStage} durationInFrames={300} {...V} defaultProps={iconStageSample as any} calculateMetadata={iconStageCalc} />
  </>
);
