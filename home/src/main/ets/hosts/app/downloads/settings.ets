import { getMySettings } from "../../../components/settings";

/**
 * Check if the download should be saved directly.
 * @returns True if direct save is enabled, false otherwise.
 */
export function isDownloadDirectSave() {
  return getMySettings().settingsData[72].value as boolean;
}

/**
 * Check if the download should be automatically viewed in the Files App after saving.
 * @returns True if auto view is enabled, false otherwise.
 */
export function isDownloadAutoView() {
  return getMySettings().settingsData[73].value as boolean;
}
