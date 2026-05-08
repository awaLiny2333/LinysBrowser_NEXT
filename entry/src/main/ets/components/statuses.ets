/**
 * ALL UI STATUSES GETTERS SHOULD BE HERE!
 */
import { meowLayout } from "../catstypicalframework/hosts/meowLayout";
import { standardSpacing } from "./settings";

export function sidebarWidth(myLayout: meowLayout) {
  if (myLayout.wideMode) {
    return defaultSidebarWidth;
  } else {
    return myLayout.width - 2 * standardSpacing;
  }
}

export const defaultSidebarWidth = 360;
