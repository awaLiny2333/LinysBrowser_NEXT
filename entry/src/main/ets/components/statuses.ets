/**
 * ALL UI STATUSES GETTERS SHOULD BE HERE!
 */
import { meowLayout } from "../catstypicalframework/hosts/meowLayout";
import { meowUiHost } from "../hosts/system/windows/classes/meowUiHost";
import { isTabsStyleVertical } from "./settings";

/**
 * Checks if the sidebar should be shown.
 * For now, this is true iff a VERTICAL tab panel is shown.
 * @param myUi The UI status of the current window.
 * @param myLayout The layout of the current window.
 * @returns True if the sidebar should be shown, false otherwise.
 */
export function showingSidebar(myUi: meowUiHost, myLayout: meowLayout) {
  // Exclude || myUi.showBookmarks for now. Let's see what it is like to put the bookmarks in a dialog...
  if (myUi.showTabs && isTabsStyleVertical(myLayout)) {
    return true;
  }
  return false;
}
