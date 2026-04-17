import { meowManagedSettings } from "../../data/settings/classes/meowManagedSettings";
import { AppStorageV2 } from "@kit.ArkUI";

/**
 * Checks if developer options (DEV_MODE) is on.
 * @returns True or false.
 */
export function getDevMode() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const result = settings.settingsData[74].value as boolean;
  return result;
}
