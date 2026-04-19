import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../../catstypicalframework/hosts/meowMisc';
import { defaultRoundedRadius } from '../../catstypicalframework/utils/ui';
import { WoofBookmarksDialog } from '../../dialogs/WoofBookmarks/WoofBookmarks';
import { WoofCatsDevDialog } from '../../dialogs/WoofCatsDev/WoofCatsDevCards';
import { WoofColorPickerDialog } from '../../dialogs/WoofColorPicker/WoofColorPicker';
import { WoofHomepageDialog } from '../../dialogs/WoofHomepage/WoofHomepage';
import { WoofSettingsDialog } from '../../dialogs/WoofSettings/WoofSettings';
import lazy { localMessage, meowAppMessageType } from '../../hosts/system/windows/scripts/messaging';
import { meowUiStatuses } from '../../hosts/system/windows/classes/meowUiStatuses';
import { meowDialogManager, openDialogRequestType } from '../../hosts/system/dialogs/classes/meowDialogManager';
import { WoofAdsBlockerDialog } from '../../dialogs/WoofAdsBlocker/WoofAdsBlocker';
import { WoofWebImagesDialog } from '../../dialogs/WoofWebImages/WoofWebImages';
import { WoofJavaScriptsDialog } from '../../dialogs/WoofJavaScripts/WoofJavaScripts';

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
    builder: WoofSettingsDialog({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofColorPickerController: CustomDialogController = new CustomDialogController({
    builder: WoofColorPickerDialog({
      myDialog: this.myDialog,
      myLayout: this.myLayout,
      onConfirm: (hex) => {
        localMessage(this.myUi, meowAppMessageType.COLOR_PICKED, hex);
      }
    }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
    onDidDisappear: () => {
      localMessage(this.myUi, meowAppMessageType.COLOR_PICKER_CLOSED);
    }
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
  woofAdsBlockerDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofAdsBlockerDialog({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofWebImagesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofWebImagesDialog({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofJavaScriptsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofJavaScriptsDialog({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi }),
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
      case openDialogRequestType.ADSBLOCKER:
        this.woofAdsBlockerDialogController.open();
        break;
      case openDialogRequestType.WEB_IMAGES:
        this.woofWebImagesDialogController.open();
        break;
      case openDialogRequestType.WEB_JAVASCRIPTS:
        this.woofJavaScriptsDialogController.open();
        break;
      default:
        break;
    }
  }
}

export { MeowPlaceForDialogs };
