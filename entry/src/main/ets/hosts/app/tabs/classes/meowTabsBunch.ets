import lazy { fastbuffer } from "@kit.ArkTS";
import lazy { webview } from "@kit.ArkWeb";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { listFilesUnderDir, readArrayBuffer, saveHybrid } from "../../../../catstypicalframework/utils/storage";
import lazy { archiveWeb, printWeb } from "../../../../catstypicalframework/utils/web";
import lazy { defaultAnimation } from "../../../../components/settings";
import { meowUiHost } from "../../../system/windows/classes/meowUiHost";
import lazy { applyUserAgentFromSettings } from "../scripts/userAgents";
import lazy { thirdPartyCookies } from "../settings";
import { meowTabInfo } from "./meowTabInfo";
import lazy { TabNodeController } from "./WebNode";

@ObservedV2
export class meowTabsBunch {
  uiContext: UIContext;
  myUi: meowUiHost;
  initialized: boolean = false;
  @Trace tabs: meowTabInfo[] = [];
  @Trace currentTab: meowTabInfo | undefined = undefined;

  constructor(uiContext: UIContext, myUi: meowUiHost) {
    this.uiContext = uiContext;
    this.myUi = myUi;
  }

  async init() {
    const startTime = Date.now();
    applyUserAgentFromSettings();
    webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(thirdPartyCookies());
    // try {
    //   webview.AdsBlockManager.addAdsBlockDisallowedList(Array.from(adBlockExceptions()));
    // } catch (e) {
    //   meow(`webview.AdsBlockManager.addAdsBlockDisallowedList(adBlockExceptions()); failed: ${e}`, 'meowTabsBunch][newTab', meowLevel.ERROR);
    // }
    // await this.applyEasyListFromDisk();
    this.initialized = true;
    meow(`Initialized in ${Date.now() - startTime} ms`, 'meowTabsBunch][init', meowLevel.WARN);
  }

  // async applyEasyListFromDisk() {
  //   await applyEasyListFromDisk(this.uiContext.getHostContext()!.filesDir, this.uiContext.getHostContext()!.tempDir);
  // }

  // WEB STATES

  get workingDir() {
    return this.myUi.workingDir;
  }

  async loadAllStatesFromDir(dir: string) {
    const startTime = Date.now();
    if (!this.initialized) {
      await this.init();
    }
    meow(`About to load all web states from [${dir}] to [${this.myUi.windowId}]!`, 'meowTabsBunch][loadAllStatesFromDir', meowLevel.WARN);

    // Read tabs
    const tabs2bAdded: meowTabInfo[] = [];
    const files = await listFilesUnderDir(dir) || [];
    const baseFiles = files.filter(name => (name[name.length - 1] !== 'l' && name != 'stat'));
    baseFiles.sort((a, b) => a.localeCompare(b));
    for (const stateName of baseFiles) {
      const newTab = new meowTabInfo(this.myUi);
      newTab.restoringWebState = true;
      newTab.webStateId = stateName;
      const labelPath = `${this.workingDir}/${stateName}_label`;
      try {
        const label = fastbuffer.from(await readArrayBuffer(labelPath)).toString();
        newTab.title = label;
        meow(`Read label: [${label}] from [${labelPath}]`, 'meowTabsBunch][loadAllStatesFromDir', meowLevel.WARN);
      } catch (e) {
        meow(`Read label failed: ${e}`, 'meowTabsBunch][loadAllStatesFromDir', meowLevel.ERROR);
      }
      tabs2bAdded.push(newTab);
    }

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

    // Push and switch
    if (baseFiles.length > 0) {
      setTimeout(() => {
        animateToImmediately(defaultAnimation(), () => {
          // Push all tabs2bAdded
          this.tabs.push(...tabs2bAdded);
          this.switchTo(switchTargetIdx);
        });
      });
    }

    meow(`Loaded all web states in ${Date.now() - startTime} ms`, 'meowTabsBunch][loadAllStatesFromDir', meowLevel.WARN);
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
    if (!this.initialized) {
      await this.init();
    }
    return this.newTabBare(overwriteUrl);
  }

  /**
   * Create a new tab, doesn't check initialization.
   * @param overwriteUrl A specific url to use?
   * @returns The new meowTabInfo.
   */
  newTabBare(overwriteUrl?: string) {
    const newTab = new meowTabInfo(this.myUi);
    newTab.controller = new webview.WebviewController();
    if (overwriteUrl) {
      newTab.url = overwriteUrl;
    }
    const newNode = new TabNodeController(this.uiContext, newTab);
    newTab.node = newNode;
    this.tabs.push(newTab);
    this.switchTo(this.tabs.length - 1);
    if (newTab.url == '') {
      meow(`New tab created with empty url. Calling requestWebStateUpdate!`, 'meowTabsBunch][newTabBare', meowLevel.WARN);
      newTab.requestWebStateUpdate(10);
    }
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
    closedTab.callClose();

    if (closedTab == this.currentTab) {
      this.switchTo(this.tabs.length - 1);
    } else {
      this.updateSaveStat();
    }

    if (this.tabs.length == 0) {
      // No node, indicating that all tabs are closed.
      // Clear the url field
      if (!this.myUi.addressBarFocused) {
        this.myUi.setCurrentSearchContent('', true, true);
      }
    }
  }

  closeCurrent() {
    if (this.currentTab) {
      this.closeTab(this.tabs.indexOf(this.currentTab));
    }
  }

  /**
   * Switch to a tab. Auto calls the tab to restore web state if it is not active.
   * @param idx The tab index.
   */
  async switchTo(idx: number) {
    if (this.currentNode) {
      this.currentNode.detachWeb();
      this.currentNode.rebuild();
    }
    this.currentTab = this.tabs[Math.min(idx, this.tabs.length - 1)];

    if (!this.currentTab.controller) {
      this.currentTab.controller = new webview.WebviewController();
    }
    // Auto create web node
    if (!this.currentTab.node) {
      const newNode = new TabNodeController(this.myUi.myTabs.uiContext, this.currentTab);
      this.currentTab.node = newNode;
    }

    // Check and attach
    if (this.currentNode) {
      this.currentNode.attachWeb();
      this.currentNode.rebuild();
      this.currentTab.syncUrlUI();
      // Show search in page bar
      if (this.currentTab.isSearching && !this.myUi.inPageSearchShow) {
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.inPageSearchShow = true;
        });
      }
      // Update addressbar overlay
      this.myUi.requestShowAddressBarOverlay();
      this.updateSaveStat();
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
    if (!this.currentTab) {
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

  // GETTERS

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
