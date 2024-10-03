import linysProgress from '../components/linysProgress';
import meowTabs from '../blocks/meowTabs';
import meowWebView from '../blocks/meowWebView';
import meowBookmarks from '../blocks/meowBookmarks';
import { animation_default } from '../hosts/bunch_of_defaults';
import meowTitleBar from '../blocks/meowTitleBar';
import { bunch_of_settings } from '../hosts/bunch_of_settings';

@Entry
@Component
struct Index {
  // UI Environment
  @StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 1;
  @StorageLink('topAvoidHeight') topAvoidHeight: number = 1;
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('screen_width') screen_width: number = 0;
  @StorageLink('screen_height') screen_height: number = 0;
  @StorageLink('animation_response') animation_response: number = 0.36;
  @StorageLink('animation_damping_coefficient') animation_damping_coefficient: number = 0.8;
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  // UI Statuses
  @State webViews_ready: boolean = false;
  @State showing_downloads: boolean = false;
  @State showing_more_options: boolean = false;
  @State showing_app_settings: boolean = false;
  @State showing_tabs: boolean = false;
  @State showing_bookmarks: boolean = false;
  @State title_bar_height: number = 0;
  @State web_and_stuff_alignRules: AlignRuleOption = {
    middle: { anchor: "__container__", align: HorizontalAlign.Center },
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
  };
  // Interactions
  @State is_search_input_typing: boolean = false;
  @State search_input: string = "*(੭*ˊᵕˋ)੭*ଘ";
  // Web Statuses
  @State tab_titles: string[] = []
  @State current_title: string = "=￣ω￣=";
  @State tab_urls: string[] = []
  @State current_url: string = "=￣ω￣=";
  @State tab_loading_progresses: number[] = [0]
  @State current_loading_progress: number = 0
  @State tab_is_loading: boolean[] = [true]
  @State current_is_loading: boolean = true
  // Web control statuses
  @State current_main_tab_index: number = 0;
  @State current_sub_tab_index: number = -1;
  @State current_accessForward: boolean = false;
  @State current_accessBackward: boolean = false;
  // Settings
  @State @Watch('on_title_bar_position_change') settings_title_bar_position: string = "";
  @State settings_collect_new_history: boolean = true;

  async aboutToAppear(): Promise<void> {
    this.animation_response = await this.bunch_of_settings.get_setting_key('animation_response') as number;
    this.animation_damping_coefficient =
      await this.bunch_of_settings.get_setting_key('animation_damping_coefficient') as number;
  }

  onBackPress(): boolean | void {
    let stop_system_back = false;

    // I know this is stupid but ¯\_(ツ)_/¯ it just works
    if (this.tablet_mode) {
      if (this.showing_downloads || this.showing_more_options || this.showing_app_settings) {
        this.showing_downloads = false;
        this.showing_more_options = false;
        this.showing_app_settings = false;
        stop_system_back = true;
      }
    } else {
      if (this.showing_downloads || this.showing_more_options || this.showing_app_settings
        || this.showing_bookmarks || this.showing_tabs) {
        this.showing_downloads = false;
        this.showing_more_options = false;
        this.showing_app_settings = false;
        this.showing_tabs = false;
        this.showing_bookmarks = false;
        stop_system_back = true;
      }
    }

    return stop_system_back;
  }

