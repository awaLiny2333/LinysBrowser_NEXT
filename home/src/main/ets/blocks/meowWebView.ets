import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large
} from '../hosts/bunch_of_defaults';
import { bunch_of_history, history_record } from '../hosts/bunch_of_history';
import { bunch_of_tabs, tab_label } from '../hosts/bunch_of_tabs';
import { sandbox_save } from '../utils/storage_tools';
import { match_domain, url_meow_to_resource, url_resource_to_meow } from '../utils/url_tools';
import { webview } from '@kit.ArkWeb';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import woofWantDownload from '../dialogs/woofWantDownload';
import { bunch_of_homepage_shortcuts, homepage_shortcut } from '../hosts/bunch_of_homepage_shortcuts';
import woofHomepageManager from '../dialogs/woofShortcutsManager';

@Component
struct meowWebView {
  @StorageProp('currentColorMode') current_color_mode: number = 0;
  @StorageProp('pathDir') pathDir: string = "";
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('fullscreen_mode') fullscreen_mode: boolean = false;
  @StorageLink('fullscreen_handler') handler: FullScreenExitHandler | null = null;
  @StorageLink('restore_web_state_arrays') restore_web_state_arrays: Uint8Array[] = [];
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('bunch_of_homepage_shortcuts') bunch_of_homepage_shortcuts: bunch_of_homepage_shortcuts =
    new bunch_of_homepage_shortcuts();
  @StorageLink('current_main_tab_index') @Watch('on_tab_info_change') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') @Watch('on_tab_info_change') current_sub_tab_index: number = -1;
  @StorageLink('homepage_background') homepage_background: PixelMap | undefined = undefined;
  @StorageProp('screen_height') screen_height: number = 100;
  // Controls and environments
  @StorageLink('tab_titles') tab_titles: string[] = []
  @StorageLink('current_title') current_title: string = "=￣ω￣=";
  @StorageLink('tab_urls') tab_urls: string[] = []
  @StorageLink('current_url') current_url: string = "=￣ω￣=";
  @StorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0]
  @StorageLink('current_loading_progress') current_loading_progress: number = 0
  @StorageLink('tab_is_loading') tab_is_loading: boolean[] = [true]
  @StorageLink('current_is_loading') current_is_loading: boolean = true
  @StorageLink('current_in_page_searching_stats_current') current_in_page_searching_stats_current: number = 0;
  @StorageLink('current_in_page_searching_stats_total') current_in_page_searching_stats_total: number = 0;
  @StorageLink('current_in_page_searching_keyword') current_in_page_searching_keyword: string = ''
  // Web control statuses
  @StorageLink('current_accessForward') current_accessForward: boolean = false;
  @StorageLink('current_accessBackward') current_accessBackward: boolean = false;
  @StorageLink('search_input') search_input: string = "*(੭*ˊᵕˋ)੭*ଘ";
  @StorageLink('is_search_input_typing') is_search_input_typing: boolean = false;
  // Settings
  @StorageProp('collect_new_history') collect_new_history: boolean = true;
  @StorageProp('intelligent_tracking_prevention') intelligent_tracking_prevention: boolean = false;
  @StorageLink('use_adblock') @Watch('on_use_adblock_state_change') use_adblock: boolean = true;
  // @StorageLink('adblock_exceptions') adblock_exceptions: string[] = [];
  @StorageLink('web_force_dark_mode') web_force_dark_mode: boolean = false;
  @StorageLink('disable_js') disable_js: boolean = false;
  @StorageLink('disable_js_these_sites') disable_js_these_sites: string[] = [];
  @StorageLink('disable_js_all_sites') disable_js_all_sites: boolean = true;
  @StorageLink('disable_image') disable_image: boolean = false;
  @StorageLink('disable_image_these_sites') disable_image_these_sites: string[] = [];
  @StorageLink('disable_image_all_sites') disable_image_all_sites: boolean = true;
  @StorageLink('homepage_shortcuts_left_or_right') homepage_shortcuts_left_or_right: string = 'right';
  // Stuffs
  @State initialization_ok: boolean = false;
  @StorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  @StorageLink('universal_global_custom_ua_gateway') now_global_custom_UA: string = "";
  @StorageLink('universal_new_download_filename_gateway') new_download_filename_gateway: string = "";
  @StorageLink('universal_new_download_additional_info') new_download_additional_info: string = "";
  @StorageLink('universal_new_download_gateway') new_download_gateway: string = "";
  @StorageProp('tab_animation') tab_animation: AnimateParam = animation_default();
  @State last_timeout_id: number | undefined = undefined;
  @State shortcut_scroll_offset: number = 0;
  @State shortcut_scroll_total_height: number = 100;
  shortcut_scroller: Scroller = new Scroller();
  // dialogs
  woofWantDownload_control: CustomDialogController = new CustomDialogController({
    builder: woofWantDownload({
      from: this.current_url,
      file_name: '',
      url: '',
      try_additional_info: ''
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  })
  homepage_shortcuts_control: CustomDialogController = new CustomDialogController({
    builder: woofHomepageManager(),
    alignment: DialogAlignment.Center,
    cornerRadius: 22,
    showInSubWindow: true,
    width: "90%",
  });
  // Colors
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  // Else
  adsBlocker_exceptions: string[] = [];

  async aboutToAppear(): Promise<void> {

    let sites_got: string;

    // Get whether image is disabled
    this.disable_image = await this.bunch_of_settings.get('disable_image') as boolean;
    this.disable_image_all_sites = await this.bunch_of_settings.get('disable_image_all_sites') as boolean;

    // Get image ban specifications
    sites_got = await this.bunch_of_settings.get('disable_image_these_sites') as string;
    if (sites_got == '') {
      this.disable_image_these_sites = [];
    } else {
      this.disable_image_these_sites = sites_got.split('\n');
    }

    // Get whether js is disabled
    this.disable_js = await this.bunch_of_settings.get('disable_js') as boolean;
    this.disable_js_all_sites = await this.bunch_of_settings.get('disable_js_all_sites') as boolean;

    // Get js ban specifications
    sites_got = await this.bunch_of_settings.get('disable_js_these_sites') as string;
    if (sites_got == '') {
      this.disable_js_these_sites = [];
    } else {
      this.disable_js_these_sites = sites_got.split('\n');
    }

    // Get whether ads blocker is enabled
    this.use_adblock = await this.bunch_of_settings.get('use_adblock') as boolean;

    // Get adblock exceptions
    let got_adsBlocker_exceptions = await this.bunch_of_settings.get('adblock_exceptions') as string;
    this.adsBlocker_exceptions = [];
    if (got_adsBlocker_exceptions == '') {
      this.adsBlocker_exceptions = [];
    } else {
      this.adsBlocker_exceptions = got_adsBlocker_exceptions.split('\n');
    }
    // Sync to AppStorage
    AppStorage.set('adblock_exceptions', this.adsBlocker_exceptions);

    this.initialization_ok = true;
  }

  build() {
    RelativeContainer() {
      if (this.homepage_background) {
        Image(this.homepage_background)
          .visibility(this.current_url == 'meow://home' ? Visibility.Visible :
          Visibility.Hidden)// .animation(animation_default())
          .transition(TransitionEffect.OPACITY.animation({ duration: 1000 }))
          .opacity(Math.max(1 - this.shortcut_scroll_offset * 1.2 / this.screen_height, 0.3))
          .brightness(Math.max(Math.min(1 - this.shortcut_scroll_offset / this.screen_height, 1), 0.6))
      } // Background

      ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
        Column() {
          Web({
            src: this.initial_src_of_tab_index(Label.index_key),
            controller:
            this.bunch_of_tabs.Tabs[Label.index_key] !== undefined ?
            this.bunch_of_tabs.Tabs[Label.index_key].controller : undefined,
            // renderMode: RenderMode.SYNC_RENDER
          })// Main WEB
            .width("100%")
            .height("100%")
            .backgroundColor('transparent')
            .databaseAccess(true)
            .javaScriptAccess(this.my_js(Label.index_key))
            .imageAccess(this.my_image(Label.index_key))
            .onlineImageAccess(this.my_image(Label.index_key))
            .fileAccess(true)
            .domStorageAccess(true)
            .multiWindowAccess(true)
            .onSearchResultReceive((result) => {
              this.current_in_page_searching_stats_current =
                Math.min(result.numberOfMatches, result.activeMatchOrdinal + 1);
              this.current_in_page_searching_stats_total = result.numberOfMatches;
              this.bunch_of_tabs.workingMainTab().searching_keyword_stats_current =
                Math.min(result.numberOfMatches, result.activeMatchOrdinal + 1);
              this.bunch_of_tabs.workingMainTab().searching_keyword_stats_total = result.numberOfMatches;
            })
            .onWindowNew((event) => {
              // TODO: Find out why this triggers twice when click once
              let new_target_url = event.targetUrl;
              // console.log('qwq_send_new_tab')
              this.new_tab_gateway = new_target_url;
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

              if (Label.index_key >= this.bunch_of_tabs.get_tabs_count()) {
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
              if (this.collect_new_history
                && !this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation
                && !this.tab_urls[Label.index_key].includes("resource://")
              ) {
                let new_record = new history_record(this.tab_titles[Label.index_key], this.tab_urls[Label.index_key])
                this.bunch_of_history.add_history(new_record, true);
              } else {
                this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation = false;
                // log
                if (!this.collect_new_history) {
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

              if (Label.index_key >= this.bunch_of_tabs.get_tabs_count()) {
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
                console.log('url: ' + event.url)
                console.log('userAgent: ' + event.userAgent)
                console.log('contentDisposition: ' + event.contentDisposition)
                console.log('contentLength: ' + event.contentLength)
                console.log('mimetype: ' + event.mimetype)

                // Save file download additional info
                let try_additional_info = ['url: ' + event.url,
                  'userAgent: ' + event.userAgent,
                  'contentDisposition: ' + event.contentDisposition,
                  'contentLength: ' + event.contentLength.toString(),
                  'mimetype: ' + event.mimetype].join('\n');

                // Cut out original file name
                let file_url_split = event.url.split("/");
                let file_name_result = file_url_split[file_url_split.length-1].split("?")[0];

                // Determine overwrite file name
                let file_name_overwrite = '';
                let file_name_start = event.contentDisposition.indexOf('filename=') + 9;
                let file_name_end = event.contentDisposition.indexOf(';', file_name_start);
                if (file_name_end == -1) {
                  file_name_end = event.contentDisposition.length;
                }
                // if key found, then cut out file_name_overwrite
                if (file_name_start > -1) {
                  file_name_overwrite = event.contentDisposition.slice(file_name_start, file_name_end);
                }
                // eliminate quotes
                let last_idx = file_name_overwrite.length - 1;
                if (file_name_overwrite[last_idx] == '\"' || file_name_overwrite[last_idx] == '\'') {
                  file_name_overwrite = file_name_overwrite.slice(1, last_idx);
                }
                // Overwrite
                if (file_name_overwrite != '') {
                  file_name_result = file_name_overwrite;
                }

                // Call popup
                this.woofWantDownload_control = new CustomDialogController({
                  builder: woofWantDownload({
                    from: this.current_url,
                    file_name: file_name_result,
                    url: event.url,
                    try_additional_info: try_additional_info,
                  }),
                  alignment: DialogAlignment.Center,
                  cornerRadius: 16
                })
                this.woofWantDownload_control.open();
              }
            })
            .onFullScreenEnter((event) => {
              this.fullscreen_mode = true;
              this.handler = event.handler;
            })
            .onFullScreenExit(() => {
              this.fullscreen_mode = false;
            })
            .onControllerAttached(async () => {
              // Set UA
              if (this.now_global_custom_UA != "") {
                this.bunch_of_tabs.Tabs[Label.index_key].controller.setCustomUserAgent(this.now_global_custom_UA);
              }

              // Set Ads Blocker
              console.log('[Meow][meowWebView] enableAdsBlock: ' + (this.use_adblock ? 'true' : 'false'))
              this.bunch_of_tabs.Tabs[Label.index_key].controller.enableAdsBlock(this.use_adblock);

              // TODO: Find out why this doesn't work sometimes for a recovered webpage :O getting crazy
              // Set Ads Blocker exception list
              try {
                console.log('[Meow][meowWebView] add Ads Blocker Exceptions success. Operated by meowWebView ~')
                webview.AdsBlockManager.addAdsBlockDisallowedList(this.adsBlocker_exceptions);
              } catch (e) {
                console.error('[ERROR][Meow][meowWebView] add Ads Blocker Exceptions error: ' + e);
              }

              // Set intelligent tracking prevention
              this.bunch_of_tabs.Tabs[Label.index_key].controller.enableIntelligentTrackingPrevention(this.intelligent_tracking_prevention);
              console.log('[Meow][meowWebView] ArkWeb Intelligent Tracking Prevention ' +
              this.intelligent_tracking_prevention.toString() + '!')

              // Restore Web State
              setTimeout(() => {
                if (this.bunch_of_tabs.Tabs[Label.index_key].restore_on_creation) {
                  if (Label.index_key < this.restore_web_state_arrays.length) {
                    this.bunch_of_tabs.restore_web_state(this.restore_web_state_arrays[Label.index_key],
                      Label.index_key);
                  } else {
                    console.error('[ERROR][Meow][meowWebView] Restore web state failed ' +
                      'for an out-of-bound index in restore_web_state_arrays.')
                  }
                }
              }, 0)
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

      Scroll(this.shortcut_scroller) {
        Column({ space: 10 }) {
          ForEach(
            this.bunch_of_homepage_shortcuts.list_of_homepage_shortcuts,
            (shortcut: homepage_shortcut, key: number) => {
              shortcutButton({
                shortcut: shortcut,
                my_index: key,
              })
            })
        }
        .onAreaChange((_o, n) => {
          this.shortcut_scroll_total_height = n.height as number;
        })
        .alignItems(this.homepage_shortcuts_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
        .padding({ top: this.screen_height * (this.tablet_mode ? 0.3 : 0.7) })
        .animation(animation_default())
        .width('100%')
      } // Shortcuts
      .padding({ right: 14, left: 14, bottom: 18 })
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Vertical)
      .align(Alignment.Bottom)
      .edgeEffect(EdgeEffect.Spring)
      .animation(animation_default())
      .visibility(this.current_url == 'meow://home' ? Visibility.Visible : Visibility.None)
      .onDidScroll(() => {
        this.shortcut_scroll_offset = this.shortcut_scroller.currentOffset().yOffset;
      })
      .onClick(() => {
        this.homepage_shortcuts_control.open();
      })
    }
    .width("100%")
    .height("100%")
    .onAppear(() => {
      console.log("[Meow][meowWebView] WebViews READY")
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
    this.current_in_page_searching_keyword = this.bunch_of_tabs.workingMainTab().searching_keyword;
    this.current_in_page_searching_stats_current = this.bunch_of_tabs.workingMainTab().searching_keyword_stats_current;
    this.current_in_page_searching_stats_total = this.bunch_of_tabs.workingMainTab().searching_keyword_stats_total;
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

  my_js(index: number) {
    if (!this.disable_js) {
      return true;
    }
    // Disable js toggle ON
    if (this.disable_js_all_sites) {
      // Disable on all sites
      return false;
    }
    // Disable on some sites
    if (this.tab_urls[index] && this.disable_js_these_sites.includes(match_domain(this.tab_urls[index]))) {
      return false;
    }
    return true;
  }

  my_image(index: number) {
    if (!this.disable_image) {
      return true;
    }
    // Disable image toggle ON
    if (this.disable_image_all_sites) {
      // Disable on all sites
      return false;
    }
    // Disable on some sites
    if (this.tab_urls[index] && this.disable_image_these_sites.includes(match_domain(this.tab_urls[index]))) {
      return false;
    }
    return true;
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

@Component
struct shortcutButton {
  @Prop my_index: number;
  @Prop shortcut: homepage_shortcut;
  // Environment
  @StorageLink('current_url') current_url: string = "=￣ω￣=";
  @StorageLink('bunch_of_homepage_shortcuts') bunch_of_homepage_shortcuts: bunch_of_homepage_shortcuts =
    new bunch_of_homepage_shortcuts();
  // Gateways
  @StorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // SHow
  @State show: Visibility = Visibility.Hidden;
  @State offset_y: number = 50;

  build() {
    Button("→ " + this.shortcut.label)// Shortcut "󰄏"
      .type(ButtonType.Capsule)
      .backgroundColor(this.color_current_secondary)
      .fontColor(this.color_current_font)
      .border({
        width: 2,
        color: "transparent"
      })
      .fontSize(fontSize_Large())
      .fontWeight(FontWeight.Normal)
      .height(capsule_bar_height())
      .onClick(() => {
        setTimeout(() => {
          this.new_tab_gateway = this.shortcut.url;
          this.current_url = this.shortcut.url;
        }, 100)
      })
      .visibility(this.show)
      .offset({ y: this.offset_y })
      .clickEffect(click_effect_default())
      .animation(animation_default())
      .onAppear(() => {
        setTimeout(() => {
          this.show = Visibility.Visible;
          this.offset_y = 0;
          // Animation of floating up
        }, this.get_animation_timeout())
      })
  }

  get_animation_timeout() {
    let unit_interval = 40;
    let load_length = this.bunch_of_homepage_shortcuts.list_of_homepage_shortcuts.length;
    if (load_length < 5) {
      unit_interval = 100;
    } else if (load_length < 10) {
      unit_interval = 70;
    } else {
      unit_interval = 40;
    }
    return this.my_index * unit_interval;
  }
}