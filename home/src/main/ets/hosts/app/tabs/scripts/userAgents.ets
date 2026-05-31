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
 * userAgentRuleList() 返回 [host, ua] 数组，将相同 ua 的域名合并后一次性调用。
 *
 * @author DeepSeek Web @ May 31 2026
 */
export function applyUserAgentRulesFromSettings() {
  const rules = userAgentRuleList(); // Array<[string, string]>
  if (!rules || rules.length === 0) {
    return;
  }

  // 按 User-Agent 分组 hosts
  const uaToHosts = new Map<string, string[]>();
  for (const rule of rules) {
    let host = rule[0];
    let ua = rule[1];
    if (!uaToHosts.has(ua)) {
      uaToHosts.set(ua, []);
    }
    uaToHosts.get(ua)!.push(host);
  }

  // 为每个不同的 UA 调用一次，传入该 UA 对应的所有域名
  const entries = uaToHosts.entries();
  for (const entry of entries) {
    let ua = entry[0];
    let hosts = entry[1];
    webview.WebviewController.setUserAgentForHosts(ua, hosts);
  }
}
