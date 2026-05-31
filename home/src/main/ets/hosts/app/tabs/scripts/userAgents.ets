import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { getCurrentAppUserAgent, userAgentRuleList } from "../settings";
import { webview } from "@kit.ArkWeb";

/**
 * Apply user agent from settings.
 */
export function applyUserAgentFromSettings() {
  const ua = getCurrentAppUserAgent();
  meow(`User agent: [${ua}]`, 'applyUserAgentFromSettings', meowLevel.INFO);
  webview.WebviewController.setAppCustomUserAgent(ua);
}

/**
 * Apply user agent rules from settings.
 * TODO: For somewaht reason it dowsn;t work.
 */
export function applyUserAgentRulesFromSettings() {
  const rules = userAgentRuleList();
  for (const rule of rules) {
    const ua = rule[0];
    const host = rule[1];
    webview.WebviewController.setUserAgentForHosts(ua, [host]);
    meow(`User agent rule: [${ua}] for host [${host}]`, 'applyUserAgentRulesFromSettings', meowLevel.INFO);
  }
}
