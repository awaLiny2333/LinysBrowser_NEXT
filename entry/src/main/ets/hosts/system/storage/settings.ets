import { getMySettings } from "../../../components/settings";

/**
 * Checks if developer options (DEV_MODE) is on.
 * @returns True or false.
 */
export function getDevMode() {
  const result = getMySettings().settingsData[74].value as boolean;
  return result;
}
