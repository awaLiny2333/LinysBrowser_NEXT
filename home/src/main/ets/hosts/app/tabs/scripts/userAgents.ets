import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { getCurrentAppUserAgent } from "../settings";
import { webview } from "@kit.ArkWeb";

/**
 * Apply user agent from settings.
 * @returns True if applied successfully, false otherwise.
 */
export function applyUserAgentFromSettings() {
  const ua = getCurrentAppUserAgent();
  meow(`User agent: [${ua}]`, 'tabs][userAgents', meowLevel.INFO);
  webview.WebviewController.setAppCustomUserAgent(ua);
}
