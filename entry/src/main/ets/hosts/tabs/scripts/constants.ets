import { webview } from "@kit.ArkWeb";

/**
 * Get the default user agent.
 * @returns The default user agent.
 */
export function defaultUserAgent() {
  return webview.WebviewController.getDefaultUserAgent();
}