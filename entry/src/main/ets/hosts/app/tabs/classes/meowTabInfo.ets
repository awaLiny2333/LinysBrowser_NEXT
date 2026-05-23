import { AppStorageV2, UIContext } from "@kit.ArkUI";
import { webview } from "@kit.ArkWeb";
import { certificateManager, certificateManagerDialog } from "@kit.DeviceCertificateKit";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { belongsToDomain } from "../../../../catstypicalframework/utils/url";
import { defaultAnimation } from "../../../../components/settings";
import { meowDialogManager, openDialogRequestType } from "../../../system/dialogs/classes/meowDialogManager";
import { requestDialog } from "../../../system/dialogs/scripts/dialog";
import { meowUiFullscreenStatus, meowUiHost } from "../../../system/windows/classes/meowUiHost";
import { meowHistorian } from "../../../userdata/history/classes/meowHistorian";
import { meowHistoryEntry } from "../../../userdata/history/classes/meowHistoryEntry";
import { getMyDawn } from "../../downloads/scripts/helper";
import { defaultBlankUrl, viewableSchemes } from "../scripts/helpers";
import { disableWebImages, disableWebImagesOnAllSites, disableWebImagesSites, disableWebJavaScripts, disableWebJavaScriptSites, disableWebJavaScriptsOnAllSites, forceWebDarkExceptions, forceWebDarkMode, intelligentTrackingPrevention, recordNewHistoryFromSettings, userHomeUrl, userNewTabUrl } from "../settings";
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
  saveHistoryTimeoutId: number | undefined;
  lastSavedHistoryEntry: meowHistoryEntry | undefined;
  // Search in page
  @Trace inputSearchKey: string = '';
  @Trace searchedSearchKey: string = '';
  @Trace isSearching: boolean = false;
  @Trace searchIsDone: boolean = true;
  @Trace currentSearchResultIdx: number = -1;
  @Trace searchResultCount: number = 0;

  constructor(myUi: meowUiHost) {
    this.myUi = myUi;
    this.controller = new webview.WebviewController();
  }

  // Statuses

  get isLoading() {
    return this.progress != -1;
  }

  // UI

  onPageBegin() {
    // Do things.
  }

  onPageEnd() {
    // Do things.
  }

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
      this.syncUrlUI();

      // Web statuses
      this.updateWebUiStatuses();

      // Save to history
      this.tryPunchHistory();
    } catch (e) {
      meow(`this.url = this.controller?.getUrl(); failed: ${e}`, 'meowTabInfo][updateUrl', meowLevel.ERROR);
    }
  }

  /**
   * Sync the url of this tab to the address bar.
   * Also analyzes the new url and tries to shift to search keywords view (address bar) if possible.
   */
  syncUrlUI() {
    const myTabs = AppStorageV2.connect(meowTabsBunch, `meowTabsBunch_${this.myUi.windowId}`)!;
    if (myTabs.currentTab != this) {
      return; // Not my stage.
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

  stop() {
    try {
      this.controller?.stop();
    } catch (e) {
      meow(`this.controller?.stop(); failed: ${e}`, 'meowTabInfo][stop', meowLevel.ERROR);
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

  /**
   * Try to punch a hole in the history tape! Requests the meowHistorian to save a new history after a certain period of time.
   * @param timeout The timeout. (By default 1999 ms).
   */
  tryPunchHistory(timeout: number = 1999) {
    if (!recordNewHistoryFromSettings()) {
      meow(`Record new history from settings is disabled!`, 'meowTabInfo][tryPunchHistory');
      return;
    }
    if (this.saveHistoryTimeoutId) {
      clearTimeout(this.saveHistoryTimeoutId);
      meow(`Cleared old timeout.`, 'meowTabInfo][tryPunchHistory');
    } else {
      console.warn(' ');
      meow(`Punching [${this.title}](${this.url}) in ${timeout} ms!`, 'meowTabInfo][tryPunchHistory', meowLevel.WARN);
    }
    this.saveHistoryTimeoutId = setTimeout(() => {
      const myHistory = AppStorageV2.connect(meowHistorian)!;
      const newEntry = new meowHistoryEntry(this.title || '', this.url || '', Date.now());
      // Check and push.
      if (newEntry.url != this.lastSavedHistoryEntry?.url) {
        myHistory.pushHistory(newEntry);
        this.lastSavedHistoryEntry = newEntry;
        meow(`Saved [${newEntry.title}](${newEntry.url})`, 'meowTabInfo][tryPunchHistory', meowLevel.WARN);
      } else {
        // this.lastSavedHistoryEntry must exist!
        if (newEntry.title != this.lastSavedHistoryEntry.title) {
          // Update in name.
          // TODO: find a quick way to update the old title.
          meow(`Update title [${this.lastSavedHistoryEntry.title}] => [${newEntry.title}]`, 'meowTabInfo][tryPunchHistory', meowLevel.WARN);
          myHistory.deleteHistory(new Set([this.lastSavedHistoryEntry.time])).then(() => {
            myHistory.pushHistory(newEntry);
          });
        } else {
          // Completely the same.
          meow(`Duplicate [${newEntry.title}](${newEntry.url}) rejected!`, 'meowTabInfo][tryPunchHistory', meowLevel.WARN);
        }
      }
      this.saveHistoryTimeoutId = undefined;
    }, timeout);
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

    // if (useAdBlock()) {
    //   try {
    //     this.controller!.enableAdsBlock(true);
    //   } catch (e) {
    //     meow(`this.controller?.enableAdsBlock(true); failed: ${e}`, 'meowTabInfo][onControllerAttached', meowLevel.ERROR);
    //   }
    // }
  }

  requestUiUpdate() {
    this.node?.update(this);
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

  requestload(event: OnLoadInterceptEvent) {
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

  requestAlert(event: OnAlertEvent) {
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.ALERT, event, true);
  }

  requestConfirm(event: OnConfirmEvent) {
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.CONFIRM, event, true);
  }

  requestPrompt(event: OnPromptEvent) {
    const myDialog = AppStorageV2.connect(meowDialogManager, `meowDialogManager_${this.myUi.windowId}`)!;
    requestDialog(myDialog, openDialogRequestType.PROMPT, event, true);
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
