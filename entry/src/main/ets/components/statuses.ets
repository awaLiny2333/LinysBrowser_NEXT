import { meowManagedSettings } from "../hosts/settings/classes/meowManagedSettings";
import { meowUiStatuses } from "../hosts/env/classes/meowUiStatuses";
import { AppStorageV2 } from "@kit.ArkUI";
import { summarizedPreferRightHand } from "./settings";
import { meowLayout } from "../catstypicalframework/hosts/meowLayout";

export function currentTabsStyleIsVertical(myLayout: meowLayout) {
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  return mySettings.settingsData[myLayout.wideMode ? 3 : 4].value as string == 'vertical';
}

export function sidebarShouldBeOnTheRight() {
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  const reverseSidebar = mySettings.settingsData[49].value as boolean;
  return summarizedPreferRightHand() && !reverseSidebar;
}

export function showingSidebar(myUi: meowUiStatuses, myLayout: meowLayout) {
  // Exclude || myUi.showBookmarks for now. Let's see what it is like to put the bookmarks in a dialog...
  if (myUi.showTabs && currentTabsStyleIsVertical(myLayout)) {
    return true;
  }
  return false;
}
