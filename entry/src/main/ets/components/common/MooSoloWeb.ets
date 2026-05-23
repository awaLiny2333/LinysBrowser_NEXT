import lazy { webview } from '@kit.ArkWeb';
import lazy { getMyDawn } from '../../hosts/app/downloads/scripts/helper';
import lazy { disableImages, disableJS, forceDark } from '../../hosts/app/tabs/scripts/helpers';
import lazy { intelligentTrackingPrevention } from '../../hosts/app/tabs/settings';
import { sidebarContentIconSet } from '../constants';

/**
 * The standalone web component that can hold some contents.
 * E.g. in the context menu of a main web.
 */
@ComponentV2
export struct MooSoloWeb {
  // Params
  @Param @Require url: string;
  @Local realUrl: string = this.url;
  // UI
  @Param radius: number = 0;
  // Web
  @Param @Once controllerMeow: webview.WebviewController = new webview.WebviewController();
  // Events
  @Event onDropMe: () => void;

  build() {
    Web({ src: '', controller: this.controllerMeow })
      .databaseAccess(true)
      .fileAccess(true)
      .domStorageAccess(true)
      .mixedMode(MixedMode.All)
      .mediaOptions({ audioExclusive: false })
      .darkMode(WebDarkMode.Auto) // Dark mode!
      .forceDarkAccess(forceDark(this.realUrl)) // Force dark mode
      .javaScriptAccess(!disableJS(this.realUrl))
      .imageAccess(!disableImages(this.realUrl))
      .onlineImageAccess(!disableImages(this.realUrl))
      .onDrop(() => {
        this.onDropMe();
      })
      .onProgressChange(() => {
        this.updateUrl();
      })
      .onPageEnd(() => {
        this.updateUrl();
      })
      .onPageBegin(() => {
        this.updateUrl();
      })
      .onControllerAttached(() => {
        // bind download delegate
        try {
          this.controllerMeow.setDownloadDelegate(getMyDawn().delegate);
        } catch (e) {
          console.error('[previewWebView] onControllerAttached setDownloadDelegate error: ' + e);
        }
        // Set Default error page
        try {
          this.controllerMeow.setErrorPageEnabled(true);
        } catch (e) {
          console.error(`[previewWebView][setErrorPageEnabled] Failed: ${e}`);
        }
        // Set intelligent tracking prevention
        try {
          this.controllerMeow.enableIntelligentTrackingPrevention(intelligentTrackingPrevention());
        } catch (e) {
          console.error('[previewWebView] onControllerAttached enableIntelligentTrackingPrevention error: ' + e);
        }
        // Load if is a web.
        if (!sidebarContentIconSet.has(this.url)) {
          try {
            this.controllerMeow.loadUrl(this.url);
          } catch (e) {
            console.error('[previewWebView] onControllerAttached loadUrl error: ' + e);
          }
        }
      })
      .borderRadius(this.radius);
  }

  /**
   * Update the URL of the web component.
   */
  updateUrl() {
    try {
      this.realUrl = this.controllerMeow.getUrl();
    } catch (e) {
      console.error('[previewWebView] onProgressChange error: ' + e);
    }
  }
}
