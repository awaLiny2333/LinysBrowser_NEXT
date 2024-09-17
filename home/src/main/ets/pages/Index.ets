import LinysProgress from '../blocks/LinysProgress';
import LinysSymbol from '../components/LinysSymbol';
import LinysShowButton from '../components/LinysShowButton';
import LinysTabs from '../blocks/LinysTabs';
import LinysWebView from '../blocks/LinysWebView';
import LinysBookmarks from '../blocks/LinysBookmarks';
import LinysAppSettings from '../blocks/LinysAppSettings';
import { BunchOfTabs } from '../hosts/BunchOfTabs';
import { BunchOfBookmarks } from '../hosts/BunchOfBookmarks';
import { unify_search_input_into_url, url_meow_to_resource, url_resource_to_meow } from '../utils/url_tools';
import {
  animation_default,
  capsule_bar_height,
  fontSize_Icon_Button,
  fontSize_Large,
  fontSize_Normal,
  home_url
} from '../hosts/BunchOfSettings';

@Entry
@Component
struct Index {
  @StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 1;
  @StorageLink('topAvoidHeight') topAvoidHeight: number = 1;
  @StorageProp('currentColorMode') current_color_mode: number = 0;
  @State is_search_input_typing: boolean = false;
  @State tablet_mode: boolean = false;
  @State search_input: string = "";
  @State search_input_unified: string = "";
  @State showing_more_options: boolean = false;
  @State showing_app_settings: boolean = false;
  @State showing_tabs: boolean = false;
  @State showing_bookmarks: boolean = false;
  @State screen_width: number = 0;
  @State current_accessForward: boolean = false;
  @State current_accessBackward: boolean = false;
  @State webViews_ready: boolean = false;
  @State current_tab_index: number = 0;
  @State bunch_of_tabs: BunchOfTabs = new BunchOfTabs();
  @State bunch_of_bookmarks: BunchOfBookmarks = new BunchOfBookmarks("Bookmarks");
  // HOST
  @State tab_titles: string[] = []
  @State current_title: string = "=￣ω￣=";
  @State tab_urls: string[] = []
  @State current_url: string = "=￣ω￣=";
  @State tab_loading_progresses: number[] = [0]
  @State current_loading_progress: number = 0
  @State tab_is_loading: boolean[] = [true]
  @State current_is_loading: boolean = true
  // Tabs

  @State universal_new_tab_gateway: string | undefined = undefined;
  // Misc weird methods but it just works ¯\_(ツ)_/¯

  @State bottom_bar_height: number = 0;
  @State @Watch('on_title_bar_position_change') settings_title_bar_position: string = "";
  @State web_and_stuff_alignRules: AlignRuleOption = {
    middle: { anchor: "__container__", align: HorizontalAlign.Center },
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
  };

  aboutToAppear(): void {
  }

