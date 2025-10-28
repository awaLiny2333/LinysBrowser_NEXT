import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { extract_search, unify_search_input_into_url, url_resource_to_meow } from '../../utils/url_tools';
import {
  animation_default,
  animation_popup_duration,
  capsule_bar_height,
  click_effect_default,
  fontSize_Icon_Button,
  fontSize_Large,
  fontSize_Normal
} from '../../hosts/bunch_of_defaults';
import { webview } from '@kit.ArkWeb';
import { bunch_of_bookmarks } from '../../hosts/bunch_of_bookmarks';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import { bunch_of_downloads } from '../../hosts/bunch_of_downloads';
import { drop_to_scratching_board } from '../../utils/drag_drop_tools';
import { current_tabs_style_is_horizontal, is_some_dialogs_opened, run_time, storage_of_id } from '../../utils/ui_tools';
import { search_engine } from '../../hosts/bunch_of_search_engines';
import lazy { add_transparency } from '../../utils/color_tools';
import lazy { copy } from '../../utils/clipboard_tools';
import lazy { share_link } from '../../utils/link_tools';
import linysText from '../../components/texts/linysText';
import linysSymbol from '../../components/texts/linysSymbol';
import linysShowButton from '../../components/buttons/linysShowButton';
import meowMoreOptions from './meowMoreOptions';
import lazy meowSuggestions from './meowSuggestions';
import lazy meowTabsHorizontal from './meowTabsHorizontal';
import lazy meowScratchingBoard from './meowScratchingBoard';
import lazy meowAppSettings from './meowAppSettings';
import lazy meowDownloads from './meowDownloads';
import lazy woofQuickSE from '../../dialogs/quicks/woofQuickSE';

