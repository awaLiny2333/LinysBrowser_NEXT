import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../../catstypicalframework/hosts/meowMisc';
import { defaultRoundedRadius } from '../../catstypicalframework/utils/ui';
import { WoofBookmarksDialog } from '../../dialogs/WoofBookmarks/WoofBookmarks';
import { WoofCatsDevDialog } from '../../dialogs/WoofCatsDev/WoofCatsDevCards';
import { WoofColorPickerDialog } from '../../dialogs/WoofColorPicker/WoofColorPicker';
import { WoofHomepageDialog } from '../../dialogs/WoofHomepage/WoofHomepage';
import { WoofSettingsDialog } from '../../dialogs/WoofSettings/WoofSettings';
import { meowDialogManager, openDialogRequestType } from '../../hosts/env/classes/meowDialogManager';
import { meowUiStatuses } from '../../hosts/env/classes/meowUiStatuses';
import { localMessage, meowAppMessageType } from '../../hosts/env/scripts/messaging';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowManagedSettings } from '../../hosts/settings/classes/meowManagedSettings';

/**
 * A place for dialogs.
 * Cooperates with meowDialogManager class.
 */
@ComponentV2
struct MeowPlaceForDialogs {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiStatuses;
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
    builder: WoofColorPickerDialog({
      myDialog: this.myDialog, myLayout: this.myLayout,
      onConfirm: (settingsId, hex) => {
        const mySettings = AppStorageV2.connect(meowManagedSettings)!;
        mySettings.setByIndex(settingsId, hex);
      }
    }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofBookmarksDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofBookmarksDialog({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi, selectMode: false }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofBookmarksPickerDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofBookmarksDialog({
      myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi, selectMode: true,
      onSelect: (folder, path) => {
        if (folder) {
          localMessage(this.myUi, meowAppMessageType.BOOKMARKS_PICKED, path);
        }
      }
    }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofHomepageDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofHomepageDialog({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    // width: '95%',
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
      case openDialogRequestType.BOOKMARKS_PICKER:
        this.woofBookmarksPickerDialogController.open();
        break;
      case openDialogRequestType.HOMEPAGE:
        this.woofHomepageDialogController.open();
        break;
      default:
        break;
    }
  }
}

export { MeowPlaceForDialogs };
