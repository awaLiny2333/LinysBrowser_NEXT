import lazy { getMyApp } from "../../windows/scripts/helpers";
import lazy { openDialogRequestType, meowDialogManager, openDialogRequest } from "../classes/meowDialogManager";
import lazy { AppStorageV2 } from "@kit.ArkUI";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";

/**
 * Request an opening of a dialog.
 * @param type The type of the dialog.
 * @param param Anything to be passed to the dialog.
 * @param ignoreOpened Whether to ignore the opened dialogs.
 */
export function requestDialog(myDialog: meowDialogManager, type: openDialogRequestType, param: string | number | boolean | object = '', ignoreOpened: boolean = false) {
  myDialog.requestOpen(new openDialogRequest(type, param, ignoreOpened));
}

/**
 * Request an opening of a dialog on the most recent window.
 * @param type The type of the dialog.
 * @param param Anything to be passed to the dialog.
 * @param ignoreOpened Whether to ignore the opened dialogs.
 */
export function requestDialogOnMostRecent(type: openDialogRequestType, param: string | number | boolean | object = '', ignoreOpened: boolean = false) {
  const lastFocusedWindowId = getMyApp().lastFocusedWindowId;
  const thatDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${lastFocusedWindowId}`);
  if (thatDialog) {
    thatDialog.requestOpen(new openDialogRequest(type, param, ignoreOpened));
  } else {
    meow(`No meowDialogManager found for windowId ${lastFocusedWindowId}!`, 'requestDialogOnMostRecent', meowLevel.ERROR);
  }
}