  build() {
    Column() {
      Row()// Top Bar Avoid
        .width("100%")
        .height(px2vp(this.topAvoidHeight))
        .animation(animation_default())
        .backgroundColor($r('app.color.block_color'))

      RelativeContainer() {

        Row() {
          Scroll() {
            Row() {
              Scroll() {
                meowTabs({
                  // Environment
                  webViews_ready: this.webViews_ready,
                  showing_tabs: this.showing_tabs,
                  // Statuses
                  current_main_tab_index: this.current_main_tab_index,
                  current_sub_tab_index: this.current_sub_tab_index,
                  tab_titles: this.tab_titles,
                  tab_urls: this.tab_urls,
                  tab_loading_progresses: this.tab_loading_progresses,
                  tab_is_loading: this.tab_is_loading,
                  current_title: this.current_title,
                  current_url: this.current_url,
                  current_loading_progress: this.current_loading_progress,
                  current_is_loading: this.current_is_loading,
                  // Other Statuses
                  current_accessForward: this.current_accessForward,
                  current_accessBackward: this.current_accessBackward,
                  search_input: this.search_input
                })// Tabs Panel
                  .width(this.tablet_mode ? 250 : 0.9 * this.screen_width)
              }
              .height("100%")
              .width(this.showing_tabs ? "100%" : 0)
              .animation(animation_default())
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)

              Scroll() {
                meowBookmarks({
                  webViews_ready: this.webViews_ready
                })// Bookmarks Panel
                  .width(this.tablet_mode ? 350 : 0.9 * this.screen_width)
              }
              .height("100%")
              .width(this.showing_bookmarks ? "100%" : 0)
              .animation(animation_default())
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)

            }
            .width("100%")
            .height("100%")
          } // Bookmarks and Tabs
          .width(
            !this.tablet_mode ?
              (this.showing_tabs || this.showing_bookmarks ? 0.9 * this.screen_width : 0) :
              ((this.showing_tabs ? 250 : 0) + (this.showing_bookmarks ? 350 : 0))
          )
          .animation(animation_default())
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .height("100%")

          Row() {
            meowWebView({
              webViews_ready: this.webViews_ready,
              settings_collect_new_history: this.settings_collect_new_history,
              // Statuses
              current_main_tab_index: this.current_main_tab_index,
              current_sub_tab_index: this.current_sub_tab_index,
              tab_titles: this.tab_titles,
              tab_urls: this.tab_urls,
              tab_loading_progresses: this.tab_loading_progresses,
              tab_is_loading: this.tab_is_loading,
              current_title: this.current_title,
              current_url: this.current_url,
              current_loading_progress: this.current_loading_progress,
              current_is_loading: this.current_is_loading,
              // Other statuses
              current_accessForward: this.current_accessForward,
              current_accessBackward: this.current_accessBackward,
              search_input: this.search_input,
            })
              .visibility(this.webViews_ready ? Visibility.Visible : Visibility.Hidden)
          } // WebViews
          .width("100%")
          .backgroundColor($r('app.color.start_window_background'))
          .layoutWeight(this.tablet_mode ? 1 : 0)

        } // Main Web
        .direction(this.tablet_mode ? Direction.Ltr : Direction.Rtl)
        .alignRules(this.web_and_stuff_alignRules)
        .layoutWeight(1)
        .width("100%")
        .backgroundColor($r('app.color.start_window_background'))
        .onAreaChange((_o, n) => {
          this.screen_width = n.width as number;
          this.screen_height = n.height as number;
          this.tablet_mode = this.screen_width > 500;
        })
        .margin(this.settings_title_bar_position == "bottom" ?
          { bottom: this.title_bar_height } : { top: this.title_bar_height })

        linysProgress({ percentage: this.current_loading_progress, is_loading: this.current_is_loading })
          .alignRules(this.web_and_stuff_alignRules)
          .margin(this.settings_title_bar_position == "bottom" ?
            { bottom: this.title_bar_height } : { top: this.title_bar_height })

        meowTitleBar({
          bar_height: this.title_bar_height,
          webViews_ready: this.webViews_ready,
          // Environments
          search_input: this.search_input,
          settings_title_bar_position: this.settings_title_bar_position,
          web_and_stuff_alignRules: this.web_and_stuff_alignRules,
          settings_collect_new_history: this.settings_collect_new_history,
          // Current statuses
          current_main_tab_index: this.current_main_tab_index,
          current_sub_tab_index: this.current_sub_tab_index,
          tab_titles: this.tab_titles,
          tab_urls: this.tab_urls,
          tab_loading_progresses: this.tab_loading_progresses,
          tab_is_loading: this.tab_is_loading,
          current_title: this.current_title,
          current_url: this.current_url,
          current_is_loading: this.current_is_loading,
          current_loading_progress: this.current_loading_progress,
          // Data
          current_accessBackward: this.current_accessBackward,
          current_accessForward: this.current_accessForward,
          // Web actions
          showing_tabs: this.showing_tabs,
          showing_bookmarks: this.showing_bookmarks,
          showing_more_options: this.showing_more_options,
          showing_app_settings: this.showing_app_settings,
          showing_downloads: this.showing_downloads,
        }) // Bottom Bar

      }
      .layoutWeight(1)
      .width("100%")
      .animation(animation_default())

      Row()// Bottom Bar Avoid
        .width("100%")
        .height(px2vp(this.bottomAvoidHeight))
        .animation(animation_default())
        .backgroundColor(this.settings_title_bar_position == "bottom" ?
          "transparent" : $r('app.color.block_color'))

    }
    .height("100%")
    .width("100%")
    .animation(animation_default())
    .backgroundColor(this.settings_title_bar_position == "bottom" ?
    $r('app.color.block_color') : $r('app.color.start_window_background'))
    .onAppear(() => {
      console.log("[Meow][Index] Home Index READY")
    })
  }

  // @Watch Reactions

  on_title_bar_position_change() {
    if (this.settings_title_bar_position == "bottom") {
      this.web_and_stuff_alignRules = {
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      }
    } else {
      this.web_and_stuff_alignRules = {
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        top: { anchor: "__container__", align: VerticalAlign.Top }
      }
    }
  }
}
