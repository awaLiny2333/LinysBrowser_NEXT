import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";

/**
 * The dialog manager that records dialogs.
 */
@ObservedV2
export class meowDialogManager {
  @Trace openedDialogs: CustomDialogController[] = [];

  /**
   * Checks if the dialog manager is empty.
   * @returns True if the dialog manager is empty.
   */
  isEmpty() {
    return this.openedDialogs.length === 0;
  }

  /**
   * Records an opening of a dialog.
   * @param dialog The dialog controller.
   * @param label The label of the dialog.
   */
  openDialog(dialog: CustomDialogController, label: ResourceStr = '') {
    this.openedDialogs.push(dialog);
    meow(`Dialog opened: [${label}]`, 'meowDialogManager', meowLevel.INFO);
  }

  /**
   * Records a closing of a dialog.
   * @param dialog The dialog controller.
   * @param label The label of the dialog.
   */
  closeDialog(dialog: CustomDialogController, label: ResourceStr = '') {
    const index = this.openedDialogs.indexOf(dialog);
    if (index > -1) {
      this.openedDialogs.splice(index, 1);
      meow(`Dialog closed: [${label}]`, 'meowDialogManager', meowLevel.INFO);
    }
  }
}
