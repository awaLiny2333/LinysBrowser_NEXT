import lazy { meowManagedSettings } from "../../userdata/settings/classes/meowManagedSettings";
import lazy { AppStorageV2 } from "@kit.ArkUI";

/**
 * Checks if developer options (DEV_MODE) is on.
 * @returns True or false.
 */
export function getDevMode() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const result = settings.settingsData[74].value as boolean;
  return result;
}
