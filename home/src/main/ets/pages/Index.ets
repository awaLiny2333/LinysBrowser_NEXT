import linysProgress from '../components/linysProgress';
import meowTabs from '../blocks/meowTabs';
import meowWebView from '../blocks/meowWebView';
import meowBookmarks from '../blocks/meowBookmarks';
import { animation_default } from '../hosts/bunch_of_defaults';
import meowTitleBar from '../blocks/meowTitleBar';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import woofFailPrompt from '../dialogs/woofFailPrompt';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import { bunch_of_history } from '../hosts/bunch_of_history';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';
import { bunch_of_search_engines } from '../hosts/bunch_of_search_engines';

@Entry
@Component
struct Index {
  // Init Hosts
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history();
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("Bookmarks~Meow");
  @StorageLink('bunch_of_downloads') bunch_of_downloads: bunch_of_downloads = new bunch_of_downloads();
  @StorageLink('bunch_of_search_engines') bunch_of_search_engines: bunch_of_search_engines =
    new bunch_of_search_engines();
  // UI Environment
  @StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 1;
  @StorageLink('topAvoidHeight') topAvoidHeight: number = 1;
  @StorageLink('leftAvoidWidth') leftAvoidWidth: number = 1;
  @StorageLink('rightAvoidWidth') rightAvoidWidth: number = 1;
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('screen_width') screen_width: number = 0;
  @StorageLink('screen_height') screen_height: number = 0;
  @StorageLink('animation_response') animation_response: number = 0.36;
  @StorageLink('animation_damping_coefficient') animation_damping: number = 0.8;
  @StorageProp('currentColorMode') @Watch('on_color_mode_change') current_color_mode: number = 0;
  // UI Statuses
  @StorageLink('showing_downloads') showing_downloads: boolean = false;
  @StorageLink('showing_more_options') showing_more_options: boolean = false;
  @StorageLink('showing_app_settings') showing_app_settings: boolean = false;
  @StorageLink('showing_tabs') @Watch('on_showing_tabs_change') showing_tabs: boolean = false;
  @StorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
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
  // Web control
  @StorageLink('current_main_tab_index') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') current_sub_tab_index: number = -1;
  @StorageLink('current_accessForward') current_accessForward: boolean = false;
  @StorageLink('current_accessBackward') current_accessBackward: boolean = false;
  @StorageLink('universal_close_tab_gateway') uni_close_tab_gateway: number = -1;
  // Settings
  @State @Watch('on_title_bar_position_change') settings_title_bar_position: string = "";
  @State sys_back_to_access_backward: boolean = false;
  @State web_force_dark_mode: boolean = false;
  @State settings_tabs_style: string = "";
  @State settings_collect_new_history: boolean = true;
  @State use_adblock: boolean = true;
  @State adblock_exceptions: string[] = [];
  // Dialogs
  @StorageLink('universal_fail_prompt_desc_gateway') @Watch('on_fail_prompt_gateway') universal_fail_prompt_desc_gateway: ResourceStr =
    "";
  @State fail_prompt_desc: ResourceStr = '';
  moveFailPrompt_control: CustomDialogController = new CustomDialogController({
    builder: woofFailPrompt({
      desc: this.fail_prompt_desc,
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    showInSubWindow: true,
    width: "90%",
  });
  // Colors
  @StorageLink('color_light_primary') @Watch('on_color_change') color_light_primary: ResourceColor =
    $r('app.color.start_window_background');
  @StorageLink('color_light_secondary') @Watch('on_color_change') color_light_secondary: ResourceColor =
    $r('app.color.block_color');
  @StorageLink('color_light_font') @Watch('on_color_change') color_light_font: ResourceColor =
    $r('app.color.font_color_title');
  @StorageLink('color_dark_primary') @Watch('on_color_change') color_dark_primary: ResourceColor =
    $r('app.color.start_window_background');
  @StorageLink('color_dark_secondary') @Watch('on_color_change') color_dark_secondary: ResourceColor =
    $r('app.color.block_color');
  @StorageLink('color_dark_font') @Watch('on_color_change') color_dark_font: ResourceColor =
    $r('app.color.font_color_title');
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  async aboutToAppear(): Promise<void> {
    this.animation_response = await this.bunch_of_settings.get('animation_response') as number;
    this.animation_damping = await this.bunch_of_settings.get('animation_damping_coefficient') as number;
    let showing_tabs = await this.bunch_of_settings.get('status_tabs_open') as boolean;
    if (this.tablet_mode) {
      this.showing_tabs = showing_tabs;
    }

    // Figure out what color should i use
    this.color_light_primary = await this.bunch_of_settings.get('color_light_primary') as string;
    this.color_light_secondary = await this.bunch_of_settings.get('color_light_secondary') as string;
    this.color_light_font = await this.bunch_of_settings.get('color_light_font') as string;
    this.color_dark_primary = await this.bunch_of_settings.get('color_dark_primary') as string;
    this.color_dark_secondary = await this.bunch_of_settings.get('color_dark_secondary') as string;
    this.color_dark_font = await this.bunch_of_settings.get('color_dark_font') as string;
  }

  onBackPress(): boolean | void {
    let stop_system_back = false;

    // I know this is stupid but ¯\_(ツ)_/¯ it just works
    // Prioritize closing UI panels
    if (this.tablet_mode) {
      if (this.showing_downloads || this.showing_more_options || this.showing_app_settings ||
      this.showing_scratching_board) {
        this.showing_downloads = false;
        this.showing_more_options = false;
        this.showing_app_settings = false;
        this.showing_scratching_board = false;
        return true;
      }
    } else {
      if (this.showing_downloads || this.showing_more_options || this.showing_app_settings ||
      this.showing_scratching_board
        || this.showing_bookmarks || this.showing_tabs) {
        this.showing_downloads = false;
        this.showing_more_options = false;
        this.showing_app_settings = false;
        this.showing_scratching_board = false;
        // Specials
        this.showing_tabs = false;
        this.showing_bookmarks = false;
        return true;
      }
    }

    // Other returns
    if (this.sys_back_to_access_backward) {
      if (this.go_back_if_possible()) {
        stop_system_back = true;
      } else {
        if (this.bunch_of_tabs.Tabs.length > 1) {
          // Can close something
          this.uni_close_tab_gateway = this.current_main_tab_index;
          stop_system_back = true;
        }
      }
    }

    return stop_system_back;
  }

  build() {
    Column() {
      Row()// Top Bar Avoid
        .width("100%")
        .height(px2vp(this.topAvoidHeight))
        .backgroundColor(this.color_current_secondary)
        .animation(animation_default())

      RelativeContainer() {

        Row() {
          Scroll() {
            Row() {
              Scroll() {
                meowTabs({
                  // Environment

                  settings_tabs_style: this.settings_tabs_style,
                  adblock_exceptions: this.adblock_exceptions,
                  use_adblock: this.use_adblock,
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
                meowBookmarks({})
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

              settings_collect_new_history: this.settings_collect_new_history,
              web_force_dark_mode: this.web_force_dark_mode,
              search_input: this.search_input,
              is_search_input_typing: this.is_search_input_typing,
              use_adblock: this.use_adblock,
              adblock_exceptions: this.adblock_exceptions
            })
          } // WebViews
          .width("100%")
          .backgroundColor(this.color_current_primary)
          .layoutWeight(this.tablet_mode ? 1 : 0)

        } // Main Web
        .direction(this.tablet_mode ? Direction.Ltr : Direction.Rtl)
        .alignRules(this.title_bar_alignRules)
        .layoutWeight(1)
        .width("100%")
        .backgroundColor(this.color_current_primary)
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

          // Environments
          search_input: this.search_input,
          is_search_input_typing: this.is_search_input_typing,
          settings_collect_new_history: this.settings_collect_new_history,
          sys_back_to_access_backward: this.sys_back_to_access_backward,
          web_force_dark_mode: this.web_force_dark_mode,
          settings_title_bar_position: this.settings_title_bar_position,
          settings_tabs_style: this.settings_tabs_style,
          title_bar_alignRules: this.title_bar_alignRules,
          use_adblock: this.use_adblock,
          adblock_exceptions: this.adblock_exceptions,
          // Web actions
        }) // Bottom Bar

      } // Web, progress, and bottom bar
      .layoutWeight(1)
      .animation(animation_default())

      // .margin({ left: px2vp(this.leftAvoidWidth), right: px2vp(this.rightAvoidWidth) })

      Row()// Bottom Bar Avoid
        .width("100%")
        .height(px2vp(this.bottomAvoidHeight))
        .animation(animation_default())
        .backgroundColor(this.settings_title_bar_position == "bottom" ?
          "transparent" : this.color_current_secondary)
    }
    .height("100%")
    .width("100%")
    .animation(animation_default())
    .backgroundColor(this.settings_title_bar_position == "bottom" ?
    this.color_current_secondary : this.color_current_primary)
    .onAppear(() => {
      console.log("[Meow][Index] Home Index READY")
    })
  }

  // @Watch or environment Reactions

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

  on_main_area_change(_old: Area, n: Area) {
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
    this.bunch_of_settings.set('status_tabs_open', this.showing_tabs);
  }

  on_fail_prompt_gateway() {
    if (this.universal_fail_prompt_desc_gateway != "") {
      this.fail_prompt_desc = this.universal_fail_prompt_desc_gateway;
      this.moveFailPrompt_control.open();
      this.universal_fail_prompt_desc_gateway = "";
    }
  }

  on_color_mode_change() {
    if (this.current_color_mode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      // Is dark mode
      this.color_current_primary = this.color_dark_primary;
      this.color_current_secondary = this.color_dark_secondary;
      this.color_current_font = this.color_dark_font;
    } else {
      this.color_current_primary = this.color_light_primary;
      this.color_current_secondary = this.color_light_secondary;
      this.color_current_font = this.color_light_font;
    }
  }

  on_color_change() {
    console.log('[Meow][Index] Color theme changed!');
    // Refresh current color
    if (this.current_color_mode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      // Is dark mode
      this.color_current_primary = this.color_dark_primary;
      this.color_current_secondary = this.color_dark_secondary;
      this.color_current_font = this.color_dark_font;
    } else {
      this.color_current_primary = this.color_light_primary;
      this.color_current_secondary = this.color_light_secondary;
      this.color_current_font = this.color_light_font;
    }
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

  go_back_if_possible(): boolean {
    return this.bunch_of_tabs.goBackward_onWorkingTab();
  }
}
