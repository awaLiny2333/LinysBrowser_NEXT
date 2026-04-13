import { openDialogRequestType, meowDialogManager, openDialogRequest } from "../classes/meowDialogManager";
import { AppStorageV2 } from "@kit.ArkUI";

/**
 * Request an opening of a dialog.
 * @param type The type of the dialog.
 * @param ignoreOpened Whether to ignore the opened dialogs.
 */
export function requestDialog(type: openDialogRequestType, param: string | number = '', ignoreOpened: boolean = false) {
  const myMeowDialogManager: meowDialogManager = AppStorageV2.connect(meowDialogManager)!;
  myMeowDialogManager.requestOpen(new openDialogRequest(type, param, ignoreOpened));
}
