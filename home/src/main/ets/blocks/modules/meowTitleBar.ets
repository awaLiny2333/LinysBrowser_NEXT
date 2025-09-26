import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { extract_search, match_domain, unify_search_input_into_url, url_resource_to_meow } from '../../utils/url_tools';
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
import { bunch_of_user_agents } from '../../hosts/bunch_of_user_agents';
import { bunch_of_bookmarks } from '../../hosts/bunch_of_bookmarks';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import { bunch_of_downloads } from '../../hosts/bunch_of_downloads';
import { allow_drop_types, drop_to_scratching_board } from '../../utils/drag_drop_tools';
import { current_tabs_style_is_horizontal } from '../../utils/ui_tools';
import { search_engine } from '../../hosts/bunch_of_search_engines';
import lazy { add_transparency } from '../../utils/color_tools';
import lazy { copy } from '../../utils/clipboard_tools';
import lazy { print_web } from '../../utils/print_tools';
import lazy { share_link } from '../../utils/share_tools';
import linysText from '../../components/texts/linysText';
import linysProgressInfo from '../../components/linysProgressInfo';
import linysSymbol from '../../components/texts/linysSymbol';
import linysShowButton from '../../components/buttons/linysShowButton';
import lazy meowSuggestions from './meowSuggestions';
import lazy meowTabsHorizontal from './meowTabsHorizontal';
import lazy meowScratchingBoard from './meowScratchingBoard';
import lazy meowAppSettings from './meowAppSettings';
import lazy meowDownloads from './meowDownloads';
import lazy meowDebug from '../panels/meowDebug';
import lazy woofQR from '../../dialogs/contents/woofQR';
import lazy woofHistory from '../../dialogs/managers/woofHistory';
import lazy woofAdsBlocker from '../../dialogs/managers/woofAdsBlocker';
import lazy woofQuickSE from '../../dialogs/quicks/woofQuickSE';
import lazy woofCookies from '../../dialogs/managers/woofCookies';
import lazy woofQuickUA from '../../dialogs/quicks/woofQuickUA';
import lazy woofGeneralManage from '../../dialogs/managers/woofGeneralManage';

