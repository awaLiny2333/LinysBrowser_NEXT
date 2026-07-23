import { webview } from "@kit.ArkWeb";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { getCurrentAppUserAgent } from "../settings";

/**
 * Apply user agent from settings.
 */
export function applyUserAgentFromSettings() {
  const ua = getCurrentAppUserAgent();
  meow(`User agent: [${ua}]`, 'applyUserAgentFromSettings', meowLevel.INFO);
  webview.WebviewController.setAppCustomUserAgent(ua);
}
