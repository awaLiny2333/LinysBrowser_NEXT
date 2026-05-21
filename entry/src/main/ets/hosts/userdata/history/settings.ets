import { getMySettings } from "../../../components/settings";

/**
 * Gets the maximum quantity of history chunks to be loaded on app startup.
 * @returns The number!
 *
 * @deprecated As we no longer need to care about this for our brand new history managing system!
 */
export function historyIndexLoadQuantityFromSettings() {
  return getMySettings().settingsData[71].value as number;
}

/**
 * Gets the maximum quantity of history suggestions to presented on search.
 * @returns The number!
 */
export function historySuggestionQuantityFromSettings() {
  return getMySettings().settingsData[13].value as number;
}
