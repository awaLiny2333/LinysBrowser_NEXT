import lazy { webview } from "@kit.ArkWeb";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { meowManagedSettings } from "../../settings/classes/meowManagedSettings";
import { AppStorageV2 } from "@kit.ArkUI";

/**
 * Apply user agent from settings.
 * @returns True if applied successfully, false otherwise.
 */
export function applyUserAgentFromSettings() {
  const ua = getCurrentUserAgent();
  meow(`User agent: [${ua}]`, 'tabs][userAgents', meowLevel.INFO);
  // TODO: Traverse all webviewControllers and set their UAs.
}

/**
 * Get user agent from settings.
 * @returns User agent string.
 */
export function getCurrentUserAgent(): string {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const uaList = settings.settingsData[41].value as string[][];
  const uaSelected = settings.settingsData[42].value as number;
  const uaDefault = webview.WebviewController.getDefaultUserAgent();
  return uaSelected == -1 ? uaDefault : uaList[uaSelected][1];
}

/**
 * Apply user agent to webview.
 * @param userAgent The user agent to be applied.
 * @returns True if success, false if controller.setCustomUserAgent(userAgent) failed, and undefined if userAgent param is empty.
 */
function applyUserAgent(userAgent: string, controller: WebviewController): boolean | undefined {
  // User Agent empty, reject.
  if (!userAgent) {
    meow(`User agent is empty. REJECTING DOING NO CHANGE.`, 'tabs][userAgents', meowLevel.WARN);
    return undefined;
  }

  // User Agent not empty, set.
  try {
    controller.setCustomUserAgent(userAgent);
    meow(`Set custom user agent of controller to: [${userAgent}]`, 'tabs][userAgents', meowLevel.INFO);
    return true;
  } catch (e) {
    meow(`Failed to set custom user agent: [${userAgent}]`, 'tabs][userAgents', meowLevel.ERROR);
    return false;
  }
}
