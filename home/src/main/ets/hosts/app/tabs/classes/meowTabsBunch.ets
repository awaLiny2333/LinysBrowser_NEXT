import lazy { unifiedDataChannel } from "@kit.ArkData";
import lazy { fastbuffer } from "@kit.ArkTS";
import lazy { AppStorageV2 } from "@kit.ArkUI";
import lazy { webview } from "@kit.ArkWeb";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { listFilesUnderDir, readArrayBuffer, saveHybrid } from "../../../../catstypicalframework/utils/storage";
import lazy { archiveWeb, printWeb } from "../../../../catstypicalframework/utils/web";
import lazy { defaultAnimation } from "../../../../components/settings";
import { meowUiHost } from "../../../system/windows/classes/meowUiHost";
import lazy { getCreateMyApp } from "../../../system/windows/scripts/helpers";
import lazy { getAllWindowIds } from "../../../system/windows/scripts/multiwindows";
import { applyAdBlockerExceptions } from "../scripts/adBlocker";
import { applyThirdPartyCookies } from "../scripts/cookies";
import lazy { applyUserAgentFromSettings, applyUserAgentRulesFromSettings } from "../scripts/userAgents";
import { meowTabInfo } from "./meowTabInfo";
import lazy { TabNodeController } from "./WebNode";

/**
 * The Unified Type name of meowTabInfo items.
 * This is used to verify the dropped items to the window.
 */
export const meowTabInfoUnifiedType = 'ApplicationDefined.meowTabInfo.flag';

@ObservedV2
export class meowTabsBunch {
  uiContext: UIContext;
  myUi: meowUiHost;
  static initialized: boolean = false;
  @Trace tabs: meowTabInfo[] = [];
  @Trace currentTab: meowTabInfo | undefined = undefined;

  constructor(uiContext: UIContext, myUi: meowUiHost) {
    this.uiContext = uiContext;
    this.myUi = myUi;
  }

  static async init() {
    const startTime = Date.now();
    // User agent
    applyUserAgentFromSettings();
    applyUserAgentRulesFromSettings();
    // Cookies
    applyThirdPartyCookies();
    // Ad blocks
    applyAdBlockerExceptions();
    // await applyEasyListFromDisk();
    "设置的自定义规则文件在应用进程内对所有的Web组件生效，是一个应用级全局配置文件，并将持久化，应用重启后可继续工作。";
    // Finish
    meowTabsBunch.initialized = true;
    meow(`Initialized in ${Date.now() - startTime} ms`, 'meowTabsBunch][init', meowLevel.WARN);
  }

  /**
   * Called to destroy this tabsBunch. Usually used when the window is closed.
   * Calls the tabs in this bunch to destroy themselves.
   */
  requestDestroy() {
    for (const element of this.tabs) {
      element.requestDestroyNode();
    }
    try {
      webview.WebviewController.trimMemoryByPressureLevel(webview.PressureLevel.MEMORY_PRESSURE_LEVEL_CRITICAL);
    } catch (e) {
      meow(`webview.WebviewController.trimMemoryByPressureLevel(webview.PressureLevel.MEMORY_PRESSURE_LEVEL_CRITICAL); failed: ${e}`, 'meowTabsBunch][requestDestroy', meowLevel.ERROR);
    }
  }

  // WEBSTATES

  get workingDir() {
    return this.myUi.workingDir;
  }

