import { animation_default } from '../hosts/bunch_of_defaults';
import { bunch_of_history, history_record } from '../hosts/bunch_of_history';
import { bunch_of_tabs, tab_label } from '../hosts/bunch_of_tabs';
import { sandbox_save } from '../utils/storage_tools';
import { url_meow_to_resource, url_resource_to_meow } from '../utils/url_tools';

@Component
struct meowWebView {
  @StorageProp('currentColorMode') current_color_mode: number = 0;
  @StorageProp('pathDir') pathDir: string = "";
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('web_state_arrays') web_state_arrays: Uint8Array[] = [];
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history();
  @StorageLink('current_main_tab_index') @Watch('on_tab_info_change') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') @Watch('on_tab_info_change') current_sub_tab_index: number = -1;
  @Prop webViews_ready: boolean | undefined;
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
  @Prop @Watch('on_use_adblock_state_change') use_adblock: boolean;
  @State last_use_adblock: boolean | undefined = undefined;
  // Stuffs
  @StorageLink('universal_global_custom_ua_gateway') now_global_custom_UA: string = "";
  @StorageLink('universal_new_download_gateway') new_download_gateway: string = "";
  @StorageProp('web_animation') web_animation: AnimateParam = animation_default();
  @State last_time_out_id: number | undefined = undefined;

  build() {
    RelativeContainer() {
      ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
        Column() {
          Web({
            src: this.initial_src_of_tab_index(Label.index_key),
            controller:
            this.bunch_of_tabs.Tabs[Label.index_key] !== undefined ?
            this.bunch_of_tabs.Tabs[Label.index_key].controller : undefined
          }) // Main WEB
            .width("100%")
            .height("100%")
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
                console.error("[Meow][ArkWeb][ERROR] "
                  + e.error.getErrorCode() + ", " + e.error.getErrorInfo()
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
                && !this.bunch_of_tabs.Tabs[Label.index_key].recovery
                && !this.tab_urls[Label.index_key].includes("resource://")
              ) {
                let new_record = new history_record(this.tab_titles[Label.index_key], this.tab_urls[Label.index_key])
                this.bunch_of_history.add_history(new_record);
                sandbox_save("history.txt", this.bunch_of_history.export_string());
              } else {
                this.bunch_of_tabs.Tabs[Label.index_key].recovery = false;
                // log
                if (!this.settings_collect_new_history) {
                  console.log("[Meow][meowWebView] Didn't save history for settings disabled.");
                } else {
                  console.log("[Meow][meowWebView] Didn't save history for a recovery process in progress");
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

              if (this.bunch_of_tabs.Tabs[Label.index_key].recovery) {
                return;
              }
              // Sync to bunch_of_tabs
              let web_state = this.bunch_of_tabs.Tabs[Label.index_key].controller.serializeWebState();
              this.bunch_of_tabs.Tabs[Label.index_key].web_state_array = web_state;
              // Sync to AppStorage
              this.web_state_arrays = this.bunch_of_tabs.get_all_web_states();
              // kv_store web state
              for (let index = 0; index < this.web_state_arrays.length; index++) {
                const element = this.web_state_arrays[index];
                let identifier = "continue_tabs_web_state_array_" + index.toString();
                // kv_store_put_uint_8_array(identifier, element);
                if (element) {
                  sandbox_save(identifier, element.buffer);
                }
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
              if (this.use_adblock) {
                this.bunch_of_tabs.Tabs[Label.index_key].controller.enableAdsBlock(true);
              }
              // Restore Web State
              this.bunch_of_tabs.restore_web_state(this.web_state_arrays, Label.index_key);
            })
        }
        .visibility((this.current_main_tab_index == Label.index_key || this.current_sub_tab_index == Label.index_key)
          ? Visibility.Visible : Visibility.None)
        .borderColor($r('app.color.block_color'))
        .borderWidth(this.border_width_tab(this.current_sub_tab_index == Label.index_key))
        .width(this.current_sub_tab_index < 0 ? "100%" : this.width_tab())
        .height(this.current_sub_tab_index < 0 ? "100%" : this.height_tab())
        .alignRules(this.current_main_tab_index == Label.index_key
          ? this.align_rules_main_tab() : this.align_rules_sub_tab())
        .animation(this.web_animation)
      }, (item: tab_label) => item.timestamp.toString())

    }
    .width("100%")
    .height("100%")
    .onAppear(() => {
      console.log("[Meow][meowWebView] WebViews READY")
      console.log("[Meow][meowWebView] Restore tabs length: " + this.bunch_of_tabs.Tabs.length.toString())
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
    if (this.last_time_out_id) {
      clearTimeout(this.last_time_out_id);
    }
    this.last_time_out_id = setTimeout(() => {
      this.web_animation = animation_default();
    }, 50)
  }

  on_use_adblock_state_change() {
    // Enable ads block for all tabs
    if (this.last_use_adblock === undefined) {
      this.last_use_adblock = this.use_adblock;
      return;
    }
    for (let index = 0; index < this.bunch_of_tabs.Tabs.length; index++) {
      if (this.bunch_of_tabs.Tabs[index].controller) {
        this.bunch_of_tabs.Tabs[index].controller.enableAdsBlock(this.use_adblock);
      }
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

  // Ladders

  private initial_src_of_tab_index(index: number): string {
    let target_packed_tab_info = this.bunch_of_tabs.Tabs[index];
    if (target_packed_tab_info == undefined) {
      return "";
    } else {
      if (target_packed_tab_info.recovery) {
        return "";
      } else {
        return url_meow_to_resource(target_packed_tab_info.url);
      }
    }
  }
}

export default meowWebView;