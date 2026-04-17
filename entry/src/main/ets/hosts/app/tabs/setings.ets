import lazy { AppStorageV2 } from "@kit.ArkUI";
import lazy { webview } from "@kit.ArkWeb";
import lazy { meowManagedSettings } from "../../data/settings/classes/meowManagedSettings";
import lazy { defaultSearchEngine, urlDefaultBlank } from "../../data/settings/scripts/defaultSettingsValues";

// Cookies

/**
 * Check if intelligent tracking prevention is enabled.
 * @returns True if enabled, false otherwise.
 */
export function intelligentTrackingPrevention() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const result = settings.settingsData[33].value as boolean;
  return result;
}

/**
 * Check if third-party cookies are allowed.
 * @returns True if allowed, false otherwise.
 */
export function thirdPartyCookies() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const result = settings.settingsData[34].value as boolean;
  return result;
}

// URL

/**
 * Gets the new tab url from settings.
 * @returns The new tab url set in meowManagedSettings or the urlDefaultBlank if not set.
 */
export function getNewTabUrlFromSettings(): string {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const userNewTabUrl = settings.settingsData[31].value as string;
  if (userNewTabUrl) {
    return userNewTabUrl;
  }
  return urlDefaultBlank();
}

/**
 * Gets the home url from settings.
 * @returns The home url set in meowManagedSettings or the urlDefaultBlank if not set.
 */
export function getHomeUrlFromSettings(): string {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const userHomeUrl = settings.settingsData[30].value as string;
  if (userHomeUrl) {
    return userHomeUrl;
  }
  return urlDefaultBlank();
}

// Search Engines

/**
 * Gets the default search engine from settings.
 * @returns The default search engine set in meowManagedSettings or the defaultSearchEngine if not set.
 */
export function getSearchEngineFromSettings() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const seList = settings.settingsData[43].value as string[][];
  const seSelected = settings.settingsData[44].value as number;
  const se = seSelected == -1 ? defaultSearchEngine() : seList[seSelected][1];
  return se;
}

// User Agents

/**
 * Get user agent from settings.
 * @returns The UA string, or an empty string if selected the default UA but webview.WebviewController.getDefaultUserAgent() returned nothing.
 */
export function getCurrentUserAgent(): string {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const uaList = settings.settingsData[41].value as string[][];
  const uaSelected = settings.settingsData[42].value as number;
  const uaDefault = webview.WebviewController.getDefaultUserAgent();
  return uaSelected == -1 ? uaDefault : uaList[uaSelected][1];
}