  async loadAllStatesFromDir(dir: string) {
    const startTime = Date.now();
    if (!meowTabsBunch.initialized) {
      await meowTabsBunch.init();
    }
    meow(`About to load all webstates from [${dir}] to [${this.myUi.windowId}]! (${Date.now() - startTime} ms)`, 'meowTabsBunch][loadAllStatesFromDir', meowLevel.WARN);

    // Read tabs
    const tabs2bAdded: meowTabInfo[] = [];
    const files = await listFilesUnderDir(dir) || [];
    const baseFiles = files.filter(name => (name[name.length - 1] !== 'l' && name != 'stat'));
    baseFiles.sort((a, b) => a.localeCompare(b));

    // Use parallel promises to accelerate.
    const readPromises = baseFiles.map(async (stateName) => {
      const newTab = new meowTabInfo(this.myUi);
      newTab.restoringWebState = true; // Mark the tab to be restored / restorable?
      newTab.webStateId = stateName;
      const labelPath = `${this.workingDir}/${stateName}_label`;

      try {
        const label = fastbuffer.from(await readArrayBuffer(labelPath)).toString();
        newTab.title = label;
        meow(`Read label: [${label}] from [${labelPath}]`, 'meowTabsBunch][loadAllStatesFromDir');
      } catch (e) {
        meow(`Read label failed: ${e}`, 'meowTabsBunch][loadAllStatesFromDir', meowLevel.ERROR);
      }
      return newTab;
    });
    tabs2bAdded.push(...await Promise.all(readPromises));

    // Read stat
    const statPath = `${this.workingDir}/stat`;
    let switchTargetIdx = 0;
    try {
      const stat = fastbuffer.from(await readArrayBuffer(statPath)).toString();
      if (stat) {
        const statParts = stat.split(' ');
        if (statParts.length > 0) {
          switchTargetIdx = Number.parseInt(statParts[0]);
          meow(`Switching to tab ${switchTargetIdx} based on stat file`, 'meowTabsBunch][loadAllStatesFromDir', meowLevel.WARN);
        }
      }
    } catch (e) {
      meow(`Read stat failed: ${e}`, 'meowTabsBunch][loadAllStatesFromDir', meowLevel.ERROR);
    }

    if (baseFiles.length <= 0) {
      // Nothing works
      return;
    }

    // Push and switch
    // We need a setTimeout to make animation work.
    await new Promise<void>((resolve) => {
      setTimeout(() => {
        animateToImmediately(defaultAnimation(), () => {
          this.tabs.push(...tabs2bAdded);
          this.switchTo(switchTargetIdx);
        });
        meow(`Loaded all webstates in ${Date.now() - startTime} ms`, 'meowTabsBunch][loadAllStatesFromDir', meowLevel.WARN);
        resolve();
      });
    });
  }

  /**
   * Saves the stat of this bunch to the disk.
   * Works together with the web state system.
   */
  async updateSaveStat() {
    let stat = '0';
    if (!this.currentTab) {
      meow(`No current tab`, 'meowTabsBunch][updateStat', meowLevel.WARN);
    } else {
      stat = `${this.tabs.indexOf(this.currentTab)}`;
    }
    const statPath = `${this.workingDir}/stat`;
    await saveHybrid(statPath, stat, true);
  }

  /**
   * Requests a tab to sleep.
   * @param index The index of the tab to sleep.
   */
  async requestSleep(index: number) {
    await this.tabs[index].requestSleep();
    // Set UI correctly if closing the current-viewing tab.
    if (this.tabs[index] == this.currentTab) {
      setTimeout(() => {
        animateToImmediately(defaultAnimation(), () => {
          this.currentTab = undefined; // Leave current tab.
          this.myUi.setAddressBarContent('', true, true); // Update address bar.
        });
      }); // Use timeout to protect animation.
    }
  }

  // DRAG & DROP

  /**
   * Drops a tab into the dedicated MyApp tunnel
   * And packs a unifiedData.
   *
   * @param tab The meowTabInfo.
   * @returns unifiedData with applicationDefinedType of meowTabInfoUnifiedType.
   */
  dropTabIntoMyAppTunnel(tab: meowTabInfo) {
    getCreateMyApp().dataTunnelForTabs = tab;

    // Fill data :P
    let unifiedData = new unifiedDataChannel.UnifiedData();

    // Application defined item record
    let r = new unifiedDataChannel.ApplicationDefinedRecord();
    r.applicationDefinedType = meowTabInfoUnifiedType;
    unifiedData.addRecord(r);

    return unifiedData;
  }

