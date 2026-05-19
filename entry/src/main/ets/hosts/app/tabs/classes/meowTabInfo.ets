import { AppStorageV2 } from "@kit.ArkUI";
import { webview } from "@kit.ArkWeb";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { belongsToDomain } from "../../../../catstypicalframework/utils/url";
import { defaultAnimation } from "../../../../components/settings";
import { meowDialogManager, openDialogRequestType } from "../../../system/dialogs/classes/meowDialogManager";
import { requestDialog } from "../../../system/dialogs/scripts/dialog";
import { meowUiFullscreenStatus, meowUiHost } from "../../../system/windows/classes/meowUiHost";
import { defaultBlankUrl, viewableSchemes } from "../scripts/helpers";
import { disableWebImages, disableWebImagesOnAllSites, disableWebImagesSites, disableWebJavaScripts, disableWebJavaScriptSites, disableWebJavaScriptsOnAllSites, forceWebDarkExceptions, forceWebDarkMode, userHomeUrl, userNewTabUrl } from "../settings";
import { meowTabsBunch } from "./meowTabsBunch";
import { TabNodeController } from "./WebNode";

@ObservedV2
export class meowTabInfo {
  @Trace myUi: meowUiHost; // NOTE: Should be updated once this tab is sent to other window!
  @Trace controller: WebviewController | undefined;
  @Trace node: TabNodeController | undefined;
  // UI info
  @Trace title: string | undefined;
  @Trace url: string | undefined = userNewTabUrl();
  @Trace progress: number = -1; // -1 for not loading, other positive values from 0 ~ 100 is the progress for loading.
  // Web settings
  @Trace forceDark: boolean = true;
  @Trace xJS: boolean = false;
  @Trace xImage: boolean = false;

  constructor(myUi: meowUiHost) {
    this.myUi = myUi;
    this.controller = new webview.WebviewController();
  }

  // UI

  /**
   * Fetches url from controller and syncs it to the UI.
   */
  updateUrl() {
    try {
      let url = this.controller?.getUrl();
      if (url == defaultBlankUrl) {
        url = '';
      }
      this.url = url;
      this.syncUrl();

      // Web statuses
      this.updateWebUiStatuses();
    } catch (e) {
      meow(`this.url = this.controller?.getUrl(); failed: ${e}`, 'meowTabInfo][updateUrl', meowLevel.ERROR);
    }
  }

