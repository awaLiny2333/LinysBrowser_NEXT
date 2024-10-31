import linysProgress from '../components/linysProgress';
import meowTabs from '../blocks/meowTabs';
import meowWebView from '../blocks/meowWebView';
import meowBookmarks from '../blocks/meowBookmarks';
import { animation_default } from '../hosts/bunch_of_defaults';
import meowTitleBar from '../blocks/meowTitleBar';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';

@Entry
@Component
struct Index {
  // Hosts
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  // UI Environment
  @StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 1;
  @StorageLink('topAvoidHeight') topAvoidHeight: number = 1;
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('screen_width') screen_width: number = 0;
  @StorageLink('screen_height') screen_height: number = 0;
  @StorageLink('animation_response') animation_response: number = 0.36;
  @StorageLink('animation_damping_coefficient') animation_damping: number = 0.8;
  // UI Statuses
  @State webViews_ready: boolean = false;
  @State showing_downloads: boolean = false;
  @State showing_more_options: boolean = false;
  @State showing_app_settings: boolean = false;
  @State @Watch('on_showing_tabs_change') showing_tabs: boolean = false;
  @State showing_bookmarks: boolean = false;
  @State showing_drop_panel: boolean = false;
  @State title_bar_height: number = 0;
  @State title_bar_alignRules: AlignRuleOption = {
    middle: { anchor: "__container__", align: HorizontalAlign.Center },
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
  };
  // Interactions
  @State is_search_input_typing: boolean = false;
  @State search_input: string = "*(੭*ˊᵕˋ)੭*ଘ";
  // Web Statuses
  @StorageLink('tab_titles') tab_titles: string[] = []
  @StorageLink('current_title') current_title: string = "=￣ω￣=";
  @StorageLink('tab_urls') tab_urls: string[] = []
  @StorageLink('current_url') current_url: string = "=￣ω￣=";
  @StorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0]
  @StorageLink('current_loading_progress') current_loading_progress: number = 0
  @StorageLink('tab_is_loading') tab_is_loading: boolean[] = [true]
  @StorageLink('current_is_loading') current_is_loading: boolean = true
  // Web control statuses
  @StorageLink('current_main_tab_index') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') current_sub_tab_index: number = -1;
  @StorageLink('current_accessForward') current_accessForward: boolean = false;
  @StorageLink('current_accessBackward') current_accessBackward: boolean = false;
  // Settings
  @State @Watch('on_title_bar_position_change') settings_title_bar_position: string = "";
  @State sys_back_to_access_backward: boolean = false;
  @State settings_tabs_style: string = "";
  @State settings_collect_new_history: boolean = true;

  async aboutToAppear(): Promise<void> {
    this.animation_response = await this.bunch_of_settings.get_setting_key('animation_response') as number;
    this.animation_damping = await this.bunch_of_settings.get_setting_key('animation_damping_coefficient') as number;
    this.showing_tabs = await this.bunch_of_settings.get_setting_key('settings_tabs_open') as boolean;
  }

  onBackPress(): boolean | void {
    let stop_system_back = false;

    // I know this is stupid but ¯\_(ツ)_/¯ it just works
    // Prioritize closing UI panels
    if (this.tablet_mode) {
      if (this.showing_downloads || this.showing_more_options || this.showing_app_settings || this.showing_drop_panel) {
        this.showing_downloads = false;
        this.showing_more_options = false;
        this.showing_app_settings = false;
        this.showing_drop_panel = false;
        return true;
      }
    } else {
      if (this.showing_downloads || this.showing_more_options || this.showing_app_settings || this.showing_drop_panel
        || this.showing_bookmarks || this.showing_tabs) {
        this.showing_downloads = false;
        this.showing_more_options = false;
        this.showing_app_settings = false;
        this.showing_drop_panel = false;
        // Specials
        this.showing_tabs = false;
        this.showing_bookmarks = false;
        return true;
      }
    }

    // Other
    if (this.sys_back_to_access_backward) {
      if (this.go_back_if_possible()) {
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
        .backgroundColor($r('app.color.block_color'))
        .animation(animation_default())

      RelativeContainer() {

        Row() {
          Scroll() {
            Row() {
              Scroll() {
                meowTabs({
                  // Environment
                  webViews_ready: this.webViews_ready,
                  showing_tabs: this.showing_tabs,
                  settings_tabs_style: this.settings_tabs_style,
                  // Statuses
                  search_input: this.search_input,
                  is_search_input_typing: this.is_search_input_typing,
                })
                  .width(this.width_of_Tabs())
              } // Tabs Panel
              .height("100%")
              .width(this.showing_tabs ? this.width_of_Tabs() : 0)
              .animation(animation_default())
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)

              Scroll() {
                meowBookmarks({
                  webViews_ready: this.webViews_ready
                })
                  .width(this.width_of_Bookmarks())
              } // Bookmarks Panel
              .height("100%")
              .width(this.showing_bookmarks ? this.width_of_Bookmarks() : 0)
              .animation(animation_default())
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)

            }
            .width("100%")
            .height("100%")
          } // Bookmarks and Tabs
          .width(this.width_of_Bookmarks_and_Tabs())
          .animation(animation_default())
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .height("100%")

          Row() {
            meowWebView({
              webViews_ready: this.webViews_ready,
              settings_collect_new_history: this.settings_collect_new_history,
              search_input: this.search_input,
              is_search_input_typing: this.is_search_input_typing,
            })
              .visibility(this.webViews_ready ? Visibility.Visible : Visibility.Hidden)
          } // WebViews
          .width("100%")
          .backgroundColor($r('app.color.start_window_background'))
          .layoutWeight(this.tablet_mode ? 1 : 0)

        } // Main Web
        .direction(this.tablet_mode ? Direction.Ltr : Direction.Rtl)
        .alignRules(this.title_bar_alignRules)
        .layoutWeight(1)
        .width("100%")
        .backgroundColor($r('app.color.start_window_background'))
        .onAreaChange((o, n) => {
          this.on_main_area_change(o, n);
        })
        .margin(this.settings_title_bar_position == "bottom" ?
          { bottom: this.title_bar_height } : { top: this.title_bar_height })
        .animation(animation_default())

        linysProgress({ percentage: this.current_loading_progress, is_loading: this.current_is_loading })
          .alignRules(this.title_bar_alignRules)
          .margin(this.settings_title_bar_position == "bottom" ?
            { bottom: this.title_bar_height } : { top: this.title_bar_height })

        meowTitleBar({
          bar_height: this.title_bar_height,
          webViews_ready: this.webViews_ready,
          // Environments
          search_input: this.search_input,
          is_search_input_typing: this.is_search_input_typing,
          settings_collect_new_history: this.settings_collect_new_history,
          sys_back_to_access_backward: this.sys_back_to_access_backward,
          settings_title_bar_position: this.settings_title_bar_position,
          settings_tabs_style: this.settings_tabs_style,
          title_bar_alignRules: this.title_bar_alignRules,
          // Web actions
          showing_tabs: this.showing_tabs,
          showing_bookmarks: this.showing_bookmarks,
          showing_more_options: this.showing_more_options,
          showing_app_settings: this.showing_app_settings,
          showing_downloads: this.showing_downloads,
          showing_scratching_board: this.showing_drop_panel
        }) // Bottom Bar

      } // Web, progress, and bottom bar
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
      this.title_bar_alignRules = {
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
      }
    } else {
      this.title_bar_alignRules = {
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        top: { anchor: "__container__", align: VerticalAlign.Top }
      }
    }
  }

  on_main_area_change(o: Area, n: Area) {
    this.screen_width = n.width as number;
    this.screen_height = n.height as number;
    this.tablet_mode = this.screen_width > 500;
    if (!this.tablet_mode) {
      if (this.showing_tabs && this.showing_bookmarks) {
        // If showing both tabs and bookmarks,
        // then close tabs when switched to non-tablet mode
        this.showing_tabs = false;
      }
    }
  }

  on_showing_tabs_change() {
    console.log(this.showing_tabs ? "a" : "b")
    this.bunch_of_settings.set_setting_value_of_key('settings_tabs_open', this.showing_tabs);
  }

  // kinds of params

  width_of_Bookmarks_and_Tabs() {
    let result = 0;
    if (this.tablet_mode) {
      if (this.showing_tabs && this.settings_tabs_style != 'horizontal') {
        result += 250;
      }
      if (this.showing_bookmarks) {
        result += 350;
      }
    } else if (this.showing_tabs || this.showing_bookmarks) {
      result += 0.9 * this.screen_width;
    }
    return result;
  }

  width_of_Bookmarks() {
    if (this.tablet_mode) {
      return 350;
    }
    return 0.9 * this.screen_width;
  }

  width_of_Tabs() {
    if (this.tablet_mode) {
      if (this.settings_tabs_style != 'horizontal') {
        return 250;
      } else {
        return 0;
      }
    }
    return 0.9 * this.screen_width;
  }

  // Operations

  other_on_back_presses() {

  }

  go_back_if_possible(): boolean {
    return this.bunch_of_tabs.goBackward_onWorkingTab();
  }
}
