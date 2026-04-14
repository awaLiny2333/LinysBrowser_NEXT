import { defaultRoundedRadius } from '../../catstypicalframework/utils/ui';
import { meowDialogManager, openDialogRequestType } from '../../hosts/env/classes/meowDialogManager';
import { WoofSettingsDialog } from '../dialogs/WoofSettings/WoofSettings';
import { CatsDevDialog } from '../dialogs/CatsDev/CatsDevCards';
import { WoofColorPickerDialog } from '../dialogs/WoofColorPicker/WoofColorPicker';
import { meowUiStatuses } from '../../hosts/env/classes/meowUiStatuses';
import { meowLayoutModeStatus } from '../../catstypicalframework/hosts/meowLayoutModeStatus';
import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { meowFreeWindowModeStatus } from '../../catstypicalframework/hosts/meowFreeWindowModeStatus';
import { meowMisc } from '../../catstypicalframework/hosts/meowMisc';

/**
 * A place for dialogs.
 * Cooperates with meowDialogManager class.
 */
@ComponentV2
struct MeowPlaceForDialogs {
  @Param @Require myMeowDialogManager: meowDialogManager;
  @Param @Require myMeowUiStatuses: meowUiStatuses;
  // catstypicalframework
  @Param @Require myMeowLayoutModeStatus: meowLayoutModeStatus;
  @Param @Require myMeowFreeWindowModeStatus: meowFreeWindowModeStatus;
  @Param @Require myMeowAvoid: meowAvoid;
  @Param @Require myMeowMisc: meowMisc;

  catsDevDialogController: CustomDialogController = new CustomDialogController({
    builder: CatsDevDialog({
      myMeowDialogManager: this.myMeowDialogManager,
      myMeowLayoutModeStatus: this.myMeowLayoutModeStatus,
      myMeowFreeWindowModeStatus: this.myMeowFreeWindowModeStatus,
      myMeowAvoid: this.myMeowAvoid,
      myMeowMisc: this.myMeowMisc
    }),
    alignment: DialogAlignment.Center,
    width: '90%',
    // height: '90%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofSettingsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofSettingsDialog({ myMeowDialogManager: this.myMeowDialogManager, myMeowUiStatuses: this.myMeowUiStatuses, myMeowLayoutModeStatus: this.myMeowLayoutModeStatus }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofColorPickerController: CustomDialogController = new CustomDialogController({
    builder: WoofColorPickerDialog({ myMeowDialogManager: this.myMeowDialogManager, myMeowLayoutModeStatus: this.myMeowLayoutModeStatus }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });

  build() {
    // Nothing
  }

  @Monitor('myMeowDialogManager.lastRequest')
  openRequestedDialog() {
    const lastRequest = this.myMeowDialogManager.lastRequest;
    if (!lastRequest) {
      return;
    }
    switch (lastRequest.target) {
      case openDialogRequestType.DEV:
        this.catsDevDialogController.open();
        break;
      case openDialogRequestType.SETTINGS:
        this.woofSettingsDialogController.open();
        break;
      case openDialogRequestType.COLOR_PICKER:
        this.woofColorPickerController.open();
        break;
      default:
        break;
    }
  }
}

export { MeowPlaceForDialogs };
