import lazy { webview } from '@kit.ArkWeb';
import lazy { meow, meowLevel } from '../../catstypicalframework/utils/catsLogger';
import lazy { getMyDawn } from '../../hosts/app/downloads/scripts/helper';
import lazy { disableImages, disableJS, forceDark, viewableSchemes } from '../../hosts/app/tabs/scripts/helpers';
import lazy { intelligentTrackingPrevention, useAdBlock } from '../../hosts/app/tabs/settings';
import lazy { openDialogRequestType } from '../../hosts/system/dialogs/classes/meowDialogManager';
import lazy { requestDialog } from '../../hosts/system/dialogs/scripts/dialog';
import { meowUiHost } from '../../hosts/system/windows/classes/meowUiHost';
import { getMySettings } from '../settings';

/**
 * The standalone web component that can hold some contents.
 * E.g. in the context menu of a main web.
 */
@ComponentV2
export struct MooSoloWeb {
  // Params
  @Param @Require url: string;
  // The main purpose is to auto load the web in the side bar after app start. If this web component is called from a onNewWindow event, the url should be automatically loaded and we don't need to do anything.
  @Param autoLoadUrlOnControllerAttached: boolean = false;
  @Param userAgent: string = '';
  @Local realUrl: string = this.url;
  // UI
  @Param @Require myUi: meowUiHost;
  @Param radius: number = 0;
  // Web
  @Param controllerMeow: webview.WebviewController = new webview.WebviewController();
  // Events
  @Event onDropMe: () => void;
  @Event onDragLeaveMe: () => void;
  @Event onUrlUpdate: (url: string) => void;
  @Event onWindowExit: () => void;

  build() {
    Web({ src: '', controller: this.controllerMeow })
      .databaseAccess(true)
      .zoomControlAccess(getMySettings().settingsData[87].value as boolean) // Block Ctrl + - and mouse wheel
      .fileAccess(true)
      .domStorageAccess(true)
      .mixedMode(MixedMode.All)
      .mediaOptions({ audioExclusive: false })
      .darkMode(WebDarkMode.Auto) // Dark mode!
      .forceDarkAccess(forceDark(this.realUrl)) // Force dark mode
      .javaScriptAccess(!disableJS(this.realUrl))
      .imageAccess(!disableImages(this.realUrl))
      .onlineImageAccess(!disableImages(this.realUrl))
      .onLoadIntercept((event) => {
        // Intercept jumps
        let intercept = false;
        const url: string = event.data.getRequestUrl();
        const scheme = url.split(':')[0];
        if (!viewableSchemes.includes(scheme)) {
          intercept = true;
          // Ask for decision from the user to jump or not.
          meow(`Jump to [${url}]?`, 'MooSoloWeb][requestload');
          requestDialog(this.myUi.myDialog, openDialogRequestType.JUMP, [this.url, event.data.getRequestUrl()], true);
        }
        return intercept;
      })
      .onDrop(() => {
        this.onDropMe();
      })
      .onDragLeave(() => {
        this.onDragLeaveMe();
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
        // Set UserAgent
        if (this.userAgent) {
          try {
            this.controllerMeow.setCustomUserAgent(this.userAgent);
          } catch (e) {
            meow(`this.controllerMeow.setCustomUserAgent(this.userAgent); Failed: ${e}`, 'MooSoloWeb][setUserAgent', meowLevel.ERROR);
          }
        }
        // Ad blocker
        if (useAdBlock()) {
          try {
            this.controllerMeow.enableAdsBlock(true);
          } catch (e) {
            meow(`this.controllerMeow.enableAdsBlock(true); Failed: ${e}`, 'MooSoloWeb][onControllerAttached', meowLevel.ERROR);
          }
        }
        // bind download delegate
        try {
          this.controllerMeow.setDownloadDelegate(getMyDawn().delegate);
          meow(`setDownloadDelegate for the new tab!`, 'MooSoloWeb][onControllerAttached');
        } catch (e) {
          meow(`setDownloadDelegate error: ${e}`, 'MooSoloWeb][onControllerAttached', meowLevel.ERROR);
        }
        // Set Default error page
        try {
          this.controllerMeow.setErrorPageEnabled(true);
        } catch (e) {
          meow(`Failed: ${e}`, 'MooSoloWeb][onControllerAttached', meowLevel.ERROR);
        }
        // Set intelligent tracking prevention
        try {
          this.controllerMeow.enableIntelligentTrackingPrevention(intelligentTrackingPrevention());
        } catch (e) {
          meow(`enableIntelligentTrackingPrevention error: ${e}`, 'MooSoloWeb][onControllerAttached', meowLevel.ERROR);
        }
        // Load if is a web (Not sidebar panels).
        if (this.autoLoadUrlOnControllerAttached) {
          try {
            this.controllerMeow.loadUrl(this.url);
          } catch (e) {
            meow('onControllerAttached loadUrl error: ' + e, 'MooSoloWeb][onControllerAttached', meowLevel.ERROR);
          }
        }
      })
      .onWindowExit(() => {
        this.onWindowExit();
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
      console.error('[MooSoloWeb] onProgressChange error: ' + e);
    }
    this.onUrlUpdate(this.realUrl);
  }
}
