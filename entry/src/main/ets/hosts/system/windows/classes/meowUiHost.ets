import { AppStorageV2, window } from "@kit.ArkUI";
import { BusinessError } from "@kit.BasicServicesKit";
import { meowLayout } from "../../../../catstypicalframework/hosts/meowLayout";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { getKeywordEntries, UnifiedDestinationResult, UnifiedDestinationResultType, unifyDestination } from "../../../../catstypicalframework/utils/url";
import { meowThemeColorType, UnifiedButtonsType } from "../../../../components/constants";
import { addressBarId } from "../../../../components/parts/Homepage/addressBar/MeowAddressBar";
import { defaultAnimation, getColor, isTabsStyleVertical, maxSuggestionsBookmark, maxSuggestionsHistory, sideAreaShrinkAuto, useEffects, webBackBack, webBackEsc } from "../../../../components/settings";
import { meowTabsBunch } from "../../../app/tabs/classes/meowTabsBunch";
import lazy { concatSearchWithEngine } from "../../../app/tabs/scripts/searchEngines";
import lazy { meowBookmarkItem } from "../../../userdata/bookmarks/classes/meowBookmarkItem";
import lazy { meowBookmarkStash } from "../../../userdata/bookmarks/classes/meowBookmarkStash";
import lazy { meowHistorian } from "../../../userdata/history/classes/meowHistorian";
import lazy { meowHistoryEntry } from "../../../userdata/history/classes/meowHistoryEntry";
import lazy { meowDialogManager } from "../../dialogs/classes/meowDialogManager";
import lazy { AddressBarStatuses } from "../scripts/addressBarStatuses";
import { getMyApp } from "../scripts/helpers";
import lazy { meowAppMessage } from "./meowAppMessage";

/**
 * The statuses that are limited to the current window only.
 */
@ObservedV2
export class meowUiHost {
  // Window info
  @Trace windowId: string;
  @Trace windowAlias: string;
  @Trace windowObj: window.Window | undefined;
  @Trace windowStage: window.WindowStage | undefined;
  // UI
  @Trace windowFocused: boolean = true;
  @Trace pin: boolean = false;
  @Trace orientation: window.Orientation = window.Orientation.AUTO_ROTATION_RESTRICTED;
  @Trace fullscreenStatus: meowUiFullscreenStatus = meowUiFullscreenStatus.NONE;
  @Trace webFullscreenHandler: FullScreenExitHandler | undefined = undefined;
  @Trace showMore: boolean = false;
  @Trace dropHover: boolean = false;
  dropHoverFlipTimeoutId: number | undefined = undefined;
  @Trace showAddressBarOverlay: boolean = false;
  addressBarOverlayReShowTimeoutId: number | undefined = undefined;
  // Side area
  @Trace showTabs: boolean = false;
  @Trace sidebarPage: string = UnifiedButtonsType.HISTORIES;
  @Trace showSidebar: boolean = false;
  @Trace sideAreaWidth: number = 0; // The side area includes all things (Vertical tabs, side bar panels)
  @Trace sideAreaShrinkBlock_menu: boolean = false; // When this is true, the side area should NOT auto shrink. This is currently only used by the sidebar button editor.
  @Trace sideAreaShrinkBlock_drag: boolean = false;
  @Trace sideAreaShrunkExpect: boolean = false;
  // Search & Address bar
  @Trace addressBarContentMajor: string = '';
  @Trace addressBarContentCurrentField: string = ''; // The current focused field / TextInput content. Majorly used for suggesting things.
  @Trace searchUnifyResult: UnifiedDestinationResult = { url: '', type: UnifiedDestinationResultType.URL_SCHEMED }; // this empty url is filled in flow.
  @Trace searchKeywordEntries: [string, string][] = [];
  @Trace searchKeywordEntriesExpanded: boolean = false;
  @Trace addressBarPreferHttps: boolean = false;
  @Trace addressBarFocused: boolean = false;
  @Trace addressBarStatus: AddressBarStatuses = AddressBarStatuses.NO_SHIFT;
  addressBarBlurTimeoutId: number | undefined = undefined;
  // In-page search
  @Trace inPageSearchShow: boolean = false;
  // Suggesting
  @Trace suggestionsHistories: meowHistoryEntry[] = [];
  @Trace suggestionsBookmarks: meowBookmarkItem[] = [];
  suggestionsRefreshTimeoutId: number | undefined = undefined;
  // Settings
  @Trace isExportingData: boolean = false;
  // MeowBookmarksPanel
  @Trace openedStack: meowBookmarkItem[] = [];
  @Trace openedIndexOfLevels: (meowBookmarkItem | undefined)[] = [];
  // Messaging
  @Trace localMessageTunnel: meowAppMessage | undefined = undefined; // The great tunnel for local window messaging! *TEMPORARY* but often NOT cleared after reception.

