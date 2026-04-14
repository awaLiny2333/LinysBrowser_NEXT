import { meowManagedSettings } from "../../settings/classes/meowManagedSettings";
import { AppStorageV2 } from "@kit.ArkUI";

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
