import { AppStorageV2, window } from "@kit.ArkUI";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { defaultAnimation } from "../../../../components/settings";
import { meowBookmarkItem } from "../../../userdata/bookmarks/classes/meowBookmarkItem";
import { meowManagedSettings } from "../../../userdata/settings/classes/meowManagedSettings";
import { meowDialogManager } from "../../dialogs/classes/meowDialogManager";
import { meowAppMessage } from "./meowAppMessage";
import { BusinessError } from "@kit.BasicServicesKit";

/**
 * The statuses that are limited to the current window only.
 */
@ObservedV2
export class meowUiStatuses {
  // Window info
  @Trace windowId: string;
  @Trace windowAlias: string;
  @Trace windowObj: window.Window | undefined;
  // UI
  @Trace pin: boolean = false;
  @Trace showMore: boolean = false;
  @Trace showTabs: boolean = false;
  @Trace sidebarShrunk: boolean = true;
  @Trace searchBarFocused: boolean = false;
  @Trace orientation: window.Orientation = window.Orientation.AUTO_ROTATION_RESTRICTED;
  @Trace fullscreenStatus: meowUiFullscreenStatus = meowUiFullscreenStatus.NONE;
  // MeowBookmarksPanel
  @Trace openedStack: meowBookmarkItem[] = [];
  @Trace openedIndexOfLevels: (meowBookmarkItem | undefined)[] = [];
  // Messaging (Shared)
  @Trace localMessageTunnel: meowAppMessage | undefined = undefined; // The great tunnel for local window messaging! *TEMPORARY* but often NOT cleared after reception.

  constructor(windowId: string, windowAlias: string = '') {
    this.windowId = windowId;
    this.windowAlias = windowAlias;
  }

  /**
   * Listen to window status changes.
   */
  listenWindowStatusChange() {
    if (this.windowObj) {
      try {
        this.windowObj.on('windowStatusDidChange', (status) => {
          // If a maximized window is manually recovered by the user:
          if (this.fullscreenStatus == meowUiFullscreenStatus.FULLSCREEN_FULL && status != window.WindowStatusType.FULL_SCREEN) {
            meow(`Window changed from FULL_SCREEN to ${status}! Go NONE!`, `windowStatusDidChange][${this.windowId}`);
            this.fullscreenStatus = meowUiFullscreenStatus.NONE;
          }
        });
      } catch (e) {
        meow(`Failed to listen window status change: ${e.message}`, `meowUiStatuses][${this.windowId}`, meowLevel.ERROR);
      }
    }
  }

