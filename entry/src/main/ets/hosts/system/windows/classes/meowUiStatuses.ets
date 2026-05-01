import { AppStorageV2, window } from "@kit.ArkUI";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { getRandomEmoticon } from "../../../../catstypicalframework/utils/meow";
import { defaultAnimation } from "../../../../components/settings";
import { meowBookmarkItem } from "../../../userdata/bookmarks/classes/meowBookmarkItem";
import { meowManagedSettings } from "../../../userdata/settings/classes/meowManagedSettings";
import { meowDialogManager } from "../../dialogs/classes/meowDialogManager";
import { meowAppMessage } from "./meowAppMessage";

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
  @Trace showMore: boolean = false;
  @Trace showTabs: boolean = false;
  @Trace sidebarShrunk: boolean = true;
  @Trace searchBarFocused: boolean = false;
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
   * The universal go back action on this window.
   * @param source The source of the go back action.
   * @returns Whether ANY action was performed.
   */
  goBackUni(source: meowUiGoBackSource, uiContext: UIContext) {
    let didSomething = false;

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
        didSomething = this.goBackWeb();
        if (didSomething) {
          return true;
        }
      }
    } else if (source == meowUiGoBackSource.BACK) {
      const webBackBack = mySettings.settingsData[10].value as boolean;
      if (webBackBack) {
        didSomething = this.goBackWeb();
        if (didSomething) {
          return true;
        }
      }
    }

    // Back in BrowserCat UI.
    if (this.showMore) {
      animateToImmediately(defaultAnimation(), () => {
        this.showMore = false;
      });
      didSomething = true;
    }

    if (this.searchBarFocused) {
      uiContext.getFocusController().clearFocus();
      animateToImmediately(defaultAnimation(), () => {
        this.searchBarFocused = false;
      });
      didSomething = true;
    }

    return didSomething;
  }

  /**
   * Go backwards in web.
   */
  private goBackWeb() {
    meow(`Try!`, 'meowUiStatuses][goBackWeb', meowLevel.WARN);
    return false; // TODO: return if go back is successful. E.g. if there is no backward page, then we cannot go back, return false.
  }
}

/**
 * Would there be more?? Hmm...
 */
export enum meowUiGoBackSource {
  BACK,
  ESC
}
