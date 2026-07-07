import lazy { webview } from "@kit.ArkWeb";
import { getMySettings } from "../../../components/settings";
import lazy { defaultSearchEngine } from "../../userdata/settings/scripts/defaultSettingsValues";

// Start up
/**
 * Gets the start up option from settings.
 * @returns 'continue' | 'home' | 'new tab'
 */
export function startUpOptionFromSettings() {
  return getMySettings().settingsData[32].value as string;
}

// History
/**
 * Gets if the current settings allows recording new history entries.
 * @returns True or false!
 */
export function recordNewHistoryFromSettings() {
  return getMySettings().settingsData[69].value as boolean;
}

// Cookies
/**
 * Check if intelligent tracking prevention is enabled.
 * @returns True if enabled, false otherwise.
 */
export function intelligentTrackingPrevention() {
  const result = getMySettings().settingsData[33].value as boolean;
  return result;
}

/**
 * Check if third-party cookies are allowed.
 * @returns True if allowed, false otherwise.
 */
export function thirdPartyCookies() {
  const result = getMySettings().settingsData[34].value as boolean;
  return result;
}

// URL

/**
 * Gets the new tab url set by the user from settings.
 * @returns The new tab url set in meowManagedSettings.
 */
export function userNewTabUrl() {
  return getMySettings().settingsData[31].value as string;
}

export function userHomeUrl() {
  return getMySettings().settingsData[30].value as string;
}


// Search Engines

export function searchEngineList() {
  return getMySettings().settingsData[43].value as string[][];
}

export function searchEngineSelected() {
  return getMySettings().settingsData[44].value as number;
}

/**
 * Gets the default search engine from settings.
 * @returns The default search engine set in meowManagedSettings or the defaultSearchEngine if not set.
 */
export function getSearchEngineFromSettings() {
  const seSelected = searchEngineSelected();
  const se = seSelected == -1 ? defaultSearchEngine() : searchEngineList()[seSelected][1];
  return se;
}

// User Agents

export function userAgentList() {
  return getMySettings().settingsData[41].value as string[][];
}

export function userAgentRuleList() {
  return getMySettings().settingsData[85].value as string[][];
}

export function userAgentSelected() {
  return getMySettings().settingsData[42].value as number;
}

export function userAgent4Slim() {
  return getMySettings().settingsData[86].value as string;
}

export function userAgent4SlimEnabled() {
  return getMySettings().settingsData[88].value as boolean;
}

/**
 * Get the current user agent applied globally.
 * @returns The UA string, or an empty string if selected the default UA but webview.WebviewController.getDefaultUserAgent() returned nothing.
 */
export function getCurrentAppUserAgent(): string {
  const uaSelected = userAgentSelected();
  const uaDefault = webview.WebviewController.getDefaultUserAgent();
  return uaSelected == -1 ? uaDefault : userAgentList()[uaSelected][1];
}

// SITE

// AdBlock

/**
 * If ad blocker is enabled.
 * @returns True if enabled, false otherwise.
 */
export function useAdBlock() {
  return getMySettings().settingsData[52].value as boolean;
}

export function adBlockExceptions() {
  return getMySettings().settingsData[53].value as string[];
}

// Dark

/**
 * If web dark mode is forced.
 * @returns True if forced, false otherwise.
 */
export function forceWebDarkMode() {
  return getMySettings().settingsData[60].value as boolean;
}

export function forceWebDarkExceptions() {
  return getMySettings().settingsData[61].value as string[];
}

// Images

export function disableWebImages() {
  return getMySettings().settingsData[57].value as boolean;
}

export function disableWebImagesOnAllSites() {
  return getMySettings().settingsData[58].value as boolean;
}

export function disableWebImagesSites() {
  return getMySettings().settingsData[59].value as string[];
}

// JS

export function disableWebJavaScripts() {
  return getMySettings().settingsData[54].value as boolean;
}

export function disableWebJavaScriptsOnAllSites() {
  return getMySettings().settingsData[55].value as boolean;
}

export function disableWebJavaScriptSites() {
  return getMySettings().settingsData[56].value as string[];
}

// Context menu

export function contextMenuEnabled() {
  return getMySettings().settingsData[16].value as boolean;
}

export function contextMenuImagePreview() {
  return getMySettings().settingsData[17].value as boolean;
}

export function contextMenuWebPreview() {
  return getMySettings().settingsData[18].value as boolean;
}

export function contextMenuImageWidth() {
  return getMySettings().settingsData[19].value as number;
}

export function contextMenuWebHeight() {
  return getMySettings().settingsData[20].value as number;
}

export function contextMenuStripText() {
  return getMySettings().settingsData[21].value as boolean;
}