  /**
   * Sync the url of this tab to the address bar.
   */
  syncUrl() {
    const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myUi.windowId}`)!;
    if (myTabs.currentTab == this && !this.myUi.addressBarFocused) {
      const newUrl = this.url || '';
      if (this.myUi.addressBarContentMajor != newUrl) {
        this.myUi.setCurrentSearchContent(newUrl, true, true);
      }
    }
  }

  /**
   * Fetches title from controller.
   */
  updateTitle() {
    try {
      let title = this.controller?.getTitle();
      let url = this.controller?.getUrl();
      if (url == defaultBlankUrl) {
        title = '';
      }
      this.title = title;
    } catch (e) {
      meow(`this.title = this.controller?.getTitle(); failed: ${e}`, 'meowTabInfo][updateTitle', meowLevel.ERROR);
    }
  }

  updateWebUiStatuses() {
    const oldForceDark = this.forceDark;
    const newForceDark = this.forceDarkMe();
    if (oldForceDark != newForceDark) {
      this.forceDark = newForceDark;
      meow(`forceDark changed from [${oldForceDark}] to [${newForceDark}] for [${this.url}]!`, 'meowTabInfo][updateWebUiStatuses');
    }

    const oldDisImage = this.xImage;
    const newDisImage = this.disableImagesMe();
    if (oldDisImage != newDisImage) {
      this.xImage = newDisImage;
      meow(`xImage changed from [${oldDisImage}] to [${newDisImage}] for [${this.url}]!`, 'meowTabInfo][updateWebUiStatuses');
    }

    const oldDisJS = this.xJS;
    const newDisJS = this.disableJSMe();
    if (oldDisJS != newDisJS) {
      this.xJS = newDisJS;
      meow(`xJS changed from [${oldDisJS}] to [${newDisJS}] for [${this.url}]!`, 'meowTabInfo][updateWebUiStatuses');
    }

    this.node?.update(this);
  }

  // Operations

  refresh() {
    try {
      this.controller?.refresh();
    } catch (e) {
      meow(`this.controller?.refresh(); failed: ${e}`, 'meowTabInfo][refresh', meowLevel.ERROR);
    }
  }

  goBack() {
    try {
      if (this.controller?.accessBackward()) {
        this.controller?.backward();
      }
    } catch (e) {
      meow(`this.controller?.back(); failed: ${e}`, 'meowTabInfo][goBack', meowLevel.ERROR);
    }
  }

  goForward() {
    try {
      if (this.controller?.accessForward()) {
        this.controller?.forward();
      }
    } catch (e) {
      meow(`this.controller?.forward(); failed: ${e}`, 'meowTabInfo][goForward', meowLevel.ERROR);
    }
  }

  goHome() {
    try {
      if (userHomeUrl()) {
        this.controller?.loadUrl(userHomeUrl());
      } else {
        this.controller?.loadUrl('resource://rawfile/meow.html');
      }

    } catch (e) {
      meow(`this.controller?.loadUrl(userHomeUrl()); failed: ${e}`, 'meowTabInfo][goHome', meowLevel.ERROR);
    }
  }

  // Web settings

  forceDarkMe() {
    if (!this.url) {
      return true;
    }
    if (!forceWebDarkMode()) {
      return false;
    }
    const exc = forceWebDarkExceptions();
    for (const domain of exc) {
      if (belongsToDomain(this.url, domain)) {
        return false;
      }
    }
    return true;
  }

  disableImagesMe() {
    if (!this.url) {
      return false;
    }
    if (!disableWebImages()) {
      return false;
    }
    if (disableWebImagesOnAllSites()) {
      return true;
    }
    const dis = disableWebImagesSites();
    for (const domain of dis) {
      if (belongsToDomain(this.url, domain)) {
        return true;
      }
    }
    return false;
  }

  disableJSMe() {
    if (!this.url) {
      return false;
    }
    if (!disableWebJavaScripts()) {
      return false;
    }
    if (disableWebJavaScriptsOnAllSites()) {
      return true;
    }
    const dis = disableWebJavaScriptSites();
    for (const domain of dis) {
      if (belongsToDomain(this.url, domain)) {
        return true;
      }
    }
    return false;
  }

  // Requests

  requestNewTab(url: string) {
    const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myUi.windowId}`)!;
    let result: WebviewController | null = null;
    animateToImmediately(defaultAnimation(), () => {
      result = myTabs.newTabBare(url).controller || null;
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

  requestload(event: OnLoadInterceptEvent) {
    let intercept = false;
    if (event) {
      const url: string = event.data.getRequestUrl();
      const scheme = url.split(':')[0];
      if (!viewableSchemes.includes(scheme)) {
        intercept = true;
        // Ask for decision from the user to jump or not.
        meow(`Jump to [${url}]?`, 'meowTabInfo][requestload');
        const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
        requestDialog(myDialog, openDialogRequestType.JUMP, [this.url, event.data.getRequestUrl()]);
      }
    }
    return intercept;
  }

  requestAlert(event: OnAlertEvent) {
    if (event) {
      const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
      requestDialog(myDialog, openDialogRequestType.ALERT, event);
    }
  }
  
  requestConfirm(event: OnConfirmEvent) {
    if (event) {
      const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
      requestDialog(myDialog, openDialogRequestType.CONFIRM, event);
    }
  }
  
  requestPrompt(event: OnPromptEvent) {
    if (event) {
      const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
      requestDialog(myDialog, openDialogRequestType.PROMPT, event);
    }
  }
}