  /**
   * Receives a tabInfo from the dedicated MyApp tunnel
   * and moves it from its original window to here.
   */
  receiveTabFromMyAppTunnel() {
    const tabInfo = getCreateMyApp().dataTunnelForTabs;
    if (!tabInfo) {
      meow(`No tab info`, 'meowTabsBunch][receiveTabFromMyAppTunnel', meowLevel.WARN);
      return;
    }

    meow(`Received tab info from MyApp tunnel`, 'meowTabsBunch][receiveTabFromMyAppTunnel', meowLevel.WARN);

    // Process
    const sourceTabs = tabInfo.myUi.myTabs;

    // Off-duty handover
    tabInfo.aboutToBeReceived();
    tabInfo.myUi = this.myUi;
    tabInfo.refreshWebStateId();

    sourceTabs.tabs.splice(sourceTabs.tabs.indexOf(tabInfo), 1);
    this.tabs.push(tabInfo);

    this.switchTo(tabInfo);
    tabInfo.saveWebState('move');
    tabInfo.wsBackupReqTmId = undefined;

    // UI
    animateToImmediately(defaultAnimation(), () => {
      this.myUi.dropHover = false;
    });
  }

  /**
   * Called when the tab is dropped to elsewhere.
   * In the .onDropEnd() events from Tabs panels from where tabs are dragged away.
   */
  sendFinish() {
    // Clear tunnel.
    getCreateMyApp().dataTunnelForTabs = undefined;
    meow(`getCreateMyApp().dataTunnelForTabs = undefined`, 'meowTabInfo][didDrop', meowLevel.WARN);
    // Clear hover state of all app windows.
    for (const wId of getAllWindowIds()) {
      const thatUi = AppStorageV2.connect(meowUiHost, `meowUiHost_${wId}`);
      if (thatUi) {
        thatUi.dropHover = false;
      }
    }
    // If I sent the tab currently viewing, then switch to another tab.
    if (this.currentTab == undefined) {
      this.switchTo(0);
    }
    this.updateSaveStat();
  }

  // ACTIONS

  /**
   * Ensures there is at least one tab.
   * @returns True if a new tab was created, false if nothing done.
   */
  private ensureTheresOneTab(overwriteUrl?: string) {
    if (this.tabs.length == 0) {
      this.newTabWrapped(overwriteUrl);
      this.switchTo(0);
      return true;
    }
    return false;
  }

  /**
   * Loads an url on current tab.
   * @param url
   */
  loadOnCurrentTab(url: string) {
    const hasCreated = this.ensureTheresOneTab(url);
    if (hasCreated) {
      // Do nothing
    } else {
      try {
        if (this.currentTab?.controller) {
          this.currentTab.restoringWebState = false;
          this.currentTab.controller.loadUrl(url);
        }
      } catch (e) {
        meow(`failed: ${e}`, 'meowTabsBunch][loadOnCurrentTab', meowLevel.ERROR);
      }
    }
  }

  /**
   * Create a new tab, do the initialization if found not init.
   * @param overwriteUrl A specific url to use?
   * @returns The new meowTabInfo.
   */
  async newTabWrapped(overwriteUrl?: string): Promise<meowTabInfo> {
    if (!meowTabsBunch.initialized) {
      await meowTabsBunch.init();
    }
    return this.newTabBare(overwriteUrl);
  }

  /**
   * Create a new tab, doesn't check initialization.
   * @param overwriteUrl A specific url to use?
   * @param controller A pre-created controller to use?
   * @returns The new meowTabInfo.
   */
  newTabBare(overwriteUrl?: string, controller?: WebviewController, delaySwitch: boolean = false) {
    const newTab = new meowTabInfo(this.myUi);
    newTab.controller = controller || new webview.WebviewController();
    if (overwriteUrl) {
      newTab.url = overwriteUrl;
    }
    const newNode = new TabNodeController(this.uiContext, newTab);
    newTab.node = newNode;
    this.tabs.push(newTab);
    if (newTab.url == '') {
      // meow(`New tab created with empty url. Calling requestWebStateUpdate!`, 'meowTabsBunch][newTabBare', meowLevel.WARN);
      newTab.saveWebState('newEmptyTab');
    }

    // Show
    if (delaySwitch) {
      setTimeout(() => {
        this.switchTo(this.tabs.length - 1);
      }, 200); // TODO: We have to wait a while before the original web finishes processing something... THIS IS NOT ELEGANT
    } else {
      this.switchTo(this.tabs.length - 1);
    }

    // Return the meowTabInfo.
    return newTab;
  }

