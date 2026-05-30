import lazy { fastbuffer } from "@kit.ArkTS";
import { AppStorageV2, UIContext } from "@kit.ArkUI";
import { webview } from "@kit.ArkWeb";
import lazy { certificateManager, certificateManagerDialog } from "@kit.DeviceCertificateKit";
import lazy { image } from "@kit.ImageKit";
import lazy { scanBarcode } from "@kit.ScanKit";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { addUnitsToSize, readArrayBuffer, saveHybrid, unlinkFile } from "../../../../catstypicalframework/utils/storage";
import { defaultAnimation } from "../../../../components/settings";
import { meowDialogManager, openDialogRequestType } from "../../../system/dialogs/classes/meowDialogManager";
import lazy { requestDialog } from "../../../system/dialogs/scripts/dialog";
import { meowUiFullscreenStatus, meowUiHost } from "../../../system/windows/classes/meowUiHost";
import lazy { globalMessage, meowAppMessageType } from "../../../system/windows/scripts/messaging";
import { meowHistorian } from "../../../userdata/history/classes/meowHistorian";
import { meowHistoryEntry } from "../../../userdata/history/classes/meowHistoryEntry";
import lazy { getMyDawn } from "../../downloads/scripts/helper";
import { disableImages, disableJS, forceDark, viewableSchemes } from "../scripts/helpers";
import { intelligentTrackingPrevention, recordNewHistoryFromSettings, useAdBlock, userHomeUrl, userNewTabUrl } from "../settings";
import { meowTabsBunch } from "./meowTabsBunch";
import { TabNodeController } from "./WebNode";

@ObservedV2
export class meowTabInfo {
  @Trace myUi: meowUiHost; // NOTE: Should be updated once this tab is sent to other window!
  @Trace controller: WebviewController | undefined;
  @Trace node: TabNodeController | undefined;
  // Web States
  webStateId: string;
  @Trace restoringWebState: boolean = false;
  @Trace saveWebStateTimeoutId: number | undefined;
  // UI info
  @Trace endOfLoadTimestamp: number = Number.MAX_VALUE; // Requests to save history / webstate after this time should be rejected.
  @Trace title: string | undefined;
  @Trace url: string | undefined = userNewTabUrl();
  @Trace progress: number = -1; // -1 for not loading, other positive values from 0 ~ 100 is the progress for loading.
  @Trace canBack: boolean = false;
  @Trace canForw: boolean = false;
  // Web settings
  @Trace forceDark: boolean = true;
  @Trace xJS: boolean = false;
  @Trace xImage: boolean = false;
  @Trace overrideUA: string | undefined;
  // Permissions
  allowedWebPermissions: string[] = [];
  // History
  @Trace saveHistoryTimeoutId: number | undefined;
  lastSavedHistoryEntries: meowHistoryEntry[] = [];
  // Search in page
  @Trace inputSearchKey: string = '';
  @Trace searchedSearchKey: string = '';
  @Trace isSearching: boolean = false;
  @Trace searchIsDone: boolean = true;
  @Trace currentSearchResultIdx: number = -1;
  @Trace searchResultCount: number = 0;
  // Context menu UI
  @Trace offsetX: number = 0;
  @Trace offsetY: number = 0;
  @Trace showMenu: boolean = false;
  // Context menu data
  contextMenuResult: WebContextMenuResult | undefined;
  @Trace linkUrl: string = '';
  @Trace sourceUrl: string = '';
  @Trace unfilteredUrl: string = '';
  @Trace selectedText: string = '';
  @Trace isEditable: boolean = false;
  // Context menu image
  @Trace hasImage: boolean = false;
  @Trace imageArrayBuffer: ArrayBuffer | undefined;
  @Trace imagePixelMap: image.PixelMap | undefined;
  @Trace imageFilename: string = '';
  @Trace imagePath: string = '';
  @Trace imageInfo: image.ImageInfo | undefined;
  @Trace imageQrResults: scanBarcode.ScanResult[] | undefined;

  constructor(myUi: meowUiHost) {
    this.myUi = myUi;
    this.webStateId = this.refreshWebStateId();
  }

