import lazy { openDialogRequestType, meowDialogManager, openDialogRequest } from "../classes/meowDialogManager";

/**
 * Request an opening of a dialog.
 * @param type The type of the dialog.
 * @param ignoreOpened Whether to ignore the opened dialogs.
 */
export function requestDialog(myDialog: meowDialogManager, type: openDialogRequestType, param: string | number | boolean | object = '', ignoreOpened: boolean = false) {
  myDialog.requestOpen(new openDialogRequest(type, param, ignoreOpened));
}
