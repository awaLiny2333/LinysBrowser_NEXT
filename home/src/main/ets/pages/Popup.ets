import { storage_of_id } from '../utils/ui_tools';
import { webview } from '@kit.ArkWeb';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { on_load_intercept } from '../processes/web_actions';
import linysText from '../components/texts/linysText';
import { add_transparency } from '../utils/color_tools';
import linysSymbol from '../components/texts/linysSymbol';
import { copy } from '../utils/clipboard_tools';
import { animation_default, animation_popup_duration } from '../hosts/bunch_of_defaults';
import linysProgress from '../components/linysProgress';

@Entry({ useSharedStorage: true })
@Component
struct Popup {
  @State url: string = 'Hello Popup';
  @StorageLink('universal_popup_tab_gateway') @Watch('on_universal_popup_tab_gateway_change') universal_popup_tab_gateway: string = '';
  // Environment
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Web
  controller: WebviewController = new webview.WebviewController();
  // UI
  @State copied_icon: boolean = false;
  copy_timeout_id: number | undefined = undefined;
  @State current_loading_progress: number = 0;
  @State current_is_loading: boolean = true;

  aboutToAppear(): void {
    console.log('[onSubWindow][Popup] my_window_id: ' + this.my_window_id);
    this.url = this.storage.get('universal_popup_tab_gateway') as string;
  }

  aboutToDisappear(): void {
    this.storage.set('sub_windowClass', undefined);
  }

  build() {
    Row() {
      Column() {
        Row({ space: 10 }) {
          Scroll() {
            linysText({ text: this.url })
          }
          .backgroundColor(add_transparency(this.color_current_font, 50))
          .animation(animation_default())
          .scrollBar(BarState.Off)
          .padding(10)
          .borderRadius(10)
          .layoutWeight(1)
          .align(Alignment.Start)
          .scrollable(ScrollDirection.Horizontal)
          .edgeEffect(EdgeEffect.Spring)

          linysSymbol({
            symbol_glyph_target: this.copied_icon ? 'sys.symbol.checkmark_clipboard_fill' : 'sys.symbol.plus_square_on_square'
          })
            .onClick(() => {
              // Copy
              copy(this.url);
              this.copied_icon = true;
              clearTimeout(this.copy_timeout_id);
              this.copy_timeout_id = setTimeout(() => {
                this.copied_icon = false;
              }, animation_popup_duration())
            })
        } // Address
        .width('100%')
        .padding(10)

        linysProgress({ percentage: this.current_loading_progress, is_loading: this.current_is_loading })

        Web({
          src: this.url,
          controller: this.controller
        })
          .layoutWeight(1)
          .databaseAccess(true)
          .fileAccess(true)
          .domStorageAccess(true)
          // .multiWindowAccess(true)
          .mixedMode(MixedMode.All)
          .allowWindowOpenMethod(true)
          .mediaOptions({ audioExclusive: false })
          .darkMode(WebDarkMode.Auto) // Dark mode!
          .forceDarkAccess(false) // Force dark mode
          .javaScriptAccess(true)
          .imageAccess(true)
          .onlineImageAccess(true)
          .onPageBegin((e) => {
            this.url = e.url;
            this.current_is_loading = true;
          })
          .onProgressChange((e)=>{
            this.current_loading_progress = e.newProgress;
          })
          .onPageEnd(()=>{
            this.current_is_loading = false;
          })
          .onTitleReceive((e) => {
            let window_class = this.storage.get('sub_windowClass') as window.Window;
            window_class.setWindowTitle(e.title).catch((e: BusinessError) => {
              console.error(`[Popup][onTitleReceive] Update Failed: ${e.code} - ${e.name}, ${e.message}`);
            });
          })
          .onLoadIntercept((event) => {
            return on_load_intercept(undefined, this.storage, event);
          })
          .onPermissionRequest((event) => {
            if (!event) {
              return;
            }
            this.storage.set('permission_request_event', event);
          })
          .onPrompt((e) => {
            if (e) {
              this.storage.set('js_prompt_event', e);
            }
            return true;
          })
          .onConfirm((e) => {
            if (e) {
              this.storage.set('js_confirm_event', e);
            }
            return true;
          })
          .onAlert((e) => {
            if (e) {
              this.storage.set('js_alert_event', e);
            }
            return true;
          })
          .onSslErrorEvent((e) => {
            if (e) {
              this.storage.set('ssl_error_event', e);
            }
          })
          .onHttpAuthRequest((e) => {
            console.log(`[Popup][onHttpAuthRequest] Host: [${e.host}], Realm: [${e.realm}]!`);
            this.storage.set('http_auth_event', e);
            return true;
          })
      }
      .width('100%')
    }
    .backgroundColor(this.color_current_secondary)
    .height('100%')
  }

  on_universal_popup_tab_gateway_change() {
    if (this.universal_popup_tab_gateway != '') {
      // Load
      try {
        this.controller.loadUrl(this.universal_popup_tab_gateway);
      } catch (e) {
        console.error(`[Popup][on_universal_popup_tab_gateway_change] Load url failed: ` + e);
      }
      this.universal_popup_tab_gateway = '';
    }
  }
}