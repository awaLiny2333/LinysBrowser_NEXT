import { openDialogRequestType, meowDialogManager, openDialogRequest } from "../classes/meowDialogManager";

/**
 * Request an opening of a dialog.
 * @param type The type of the dialog.
 * @param ignoreOpened Whether to ignore the opened dialogs.
 */
export function requestDialog(myMeowDialogManager: meowDialogManager, type: openDialogRequestType, param: string | number = '', ignoreOpened: boolean = false) {
  myMeowDialogManager.requestOpen(new openDialogRequest(type, param, ignoreOpened));
}