@Component
struct meowTitleBar {
  // Hosts
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @StorageLink('bunch_of_downloads') bunch_of_downloads: bunch_of_downloads = new bunch_of_downloads(true);
  // Environments
  @StorageLink('fullscreen_mode') fullscreen_mode: boolean = false;
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('screen_width') screen_width: number = 0;
  @StorageProp('screen_height') screen_height: number = 0;
  @StorageLink('full_screen_height') full_screen_height: number = 0;
  @Link bar_height: number;
  @StorageLink('leftAvoidWidth') leftAvoidWidth: number = 1;
  @StorageLink('rightAvoidWidth') rightAvoidWidth: number = 1;
  @StorageProp('reindexing_history_progress') reindexing_history_progress: string = "";
  @StorageProp('history_index_loading_progress') history_index_loading_progress: string = "";
  @StorageProp('history_index_saving_progress') history_index_saving_progress: string = "";
  // Current environment
  @Link title_bar_alignRules: AlignRuleOption;
  @State search_input_unified: string = "";
  @StorageLink('search_input') search_input: string = "*(੭*ˊᵕˋ)੭*ଘ";
  @StorageLink('is_search_input_typing') is_search_input_typing: boolean = false;
  @StorageLink('uni_webDownloadItem_gateway') @Watch('on_download_start') uni_webDownloadItem_gateway: webview.WebDownloadItem | undefined = undefined;
  @State download_started_popup: boolean = false;
  @StorageLink('drop_result_strings') drop_result_string: string[] = [];
  @StorageLink('current_in_page_searching_keyword') current_in_page_searching_keyword: string = "";
  @StorageLink('current_in_page_searching_stats_current') current_in_page_searching_stats_current: number = 0;
  @StorageLink('current_in_page_searching_stats_total') current_in_page_searching_stats_total: number = 0;
  // Search analyze
  @StorageLink('search_extracted_keyword') search_extracted_keyword: string = '';
  @State search_extracted_engine: string = '';
  @State showing_search_extracted_field: boolean = false;
  @State search_extracted_field_available: boolean = false;
  @State is_search_input_address: boolean = false;
  @State search_input_unify_scheme_http: boolean = true;
  // Web statuses
  @StorageLink('tab_titles') tab_titles: string[] = []
  @StorageLink('current_title') current_title: string = "=￣ω￣=";
  @StorageLink('tab_urls') tab_urls: string[] = []
  @StorageLink('current_url') @Watch('on_current_url_change') current_url: string = "=￣ω￣=";
  @StorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0]
  @StorageLink('current_loading_progress') current_loading_progress: number = 0
  @StorageLink('tab_is_loading') tab_is_loading: boolean[] = [true]
  @StorageLink('current_is_loading') current_is_loading: boolean = true
  // Web control statuses
  @StorageLink('current_main_tab_index') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') current_sub_tab_index: number = -1;
  @StorageLink('current_accessForward') current_accessForward: boolean = false;
  @StorageLink('current_accessBackward') current_accessBackward: boolean = false;
  // UI control actions
  @StorageLink('showing_tabs') showing_tabs: boolean = false;
  @StorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @StorageLink('showing_more_options') showing_more_options: boolean = false;
  @StorageLink('showing_app_settings') showing_app_settings: boolean = false;
  @StorageLink('showing_downloads') showing_downloads: boolean = false;
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  @State address_analyzers_desc_close_cd: number = 0;
  @State horizontal_tabs_height: number = 120;
  @StorageLink('delayed_load_p0') delayed_load_p0: boolean = false;
  @StorageLink('delayed_load_p1') delayed_load_p1: boolean = false;
  @StorageLink('delayed_load_p2') delayed_load_p2: boolean = false;
  // settings
  @StorageLink('DEV_MODE') DEV_MODE: boolean = false;
  @StorageLink('resource_monitor') resource_monitor: boolean = true;
  @StorageLink('disable_js') disable_js: boolean = true;
  @StorageLink('disable_js_these_sites') disable_js_these_sites: string[] = [];
  @StorageLink('disable_js_all_sites') disable_js_all_sites: boolean = false;
  @StorageLink('disable_image') disable_image: boolean = true;
  @StorageLink('disable_image_these_sites') disable_image_these_sites: string[] = [];
  @StorageLink('disable_image_all_sites') disable_image_all_sites: boolean = false;
  @StorageProp('title_bar_position') title_bar_position: string = "";
  @StorageLink('tabs_style') tabs_style: string = "";
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  @StorageLink('max_bookmark_advice') max_bookmark_advice: number = 5;
  @StorageLink('max_history_advice') max_history_advice: number = 5;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Dialogs
  woofQR_control: CustomDialogController = new CustomDialogController({
    builder: woofQR({
      title: this.current_title,
      link: this.current_url
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  });
  woofQuickUA_control: CustomDialogController = new CustomDialogController({
    builder: woofQuickUA(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  });
  woofHistory_control: CustomDialogController = new CustomDialogController({
    builder: woofHistory({ showing_settings: this.showing_app_settings }),
    alignment: DialogAlignment.Center,
    cornerRadius: 22,
    // showInSubWindow: true,
    width: "90%",
  });
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
  woofAdsBlocker_control: CustomDialogController = new CustomDialogController({
    builder: woofAdsBlocker({
      add_exception_domain_edit: match_domain(this.search_input)[1],
      showing_add_panel: true
    }),
    // showInSubWindow: true,
    width: "90%",
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  });
  cookies_control: CustomDialogController = new CustomDialogController({
    builder: woofCookies(),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // showInSubWindow: true,
    width: "90%",
  });
  js_manage_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.disable_js,
      general_sites_list: this.disable_js_these_sites,
      general_on_all_sites_switch: this.disable_js_all_sites,
      add_site_edit: match_domain(this.search_input)[1],
      showing_add_panel: true
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // showInSubWindow: true,
    width: "90%",
  });
  image_manage_control: CustomDialogController = new CustomDialogController({
    builder: woofGeneralManage({
      general_switch: this.disable_image,
      general_sites_list: this.disable_image_these_sites,
      general_on_all_sites_switch: this.disable_image_all_sites,
      add_site_edit: match_domain(this.search_input)[1],
      showing_add_panel: true,
      general_descriptions: [
        $r('app.string.Settings_image_desc_1'),
        $r('app.string.Settings_image_desc_2'),
        $r('app.string.Settings_image_desc_3')],
      general_tips: $r('app.string.Settings_image_already_disabled'),
      general_title: $r('app.string.Settings_image_manage'),
      general_switch_desc: $r('app.string.Settings_image_disable_image'),
      general_subtitle_execute_on_these_sites: $r('app.string.Settings_image_some_sites'),
      general_subtitle_execute_on_all_sites: $r('app.string.Settings_image_all_sites'),
      general_switch_settings_id: 'disable_image',
      general_sites_list_settings_id: 'disable_image_these_sites',
      general_switch_all_sites_settings_id: 'disable_image_all_sites',
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16,
    // showInSubWindow: true,
    width: "90%",
  });
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 10 }) {
      // if (this.title_bar_position == "top") {
      //   Row().height(0)
      // }

      if (this.title_bar_position == "bottom" && this.delayed_load_p0) {
        meowSuggestions({ top_margin: 15 })
          .animation(animation_default())
      }

      if (this.delayed_load_p1) {
        meowTabsHorizontal() // Horizontal tabs
          .visibility(this.visibility_of_horizontal_tabs())
          .animation(animation_default())
          .onAreaChange((_oo, n) => {
            this.horizontal_tabs_height = Math.max(0, n.height as number + 10);
          })
      }

      if (this.delayed_load_p0) {
        EstimatedDestination({
          is_http_no_s: this.search_input_unify_scheme_http,
          is_search_input_typing: this.is_search_input_typing,
          is_search_input_address: this.is_search_input_address,
          search_input: this.search_input,
          search_input_unified: this.search_input_unified
        })
          .visibility(this.is_search_input_typing && this.title_bar_position == 'bottom' ? Visibility.Visible : Visibility.None)
          .padding({ left: 15, right: 15 })
          .width("100%")
          .animation(animation_default())
          .constraintSize({ minHeight: 20 })

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
              share_link(this.current_url, this.current_title);
            })
        } // Title Bar for This Page Info display
        .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
        .padding({ left: 15, right: 15, top: 6 })
        .width("100%")
        .visibility(this.current_in_page_searching_stats_total <= 0 && this.showing_more_options && !this.showing_scratching_board
          ? Visibility.Visible : Visibility.None)
        .animation(animation_default())
      }

      RelativeContainer() {
        Row({ space: this.tablet_mode ? 10 : 6 }) {
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.arrow_left'
          })// Backward
            .enabled(this.current_accessBackward)
            .opacity(this.current_accessBackward ? 1 : 0.5)
            .visibility(this.visible_when_no_panels_open_in_normal_mode())
            .animation(animation_default())
            .onClick(() => {
              this.go_backward();
            })

          linysSymbol({
            symbol_glyph_target: 'sys.symbol.arrow_right'
          })// Forward
            .enabled(this.current_accessForward)
            .opacity(this.current_accessForward ? 1 : 0.5)
            .visibility(this.visible_when_no_panels_open_in_normal_mode())
            .animation(animation_default())
            .onClick(() => {
              this.go_forward();
            })

          SymbolGlyph(!this.current_is_loading ? $r('sys.symbol.arrow_clockwise') : $r('sys.symbol.xmark'))
            .fontSize(fontSize_Icon_Button())
            .fontColor([this.color_current_font])
            .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.current_is_loading)
            .visibility(this.visible_when_no_panels_open_in_normal_mode())
            .animation(animation_default())
            .onClick(() => {
              if (this.current_is_loading) {
                this.stop_page()
              } else {
                this.refresh_page()
              }
            })
            .keyboardShortcut(this.bunch_of_key_shortcuts.refresh.main_key, this.bunch_of_key_shortcuts.refresh.modifier)

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
          RelativeContainer() {
            Scroll() {
              TextInput({ text: this.search_input })
                .allowDrop(null)
                .visibility(this.showing_scratching_board ? Visibility.Hidden : Visibility.Visible)
                .height(capsule_bar_height())
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .selectedBackgroundColor(this.color_current_font)
                .offset({ y: !this.showing_search_extracted_field ? 0 : -50 })
                .opacity(!this.showing_search_extracted_field ? (this.showing_scratching_board ? 0.8 : 1) : 0)
                .animation(animation_default())
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
            } // URL
            .scrollable(ScrollDirection.Vertical)
            .height(this.showing_search_extracted_field ? 0 : 36)
            .scrollBar(BarState.Off)
            .animation(animation_default())

            Scroll() {
              TextInput({ text: this.search_extracted_keyword })
                .allowDrop(null)
                .visibility(this.showing_scratching_board ? Visibility.Hidden : Visibility.Visible)
                .height(capsule_bar_height())
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .offset({ y: this.showing_search_extracted_field ? 0 : 50 })
                .opacity(this.showing_search_extracted_field ? (this.showing_scratching_board ? 0.8 : 1) : 0)
                .animation(animation_default())
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
                  // After submit, as the web loads, the new url will be synced to the search_input (address bar)
                  // Then it will trigger @Watch('on_search_input_change')
                  // And the extracted keyword would be synced to its TextInput.
                })
                .selectAll(true)
                .selectedBackgroundColor(this.color_current_font)
                .id('key_bar')
                .keyboardShortcut(this.showing_search_extracted_field ? this.bunch_of_key_shortcuts.focus_address.main_key : '',
                  this.bunch_of_key_shortcuts.focus_address.modifier)
            } // Keywords
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Off)
            .height(this.showing_search_extracted_field ? 36 : 0)
            .animation(animation_default())

          } // Two inputs
          .layoutWeight(1)

          linysSymbol({ symbol_glyph_target: 'sys.symbol.arrow_right' })// Search
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
            show: this.address_analyzers_desc_close_cd > 0,
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
              this.address_analyzers_desc_close_cd = 1200;
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
        .height(36)
        .padding(this.tablet_mode ? { left: 10, right: 10 } : {})
        .alignRules(this.tablet_mode
          ? {
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
            .animation(animation_default())
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
            Scroll() {
              Text($r('app.string.Index_download_task_start'))
                .fontSize(fontSize_Large() - 2)
                .fontColor(this.color_current_primary)
                .margin({ right: this.showing_downloads ? 5 : 0 })
            }
            .width(this.download_started_popup ? undefined : 0)
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .animation(animation_default())
          } // Downloads
          .padding(!this.showing_downloads && this.download_started_popup ? 5 : 0)
          .backgroundColor(this.download_started_popup ? this.color_current_font : "transparent")
          .borderRadius(10)
          .clickEffect(click_effect_default())
          // .visibility(this.bunch_of_downloads.list_of_urls.length > 0 ? Visibility.Visible : Visibility.None)
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
      .height(this.tablet_mode || this.showing_scratching_board ? 36 : 82)
      .animation(animation_default())

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

      // Delayed loading
      if (this.delayed_load_p2) {
        Scroll() {
          Column({ space: 10 }) {
            RelativeContainer() {
              Row({ space: 10 }) {
                linysSymbol({
                  symbol_glyph_target: 'sys.symbol.doc_text_badge_magnifyingglass'
                }) // in-page Search

                TextInput({
                  text: this.current_in_page_searching_keyword,
                  placeholder: $r('app.string.More_in_page_search')
                })
                  .onChange((edit) => {
                    this.current_in_page_searching_keyword = edit;
                    this.bunch_of_tabs.workingMainTab().searching_keyword = edit;
                  })
                  .visibility(this.showing_scratching_board ? Visibility.Hidden : Visibility.Visible)// .margin({ left: 10 })
                  .layoutWeight(1)
                  .allowDrop(null)
                  .height(capsule_bar_height())
                  .fontWeight(FontWeight.Regular)
                  .fontColor(this.color_current_font)
                  .caretColor(this.color_current_font)
                  .selectedBackgroundColor(this.color_current_font)
                  .onDragEnter(() => {
                    this.showing_scratching_board = false;
                  })
                  .enabled(this.showing_scratching_board ? false : true)
                  .opacity(this.showing_scratching_board ? 0.8 : 1)
                  .onSubmit(() => {
                    try {
                      this.bunch_of_tabs.workingMainTab().controller.searchAllAsync(this.current_in_page_searching_keyword);
                    } catch (e) {
                      console.error(e);
                    }
                  })
                  .id('in_page_search_blank')

                linysSymbol({ symbol_glyph_target: 'sys.symbol.magnifyingglass' })
                  .onClick(() => {
                    try {
                      this.bunch_of_tabs.workingMainTab().controller.searchAllAsync(this.current_in_page_searching_keyword);
                    } catch (e) {
                      console.error(e);
                    }
                  })
                // .margin({ left: 10 })

                linysSymbol({ symbol_glyph_target: 'sys.symbol.xmark' })
                  .onClick(() => {
                    this.current_in_page_searching_keyword = '';
                    this.current_in_page_searching_stats_current = 0;
                    this.current_in_page_searching_stats_total = 0;
                    this.bunch_of_tabs.workingMainTab().searching_keyword_stats_current = 0;
                    this.bunch_of_tabs.workingMainTab().searching_keyword_stats_total = 0;
                    this.bunch_of_tabs.workingMainTab().searching_keyword = '';
                    try {
                      this.bunch_of_tabs.workingMainTab().controller.clearMatches();
                    } catch (e) {
                      console.error(e);
                    }
                  })// .margin({ left: 10 })
                  .visibility(this.current_in_page_searching_keyword != "" ? Visibility.Visible : Visibility.None)
                  .animation(animation_default())
              } // Search bar
              .margin(this.tablet_mode ? (this.preferred_hand_left_or_right == 'right' ? { right: 10, left: 5 } : { left: 10, right: 5 }) : { left: 5, right: 5 })
              .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
              .id('in_page_search_bar')
              .alignRules(this.tablet_mode ? {
                left: { anchor: "__container__", align: HorizontalAlign.Start },
                right: { anchor: "in_page_search_operation_buttons", align: HorizontalAlign.Start }
              } : {
                left: { anchor: "__container__", align: HorizontalAlign.Start },
                right: { anchor: "__container__", align: HorizontalAlign.End },
                top: { anchor: "__container__", align: VerticalAlign.Top }
              })
              .animation(animation_default())

              Row({ space: 10 }) {
                linysText({
                  text: this.current_in_page_searching_stats_current.toString() + '／' +
                  this.current_in_page_searching_stats_total.toString()
                })
                  .animation(animation_default())
                linysSymbol({ symbol_glyph_target: 'sys.symbol.chevron_up' })
                  .keyboardShortcut(FunctionKey.DPAD_UP, [])
                  .onClick(() => {
                    try {
                      this.bunch_of_tabs.workingMainTab().controller.searchNext(false);
                    } catch (e) {
                      console.error(e);
                    }
                  })
                linysSymbol({ symbol_glyph_target: 'sys.symbol.chevron_down' })
                  .keyboardShortcut(FunctionKey.DPAD_DOWN, [])
                  .onClick(() => {
                    try {
                      this.bunch_of_tabs.workingMainTab().controller.searchNext(true);
                    } catch (e) {
                      console.error(e);
                    }
                  })
              } // Operation buttons
              .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
              .margin(!this.tablet_mode ? { left: 5, right: 5 } : 0)
              .id('in_page_search_operation_buttons')
              .padding({ left: this.tablet_mode ? 10 : 0 })
              .alignRules(this.tablet_mode ? {
                right: { anchor: "__container__", align: HorizontalAlign.End },
                center: { anchor: "__container__", align: VerticalAlign.Center }
              } : {
                left: { anchor: "__container__", align: HorizontalAlign.Start },
                right: { anchor: "__container__", align: HorizontalAlign.End },
                bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
              })
              .animation(animation_default())
            } // Search in page
            .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
            .width("100%")
            .height(20 + (this.tablet_mode ? capsule_bar_height() : 2 * capsule_bar_height()))
            .backgroundColor(this.current_in_page_searching_stats_total <= 0
              ? this.color_current_primary
              : add_transparency(this.color_current_primary, 128))
            .borderRadius(10)
            .padding(10)
            .animation(animation_default())

            Scroll() {
              Row({ space: 10 }) {
                linysSymbol({
                  symbol_glyph_target: 'sys.symbol.printer'
                })// Print
                  .onClick(() => {
                    print_web(this.bunch_of_tabs.workingMainTab().controller);
                  })
                linysSymbol({
                  symbol_glyph_target: 'sys.symbol.tracking_cookie_interception'
                })// Cookies
                  .onClick(() => {
                    this.cookies_control.open();
                  })
                linysSymbol({
                  symbol_glyph_target: 'sys.symbol.picture_2'
                })// Image
                  .onClick(() => {
                    this.image_manage_control.open();
                  })
                linysSymbol({
                  symbol_glyph_target: 'sys.symbol.electric_install'
                })// JS
                  .onClick(() => {
                    this.js_manage_control.open();
                  })
                linysSymbol({
                  symbol_glyph_target: 'sys.symbol.ad_circle_slash'
                })// Enable ads blocker
                  .onClick(() => {
                    this.woofAdsBlocker_control.open();
                  })
                linysSymbol({
                  symbol_glyph_target: 'sys.symbol.arrow_counterclockwise_clock'
                })// History
                  .onClick(() => {
                    this.woofHistory_control.open();
                  })
                linysSymbol({
                  symbol_glyph_target: 'sys.symbol.label'
                })// UA
                  .onClick(() => {
                    this.woofQuickUA_control.open();
                  })
                linysSymbol({
                  symbol_glyph_target: 'sys.symbol.qrcode'
                })// QRcode
                  .onClick(() => {
                    this.woofQR_control.open();
                  })
                linysSymbol({
                  symbol_glyph_target: this.fullscreen_mode ?
                    'sys.symbol.arrow_down_right_and_arrow_up_left' :
                    'sys.symbol.arrow_up_left_and_arrow_down_right'
                })// FullScreen
                  .onClick(() => {
                    this.fullscreen_mode = !this.fullscreen_mode;
                    this.showing_more_options = false;
                  })
              } // Small buttons
              .justifyContent(FlexAlign.End)
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .visibility(this.visible_when_in_page_search())
            .animation(animation_default())

            Row() {
              meowDebug()
            } // Debug
            .opacity(0.8)
            .visibility(this.resource_monitor
              ? (this.visible_when_in_page_search())
              : Visibility.None)
            .animation(animation_default())

            linysProgressInfo({
              notification: $r('app.string.Settings_experience_history_index_loading_index_from_disk'),
              progress: this.history_index_loading_progress,
            })
              .opacity(0.8)
              .visibility(this.history_index_loading_progress != "" ? (this.visible_when_in_page_search()) : Visibility.None)
              .animation(animation_default())

            linysProgressInfo({
              notification: $r('app.string.Settings_experience_history_index_reindexing'),
              progress: this.reindexing_history_progress,
            })
              .opacity(0.8)
              .visibility(this.reindexing_history_progress != "" ? (this.visible_when_in_page_search()) : Visibility.None)
              .animation(animation_default())

            linysProgressInfo({
              notification: $r('app.string.Settings_experience_history_index_saving_to_disk'),
              progress: this.history_index_saving_progress,
            })
              .opacity(0.8)
              .visibility(this.history_index_saving_progress != "" ? (this.visible_when_in_page_search()) : Visibility.None)
              .animation(animation_default())

          } // Title Bar of More Options
          .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
          .width("100%")
          .animation(animation_default())
        } // More Options
        .margin({ left: 15, right: 15 })
        .align(Alignment.Bottom)
        .borderRadius(16)
        .visibility(this.showing_more_options ? Visibility.Visible : Visibility.None)
        .layoutWeight(this.showing_more_options ? 1 : undefined)
        .animation(animation_default())
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)

        meowAppSettings({ showing_app_settings: this.showing_app_settings })// Settings
          .visibility(this.showing_app_settings ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

        meowDownloads({ screen_width: this.screen_width })
          .visibility(this.showing_downloads ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

        meowScratchingBoard()
          .visibility(this.showing_scratching_board ? Visibility.Visible : Visibility.None)
          .animation(animation_default())
      }

      if (this.title_bar_position == "top" && this.delayed_load_p0) {
        meowSuggestions({ bottom_margin: 15 })
          .animation(animation_default())
      }

      if (this.title_bar_position == "bottom") {
        Row().height(5)
      }
    } // Title Bars
    .clip(true)
    .allowDrop(allow_drop_types())
    .onDrop((e) => {
      drop_to_scratching_board(e);
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
    .padding({ left: this.leftAvoidWidth, right: this.rightAvoidWidth })
    .onAreaChange((_o, n) => {
      if (!this.showing_more_options && !this.is_search_input_typing && !this.showing_app_settings && !this.showing_downloads &&
        !this.showing_scratching_board) {
        this.bar_height = n.height as number;
      }
    })
    .offset({ y: !this.fullscreen_mode ? 0 : (this.title_bar_position == 'bottom' ? 1.1 : -1.1) * this.bar_height })
    .animation(animation_default())
    .onAppear(() => {
      // console.log("[Meow][meowTitleBar] Title Bar READY")
      setInterval(() => {
        if (this.address_analyzers_desc_close_cd > 0) {
          this.address_analyzers_desc_close_cd -= 10;
        }
      }, 10)
    })
    .keyboardShortcut(this.bunch_of_key_shortcuts.in_page_search.main_key, this.bunch_of_key_shortcuts.in_page_search.modifier, () => {
      this.showing_more_options = true;
      focusControl.requestFocus("in_page_search_blank")
    })
  }

  // Visibility

  visible_when_search_input_is_not_blank() {
    return this.search_input == "" ? Visibility.None : Visibility.Visible
  }

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

  visible_when_in_page_search() {
    return (this.current_in_page_searching_stats_total <= 0 ? Visibility.Visible : Visibility.None);
  }

  // Events

  on_download_start() {
    // Show popup when gateway is set back to undefined.
    if (!this.uni_webDownloadItem_gateway) {
      this.download_started_popup = true;
      setTimeout(() => {
        this.download_started_popup = false;
      }, animation_popup_duration())
    }
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

  show_add_bookmarks() {
    if (this.showing_bookmarks) {
      this.showing_bookmarks = false;
      AppStorage.set('adding_bookmark', false);
    } else {
      // Add Bookmark
      AppStorage.set('bookmark_add_label', this.bunch_of_tabs.workingMainTab().title);
      AppStorage.set('bookmark_add_link', url_resource_to_meow(this.bunch_of_tabs.workingMainTab().url));
      this.showing_bookmarks = true;
      AppStorage.set('adding_bookmark', true);
    }
  }

  new_tab() {
    AppStorage.set('extra_background', false);
    AppStorage.set('universal_new_tab_gateway', "new_tab");
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
    // Flip url field if needed
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

    this.bunch_of_tabs.refresh_onWorkingTab()
    this.bunch_of_tabs.workingMainTab().update_is_loading(true)
  }

  stop_page() {
    this.bunch_of_tabs.stop_onWorkingTab();
    this.bunch_of_tabs.workingMainTab().update_is_loading(false);
    this.sync_tabs_list_info();
    this.update_tabs_current_info();
  }

  // Values

  max_height_of_title_bar() {
    if (!this.showing_more_options) {
      return undefined;
    }

    if (this.current_in_page_searching_stats_total > 0) {
      // in-page Searching
      let base_height = this.tablet_mode ? 110 : 190;
      let tabs_offset = this.showing_tabs && current_tabs_style_is_horizontal() ? this.horizontal_tabs_height : 0;
      let position_offset = this.title_bar_position == 'top' ? 0 : 15;
      return base_height + tabs_offset + position_offset;
    } else {
      // Normal height
      return Math.min(this.full_screen_height, this.tablet_mode ? 370 : 460);
    }
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

  update_tabs_current_info() {
    this.current_title = this.tab_titles[this.current_main_tab_index];
    this.current_url = this.tab_urls[this.current_main_tab_index];
    this.current_url = url_resource_to_meow(this.current_url);
    // translate "resource://" into "meow://"
    this.current_loading_progress = this.tab_loading_progresses[this.current_main_tab_index];
    this.current_is_loading = this.tab_is_loading[this.current_main_tab_index];
    // Set loading progress
    this.current_in_page_searching_keyword = this.bunch_of_tabs.workingMainTab().searching_keyword;
    this.current_in_page_searching_stats_current = this.bunch_of_tabs.workingMainTab().searching_keyword_stats_current;
    this.current_in_page_searching_stats_total = this.bunch_of_tabs.workingMainTab().searching_keyword_stats_total;
  }

  sync_tabs_list_info() {
    this.tab_titles = this.bunch_of_tabs.get_all_titles()
    this.tab_urls = this.bunch_of_tabs.get_all_urls()
    this.tab_is_loading = this.bunch_of_tabs.get_all_is_loading();
    this.tab_loading_progresses = this.bunch_of_tabs.get_all_loading_progress()
  }
}

export default meowTitleBar;

@Component
struct EstimatedDestination {
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
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