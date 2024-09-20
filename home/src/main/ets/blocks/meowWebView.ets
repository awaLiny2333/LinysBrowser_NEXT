import { bunch_of_tabs, tab_label } from '../hosts/bunch_of_tabs';
import { url_meow_to_resource, url_resource_to_meow } from '../utils/url_tools';

@Component
struct meowWebView {
  @StorageProp('currentColorMode') current_color_mode: number = 0;
  @Link bunch_of_tabs: bunch_of_tabs;
  @Link current_tab_index: number;
  @Link universal_new_tab_gateway: string | undefined;
  @Prop show_webViews: boolean;
  @Prop tablet_mode: boolean;
  // Controls and environments
  @Link tab_titles: string[];
  @Link current_title: string;
  @Link tab_urls: string[];
  @Link current_url: string;
  @Link tab_loading_progresses: number[];
  @Link current_loading_progress: number;
  @Link tab_is_loading: boolean[];
  @Link current_is_loading: boolean;
  // Info or Statuses of bunch of tabs
  @Link current_accessForward: boolean;
  @Link current_accessBackward: boolean;
  @Link search_input: string;
  @Link now_global_custom_UA: string;

  build() {
    Row() {
      ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
        Web({
          src: url_meow_to_resource(this.bunch_of_tabs.Tabs[Label.index_key] !== undefined ?
          this.bunch_of_tabs.Tabs[Label.index_key].url : ""),
          controller: this.bunch_of_tabs.Tabs[Label.index_key] !== undefined ?
          this.bunch_of_tabs.Tabs[Label.index_key].controller : undefined
        })// Main WEB
          .width("100%")
          .height("100%")
          .visibility(this.current_tab_index == Label.index_key ? Visibility.Visible : Visibility.None)
          .databaseAccess(true)
          .onlineImageAccess(true)
          .javaScriptAccess(true)
          .fileAccess(true)
          .domStorageAccess(true)
          .multiWindowAccess(true)
          .onWindowNew((event) => {
            let new_target_url = event.targetUrl;
            this.universal_new_tab_gateway = new_target_url;
            event.handler.setWebController(null);
          })
          .onErrorReceive((e) => {
            console.log("[Meow][ArkWeb][ERROR] "
              + e.error.getErrorCode() + ", " + e.error.getErrorInfo()
              + " @ " + this.tab_urls[Label.index_key])
            // Log web errors
          })
          .onPageBegin(() => {
            console.log("[Meow][ArkWeb] on page begin")
            this.current_accessBackward = this.bunch_of_tabs.Tabs[Label.index_key].controller.accessBackward()
            this.current_accessForward = this.bunch_of_tabs.Tabs[Label.index_key].controller.accessForward()
            // Update History
            this.bunch_of_tabs.Tabs[Label.index_key].update_title()
            this.bunch_of_tabs.Tabs[Label.index_key].update_url()
            this.bunch_of_tabs.Tabs[Label.index_key].update_is_loading(true)
            this.bunch_of_tabs.Tabs[Label.index_key].update_loading_progress(0)
            // Ask tab to update its info (Reset)
            this.sync_list_info()
            // Get synced lists
            this.update_current_info()
            this.update_search_box_text(this.current_url)
            // Update Input Search Box
          })
          .onPageEnd(() => {
            console.log("[Meow][ArkWeb] on page end")
            this.bunch_of_tabs.Tabs[Label.index_key].update_is_loading(false);
            this.tab_is_loading = this.bunch_of_tabs.get_all_is_loading();
            this.update_current_info();
          })
          .onProgressChange((event) => {
            let progress: number = event.newProgress;
            console.log("[Meow][ArkWeb] on progress change: " + progress.toString())
            // Update current loading progress
            if (progress == 0) {
              return;
            }
            this.bunch_of_tabs.Tabs[Label.index_key].update_title()
            this.bunch_of_tabs.Tabs[Label.index_key].update_url()
            this.bunch_of_tabs.Tabs[Label.index_key].update_loading_progress(progress)
            // Ask tab to update its info
            this.sync_list_info()
            // Get synced lists
            this.update_current_info()
            this.update_search_box_text(this.current_url)
            // Update Input Search Box
          })
          .onAppear(() => {
            if (this.now_global_custom_UA.length != 0) {
              this.bunch_of_tabs.Tabs[Label.index_key].controller.setCustomUserAgent(this.now_global_custom_UA);
              // set ua
            }
          })
      }, (item: tab_label) => item.timestamp.toString())

    }
    .backgroundColor("green")
    .width("100%")
    .height("100%")
    .onAppear(() => {
      console.log("[Meow][meowWebView] WebViews READY")
    })
  }

  update_current_info() {
    this.current_title = this.tab_titles[this.current_tab_index];
    this.current_url = this.tab_urls[this.current_tab_index];
    this.current_url = url_resource_to_meow(this.current_url);
    // translate "resource://" into "meow://"
    this.current_loading_progress = this.tab_loading_progresses[this.current_tab_index];
    this.current_is_loading = this.tab_is_loading[this.current_tab_index];
    // Set loading progress
  }

  sync_list_info() {
    this.tab_titles = this.bunch_of_tabs.get_all_titles()
    this.tab_urls = this.bunch_of_tabs.get_all_urls()
    this.tab_is_loading = this.bunch_of_tabs.get_all_is_loading();
    this.tab_loading_progresses = this.bunch_of_tabs.get_all_loading_progress()
  }

  update_search_box_text(text: string) {
    this.search_input = url_resource_to_meow(text)
    // Update Input Search Box
  }
}

export default meowWebView;