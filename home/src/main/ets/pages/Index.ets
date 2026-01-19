import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { animation_default, default_new_window_name } from '../hosts/bunch_of_defaults';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { bunch_of_key_shortcuts } from '../hosts/bunch_of_key_shortcuts';
import lazy { print_web } from '../utils/print_tools';
import lazy { bunch_of_settings } from '../hosts/bunch_of_settings';
import lazy {
  current_tabs_style_is_horizontal,
  enter_free_window_mode,
  enter_traditional_window_mode,
  is_some_dialogs_opened,
  new_window,
  pin_to_top,
  update_window_decor_height,
  window_index_of_id,
} from '../utils/ui_tools';
import { change_window_alias, last_storage, run_time, storage_of_id } from '../utils/ui_tools';
import lazy { off_zone, set_zone } from '../processes/zone_actions';
import lazy { cancel_in_page_search, is_current_in_page_searching } from '../processes/tabs_actions';
import lazy { webview } from '@kit.ArkWeb';
import lazy meowTabsVertical from '../blocks/modules/meowTabsVertical';
import lazy meowTitleBar from '../blocks/modules/meowTitleBar';
import lazy meowBookmarks from '../blocks/modules/meowBookmarks';
import lazy meowWebView from '../blocks/modules/meowWebView';
import lazy woofPromptFail from '../dialogs/prompts/woofPromptFail';
import lazy woofHistory from '../dialogs/managers/woofHistory';
import lazy woofZones from '../dialogs/contents/woofZones';
import meowShortcuts from '../blocks/modules/meowShortcuts';
import linysProgress from '../components/linysProgress';
import linysWindowButton from '../components/buttons/linysWindowButton';
import linysText from '../components/texts/linysText';
import meowTabsHost from '../blocks/modules/meowTabsHost';
import meowExtensionView from '../blocks/modules/meowExtensionView';

