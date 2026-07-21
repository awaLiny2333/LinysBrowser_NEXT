import { defaultRoundedRadius } from '../../catstypicalframework/utils/ui';
import lazy { WoofBookmarksDialog } from '../../dialogs/parts/WoofBookmarks/WoofBookmarks';
import lazy { WoofCatsDevDialog } from '../../dialogs/parts/WoofCatsDev/WoofCatsDevCards';
import lazy { WoofCreditsDialog } from '../../dialogs/parts/WoofCredits/WoofCredits';
import lazy { WoofDownloadsDialog } from '../../dialogs/parts/WoofDownloads/WoofDownloads';
import lazy { WoofHistoryDialog } from '../../dialogs/parts/WoofHistory/WoofHistory';
import lazy { WoofScratchingBoardDialog } from '../../dialogs/parts/WoofScratchingBoard/WoofScratchingBoard';
import lazy { WoofSettingsDialog } from '../../dialogs/parts/WoofSettings/WoofSettings';
import lazy { WoofUpdatesDialog } from '../../dialogs/parts/WoofUpdates/WoofUpdates';
import lazy { WoofZonesDialog } from '../../dialogs/parts/WoofZones/WoofZones';
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
import lazy { WoofHttpAuthDialog } from '../../dialogs/web/auth/WoofHttpAuth';
import lazy { WoofDownloadAskDialog } from '../../dialogs/web/misc/WoofDownloadAsk';
import lazy { WoofJumpDialog } from '../../dialogs/web/misc/WoofJump';
import lazy { WoofSslErrorDialog } from '../../dialogs/web/misc/WoofSslError';
import lazy { WoofWebGeolocationDialog } from '../../dialogs/web/permissions/WoofLocation';
import lazy { WoofPermissionsDialog } from '../../dialogs/web/permissions/WoofPermissions';
import lazy { WoofRequestScreenCaptureDialog } from '../../dialogs/web/permissions/WoofRequestScreenCapture';
import lazy { WoofQuickSEDialog } from '../../dialogs/web/settings/WoofQuickSE';
import lazy { WoofQuickUADialog } from '../../dialogs/web/settings/WoofQuickUA';
import lazy { WoofAlertDialog } from '../../dialogs/web/window/WoofAlert';
import lazy { WoofConfirmDialog } from '../../dialogs/web/window/WoofConfirm';
import lazy { WoofPromptDialog } from '../../dialogs/web/window/WoofPrompt';
import { openDialogRequestType } from '../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiHost } from '../../hosts/system/windows/classes/meowUiHost';
import lazy { localMessage, meowAppMessageType } from '../../hosts/system/windows/scripts/messaging';

/**
 * A place for dialogs.
 * Cooperates with meowDialogManager class.
 */
@ComponentV2
struct MeowPlaceForDialogs {
  @Param @Require myUi: meowUiHost;

  woofErrorPromptDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofErrorPromptDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofCatsDevDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofCatsDevDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofSettingsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofSettingsDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofColorPickerController: CustomDialogController = new CustomDialogController({
    builder: WoofColorPickerDialog({
      myUi: this.myUi,
      onConfirm: (hex) => {
        localMessage(this.myUi, meowAppMessageType.COLOR_PICKED, hex);
      }
    }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
    onDidDisappear: () => {
      localMessage(this.myUi, meowAppMessageType.COLOR_PICKER_CLOSED);
    }
  });
  woofBookmarksDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofBookmarksDialog({ myUi: this.myUi, selectMode: false }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofBookmarksPickerDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofBookmarksDialog({
      myUi: this.myUi, selectMode: true,
      onSelect: (folder, path) => {
        if (folder) localMessage(this.myUi, meowAppMessageType.BOOKMARKS_PICKED, path);
      }
    }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofHomepageDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofHomepageDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofAdBlockerDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofAdBlockerDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofAdBlockerRulesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofAdBlockerRulesDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofWebImagesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofWebImagesDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofJavaScriptsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofJavaScriptsDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofDarkDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofDarkDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofKeyShortcutsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofKeyShortcutsDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofKeyShortcutsPickerDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofKeyShortcutPickerDialog({
      myUi: this.myUi, onConfirm: (bind) => {
        localMessage(this.myUi, meowAppMessageType.KEY_SHORTCUTS_PICKED, bind);
      }
    }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofButtonsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofButtonsDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofHistoryDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofHistoryDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofCookiesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofCookiesDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofFaultLogsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofFaultLogsDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofUpdatesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofUpdatesDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofQRDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofQRDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofQuickUADialogController: CustomDialogController = new CustomDialogController({
    builder: WoofQuickUADialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofQuickSEDialoController: CustomDialogController = new CustomDialogController({
    builder: WoofQuickSEDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofCreditsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofCreditsDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofScratchingBoardDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofScratchingBoardDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofDownloadsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofDownloadsDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofJumpDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofJumpDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofAlertDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofAlertDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofConfirmDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofConfirmDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofPromptDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofPromptDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofSslErrorDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofSslErrorDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofPermissionsDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofPermissionsDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofRequestScreenCaptureDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofRequestScreenCaptureDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofWebGeolocationDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofWebGeolocationDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofHttpAuthDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofHttpAuthDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofDownloadAskDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofDownloadAskDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    cornerRadius: defaultRoundedRadius + 4,
  });
  woofZonesDialogController: CustomDialogController = new CustomDialogController({
    builder: WoofZonesDialog({ myUi: this.myUi }),
    alignment: DialogAlignment.Center,
    width: '95%',
    height: '95%',
    cornerRadius: defaultRoundedRadius + 4,
  });


  build() {
    // Nothing
  }

  @Monitor('myUi.myDialog.lastRequest')
  openRequestedDialog() {
    const lastRequest = this.myUi.myDialog.lastRequest;
    if (!lastRequest) {
      return;
    }
    switch (lastRequest.target) {
      case openDialogRequestType.ERROR_PROMPT:
        this.woofErrorPromptDialogController.open();
        break;
      case openDialogRequestType.DEV:
        this.woofCatsDevDialogController.open();
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
      case openDialogRequestType.DOWNLOADS:
        this.woofDownloadsDialogController.open();
        break;
      case openDialogRequestType.DOWNLOAD_ASK:
        this.woofDownloadAskDialogController.open();
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
      case openDialogRequestType.HTTP_AUTH:
        this.woofHttpAuthDialogController.open();
        break;
      case openDialogRequestType.ZONES:
        this.woofZonesDialogController.open();
        break;
      default:
        break;
    }
  }
}

export { MeowPlaceForDialogs };
