import lazy { meowManagedSettings } from "../../userdata/settings/classes/meowManagedSettings";
import lazy { AppStorageV2 } from "@kit.ArkUI";

/**
 * Check if the download should be saved directly.
 * @returns True if direct save is enabled, false otherwise.
 */
export function isDownloadDirectSave() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[72].value as boolean;
}

/**
 * Check if the download should be automatically viewed in the Files App after saving.
 * @returns True if auto view is enabled, false otherwise.
 */
export function isDownloadAutoView() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[73].value as boolean;
}
