import LinysProgress from '../blocks/LinysProgress';
import LinysSymbol from '../blocks/LinysSymbol';
import LinysTabs from '../blocks/LinysTabs';
import LinysWebView from '../blocks/LinysWebView';
import LinysBookmarks from '../blocks/LinysBookmarks';
import { BunchOfTabs } from '../hosts/BunchOfTabs';
import { BunchOfBookmarks } from '../hosts/BunchOfBookmarks';
import { unify_search_input_into_url, url_meow_to_resource, url_resource_to_meow } from '../utils/url_tools';
import { animation_default, fontSize_Icon_Button, fontSize_Large, fontSize_Normal } from '../hosts/BunchOfSettings';

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

  aboutToAppear(): void {

  }

  build() {
    Column() {
      Row()// Top Bar Avoid
        .width("100%")
        .height(px2vp(this.topAvoidHeight))
        .backgroundColor($r('app.color.block_color'))

      RelativeContainer() {

        Column() {
          Row() {
            Scroll() {
              Row() {

                Scroll() {
                  Column() {
                    LinysBookmarks({
                      bunch_of_tabs: this.bunch_of_tabs,
                      bunch_of_bookmarks: this.bunch_of_bookmarks,
                      animation_default: animation_default(),
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
          .layoutWeight(1)

          Column()// Bottom Avoid
            .height(50 + (this.tablet_mode ? 0 : 40))

        } // Webview Base
        .alignRules({
          middle: { anchor: "__container__", align: HorizontalAlign.Center },
          center: { anchor: "__container__", align: VerticalAlign.Center }
        })
        .height("100%")
        .width("100%")
        .backgroundColor($r('app.color.start_window_background'))
        .onAreaChange((_o, n) => {
          this.screen_width = n.width as number
          this.tablet_mode = this.screen_width > 500
        })

        Column() {
          LinysProgress({ percentage: this.current_loading_progress, is_loading: this.current_is_loading })
          Column() {
          } // Bottom Avoid
          .height(50 + (this.tablet_mode ? 0 : 40))
        } // Loading Bar
        .alignRules({
          middle: { anchor: "__container__", align: HorizontalAlign.Center },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
        })
        .width("100%")

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
          .padding({ top: 15, left: 15, right: 15 })
          .width("100%")
          .backgroundColor($r('app.color.block_color'))
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
          .padding({ top: 15, left: 16, right: 15 })
          .width("100%")
          .backgroundColor($r('app.color.block_color'))
          .visibility(this.showing_more_options ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

          Row({ space: 12 }) {
            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.arrow_left'
            })
              .enabled(this.current_accessBackward)
              .opacity(this.current_accessBackward ? 1 : 0.5)
              .onClick(() => {
                this.go_backward()
              })

            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.arrow_right'
            })
              .enabled(this.current_accessForward)
              .opacity(this.current_accessForward ? 1 : 0.5)
              .onClick(() => {
                this.go_forward()
              })

            SymbolGlyph(!this.current_is_loading ? $r('sys.symbol.arrow_clockwise') : $r('sys.symbol.xmark'))
              .fontSize(fontSize_Icon_Button())
              .fontColor([$r('app.color.font_color_title')])
              .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.current_is_loading)
              .onClick(() => {
                if (this.current_is_loading) {
                  this.stop_page()
                } else {
                  this.refresh_page()
                }
              })

            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.house'
            })
              .onClick(() => {
                this.go_home()
              })

            TextInput({ text: this.search_input })
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
              symbol_glyph_target: 'sys.symbol.bookmark'
            })
              .onClick(() => {
                this.show_bookmarks();
              })

            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.magnifyingglass'
            })
              .visibility(this.visible_when_typing_in_tablet_mode())
              .onClick(() => {
                this.submit_searching()
              })

            LinysSymbol({
              symbol_glyph_target: 'sys.symbol.square_grid_2x2'
            })
              .onClick(() => {
                this.show_tabs()
              })

            SymbolGlyph(this.showing_more_options ? $r('sys.symbol.chevron_down') : $r('sys.symbol.dot_grid_2x2'))
              .fontSize(fontSize_Icon_Button())
              .fontColor([$r('app.color.font_color_title')])
              .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), this.showing_more_options)
              .onClick(() => {
                this.show_more()
              })

          } // Bottom Bar of controls
          .padding({ top: 10, left: 15, right: 15 })
          .width("100%")
          .backgroundColor($r('app.color.block_color'))

          Row({ space: 10 }) {
            TextInput({ text: this.search_input })
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
          .padding({ top: 15, left: 15, right: 15 })
          .width("100%")
          .backgroundColor($r('app.color.block_color'))
          .animation(animation_default())

          WaterFlow() {
            FlowItem() {
              LinysSymbol({
                symbol_glyph_target: 'sys.symbol.qrcode'
              })
                .onClick(() => {

                })
            }
          } // Bottom Bar of More Options
          .rowsGap(15)
          .columnsTemplate("1fr ".repeat(Math.floor(this.screen_width / 47)))
          .visibility(this.showing_more_options ? Visibility.Visible : Visibility.None)
          .padding({ top: 16, left: 15, right: 15 })
          .width("100%")
          .height(Math.ceil(3 / Math.floor(this.screen_width / 47)) * 47)
          .backgroundColor($r('app.color.block_color'))
          .animation(animation_default())

        } // Bottom Bars
        .width("100%")
        .backgroundColor($r('app.color.block_color'))
        .animation(animation_default())
        .alignRules({
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          middle: { anchor: "__container__", align: HorizontalAlign.Center }
        })
      }
      .layoutWeight(1)
      .width("100%")

      Row()// Bottom Bar Avoid
        .width("100%")
        .height(px2vp(this.bottomAvoidHeight))
        .backgroundColor($r('app.color.block_color'))
    }
    .height("100%")
    .width("100%")
    .backgroundColor($r('app.color.block_color'))
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
    this.showing_more_options = false;
    this.showing_bookmarks = false;

    this.showing_tabs = !this.showing_tabs;
  }

  show_more() {
    if (!this.tablet_mode) {
      this.showing_tabs = false;
      this.showing_bookmarks = false;
    }
    // Close all other panels

    this.showing_more_options = !this.showing_more_options;
  }

  show_bookmarks() {
    this.showing_tabs = false;
    this.showing_more_options = false;

    this.showing_bookmarks = !this.showing_bookmarks;
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
    this.bunch_of_tabs.loadUrl_onWorkingTab(this.home_url())
  }

  // control events

  home_url() {
    return this.is_dark_mode() ? 'meow://home_dark' : 'meow://home_light'
  }

  // default stuffs

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
}