  /**
   * Close a tab.
   * @param idx The tab index.
   */
  closeTab(idx: number) {
    const closedTab = this.tabs[idx];
    if (!closedTab?.node) {
      meow(`closedTab?.node is undefined`, 'meowTabsBunch][closeTab', meowLevel.WARN);
    }

    this.tabs.splice(idx, 1);

    // Delete web state
    closedTab.onClose();

    if (closedTab == this.currentTab) {
      this.switchTo(this.tabs.length - 1);
    } else {
      this.updateSaveStat();
    }

    if (this.tabs.length == 0) {
      // No node, indicating that all tabs are closed.
      // Clear the url field
      if (!this.myUi.addressBarFocused) {
        this.myUi.setAddressBarContent('', true, true);
      }
    }

    // Request trim memory.
    try {
      webview.WebviewController.trimMemoryByPressureLevel(webview.PressureLevel.MEMORY_PRESSURE_LEVEL_CRITICAL);
    } catch (e) {
      meow(`webview.WebviewController.trimMemoryByPressureLevel(webview.PressureLevel.MEMORY_PRESSURE_LEVEL_CRITICAL); failed: ${e}`, 'meowTabsBunch][requestDestroy', meowLevel.ERROR);
    }
  }

  closeCurrent() {
    if (this.currentTab) {
      this.closeTab(this.tabs.indexOf(this.currentTab));
    }
  }

