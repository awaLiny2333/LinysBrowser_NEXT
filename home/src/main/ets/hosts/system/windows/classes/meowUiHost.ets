import lazy { Want } from "@kit.AbilityKit";
import lazy { AppStorageV2, window } from "@kit.ArkUI";
import lazy { BusinessError } from "@kit.BasicServicesKit";
import { meowAvoid } from "../../../../catstypicalframework/hosts/meowAvoid";
import { meowLayout } from "../../../../catstypicalframework/hosts/meowLayout";
import { meowMisc } from "../../../../catstypicalframework/hosts/meowMisc";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { ensureDirectoryExist, removeDir, renameFolder } from "../../../../catstypicalframework/utils/storage";
import lazy { updateNavigationIndicator } from "../../../../catstypicalframework/utils/ui";
import { getKeywordEntries, UnifiedDestinationResult, UnifiedDestinationResultType, unifyDestination } from "../../../../catstypicalframework/utils/url";
import { meowThemeColorType, UnifiedButtonsType } from "../../../../components/constants";
import { addressBarId } from "../../../../components/parts/Homepage/addressBar/MeowAddressBar";
import { defaultAnimation, getColor, isTabsStyleVertical, maxSuggestionsBookmark, maxSuggestionsHistory, showWindowTitle, sideAreaShrinkAuto, useEffects, webBackBack, webBackEsc, windowTitleOnAddressBar } from "../../../../components/settings";
import { meowTabsBunch } from "../../../app/tabs/classes/meowTabsBunch";
import lazy { concatSearchWithEngine } from "../../../app/tabs/scripts/searchEngines";
import { startUpOptionFromSettings, userHomeUrl, userNewTabUrl } from "../../../app/tabs/settings";
import lazy { meowBookmarkItem } from "../../../userdata/bookmarks/classes/meowBookmarkItem";
import lazy { meowBookmarkStash } from "../../../userdata/bookmarks/classes/meowBookmarkStash";
import lazy { meowHistorian } from "../../../userdata/history/classes/meowHistorian";
import lazy { meowHistoryEntry } from "../../../userdata/history/classes/meowHistoryEntry";
import lazy { meowDialogManager } from "../../dialogs/classes/meowDialogManager";
import lazy { AddressBarStatuses } from "../scripts/addressBarStatuses";
import lazy { getCreateMyApp } from "../scripts/helpers";
import lazy { meowAppMessage } from "./meowAppMessage";

/**
 * The statuses that are limited to the current window only.
 */
@ObservedV2
export class meowUiHost {
  // Window info
  @Trace windowId: string;
  @Trace windowAlias: string = '';
  @Trace windowObj: window.Window | undefined;
  @Trace windowStage: window.WindowStage | undefined;
  @Trace workingDir: string; // TODO: Should be changed after setting ON / OFF being a zone.
  @Trace isZone: boolean = false;
  // Wants
  launchWant: Want;
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
  @Trace tabsSelectingSleep: boolean = false; // Whether is selecting tabs to be put into sleep.
  // Side area
  @Trace showTabs: boolean = false;
  @Trace sidebarPage: string = UnifiedButtonsType.HISTORIES;
  @Trace showSidebar: boolean = false;
  @Trace sideAreaWidth: number = 0; // The side area includes all things (Vertical tabs, side bar panels)
  @Trace sideAreaShrinkBlock_menu: boolean = false; // When this is true, the side area should NOT auto shrink. This is currently only used by the sidebar button editor.
  @Trace sideAreaShrinkBlock_drag: boolean = false;
  @Trace sideAreaShrinkExpect: boolean = false;
  // Search & Address bar
  @Trace addressBarContentMajor: string = ''; // The contents in the address bar.
  @Trace addressBarContentCurrentField: string = ''; // The currently focused field / TextInput content. Majorly used for suggesting things.
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
  suggestionsRefreshId: number = 0; //
  // Settings
  @Trace isExportingData: boolean = false;
  // MeowBookmarksPanel
  @Trace openedStack: meowBookmarkItem[] = [];
  @Trace openedIndexOfLevels: (meowBookmarkItem | undefined)[] = [];
  // Messaging
  @Trace localMessageTunnel: meowAppMessage | undefined = undefined; // The great tunnel for local window messaging! *TEMPORARY* but often NOT cleared after reception.