  constructor(windowId: string, windowAlias: string = '') {
    this.windowId = windowId;
    this.windowAlias = windowAlias;
  }

  /**
   * Whether to show vertical tabs.
   */
  get showingVerticalTab() {
    const myLayout = AppStorageV2.connect(meowLayout, `meowLayout_${this.windowId}`)!;
    return this.showTabs && isTabsStyleVertical(myLayout);
  }

  /**
   * Whether the side area is shrunk. Takes the blocker into consideration.
   */
  get sideAreaShrunkSummarized() {
    return this.sideAreaShrunkExpect && !this.sideAreaShrinkBlock_menu && !this.sideAreaShrinkBlock_drag;
  }

  /**
   * Whether the side area is blocked from shrinking.
   */
  get sideAreaShrunkBlocked() {
    return this.sideAreaShrinkBlock_menu || this.sideAreaShrinkBlock_drag;
  }

  get myTabs() {
    const myTabs: meowTabsBunch = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.windowId}`)!;
    return myTabs;
  }

  get myLayout() {
    const myLayout: meowLayout = AppStorageV2.connect(meowLayout, `meowLayout_${this.windowId}`)!;
    return myLayout;
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
    if (source == meowUiGoBackSource.ESC) {
      if (webBackEsc()) {
        if (this.goBackWeb()) {
          return true;
        }
      }
    } else if (source == meowUiGoBackSource.BACK) {
      if (webBackBack()) {
        if (this.goBackWeb()) {
          return true;
        }
      }
    }

    // Back in BrowserCat UI.

    if (this.addressBarFocused) {
      this.requestAddressBarBlur(uiContext);
      return true;
    }

    if (this.showMore) {
      animateToImmediately(defaultAnimation(), () => {
        this.showMore = false;
      });
      return true;
    }

    // Have side area ENABLED & AUTOSHRINK & EXPANDED & NOT BLOCKED
    if ((this.showSidebar || this.showingVerticalTab) && sideAreaShrinkAuto() && !this.sideAreaShrunkExpect && !this.sideAreaShrinkBlock_menu) {
      animateToImmediately(defaultAnimation(), () => {
        this.sideAreaShrunkExpect = true;
      });
      meow(`Auto shrink vertical tabs.`, 'goBackUni');
      return true;
    }

    // In-page search
    if (this.inPageSearchShow) {
      const myTabs: meowTabsBunch = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.windowId}`)!;
      myTabs.currentTabSearchCancel();
      animateToImmediately(defaultAnimation(), () => {
        this.inPageSearchShow = false;
      });
      return true;
    }

    const inFullscreen = this.fullscreenStatus != meowUiFullscreenStatus.NONE;
    if (inFullscreen) {
      this.fullscreenExit();
      return true;
    }

    return false;
  }

  /**
   * Go backwards in web.
   * @returns if go back is successful. E.g. if there is no backward page, then we cannot go back, return false.
   */
  private goBackWeb() {
    const myTabs: meowTabsBunch = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.windowId}`)!;
    return myTabs.goBackCurrent();
  }

  // WINDOW

  /**
   * Update the window title.
   */
  async updateWindowTitle() {
    meow(`Update window title to: ${this.windowAlias}`, `meowUiHost][${this.windowId}][updateWindowTitle`, meowLevel.WARN);
    this.windowObj?.setWindowTitle(this.windowAlias)
      .catch((e: BusinessError) => {
        meow(`Failed to set window title: ${e.message}`, `meowUiHost][${this.windowId}][updateWindowTitle`, meowLevel.ERROR);
      });
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
          meow(`Failed to set window topmost: ${e.message}`, `meowUiHost][${this.windowId}`, meowLevel.ERROR);
        });
    }
  }

  /**
   * Sets the display orientation of the window.
   */
  async setOrientation(orientation: window.Orientation) {
    return this.windowObj?.setPreferredOrientation(orientation)
      .then((data) => {
        meow(`this.windowObj?.setPreferredOrientation(orientation) Set ${orientation}, Returned: ${JSON.stringify(data)}`, `meowUiHost][${this.windowId}][setOrientation`);
        this.orientation = orientation;
        return true;
      })
      .catch((err: string) => {
        meow(`this.windowObj?.setPreferredOrientation(orientation) Failed: ${JSON.stringify(err)}`, `meowUiHost][${this.windowId}][setOrientation`, meowLevel.ERROR);
        return false;
      });
  }

  /**
   * Toggle the windowed fullscreen status of the window.
   */
  async fullscreenWindowed() {
    this.showMore = false;
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
        this.webFullscreenHandler?.exitFullScreen();
        break;
      case meowUiFullscreenStatus.FULLSCREEN_FULL:
        // Exit fullscreen
        this.windowObj?.recover().catch((e: BusinessError) => {
          meow(`Failed to recover window: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
        });
        this.fullscreenStatus = meowUiFullscreenStatus.FULLSCREEN_WINDOWED;
        break;
    }
  }

  /**
   * Toggle the full fullscreen status of the window.
   */
  async fullscreenFull() {
    this.showMore = false;
    switch (this.fullscreenStatus) {
      case meowUiFullscreenStatus.NONE:
        this.fullscreenStatus = meowUiFullscreenStatus.FULLSCREEN_FULL; // Put this line first to avoid render / display flaws. // This seems helpless to the issue :P
        // Enter fullscreen
        this.windowObj?.maximize().catch((e: BusinessError) => {
          meow(`Failed to maximize window: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
        });
        break;
      case meowUiFullscreenStatus.FULLSCREEN_WINDOWED:
        this.fullscreenStatus = meowUiFullscreenStatus.FULLSCREEN_FULL;
        // Enter fullscreen
        this.windowObj?.maximize().catch((e: BusinessError) => {
          meow(`Failed to maximize window: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
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
  fullscreenExit() {
    this.webFullscreenHandler?.exitFullScreen();
    this.windowObj?.recover().catch((e: BusinessError) => {
      meow(`Failed to recover window: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
    });
    animateToImmediately(defaultAnimation(), () => {
      this.fullscreenStatus = meowUiFullscreenStatus.NONE;
    });
  }

  /**
   * Updates the background color for the window.
   */
  updateWindowBackgroundColor() {
    let color = getColor(meowThemeColorType.SECONDARY) as ResourceColor as string;
    if (useEffects()) {
      if (getMyApp().dark) {
        color = '#ff000000'; // Set all black
      } else {
        color = '#ffffffff'; // Set all white
      }
    }
    try {
      this.windowObj?.setWindowBackgroundColor(color);
      meow(`windowObj.setWindowBackgroundColor("${color}") Success!`, 'meowUiHost][updateWindowBackgroundColor', meowLevel.INFO);
    } catch (e) {
      meow(`windowObj.setWindowBackgroundColor("${color}") Failed: ${e}`, 'meowUiHost][updateWindowBackgroundColor', meowLevel.ERROR);
    }
  }

  requestHideAddressBarOverlay() {
    if (this.showAddressBarOverlay) {
      animateToImmediately(defaultAnimation(), () => {
        this.showAddressBarOverlay = false;
      });
    }
    clearTimeout(this.addressBarOverlayReShowTimeoutId);
    this.addressBarOverlayReShowTimeoutId = setTimeout(() => {
      if (this.addressBarFocused) {
        return; // Reject if user is typing something
      }
      animateToImmediately(defaultAnimation(), () => {
        this.showAddressBarOverlay = true;
      });
    }, 4399);
  }

  requestShowAddressBarOverlay() {
    clearTimeout(this.addressBarOverlayReShowTimeoutId);
    if (!this.showAddressBarOverlay) {
      animateToImmediately(defaultAnimation(), () => {
        this.showAddressBarOverlay = true;
      });
    }
  }

  // FOCUS

  /**
   * Clear address bar focus.
   * @param uiContext The uiContext.
   */
  requestAddressBarBlur(uiContext: UIContext) {
    uiContext.getFocusController().clearFocus();
    this.reportAddressBarBlur();
  }

  /**
   * Focus address bar.
   * @param uiContext The uiContext.
   */
  requestAddressBarFocus(uiContext: UIContext) {
    this.requestHideAddressBarOverlay();
    try {
      uiContext.getFocusController().requestFocus(addressBarId);
      this.reportAddressBarFocus();
      return true;
    } catch (e) {
      meow(`Failed to request focus: ${e.message}`, `meowUiHost][${this.windowId}][focusAddressbar`, meowLevel.ERROR);
      return false;
    }
  }

  /**
   * Called after focusing the adress bar, to synchronize the statuses in this meowUiHost.
   */
  reportAddressBarFocus() {
    clearTimeout(this.addressBarBlurTimeoutId);
    if (!this.addressBarFocused) {
      animateToImmediately(defaultAnimation(), () => {
        this.addressBarFocused = true;
      });
    }
  }

  /**
   * Called after blurring the address bar, to synchronize the statuses in this meowUiHost.
   */
  reportAddressBarBlur() {
    clearTimeout(this.addressBarBlurTimeoutId);
    if (this.addressBarFocused) {
      this.addressBarBlurTimeoutId = setTimeout(() => {
        animateToImmediately(defaultAnimation(), () => {
          this.addressBarFocused = false;
        });
      }, 50);
    }
    this.requestHideAddressBarOverlay();
  }

  // SEARCH

  /**
   * Sets the current search content of the window.
   * Also refreshes the keyword entries and / or destination on demand (passed in args).
   * @param newContent The new search content.
   * @param doKeywordRefresh Whether to refresh the keyword entries.
   */
  setCurrentSearchContent(newContent: string, doKeywordRefresh: boolean, doDestinationRefresh: boolean) {
    this.addressBarContentMajor = newContent;
    if (doKeywordRefresh) {
      this.refreshKeywordEntries();
    }
    if (doDestinationRefresh) {
      this.refreshDestination();
    }
  }

  /**
   * Sets the current field content of the address bar.
   * @param newContent The new field content.
   */
  setCurrentFieldContent(newContent: string, timeout: number = 1) {
    if (this.addressBarContentCurrentField != newContent) {
      this.addressBarContentCurrentField = newContent;
      // Refresh suggestions
      clearTimeout(this.suggestionsRefreshTimeoutId);
      this.suggestionsRefreshTimeoutId = setTimeout(() => {
        this.refreshSuggestions();
      }, timeout);
    }
  }

  /**
   * Tries to auto shift the address bar, if there are query keys available.
   */
  tryAutoShift() {
    if (this.addressBarStatus == AddressBarStatuses.NO_SHIFT) {
      return;
    }
    if (preferedKeysSet.has(this.searchKeywordEntries[0][0])) {
      // Shift to search keyword entries.
      if (this.addressBarStatus == AddressBarStatuses.CAN_SHIFT) {
        animateToImmediately(defaultAnimation(), () => {
          this.addressBarStatus = AddressBarStatuses.SHIFTED;
        });
      }
    } else {
      // Shift back to pure url.
      if (this.addressBarStatus == AddressBarStatuses.SHIFTED) {
        animateToImmediately(defaultAnimation(), () => {
          this.addressBarStatus = AddressBarStatuses.NO_SHIFT;
        });
      }
    }
  }

  /**
   * Refreshes the keyword entries.
   */
  refreshKeywordEntries() {
    const entries = getKeywordEntries(this.addressBarContentMajor);
    if (entries.length > 0) {
      // Put the prefered keys to the beginning
      let matched: [string, string][] = [];
      let unmatched: [string, string][] = [];
      for (let i = 0; i < entries.length; i++) {
        let entry = entries[i];
        if (preferedKeysSet.has(entry[0])) {
          matched.push(entry);
        } else {
          unmatched.push(entry);
        }
      }
      // const matched = entries.filter(([key]) => keySet.has(key));
      // const unmatched = entries.filter(([key]) => !keySet.has(key));
      const entriesSorted = [...matched, ...unmatched];
      this.searchKeywordEntries = entriesSorted;

      // Switch state.
      if (this.addressBarStatus == AddressBarStatuses.NO_SHIFT) {
        this.addressBarStatus = AddressBarStatuses.CAN_SHIFT;
      }
    } else {
      this.searchKeywordEntries = [];
      this.addressBarStatus = AddressBarStatuses.NO_SHIFT;
    }
  }

  /**
   * Refreshes the unified destination.
   */
  refreshDestination() {
    this.searchUnifyResult = unifyDestination(this.addressBarContentMajor, this.addressBarPreferHttps);
  }

  /**
   * Refreshes the suggestions.
   */
  refreshSuggestions() {
    const maxResultsBookmarks = maxSuggestionsBookmark();
    const maxResultsHistorian = maxSuggestionsHistory();

    // History
    if (this.addressBarContentCurrentField.length > 0 && maxResultsHistorian > 0) {
      const myHistorian = AppStorageV2.connect(meowHistorian)!;
      myHistorian.lookUpHistoryEntries(this.addressBarContentCurrentField, maxResultsHistorian, false, 0.8, true).then((resultsHistories) => {
        animateToImmediately(defaultAnimation(), () => {
          this.suggestionsHistories = resultsHistories;
        });
      });
    } else {
      animateToImmediately(defaultAnimation(), () => {
        this.suggestionsHistories = [];
      });
    }

    // Bookmarks
    let newSuggestionsBookmarks: meowBookmarkItem[];
    const myBookmarks = AppStorageV2.connect(meowBookmarkStash)!;
    if (this.addressBarContentCurrentField.length > 0 && maxResultsBookmarks > 0) {
      const resultsBookmarks = myBookmarks.lookUpBookmarksEntries(this.addressBarContentCurrentField, maxResultsBookmarks, 0.8);
      newSuggestionsBookmarks = resultsBookmarks;
    } else {
      newSuggestionsBookmarks = [];
    }
    animateToImmediately(defaultAnimation(), () => {
      this.suggestionsBookmarks = newSuggestionsBookmarks;
    });
  }

  /**
   * The universal gateway to submit search!
   * @param url If set, then load the URL. If not, then loads the searchUnifyResult.url
   */
  submitSearchOrLoad(url?: string) {
    if (url) {
      this.addressBarContentMajor = url;
      this.refreshKeywordEntries();
      this.refreshDestination();
    }
    const target = this.searchUnifyResult?.url || concatSearchWithEngine('').result;
    const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.windowId}`)!;
    myTabs.loadOnCurrentTab(target);
    // SEARCH / LOAD!
    meow(`Visit / load [${target}]!`, 'meowUiHost][submitSearchOrLoad', meowLevel.WARN);
  }

  /**
   * Open a new tab with the given URL.
   * @param url The URL.
   */
  openNewTab(url: string) {
    const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.windowId}`)!;
    myTabs.newTabWrapped(url);
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
export const ALL_WINDOW_ORIENTATIONS = [
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

const preferedKeys: string[] = ['q', 'query', 's', 'key', 'wd', 'w', 'word', 'searchKeyWord', 'search_text', 'keyword', 'val', 'value', 'text', 'tag', 'tags', 'search'];
const preferedKeysSet = new Set(preferedKeys);
