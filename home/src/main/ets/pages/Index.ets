import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { animation_default } from '../hosts/bunch_of_defaults';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { bunch_of_key_shortcuts } from '../hosts/bunch_of_key_shortcuts';
import { meowPx2vp } from '../utils/environment_tools';
import { drop_to_scratching_board } from '../utils/drag_drop_tools';
import lazy { print_web } from '../utils/print_tools';
import lazy { bunch_of_settings } from '../hosts/bunch_of_settings';
import linysProgress from '../components/linysProgress';
import meowTabsVertical from '../blocks/modules/meowTabsVertical';
import meowTitleBar from '../blocks/modules/meowTitleBar';
import lazy meowBookmarks from '../blocks/modules/meowBookmarks';
import lazy meowWebView from '../blocks/modules/meowWebView';
import lazy woofPromptFail from '../dialogs/prompts/woofPromptFail';
import {
  change_window_alias,
  current_tabs_style_is_horizontal,
  enter_free_window_mode,
  enter_traditional_window_mode,
  is_some_dialogs_opened,
  last_storage,
  new_window,
  pin_to_top,
  run_time,
  storage_of_id,
  update_window_decor_height,
  window_index_of_id,
  window_index_of_windowClass
} from '../utils/ui_tools';
import linysText from '../components/texts/linysText';
import linysWindowButton from '../components/buttons/linysWindowButton';
import { cancel_in_page_search, is_current_in_page_searching } from '../processes/tabs_actions';
import woofHistory from '../dialogs/managers/woofHistory';
import { bookmarks } from '../processes/init_process';
import { init_passkey } from '../utils/passkey_tools';

