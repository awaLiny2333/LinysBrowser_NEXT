import { AppStorageV2 } from "@kit.ArkUI";
import { meowManagedSettings } from "../../settings/classes/meowManagedSettings";

/**
 * Gets if the current settings allows recording new history entries.
 * @returns True or false!
 */
export function recordNewHistoryFromSettings() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[69].value as boolean;
}

/**
 * Gets the maximum quantity of history chunks to be loaded on app startup.
 * @returns The number!
 *
 * @deprecated As we no longer need to care about this for our brand new history managing system!
 */
export function historyIndexLoadQuantityFromSettings() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[71].value as number;
}

/**
 * Gets the maximum quantity of history suggestions to presented on search.
 * @returns The number!
 */
export function historySuggestionQuantityFromSettings() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[13].value as number;
}
