// Be Vietnam Pro renders Vietnamese diacritics cleanly; the vietnamese subset is required.
// Loaded through @remotion/google-fonts, so the first render needs internet access.
import { loadFont as loadBeVietnamPro } from "@remotion/google-fonts/BeVietnamPro";

export const beVietnamPro = loadBeVietnamPro("normal", {
  weights: ["500", "600", "700"],
  subsets: ["latin", "vietnamese"],
}).fontFamily;
