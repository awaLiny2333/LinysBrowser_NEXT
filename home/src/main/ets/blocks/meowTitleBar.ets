import linysSymbol from '../components/linysSymbol';
import linysShowButton from '../components/linysShowButton';
import meowAppSettings from './meowAppSettings';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import {
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
import meowDrops from './meowDrops';
import woofAdsBlocker from '../dialogs/woofAdsBlocker';

@Component
struct meowTitleBar {
  // Hosts
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  // Environments
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('screen_width') screen_width: number = 0;
  @StorageProp('screen_height') screen_height: number = 0;
  @StorageProp('universal_new_download_gateway') @Watch('on_download_start') uni_new_download_gateway: string = "";
  @Link bar_height: number;
  @Link webViews_ready: boolean;
  // Current environment
  @Link title_bar_alignRules: AlignRuleOption;
  @Link search_input: string;
  @State search_input_unified: string = "";
  @Link is_search_input_typing: boolean;
  @State download_started_popup: boolean = false;
  @State drop_result_string: string[] = [];
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
  @Link showing_tabs: boolean;
  @Link showing_bookmarks: boolean;
  @Link showing_more_options: boolean;
  @Link showing_app_settings: boolean;
  @Link showing_downloads: boolean;
  @Link showing_scratching_board: boolean;
  @State show_feed_prompt: boolean = true;
  // settings
  @Link settings_title_bar_position: string;
  @Link settings_tabs_style: string;
  @Link settings_collect_new_history: boolean;
  @Link sys_back_to_access_backward: boolean;
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
  woofAdsBlocker_control: CustomDialogController = new CustomDialogController({
    builder: woofAdsBlocker({
      adblock_exceptions: this.adblock_exceptions,
      add_exception_domain_edit: match_domain(this.search_input),
      showing_add_panel: true
    }),
    width: "90%",
    alignment: DialogAlignment.Center,
    cornerRadius: 16
  })

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

      meowTabsHorizontal({
        webViews_ready: this.webViews_ready,
        showing_tabs: this.showing_tabs,
      })
        .visibility(this.showing_tabs && this.settings_tabs_style == "horizontal" && this.tablet_mode ?
        Visibility.Visible : Visibility.None)
        .animation(animation_default())

      Row() {
        Text("→ " + (this.search_input_unified == "" ? "(　o=^•ェ•)o ?" : this.search_input_unified))
          .fontColor($r('app.color.font_color_title'))
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
            .fontColor($r('app.color.font_color_title'))
            .fontWeight(FontWeight.Medium)
            .fontSize(fontSize_Large())
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.current_url)
            .fontColor($r('app.color.font_color_title'))
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
          .fontColor([$r('app.color.font_color_title')])
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

        TextInput({ text: this.search_input })
          .allowDrop(null)
          .visibility(this.showing_scratching_board ? Visibility.Hidden : this.visible_in_tablet_mode())
          .height(capsule_bar_height())
          .layoutWeight(1)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.font_color_title'))
          .animation(animation_default())
          .onClick(() => {
            this.is_search_input_typing = true;
          })
          .onDragEnter(() => {
            this.showing_scratching_board = true;
          })
          .onBlur(() => {
            this.is_search_input_typing = false;
          })
          .onChange((content) => {
            this.update_search_input(content)
          })
          .onSubmit(() => {
            this.submit_searching()
          })
          .selectAll(true)
          .caretColor($r('app.color.font_color_title'))
          .selectedBackgroundColor($r('app.color.font_color_title'))

        Blank()
          .visibility(this.visible_in_normal_mode())

        linysSymbol({
          symbol_glyph_target: 'sys.symbol.magnifyingglass'
        })// Search
          .onClick(() => {
            this.submit_searching()
          })
          .visibility(this.visible_when_typing_in_tablet_mode())

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
            $r('app.color.start_window_background') : $r('app.color.font_color_title')
          })
          Scroll() {
            Text($r('app.string.Index_download_task_start'))
              .fontSize(fontSize_Large() - 2)
              .fontColor($r('app.color.start_window_background'))
              .margin({ right: this.showing_downloads ? 5 : 0 })
          }
          .width(this.download_started_popup ? undefined : 0)
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .animation(animation_default())
        } // Downloads
        .padding(!this.showing_downloads && this.download_started_popup ? 5 : 0)
        .backgroundColor(this.download_started_popup ? $r('app.color.font_color_title') : "transparent")
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

      } // Title Bar of controls
      .padding({ left: 15, right: 15 })
      .width("100%")
      .constraintSize({ minHeight: 36 })
      .animation(animation_default())

      Row({ space: 10 }) {
        TextInput({ text: this.search_input })
          .allowDrop(null)
          .height(capsule_bar_height())
          .layoutWeight(1)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.font_color_title'))
          .caretColor($r('app.color.font_color_title'))
          .onClick(() => {
            this.is_search_input_typing = true;
          })
          .onDragEnter(() => {
            this.showing_scratching_board = true;
          })
          .onBlur(() => {
            this.is_search_input_typing = false;
          })
          .onChange((content) => {
            this.update_search_input(content)
          })
          .onSubmit(() => {
            this.submit_searching()
          })
          .selectAll(true)
          .selectedBackgroundColor($r('app.color.font_color_title'))

        linysSymbol({
          symbol_glyph_target: 'sys.symbol.magnifyingglass'
        })
          .visibility(this.visible_when_typing())
          .onClick(() => {
            this.submit_searching()
          })

      } // Title Bar of extended searching bar
      .visibility(this.showing_scratching_board ? Visibility.None : this.visible_in_normal_mode())
      .padding({ left: 15, right: 15 })
      .width("100%")
      .animation(animation_default())

      Row({ space: 10 }) {
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
        showing_downloads: this.showing_downloads,
      })
        .visibility(this.showing_downloads ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      meowDrops({
        data_list: this.drop_result_string,
        showing_scratching_board: this.showing_scratching_board,
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
    .backgroundColor($r('app.color.block_color'))
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

  visible_in_normal_mode() {
    return !this.tablet_mode ? Visibility.Visible : Visibility.None;
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
    }, animation_popup_duration() * 10)
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
    this.webViews_ready = true;

    if (this.search_input_unified != "") {
      let unified_url: string = unify_search_input_into_url(this.search_input);
      // unify input into a legal link
      unified_url = url_meow_to_resource(unified_url);
      // translate "meow://" into "resource://"
      this.bunch_of_tabs.loadUrl_onWorkingTab(unified_url);
    }
  }

  go_backward() {
    this.webViews_ready = true;
    this.bunch_of_tabs.goBackward_onWorkingTab();
  }

  go_forward() {
    this.webViews_ready = true;
    this.bunch_of_tabs.goForward_onWorkingTab();
  }

  go_home() {
    this.webViews_ready = true;
    this.bunch_of_tabs.go_home_onWorkingTab();
  }

  refresh_page() {
    this.webViews_ready = true;
    this.bunch_of_tabs.refresh_onWorkingTab()
    this.bunch_of_tabs.workingTab().update_is_loading(true)
  }

  stop_page() {
    this.webViews_ready = true;
    this.bunch_of_tabs.stop_onWorkingTab();
    this.bunch_of_tabs.workingTab().update_is_loading(false);
    this.sync_tabs_list_info();
    this.update_tabs_current_info();
  }

  // Data synchronizing

  update_search_input(content: string) {
    this.search_input = content;
    this.search_input_unified = unify_search_input_into_url(content);
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