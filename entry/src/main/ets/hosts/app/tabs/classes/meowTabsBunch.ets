import lazy { webview } from "@kit.ArkWeb";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { defaultAnimation } from "../../../../components/settings";
import { meowUiHost } from "../../../system/windows/classes/meowUiHost";
import { applyUserAgentFromSettings } from "../scripts/userAgents";
import { thirdPartyCookies } from "../settings";
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

  get currentNode() {
    if (this.currentTab) {
      return this.currentTab.node;
    } else {
      return undefined;
    }
  }

  async init() {
    applyUserAgentFromSettings();
    webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(thirdPartyCookies());
    // try {
    //   webview.AdsBlockManager.addAdsBlockDisallowedList(Array.from(adBlockExceptions()));
    // } catch (e) {
    //   meow(`webview.AdsBlockManager.addAdsBlockDisallowedList(adBlockExceptions()); failed: ${e}`, 'meowTabsBunch][newTab', meowLevel.ERROR);
    // }
    // await this.applyEasyListFromDisk();
    this.initialized = true;
  }

  // async applyEasyListFromDisk() {
  //   await applyEasyListFromDisk(this.uiContext.getHostContext()!.filesDir, this.uiContext.getHostContext()!.tempDir);
  // }s

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
    if (overwriteUrl) {
      newTab.url = overwriteUrl;
    }
    const newNode = new TabNodeController(this.uiContext, newTab);
    newTab.node = newNode;
    this.tabs.push(newTab);
    this.switchTo(this.tabs.length - 1);
    return newTab;
  }

  /**
   * Close a tab.
   * @param idx The tab index.
   */
  closeTab(idx: number) {
    const closedTab = this.tabs[idx];

    this.tabs.splice(idx, 1);

    closedTab.node!.detachWeb();
    closedTab.node!.dispose();

    if (closedTab == this.currentTab) {
      this.switchTo(this.tabs.length - 1);
    }
  }

  closeCurrent() {
    if (this.currentTab) {
      this.closeTab(this.tabs.indexOf(this.currentTab));
    }
  }

  /**
   * Switch to a tab.
   * @param idx The tab index.
   */
  switchTo(idx: number) {
    if (this.currentNode) {
      this.currentNode.detachWeb();
      this.currentNode.rebuild();
    }
    this.currentTab = this.tabs[idx];
    if (this.currentNode) {
      this.currentNode.attachWeb();
      this.currentNode.rebuild();
      this.currentTab.syncUrlUI();
      this.currentTab.requestUiUpdate();
      // Show search in page bar
      if (this.currentTab.isSearching && !this.myUi.inPageSearchShow) {
        animateToImmediately(defaultAnimation(), () => {
          this.myUi.inPageSearchShow = true;
        });
      }
    } else {
      // Clear the url field
      if (!this.myUi.addressBarFocused) {
        this.myUi.setCurrentSearchContent('', true, true);
      }
    }
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

  // GETTERS

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
