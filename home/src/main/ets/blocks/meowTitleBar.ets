import linysSymbol from '../components/linysSymbol';
import linysShowButton from '../components/linysShowButton';
import meowAppSettings from './meowAppSettings';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import {
  extract_search,
  match_domain,
  unify_search_input_into_url,
  url_meow_to_resource,
  url_resource_to_meow
} from '../utils/url_tools';
import {
  animation_default,
  animation_popup_duration,
  capsule_bar_height,
  click_effect_default,
  fontSize_Icon_Button,
  fontSize_Large,
  fontSize_Normal
} from '../hosts/bunch_of_defaults';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import meowDownloads from './meowDownloads';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';
import meowSuggestions from './meowSuggestions';
import woofQR from '../dialogs/woofQR';
import meowTabsHorizontal from './meowTabsHorizontal';
import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import meowScratchingBoard from './meowScratchingBoard';
import woofAdsBlocker from '../dialogs/woofAdsBlocker';
import woofAddSE from '../dialogs/woofAddSE';

@Component
struct meowTitleBar {
  // Hosts
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // Environments
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('screen_width') screen_width: number = 0;
  @StorageProp('screen_height') screen_height: number = 0;
  @StorageProp('universal_new_download_gateway') @Watch('on_download_start') uni_new_download_gateway: string = "";
  @Link bar_height: number;
  // Current environment
  @Link title_bar_alignRules: AlignRuleOption;
  @Link @Watch('on_search_input_change') search_input: string;
  @State search_input_unified: string = "";
  @Link is_search_input_typing: boolean;
  @State download_started_popup: boolean = false;
  @State drop_result_string: string[] = [];
  // Search analyze
  @State search_extracted_keyword: string = '';
  @State search_extracted_engine: string = '';
  @State showing_search_extracted_field: boolean = false;
  @State search_extracted_field_available: boolean = false;
  @State search_input_is_address: boolean = false;
  // Web statuses
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
  // UI control actions
  @StorageLink('showing_tabs') showing_tabs: boolean = false;
  @StorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @StorageLink('showing_more_options') showing_more_options: boolean = false;
  @StorageLink('showing_app_settings') showing_app_settings: boolean = false;
  @StorageLink('showing_downloads') showing_downloads: boolean = false;
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  @State address_analyzers_desc_close_cd: number = 0;
  // settings
  @Link settings_title_bar_position: string;
  @Link settings_tabs_style: string;
  @Link settings_collect_new_history: boolean;
  @Link sys_back_to_access_backward: boolean;
  @Link web_force_dark_mode: boolean;
  @Link use_adblock: boolean;
  @Link adblock_exceptions: string[];
  @State settings_max_bookmark_advice: number = 5;
  @State settings_max_history_advice: number = 5;
  // Dialogs
  woofQR_control: CustomDialogController = new CustomDialogController({
    builder: woofQR({
      title: this.current_title,
      link: this.current_url
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  })
  woofAddSE_control: CustomDialogController = new CustomDialogController({
    builder: woofAddSE({
      label: this.current_title,
      link: this.search_extracted_engine,
      keyword: this.search_extracted_keyword
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  })
  woofAdsBlocker_control: CustomDialogController = new CustomDialogController({
    builder: woofAdsBlocker({
      adblock_exceptions: this.adblock_exceptions,
      add_exception_domain_edit: match_domain(this.search_input),
      showing_add_panel: true
    }),
    showInSubWindow: true,
    width: "90%",
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  })
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 10 }) {
      if (this.settings_title_bar_position == "bottom") {
        meowSuggestions({
          settings_max_history_suggestions: this.settings_max_history_advice,
          settings_max_bookmark_suggestions: this.settings_max_bookmark_advice,
          top_margin: 15,
          is_search_input_typing: this.is_search_input_typing,
          search_input: this.search_input,
        })
          .animation(animation_default())
      }

      meowTabsHorizontal()// Horizontal tabs
        .visibility(this.showing_tabs && this.settings_tabs_style == "horizontal" && this.tablet_mode ?
        Visibility.Visible : Visibility.None)
        .animation(animation_default())

      Row() {
        Text("→ " + (this.search_input_unified == "" ? "(　o=^•ェ•)o ?" : this.search_input_unified))
          .fontColor(this.color_current_font)
          .fontWeight(FontWeight.Medium)
          .fontSize(fontSize_Normal())
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      } // Title Bar for estimated destination indication
      .visibility(this.visible_when_typing())
      .padding({ left: 15, right: 15 })
      .width("100%")
      .animation(animation_default())
      .constraintSize({ minHeight: 30 })

      Row() {
        Column({ space: 2.5 }) {
          Text(this.current_title)
            .fontColor(this.color_current_font)
            .fontWeight(FontWeight.Medium)
            .fontSize(fontSize_Large())
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.current_url)
            .fontColor(this.color_current_font)
            .fontWeight(FontWeight.Medium)
            .fontSize(fontSize_Normal())
            .opacity(0.7)
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        linysSymbol({ symbol_glyph_target: 'sys.symbol.share' })
      } // Title Bar for This Page Info display
      .padding({ left: 16, right: 15, top: 6 })
      .width("100%")
      .visibility(this.showing_more_options ? Visibility.Visible : Visibility.None)
      .animation(animation_default())

      RelativeContainer() {
        Row({ space: this.tablet_mode ? 10 : 7 }) {
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

        Row() {
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.curve_magnifyingglass'
          })// Add Search Engine
            .onClick(() => {
              this.woofAddSE_control.open();
            })
            .margin({ right: 10 })
            .opacity(this.search_extracted_field_available ? 1 : 0.5)
            .enabled(this.search_extracted_field_available ? true : false)
            .animation(animation_default())

          RelativeContainer() {
            Scroll() {
              TextInput({ text: this.search_input })
                .allowDrop(null)// .enabled(this.showing_search_extracted_field ? false : true)
                .height(capsule_bar_height())
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .offset({ y: !this.showing_search_extracted_field ? 0 : -50 })
                .opacity(this.showing_search_extracted_field ? 0 : 100)
                .animation(animation_default())
                .onDragEnter(() => {
                  this.showing_scratching_board = true;
                })
                .onFocus(() => {
                  this.is_search_input_typing = true;
                })
                .onBlur(() => {
                  this.is_search_input_typing = false;
                })
                .focusable(this.showing_scratching_board ? false : true)
                .onChange((content) => {
                  this.update_search_input(content);
                })
                .onSubmit(() => {
                  this.submit_searching()
                })
                .selectAll(true)
                .selectedBackgroundColor(this.color_current_font)
                .id('address_bar')
            }
            .scrollable(ScrollDirection.Vertical)
            .height(this.showing_search_extracted_field ? 0 : 36)
            .scrollBar(BarState.Off)
            .animation(animation_default())

            Scroll() {
              TextInput({ text: this.search_extracted_keyword })
                .allowDrop(null)// .enabled(this.showing_search_extracted_field ? true : false)
                .height(capsule_bar_height())
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .offset({ y: this.showing_search_extracted_field ? 0 : 50 })
                .opacity(this.showing_search_extracted_field ? 100 : 0)
                .animation(animation_default())
                .onDragEnter(() => {
                  this.showing_scratching_board = true;
                })
                .onFocus(() => {
                  this.is_search_input_typing = true;
                })
                .onBlur(() => {
                  this.is_search_input_typing = false;
                })
                .focusable(this.showing_scratching_board ? false : true)
                .onChange((content) => {
                  this.search_extracted_keyword = content;
                  if (content == '') {
                    this.search_input_unified = this.search_extracted_engine.replaceAll('%s', 'o(=•ェ•=)m?');
                  } else {
                    this.search_input_unified =
                      this.search_extracted_engine.replaceAll('%s', encodeURIComponent(content));
                    this.search_input = this.search_input_unified;
                  }
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
            }
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Off)
            .height(this.showing_search_extracted_field ? 36 : 0)
            .animation(animation_default())

          } // Two inputs
          .layoutWeight(1)

          Row() {
            linysShowButton({
              symbol_glyph_target: this.showing_search_extracted_field ? 'sys.symbol.text_and_t' : 'sys.symbol.link',
              text: $r(this.showing_search_extracted_field ?
                'app.string.Address_analyzer_keyword' :
                'app.string.Address_analyzer_address'),
              show: this.address_analyzers_desc_close_cd > 0,
            })// Key Link
              .margin({ left: 10 })
              .visibility(this.search_extracted_field_available ? Visibility.Visible : Visibility.None)
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

            linysSymbol({ symbol_glyph_target: 'sys.symbol.magnifyingglass' })// Search
              .visibility(this.visible_when_typing())
              .onClick(() => {
                this.submit_searching()
              })
              .margin({ left: 10 })
              .animation(animation_default())
          } // Buttons
        } // Searching bar
        .height(36)
        .padding(this.tablet_mode ? { left: 10, right: 10 } : {})
        .alignRules(this.tablet_mode ?
          {
            left: { anchor: 'left_controls', align: HorizontalAlign.End },
            right: { anchor: 'right_controls', align: HorizontalAlign.Start },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          } : { bottom: { anchor: '__container__', align: VerticalAlign.Bottom } })
        .animation(animation_default())

        Row({ space: this.tablet_mode ? 10 : 7 }) {
          linysShowButton({
            show: this.showing_scratching_board,
            text: $r('app.string.Index_drop_scratching_board'),
            symbol_glyph_target: this.showing_scratching_board ? 'sys.symbol.chevron_down' : 'sys.symbol.doc_rectify'
          })// Scratching board
            .visibility(this.drop_result_string.length > 0 ? Visibility.Visible : Visibility.None)
            .animation(animation_default())
            .onClick(() => {
              this.showing_scratching_board = !this.showing_scratching_board;
            })

          linysShowButton({
            show: this.showing_more_options,
            text: $r('app.string.Index_more_title'),
            symbol_glyph_target: this.showing_more_options ? 'sys.symbol.chevron_down' : 'sys.symbol.dot_grid_2x2'
          })// More options
            .onClick(() => {
              this.show_more_options()
            })

          linysShowButton({
            symbol_glyph_target: 'sys.symbol.rectangle_stack',
            show: this.showing_tabs
          })// Tabs
            .onClick(() => {
              this.show_tabs()
            })

          linysShowButton({
            show: this.showing_bookmarks,
            text: $r('app.string.Index_bookmarks_title'),
            symbol_glyph_target: 'sys.symbol.bookmark'
          })// Bookmarks
            .onClick(() => {
              this.show_bookmarks();
            })

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
          .animation(animation_default())
          .onClick(() => {
            if (this.download_started_popup) {
              this.download_started_popup = false;
            } else {
              this.show_downloads()
            }
          })

          linysShowButton({
            show: this.showing_app_settings,
            text: $r('app.string.Index_app_settings_title'),
            symbol_glyph_target: this.showing_app_settings ? 'sys.symbol.chevron_down' : 'sys.symbol.gearshape'
          })// Settings
            .onClick(() => {
              this.show_app_settings()
            })

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
      .height(this.tablet_mode ? 36 : 82)
      .animation(animation_default())

      Row({ space: this.tablet_mode ? 10 : 7 }) {
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.qrcode'
        })// QRcode
          .onClick(() => {
            this.woofQR_control.open();
          })
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.ad_rectangle_fill'
        })// Enable ads
          .onClick(() => {
            this.woofAdsBlocker_control.open();
          })
      } // Title Bar of More Options
      .visibility(this.showing_more_options ? Visibility.Visible : Visibility.None)
      .padding({ left: 15, right: 15, bottom: 6 })
      .width("100%")
      .direction(Direction.Rtl)
      .animation(animation_default())

      meowAppSettings({
        showing_app_settings: this.showing_app_settings,
        settings_collect_new_history: this.settings_collect_new_history,
        use_adblock: this.use_adblock,
        adblock_exceptions: this.adblock_exceptions,
        sys_back_to_access_backward: this.sys_back_to_access_backward,
        web_force_dark_mode: this.web_force_dark_mode,
        settings_max_bookmark_suggestions: this.settings_max_bookmark_advice,
        settings_max_history_suggestions: this.settings_max_history_advice,
        settings_title_bar_position: this.settings_title_bar_position,
        settings_tabs_style: this.settings_tabs_style,
        show: this.showing_app_settings,
      })// Settings
        .visibility(this.showing_app_settings ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      meowDownloads({
        screen_width: this.screen_width,
      })
        .visibility(this.showing_downloads ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      meowScratchingBoard({
        data_list: this.drop_result_string,
      })
        .visibility(this.showing_scratching_board ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      if (this.settings_title_bar_position == "top") {
        meowSuggestions({
          settings_max_history_suggestions: this.settings_max_history_advice,
          settings_max_bookmark_suggestions: this.settings_max_bookmark_advice,
          bottom_margin: 15,
          is_search_input_typing: this.is_search_input_typing,
          search_input: this.search_input,
        })
          .animation(animation_default())
      }

    } // Title Bars
    .allowDrop([uniformTypeDescriptor.UniformDataType.TEXT,
      uniformTypeDescriptor.UniformDataType.HYPERLINK,
      uniformTypeDescriptor.UniformDataType.PLAIN_TEXT])
    .onDrop((e) => {
      this.on_drop(e);
    })
    .onDragEnter(() => {
      this.showing_scratching_board = true;
    })
    .onDragLeave(() => {
      this.showing_scratching_board = false;
    })
    .width("100%")
    .backgroundColor(this.color_current_secondary)
    .alignRules(this.title_bar_alignRules)
    .onAreaChange((_o, n) => {
      if (!this.showing_more_options && !this.is_search_input_typing &&
        !this.showing_app_settings && !this.showing_downloads && !this.showing_scratching_board) {
        this.bar_height = n.height as number;
      }
    })
    .visibility(this.settings_title_bar_position == "" ? Visibility.Hidden : Visibility.Visible)
    .animation(this.showing_app_settings ? animation_default() : undefined)
    .onAppear(() => {
      console.log("[Meow][meowTitleBar] Title Bar READY")
      setInterval(() => {
        if (this.address_analyzers_desc_close_cd > 0) {
          this.address_analyzers_desc_close_cd -= 10;
        }
      }, 10)
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

  visible_in_tablet_mode() {
    return this.tablet_mode ? Visibility.Visible : Visibility.None;
  }

  visible_when_title_bar_on_top() {
    return this.settings_title_bar_position == "top" ? Visibility.Visible : Visibility.None;
  }

  visible_when_title_bar_on_bottom() {
    return this.settings_title_bar_position == "bottom" ? Visibility.Visible : Visibility.None;
  }

  visible_when_typing_in_tablet_mode() {
    return this.tablet_mode && this.is_search_input_typing ? Visibility.Visible : Visibility.None;
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

  // Events

  on_drop(e: DragEvent) {
    let drop_data = e.getData().getRecords();
    let result_list: string[] = [];
    for (let i = 0; i < drop_data.length; i++) {
      let record = drop_data[i]
      if (record.getType() == uniformTypeDescriptor.UniformDataType.HYPERLINK) {
        let desc = (record as unifiedDataChannel.Hyperlink).description;
        let url = (record as unifiedDataChannel.Hyperlink).url;

        if (desc && !result_list.includes(desc)) {
          // Push link description
          result_list.push(desc);
        }
        if (!result_list.includes(url)) {
          // Push link
          result_list.push(url);
        }

      } else if (record.getType() == uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) {
        let textContent = (record as unifiedDataChannel.PlainText).textContent;

        if (!result_list.includes(textContent)) {
          // Push text
          result_list.push(textContent);
        }
      }
    }
    this.drop_result_string = result_list.concat(this.drop_result_string);
    e.setResult(DragResult.DRAG_SUCCESSFUL);
  }

  on_download_start() {
    this.download_started_popup = true;
    setTimeout(() => {
      this.download_started_popup = false;
    }, animation_popup_duration())
  }

  on_search_input_change() {
    let extract: string[] = extract_search(this.search_input);
    if (extract[1] == '' && extract[0] == '') {
      this.showing_search_extracted_field = false;
      this.search_extracted_field_available = false;
    } else {
      this.search_extracted_field_available = true;
      this.search_extracted_engine = extract[0];
      this.search_extracted_keyword = extract[1];
    }
  }

  // UI controls

  show_tabs() {
    if (!this.tablet_mode) {
      this.showing_more_options = false;
      this.showing_app_settings = false;
      this.showing_downloads = false;
    }

    if (!this.tablet_mode) {
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
    }
    if (!this.tablet_mode) {
      // allow bookmarks and tabs coexist in tablet mode
      this.showing_tabs = false;
    }
    this.showing_bookmarks = !this.showing_bookmarks;
  }

  show_more_options() {
    if (!this.tablet_mode) {
      this.showing_tabs = false;
      this.showing_bookmarks = false;
    }
    // Close all other panels

    this.showing_downloads = false;
    this.showing_app_settings = false;
    this.showing_more_options = !this.showing_more_options;
  }

  show_app_settings() {
    if (!this.tablet_mode) {
      this.showing_tabs = false;
      this.showing_bookmarks = false;
    }
    // Close all other panels

    this.showing_downloads = false;
    this.showing_more_options = false;
    this.showing_app_settings = !this.showing_app_settings;
  }

  show_downloads() {
    if (!this.tablet_mode) {
      this.showing_tabs = false;
      this.showing_bookmarks = false;
    }
    // Close all other panels

    this.showing_more_options = false;
    this.showing_app_settings = false;
    this.showing_downloads = !this.showing_downloads;
  }

  // Web control events

  submit_searching() {
    if (this.search_input_unified != "") {
      let unified_url: string = this.search_input_unified;
      // unify input into a legal link
      unified_url = url_meow_to_resource(unified_url);
      // translate "meow://" into "resource://"
      this.bunch_of_tabs.loadUrl_onWorkingTab(unified_url);
    }
    if (!this.search_input_is_address) {
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

  // Data synchronizing

  update_search_input(content: string) {
    this.search_input = content;
    let uni_result = unify_search_input_into_url(content);
    this.search_input_unified = uni_result[0] as string;
    this.search_input_is_address = uni_result[1] as boolean;
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
  }

  sync_tabs_list_info() {
    this.tab_titles = this.bunch_of_tabs.get_all_titles()
    this.tab_urls = this.bunch_of_tabs.get_all_urls()
    this.tab_is_loading = this.bunch_of_tabs.get_all_is_loading();
    this.tab_loading_progresses = this.bunch_of_tabs.get_all_loading_progress()
  }
}

export default meowTitleBar;