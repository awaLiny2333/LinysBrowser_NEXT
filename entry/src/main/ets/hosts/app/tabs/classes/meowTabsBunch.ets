import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { meowUiHost } from "../../../system/windows/classes/meowUiHost";
import lazy { applyEasyListFromDisk } from "../scripts/adBlocker";
import { applyUserAgentFromSettings } from "../scripts/userAgents";
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
    // try {
    //   webview.AdsBlockManager.addAdsBlockDisallowedList(Array.from(adBlockExceptions()));
    // } catch (e) {
    //   meow(`webview.AdsBlockManager.addAdsBlockDisallowedList(adBlockExceptions()); failed: ${e}`, 'meowTabsBunch][newTab', meowLevel.ERROR);
    // }
    // await this.applyEasyListFromDisk();
    this.initialized = true;
  }

  async applyEasyListFromDisk() {
    await applyEasyListFromDisk(this.uiContext.getHostContext()!.filesDir, this.uiContext.getHostContext()!.tempDir);
  }

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
      this.currentTab.syncUrl();
      this.currentTab.requestUiUpdate();
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
    if (this.currentTab) {
      this.currentTab.refresh();
    }
  }

  goBackCurrent() {
    if (this.currentTab) {
      this.currentTab.goBack();
    }
  }

  goForwardCurrent() {
    if (this.currentTab) {
      this.currentTab.goForward();
    }
  }

  goHomeCurrent() {
    if (this.currentTab) {
      this.currentTab.goHome();
    }
  }
}
