import { animation_default } from '../hosts/bunch_of_defaults';
import { bunch_of_history, history_record } from '../hosts/bunch_of_history';
import { bunch_of_tabs, tab_label } from '../hosts/bunch_of_tabs';
import { sandbox_save } from '../utils/storage_tools';
import { url_meow_to_resource, url_resource_to_meow } from '../utils/url_tools';
import { webview } from '@kit.ArkWeb';
import { bunch_of_settings } from '../hosts/bunch_of_settings';

@Component
struct meowWebView {
  @StorageProp('currentColorMode') current_color_mode: number = 0;
  @StorageProp('pathDir') pathDir: string = "";
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('restore_web_state_arrays') restore_web_state_arrays: Uint8Array[] = [];
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('current_main_tab_index') @Watch('on_tab_info_change') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') @Watch('on_tab_info_change') current_sub_tab_index: number = -1;
  // Controls and environments
  @StorageLink('tab_titles') tab_titles: string[] = []
  @StorageLink('current_title') current_title: string = "=￣ω￣=";
  @StorageLink('tab_urls') tab_urls: string[] = []
  @StorageLink('current_url') current_url: string = "=￣ω￣=";
  @StorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0]
  @StorageLink('current_loading_progress') current_loading_progress: number = 0
  @StorageLink('tab_is_loading') tab_is_loading: boolean[] = [true]
  @StorageLink('current_is_loading') current_is_loading: boolean = true
  // Web control statuses
  @StorageLink('current_accessForward') current_accessForward: boolean = false;
  @StorageLink('current_accessBackward') current_accessBackward: boolean = false;
  @Link search_input: string;
  @Link is_search_input_typing: boolean;
  // Settings
  @Prop settings_collect_new_history: boolean;
  @Link @Watch('on_use_adblock_state_change') use_adblock: boolean;
  @Link adblock_exceptions: string[];
  @Link web_force_dark_mode: boolean;
  // Stuffs
  @StorageLink('universal_global_custom_ua_gateway') now_global_custom_UA: string = "";
  @StorageLink('universal_new_download_gateway') new_download_gateway: string = "";
  @StorageProp('tab_animation') tab_animation: AnimateParam = animation_default();
  @State last_timeout_id: number | undefined = undefined;
  // Colors
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');

  async aboutToAppear(): Promise<void> {

    // Get whether ads blocker is enabled
    this.use_adblock = await this.bunch_of_settings.get('use_adblock') as boolean;

    // Get adblock exceptions
    let exceptions_got = await this.bunch_of_settings.get('adblock_exceptions') as string;
    this.adblock_exceptions = exceptions_got.split('\n');

    // If directly use addAdsBlockDisallowedList(this.adblock_exceptions)
    // would cause Error: BusinessError 401: Parameter error. The type of domainSuffixes must be an array of string.
    // So a manual copy of string[] is unavoidable so far
    // WEIRD 눈_눈
    // TODO: Find out why "401: The type of domainSuffixes must be an array of string" if don't manually copy this array

    let exceptions: string[] = [];
    for (let i = 0; i < this.adblock_exceptions.length; i++) {
      if (this.adblock_exceptions[i] != "" && this.adblock_exceptions[i] != " ") {
        exceptions.push(this.adblock_exceptions[i]);
      }
    }

    // Set
    this.adblock_exceptions = exceptions;
    console.log("[Meow][meowAppSettings] Set AdsBlocker exceptions: " + this.adblock_exceptions.join(", "));

    // TODO: Find out why this doesn't work here
    // Set Ads Blocker exception list
    // webview.AdsBlockManager.addAdsBlockDisallowedList(this.adblock_exceptions);

  }

  build() {
    RelativeContainer() {
      ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
        Column() {
          Web({
            src: this.initial_src_of_tab_index(Label.index_key),
            controller:
            this.bunch_of_tabs.Tabs[Label.index_key] !== undefined ?
            this.bunch_of_tabs.Tabs[Label.index_key].controller : undefined
          })// Main WEB
            .width("100%")
            .height("100%")
            .backgroundColor('transparent')
            .databaseAccess(true)
            .onlineImageAccess(true)
            .javaScriptAccess(true)
            .fileAccess(true)
            .domStorageAccess(true)
            .multiWindowAccess(true)
            .onWindowNew((event) => {
              let new_target_url = event.targetUrl;
              AppStorage.setOrCreate('universal_new_tab_gateway', new_target_url);
              event.handler.setWebController(null);
            })
            .onErrorReceive((e) => {
              if (e) {
                console.error("[ArkWeb][ERROR] " + e.error.getErrorCode() + ", " + e.error.getErrorInfo()
                  + " @ " + this.tab_urls[Label.index_key])
                // Log web errors
              }
            })
            .onPageBegin(() => {
              // console.log("[Meow][ArkWeb] on page begin")

              if (Label.index_key >= this.bunch_of_tabs.Tabs.length) {
                // If not synced, idk why but o(=•ェ•=)m
                return;
              }

              // Update History
              this.current_accessBackward = this.bunch_of_tabs.Tabs[Label.index_key].controller.accessBackward()
              this.current_accessForward = this.bunch_of_tabs.Tabs[Label.index_key].controller.accessForward()
              // Ask tab to update its info (Reset)
              this.bunch_of_tabs.Tabs[Label.index_key].update_title()
              this.bunch_of_tabs.Tabs[Label.index_key].update_url()
              this.bunch_of_tabs.Tabs[Label.index_key].update_is_loading(true)
              this.bunch_of_tabs.Tabs[Label.index_key].update_loading_progress(0)
              // Get synced lists
              this.sync_list_info()
              // Update Input Search Box
              this.update_current_info()
              this.update_search_box_text(this.current_url)

            })
            .onPageEnd(() => {
              // console.log("[Meow][ArkWeb] on page end")
              this.bunch_of_tabs.Tabs[Label.index_key].update_is_loading(false);
              this.tab_is_loading = this.bunch_of_tabs.get_all_is_loading();
              this.update_current_info();

              // Save browse history if is neither new tab nor a recovery tab
              if (this.settings_collect_new_history
                && !this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation
                && !this.tab_urls[Label.index_key].includes("resource://")
              ) {
                let new_record = new history_record(this.tab_titles[Label.index_key], this.tab_urls[Label.index_key])
                this.bunch_of_history.add_history(new_record, true);
              } else {
                this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation = false;
                // log
                if (!this.settings_collect_new_history) {
                  console.log("[meowWebView] Didn't save history for settings disabled.");
                } else {
                  console.log("[meowWebView] Didn't save history for a recovery process in progress");
                }
              }
            })
            .onProgressChange((event) => {
              if (!event) {
                return;
              }

              let progress: number = event.newProgress;
              // console.log("[Meow][ArkWeb] on progress change: " + progress.toString())
              // Update current loading progress
              if (progress == 0) {
                return;
              }

              if (Label.index_key >= this.bunch_of_tabs.Tabs.length) {
                // If not synced, idk why but o(=•ェ•=)m
                return;
              }

              this.bunch_of_tabs.Tabs[Label.index_key].update_title()
              this.bunch_of_tabs.Tabs[Label.index_key].update_url()
              this.bunch_of_tabs.Tabs[Label.index_key].update_loading_progress(progress)
              // Ask tab to update its info
              this.sync_list_info()
              // Get synced lists
              this.update_current_info()
              // Update Input Search Box
              this.update_search_box_text(this.current_url)

              if (this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation) {
                return;
              }

              // Get web_state
              let web_state = this.bunch_of_tabs.Tabs[Label.index_key].controller.serializeWebState();
              // Sync to bunch_of_tabs
              this.bunch_of_tabs.Tabs[Label.index_key].web_state_array = web_state;
              // save web state to sandbox storage
              if (web_state && !this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation) {
                let identifier = "continue/continue_tabs_web_state_array_" + Label.index_key.toString();
                sandbox_save(identifier, web_state.buffer);
              }
            })
            .onDownloadStart((event) => {
              if (event) {
                console.log('url:' + event.url)
                console.log('userAgent:' + event.userAgent)
                console.log('contentDisposition:' + event.contentDisposition)
                console.log('contentLength:' + event.contentLength)
                console.log('mimetype:' + event.mimetype)

                this.new_download_gateway = event.url;
              }
            })
            .onAppear(() => {
              if (this.now_global_custom_UA != "") {
                this.bunch_of_tabs.Tabs[Label.index_key].controller.setCustomUserAgent(this.now_global_custom_UA);
              }
              console.log('[Meow][meowWebView] enableAdsBlock: ' + (this.use_adblock ? 'true' : 'false'))
              this.bunch_of_tabs.Tabs[Label.index_key].controller.enableAdsBlock(this.use_adblock);

              // Set Ads Blocker exception list
              try {
                console.log('[Meow][meowWebView] add Ads Blocker Exceptions success. Operated by tab No.' +
                Label.index_key.toString() + ' ~')
                webview.AdsBlockManager.addAdsBlockDisallowedList(this.adblock_exceptions);
              } catch (e) {
                console.error('[ERROR][Meow][meowWebView] add Ads Blocker Exceptions error: ')
                console.error(e);
              }

              // Restore Web State
              if (this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation) {
                if (Label.index_key < this.restore_web_state_arrays.length) {
                  this.bunch_of_tabs.restore_web_state(this.restore_web_state_arrays[Label.index_key], Label.index_key);
                } else {
                  console.error('[ERROR][Meow][meowWebView] Restore web state failed ' +
                    'for an out-of-bound index in restore_web_state_arrays.')
                }
              }
            })
            .darkMode(WebDarkMode.Auto)// Dark mode!
            .forceDarkAccess(this.web_force_dark_mode) // Force dark mode
        }
        .borderColor(this.color_current_secondary)
        .borderWidth(this.border_width_tab(this.current_sub_tab_index == Label.index_key))
        .width(this.current_sub_tab_index < 0 ? "100%" : this.width_tab())
        .height(this.current_sub_tab_index < 0 ? "100%" : this.height_tab())
        .alignRules(this.current_main_tab_index == Label.index_key
          ? this.align_rules_main_tab() : this.align_rules_sub_tab())
        .visibility(this.my_visibility(Label.index_key))
        .animation(this.tab_animation)
      }, (item: tab_label) => item.timestamp.toString())

    }
    .width("100%")
    .height("100%")
    .onAppear(() => {
      console.log("[Meow][meowWebView] WebViews READY")
      // console.log("[Meow][meowWebView] Restore tabs length: " + this.bunch_of_tabs.Tabs.length.toString())
    })
  }

  // Operations

  update_current_info() {
    this.current_title = this.tab_titles[this.current_main_tab_index];
    this.current_url = this.tab_urls[this.current_main_tab_index];
    this.current_url = url_resource_to_meow(this.current_url);
    // translate "resource://" into "meow://"
    this.current_loading_progress = this.tab_loading_progresses[this.current_main_tab_index];
    this.current_is_loading = this.tab_is_loading[this.current_main_tab_index];
    // Set loading progress
  }

  sync_list_info() {
    this.tab_titles = this.bunch_of_tabs.get_all_titles()
    this.tab_urls = this.bunch_of_tabs.get_all_urls()
    this.tab_is_loading = this.bunch_of_tabs.get_all_is_loading();
    this.tab_loading_progresses = this.bunch_of_tabs.get_all_loading_progress()
  }

  update_search_box_text(text: string) {
    if (!this.is_search_input_typing) {
      this.search_input = url_resource_to_meow(text)
      // Update Input Search Box
    }
    // Update Input Search Box when new page loaded
  }

  on_tab_info_change() {
    if (this.last_timeout_id) {
      clearTimeout(this.last_timeout_id);
    }
    this.last_timeout_id = setTimeout(() => {
      this.tab_animation = animation_default();
    }, 50)
  }

  on_use_adblock_state_change() {
    // Enable ads block for all tabs
    // if (this.last_use_adblock === undefined) {
    //   // Prevent: Init error. The WebviewController must be associated with a Web component
    //   this.last_use_adblock = this.use_adblock;
    //   return;
    // }
    console.log('[Meow][meowWebView] enableAdsBlock: ' + (this.use_adblock ? 'true' : 'false'))
    for (let index = 0; index < this.bunch_of_tabs.Tabs.length; index++) {
      this.bunch_of_tabs.Tabs[index].controller.enableAdsBlock(this.use_adblock);
    }
  }

  // Kind of constants

  align_rules_main_tab() {
    let align: AlignRuleOption;
    if (this.tablet_mode) {
      align = { left: { anchor: "__container__", align: HorizontalAlign.Start } }
    } else {
      align = { top: { anchor: "__container__", align: VerticalAlign.Top } }
    }
    return align;
  }

  align_rules_sub_tab() {
    let align: AlignRuleOption;
    if (this.tablet_mode) {
      align = { right: { anchor: "__container__", align: HorizontalAlign.End } }
    } else {
      align = { bottom: { anchor: "__container__", align: VerticalAlign.Bottom } }
    }
    return align;
  }

  width_tab() {
    if (this.tablet_mode) {
      return "50%";
    } else {
      return "100%";
    }
  }

  height_tab() {
    if (this.tablet_mode) {
      return "100%";
    } else {
      return "50%";
    }
  }

  border_width_tab(is_sub: boolean) {
    let border_width: EdgeWidths;
    if (this.tablet_mode) {
      border_width = { left: is_sub ? 2 : 0, top: 0 };
    } else {
      border_width = { top: is_sub ? 2 : 0, left: 0 };
    }
    return border_width;
  }

  my_visibility(index: number) {
    if (!(this.current_main_tab_index == index || this.current_sub_tab_index == index)) {
      // Not present
      return Visibility.None;
    }
    return Visibility.Visible;
  }

  // Ladders

  private initial_src_of_tab_index(index: number): string {
    let target_packed_tab_info = this.bunch_of_tabs.Tabs[index];
    if (target_packed_tab_info == undefined) {
      return "";
    } else {
      if (target_packed_tab_info.restore_on_creation) {
        return "";
      } else {
        return url_meow_to_resource(target_packed_tab_info.url);
      }
    }
  }
}

export default meowWebView;