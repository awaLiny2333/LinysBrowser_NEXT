import { getMySettings } from "../../../components/settings";

export function keyShortcutsString() {
  return getMySettings().settingsData[29].value as string[];
}