  /**
   * Switch to a tab. Auto calls the tab to restore web state if it is not active.
   * @param target The tab index or the meowTabInfo itself.
   */
  async switchTo(target: number | meowTabInfo) {
    if (this.currentNode) {
      this.currentNode.detachWeb();
      this.currentNode.rebuild();
    }
    if (typeof target == 'number') {
      this.currentTab = this.tabs[Math.min(target, this.tabs.length - 1)];
    } else {
      this.currentTab = target;
    }

    if (!this.currentTab.controller) {
      this.currentTab.controller = new webview.WebviewController();
    }
    // Auto create web node
    if (!this.currentTab.node) {
      const newNode = new TabNodeController(this.myUi.myTabs.uiContext, this.currentTab);
      this.currentTab.node = newNode;
    }

    // Update UA
    this.currentTab.updateSlimUA();

    // Check and attach
    if (this.currentNode) {
      this.currentNode.attachWeb();
      this.currentNode.rebuild();
      // Show search in page bar
      if (this.currentTab.isSearching && !this.myUi.inPageSearchShow) {
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.inPageSearchShow = true;
        });
      }
      // Update addressbar overlay
      this.myUi.requestShowAddressBarOverlay();
      this.updateSaveStat();
      this.currentTab.syncUrlUI();
      return;
    }

    // Save stat
    this.updateSaveStat();
  }

  /**
   * Refresh the current tab.
   */
  refreshCurrent() {
    if (this.currentTab && !this.currentTab.isLoading) {
      this.currentTab.refresh();
    }
  }

  /**
   * Stop the current tab.
   */
  stopCurrent() {
    if (this.currentTab && this.currentTab.isLoading) {
      this.currentTab.stop();
    }
  }

  /**
   * Refresh or stop the current tab.
   */
  refreshStopCurrent() {
    if (this.currentTab == undefined) {
      meow(`refreshStopCurrent: currentTab is undefined`, 'meowTabsBunch][refreshStopCurrent', meowLevel.ERROR);
      return;
    }
    if (this.currentTab.isLoading) {
      this.currentTab.stop();
    } else {
      this.currentTab.refresh();
    }
  }

  goBackCurrent(): boolean {
    if (this.currentTab) {
      return this.currentTab.goBack();
    }
    return false;
  }

  goForwardCurrent(): boolean {
    if (this.currentTab) {
      return this.currentTab.goForward();
    }
    return false;
  }

  goHomeCurrent() {
    if (this.currentTab) {
      this.currentTab.goHome();
    }
  }

  printCurrent() {
    printWeb(this.currentTab?.controller);
  }

  saveCurrent() {
    archiveWeb(this.currentTab?.controller);
  }

  zoomInCurrent() {
    if (this.currentTab && this.currentTab.webScale < 1000) {
      this.currentTab.webScale += 10;
      // this.currentTab.zoomByJs(this.currentTab.webScale);
    }
  }

  zoomOutCurrent() {
    if (this.currentTab && this.currentTab.webScale > 10) {
      this.currentTab.webScale -= 10;
      // this.currentTab.zoomByJs(this.currentTab.webScale);
    }
  }

  // GETTERS

  /**
   * Gets if any of the tabs are doing a webstate saving or history punching.
   */
  get isBusy() {
    let busy = false;
    for (const tab of this.tabs) {
      if (tab.wsBackupReqTmId != undefined || tab.saveHistoryTimeoutId != undefined) {
        busy = true;
        break;
      }
    }
    return busy;
  }

  get currentNode() {
    if (this.currentTab) {
      return this.currentTab.node;
    } else {
      return undefined;
    }
  }

  get currentTabCanBack() {
    return this.currentTab?.canBack;
  }

  get currentTabCanForw() {
    return this.currentTab?.canForw;
  }

  /**
   * Gets the current tab search total result count.
   */
  get currentTabSearchResultCount() {
    return this.currentTab?.searchResultCount;
  }

  /**
   * Gets the current search result index.
   */
  get currentTabSearchIdx() {
    return this.currentTab?.currentSearchResultIdx;
  }

  /**
   * Gets the current tab search is done.
   */
  get currentTabSearchIsDone() {
    return this.currentTab?.searchIsDone;
  }

  /**
   * Gets the current tab search is in search mode.
   */
  get currentTabSearchIsSearching() {
    return this.currentTab?.isSearching;
  }

  /**
   * Gets the current tab search key in the input field.
   */
  get currentTabSearchInputKey() {
    return this.currentTab?.inputSearchKey;
  }

  /**
   * Gets the current tab search key that is searched last time.
   */
  get currentTabSearchSearchedKey() {
    return this.currentTab?.searchedSearchKey;
  }

  // IN-PAGE SEARCH

  /**
   * Sets the current tab search key.
   */
  currentTabSearchSetKey(searchKey: string) {
    if (this.currentTab) {
      this.currentTab.inputSearchKey = searchKey;
    } else {
      meow(`No current tab found!`, 'meowTabBunch][setCurrentTabSearchKey', meowLevel.WARN);
    }
  }

  /**
   * Submits the search on current tab.
   */
  currentTabSearchSubmit() {
    if (!this.currentTab) {
      meow(`No current tab found!`, 'meowTabBunch][submitCurrentTabSearchKey', meowLevel.WARN);
      return;
    }
    this.currentTab.searchInPage();
  }

  /**
   * Go to last search result on current tab.
   */
  currentTabSearchLast() {
    if (!this.currentTab) {
      meow(`No current tab found!`, 'meowTabBunch][currentTabSearchLast', meowLevel.WARN);
      return;
    }
    this.currentTab.searchLast();
  }

  /**
   * Go to next search result on current tab.
   */
  currentTabSearchNext() {
    if (!this.currentTab) {
      meow(`No current tab found!`, 'meowTabBunch][currentTabSearchNext', meowLevel.WARN);
      return;
    }
    this.currentTab.searchNext();
  }

  /**
   * Cancel search on current tab.
   */
  currentTabSearchCancel() {
    if (!this.currentTab) {
      meow(`No current tab found!`, 'meowTabBunch][currentTabSearchCancel', meowLevel.WARN);
      return;
    }
    this.currentTab.searchCancel();
  }
}