  // Statuses

  get isLoading() {
    return this.progress != -1;
  }

  get isActive() {
    return this.node != undefined;
  }

  // LIFE CYCLES

  /**
   * Called when the tab is being closed.
   */
  onClose() {
    clearTimeout(this.saveHistoryTimeoutId);
    clearTimeout(this.saveWebStateTimeoutId);
    this.deleteWebState();

    // Destroy the web node.
    if (this.isActive) {
      this.node!.detachWeb();
      this.node!.dispose();
    }
  }

  /**
   * Called be the receipient window's meowTabsBunch.
   * Includes some final stage preparations, before this.myUi is changed.
   */
  aboutToBeReceived() {
    clearTimeout(this.saveHistoryTimeoutId);
    clearTimeout(this.saveWebStateTimeoutId);
    this.deleteWebState();

    // ↓ Modified from closeTab() in meowTabsBunch.

    if (this.isActive) {
      this.node?.detachWeb();
      this.node?.rebuild();
    }

    if (this == this.myUi.myTabs.currentTab) {
      this.myUi.myTabs.currentTab = undefined;
    }

    // Now only one tab (The tab about to be dragged away)
    // So when it is dragged away, there won't be any left.
    // So clear the url field.
    if (this.myUi.myTabs.tabs.length == 1 && !this.myUi.addressBarFocused) {
      this.myUi.setCurrentSearchContent('', true, true);
    }
  }

  // WEB STATES

  /**
   * Updates and also returns the new webstate id built based on current time.
   * @returns The ID.
   */
  refreshWebStateId() {
    this.webStateId = 'meow_' + Date.now().toString(16).padStart(16, '0');
    return this.webStateId;
  }

  /**
   * Tries to restore web state. Does nothing if no available state files exist.
   * @returns True if succeeded, false if failed.
   */
  async restoreWebState() {
    if (!this.restoringWebState) {
      return;
    }
    const statePath = `${this.myUi.myTabs.workingDir}/${this.webStateId}`;

    // Read and restore web state.
    const arrayBuffer = await readArrayBuffer(statePath);
    if (arrayBuffer && arrayBuffer.byteLength < 512000) {
      const state = new Uint8Array(arrayBuffer);
      try {
        this.controller?.restoreWebState(state);
        meow(`this.controller?.restoreWebState(state) succeeded (${addUnitsToSize(arrayBuffer.byteLength)}).`, 'meowTabInfo][restoreWebState', meowLevel.WARN);
        return true;
      } catch (e) {
        meow(`this.controller?.restoreWebState(state) failed: ${e}.`, 'meowTabInfo][restoreWebState', meowLevel.ERROR);
      }
    }

    // Web state read fail, or too large. Load the URL (Give up history stack).
    const urlPath = `${this.myUi.myTabs.workingDir}/${this.webStateId}_url`;
    const urlBuffer = await readArrayBuffer(urlPath);
    if (urlBuffer) {
      try {
        this.url = fastbuffer.from(urlBuffer).toString();
        this.controller?.loadUrl(this.url);
        return true;
      } catch (e) {
        meow(`this.url = fastbuffer.from(urlBuffer).toString(); failed: ${e}.`, 'meowTabInfo][restoreWebState', meowLevel.ERROR);
      }
    }

    return false;
  }

