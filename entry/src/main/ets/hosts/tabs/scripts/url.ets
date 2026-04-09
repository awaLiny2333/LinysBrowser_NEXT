import { meowManagedSettings } from "../../settings/classes/meowManagedSettings";
import { AppStorageV2 } from "@kit.ArkUI";
import { urlDefaultBlank } from "../../settings/scripts/defaultSettingsValues";

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