  /**
   * The universal go back action on this window.
   * @param source The source of the go back action.
   * @returns Whether ANY action was performed.
   */
  goBackUni(source: meowUiGoBackSource, uiContext: UIContext) {
    // TODO: Do we need go back in bookmarks?

    // Close dialogs.
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.windowId}`)!;
    if (!myDialog.isEmpty()) {
      myDialog.requestCloseTop();
      return true;
    }

    // Back in web.
    const mySettings = AppStorageV2.connect(meowManagedSettings)!;
    if (source == meowUiGoBackSource.ESC) {
      const webBackEsc = mySettings.settingsData[11].value as boolean;
      if (webBackEsc) {
        if (this.goBackWeb()) {
          return true;
        }
      }
    } else if (source == meowUiGoBackSource.BACK) {
      const webBackBack = mySettings.settingsData[10].value as boolean;
      if (webBackBack) {
        if (this.goBackWeb()) {
          return true;
        }
      }
    }

    // Back in BrowserCat UI.

    const inFullscreen = this.fullscreenStatus != meowUiFullscreenStatus.NONE;

    if (inFullscreen) {
      this.fullscreenExit();
      return true;
    }

    if (this.searchBarFocused) {
      uiContext.getFocusController().clearFocus();
      animateToImmediately(defaultAnimation(), () => {
        this.searchBarFocused = false;
      });
      return true;
    }

    if (this.showMore) {
      animateToImmediately(defaultAnimation(), () => {
        this.showMore = false;
      });
      return true;
    }

    return false;
  }

  /**
   * Go backwards in web.
   */
  private goBackWeb() {
    meow(`Try!`, 'meowUiStatuses][goBackWeb', meowLevel.WARN);
    return false; // TODO: return if go back is successful. E.g. if there is no backward page, then we cannot go back, return false.
  }

  /**
   * Toggle the pin state of the window.
   */
  async togglePin() {
    if (this.windowObj) {
      await this.windowObj.setWindowTopmost(!this.pin)
        .then(() => {
          this.pin = !this.pin;
        })
        .catch((e: BusinessError) => {
          meow(`Failed to set window topmost: ${e.message}`, `meowUiStatuses][${this.windowId}`, meowLevel.ERROR);
        });
    }
  }

  /**
   * Sets the display orientation of the window.
   */
  async setOrientation(orientation: window.Orientation) {
    return this.windowObj?.setPreferredOrientation(orientation)
      .then((data) => {
        meow(`this.windowObj?.setPreferredOrientation(orientation) Set ${orientation}, Returned: ${JSON.stringify(data)}`, `meowUiStatuses][${this.windowId}][setOrientation`);
        this.orientation = orientation;
        return true;
      })
      .catch((err: string) => {
        meow(`this.windowObj?.setPreferredOrientation(orientation) Failed: ${JSON.stringify(err)}`, `meowUiStatuses][${this.windowId}][setOrientation`, meowLevel.ERROR);
        return false;
      });
  }

  /**
   * Toggle the windowed fullscreen status of the window.
   */
  async fullscreenWindowed() {
    switch (this.fullscreenStatus) {
      case meowUiFullscreenStatus.NONE:
        animateToImmediately(defaultAnimation(), () => {
          this.fullscreenStatus = meowUiFullscreenStatus.FULLSCREEN_WINDOWED;
        });
        break;
      case meowUiFullscreenStatus.FULLSCREEN_WINDOWED:
        animateToImmediately(defaultAnimation(), () => {
          this.fullscreenStatus = meowUiFullscreenStatus.NONE;
        });
        break;
      case meowUiFullscreenStatus.FULLSCREEN_FULL:
        // Exit fullscreen
        this.windowObj?.recover().catch((e: BusinessError) => {
          meow(`Failed to recover window: ${e.message}`, `meowUiStatuses][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
        });
        this.fullscreenStatus = meowUiFullscreenStatus.FULLSCREEN_WINDOWED;
        break;
    }
  }

  /**
   * Toggle the full fullscreen status of the window.
   */
  async fullscreenFull() {
    switch (this.fullscreenStatus) {
      case meowUiFullscreenStatus.NONE:
        this.fullscreenStatus = meowUiFullscreenStatus.FULLSCREEN_FULL; // Put this line first to avoid render / display flaws. // This seems helpless to the issue :P
        // Enter fullscreen
        this.windowObj?.maximize().catch((e: BusinessError) => {
          meow(`Failed to maximize window: ${e.message}`, `meowUiStatuses][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
        });
        break;
      case meowUiFullscreenStatus.FULLSCREEN_WINDOWED:
        this.fullscreenStatus = meowUiFullscreenStatus.FULLSCREEN_FULL;
        // Enter fullscreen
        this.windowObj?.maximize().catch((e: BusinessError) => {
          meow(`Failed to maximize window: ${e.message}`, `meowUiStatuses][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
        });
        break;
      case meowUiFullscreenStatus.FULLSCREEN_FULL:
        this.fullscreenExit();
        break;
    }
  }

  /**
   * Exit fullscreen.
   */
  private fullscreenExit() {
    this.windowObj?.recover().catch((e: BusinessError) => {
      meow(`Failed to recover window: ${e.message}`, `meowUiStatuses][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
    });
    this.fullscreenStatus = meowUiFullscreenStatus.NONE;
  }
}

/**
 * Would there be more?? Hmm...
 */
export enum meowUiGoBackSource {
  BACK,
  ESC
}

export enum meowUiFullscreenStatus {
  NONE,
  FULLSCREEN_WINDOWED,
  FULLSCREEN_FULL
}

/**
* All window orientation enums.
* @returns The GRAND list orz.
* */
export const allWindowOrientations = [
  window.Orientation.UNSPECIFIED,
  window.Orientation.PORTRAIT,
  window.Orientation.LANDSCAPE,
  window.Orientation.PORTRAIT_INVERTED,
  window.Orientation.LANDSCAPE_INVERTED,
  window.Orientation.AUTO_ROTATION,
  window.Orientation.AUTO_ROTATION_PORTRAIT,
  window.Orientation.AUTO_ROTATION_LANDSCAPE,
  window.Orientation.AUTO_ROTATION_RESTRICTED,
  window.Orientation.AUTO_ROTATION_PORTRAIT_RESTRICTED,
  window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED,
  window.Orientation.LOCKED,
  window.Orientation.AUTO_ROTATION_UNSPECIFIED,
  window.Orientation.USER_ROTATION_PORTRAIT,
  window.Orientation.USER_ROTATION_LANDSCAPE,
  window.Orientation.USER_ROTATION_PORTRAIT_INVERTED,
  window.Orientation.USER_ROTATION_LANDSCAPE_INVERTED,
  window.Orientation.FOLLOW_DESKTOP
];