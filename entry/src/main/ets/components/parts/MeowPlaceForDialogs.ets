import { defaultRoundedRadius } from '../../catstypicalframework/utils/ui';
import { meowDialogManager, openDialogRequestType } from '../../hosts/env/classes/meowDialogManager';
import { WoofSettingsDialog } from '../dialogs/WoofSettings/WoofSettings';
import { WoofCatsDevDialog } from '../dialogs/WoofCatsDev/WoofCatsDevCards';
import { WoofColorPickerDialog } from '../dialogs/WoofColorPicker/WoofColorPicker';
import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { meowMisc } from '../../catstypicalframework/hosts/meowMisc';
import { WoofBookmarksDialog } from '../dialogs/WoofBookmarks/WoofBookmarks';

/**
 * A place for dialogs.
 * Cooperates with meowDialogManager class.
 */
@ComponentV2
struct MeowPlaceForDialogs {
  @Param @Require myDialog: meowDialogManager;
  // catstypicalframework
  @Param @Require myLayout: meowLayout;
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myMisc: meowMisc;

  WoofCatsDevDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofCatsDevDialog({
      myDialog: this.myDialog,
      myLayout: this.myLayout,
      myAvoid: this.myAvoid,
      myMisc: this.myMisc
    }),
    alignment: DialogAlignment.Center,
    width: '90%',
    // height: '90%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofSettingsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofSettingsDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofColorPickerController: CustomDialogController = new CustomDialogController({
    builder: WoofColorPickerDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofBookmarksDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofBookmarksDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });

  build() {
    // Nothing
  }

  @Monitor('myDialog.lastRequest')
  openRequestedDialog() {
    const lastRequest = this.myDialog.lastRequest;
    if (!lastRequest) {
      return;
    }
    switch (lastRequest.target) {
      case openDialogRequestType.DEV:
        this.WoofCatsDevDialogController.open();
        break;
      case openDialogRequestType.SETTINGS:
        this.woofSettingsDialogController.open();
        break;
      case openDialogRequestType.COLOR_PICKER:
        this.woofColorPickerController.open();
        break;
      case openDialogRequestType.BOOKMARKS:
        this.woofBookmarksDialogController.open();
        break;
      default:
        break;
    }
  }
}

export { MeowPlaceForDialogs };