  constructor(want: Want, windowId: string, workingDirectory: string) {
    this.launchWant = want;
    this.windowId = windowId;
    this.workingDir = workingDirectory;
    // Determine isZone
    const paths = workingDirectory.split('/');
    paths.pop(); // Zone alias name, should be == windowId
    this.isZone = paths.pop() == 'zones'; // The zones folder name.
  }

  // Getters

  get myDialog() {
    return AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.windowId}`)!;
  }

  get myTabs() {
    return AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.windowId}`)!;
  }

  get myLayout() {
    return AppStorageV2.connect(meowLayout, `meowLayout_${this.windowId}`)!;
  }

  get myAvoid() {
    return AppStorageV2.connect(meowAvoid, `meowAvoid_${this.windowId}`)!;
  }

  get myMisc() {
    return AppStorageV2.connect(meowMisc, `meowMisc_${this.windowId}`)!;
  }

  /**
   * In free window mode, and title top (major) area is empty, and is in wide mode then is true.
   */
  get titleTopCanShift() {
    return this.titleTopEmpty && getCreateMyApp().freeWindow && this.myLayout.wideMode;
  }

  /**
   * Whether there is nothing in the major title top area.
   */
  get titleTopEmpty() {
    if (windowTitleOnAddressBar() || !showWindowTitle(this)) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * Whether to show vertical tabs.
   */
  get showingVerticalTabs() {
    return this.showTabs && isTabsStyleVertical(this);
  }

  /**
   * Whether the side area is shrunk. Takes the blocker into consideration.
   */
  get sideAreaShrunkSummarized() {
    return this.sideAreaShrinkExpect && !this.sideAreaShrinkBlock_menu && !this.sideAreaShrinkBlock_drag;
  }

  /**
   * Whether the side area is blocked from shrinking.
   * E.g. dragging something over the area, or the edit menu of a button is opened.
   */
  get sideAreaShrunkBlocked() {
    return this.sideAreaShrinkBlock_menu || this.sideAreaShrinkBlock_drag;
  }

  // Methods

  /**
   * Ensures the working directory exist and determines if isZone.
   */
  async initWorkingDir() {
    const alreadyExist = await ensureDirectoryExist(this.workingDir); // Opened tabs for this window.
    meow(`Ensured directory [${this.workingDir}]. isZone = [${this.isZone}]. alreadyExist = [${alreadyExist}].`, `meowUiHost][initWorkingDir][${this.windowId}`, meowLevel.WARN);

    // Load something
    const startUpOption = startUpOptionFromSettings();
    if (startUpOption == 'continue') {
      await this.myTabs.loadAllStatesFromDir(this.workingDir);
    } else if (startUpOption == 'home') {
      await this.myTabs.newTabWrapped(userHomeUrl());
    } else if (startUpOption == 'new tab') {
      await this.myTabs.newTabWrapped(userNewTabUrl());
    } else {
      // Do nothing
    }
  }

  /**
   * The universal go back action on this window.
   * @param source The source of the go back action.
   * @returns Whether ANY action was performed.
   */
  goBackUni(source: meowUiGoBackSource, uiContext: UIContext) {

    // Close dialogs.
    if (!this.myDialog.isEmpty()) {
      this.myDialog.requestCloseTop();
      return true;
    }

    const inFullscreen = this.fullscreenStatus != meowUiFullscreenStatus.NONE;
    if (inFullscreen) {
      this.fullscreenExit();
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
    if ((this.showSidebar || this.showingVerticalTabs) && sideAreaShrinkAuto() && !this.sideAreaShrinkExpect && !this.sideAreaShrinkBlock_menu) {
      animateToImmediately(defaultAnimation(), () => {
        this.sideAreaShrinkExpect = true;
      });
      meow(`Auto shrink vertical tabs.`, 'goBackUni');
      return true;
    }

    // In-page search
    if (this.inPageSearchShow) {
      this.myTabs.currentTabSearchCancel();
      animateToImmediately(defaultAnimation(), () => {
        this.inPageSearchShow = false;
      });
      return true;
    }

    return false;
  }

  /**
   * Go backwards in web.
   * @returns if go back is successful. E.g. if there is no backward page, then we cannot go back, return false.
   */
  private goBackWeb() {
    const tabBackSuccessful = this.myTabs.goBackCurrent();
    if (tabBackSuccessful) {
      return true;
    } else {
      // Try close tab
      if (this.myTabs.tabs.length > 0) {
        this.myTabs.closeCurrent();
        return true;
      } else {
        return false;
      }
    }
  }

  // WINDOW

  /**
   * Does the cleaning jobs of this window. Is the very last method called in the window's life.
   * Removes the working directory if not isZone.
   * And destroys the web nodes, and clears hosts from AppStorageV2.
   */
  async reportWindowClose() {
    meow(`Window [${this.windowId}] closed.`, `meowUiHost][reportWindowClose][${this.windowId}`, meowLevel.WARN);
    const isLastWindow = getCreateMyApp().windowIds.length == 0;
    const nextTimeNeed = startUpOptionFromSettings() == 'continue';

    // Web nodes
    this.myTabs.requestDestroy();

    // Remove if is either one of:
    // 1. Not ZONE && not last window
    // 2. Not ZONE && (IS last window &&) not next time need
    if (!this.isZone && (!isLastWindow || !nextTimeNeed)) {
      await removeDir(this.workingDir);
      meow(`Removed directory [${this.workingDir}]. isLastWindow = [${isLastWindow}], nextTimeNeed = [${nextTimeNeed}].`, `meowUiHost][reportWindowClose][${this.windowId}`, meowLevel.WARN);
    } else {
      // Is a zone, or is the last non-zone but next time need.
      // Remove nothing.

      // These doesn't seem to work as intended... :(
      // Sometimes they are not triggered?
      // meow(`About to save all webStates to disk!`, `meowUiHost][reportWindowClose][${this.windowId}`, meowLevel.WARN);
      // await Promise.all(this.myTabs.tabs.map((tab): Promise<boolean> => tab.saveWebState()));
    }

    // Clear from AppStorageV2
    AppStorageV2.remove(`meowTabsBunch_${this.windowId}`);
    AppStorageV2.remove(`meowLayout_${this.windowId}`);
    AppStorageV2.remove(`meowUiHost_${this.windowId}`);
    AppStorageV2.remove(`meowAvoid_${this.windowId}`);
    AppStorageV2.remove(`meowMisc_${this.windowId}`);
  }

  /**
   * Update the window title.
   */
  async updateWindowTitle() {
    const alias = this.isZone ? `󰙟 ${this.windowAlias}` : this.windowAlias;
    meow(`Update window title to: ${alias}`, `meowUiHost][${this.windowId}][updateWindowTitle`, meowLevel.WARN);
    this.windowObj?.setWindowTitle(alias)
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
   * Sets the alias of the window.
   */
  async setWindowAlias(newAlias: string) {
    this.windowAlias = newAlias;
    await this.updateWindowTitle();

    // Zones names
    if (this.isZone) {
      // Replace the last part of current workingDir to the newAlias
      const oldDir = this.workingDir;
      this.workingDir = this.workingDir.replace(/\/[^/]+$/, `/${newAlias}`);
      await renameFolder(oldDir, this.workingDir);
    }
  }

  /**
   * Toggle the windowed fullscreen status of the window.
   */
  async fullscreenWindowed() {
    this.showMore = false;

    // Exit if is already in windowed fullscreen.
    if (this.fullscreenStatus === meowUiFullscreenStatus.FULLSCREEN_WINDOWED) {
      this.fullscreenExit();
      return;
    }

    // For NONE & FULLSCREEN_FULL, enter windowed fullscreen.
    animateToImmediately(defaultAnimation(), () => {
      this.fullscreenStatus = meowUiFullscreenStatus.FULLSCREEN_WINDOWED;
    });
    this.windowObj?.recover().catch((e: BusinessError) => {
      meow(`Failed to recover window: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenWindowed`, meowLevel.ERROR);
    });
    this.windowObj?.setSpecificSystemBarEnabled('status', true).catch((e: BusinessError) => {
      meow(`Failed to show status: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenWindowed`, meowLevel.ERROR);
    });
  }

  /**
   * Toggle the full fullscreen status of the window.
   */
  async fullscreenFull() {
    this.showMore = false;

    // Exit if is already in full fullscreen.
    if (this.fullscreenStatus === meowUiFullscreenStatus.FULLSCREEN_FULL) {
      this.fullscreenExit();
      return;
    }

    // For NONE & FULLSCREEN_WINDOWED, enter full fullscreen.
    animateToImmediately(defaultAnimation(), () => {
      this.fullscreenStatus = meowUiFullscreenStatus.FULLSCREEN_FULL;
    });
    this.windowObj?.maximize().catch((e: BusinessError) => {
      meow(`Failed to maximize window: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
    });
    this.windowObj?.setSpecificSystemBarEnabled('status', false).catch((e: BusinessError) => {
      meow(`Failed to hide status: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
    });
    this.windowObj?.setSpecificSystemBarEnabled('navigationIndicator', false).catch((e: BusinessError) => {
      meow(`Failed to hide navigationIndicator: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenFull`, meowLevel.ERROR);
    });
  }

  /**
   * Exit fullscreen.
   */
  fullscreenExit() {
    this.webFullscreenHandler?.exitFullScreen();
    this.windowObj?.recover().catch((e: BusinessError) => {
      meow(`Failed to recover window: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenExit`, meowLevel.ERROR);
    });
    this.windowObj?.setSpecificSystemBarEnabled('status', true).catch((e: BusinessError) => {
      meow(`Failed to show status: ${e.message}`, `meowUiHost][${this.windowId}][fullscreenExit`, meowLevel.ERROR);
    });
    updateNavigationIndicator(this.windowObj!);
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
      if (getCreateMyApp().dark) {
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

  /**
   * Hide the address bar overlay for a period.
   */
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

  /**
   * Show the address bar overlay back.
   */
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
   * Clear address bar focus.
   * @param uiContext The uiContext.
   */
  requestAddressBarBlur(uiContext: UIContext) {
    uiContext.getFocusController().clearFocus();
    this.reportAddressBarBlur();
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

  // SEARCH / ADDRESS BAR

  /**
   * Sets the address bar content of the window.
   * Also refreshes the keyword entries and / or destination on demand (passed in args).
   * @param newContent The new search content.
   * @param doKeywordRefresh Whether to refresh the keyword entries.
   */
  setAddressBarContent(newContent: string, doKeywordRefresh: boolean, doDestinationRefresh: boolean) {
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
  setCurrentFieldContent(newContent: string, timeout: number = 10) {
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
    if (this.searchKeywordEntries.length > 0 && preferedKeysSet.has(this.searchKeywordEntries[0][0])) {
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
    // Generation ID
    this.suggestionsRefreshId += 1; // Iterate this ID.
    const myGeneration = this.suggestionsRefreshId;

    // User-set Limits
    const maxResultsBookmarks = maxSuggestionsBookmark();
    const maxResultsHistorian = maxSuggestionsHistory();

    // History
    if (this.addressBarContentCurrentField.length > 0 && maxResultsHistorian > 0) {
      const myHistorian = AppStorageV2.connect(meowHistorian)!;
      myHistorian.lookUpHistoryEntries(this.addressBarContentCurrentField, maxResultsHistorian, false, 0.8, true).then((resultsHistories) => {
        // Not the latest request, drop.
        if (myGeneration !== this.suggestionsRefreshId) {
          return;
        }
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
   * The universal gateway to submit search on CURRENT TAB!
   * @param url If set, then load the URL. If not, then loads the searchUnifyResult.url
   */
  submitSearchOrLoad(url?: string) {
    if (url) {
      this.addressBarContentMajor = url;
      this.refreshKeywordEntries();
      this.refreshDestination();
    }
    const target = this.searchUnifyResult?.url || concatSearchWithEngine('').result;
    this.myTabs.loadOnCurrentTab(target);
    // SEARCH / LOAD!
    meow(`Visit / load [${target}]!`, 'meowUiHost][submitSearchOrLoad', meowLevel.WARN);
  }

  /**
   * Open a NEW TAB with the given URL.
   * @param url The URL.
   */
  openNewTab(url: string) {
    this.myTabs.newTabWrapped(url);
  }

  /**
   * Open a URL in the current tab or a new tab depending on the current tab's state.
   * @param url The URL.
   */
  openUrlAuto(url: string) {
    if (this.myTabs.currentTab?.url) {
      // Current tab is not empty.
      this.openNewTab(url);
    } else {
      // Current tab is empty / no tab is current.
      this.submitSearchOrLoad(url);
    }
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
