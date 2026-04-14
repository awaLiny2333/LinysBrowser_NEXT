import { meowManagedSettings } from "../hosts/settings/classes/meowManagedSettings";
import { meowUiStatuses } from "../hosts/env/classes/meowUiStatuses";
import { AppStorageV2 } from "@kit.ArkUI";
import { summarizedPreferRightHand } from "./settings";
import { meowLayout } from "../catstypicalframework/hosts/meowLayout";

/**
 * Check the settings and see if the current tabs style is vertical, taking into consideration the current layout wide mode status.
 * @param myLayout The layout of the current window.
 * @returns True if the current tabs style is vertical, false otherwise.
 */
export function currentTabsStyleIsVertical(myLayout: meowLayout) {
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  return mySettings.settingsData[myLayout.wideMode ? 3 : 4].value as string == 'vertical';
}

/**
 * Check the settings and see if the sidebar should be on the right.
 * @returns True if the sidebar should be on the right, false otherwise.
 */
export function sidebarShouldBeOnTheRight() {
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  const reverseSidebar = mySettings.settingsData[49].value as boolean;
  return summarizedPreferRightHand() && !reverseSidebar;
}

/**
 * Checks if the sidebar should be shown.
 * For now, this is true iff a VERTICAL tab panel is shown.
 * @param myUi The UI status of the current window.
 * @param myLayout The layout of the current window.
 * @returns True if the sidebar should be shown, false otherwise.
 */
export function showingSidebar(myUi: meowUiStatuses, myLayout: meowLayout) {
  // Exclude || myUi.showBookmarks for now. Let's see what it is like to put the bookmarks in a dialog...
  if (myUi.showTabs && currentTabsStyleIsVertical(myLayout)) {
    return true;
  }
  return false;
}