// @Entry({ useSharedStorage: true })
@Entry(last_storage())
@Component
struct Index {
  @StorageLink('showing_large_my_window_alias') showing_large_my_window_alias: boolean = false;
  @LocalStorageLink('is_zone') @Watch('on_is_zone_changed') is_zone: boolean = false;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @LocalStorageLink('my_windowClass') my_windowClass: window.Window | undefined = undefined;
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  @StorageLink('showing_my_window_alias') @Watch('on_showing_my_window_alias_change') showing_my_window_alias: boolean = false;
  @StorageLink('showing_my_window_alias_non_tablet') @Watch('on_showing_my_window_alias_change') showing_my_window_alias_non_tablet: boolean = false;
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  /**
   * UI Environment */
  @StorageLink('DEV_MODE') DEV_MODE: boolean = false;
  @StorageLink('free_window_mode') @Watch('on_free_window_mode_change') free_window_mode: boolean = false;
  @StorageLink('preferred_hand_auto') preferred_hand_auto: boolean = false;
  @LocalStorageLink('on_focus') on_focus: boolean = true;
  @LocalStorageLink('windowDecorWidth') windowDecorWidth: number = 0;
  @LocalStorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 1;
  @LocalStorageLink('topAvoidHeight') topAvoidHeight: number = 1;
  @LocalStorageLink('leftAvoidWidth') leftAvoidWidth: number = 1;
  @LocalStorageLink('rightAvoidWidth') rightAvoidWidth: number = 1;
  @LocalStorageLink('tablet_mode') @Watch('on_showing_my_window_alias_change') tablet_mode: boolean = false;
  @LocalStorageLink('compact_mode') compact_mode: boolean = false; // Like PuraX
  woofHistory_control: CustomDialogController = new CustomDialogController({
    builder: woofHistory({
      full_view: this.compact_mode
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    width: "90%",
  });
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
   * Web Statuses*/
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  /**
   * UI params */
  @StorageLink('effects') @Watch('on_effects_change') effects: boolean = false;
  @State title_bar_height: number = 0;
  @State title_bar_alignRules: AlignRuleOption = {
    middle: { anchor: "__container__", align: HorizontalAlign.Center },
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
  };
  @StorageLink('bottom_avoid') bottom_avoid: boolean = true;
  @LocalStorageLink('shortcut_scroll_offset') shortcut_scroll_offset: number = 0;
  @StorageLink('homepage_background') homepage_background: PixelMap | undefined = undefined;
  @State is_Hov_watermark: boolean = false;
  @LocalStorageLink('is_Hov_vertical_tabs') is_Hov_vertical_tabs: boolean = false;
  /**
   * Delay */
  @LocalStorageLink('delayed_load_p0') delayed_load_p0: boolean = false;
  delay_p0: number = 30;
  @LocalStorageLink('delayed_load_p1') delayed_load_p1: boolean = false;
  delay_p1: number = 30;
  @LocalStorageLink('delayed_load_p2') delayed_load_p2: boolean = false;
  delay_p2: number = 30;
  @LocalStorageLink('delayed_load_p3') delayed_load_p3: boolean = false;
  delay_p3: number = 30;
  @LocalStorageLink('index_init_ok') index_init_ok: boolean = false;
  /**
   * Web Statuses */
  @LocalStorageLink('dl_delegate') dl_delegate: webview.WebDownloadDelegate = new webview.WebDownloadDelegate();
  @LocalStorageLink('current_loading_progress') current_loading_progress: number = 0;
  @LocalStorageLink('current_is_loading') current_is_loading: boolean = true;
  /**
   * Settings */
  @StorageLink('title_bar_position') @Watch('on_title_bar_position_change') title_bar_position: string = "";
  @StorageLink('sys_back_to_access_backward') sys_back_to_access_backward: boolean = false;
  @StorageLink('tabs_style') tabs_style: string = "";
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  @StorageLink('tabs_vertical_auto_hide') tabs_vertical_auto_hide: boolean = false;
  /**
   * Settings - Accessibility */
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_tabs_panel') preferred_hand_reverse_tabs_panel: boolean = false;
  /**
   * Gateways */
  @LocalStorageLink('universal_close_tab_gateway') uni_close_tab_gateway: number = -1;
  @LocalStorageLink('universal_new_tab_gateway') uni_new_tab_gateway: (string | boolean)[] = ['', false];
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
  Zones_control: CustomDialogController = new CustomDialogController({
    builder: woofZones(),
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
  @StorageLink('color_current_back') color_current_back: ResourceColor = $r('app.color.font_color_title');

  aboutToAppear(): void {
    // console.log(`[Meow][Index] aboutToLoad Index! (${run_time(this.storage)} ms)`);

    // Init title bar
    this.on_title_bar_position_change();

    // Init color
    this.on_color_change();

    console.log(`[Meow][Index] Finished Loading Index! (${run_time(this.storage)} ms)`);
  }

  onBackPress(): boolean {
    return this.back();
  }

  build() {
    Stack() {
      Column() {
        // I know this is stupid
        // Forgive me
        // O.o
        if (this.delay_p0) {
          // Keyboard shortcuts
          Row() {
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.fullscreen.main_key, this.bunch_of_key_shortcuts.fullscreen.modifier, () => {
              this.fullscreen_mode = !this.fullscreen_mode;
              this.showing_more_options = false;
            })
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.print.main_key, this.bunch_of_key_shortcuts.print.modifier, () => {
              if (is_some_dialogs_opened(this.storage)) {
                return;
              }
              if (this.bunch_of_tabs.workingMainTab().controller) {
                print_web(this.bunch_of_tabs.workingMainTab().controller!, this.getUIContext().getHostContext()!);
              }
            })
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.new_window.main_key, this.bunch_of_key_shortcuts.new_window.modifier, () => {
              this.create_new_window();
            })
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.pin_to_top.main_key, this.bunch_of_key_shortcuts.pin_to_top.modifier, () => {
              pin_to_top(this.my_window_id);
            })
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.history.main_key, this.bunch_of_key_shortcuts.history.modifier, () => {
              if (is_some_dialogs_opened(this.storage)) {
                return;
              }
              this.woofHistory_control.open();
            })
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.save_page.main_key, this.bunch_of_key_shortcuts.save_page.modifier, () => {
              this.bunch_of_tabs.archive_onWorkingTab(this.getUIContext().getHostContext()?.tempDir);
            })
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.in_page_search.main_key, this.bunch_of_key_shortcuts.in_page_search.modifier, () => {
              this.universal_find();
            })
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.focus_address.main_key, this.bunch_of_key_shortcuts.focus_address.modifier, () => {
              this.universal_focus_address();
            })
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.view_zones.main_key, this.bunch_of_key_shortcuts.view_zones.modifier, () => {
              if (is_some_dialogs_opened(this.storage)) {
                return;
              }
              this.Zones_control.open();
            })
            Row().keyboardShortcut(this.bunch_of_key_shortcuts.close_tab.main_key, this.bunch_of_key_shortcuts.close_tab.modifier, () => {
              this.storage.set('universal_close_tab_gateway', this.bunch_of_tabs.main_tab_idx);
            })
            Row().keyboardShortcut(FunctionKey.ESC, [], () => {
              try {
                this.universal_esc();
              } catch (e) {
                console.error('[ESC] Failed! ' + e);
              }
            })
            Row().keyboardShortcut(FunctionKey.DPAD_UP, [], () => {
              this.in_page_search_last();
            })
            Row().keyboardShortcut(FunctionKey.DPAD_DOWN, [], () => {
              this.in_page_search_next();
            })
          }.height(0)
        }

        RelativeContainer() {
          if (this.free_window_mode) {
            Row({ space: 10 }) {
              linysWindowButton({
                symbol: $r('sys.symbol.square_stack_3d'),
                execution: () => {
                  this.Zones_control.open();
                }
              })
            } // Window control buttons
            .id('window_controls_left')
            .padding({ top: this.showing_my_window_alias_summarized() ? 9 : 5, left: 5 })
            .alignRules({ top: { anchor: '__container__', align: VerticalAlign.Top }, left: { anchor: '__container__', align: HorizontalAlign.Start } })
          }

          WindowTitle()
            .padding(this.tablet_mode ? { right: 20, left: 20, bottom: 5 } : undefined)
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              left: !this.tablet_mode ? { anchor: '__container__', align: HorizontalAlign.Start } : { anchor: 'window_controls_left', align: HorizontalAlign.End },
              right: !this.tablet_mode ? { anchor: '__container__', align: HorizontalAlign.End } : { anchor: 'window_controls_right', align: HorizontalAlign.Start }
            })
            .visibility(this.showing_my_window_alias_summarized() ? Visibility.Visible : Visibility.Hidden)
            .animation(this.delayed_load_p3 ? animation_default() : { duration: 0 })

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
            .id('window_controls_right')
            .padding({ top: this.showing_my_window_alias_summarized() ? 9 : 5, right: Math.max(15, this.windowDecorWidth) - 15 })
            .alignRules({ top: { anchor: '__container__', align: VerticalAlign.Top }, right: { anchor: '__container__', align: HorizontalAlign.End } })
          }
        } // Top Bar Avoid (Title)
        // .backgroundColor(this.background_color())
        .height(this.height_of_top_avoid())
        .animation(this.delayed_load_p3 ? animation_default() : { duration: 0 })
        .padding({
          left: 15,
          right: 15
        })
        .clip(true)
        .width('100%')

        // Scroll() {
        //   Column() {
        RelativeContainer() {
          Row() {
            if (this.delayed_load_p3) {
              meowBookmarks()
                .width(this.showing_bookmarks && !this.fullscreen_mode ? undefined : 0)
                .animation(animation_default())
                .clip(true)
            }

            if (this.delayed_load_p0) {
              Row() {
                meowTabsVertical()
              }
              .margin({
                bottom: 10,
                // right: !this.is_right_align() && this.is_shrunk() ? 5 : 0,
                // left: this.is_right_align() && this.is_shrunk() ? 5 : 0,
              })
              .borderRadius(10)
              .width(this.showing_vertical_tabs() && !this.fullscreen_mode ? (!this.is_shrunk() ? undefined : 45) : 0)
              .animation(animation_default())
              .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
              .clip(true)
              .onHover((h) => {
                this.is_Hov_vertical_tabs = h;
              })
            }

            Stack() {
              if (this.delayed_load_p0) {
                meowTabsHost()
              }

              if (this.homepage_background) {
                Image(this.homepage_background)
                  .opacity(Math.max(1 - this.shortcut_scroll_offset / this.screen_height, 0.5))
                  .visibility(this.visibility_of_background_image())
              } // Background

              if (this.delayed_load_p1) {
                meowWebView()
              } // WebViews

              // if (this.delayed_load_p0) {
              meowShortcuts()
              // }

              // Extensions Web
              if (this.delayed_load_p1 && this.DEV_MODE) {
                meowExtensionView()
              }
            }
            .clip(true)
            .margin(this.web_margin())
            .borderRadius(this.effects && !this.fullscreen_mode ? 10 : 0)
            .animation(this.delayed_load_p3 ? animation_default() : { duration: 0 })
            .backgroundColor(this.color_current_primary)
            .layoutWeight(this.tablet_mode ? 1 : 0)

          } // Main Web
          .padding(this.main_web_padding())
          .backgroundColor(this.effects ? undefined : this.color_current_primary)
          .useEffect(this.effects, EffectType.WINDOW_EFFECT)
          .direction(this.direction_of_web_and_side_panels())
          .margin(this.title_bar_position == "bottom"
            ? { bottom: this.fullscreen_mode ? 0 : this.title_bar_height }
            : { top: this.fullscreen_mode ? 0 : this.title_bar_height })
          .animation(this.delayed_load_p3 ? animation_default() : { duration: 0 })
          .width("100%")

          if (this.index_init_ok) {
            linysProgress({ percentage: this.current_loading_progress, is_loading: this.current_is_loading })
              .alignRules(this.title_bar_alignRules)
              .margin(this.title_bar_position == "bottom"
                ? { bottom: this.fullscreen_mode ? 0 : this.title_bar_height }
                : { top: this.fullscreen_mode ? 0 : this.title_bar_height })
              .animation(this.delayed_load_p3 ? animation_default() : { duration: 0 })

            meowTitleBar({
              bar_height: this.title_bar_height,
              title_bar_alignRules: this.title_bar_alignRules,
            })
          } // Title Bar
        } // Web, progress, and Title bar
        .onAreaChange((o, n) => {
          this.on_main_area_change(o, n);
        })
        .layoutWeight(1)
        .animation(this.delayed_load_p3 ? animation_default() : { duration: 0 })

        Row()// Bottom Bar Avoid
          .height((this.title_bar_position == "bottom" || this.bottom_avoid) ? this.height_of_bottom_avoid() : 0)
          .animation(this.delayed_load_p3 ? animation_default() : { duration: 0 })
          .width("100%")

      }
      .height("100%")
      .width("100%")
      .alignItems(HorizontalAlign.Start)

      if (this.showing_large_my_window_alias) {
        Text(this.my_window_alias)
          .fontSize(0.12 * this.screen_width)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.color_current_font)
          .hitTestBehavior(HitTestMode.Transparent)
          .opacity(this.on_focus || this.is_Hov_watermark ? 0 : 0.5)
          .animation(animation_default())
          .textAlign(TextAlign.Center)
          .height("100%")
          .width("100%")
          .onHover((h) => {
            this.is_Hov_watermark = h;
          })
      }
    }
    .alignContent(Alignment.Center)
    .backgroundColor(this.background_color())
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
    .animation(this.delayed_load_p3 ? animation_default() : { duration: 0 })
    .onAreaChange((_o, n) => {
      this.full_screen_height = n.height as number;
    })
    .onAppear(() => {
      // Set window title
      change_window_alias(this.my_window_id, this.my_window_alias);

      // Determine window decor height
      update_window_decor_height(this.my_window_id);

      this.delayed_loading();
    })
  }

  delayed_loading() {
    setTimeout(() => {
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
            setTimeout(() => {
              this.delayed_load_p3 = true;
              console.log(`[Meow][Index] Delay P3! (${run_time(this.storage)} ms)`);
            }, this.delay_p3);
          }, this.delay_p2);
        }, this.delay_p1);
      }, this.delay_p0);
      this.index_init_ok = true;
    }, 1) // Delayed loading
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
    console.log(`[Index][on_main_area_change] screen_width: ${this.screen_width}, screen_height: ${this.screen_height}`);
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

  refresh_colors() {
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
    this.color_current_back = this.color_current_font;
    if (this.effects) {
      this.color_current_primary = $r('sys.color.comp_background_tertiary');
      this.color_current_secondary = $r('sys.color.comp_background_tertiary');
      this.color_current_back = $r('sys.color.comp_background_tertiary');
    }
  }

  on_color_mode_change() {
    if (this.effects) {
      if (this.current_color_mode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        this.color_current_font = this.color_dark_font;
      } else {
        this.color_current_font = this.color_light_font;
      }
      return;
    }
    this.refresh_colors();
  }

  on_color_change() {
    console.log('[Meow][Index] Color theme changed!');
    // Refresh current color
    this.refresh_colors();
  }

  on_effects_change() {
    this.refresh_colors();
  }

  /**
   * Hides and shows system UI components.
   * */
  on_fullscreen_switch() {
    window.getLastWindow(this.getUIContext().getHostContext()).then((win) => {
      if (this.fullscreen_mode) {
        console.info(`[on_fullscreen_switch] FULLSCREEN ON!`);
        if (this.free_window_mode) {
          win.maximize().catch((e: BusinessError) => {
            console.error(`[on_fullscreen_switch][maximize] Failed: ${e}`);
          });
        }
        win.enableLandscapeMultiWindow().catch((e: BusinessError) => {
          console.error(`[on_fullscreen_switch][enableLandscapeMultiWindow] Failed: ${e}`);
        });
        win.setWindowSystemBarEnable([]).catch((e: BusinessError) => {
          console.error(`[on_fullscreen_switch][setWindowSystemBarEnable] Failed: ${e}`);
        });
        try {
          win.setWindowTitleButtonVisible(false, false, false);
        } catch (e) {
          console.error(`[on_fullscreen_switch][setWindowTitleButtonVisible] Failed: ${e}`);
        }
      } else {
        console.info(`[on_fullscreen_switch] FULLSCREEN OFF! `);
        win.recover().catch((e: BusinessError) => {
          console.error(`[on_fullscreen_switch][recover] Failed: ${e}`);
        });
        win.disableLandscapeMultiWindow().catch((e: BusinessError) => {
          console.error(`[on_fullscreen_switch][enableLandscapeMultiWindow] Failed: ${e}`);
        });
        win.setWindowSystemBarEnable(["status", "navigation"]).catch((e: BusinessError) => {
          console.error(`[on_fullscreen_switch][setWindowSystemBarEnable] Failed: ${e}`);
        });
        try {
          win.setWindowTitleButtonVisible(true, true, true);
        } catch (e) {
          console.error(`[on_fullscreen_switch][setWindowTitleButtonVisible] Failed: ${e}`);
        }
      }
    })
  }

  showing_my_window_alias_summarized() {
    if (this.tablet_mode) {
      return this.showing_my_window_alias;
    } else {
      return this.showing_my_window_alias_non_tablet;
    }
  }

  /**
   * Updates the window decor height.
   * */
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

  on_is_zone_changed() {
    if (this.is_zone) {
      console.log(`[zone_actions] SET ZONE!`);
      set_zone(this.my_window_id);
    } else {
      console.log(`[zone_actions] OFF ZONE!`);
      off_zone(this.my_window_id);
    }
  }

  // kinda params

  showing_vertical_tabs() {
    if (!this.showing_tabs) {
      return false;
    }

    if (this.tablet_mode && this.tabs_style == 'vertical') {
      return true;
    } else if (!this.tablet_mode && this.tabs_style_non_tablet_mode == 'vertical') {
      return true;
    }
    return false;
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

  height_of_top_avoid() {
    if (this.fullscreen_mode) {
      return 0;
    }
    let tablet_mode_compensation = 0;
    if (!this.tablet_mode && this.showing_my_window_alias_summarized()) {
      tablet_mode_compensation = 28;
    }
    return this.topAvoidHeight + tablet_mode_compensation;
  }

  direction_of_web_and_side_panels() {
    let status = this.preferred_hand_left_or_right == 'right';
    if (this.preferred_hand_reverse_tabs_panel) {
      status = !status;
    }
    return status ? Direction.Rtl : Direction.Ltr;
  }

  visibility_of_background_image() {
    let vis = true;
    const pre_init = this.current_url == '=￣ω￣=' || this.current_url == undefined;
    const on_home = this.current_url == 'meow://home' && this.bunch_of_tabs.sub_tab_idx == -1;
    if (!(pre_init || on_home)) {
      vis = false;
    }
    return vis ? Visibility.Visible : Visibility.Hidden;
  }

  web_margin() {
    if (this.fullscreen_mode) {
      return 0;
    }

    const is_vertical = !current_tabs_style_is_horizontal(this.storage);
    const reverse_multiplier = this.preferred_hand_reverse_tabs_panel && this.is_shrunk() && is_vertical ? 2 : 1;
    const showing_vertical_tabs = this.showing_tabs && is_vertical;

    let bottom = this.effects ? 10 : 0;

    // Showing vertical tab in traditional view
    if (!this.effects && showing_vertical_tabs) {
      if (this.is_right_align()) {
        return { right: 5 * reverse_multiplier, bottom: bottom } as Padding;
      } else {
        return { left: 5 * reverse_multiplier, bottom: bottom } as Padding;
      }
    }

    let lr = (this.effects ? 5 : 0) * reverse_multiplier;
    return { left: lr, right: lr, bottom: bottom } as Padding;
  }

  main_web_padding() {
    if (this.fullscreen_mode) {
      return 0;
    }

    let showing_vertical_tabs = this.showing_tabs && !current_tabs_style_is_horizontal(this.storage);
    let has_side_bars = showing_vertical_tabs || this.showing_bookmarks;
    console.log(`[main_web_padding] has_side_bars=${has_side_bars}`);
    if (!has_side_bars) {
      if (this.effects) {
        return { left: 5, right: 5 } as Padding;
      } else {
        return 0;
      }
    }

    if (this.showing_bookmarks) {
      if (this.effects) {
        return { left: 5, right: 5 } as Padding;
      } else {
        // To compensate the padding of the bookmark panel.
        if (this.is_right_align()) {
          return { right: 5 } as Padding;
        } else {
          return { left: 5 } as Padding;
        }
      }
    }

    // showing tabs
    if (this.effects) {
      if (this.is_right_align()) {
        return { left: 5 } as Padding;
      } else {
        return { right: 5 } as Padding;
      }
    } else {
      return 0;
    }
  }

  is_right_align() {
    return (this.preferred_hand_left_or_right == 'right' && !this.preferred_hand_reverse_tabs_panel) ||
      (!(this.preferred_hand_left_or_right == 'right') && this.preferred_hand_reverse_tabs_panel);
  }

  title_background_color(): ResourceColor | undefined {
    if (this.effects) {
      return undefined;
    }
    return this.color_current_secondary;
  }

  background_color(): ResourceColor {
    if (this.effects) {
      return $r('sys.color.background_tertiary');
    }
    return this.color_current_secondary;
  }

  is_shrunk() {
    return !this.is_Hov_vertical_tabs && this.tablet_mode && this.tabs_vertical_auto_hide;
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
    let zones = AppStorage.get('zones') as string[];
    if (zones.includes(alias)) {
      alias = default_new_window_name();
    }
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
    if (this.showing_more_options && (this.storage.get('current_in_page_searching_keyword') as string != '')) {
      cancel_in_page_search(this.storage);
      console.log('[universal_esc] Cleared In-page search key!');
      return;
    }
    if (this.storage.get('is_search_in_page_focused')) {
      this.getUIContext().getFocusController().clearFocus();
      console.log('[universal_esc] Exit focus from In-page search input!');
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

  /**
   * Technically executed everytime the key shortcut in_page_search is triggered. (Ctrl + F by default)
   * */
  universal_find() {
    if (is_some_dialogs_opened(this.storage)) {
      return;
    }
    // In page search
    this.storage.set('showing_more_options', true);
    focusControl.requestFocus("in_page_search_blank");
  }

  /**
   * Triggered each time when key shortcut focus_address is pressed. (Alt + D by default)
   * */
  universal_focus_address() {
    if (is_some_dialogs_opened(this.storage)) {
      return;
    }
    if (this.storage.get('showing_search_extracted_field') as boolean) {
      focusControl.requestFocus('key_bar');
    } else {
      focusControl.requestFocus('address_bar');
    }
  }

  // Web

  in_page_search_last() {
    try {
      this.bunch_of_tabs.workingMainTab().controller!.searchNext(false);
    } catch (e) {
      console.error('[in_page_search_last] Failed: ' + e);
    }
  }

  in_page_search_next() {
    try {
      this.bunch_of_tabs.workingMainTab().controller!.searchNext(true);
    } catch (e) {
      console.error('[in_page_search_last] Failed: ' + e);
    }
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
  @LocalStorageLink('is_zone') is_zone: boolean = false;
  // Statuses
  @StorageLink('my_window_alias_position') my_window_alias_position: string = "center";
  @LocalStorageLink('current_title') current_title: string = "=￣ω￣=";

  build() {
    Row({ space: 10 }) {
      linysText({
        text: '#' + this.windowIds.indexOf(this.my_window_id) + '｜' + this.current_title + '｜' + (this.is_zone ? '󰙟 ' : '') + this.my_window_alias
      })
        .constraintSize(this.free_window_mode ? undefined : { maxWidth: this.screen_width * 0.7 })
    }
    .justifyContent(this.justifyContents_of_alias())
    .animation(animation_default())
    .width('100%')
    .padding({
      top: 8,
      bottom: 8,
    })
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
      if (!this.is_zone) {
        bunch_of_settings.set('my_window_alias_last', this.my_window_alias);
      }
    }
  }
}