@Component
struct meowTitleBar {
  @StorageLink('windowIds') windowIds: string[] = [];
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // Hosts
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @StorageLink('bunch_of_downloads') bunch_of_downloads: bunch_of_downloads = new bunch_of_downloads(true);
  // Environments
  @LocalStorageLink('fullscreen_mode') fullscreen_mode: boolean = false;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('compact_mode') compact_mode: boolean = false; // Like PuraX
  @LocalStorageProp('screen_width') screen_width: number = 0;
  @LocalStorageProp('screen_height') screen_height: number = 0;
  @LocalStorageLink('full_screen_height') full_screen_height: number = 0;
  @Link bar_height: number;
  @LocalStorageLink('leftAvoidWidth') leftAvoidWidth: number = 1;
  @LocalStorageLink('rightAvoidWidth') rightAvoidWidth: number = 1;
  // Current environment
  @Link title_bar_alignRules: AlignRuleOption;
  @State search_input_unified: string = "";
  @LocalStorageLink('search_input') search_input: string = "ଘ*(੭*ˊᵕˋ)੭*";
  @LocalStorageLink('is_search_input_typing') is_search_input_typing: boolean = false;
  @LocalStorageLink('uni_webDownloadItem_gateway') @Watch('on_download_start') uni_webDownloadItem_gateway: webview.WebDownloadItem | undefined = undefined;
  @State download_started_popup: boolean = false;
  @LocalStorageLink('drop_result_strings') drop_result_string: string[] = [];
  @LocalStorageLink('current_in_page_searching_stats_total') current_in_page_searching_stats_total: number = 0;
  // Search analyze
  @LocalStorageLink('search_extracted_keyword') search_extracted_keyword: string = '';
  @State search_extracted_engine: string = '';
  @State showing_search_extracted_field: boolean = false;
  @State search_extracted_field_available: boolean = false;
  @State is_search_input_address: boolean = false;
  @State search_input_unify_scheme_http: boolean = true;
  // Web statuses
  @LocalStorageLink('tab_titles') tab_titles: string[] = [];
  @LocalStorageLink('current_title') current_title: string = "=￣ω￣=";
  @LocalStorageLink('tab_urls') tab_urls: string[] = [];
  @LocalStorageLink('current_url') @Watch('on_current_url_change') current_url: string = "=￣ω￣=";
  @LocalStorageLink('tab_match_domains') tab_match_domains: string[][] = [];
  // @LocalStorageLink('current_match_domain') current_match_domain: string[] = ['scheme', 'domain'];
  @LocalStorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0];
  @LocalStorageLink('current_loading_progress') current_loading_progress: number = 0;
  @LocalStorageLink('tab_is_loading') tab_is_loading: boolean[] = [true];
  @LocalStorageLink('current_is_loading') current_is_loading: boolean = true;
  // UI control actions
  @StorageLink('showing_tabs') showing_tabs_global: boolean = false;
  @LocalStorageLink('showing_tabs') showing_tabs: boolean = false;
  @LocalStorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  @LocalStorageLink('showing_app_settings') showing_app_settings: boolean = false;
  @LocalStorageLink('showing_downloads') showing_downloads: boolean = false;
  @LocalStorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  @State address_analyzers_desc_showing: boolean = false;
  address_analyzers_desc_close_cd_timeout_id: number | undefined = undefined;
  @State horizontal_tabs_height: number = 120;
  @LocalStorageLink('delayed_load_p0') delayed_load_p0: boolean = false;
  @LocalStorageLink('delayed_load_p1') delayed_load_p1: boolean = false;
  @LocalStorageLink('delayed_load_p2') delayed_load_p2: boolean = false;
  // settings
  @StorageLink('title_bar_position') title_bar_position: string = "";
  @StorageLink('tabs_style') tabs_style: string = "";
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Dialogs
  quick_keyword: string = '';
  quick_se: search_engine | undefined = undefined;
  woofQuickSE_control: CustomDialogController = new CustomDialogController({
    builder: woofQuickSE({
      default_new_se: this.quick_se,
      keyword: this.quick_keyword
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  });
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 10 }) {
      if (this.title_bar_position == "bottom") {
        meowSuggestions({ top_margin: 5 })
      } // Suggestions

      if (this.delayed_load_p1) {
        Column() {
          if (this.tablet_mode && this.tabs_style == 'horizontal' || !this.tablet_mode && this.tabs_style_non_tablet_mode == 'horizontal') {
            meowTabsHorizontal()
          }
        }
        .onAreaChange((_o, n) => {
          this.horizontal_tabs_height = Math.max(0, n.height as number + 10);
        })
        .visibility(this.visibility_of_horizontal_tabs())
        .animation(animation_default())
      } // Horizontal tabs

      if (this.delayed_load_p0) {
        EstimatedDestination({
          is_http_no_s: this.search_input_unify_scheme_http,
          is_search_input_typing: this.is_search_input_typing,
          is_search_input_address: this.is_search_input_address,
          search_input: this.search_input,
          search_input_unified: this.search_input_unified,
        })
          .visibility(this.is_search_input_typing && this.title_bar_position == 'bottom' ? Visibility.Visible : Visibility.None)
          .padding({ left: 15, right: 15 })
          .width("100%")
          .animation(animation_default())
          .constraintSize({ minHeight: 20 })

        ThisPageInfo({
          current_title: this.current_title,
          current_url: this.current_url
        })
      } // Estimated Destination & This Page Info

      RelativeContainer() {
        Row({ space: this.tablet_mode ? 10 : 6 }) {
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.arrow_left'
          })// Backward
            .enabled(this.bunch_of_tabs.current_accessBackward)
            .opacity(this.bunch_of_tabs.current_accessBackward ? 1 : 0.5)
            .visibility(this.visible_when_no_panels_open_in_normal_mode())
            .animation(animation_default())
            .onClick(() => {
              this.go_backward();
            })

          linysSymbol({
            symbol_glyph_target: 'sys.symbol.arrow_right'
          })// Forward
            .enabled(this.bunch_of_tabs.current_accessForward)
            .opacity(this.bunch_of_tabs.current_accessForward ? 1 : 0.5)
            .visibility(this.visible_when_no_panels_open_in_normal_mode())
            .animation(animation_default())
            .onClick(() => {
              this.go_forward();
            })

          SymbolGlyph(!this.current_is_loading ? $r('sys.symbol.arrow_clockwise') : $r('sys.symbol.xmark')) // Refresh
            .fontSize(fontSize_Icon_Button())
            .fontColor([this.color_current_font])
            .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.current_is_loading)
            .visibility(this.visible_when_no_panels_open_in_normal_mode())
            .animation(animation_default())
            .keyboardShortcut(this.bunch_of_key_shortcuts.refresh.main_key, this.bunch_of_key_shortcuts.refresh.modifier)
            .onClick(() => {
              if (this.current_is_loading) {
                this.stop_page()
              } else {
                this.refresh_page()
              }
            })

          linysSymbol({
            symbol_glyph_target: 'sys.symbol.house'
          })// Home
            .visibility(this.visible_when_no_panels_open_in_normal_mode())
            .animation(animation_default())
            .onClick(() => {
              this.go_home()
            })

        } // Title Bar of left controls
        .height(36)
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          top: { anchor: '__container__', align: VerticalAlign.Top }
        })
        .animation(animation_default())
        .id('left_controls')

        Row({ space: 10 }) {
          Column() {
            TextInput({ text: this.search_input })
              .allowDrop(null)
              .visibility(this.showing_scratching_board ? Visibility.Hidden : Visibility.Visible)
              .height(!this.showing_search_extracted_field ? capsule_bar_height() : 0)
              .fontWeight(FontWeight.Regular)
              .fontColor(this.color_current_font)
              .caretColor(this.color_current_font)
              .selectedBackgroundColor(this.color_current_font)
              .translate({ y: !this.showing_search_extracted_field ? 0 : -50 })
              .opacity(!this.showing_search_extracted_field ? (this.showing_scratching_board ? 0.8 : 1) : 0)
              .animation(animation_default())
              .padding(!this.showing_search_extracted_field ? { left: 16, right: 16 } : {})
              .onDragEnter(() => {
                this.showing_scratching_board = false;
              })
              .onFocus(() => {
                this.is_search_input_typing = true;
              })
              .onBlur(() => {
                this.is_search_input_typing = false;
              })
              .enabled(this.showing_scratching_board ? false : true)
              .onChange((content) => {
                this.update_search_input(content);
              })
              .onSubmit(() => {
                this.submit_searching()
              })
              .selectAll(true)
              .id('address_bar')
              .keyboardShortcut(!this.showing_search_extracted_field ? this.bunch_of_key_shortcuts.focus_address.main_key : '',
                this.bunch_of_key_shortcuts.focus_address.modifier)

            TextInput({ text: this.search_extracted_keyword })
              .allowDrop(null)
              .visibility(this.showing_scratching_board ? Visibility.Hidden : Visibility.Visible)
              .height(this.showing_search_extracted_field ? capsule_bar_height() : 0)
              .fontWeight(FontWeight.Regular)
              .fontColor(this.color_current_font)
              .caretColor(this.color_current_font)
              .translate({ y: this.showing_search_extracted_field ? 0 : 50 })
              .opacity(this.showing_search_extracted_field ? (this.showing_scratching_board ? 0.8 : 1) : 0)
              .animation(animation_default())
              .padding(this.showing_search_extracted_field ? { left: 16, right: 16 } : {})
              .onDragEnter(() => {
                this.showing_scratching_board = false;
              })
              .onFocus(() => {
                this.is_search_input_typing = true;
              })
              .onBlur(() => {
                this.is_search_input_typing = false;
              })
              .enabled(this.showing_scratching_board ? false : true)
              .onChange((content) => {
                this.search_extracted_keyword = content;
                if (content == '') {
                  this.search_input_unified = this.search_extracted_engine.replaceAll('%s', "");
                } else {
                  this.search_input_unified = this.search_extracted_engine.replaceAll('%s', encodeURIComponent(content));
                }
                this.search_input = this.search_input_unified;
              })
              .onSubmit(() => {
                this.submit_searching();
                // After submit, as the web loads, the new link will be synced to the search_input (address bar)
                // Then it will trigger @Watch('on_search_input_change')
                // And the extracted keyword would be synced to its TextInput.
              })
              .selectAll(true)
              .selectedBackgroundColor(this.color_current_font)
              .id('key_bar')
              .keyboardShortcut(this.showing_search_extracted_field ? this.bunch_of_key_shortcuts.focus_address.main_key : '',
                this.bunch_of_key_shortcuts.focus_address.modifier)

          } // Two inputs
          .clip(true)
          .layoutWeight(1)

          linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_right' }) // Search
            .visibility(this.visible_when_typing())
            .onClick(() => {
              this.submit_searching()
            })
            .animation(animation_default())

          linysShowButton({
            symbol_glyph_target: this.showing_search_extracted_field ? 'sys.symbol.text_and_t' : 'sys.symbol.link',
            text: $r(this.showing_search_extracted_field ?
              'app.string.Address_analyzer_keyword' :
              'app.string.Address_analyzer_address'),
            show: this.address_analyzers_desc_showing,
          })// Key Link
            .visibility(this.showing_scratching_board ? Visibility.None : this.search_extracted_field_available ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.showing_search_extracted_field = !this.showing_search_extracted_field;
              if (this.is_search_input_typing) {
                // Switch focus
                if (this.showing_search_extracted_field) {
                  focusControl.requestFocus('key_bar');
                } else {
                  focusControl.requestFocus('address_bar');
                }
              }
              this.address_analyzers_desc_showing = true;
              clearTimeout(this.address_analyzers_desc_close_cd_timeout_id);
              this.address_analyzers_desc_close_cd_timeout_id = setTimeout(() => {
                this.address_analyzers_desc_showing = false;
                this.address_analyzers_desc_close_cd_timeout_id = undefined;
              }, 1200)
            })
            .animation(animation_default())

          linysSymbol({
            symbol_glyph_target: 'sys.symbol.magnifyingglass',
          })// Add Search Engine
            .enabled(this.showing_scratching_board ? false : true)
            .visibility((this.is_search_input_typing || this.search_extracted_field_available) && !this.showing_scratching_board
              ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              let extract: string[] = extract_search(this.search_input);
              let key = extract[1];
              let link = extract[0];
              if (key == '' && link == '') {
                this.quick_keyword = this.search_input;
                this.quick_se = undefined;
              } else {
                this.quick_keyword = this.search_extracted_keyword;
                // Set default add Search engine
                let label = this.current_title;
                label = label.replaceAll(key, '');
                label = label.replace(/ ?[_-] ?/g, '');
                this.quick_se = new search_engine(label, link);
              }
              this.woofQuickSE_control.open();
            })
            .animation(animation_default())

        } // Searching bar
        .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
        .height(capsule_bar_height())
        .padding(this.tablet_mode ? { left: 10, right: 10 } : {})
        .alignRules(this.tablet_mode ? {
          left: { anchor: 'left_controls', align: HorizontalAlign.End },
          right: { anchor: 'right_controls', align: HorizontalAlign.Start },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        } : { bottom: { anchor: '__container__', align: VerticalAlign.Bottom } })
        .animation(animation_default())

        Row({ space: this.tablet_mode ? 10 : 6 }) {
          linysShowButton({
            show: this.showing_scratching_board,
            text: $r('app.string.Index_drop_scratching_board'),
            symbol_glyph_target: this.showing_scratching_board ? 'sys.symbol.chevron_down' : 'sys.symbol.doc_rectify'
          })// Scratching board
            .visibility(this.drop_result_string.length > 0 ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.show_scratching_board();
            })

          linysShowButton({
            show: this.showing_more_options,
            text: $r('app.string.Index_more_title'),
            symbol_glyph_target: this.showing_more_options ? 'sys.symbol.chevron_down' : 'sys.symbol.dot_grid_2x2'
          })// More options
            .onClick(() => {
              this.show_more_options()
            })
            .opacity(this.delayed_load_p2 ? 1 : 0.5)
            .animation(animation_default())
            .enabled(this.delayed_load_p2)

          linysShowButton({
            symbol_glyph_target: 'sys.symbol.rectangle_stack',
            show: this.showing_tabs
          })// Tabs
            .onClick(() => {
              this.show_tabs();
            })
            .gesture(
              LongPressGesture({ repeat: false })
                .onAction(() => {
                  this.new_tab();
                }))
            .onMouse((e) => {
              if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
                // Right click
                this.new_tab();
              }
            })
            .keyboardShortcut(this.bunch_of_key_shortcuts.show_tabs.main_key, this.bunch_of_key_shortcuts.show_tabs.modifier)

          linysShowButton({
            show: this.showing_bookmarks,
            text: $r('app.string.Index_bookmarks_title'),
            symbol_glyph_target: 'sys.symbol.bookmark'
          })// Bookmarks
            .gesture(
              LongPressGesture({ repeat: false })
                .onAction(() => {
                  this.show_add_bookmarks();
                }))
            .onMouse((e) => {
              if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
                // Right click
                this.show_add_bookmarks();
              }
            })
            .onClick(() => {
              this.show_bookmarks();
            })
            .opacity(this.delayed_load_p1 ? 1 : 0.5)
            .animation(animation_default())
            .enabled(this.delayed_load_p1)

          Row() {
            linysShowButton({
              text: $r('app.string.Index_downloads_title'),
              symbol_glyph_target: this.showing_downloads ? 'sys.symbol.chevron_down' : 'sys.symbol.download',
              show: this.showing_downloads,
              color_false: !this.showing_downloads && this.download_started_popup ?
                this.color_current_primary : this.color_current_font
            })
            Text($r('app.string.Index_download_task_start'))
              .fontSize(fontSize_Large() - 2)
              .fontColor(this.color_current_primary)
              .margin({ right: this.showing_downloads ? 5 : 0 })
              .visibility(this.download_started_popup ? Visibility.Visible : Visibility.None)
              .animation(animation_default())
          } // Downloads
          .padding(!this.showing_downloads && this.download_started_popup ? 5 : 0)
          .backgroundColor(this.download_started_popup ? this.color_current_font : "transparent")
          .borderRadius(10)
          .clickEffect(click_effect_default())
          .opacity(this.delayed_load_p2 ? 1 : 0.5)
          .animation(animation_default())
          .onClick(() => {
            if (this.download_started_popup) {
              this.download_started_popup = false;
            } else {
              this.show_downloads();
            }
          })
          .enabled(this.delayed_load_p2)

          linysShowButton({
            show: this.showing_app_settings,
            text: $r('app.string.Index_app_settings_title'),
            symbol_glyph_target: this.showing_app_settings ? 'sys.symbol.chevron_down' : 'sys.symbol.gearshape'
          })// Settings
            .onClick(() => {
              this.show_app_settings()
            })
            .opacity(this.delayed_load_p2 ? 1 : 0.5)
            .animation(animation_default())
            .enabled(this.delayed_load_p2)

        } // Title Bar of right controls
        .height(36)
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End },
          top: { anchor: '__container__', align: VerticalAlign.Top }
        })
        .animation(animation_default())
        .id('right_controls')

      } // Button controls and search
      .padding({ left: 15, right: 15 })
      .width("100%")
      .height(this.tablet_mode || this.showing_scratching_board ? capsule_bar_height() : 2 * capsule_bar_height() + 10)
      .animation(animation_default())

      if (this.delayed_load_p0) {
        EstimatedDestination({
          is_http_no_s: this.search_input_unify_scheme_http,
          is_search_input_typing: this.is_search_input_typing,
          is_search_input_address: this.is_search_input_address,
          search_input: this.search_input,
          search_input_unified: this.search_input_unified
        })
          .visibility(this.is_search_input_typing && this.title_bar_position == 'top' ? Visibility.Visible : Visibility.None)
          .padding({ left: 15, right: 15 })
          .width("100%")
          .animation(animation_default())
          .constraintSize({ minHeight: 20 })
      } // Estimated Destination

      if (this.delayed_load_p2) {
        meowMoreOptions() // More Options

        meowAppSettings({ showing_app_settings: this.showing_app_settings })// Settings
          .visibility(this.showing_app_settings ? Visibility.Visible : Visibility.None)
          .layoutWeight(this.showing_app_settings ? 1 : undefined)
          .animation(animation_default())

        meowDownloads()
          .visibility(this.showing_downloads ? Visibility.Visible : Visibility.None)
          .layoutWeight(this.showing_downloads ? 1 : undefined)
          .animation(animation_default())

        meowScratchingBoard()
          .visibility(this.showing_scratching_board ? Visibility.Visible : Visibility.None)
          .layoutWeight(this.showing_scratching_board ? 1 : undefined)
          .animation(animation_default())
      } // All the panels

      if (this.title_bar_position == "top") {
        meowSuggestions({ bottom_margin: 5 })
      } // Suggestions

      if (this.title_bar_position == "bottom") {
        Row().height(5)
      } // Space
    } // Title Bars
    .clip(true)
    .onDrop((e) => {
      try {
        let drop_ok = drop_to_scratching_board(e, this.storage, false);
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
    .width("100%")
    .constraintSize({
      maxHeight: this.max_height_of_title_bar()
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(!this.showing_more_options || this.current_in_page_searching_stats_total <= 0
      ? this.color_current_secondary
      : add_transparency(this.color_current_secondary, 128))
    .alignRules(this.title_bar_alignRules)
    .padding({
      top: (this.title_bar_position == 'bottom' ? 10 : 0) + this.top_title_bar_spacing(),
      bottom: (this.title_bar_position == 'top' ? 10 : 0),
      left: this.leftAvoidWidth,
      right: this.rightAvoidWidth
    })
    .onAreaChange((_o, n) => {
      if (!this.showing_more_options && !this.is_search_input_typing && !this.showing_app_settings && !this.showing_downloads &&
        !this.showing_scratching_board) {
        this.bar_height = n.height as number;
      }
    })
    .offset({
      y: this.y_offset_title_bar()
    })
    .animation(animation_default())
    .onAppear(() => {
      // console.log("[Meow][meowTitleBar] Title Bar READY")
      // setInterval(() => {
      //   if (this.address_analyzers_desc_close_cd > 0) {
      //     this.address_analyzers_desc_close_cd -= 1000;
      //   }
      // }, 1000);
      console.log(`[Meow][meowTitleBar] onAppear! (${run_time(this.storage)} ms)`);
    })
    .keyboardShortcut(this.bunch_of_key_shortcuts.in_page_search.main_key, this.bunch_of_key_shortcuts.in_page_search.modifier, () => {
      this.on_search_in_page_key_shortcut();
    })
  }

  // Visibility


  visible_when_typing() {
    return this.is_search_input_typing ? Visibility.Visible : Visibility.None
  }

  visible_when_typing_not() {
    return !this.is_search_input_typing ? Visibility.Visible : Visibility.None
  }

  visible_when_title_bar_on_top() {
    return this.title_bar_position == "top" ? Visibility.Visible : Visibility.None;
  }

  visible_when_title_bar_on_bottom() {
    return this.title_bar_position == "bottom" ? Visibility.Visible : Visibility.None;
  }

  visible_when_no_panels_open_in_normal_mode() {
    let result: Visibility = Visibility.Visible;
    if (this.showing_more_options || this.showing_downloads || this.showing_app_settings || this.showing_tabs ||
    this.showing_bookmarks || this.download_started_popup || this.showing_scratching_board) {
      if (this.tablet_mode == false) {
        result = Visibility.None;
      }
    }
    return result;
  }

  visible_in_tablet_mode() {
    return this.tablet_mode ? Visibility.Visible : Visibility.None;
  }

  visible_when_typing_in_tablet_mode() {
    return this.tablet_mode && this.is_search_input_typing ? Visibility.Visible : Visibility.None;
  }

  visibility_of_horizontal_tabs() {
    if (!this.showing_tabs) {
      return Visibility.None;
    }

    if (this.tablet_mode) {
      if (this.tabs_style == "horizontal") {
        return Visibility.Visible;
      }
    } else {
      // Non tablet mode
      if (this.tabs_style_non_tablet_mode == "horizontal") {
        return Visibility.Visible;
      }
    }

    return Visibility.None
  }

  // Events

  on_download_start() {
    if (this.uni_webDownloadItem_gateway) {
      return;
    }

    // Show popup when gateway is set back to undefined.
    this.download_started_popup = true;
    setTimeout(() => {
      this.download_started_popup = false;
    }, animation_popup_duration())
  }

  on_current_url_change() {
    if (this.current_url) {
      let extract: string[] = extract_search(this.current_url);
      if (extract[1] == '' && extract[0] == '') {
        this.showing_search_extracted_field = false;
        this.search_extracted_field_available = false;
      } else {
        this.search_extracted_engine = extract[0];
        this.search_extracted_keyword = extract[1];
        this.showing_search_extracted_field = true;
        this.search_extracted_field_available = true;
      }
    }
  }

  on_search_in_page_key_shortcut() {
    if (is_some_dialogs_opened(this.storage)) {
      return;
    }
    this.showing_more_options = true;
    focusControl.requestFocus("in_page_search_blank");
  }

  // UI controls

  show_tabs() {
    if (!this.tablet_mode && this.tabs_style_non_tablet_mode == "vertical") {
      this.showing_more_options = false;
      this.showing_app_settings = false;
      this.showing_downloads = false;
      this.showing_scratching_board = false;
      // allow bookmarks and tabs coexist in tablet mode
      this.showing_bookmarks = false;
    }
    this.showing_tabs = !this.showing_tabs;
  }

  show_bookmarks() {
    if (!this.tablet_mode) {
      this.showing_more_options = false;
      this.showing_app_settings = false;
      this.showing_downloads = false;
      this.showing_scratching_board = false;
    }
    if (!this.tablet_mode) {
      // allow bookmarks and tabs coexist in tablet mode
      if (this.tabs_style_non_tablet_mode == "vertical") {
        this.showing_tabs = false;
      }
    }
    this.showing_bookmarks = !this.showing_bookmarks;
  }

  /**
   * Closes the Vertical Tabs and bookmarks panels if is not tablet mode.
   * */
  close_tabs_and_bookmarks_non_tablet() {
    if (!this.tablet_mode) {
      if (this.tabs_style_non_tablet_mode == "vertical") {
        this.showing_tabs = false;
      }
      this.showing_bookmarks = false;
    }
  }

  show_more_options() {
    this.close_tabs_and_bookmarks_non_tablet();

    // Close all other panels
    this.showing_scratching_board = false;
    this.showing_downloads = false;
    this.showing_app_settings = false;
    this.showing_more_options = !this.showing_more_options;
  }

  show_app_settings() {
    this.close_tabs_and_bookmarks_non_tablet();

    // Close all other panels
    this.showing_scratching_board = false;
    this.showing_downloads = false;
    this.showing_more_options = false;
    this.showing_app_settings = !this.showing_app_settings;
  }

  show_downloads() {
    this.close_tabs_and_bookmarks_non_tablet();

    // Close all other panels
    this.showing_scratching_board = false;
    this.showing_more_options = false;
    this.showing_app_settings = false;
    this.showing_downloads = !this.showing_downloads;
  }

  show_scratching_board() {
    this.close_tabs_and_bookmarks_non_tablet();

    // Close all other panels
    this.showing_more_options = false;
    this.showing_downloads = false;
    this.showing_app_settings = false;
    this.showing_scratching_board = !this.showing_scratching_board;
  }

  // Operations

  /**
   * Opens the bookmarks panel and prepare to add current page.
   * */
  show_add_bookmarks() {
    if (this.showing_bookmarks) {
      this.showing_bookmarks = false;
      this.storage.set('adding_bookmark', false);
    } else {
      // Add Bookmark
      this.storage.set('bookmark_add_label', this.bunch_of_tabs.workingMainTab().title);
      this.storage.set('bookmark_add_link', url_resource_to_meow(this.bunch_of_tabs.workingMainTab().url));
      this.showing_bookmarks = true;
      this.storage.set('adding_bookmark', true);
    }
  }

  new_tab() {
    this.storage.set('extra_background', false);
    this.storage.set('universal_new_tab_gateway', "new_tab");
  }

  // Web control events

  submit_searching() {
    if (this.search_input_unified != "") {
      try {
        this.bunch_of_tabs.loadUrl_onWorkingTab(this.search_input_unified);
      } catch (e) {
        console.error('[Meow][meowTitleBar][submit_searching][loadUrl_onWorkingTab] ' + e + '\n\t' + this.search_input_unified);
      }
    }
    // Flip link field if needed
    if (!this.is_search_input_address) {
      this.showing_search_extracted_field = true;
    }
  }

  go_backward() {
    this.bunch_of_tabs.goBackward_onWorkingTab();
  }

  go_forward() {
    this.bunch_of_tabs.goForward_onWorkingTab();
  }

  go_home() {
    this.bunch_of_tabs.go_home_onWorkingTab();
  }

  refresh_page() {
    this.bunch_of_tabs.refresh_onWorkingTab();
    this.bunch_of_tabs.workingMainTab().update_is_loading(true);
    this.tab_is_loading[this.bunch_of_tabs.main_tab_idx] = true;
  }

  stop_page() {
    this.bunch_of_tabs.stop_onWorkingTab();
    this.bunch_of_tabs.workingMainTab().update_is_loading(false);
    // Simply directly set the element in list in LocalStorage to false, instead of sync_tabs_list_info(this.storage) to reduce computation and performance lost.
    this.tab_is_loading[this.bunch_of_tabs.main_tab_idx] = false;
    // sync_tabs_list_info(this.storage);
  }

  // Values

  max_height_of_title_bar() {
    // TODO: Clean up the logics here
    if (this.showing_more_options && this.current_in_page_searching_stats_total > 0) {
      // in-page Searching
      let base_height = this.tablet_mode ? 110 : 190;
      let tabs_offset = this.showing_tabs && current_tabs_style_is_horizontal(this.storage) ? this.horizontal_tabs_height : 0;
      let position_offset = this.title_bar_position == 'top' ? 0 : 15;
      return base_height + tabs_offset + position_offset;
    } else {
      // Normal height
      if (this.showing_more_options) {
        return Math.min(this.full_screen_height, (this.tablet_mode ? 400 : 460));
      }
      if (this.full_screen_height < 400) {
        return this.full_screen_height
      }
      return this.full_screen_height * 0.75;
    }
  }

  y_offset_title_bar() {
    // Normal case, no fullscreen mode.
    if (!this.fullscreen_mode) {
      return 0;
    }
    // Called something in fullscreen mode.
    let direction = (this.title_bar_position == 'bottom' ? 1 : -1);
    if (this.need_full_screen_extent_area()) {
      return 0;
    }
    return direction * 1.1 * this.bar_height;
  }

  top_title_bar_spacing() {
    if (this.title_bar_position == 'top' && this.fullscreen_mode && (this.need_full_screen_extent_area())) {
      return 10;
    }
    // Normal case, no fullscreen mode.
    return 0;
  }

  need_full_screen_extent_area() {
    return this.is_search_input_typing || this.showing_more_options || this.showing_app_settings || this.showing_downloads || this.showing_scratching_board;
  }

  // Data synchronizing

  update_search_input(content?: string) {
    if (content) {
      this.search_input = content;
    } else {
      this.search_input = "";
    }
    let s: string = content || "¯\\_(ツ)_/¯";
    let uni_result = unify_search_input_into_url(s, this.search_input_unify_scheme_http ? "http" : "https");
    this.search_input_unified = uni_result[0] as string;
    this.is_search_input_address = uni_result[1] as boolean;
    this.search_input_unified = url_resource_to_meow(this.search_input_unified);
  }
}

export default meowTitleBar;

@Component
struct EstimatedDestination {
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Data
  @Link is_http_no_s: boolean;
  @Link is_search_input_typing: boolean;
  @Link is_search_input_address: boolean;
  @Link search_input: string;
  @Link search_input_unified: string;

  build() {
    Row({ space: 10 }) {
      Row({ space: 5 }) {
        linysSymbol({
          symbol_glyph_target: this.is_http_no_s ? "sys.symbol.lock_open" : "sys.symbol.lock"
        })
        linysText({
          text: this.is_http_no_s ? "http" : "https"
        })
      } // Https icon
      .padding(8)
      .onClick(() => {
        this.is_http_no_s = !this.is_http_no_s;
        this.update_search_input_unified(this.search_input);
      })
      .borderRadius(8)
      .backgroundColor(this.color_current_primary)
      .visibility(this.visible_when_input_is_a_scheme_less_address())
      .clickEffect(click_effect_default())
      .animation(animation_default())

      Text("→ " + (this.search_input_unified == "" ? "(　o=^•ェ•)o ?" : this.search_input_unified))
        .fontColor(this.color_current_font)
        .fontWeight(FontWeight.Bold)
        .fontSize(fontSize_Normal())
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      linysSymbol({
        symbol_glyph_target: 'sys.symbol.chevron_up'
      })
        .onClick(() => {
          // Clear focus
          this.getUIContext().getFocusController().clearFocus();
        })
    } // Title Bar for estimated destination indication
  }

  visible_when_typing() {
    return this.is_search_input_typing ? Visibility.Visible : Visibility.None
  }

  is_input_scheme_less_address() {
    if (!this.search_input || this.search_input.includes("://")) {
      return false;
    }
    return this.is_search_input_address ? true : false;
  }

  visible_when_input_is_a_scheme_less_address() {
    return this.is_input_scheme_less_address() ? Visibility.Visible : Visibility.None;
  }

  // Data

  update_search_input_unified(content?: string) {
    let s: string = content || "¯\\_(ツ)_/¯";
    let uni_result = unify_search_input_into_url(s, this.is_http_no_s ? "http" : "https");
    this.search_input_unified = uni_result[0] as string;
    this.is_search_input_address = uni_result[1] as boolean;
  }
}

@Component
struct ThisPageInfo {
  @Prop current_title: string;
  @Prop current_url: string;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // UI
  @LocalStorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  @LocalStorageLink('current_in_page_searching_stats_total') current_in_page_searching_stats_total: number = 0;

  build() {
    Row({ space: 15 }) {
      Column({ space: 2.5 }) {
        Text(this.current_title)
          .fontColor(this.color_current_font)
          .fontWeight(FontWeight.Bold)
          .fontSize(fontSize_Large())
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .clickEffect(click_effect_default())
          .onClick(() => {
            copy(this.current_title);
          })
        Text(this.current_url)
          .fontColor(this.color_current_font)
          .fontWeight(FontWeight.Bold)
          .fontSize(fontSize_Normal())
          .opacity(0.7)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .clickEffect(click_effect_default())
          .onClick(() => {
            copy(this.current_url);
          })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      linysSymbol({ symbol_glyph_target: 'sys.symbol.share' })
        .onClick(() => {
          share_link(this.current_url, this.current_title, this.getUIContext().getHostContext()!);
        })
    } // Title Bar for This Page Info display
    .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
    .visibility(this.current_in_page_searching_stats_total <= 0 && this.showing_more_options && !this.showing_scratching_board
      ? Visibility.Visible : Visibility.None)
    .animation(animation_default())
    .padding({ left: 15, right: 15, top: 6 })
    .width("100%")
  }
}