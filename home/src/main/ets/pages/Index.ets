import { AbilityConstant, ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { animation_default } from '../hosts/bunch_of_defaults';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { bunch_of_key_shortcuts } from '../hosts/bunch_of_key_shortcuts';
import { meowContext, meowPx2vp } from '../utils/environment_tools';
import lazy { print_web } from '../utils/print_tools';
import lazy { bunch_of_settings } from '../hosts/bunch_of_settings';
import linysProgress from '../components/linysProgress';
import meowTabsVertical from '../blocks/modules/meowTabsVertical';
import meowTitleBar from '../blocks/modules/meowTitleBar';
import lazy meowBookmarks from '../blocks/modules/meowBookmarks';
import lazy meowWebView from '../blocks/modules/meowWebView';
import lazy woofPromptFail from '../dialogs/prompts/woofPromptFail';

@Entry
@Component
struct Index {
  /**
   * Init Hosts */
  // @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  // @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  // @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("Bookmarks~Meow");
  // @StorageLink('bunch_of_downloads') bunch_of_downloads: bunch_of_downloads = new bunch_of_downloads(true);
  // @StorageLink('bunch_of_search_engines') bunch_of_search_engines: bunch_of_search_engines = new bunch_of_search_engines();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  /**
   * UI Environment */
  @StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 1;
  @StorageLink('topAvoidHeight') topAvoidHeight: number = 1;
  @StorageLink('leftAvoidWidth') leftAvoidWidth: number = 1;
  @StorageLink('rightAvoidWidth') rightAvoidWidth: number = 1;
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('screen_width') screen_width: number = 0;
  @StorageLink('screen_height') screen_height: number = 0;
  @StorageLink('full_screen_height') full_screen_height: number = 0;
  @StorageLink('fullscreen_mode') @Watch('on_fullscreen_switch') fullscreen_mode: boolean = false;
  @StorageProp('currentColorMode') @Watch('on_color_mode_change') current_color_mode: number = 0;
  // @StorageLink('animation_response') animation_response: number = 36;
  // @StorageLink('animation_damping_coefficient') animation_damping: number = 20;
  /**
   * History Indexing */
  // @StorageProp('reindexing_history') reindexing_history: boolean | undefined = undefined;
  // @StorageProp('reindexing_history_progress') reindexing_history_progress: string = "";
  // @StorageProp('history_index_loading') history_index_loading: boolean | undefined = undefined;
  // @StorageProp('history_index_loading_progress') history_index_loading_progress: string = "";
  // @StorageProp('history_index_saving') history_index_saving: boolean | undefined = undefined;
  // @StorageProp('history_index_saving_progress') history_index_saving_progress: string = "";
  /**
   * UI Statuses */
  @StorageLink('fullscreen_handler') handler: FullScreenExitHandler | null = null;
  @StorageLink('showing_downloads') showing_downloads: boolean = false;
  @StorageLink('showing_more_options') showing_more_options: boolean = false;
  @StorageLink('showing_app_settings') showing_app_settings: boolean = false;
  @StorageLink('showing_tabs') @Watch('on_showing_tabs_change') showing_tabs: boolean = false;
  @StorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  /**
   * UI params */
  @State title_bar_height: number = 0;
  @State title_bar_alignRules: AlignRuleOption = {
    middle: { anchor: "__container__", align: HorizontalAlign.Center },
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
  };
  /**
   * Delay */
  @StorageLink('delayed_load_p0') delayed_load_p0: boolean = false;
  delay_p0: number = 200;
  @StorageLink('delayed_load_p1') delayed_load_p1: boolean = false;
  delay_p1: number = 500;
  @StorageLink('delayed_load_p2') delayed_load_p2: boolean = false;
  delay_p2: number = 800;
  /**
   * Interactions (Duplicated in meowTitleBar) */
  // @StorageLink('is_search_input_typing') is_search_input_typing: boolean = false;
  // @StorageLink('search_input') search_input: string = "ଘ*(੭*ˊᵕˋ)੭*";
  /**
   * Web Statuses */
  // @StorageLink('tab_titles') tab_titles: string[] = [];
  // @StorageLink('current_title') current_title: string = "=￣ω￣=";
  // @StorageLink('tab_urls') tab_urls: string[] = [];
  // @StorageLink('current_url') current_url: string = "=￣ω￣=";
  // @StorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0];
  @StorageLink('current_loading_progress') current_loading_progress: number = 0;
  // @StorageLink('tab_is_loading') tab_is_loading: boolean[] = [true];
  @StorageLink('current_is_loading') current_is_loading: boolean = true;
  /**
   * Web control */
  @StorageLink('current_main_tab_index') current_main_tab_index: number = 0;
  // @StorageLink('current_sub_tab_index') current_sub_tab_index: number = -1;
  // @StorageLink('current_accessForward') current_accessForward: boolean = false;
  // @StorageLink('current_accessBackward') current_accessBackward: boolean = false;
  /**
   * Settings */
  @StorageLink('title_bar_position') @Watch('on_title_bar_position_change') title_bar_position: string = "";
  @StorageLink('sys_back_to_access_backward') sys_back_to_access_backward: boolean = false;
  @StorageLink('tabs_style') tabs_style: string = "";
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  // @StorageLink('web_force_dark_mode') web_force_dark_mode: boolean = false;
  // @StorageLink('collect_new_history') collect_new_history: boolean = true;
  // @StorageLink('intelligent_tracking_prevention') intelligent_tracking_prevention: boolean = false;
  // @StorageLink('use_adblock') use_adblock: boolean = true;
  // @StorageLink('adblock_exceptions') adblock_exceptions: string[] = [];
  // @StorageLink('max_bookmark_advice') max_bookmark_advice: number = 5;
  // @StorageLink('max_history_advice') max_history_advice: number = 5;
  /**
   * Settings - Accessibility */
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_tabs_panel') preferred_hand_reverse_tabs_panel: boolean = false;
  /**
   * Gateways */
  @StorageLink('universal_close_tab_gateway') uni_close_tab_gateway: number = -1;
  @StorageLink('universal_new_tab_gateway') uni_new_tab_gateway: string = "";
  /**
   * Dialogs */
  @StorageLink('universal_fail_prompt_desc_gateway') @Watch('on_fail_prompt_gateway') universal_fail_prompt_desc_gateway: ResourceStr = "";
  @State fail_prompt_desc: ResourceStr = '';
  moveFailPrompt_control: CustomDialogController = new CustomDialogController({
    builder: woofPromptFail({
      desc: this.fail_prompt_desc,
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // showInSubWindow: true,
    width: "90%",
  });
  /**
   * Colors */
  @StorageLink('color_light_primary') @Watch('on_color_change') color_light_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_light_secondary') @Watch('on_color_change') color_light_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_light_font') @Watch('on_color_change') color_light_font: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('color_dark_primary') @Watch('on_color_change') color_dark_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_dark_secondary') @Watch('on_color_change') color_dark_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_dark_font') @Watch('on_color_change') color_dark_font: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  async aboutToAppear(): Promise<void> {
    console.log(' \n[Meow][Index]\n ');

    // Determine tablet mode
    await window.getLastWindow(this.getUIContext().getHostContext()).then((value: window.Window) => {
      try {
        const rect: window.Rect = value.getWindowProperties().windowRect;
        this.tablet_mode = meowPx2vp(rect.width) > 600;
      } catch (error) {
        // Leave tablet_mode there to be negative
        this.tablet_mode = false;
      }
    });

    // Init title bar
    this.on_title_bar_position_change();

    // Init color
    this.on_color_change();

    // Trigger delayed load
    setTimeout(() => {
      this.delayed_load_p0 = true;
    }, this.delay_p0);
    setTimeout(() => {
      this.delayed_load_p1 = true;
      // Reopen tabs panel
      // this.bunch_of_settings.get('status_tabs_open').then((status_tabs_open) => {
      //   AppStorage.setOrCreate('showing_tabs', status_tabs_open as boolean);
      // })
    }, this.delay_p1);
    setTimeout(() => {
      this.delayed_load_p2 = true;
    }, this.delay_p2);
  }

  onPageShow(): void {
    // Enable continue
    meowContext().setMissionContinueState(AbilityConstant.ContinueState.ACTIVE).catch(() => {
      // TODO: Implement error handling.
    });
  }

  onBackPress(): boolean {
    return this.back();
  }

  build() {
    Column() {
      // I know this is stupid
      // Forgive me
      // O.o
      Row()// Keyboard shortcuts
        .keyboardShortcut(this.bunch_of_key_shortcuts.fullscreen.main_key, this.bunch_of_key_shortcuts.fullscreen.modifier, () => {
          this.fullscreen_mode = !this.fullscreen_mode;
          this.showing_more_options = false;
        })
        .keyboardShortcut(this.bunch_of_key_shortcuts.print.main_key, this.bunch_of_key_shortcuts.print.modifier, () => {
          print_web(this.bunch_of_tabs.workingMainTab().controller);
        })
      // .keyboardShortcut(FunctionKey.ESC, [], () => {
      //   this.back();
      // })

      Row()// Top Bar Avoid
        .height(this.height_of_top_avoid())
        .backgroundColor(this.color_current_secondary)
        .animation(animation_default())
        .width("100%")

      // Scroll() {
      //   Column() {
      RelativeContainer() {
        Row() {
          Scroll() {
            Row() {
              Scroll() {
                meowTabsVertical()
                  .width(this.width_of_Tabs())
                  .padding(10)
              } // Tabs Panel
              .height("100%")
              .width(this.showing_tabs ? this.width_of_Tabs() : 0)
              .animation(animation_default())
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)

              if (this.delayed_load_p1) {
                Scroll() {
                  meowBookmarks()
                    .width(this.width_of_Bookmarks())
                    .padding(10)
                } // Bookmarks Panel
                .height("100%")
                .width(this.showing_bookmarks ? this.width_of_Bookmarks() : 0)
                .animation(animation_default())
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
              }
            }
            .width("100%")
            .height("100%")
          } // Bookmarks and Tabs
          .width(this.width_of_Bookmarks_and_Tabs())
          .margin(this.margin_of_Bookmarks_and_Tabs())
          .animation(animation_default())
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .height("100%")

          if (this.delayed_load_p0) {
            Row() {
              meowWebView()
            } // WebViews
            .width("100%")
            .backgroundColor(this.color_current_primary)
            .layoutWeight(this.tablet_mode ? 1 : 0)
          }

        } // Main Web
        .direction(this.direction_of_web_and_side_panels())
        .margin(this.title_bar_position == "bottom"
          ? { bottom: this.fullscreen_mode ? 0 : this.title_bar_height }
          : { top: this.fullscreen_mode ? 0 : this.title_bar_height })
        .backgroundColor(this.color_current_primary)
        .alignRules(this.title_bar_alignRules)
        .animation(animation_default())
        .layoutWeight(1)
        .width("100%")
        .onAreaChange((o, n) => {
          this.on_main_area_change(o, n);
        })

        linysProgress({ percentage: this.current_loading_progress, is_loading: this.current_is_loading })
          .alignRules(this.title_bar_alignRules)
          .margin(this.title_bar_position == "bottom"
            ? { bottom: this.fullscreen_mode ? 0 : this.title_bar_height }
            : { top: this.fullscreen_mode ? 0 : this.title_bar_height })

        meowTitleBar({
          bar_height: this.title_bar_height,
          title_bar_alignRules: this.title_bar_alignRules,
        }) // Title Bar
      } // Web, progress, and Title bar
      .layoutWeight(1)
      .animation(animation_default())

      Row()// Bottom Bar Avoid
        .height(this.height_of_bottom_avoid())
        .backgroundColor(this.title_bar_position == "bottom" ? "transparent" : this.color_current_secondary)
        .animation(animation_default())
        .width("100%")

      //   }
      // }
      // .width('100%')
      // .layoutWeight(1)

    }
    .height("100%")
    .width("100%")
    .alignItems(HorizontalAlign.Start)
    .animation(animation_default())
    .backgroundColor(this.color_current_secondary)
    .onAreaChange((_o, n) => {
      this.full_screen_height = n.height as number;
    })
    .onAppear(() => {
      // console.log("[Meow][Index] Home Index READY")
    })
  }

  // @Watch or environment Reactions

  on_title_bar_position_change() {
    if (this.title_bar_position == "bottom") {
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
    this.tablet_mode = this.screen_width > 600;

    if (!this.tablet_mode) {
      if (this.showing_tabs && this.showing_bookmarks) {
        // If showing both tabs and bookmarks,
        // then close tabs when switched to non-tablet mode
        if (this.tabs_style_non_tablet_mode == "vertical") {
          this.showing_tabs = false;
        }
      }
    }
  }

  on_showing_tabs_change() {
    bunch_of_settings.set('status_tabs_open', this.showing_tabs);
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

  /**
   * Hides and shows system UI components.
   * */
  on_fullscreen_switch() {
    window.getLastWindow(this.getUIContext().getHostContext()).then((win) => {
      if (this.fullscreen_mode) {
        win.setWindowSystemBarEnable([]).catch(() => {
          // TODO: Implement error handling.
        });
      } else {
        win.setWindowSystemBarEnable(["status", "navigation"]).catch(() => {
          // TODO: Implement error handling.
        });
      }
    })
  }

  // on_bunch_of_key_shortcuts_change() {
  //   console.log('[Index] on_bunch_of_key_shortcuts_change!');
  // }

  // kinda params

  width_of_Bookmarks_and_Tabs() {
    let result = 0;
    if (this.tablet_mode) {
      if (this.showing_tabs && this.tabs_style != 'horizontal') {
        result += 250;
      }
      if (this.showing_bookmarks) {
        result += 350;
      }
    } else {
      // non_tablet_mode
      if (this.showing_bookmarks) {
        result += 0.9 * this.screen_width;
      }
      if (this.showing_tabs && this.tabs_style_non_tablet_mode == 'vertical') {
        result += 0.9 * this.screen_width;
      }
    }
    return result;
  }

  margin_of_Bookmarks_and_Tabs(): Padding | number {
    if (this.width_of_Bookmarks_and_Tabs() == 0) {
      return 0;
    }
    let status = this.preferred_hand_left_or_right == 'right';
    if (this.preferred_hand_reverse_tabs_panel) {
      status = !status;
    }
    return status ? { right: this.rightAvoidWidth } : { left: this.leftAvoidWidth };
  }

  width_of_Bookmarks() {
    if (this.tablet_mode) {
      return 350;
    }
    return 0.9 * this.screen_width;
  }

  width_of_Tabs() {
    if (this.tablet_mode) {
      // Tablet mode
      if (this.tabs_style == 'horizontal') {
        return 0;
      } else {
        return 250;
      }
    } else {
      // non_tablet_mode
      if (this.tabs_style_non_tablet_mode == 'horizontal') {
        return 0;
      } else {
        return 0.9 * this.screen_width;
      }
    }
  }

  height_of_top_avoid() {
    if (this.fullscreen_mode) {
      return 0;
    }
    if (deviceInfo.deviceType == '2in1' && this.title_bar_position == 'top' && this.tabs_style == 'horizontal' && this.showing_tabs && this.tablet_mode) {
      return 10;
    }
    return this.topAvoidHeight;
  }

  height_of_bottom_avoid() {
    if (this.fullscreen_mode) {
      return 0;
    }
    if (deviceInfo.deviceType == '2in1') {
      return 0;
    }
    let target = this.bottomAvoidHeight;
    if (this.title_bar_position == "bottom") {
      target -= 20;
    }
    return Math.max(0, target);
  }

  direction_of_web_and_side_panels() {
    let status = this.preferred_hand_left_or_right == 'right';
    if (this.preferred_hand_reverse_tabs_panel) {
      status = !status;
    }
    return status ? Direction.Rtl : Direction.Ltr;
  }

  // Operations

  /**
   * Universal Go back function
   * @returns true if successfully executed <Back> for some effects.
   * */
  back() {
    let stop_system_back = false;

    if (this.fullscreen_mode) {
      if (this.handler != null) {
        this.handler.exitFullScreen();
      }
      this.fullscreen_mode = false;
      return true;
    }

    let showing_ui_panels = this.showing_downloads || this.showing_more_options || this.showing_app_settings || this.showing_scratching_board;

    // I know this is stupid but ¯\_(ツ)_/¯ it just works
    // Prioritize closing UI panels
    if (this.tablet_mode) {
      if (showing_ui_panels) {
        this.showing_downloads = false;
        this.showing_more_options = false;
        this.showing_app_settings = false;
        this.showing_scratching_board = false;
        return true;
      }
    } else {
      // Non-tablet mode
      if (showing_ui_panels || this.showing_bookmarks || this.showing_tabs) {
        this.showing_downloads = false;
        this.showing_more_options = false;
        this.showing_app_settings = false;
        this.showing_scratching_board = false;
        // Specials
        if (this.tabs_style_non_tablet_mode == "vertical") {
          this.showing_tabs = false;
        }
        this.showing_bookmarks = false;
        return true;
      }
    }

    // Other returns
    // Only triggers if no closable UI panels are opened
    if (this.sys_back_to_access_backward) {
      if (this.go_back_tab()) {
        stop_system_back = true;
      } else if (this.bunch_of_tabs.get_tabs_count() > 1) {
        // Can close something
        this.uni_close_tab_gateway = this.current_main_tab_index;
        stop_system_back = true;
      }
    }

    return stop_system_back;
  }

  go_back_tab(): boolean {
    return this.bunch_of_tabs.goBackward_onWorkingTab();
  }
}