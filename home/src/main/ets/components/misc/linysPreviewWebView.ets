import lazy { webview } from '@kit.ArkWeb';
import lazy { bunch_of_tabs } from '../../hosts/bunch_of_tabs';

@Component
struct linysPreviewWebView {
  // Params
  url: string = 'huawei.com'
  controller_meow: webview.WebviewController = new webview.WebviewController();
  // Env
  storage: LocalStorage = new LocalStorage();
  // Hosts
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);

  build() {
    Web({ src: this.url, controller: this.controller_meow })
      .databaseAccess(true)
      .fileAccess(true)
      .domStorageAccess(true)
      .multiWindowAccess(true)
      .mixedMode(MixedMode.All)
      .allowWindowOpenMethod(true)
      .mediaOptions({ audioExclusive: false })
      .darkMode(WebDarkMode.Auto) // Dark mode!
      .forceDarkAccess(this.bunch_of_tabs.workingMainTab().tab_force_dark) // Force dark mode
      .javaScriptAccess(!this.bunch_of_tabs.workingMainTab().tab_disable_js)
      .imageAccess(!this.bunch_of_tabs.workingMainTab().tab_disable_image)
      .onlineImageAccess(!this.bunch_of_tabs.workingMainTab().tab_disable_image)
      .borderRadius(6)
      .onControllerAttached(() => {
        // BORROWED FROM export function on_controller_attached(pk: tab_info_packed) in src/main/ets/processes/web_actions.ets

        // bind download delegate
        try {
          this.controller_meow.setDownloadDelegate(this.storage.get('dl_delegate') as webview.WebDownloadDelegate);
        } catch (e) {
          console.error('[previewWebView] onControllerAttached setDownloadDelegate error: ' + e);
        }

        // Set Default error page
        try {
          this.controller_meow.setErrorPageEnabled(true);
        } catch (e) {
          console.error(`[previewWebView][setErrorPageEnabled] Failed: ${e}`)
        }

        // Set UA
        let now_global_custom_UA = AppStorage.get('universal_global_custom_ua_gateway') as string;
        if (now_global_custom_UA != "") {
          try {
            this.controller_meow.setCustomUserAgent(now_global_custom_UA);
          } catch (e) {
            console.error('[previewWebView] onControllerAttached setCustomUserAgent error: ' + e);
          }
        }

        // Set Ads Blocker
        let use_adblock = AppStorage.get('use_adblock') as boolean;
        console.log('[previewWebView] enableAdsBlock: ' + (use_adblock ? 'true' : 'false'));
        try {
          this.controller_meow.enableAdsBlock(use_adblock);
          console.info('[previewWebView] onControllerAttached enableAdsBlock! [' + this.url + ']');
        } catch (e) {
          console.error('[previewWebView] onControllerAttached enableAdsBlock error: ' + e);
        }

        // Set Ads Blocker exception list
        try {
          let adblock_exceptions = AppStorage.get('adblock_exceptions') as string[];
          console.log('[previewWebView] Trying to add ads blocker exceptions: [' + adblock_exceptions + '] Operated by meowWebView ~');
          // webview.AdsBlockManager.addAdsBlockDisallowedList(adblock_exceptions);
          webview.AdsBlockManager.addAdsBlockDisallowedList(Array.from(adblock_exceptions)); // wtf??? why???
        } catch (e) {
          console.error('[previewWebView] add Ads Blocker Exceptions error: ' + e);
        }

        // Set intelligent tracking prevention
        try {
          let intelligent_tracking_prevention = AppStorage.get('intelligent_tracking_prevention') as boolean;
          this.controller_meow.enableIntelligentTrackingPrevention(intelligent_tracking_prevention);
          console.log('[previewWebView] ArkWeb Intelligent Tracking Prevention ' + intelligent_tracking_prevention.toString() + '!');
        } catch (e) {
          console.error('[previewWebView] onControllerAttached enableIntelligentTrackingPrevention error: ' + e);
        }
      })
  }
}

export default linysPreviewWebView;