// @Entry({ useSharedStorage: true })
@Entry(last_storage())
@Component
struct Index {
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('my_windowClass') my_windowClass: window.Window | undefined = undefined;
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  @StorageLink('showing_my_window_alias') @Watch('on_showing_my_window_alias_change') showing_my_window_alias: boolean = false;
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  /**
   * UI Environment */
  @StorageLink('free_window_mode') @Watch('on_free_window_mode_change') free_window_mode: boolean = false;
  @LocalStorageLink('windowDecorWidth') windowDecorWidth: number = 0;
  @LocalStorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 1;
  @LocalStorageLink('topAvoidHeight') topAvoidHeight: number = 1;
  @LocalStorageLink('leftAvoidWidth') leftAvoidWidth: number = 1;
  @LocalStorageLink('rightAvoidWidth') rightAvoidWidth: number = 1;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('compact_mode') compact_mode: boolean = false; // Like PuraX
  @LocalStorageLink('screen_width') screen_width: number = 0;
  @LocalStorageLink('screen_height') screen_height: number = 0;
  @LocalStorageProp('pin_to_top') pin_to_top: boolean = false;
  @LocalStorageLink('full_screen_height') full_screen_height: number = 0;
  @LocalStorageLink('fullscreen_mode') @Watch('on_fullscreen_switch') fullscreen_mode: boolean = false;
  @StorageLink('currentColorMode') @Watch('on_color_mode_change') current_color_mode: number = 0;
  /**
   * UI Statuses */
  @LocalStorageLink('fullscreen_handler') handler: FullScreenExitHandler | null = null;
  @LocalStorageLink('showing_downloads') showing_downloads: boolean = false;
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  @LocalStorageLink('showing_app_settings') showing_app_settings: boolean = false;
  @LocalStorageLink('showing_tabs') @Watch('on_showing_tabs_change') showing_tabs: boolean = false;
  @LocalStorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @LocalStorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  /**
   * UI params */
  @State title_bar_height: number = 0;
  @State title_bar_alignRules: AlignRuleOption = {
    middle: { anchor: "__container__", align: HorizontalAlign.Center },
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
  };
  @StorageLink('bottom_avoid') bottom_avoid: boolean = true;
  /**
   * Delay */
  @LocalStorageLink('delayed_load_p0') delayed_load_p0: boolean = false;
  delay_p0: number = 30;
  @LocalStorageLink('delayed_load_p1') delayed_load_p1: boolean = false;
  delay_p1: number = 20;
  @LocalStorageLink('delayed_load_p2') delayed_load_p2: boolean = false;
  delay_p2: number = 30;
  /**
   * Web Statuses */
  @LocalStorageLink('current_loading_progress') current_loading_progress: number = 0;
  @LocalStorageLink('current_is_loading') current_is_loading: boolean = true;
  /**
   * Settings */
  @StorageLink('title_bar_position') @Watch('on_title_bar_position_change') title_bar_position: string = "";
  @StorageLink('sys_back_to_access_backward') sys_back_to_access_backward: boolean = false;
  @StorageLink('tabs_style') tabs_style: string = "";
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  /**
   * Settings - Accessibility */
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_tabs_panel') preferred_hand_reverse_tabs_panel: boolean = false;
  /**
   * Gateways */
  @LocalStorageLink('universal_close_tab_gateway') uni_close_tab_gateway: number = -1;
  @LocalStorageLink('universal_new_tab_gateway') uni_new_tab_gateway: string = "";
  /**
   * Dialogs */
  @LocalStorageLink('universal_fail_prompt_desc_gateway') @Watch('on_fail_prompt_gateway') universal_fail_prompt_desc_gateway: ResourceStr = "";
  @State fail_prompt_desc: ResourceStr = '';
  moveFailPrompt_control: CustomDialogController = new CustomDialogController({
    builder: woofPromptFail({
      desc: this.fail_prompt_desc,
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    // showInSubWindow: true,
    width: "90%",
  });
  woofHistory_control: CustomDialogController = new CustomDialogController({
    builder: woofHistory({
      full_view: this.compact_mode
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
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

    // Determine tablet mode and other window data.
    await window.getLastWindow(this.getUIContext().getHostContext()).then((w: window.Window) => {

      const my_index = window_index_of_windowClass(w);
      let log = [
        ' ',
        '[Meow][Index]',
        '    window.Window #' + my_index,
        '    my_window_id from this.storage: ' + this.storage.get('my_window_id'),
        '    my_window_id from @LocalStorageLink: ' + this.my_window_id,
        '    bunch_of_tabs.my_id: ' + this.bunch_of_tabs.my_id,
        '    alias: ' + this.my_window_alias,
        ' '
      ].join('\n');
      console.log(log);

      try {
        const rect: window.Rect = w.getWindowProperties().windowRect;
        this.tablet_mode = meowPx2vp(rect.width) > 600;
        this.compact_mode = meowPx2vp(rect.height) < 400;
      } catch (error) {
        // Leave tablet_mode there to be negative
        this.tablet_mode = false;
        this.compact_mode = false;
      }

      // Set window title
      change_window_alias(this.my_window_id, this.my_window_alias);
    });

    // Init title bar
    this.on_title_bar_position_change();

    // Init color
    this.on_color_change();

    update_window_decor_height(this.my_window_id);

    console.log(`[Meow][Index] Load Index! (${run_time(this.storage)} ms)`);

    // Init Auth
    init_passkey(this.getUIContext());

    setTimeout(async () => {
      let time_on_bookmarks = 0;
      try {
        time_on_bookmarks = await bookmarks(this.storage);
      } catch (e) {
        console.error('[Meow][Index] INIT bookmarks failed: ' + e);
      }
      let justified_delay_p0 = Math.max(this.delay_p0 - time_on_bookmarks, 0);

      // Trigger delayed load
      setTimeout(() => {
        this.delayed_load_p0 = true;
        console.log(`[Meow][Index] Delay P0! (${run_time(this.storage)} ms)`);
        setTimeout(() => {
          this.delayed_load_p1 = true;
          console.log(`[Meow][Index] Delay P1! (${run_time(this.storage)} ms)`);
          setTimeout(() => {
            this.delayed_load_p2 = true;
            console.log(`[Meow][Index] Delay P2! (${run_time(this.storage)} ms)`);
          }, this.delay_p2);
        }, this.delay_p1);
      }, justified_delay_p0);

      // Reopen tabs panel
      // this.bunch_of_settings.get('status_tabs_open').then((status_tabs_open) => {
      //   AppStorage.setOrCreate('showing_tabs', status_tabs_open as boolean);
      // })
    }, 10) // Delayed loading
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
          if (is_some_dialogs_opened(this.storage)) {
            return;
          }
          print_web(this.bunch_of_tabs.workingMainTab().controller, this.getUIContext().getHostContext()!);
        })
        .keyboardShortcut(this.bunch_of_key_shortcuts.new_window.main_key, this.bunch_of_key_shortcuts.new_window.modifier, () => {
          this.create_new_window();
        })
        .keyboardShortcut(this.bunch_of_key_shortcuts.pin_to_top.main_key, this.bunch_of_key_shortcuts.pin_to_top.modifier, () => {
          pin_to_top(this.my_window_id);
        })
        .keyboardShortcut(this.bunch_of_key_shortcuts.history.main_key, this.bunch_of_key_shortcuts.history.modifier, () => {
          if (is_some_dialogs_opened(this.storage)) {
            return;
          }
          this.woofHistory_control.open();
        })
        .keyboardShortcut(FunctionKey.ESC, [], () => {
          try {
            this.universal_esc();
          } catch (e) {
            console.error('[ESC] Failed! ' + e);
          }
        })

      RelativeContainer() {
        WindowTitle()
          .padding(this.tablet_mode ? { right: 20, bottom: 5 } : undefined)
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: !this.tablet_mode ? { anchor: '__container__', align: HorizontalAlign.End } : { anchor: 'window_controls', align: HorizontalAlign.Start }
          })
          .animation(animation_default())

        if (this.free_window_mode) {
          Row({ space: 10 }) {
            linysWindowButton({
              symbol: this.pin_to_top ? $r('sys.symbol.pin_vertical_fill') : $r('sys.symbol.pin'),
              execution: () => {
                pin_to_top(this.my_window_id);
              }
            })

            linysWindowButton({
              symbol: $r('sys.symbol.plus'),
              execution: () => {
                this.create_new_window();
              }
            })

          } // Window control buttons
          .id('window_controls')
          .padding({ top: this.showing_my_window_alias ? 9 : 5, right: Math.max(15, this.windowDecorWidth) - 15 })
          .alignRules({ top: { anchor: '__container__', align: VerticalAlign.Top }, right: { anchor: '__container__', align: HorizontalAlign.End } })
        }
      } // Top Bar Avoid (Title)
      .padding({
        left: 15,
        right: 15
      })
      .height(this.height_of_top_avoid())
      .clip(true)
      .backgroundColor(this.color_current_secondary)
      .animation(animation_default())
      .width('100%')
      .onDrop((e) => {
        try {
          let drop_ok = drop_to_scratching_board(e, this.storage);
          if (!drop_ok) {
            this.showing_scratching_board = false;
          }
        } catch (e) {
          console.error('[onDrop] Failed: ' + e);
        }
      })
      .onDragEnter(() => {
        this.showing_scratching_board = true;
        this.showing_more_options = false;
      })
      .onDragLeave(() => {
        this.showing_scratching_board = false;
      })

      // Scroll() {
      //   Column() {
      RelativeContainer() {
        Row() {
          Row() {
            if (this.delayed_load_p0) {
              meowTabsVertical()
                .width(this.showing_tabs ? this.width_of_Tabs() : 0)
                .padding((this.showing_tabs && !current_tabs_style_is_horizontal(this.storage)) ? 10 : 0)
                .animation(animation_default())
            }
            if (this.delayed_load_p1) {
              meowBookmarks()
                .padding(this.showing_bookmarks ? 10 : 0)
                .height("100%")
                .width(this.showing_bookmarks ? this.width_of_Bookmarks() : 0)
                .animation(animation_default())
            }
          }
          .width(this.width_of_Bookmarks_and_Tabs())
          .margin(this.margin_of_Bookmarks_and_Tabs())
          .animation(animation_default())
          .height("100%")

          if (this.delayed_load_p1) {
            meowWebView()
              .width("100%")
              .backgroundColor(this.color_current_primary)
              .layoutWeight(this.tablet_mode ? 1 : 0)
          } // WebViews

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
          .animation(animation_default())

        meowTitleBar({
          bar_height: this.title_bar_height,
          title_bar_alignRules: this.title_bar_alignRules,
        }) // Title Bar
      } // Web, progress, and Title bar
      .layoutWeight(1)
      .animation(animation_default())

      Row()// Bottom Bar Avoid
        .height((this.title_bar_position == "bottom" || this.bottom_avoid) ? this.height_of_bottom_avoid() : 0)
        .backgroundColor(this.title_bar_position == "bottom" ? "transparent" : this.color_current_secondary)
        .animation(animation_default())
        .width("100%")

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
    this.compact_mode = this.screen_height < 400;

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
    // TODO: Implement error handling.
    window.getLastWindow(this.getUIContext().getHostContext()).then((win) => {
      if (this.fullscreen_mode) {
        // win.maximize().catch(() => {
        // });
        win.setWindowSystemBarEnable([]).catch(() => {
        });
        try {
          win.setWindowTitleButtonVisible(false, false, false);
        } catch (e) {
        }
      } else {
        // win.recover().catch(() => {
        // });
        win.setWindowSystemBarEnable(["status", "navigation"]).catch(() => {
        });
        try {
          win.setWindowTitleButtonVisible(true, true, true);
        } catch (e) {
        }
      }
    })
  }

  on_showing_my_window_alias_change() {
    update_window_decor_height(this.my_window_id);
  }

  on_free_window_mode_change() {
    if (this.free_window_mode) {
      console.log('\t[free][@Watch] Trying to enter Free-window mode. [' + this.my_window_id + ']');
      enter_free_window_mode(this.my_windowClass!, this.storage, this.my_window_id);
    } else {
      console.log('\t[free][@Watch] Trying to enter Traditional mode. [' + this.my_window_id + ']');
      enter_traditional_window_mode(this.my_windowClass!, this.storage, this.my_window_id);
    }
  }

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
    let tablet_mode_compensation = 0;
    if (!this.tablet_mode && this.showing_my_window_alias) {
      tablet_mode_compensation = 28;
    }
    return this.topAvoidHeight + tablet_mode_compensation;
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
  back(isESC: boolean = false) {
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

    let esc_to_access_backward = AppStorage.get('esc_to_access_backward') as boolean;

    // Other returns
    // Only triggers if no closable UI panels are opened
    if (this.sys_back_to_access_backward && (esc_to_access_backward || !isESC)) {
      if (this.go_back_tab()) {
        stop_system_back = true;
      } else if (this.bunch_of_tabs.get_tabs_count() > 1) {
        // Can close something
        this.uni_close_tab_gateway = this.bunch_of_tabs.main_tab_idx;
        stop_system_back = true;
      }
    }

    return stop_system_back;
  }

  go_back_tab(): boolean {
    return this.bunch_of_tabs.goBackward_onWorkingTab();
  }

  /**
   * Creates a new window of given alias.
   * @param alias The alias.
   * */
  create_new_window(alias: string = this.my_window_alias) {
    new_window(this.getUIContext().getHostContext() as common.UIAbilityContext, Date.now().toString(), alias);
  }

  /**
   * What happens if esc key is pressed.
   * */
  universal_esc() {
    let opened_dialog_controllers = this.storage.get('opened_dialog_controllers') as CustomDialogController[];

    // Close the top most dialog
    if (opened_dialog_controllers && opened_dialog_controllers.length > 0) {
      opened_dialog_controllers[opened_dialog_controllers.length-1].close();
      console.log('[universal_esc] Exit a dialog!');
      return;
    }

    // Exit in-page searching
    if (is_current_in_page_searching(this.storage)) {
      cancel_in_page_search(this.storage);
      console.log('[universal_esc] Exit In-page searching!');
      return;
    }

    // Exit typing
    if (this.storage.get('is_search_input_typing') as boolean) {
      this.getUIContext().getFocusController().clearFocus();
      this.storage.set('is_search_input_typing', false);
      console.log('[universal_esc] Exit Typing!');
      return;
    }

    // Inheritance (?) from the universal back function.
    this.back(true);
    console.log('[universal_esc] UNIVERSAL BACK!!');
  }
}

@Component
struct WindowTitle {
  // Environment
  @StorageLink('free_window_mode') free_window_mode: boolean = false;
  @StorageLink('windowIds') @Watch('on_windowIDs_change') windowIds: string[] = [];
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  @LocalStorageLink('screen_width') screen_width: number = 0;
  // Statuses
  @StorageLink('showing_my_window_alias') showing_my_window_alias: boolean = false;
  @StorageLink('my_window_alias_position') my_window_alias_position: string = "center";
  @LocalStorageLink('current_title') current_title: string = "=￣ω￣=";

  build() {
    Row({ space: 10 }) {
      linysText({
        text: '#' + this.windowIds.indexOf(this.my_window_id) + '｜' + this.current_title + '｜' + this.my_window_alias
      })
        .constraintSize(this.free_window_mode ? undefined : { maxWidth: this.screen_width * 0.7 })
    }
    .width('100%')
    .padding({
      top: 8,
      bottom: 8,
    })
    .justifyContent(this.justifyContents_of_alias())
    .visibility(this.showing_my_window_alias ? Visibility.Visible : Visibility.Hidden)
    .animation(animation_default())
    .opacity(0.7)
  }

  justifyContents_of_alias() {
    if (this.my_window_alias_position == 'left') {
      return FlexAlign.Start;
    }
    if (this.my_window_alias_position == 'right') {
      return FlexAlign.End;
    }
    return FlexAlign.Center;
  }

  on_windowIDs_change() {
    if (window_index_of_id(this.my_window_id) == 0) {
      bunch_of_settings.set('my_window_alias_last', this.my_window_alias);
      AppStorage.set('LAST_WINDOW_WINDOW_NAME', this.my_window_alias);
    }
  }
}