  build() {
    Column() {
      Row()// Top Bar Avoid
        .width("100%")
        .height(px2vp(this.topAvoidHeight))
        .backgroundColor($r('app.color.block_color'))

      RelativeContainer() {

        Row() {
          Scroll() {
            Row() {
              Scroll() {
                Column() {
                  LinysBookmarks({
                    bunch_of_tabs: this.bunch_of_tabs,
                    bunch_of_bookmarks: this.bunch_of_bookmarks,
                    webViews_ready: this.webViews_ready
                  });
                } // Bookmarks Panel
                .width(this.tablet_mode ? 350 : 0.9 * this.screen_width)
                .height("100%")
              }
              .height("100%")
              .width(this.showing_bookmarks ? "100%" : 0)
              .animation(animation_default())
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)

              Scroll() {
                Column() {
                  LinysTabs({
                    tablet_mode: this.tablet_mode,
                    show_webViews: this.webViews_ready,
                    showing_tabs: this.showing_tabs,
                    animation_default: animation_default(),
                    // Environment
                    bunch_of_tabs: this.bunch_of_tabs,
                    universal_new_tab_gateway: this.universal_new_tab_gateway,
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
                  })
                } // Tabs Panel
                .width(this.tablet_mode ? 250 : 0.9 * this.screen_width)
                .height("100%")
              }
              .height("100%")
              .width(this.showing_tabs ? "100%" : 0)
              .animation(animation_default())
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)

            }
            .width("100%")
            .height("100%")
          }
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
            LinysWebView({
              tablet_mode: this.tablet_mode,
              show_webViews: this.webViews_ready,
              // Environment
              bunch_of_tabs: this.bunch_of_tabs,
              universal_new_tab_gateway: this.universal_new_tab_gateway,
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
          { bottom: this.bottom_bar_height } : { top: this.bottom_bar_height })

        Column() {
          LinysProgress({ percentage: this.current_loading_progress, is_loading: this.current_is_loading })
        } // Loading Bar
        .alignRules(this.web_and_stuff_alignRules)
        .width("100%")
        .margin(this.settings_title_bar_position == "bottom" ?
          { bottom: this.bottom_bar_height } : { top: this.bottom_bar_height })

        Column() {

          Row() {
            Text("→ " + (this.search_input_unified == "" ? "(　o=^•ェ•)o ?" : this.search_input_unified))
              .fontColor($r('app.color.font_color_title'))
              .fontWeight(FontWeight.Medium)
              .fontSize(fontSize_Normal())
              .maxLines(4)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          } // Bottom Bar for estimated destination indication
          .visibility(this.visible_when_typing())
          .padding({
            top: this.settings_title_bar_position == "bottom" ? 10 : 0,
            bottom: this.settings_title_bar_position == "bottom" ? 0 : 10,
            left: 15,
            right: 15
          })
          .width("100%")
          .animation(animation_default())

          Row({ space: 15 }) {
            Column({ space: 5 }) {
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

            LinysSymbol({ symbol_glyph_target: 'sys.symbol.share' })
          } // Bottom Bar for This Page Info display
          .padding({
            top: this.settings_title_bar_position == "bottom" ? 15 : 0,
            left: 16,
            right: 15
          })
          .width("100%")
          .visibility(this.showing_more_options ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

          Row({ space: 10 }) {

            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.arrow_left'
            })// Backward
              .enabled(this.current_accessBackward)
              .opacity(this.current_accessBackward ? 1 : 0.5)
              .visibility(this.visible_when_no_panels_open_in_normal_mode())
              .animation(animation_default())
              .onClick(() => {
                this.go_backward()
              })

            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.arrow_right'
            })// Forward
              .enabled(this.current_accessForward)
              .opacity(this.current_accessForward ? 1 : 0.5)
              .visibility(this.visible_when_no_panels_open_in_normal_mode())
              .animation(animation_default())
              .onClick(() => {
                this.go_forward()
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

            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.house'
            })// Home
              .visibility(this.visible_when_no_panels_open_in_normal_mode())
              .animation(animation_default())
              .onClick(() => {
                this.go_home()
              })

            TextInput({ text: this.search_input })
              .height(capsule_bar_height())
              .layoutWeight(1)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.font_color_title'))
              .visibility(this.visible_in_tablet_mode())
              .onFocus(() => {
                this.is_search_input_typing = true;
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

            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.magnifyingglass'
            })// Search
              .visibility(this.visible_when_typing_in_tablet_mode())
              .onClick(() => {
                this.submit_searching()
              })

            LinysShowButton({
              show: this.showing_more_options,
              text: $r('app.string.Index_more_title'),
              symbol_glyph_target: this.showing_more_options ? 'sys.symbol.chevron_down' : 'sys.symbol.dot_grid_2x2'
            })// More options
              .onClick(() => {
                this.show_more()
              })

            LinysShowButton({
              show: this.showing_bookmarks,
              text: $r('app.string.Index_bookmarks_title'),
              symbol_glyph_target: 'sys.symbol.bookmark'
            })// Bookmarks
              .onClick(() => {
                this.show_bookmarks();
              })

            LinysShowButton({
              symbol_glyph_target: 'sys.symbol.rectangle_stack',
              show: this.showing_tabs
            })// Tabs
              .onClick(() => {
                this.show_tabs()
              })

            LinysShowButton({
              show: this.showing_app_settings,
              text: $r('app.string.Index_app_settings_title'),
              symbol_glyph_target: this.showing_app_settings ? 'sys.symbol.chevron_down' : 'sys.symbol.gearshape'
            })// Settings
              .onClick(() => {
                this.show_settings()
              })

          } // Bottom Bar of controls
          .padding({
            top: this.settings_title_bar_position == "bottom" ? 12 : 0,
            bottom: !this.showing_app_settings && this.settings_title_bar_position == "top" && this.tablet_mode ?
              10 : 0,
            left: 15,
            right: 15
          })
          .width("100%")
          .animation(animation_default())

          Row({ space: 10 }) {
            TextInput({ text: this.search_input })
              .height(capsule_bar_height())
              .layoutWeight(1)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('app.color.font_color_title'))
              .caretColor($r('app.color.font_color_title'))
              .onFocus(() => {
                this.is_search_input_typing = true;
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

            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.magnifyingglass'
            })
              .visibility(this.visible_when_typing())
              .onClick(() => {
                this.submit_searching()
              })
          } // Bottom Bar of extended searching bar
          .visibility(this.visible_in_normal_mode())
          .padding({
            top: 10,
            bottom: !this.showing_app_settings && this.settings_title_bar_position == "top" ? 10 : 0,
            left: 15,
            right: 15
          })
          .width("100%")
          .animation(animation_default())

          Row() {
            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.qrcode'
            })
              .onClick(() => {

              })
          } // Bottom Bar of More Options
          .visibility(this.showing_more_options ? Visibility.Visible : Visibility.None)
          .padding({
            top: this.settings_title_bar_position == "top" ? 5 : 10,
            bottom: this.settings_title_bar_position == "top" ? 15 : 0,
            left: 15,
            right: 15
          })
          .width("100%")
          .animation(animation_default())

          LinysAppSettings({
            screen_width: this.screen_width,
            show: this.showing_app_settings,
            settings_title_bar_position: this.settings_title_bar_position
          })
            .padding({ top: 10 })
            .visibility(this.showing_app_settings ? Visibility.Visible : Visibility.None)
            .animation(animation_default())

        } // Bottom Bars
        .width("100%")
        .backgroundColor($r('app.color.block_color'))
        .alignRules(this.web_and_stuff_alignRules)
        .onAreaChange((_o, n) => {
          if (!this.showing_more_options && !this.is_search_input_typing && !this.showing_app_settings) {
            this.bottom_bar_height = n.height as number;
          }
        })
        .visibility(this.settings_title_bar_position == "" ? Visibility.Hidden : Visibility.Visible)
        .animation(this.showing_app_settings ? animation_default() : undefined)

      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.block_color'))
      .width("100%")
      .animation(animation_default())

      Row()// Bottom Bar Avoid
        .width("100%")
        .height(px2vp(this.bottomAvoidHeight))
        .backgroundColor($r('app.color.block_color'))
    }
    .height("100%")
    .width("100%")
    .onAppear(() => {
      console.log("[Meow][Index] Home Index READY")
    })
  }

  // the page

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

  visible_when_typing_in_tablet_mode() {
    return this.tablet_mode && this.is_search_input_typing ? Visibility.Visible : Visibility.None;
  }

  visible_when_no_panels_open_in_normal_mode() {
    let result: Visibility = Visibility.Visible;
    if (this.showing_more_options || this.showing_app_settings || this.showing_tabs || this.showing_bookmarks) {
      if (this.tablet_mode == false) {
        result = Visibility.None;
      }
    }
    return result;
  }

  // visible statuses

  is_dark_mode() {
    return this.current_color_mode == 0;
  }

  // other statuses

  submit_searching() {
    this.webViews_ready = true;

    if (this.search_input_unified != "") {
      let unified_url: string = unify_search_input_into_url(this.search_input)
      // unify input into a legal link
      unified_url = url_meow_to_resource(unified_url)
      // translate "meow://" into "resource://"
      this.bunch_of_tabs.loadUrl_onWorkingTab(unified_url)
    }
  }

  show_tabs() {
    if (!this.tablet_mode) {
      this.showing_more_options = false;
    }
    this.showing_bookmarks = false;

    this.showing_tabs = !this.showing_tabs;
  }

  show_bookmarks() {
    if (!this.tablet_mode) {
      this.showing_more_options = false;
    }
    this.showing_tabs = false;

    this.showing_bookmarks = !this.showing_bookmarks;
  }

  show_more() {
    if (!this.tablet_mode) {
      this.showing_tabs = false;
      this.showing_bookmarks = false;
    }
    // Close all other panels

    this.showing_app_settings = false;
    this.showing_more_options = !this.showing_more_options;
  }

  show_settings() {
    if (!this.tablet_mode) {
      this.showing_tabs = false;
      this.showing_bookmarks = false;
    }
    // Close all other panels

    this.showing_more_options = false;
    this.showing_app_settings = !this.showing_app_settings;
  }

  go_backward() {
    this.bunch_of_tabs.goBackward_onWorkingTab()
  }

  go_forward() {
    this.bunch_of_tabs.goForward_onWorkingTab()
  }

  refresh_page() {
    this.bunch_of_tabs.refresh_onWorkingTab()
    this.bunch_of_tabs.workingTab().update_is_loading(true)
  }

  stop_page() {
    this.bunch_of_tabs.stop_onWorkingTab()
    this.bunch_of_tabs.workingTab().update_is_loading(false)
    this.sync_list_info()
    this.update_current_info()
  }

  go_home() {
    this.bunch_of_tabs.loadUrl_onWorkingTab(home_url())
  }

  // control events

  update_search_input(content: string) {
    this.search_input = content
    this.search_input_unified = unify_search_input_into_url(content)
    this.search_input_unified = url_resource_to_meow(this.search_input_unified)
  }

  update_search_box_text(text: string) {
    this.search_input = url_resource_to_meow(text)
    // Update Input Search Box
  }

  update_current_info() {
    this.current_title = this.tab_titles[this.current_tab_index];
    this.current_url = this.tab_urls[this.current_tab_index];
    this.current_url = url_resource_to_meow(this.current_url);
    // translate "resource://" into "meow://"
    this.current_loading_progress = this.tab_loading_progresses[this.current_tab_index];
    this.current_is_loading = this.tab_is_loading[this.current_tab_index];
    // Set loading progress
  }

  sync_list_info() {
    this.tab_titles = this.bunch_of_tabs.get_all_titles()
    this.tab_urls = this.bunch_of_tabs.get_all_urls()
    this.tab_is_loading = this.bunch_of_tabs.get_all_is_loading();
    this.tab_loading_progresses = this.bunch_of_tabs.get_all_loading_progress()
  }

  // UI params

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
}
