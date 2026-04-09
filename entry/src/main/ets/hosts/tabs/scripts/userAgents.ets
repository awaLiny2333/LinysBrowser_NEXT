import { webview } from "@kit.ArkWeb";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { meowManagedSettings } from "../../settings/classes/meowManagedSettings";

/**
 * Apply user agent from settings.
 * @param settings The meowManagedSettings instance.
 * @returns True if applied successfully, false otherwise.
 */
export function applyUserAgentFromSettings(settings: meowManagedSettings) {
  const uaList = settings.settingsData[41].value as string[][];
  const uaSelected = settings.settingsData[42].value as number;
  const ua = uaSelected == -1 ? '' : uaList[uaSelected][1];
  return applyUserAgent(ua);
}

/**
 * Apply user agent to webview.
 * @param userAgent The user agent to be applied.
 * @returns True if applied successfully, false otherwise.
 */
export function applyUserAgent(userAgent: string): boolean {
  if (userAgent) {
    // User Agent not empty, set.
    webview.WebviewController.setAppCustomUserAgent(userAgent);
    meow(`Set app custom user agent to: [${userAgent}]`, 'tabs][userAgents', meowLevel.INFO);
    return true;
  } else {
    // User Agent is empty, do nothing and let Ark Web use the default UA.
    return resetDefaultUserAgent();
  }
}

/**
 * Reset default user agent.
 * @returns True if reset successfully, false otherwise.
 */
function resetDefaultUserAgent(): boolean {
  let defaultUserAgent = webview.WebviewController.getDefaultUserAgent();
  if (defaultUserAgent) {
    webview.WebviewController.setAppCustomUserAgent(defaultUserAgent);
    meow(`Reset default user agent to: [${defaultUserAgent}]`, 'tabs][userAgents', meowLevel.INFO);
    return true;
  } else {
    // Not initialized? or am i not called from the UI thread?
    meow('WebviewController.getDefaultUserAgent() failed. NO CHANGE IS MADE.', 'tabs][userAgents', meowLevel.WARN);
    return false;
  }
}
