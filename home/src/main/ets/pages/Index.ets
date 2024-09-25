import linysProgress from '../components/linysProgress';
import meowTabs from '../blocks/meowTabs';
import meowWebView from '../blocks/meowWebView';
import meowBookmarks from '../blocks/meowBookmarks';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';
import { animation_default } from '../hosts/bunch_of_settings';
import meowTitleBar from '../blocks/meowTitleBar';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';

@Entry
@Component
struct Index {
  @StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 1;
  @StorageLink('topAvoidHeight') topAvoidHeight: number = 1;
  // Interactions
  @State is_search_input_typing: boolean = false;
  @State search_input: string = "*(੭*ˊᵕˋ)੭*ଘ";
  @State search_input_unified: string = "";
  // UI Statuses
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('screen_width') screen_width: number = 0;
  @State showing_downloads: boolean = false;
  @State showing_more_options: boolean = false;
  @State showing_app_settings: boolean = false;
  @State showing_tabs: boolean = false;
  @State showing_bookmarks: boolean = false;
  @State webViews_ready: boolean = false;
  @State title_bar_height: number = 0;
  @State web_and_stuff_alignRules: AlignRuleOption = {
    middle: { anchor: "__container__", align: HorizontalAlign.Center },
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
  };
  // HOSTs
  @State bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  @State bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("Bookmarks Meow");
  @State bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @State bunch_of_downloads: bunch_of_downloads = new bunch_of_downloads();
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
  @State current_tab_index: number = 0;
  @State current_accessForward: boolean = false;
  @State current_accessBackward: boolean = false;
  // Misc weird methods but it just works ¯\_(ツ)_/¯
  @StorageLink('universal_new_tab_gateway') universal_new_tab_gateway: string = "";
  // Settings
  @State @Watch('on_title_bar_position_change') settings_title_bar_position: string = "";
  @State @Watch('on_global_custom_UA_change') now_global_custom_UA: string = "";

  aboutToAppear() {
  }

  build() {
    Column() {
      Row()// Top Bar Avoid
        .width("100%")
        .height(px2vp(this.topAvoidHeight))

      RelativeContainer() {

        Row() {
          Scroll() {
            Row() {
              Scroll() {
                meowTabs({
                  webViews_ready: this.webViews_ready,
                  showing_tabs: this.showing_tabs,
                  animation_default: animation_default(),
                  // Environment
                  bunch_of_tabs: this.bunch_of_tabs,
                  // HOST
                  current_tab_index: this.current_tab_index,
                  tab_titles: this.tab_titles,
                  tab_urls: this.tab_urls,
                  tab_loading_progresses: this.tab_loading_progresses,
                  tab_is_loading: this.tab_is_loading,
                  current_title: this.current_title,
                  current_url: this.current_url,
                  current_loading_progress: this.current_loading_progress,
                  current_is_loading: this.current_is_loading,
                  // Statuses
                  current_accessForward: this.current_accessForward,
                  current_accessBackward: this.current_accessBackward,
                  search_input: this.search_input
                  // Other statuses
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
                  bunch_of_tabs: this.bunch_of_tabs,
                  bunch_of_bookmarks: this.bunch_of_bookmarks,
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
              // Environment
              bunch_of_downloads: this.bunch_of_downloads,
              bunch_of_tabs: this.bunch_of_tabs,
              // HOST
              current_tab_index: this.current_tab_index,
              tab_titles: this.tab_titles,
              tab_urls: this.tab_urls,
              tab_loading_progresses: this.tab_loading_progresses,
              tab_is_loading: this.tab_is_loading,
              current_title: this.current_title,
              current_url: this.current_url,
              current_loading_progress: this.current_loading_progress,
              current_is_loading: this.current_is_loading,
              // Statuses
              current_accessForward: this.current_accessForward,
              current_accessBackward: this.current_accessBackward,
              search_input: this.search_input,
              now_global_custom_UA: this.now_global_custom_UA
              // Other statuses
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
          this.screen_width = n.width as number
          this.tablet_mode = this.screen_width > 500
        })
        .margin(this.settings_title_bar_position == "bottom" ?
          { bottom: this.title_bar_height } : { top: this.title_bar_height })

        linysProgress({ percentage: this.current_loading_progress, is_loading: this.current_is_loading })
          .alignRules(this.web_and_stuff_alignRules)
          .margin(this.settings_title_bar_position == "bottom" ?
            { bottom: this.title_bar_height } : { top: this.title_bar_height })

        meowTitleBar({
          bunch_of_downloads: this.bunch_of_downloads,
          bunch_of_user_agents: this.bunch_of_user_agents,
          bunch_of_tabs: this.bunch_of_tabs,
          bar_height: this.title_bar_height,
          webViews_ready: this.webViews_ready,
          // Environments
          search_input: this.search_input,
          search_input_unified: this.search_input_unified,
          is_search_input_typing: this.is_search_input_typing,
          settings_title_bar_position: this.settings_title_bar_position,
          web_and_stuff_alignRules: this.web_and_stuff_alignRules,
          now_global_custom_UA: this.now_global_custom_UA,
          // Current statuses
          current_tab_index: this.current_tab_index,
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
      .backgroundColor($r('app.color.block_color'))
      .width("100%")
      .animation(animation_default())

      Row()// Bottom Bar Avoid
        .width("100%")
        .height(px2vp(this.bottomAvoidHeight))
    }
    .height("100%")
    .width("100%")
    .backgroundColor($r('app.color.block_color'))
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

  on_global_custom_UA_change() {
    this.bunch_of_tabs.set_global_custom_UA(this.now_global_custom_UA);
  }
}