  /**
   * Updates web state and save them to disk.
   * @returns True if succeeded, false if failed.
   */
  async saveWebState(sourceInfo: string = 'x') {
    if (!this.isActive) {
      return false;
    }
    const startTime = Date.now();
    const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myUi.windowId}`)!;

    let state: Uint8Array = new Uint8Array();
    const label = this.title || '';
    const url = this.url || '';
    if (url != '' || this.canBack || this.canForw) {
      try {
        state = this.controller?.serializeWebState() || new Uint8Array();
      } catch (e) {
        meow(`this.controller?.serializeWebState() failed: ${e}. Put a new Uint8Array().`, `meowTabInfo][saveWebState][${sourceInfo}`, meowLevel.ERROR);
      }
    }

    const wDir = myTabs.workingDir;
    const statePath = `${wDir}/${this.webStateId}`;
    const labelPath = `${wDir}/${this.webStateId}_label`;
    const urlPath = `${wDir}/${this.webStateId}_url`;

    // NOTE: Notice that labelPath and urlPath both ends with letter 'l'!

    await Promise.all([
      saveHybrid(statePath, state.buffer, true),
      saveHybrid(labelPath, label, true),
      saveHybrid(urlPath, url, true)
    ]);

    meow(`Saved webstate to disk:       [${label}](${url}) (${Date.now() - startTime} ms)`, `meowTabInfo][saveWebState][${sourceInfo}`, meowLevel.WARN);
    return true;
  }

  /**
   * Deletes web state and related files.
   * @returns True if succeeded, false if failed.
   */
  async deleteWebState() {
    const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myUi.windowId}`)!;

    const wDir = myTabs.workingDir;
    const statePath = `${wDir}/${this.webStateId}`;
    const labelPath = `${wDir}/${this.webStateId}_label`;
    const urlPath = `${wDir}/${this.webStateId}_url`;

    await Promise.all([
      unlinkFile(statePath),
      unlinkFile(labelPath),
      unlinkFile(urlPath)
    ]);
    return true;
  }

  // Events

  putBackupReq() {
    clearTimeout(this.saveWebStateTimeoutId);
    this.saveWebStateTimeoutId = setTimeout(() => {
      this.saveWebState('B').then(() => {
        this.saveWebStateTimeoutId = undefined;
      });
    }, 1500);
    const logTag = `meowTabInfo][putBackupReq][${this.saveWebStateTimeoutId}`;
    meow('WebState >', logTag, meowLevel.WARN);
    meow(`Request for backup WebState saving in ${1500} ms.`, logTag, meowLevel.WARN);
  }

  clearBackupReq(sourceInfo: string) {
    if (this.saveWebStateTimeoutId) {
      meow(`Cleared save webstate req.`, `meowTabInfo][clearBackupReq][${sourceInfo}][${this.saveWebStateTimeoutId}`);
      clearTimeout(this.saveWebStateTimeoutId);
      this.saveWebStateTimeoutId = undefined;
    }
  }

  getUrlTitleFromController() {
    try {
      const title = this.controller?.getTitle() || '';
      const url = this.controller?.getUrl() || '';
      // Filter blank page.
      if (url.startsWith('resource://')) {
        this.url = '';
        this.title = '';
      } else {
        this.url = url;
        this.title = title;
      }
    } catch (e) {
      meow(`this.controller?.getTitle() failed: ${e}`, `meowTabInfo][getUrlTitleFromController`, meowLevel.ERROR);
    }
  }

  onPageBegin() {
    // Do things.
    this.progress = 0;
    this.endOfLoadTimestamp = Number.MAX_VALUE; // 封顶 by onPageEndLoadFinished

    // Update addressbar overlay
    this.myUi.requestShowAddressBarOverlay();

    // Web states.
    // This request here is more of a fallback / backup,
    // as some reaaally slow sites may not cause enough onProgress very quickly.
    // And in normal cases, this exact request is going to be cleared
    // by following requests triggered by onProgress and / or onPageEnd.
    if (!this.restoringWebState) {
      this.putBackupReq();
    }

    this.updateWebSettings();
  }

  /**
   * Called on both onPageEnd and onLoadFinished.
   */
  onPageEndLoadFinished() {
    this.endOfLoadTimestamp = Date.now() + 5000; // Extend a few seconds.

    // Set the fake last saved history, so that won't punch duplicated histories.
    if (this.restoringWebState) {
      this.lastSavedHistoryEntries = [new meowHistoryEntry(this.title || '', this.url || '', Date.now())];
    }

    this.getUrlTitleFromController();

    // Save history & web state
    this.tryPunchHistoryWebState(500, 'theEnd?');

    // This method would be called twice on both onPageEnd and onLoadFinished.
    // So we need a minimal timeout to delay the setting of this.restoringWebState,
    // So that both of the calls to punch history and webstate would be rejected.
    setTimeout(() => {
      this.restoringWebState = false;
    });

    this.updateWebSettings();
  }

  onTitle() {
    try {
      this.getUrlTitleFromController();

      this.syncUrlUI();

      // Save history & web state, majorly to update the title in history and the label of webstate.
      if (Date.now() < this.endOfLoadTimestamp) {
        this.tryPunchHistoryWebState(500, 'onTitle');
      }
    } catch (e) {
      meow(`this.controller?.getTitle() failed: ${e}`, `meowTabInfo][onTitle`, meowLevel.ERROR);
    }
  }

  /**
   * Fetches url and title from controller and syncs it to the UI.
   * Also calls to save web state and history.
   */
  onProgressChange() {
    try {
      let url = this.controller?.getUrl();
      if (url == this.url) {
        return;
      }

      // Update Settings
      this.updateWebSettings();

      let title = this.controller?.getTitle();
      if (this.title == title) {
        return;
      }

      // Update info
      this.getUrlTitleFromController();

      // Web settings & BrowserCat UI
      this.syncUrlUI();

    } catch (e) {
      meow(`this.url = this.controller?.getUrl(); failed: ${e}`, `meowTabInfo][onProgressChange`, meowLevel.ERROR);
    }
  }

  /**
   * Try to punch a hole in the history tape!
   * Requests the meowHistorian to save a new history after a certain period of time.
   * Also requests a saving of web state!
   * @param timeout The timeout.
   */
  tryPunchHistoryWebState(timeout: number, sourceInfo: string) {
    if (this.restoringWebState) {
      meow(`Restoring web state, skipping history & webstate punch.`, 'meowTabInfo][tryPunchHistoryWebState');
      return;
    }

    this.clearBackupReq(sourceInfo);

    // Clear timeouts.
    if (this.saveHistoryTimeoutId) {
      clearTimeout(this.saveHistoryTimeoutId);
      this.saveHistoryTimeoutId = undefined;
    }

    // Punch history.
    this.saveHistoryTimeoutId = setTimeout(() => {
      const logTag = `meowTabInfo][tryPunchHistoryWebState][${this.saveHistoryTimeoutId}`;
      let newEntry = new meowHistoryEntry(this.title || '', this.url || '', Date.now());
      const myHistory = AppStorageV2.connect(meowHistorian)!;

      // Find if duplicate
      // Traverse lastSavedHistoryEntries and see if there is duplicate urls
      const duplicateUrlEntries: meowHistoryEntry[] = []; // Duplicate URL, different TITLEs.
      let exactDuplicateTimestamp: number | undefined = undefined;
      for (const entry of this.lastSavedHistoryEntries) {
        if (entry.url == newEntry.url) {
          if (entry.title == newEntry.title) {
            exactDuplicateTimestamp = entry.time;
          } else {
            duplicateUrlEntries.push(entry);
          }
        }
      }

      // If no EXACT DUPLICATE entries, and ok to record history.
      if (exactDuplicateTimestamp == undefined && this.url && recordNewHistoryFromSettings()) {
        myHistory.pushHistory(newEntry).then(async () => {
          if (duplicateUrlEntries.length == 0) {
            // Completely NO DUPLICATE.
            // Is a completely NEW History.
            meow(`Punched History!   [${newEntry.title}](${newEntry.url})`, logTag, meowLevel.WARN);
          } else {
            // There exist some entries with duplicate URLs but different titles.
            // Update the Titles.
            await myHistory.deleteHistory(new Set(duplicateUrlEntries.map(entry => entry.time))); // TODO: find a quick way to update the old title.
            for (const entry of duplicateUrlEntries) {
              entry.title = newEntry.title;
            }
            meow(`Update title:      [${duplicateUrlEntries}] => [${newEntry.title}]`, logTag, meowLevel.WARN);
          }
          // Record in last saves.
          this.lastSavedHistoryEntries.push(newEntry);
          if (this.lastSavedHistoryEntries.length > 10) {
            this.lastSavedHistoryEntries.shift();
          }
          // Broadcast sync UI.
          globalMessage(meowAppMessageType.HISTORY_REFRESH);
        });
      } else {
        if (this.url && recordNewHistoryFromSettings()) {
          meow(`Rejected Duplicate.`, logTag);
        } else {
          meow(`Rejected empty URL or settings OFF.`, logTag);
        }
      }

      // WebState
      this.saveWebState(`${this.saveHistoryTimeoutId}`);
      this.saveHistoryTimeoutId = undefined;
    }, timeout);

    meow(`Punching: [${this.title}](${this.url}) in ${timeout} ms!`, `meowTabInfo][tryPunchHistoryWebState][${this.saveHistoryTimeoutId}][${sourceInfo}`);
  }

  /**
   * Sync the url of this tab to the address bar.
   * Also analyzes the new url and tries to shift to search keywords view (address bar) if possible.
   */
  syncUrlUI() {
    const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myUi.windowId}`)!;
    if (myTabs.currentTab != this) {
      return; // Not current tab.
    }

    // ENTER ME!

    // Update address bar
    if (!this.myUi.addressBarFocused) {
      const newUrl = this.url || '';
      if (this.myUi.addressBarContentMajor != newUrl) {
        this.myUi.setCurrentSearchContent(newUrl, true, true);
        this.myUi.tryAutoShift();
      }
    }

    // Update forward / backward
    try {
      this.canBack = this.controller?.accessBackward() || false;
      this.canForw = this.controller?.accessForward() || false;
    } catch (e) {
      meow(`this.controller?.accessBackward() / accessForward() failed: ${e}`, 'meowTabInfo][syncUrlUI', meowLevel.ERROR);
    }
  }

  /**
   * Updates the UI settings for the web.
   */
  updateWebSettings() {
    const oldForceDark = this.forceDark;
    const newForceDark = forceDark(this.url);
    if (oldForceDark != newForceDark) {
      this.forceDark = newForceDark;
      meow(`forceDark changed from [${oldForceDark}] to [${newForceDark}] for [${this.url}]!`, 'meowTabInfo][updateWebUiStatuses');
    }

    const oldDisImage = this.xImage;
    const newDisImage = disableImages(this.url);
    if (oldDisImage != newDisImage) {
      this.xImage = newDisImage;
      meow(`xImage changed from [${oldDisImage}] to [${newDisImage}] for [${this.url}]!`, 'meowTabInfo][updateWebUiStatuses');
    }

    const oldDisJS = this.xJS;
    const newDisJS = disableJS(this.url);
    if (oldDisJS != newDisJS) {
      this.xJS = newDisJS;
      meow(`xJS changed from [${oldDisJS}] to [${newDisJS}] for [${this.url}]!`, 'meowTabInfo][updateWebUiStatuses');
    }
  }

  // Operations

  refresh() {
    try {
      this.controller?.refresh();
    } catch (e) {
      meow(`this.controller?.refresh(); failed: ${e}`, 'meowTabInfo][refresh', meowLevel.ERROR);
    }
  }

  stop() {
    try {
      this.controller?.stop();
    } catch (e) {
      meow(`this.controller?.stop(); failed: ${e}`, 'meowTabInfo][stop', meowLevel.ERROR);
    }
  }

  /**
   * Go back.
   * @returns True if successful.
   */
  goBack() {
    try {
      if (this.controller?.accessBackward()) {
        this.controller?.backward();
        return true;
      }
    } catch (e) {
      meow(`this.controller?.back(); failed: ${e}`, 'meowTabInfo][goBack', meowLevel.ERROR);
    }
    return false;
  }

  goForward() {
    try {
      if (this.controller?.accessForward()) {
        this.controller?.forward();
        return true;
      }
    } catch (e) {
      meow(`this.controller?.forward(); failed: ${e}`, 'meowTabInfo][goForward', meowLevel.ERROR);
    }
    return false;
  }

  goHome() {
    try {
      if (userHomeUrl()) {
        this.controller?.loadUrl(userHomeUrl());
      } else {
        this.controller?.loadUrl('resource://rawfile/Meow.html');
      }
    } catch (e) {
      meow(`this.controller?.loadUrl(userHomeUrl()); failed: ${e}`, 'meowTabInfo][goHome', meowLevel.ERROR);
    }
  }

  /**
   * Search in page.
   */
  searchInPage() {
    try {
      this.controller?.searchAllAsync(this.inputSearchKey);
      this.isSearching = true;
      this.searchedSearchKey = this.inputSearchKey || '';
      meow(`Submit in-page search for [${this.inputSearchKey}]!`, 'meowTabInfo][searchInPage', meowLevel.INFO);
    } catch (e) {
      meow(`Failed to submit in-page search for [${this.inputSearchKey}]: ${e}`, 'meowTabInfo][searchInPage', meowLevel.ERROR);
    }
  }

  /**
   * Search last.
   */
  searchLast() {
    try {
      this.controller?.searchNext(false);
    } catch (e) {
      meow(`Failed to search last for [${this.searchedSearchKey}]: ${e}`, 'meowTabInfo][currentTabSearchLast', meowLevel.ERROR);
    }
  }

  /**
   * Search next.
   */
  searchNext() {
    try {
      this.controller?.searchNext(true);
    } catch (e) {
      meow(`Failed to search next for [${this.searchedSearchKey}]: ${e}`, 'meowTabInfo][currentTabSearchNext', meowLevel.ERROR);
    }
  }

  /**
   * Cancel current search.
   */
  searchCancel() {
    try {
      this.controller?.clearMatches();
      this.isSearching = false;
      this.inputSearchKey = '';
      this.searchedSearchKey = '';
      this.searchResultCount = 0;
      this.currentSearchResultIdx = 0;
      this.searchIsDone = true;
    } catch (e) {
      meow(`Failed to cancel for [${this.searchedSearchKey}]: ${e}`, 'meowTabInfo][currentTabSearchCancel', meowLevel.ERROR);
    }
  }

  // Web settings

  /**
   * Override tab user agent.
   * @param newUA The new user agent.
   */
  overrideTabUA(newUA: string) {
    this.overrideUA = newUA;
    try {
      this.controller?.setCustomUserAgent(newUA);
      meow(`Override tab user agent to: ${newUA}`, 'meowTabInfo][overrideTabUA');
    } catch (e) {
      meow(`Failed: ${e}`, 'meowTabInfo][overrideTabUA', meowLevel.ERROR);
    }
  }

  /**
   * Resets the tab user agent.
   */
  resetTabUA() {
    this.overrideUA = undefined;
    try {
      this.controller?.setCustomUserAgent(webview.WebviewController.getDefaultUserAgent());
      meow(`Reset tab user agent`, 'meowTabInfo][resetTabUA');
    } catch (e) {
      meow(`Failed: ${e}`, 'meowTabInfo][resetTabUA', meowLevel.ERROR);
    }
  }

  // Requests

  onControllerAttached() {
    // Ad blocker
    if (useAdBlock()) {
      try {
        this.controller!.enableAdsBlock(true);
      } catch (e) {
        meow(`Failed: ${e}`, 'meowTabInfo][onControllerAttached', meowLevel.ERROR);
      }
    }

    // Set Default error page
    try {
      this.controller!.setErrorPageEnabled(true);
    } catch (e) {
      meow(`Failed: ${e}`, 'meowTabInfo][onControllerAttached', meowLevel.ERROR);
    }

    // Set intelligent tracking prevention
    try {
      let itp = intelligentTrackingPrevention();
      this.controller!.enableIntelligentTrackingPrevention(itp);
      // meow(`ArkWeb Intelligent Tracking Prevention [${itp}]!`, 'meowTabInfo][onControllerAttached');
    } catch (e) {
      meow(`enableIntelligentTrackingPrevention error: ${e}`, 'meowTabInfo][onControllerAttached', meowLevel.ERROR);
    }

    // Set download delegate
    try {
      const delegate = getMyDawn().delegate;
      this.controller?.setDownloadDelegate(delegate);
      meow(`setDownloadDelegate for the new tab!`, 'meowTabInfo][onControllerAttached');
    } catch (e) {
      meow(`setDownloadDelegate error: ${e}`, 'meowTabInfo][onControllerAttached', meowLevel.ERROR);
    }

    // Restore if possible.
    // No effect for new tabs. Trust me :P
    this.restoreWebState().then(() => {
      if (!this.restoringWebState) {
        return; // Nothing to maintain in this case.
      }
      if (this.url == '' && !this.canBack && !this.canForw) {
        // Is Meow blank
        this.restoringWebState = false;
        meow(`Set this.restoringWebState = false; for a blank page!`, 'meowTabInfo][onControllerAttached');
      }
    });
  }

  requestLoad(event: OnLoadInterceptEvent) {
    // Intercept jumps
    let intercept = false;
    const url: string = event.data.getRequestUrl();
    const scheme = url.split(':')[0];
    if (!viewableSchemes.includes(scheme)) {
      intercept = true;
      // Ask for decision from the user to jump or not.
      meow(`Jump to [${url}]?`, 'meowTabInfo][requestload');
      const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
      requestDialog(myDialog, openDialogRequestType.JUMP, [this.url, event.data.getRequestUrl()], true);
    }
    return intercept;
  }

  requestActivateContent() {
    this.myUi.myTabs.switchTo(this);
    meow(`Activate! ${this.url}`, 'WebNode][onActivateContent');
  }

  requestExit() {
    const myTabs = this.myUi.myTabs;
    myTabs.closeTab(myTabs.tabs.indexOf(this));
    meow(`Exit! ${this.url}`, 'WebNode][onWindowExit');
  }

  requestNewTab(url: string): WebviewController | null {
    const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myUi.windowId}`)!;
    let result: WebviewController | undefined = undefined;
    animateToImmediately(defaultAnimation(), () => {
      result = myTabs.newTabBare(url).controller;
    });
    return result || null;
  }

  requestFullScreen(event: FullScreenEnterEvent) {
    this.myUi.webFullscreenHandler?.exitFullScreen(); // Exit current handler.
    this.myUi.webFullscreenHandler = event.handler;
    if (this.myUi.fullscreenStatus == meowUiFullscreenStatus.NONE) {
      this.myUi.fullscreenFull();
    }
  }

  requestFullScreenExit() {
    this.myUi.webFullscreenHandler?.exitFullScreen();
    this.myUi.webFullscreenHandler = undefined;
    this.myUi.fullscreenExit();
  }

  requestAlert(event: OnAlertEvent) {
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.ALERT, event, true);
    return true;
  }

  requestConfirm(event: OnConfirmEvent) {
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.CONFIRM, event, true);
    return true;
  }

  requestPrompt(event: OnPromptEvent) {
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.PROMPT, event, true);
    return true;
  }

  requestSslError(event: SslErrorEvent) {
    if (event) {
      const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
      requestDialog(myDialog, openDialogRequestType.SSL_ERROR, event, true);
    }
  }

  requestWebPermissions(event: OnPermissionRequestEvent) {
    // Check if some permissions are already allowed
    let needFurtherAsk = false;
    for (const prt of event.request.getAccessibleResource()) { // prt for 'Protected Resource Type'
      if (!this.allowedWebPermissions.includes(prt)) {
        needFurtherAsk = true;
      }
    }
    if (!needFurtherAsk) {
      event.request.grant(event.request.getAccessibleResource());
      meow(`Directly granted: [${event.request.getAccessibleResource().join(', ')}]`, 'meowTabInfo][requestWebPermissions', meowLevel.WARN);
      return;
    }
    // Need further ask (new, not formerly allowed permissions), request a dialog.
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.WEB_PERMISSIONS, [event, this], true);
  }

  requestScreenCapture(event: OnScreenCaptureRequestEvent) {
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.SCREEN_CAPTURE, event, true);
  }

  requestGeolocation(event: OnGeolocationShowEvent) {
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.WEB_GEOLOCATION, event, true);
  }

  /**
   * Request client (SSL) authentication.
   * Adapted from https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-basic-components-web-events#onverifypin22
   *
   * @param event The OnClientAuthenticationEvent.
   */
  requestClientAuthentication(event: OnClientAuthenticationEvent) {
    // 收到客户端证书请求事件
    meow(`onClientAuthenticationRequest!`, 'requestClientAuthentication');
    let certTypes: Array<certificateManagerDialog.CertificateType> = [
      certificateManagerDialog.CertificateType.CREDENTIAL_UKEY,
      certificateManagerDialog.CertificateType.CREDENTIAL_USER,
      certificateManagerDialog.CertificateType.CREDENTIAL_APP,
    ];
    let certPurpose: certificateManager.CertificatePurpose = certificateManager.CertificatePurpose.PURPOSE_ALL;
    // 调用证书管理，打开证书选择框
    certificateManagerDialog.openAuthorizeDialog(UIContext.getCallingScopeUIContext()?.getHostContext(), { certTypes: certTypes, certPurpose: certPurpose })
      .then((data: certificateManagerDialog.CertReference) => {
        meow(`openAuthorizeDialog request cred auth success`, 'requestClientAuthentication');
        // This is bad. HarmonyOS has multiple sets of enums to represent credential / certificate types...
        const typeMap = new Map<certificateManagerDialog.CertificateType, CredentialType>([
          [certificateManagerDialog.CertificateType.CREDENTIAL_UKEY, CredentialType.CREDENTIAL_UKEY],
          [certificateManagerDialog.CertificateType.CREDENTIAL_USER, CredentialType.CREDENTIAL_USER],
          [certificateManagerDialog.CertificateType.CREDENTIAL_APP, CredentialType.CREDENTIAL_APP],
        ]);
        const type = typeMap.get(data.certType) ?? CredentialType.CREDENTIAL_UKEY;
        try {
          event.handler.confirm(data.keyUri, type);
        } catch (e) {
          meow(`event.handler.confirm(data.keyUri, ${type}); failed, err: ${JSON.stringify(e)}`, 'requestClientAuthentication', meowLevel.ERROR);
        }
      }).catch((err: BusinessError) => {
        // Note that if no certificate is available on the device, this would throw ↓ and this is normal. Just install a certificate and the dialog would show.
        // 29700001: Internal error. Possible causes: 1. IPC communication failed; 2. Memory operation error; 3. File operation error.
        meow(`openAuthorizeDialog request cred auth failed, err: ${JSON.stringify(err)}`, 'requestClientAuthentication', meowLevel.ERROR);
      });
  }

  /**
   * Request PIN verification.
   * Adapted from https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-basic-components-web-events#onverifypin22
   *
   * @param event The VerifyPinEvent.
   */
  requestVerifyPin(event: VerifyPinEvent) {
    // 收到PIN码认证请求事件
    meow(`onVerifyPin`, 'requestVerifyPin');
    // 调用证书管理，打开PIN码输入框
    certificateManagerDialog.openUkeyAuthDialog(UIContext.getCallingScopeUIContext()?.getHostContext(), { keyUri: event.identity })
      .then(() => {
        // 通知webPIN码认证成功
        meow(`onVerifyPin success`, 'requestVerifyPin');
        event.handler.confirm(PinVerifyResult.PIN_VERIFICATION_SUCCESS);
      }).catch((err: BusinessError) => {
        // 通知webPIN码认证失败
        meow(`onVerifyPin fail ${err}`, 'requestVerifyPin', meowLevel.ERROR);
        event.handler.confirm(PinVerifyResult.PIN_VERIFICATION_FAILED);
      });
  }

  requestHttpAuth(event: OnHttpAuthRequestEvent) {
    if (event.handler.isHttpAuthInfoSaved()) {
      meow(`HttpAuthInfo saved, skip`, 'requestHttpAuth', meowLevel.WARN);
      return;
    }
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.HTTP_AUTH, event, true);
  }

  receiveSearchResult(result: OnSearchResultReceiveEvent) {
    this.currentSearchResultIdx = result.activeMatchOrdinal;
    this.searchResultCount = result.numberOfMatches;
    this.searchIsDone = result.isDoneCounting;
  }
}
