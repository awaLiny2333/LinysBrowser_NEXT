import lazy { thirdPartyCookies } from "../settings";
import lazy { webview } from "@kit.ArkWeb";

/**
 * Apply App settings on third-party cookies.
 */
export function applyThirdPartyCookies() {
  webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(thirdPartyCookies());
}
