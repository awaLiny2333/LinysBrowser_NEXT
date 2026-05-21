import { meowAvoid } from '../../catstypicalframework/hosts/meowAvoid';
import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
import { meowMisc } from '../../catstypicalframework/hosts/meowMisc';
import { defaultRoundedRadius } from '../../catstypicalframework/utils/ui';
import lazy { WoofBookmarksDialog } from '../../dialogs/parts/WoofBookmarks/WoofBookmarks';
import lazy { WoofCatsDevDialog } from '../../dialogs/parts/WoofCatsDev/WoofCatsDevCards';
import lazy { WoofCreditsDialog } from '../../dialogs/parts/WoofCredits/WoofCredits';
import lazy { WoofHistoryDialog } from '../../dialogs/parts/WoofHistory/WoofHistory';
import lazy { WoofScratchingBoardDialog } from '../../dialogs/parts/WoofScratchingBoard/WoofScratchingBoard';
import lazy { WoofSettingsDialog } from '../../dialogs/parts/WoofSettings/WoofSettings';
import lazy { WoofUpdatesDialog } from '../../dialogs/parts/WoofUpdates/WoofUpdates';
import lazy { WoofColorPickerDialog } from '../../dialogs/public/WoofColorPicker/WoofColorPicker';
import lazy { WoofErrorPromptDialog } from '../../dialogs/public/WoofErrorPrompt/WoofErrorPrompt';
import lazy { WoofKeyShortcutPickerDialog } from '../../dialogs/public/WoofKeyShortcutPicker/WoofKeyShortcutPicker';
import lazy { WoofQRDialog } from '../../dialogs/public/WoofQR/WoofQR';
import lazy { WoofAdBlockerDialog } from '../../dialogs/settings/WoofAdBlocker/WoofAdBlocker';
import lazy { WoofAdBlockerRulesDialog } from '../../dialogs/settings/WoofAdBlocker/WoofAdBlockerRules';
import lazy { WoofCookiesDialog } from '../../dialogs/settings/WoofCookies/WoofCookies';
import lazy { WoofDarkDialog } from '../../dialogs/settings/WoofDark/WoofDark';
import lazy { WoofFaultLogsDialog } from '../../dialogs/settings/WoofFaultLogs/WoofFaultLogs';
import lazy { WoofHomepageDialog } from '../../dialogs/settings/WoofHomepage/WoofHomepage';
import lazy { WoofJavaScriptsDialog } from '../../dialogs/settings/WoofJavaScripts/WoofJavaScripts';
import lazy { WoofKeyShortcutsDialog } from '../../dialogs/settings/WoofKeyShortcuts/WoofKeyShortcuts';
import lazy { WoofButtonsDialog } from '../../dialogs/settings/WoofMeowButtons/ButtonsManager';
import lazy { WoofWebImagesDialog } from '../../dialogs/settings/WoofWebImages/WoofWebImages';
import lazy { WoofWebGeolocationDialog } from '../../dialogs/web/permissions/WoofLocation';
import lazy { WoofPermissionsDialog } from '../../dialogs/web/permissions/WoofPermissions';
import lazy { WoofRequestScreenCaptureDialog } from '../../dialogs/web/permissions/WoofRequestScreenCapture';
import lazy { WoofQuickSEDialog } from '../../dialogs/web/settings/WoofQuickSE';
import lazy { WoofQuickUADialog } from '../../dialogs/web/settings/WoofQuickUA';
import lazy { WoofAlertDialog } from '../../dialogs/web/WoofAlert';
import lazy { WoofConfirmDialog } from '../../dialogs/web/WoofConfirm';
import lazy { WoofJumpDialog } from '../../dialogs/web/WoofJump';
import lazy { WoofPromptDialog } from '../../dialogs/web/WoofPrompt';
import lazy { WoofSslErrorDialog } from '../../dialogs/web/WoofSslError';
import { meowDialogManager, openDialogRequestType } from '../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiHost } from '../../hosts/system/windows/classes/meowUiHost';
import lazy { localMessage, meowAppMessageType } from '../../hosts/system/windows/scripts/messaging';

/**
 * A place for dialogs.
 * Cooperates with meowDialogManager class.
 */
@ComponentV2
struct MeowPlaceForDialogs {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiHost;
  // catstypicalframework
  @Param @Require myLayout: meowLayout;
  @Param @Require myAvoid: meowAvoid;
  @Param @Require myMisc: meowMisc;

  WoofErrorPromptDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofErrorPromptDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
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
  woofAdBlockerDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofAdBlockerDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofAdBlockerRulesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofAdBlockerRulesDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofWebImagesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofWebImagesDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofJavaScriptsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofJavaScriptsDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofDarkDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofDarkDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofKeyShortcutsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofKeyShortcutsDialog({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofKeyShortcutsPickerDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofKeyShortcutPickerDialog({
      myDialog: this.myDialog, myLayout: this.myLayout, onConfirm: (bind) => {
        // meow(`Messaged ${bind}`);
        localMessage(this.myUi, meowAppMessageType.KEY_SHORTCUTS_PICKED, bind);
      }
    }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofButtonsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofButtonsDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofHistoryDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofHistoryDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofCookiesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofCookiesDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofFaultLogsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofFaultLogsDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofUpdatesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofUpdatesDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofQRDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofQRDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofQuickUADialogController: CustomDialogController = new CustomDialogController({
    builder: WoofQuickUADialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofQuickSEDialoController: CustomDialogController = new CustomDialogController({
    builder: WoofQuickSEDialog({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofCreditsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofCreditsDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofScratchingBoardDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofScratchingBoardDialog({ myDialog: this.myDialog, myLayout: this.myLayout, myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofJumpDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofJumpDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofAlertDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofAlertDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofConfirmDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofConfirmDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofPromptDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofPromptDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofSslErrorDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofSslErrorDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofPermissionsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofPermissionsDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofRequestScreenCaptureDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofRequestScreenCaptureDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
    alignment: DialogAlignment.Center,
    // width: '95%',
    // height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofWebGeolocationDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofWebGeolocationDialog({ myDialog: this.myDialog, myLayout: this.myLayout }),
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
      case openDialogRequestType.ERROR_PROMPT:
        this.WoofErrorPromptDialogController.open();
        break;
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
      case openDialogRequestType.ADBLOCKER:
        this.woofAdBlockerDialogController.open();
        break;
      case openDialogRequestType.ADBLOCKER_RULES:
        this.woofAdBlockerRulesDialogController.open();
        break;
      case openDialogRequestType.WEB_IMAGES:
        this.woofWebImagesDialogController.open();
        break;
      case openDialogRequestType.WEB_JAVASCRIPTS:
        this.woofJavaScriptsDialogController.open();
        break;
      case openDialogRequestType.DARK:
        this.woofDarkDialogController.open();
        break;
      case openDialogRequestType.KEY_SHORTCUTS:
        this.woofKeyShortcutsDialogController.open();
        break;
      case openDialogRequestType.KEY_SHORTCUTS_PICKER:
        this.woofKeyShortcutsPickerDialogController.open();
        break;
      case openDialogRequestType.BUTTONS:
        this.woofButtonsDialogController.open();
        break;
      case openDialogRequestType.HISTORY:
        this.woofHistoryDialogController.open();
        break;
      case openDialogRequestType.COOKIES:
        this.woofCookiesDialogController.open();
        break;
      case openDialogRequestType.FAULTLOGS:
        this.woofFaultLogsDialogController.open();
        break;
      case openDialogRequestType.UPDATES:
        this.woofUpdatesDialogController.open();
        break;
      case openDialogRequestType.QR:
        this.woofQRDialogController.open();
        break;
      case openDialogRequestType.QUICK_UA:
        this.woofQuickUADialogController.open();
        break;
      case openDialogRequestType.QUICK_SE:
        this.woofQuickSEDialoController.open();
        break;
      case openDialogRequestType.CREDITS:
        this.woofCreditsDialogController.open();
        break;
      case openDialogRequestType.SCRATCHING_BOARD:
        this.woofScratchingBoardDialogController.open();
        break;
      case openDialogRequestType.JUMP:
        this.woofJumpDialogController.open();
        break;
      case openDialogRequestType.ALERT:
        this.woofAlertDialogController.open();
        break;
      case openDialogRequestType.CONFIRM:
        this.woofConfirmDialogController.open();
        break;
      case openDialogRequestType.PROMPT:
        this.woofPromptDialogController.open();
        break;
      case openDialogRequestType.SSL_ERROR:
        this.woofSslErrorDialogController.open();
        break;
      case openDialogRequestType.WEB_PERMISSIONS:
        this.woofPermissionsDialogController.open();
        break;
      case openDialogRequestType.SCREEN_CAPTURE:
        this.woofRequestScreenCaptureDialogController.open();
        break;
      case openDialogRequestType.WEB_GEOLOCATION:
        this.woofWebGeolocationDialogController.open();
        break;
      default:
        break;
    }
  }
}

export { MeowPlaceForDialogs };
