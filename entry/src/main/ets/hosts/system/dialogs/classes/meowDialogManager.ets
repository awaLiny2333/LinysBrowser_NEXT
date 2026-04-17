import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";

/**
 * The dialog manager that records dialogs.
 *
 * Works together with MeowPlaceForDialogs, the one and only component that holds dialogs at one place.
 * MeowPlaceForDialogs monitors property lastRequest of this class and reacts when there is a new request of a dialog.
 *
 * ALL DIALOGS SHOULD BE SUMMONED THROUGH requestDialog()!!
 *
 * @see entry/src/main/ets/components/parts/MeowPlaceForDialogs.ets
 * @see entry/src/main/ets/hosts/env/scripts/dialog.ets
 */
@ObservedV2
export class meowDialogManager {
  private openedDialogs: CustomDialogController[] = [];
  @Trace lastRequest: openDialogRequest | undefined;

  /**
   * Request an opening of a dialog. ONLY Expected to be called by function requestDialog defined below.
   * @param req The request.
   */
  requestOpen(req: openDialogRequest) {
    if (req.ignoreOpened || this.isEmpty()) {
      this.lastRequest = req;
    }
  }

  /**
   * Checks if the dialog manager is empty.
   * @returns True if the dialog manager is empty.
   */
  private isEmpty() {
    return this.openedDialogs.length === 0;
  }

  /**
   * Records an opening of a dialog. ONLY Expected to be called by WoofUniFrame.
   * @param dialog The dialog controller.
   * @param label The label of the dialog.
   */
  registerOpenDialog(dialog: CustomDialogController, label: ResourceStr = '') {
    this.openedDialogs.push(dialog);
    meow(`Dialog opened: [${label}]`, 'meowDialogManager', meowLevel.INFO);
  }

  /**
   * Records a closing of a dialog. ONLY Expected to be called by WoofUniFrame.
   * @param dialog The dialog controller.
   * @param label The label of the dialog.
   */
  registerCloseDialog(dialog: CustomDialogController, label: ResourceStr = '') {
    const index = this.openedDialogs.indexOf(dialog);
    if (index > -1) {
      this.openedDialogs.splice(index, 1);
      meow(`Dialog closed: [${label}]`, 'meowDialogManager', meowLevel.INFO);
    }
  }
}

/**
 * Types of dialogs
 */
export enum openDialogRequestType {
  DEV,
  SETTINGS,
  COLOR_PICKER,
  BOOKMARKS,
  BOOKMARKS_PICKER,
  HOMEPAGE
}

/**
 * Request of opening a dialog.
 *
 * Would using an interface be of the same effect as using a class? *Thinking*
 */
@ObservedV2
export class openDialogRequest {
  @Trace target: openDialogRequestType;
  @Trace time: number;
  @Trace param: string | number;
  @Trace ignoreOpened: boolean;

  constructor(target: openDialogRequestType, param: string | number = '', ignoreOpened: boolean = false) {
    this.target = target;
    this.time = Date.now();
    this.param = param;
    this.ignoreOpened = ignoreOpened;
  }
}
