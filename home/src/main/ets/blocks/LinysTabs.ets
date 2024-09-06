import LinysSymbol from './LinysSymbol';
import { BunchOfTabs } from '../hosts/BunchOfTabs';
import { url_resource_to_meow } from '../utils/url_tools';

@Component
struct LinysTabs {
  @StorageProp('currentColorMode') current_color_mode: number = 0;
  @Link bunch_of_tabs: BunchOfTabs;
  @Prop show_webViews: boolean;
  @Prop tablet_mode: boolean;
  @Prop showing_tabs: boolean;
  @Prop animation_default: AnimateParam;
  @Link current_tab_index: number;
  // Controls and environments
  @Link tab_titles: string[];
  @Link current_title: string;
  @Link tab_urls: string[];
  @Link current_url: string;
  @Link tab_loading_progresses: number[];
  @Link current_loading_progress: number;
  @Link tab_is_loading: boolean[];
  @Link current_is_loading: boolean;
  // Info / Statuses of bunch of tabs
  @Link current_accessForward: boolean;
  @Link current_accessBackward: boolean;
  @Link search_input: string;
  // Other Info / Statuses
  @State extension_area: number[] = [];
  @State offset_area: number[] = [];
  @State count_down_for_switching_back_to_spring: number = 0;
  // Animation info
  tab_height_default: number = 46;
  scroll_controller: Scroller = new Scroller();

  build() {
    Column({ space: 10 }) {
      Scroll(this.scroll_controller) {
        Column({ space: 5 }) {
          ForEach(this.tab_titles, (title: string, key: number) => {
            RelativeContainer() {
              Row() {
                Text(title == "" ? "Meow" : title)
                  .padding({ left: 2 })
                  .fontSize(20)
                  .fontColor($r('app.color.font_color_title'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
                  .onClick(() => {
                    this.switch_tab(key)
                  })

                SymbolGlyph($r('sys.symbol.xmark'))
                  .fontSize(20)
                  .fontColor([$r('app.color.font_color_title')])
                  .fontWeight(FontWeight.Medium)

              } // Title and xmark
              .width("100%")
              .height(this.tab_height_default)
              .border({
                radius: 10,
                width: 2,
                color: this.current_tab_index == key ? $r('app.color.font_color_title') : "transparent"
              })
              .padding(10)
              .backgroundColor($r('app.color.block_color'))
              .alignRules({
                middle: { anchor: "__container__", align: HorizontalAlign.Center },
                top: { anchor: "__container__", align: VerticalAlign.Top }
              })
              .offset({ y: this.offset_area[key] })

              Column() {
              } // The True Tab Closer
              .width(70)
              .height("100%")
              .alignRules({
                middle: { anchor: "__container__", align: HorizontalAlign.End },
                center: { anchor: "__container__", align: VerticalAlign.Center }
              })
              .onClick(() => {
                this.close_tab(key)
              })
            }
            .width("100%")
            .height(this.tab_height_default + this.extension_area[key])
          })
        }
        .width("100%")
      } // Tab Buttons List
      .direction(Direction.Rtl)
      .align(Alignment.Bottom)
      .edgeEffect(this.count_down_for_switching_back_to_spring == 0 ? EdgeEffect.Spring : EdgeEffect.None)
      .width("100%")
      .layoutWeight(1)

      Row({ space: 10 }) {
        Blank()
        LinysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
          .onClick(() => {
            this.new_tab()
          })
      } // New Tab Button
      .width("100%")

    } // Tabs Panel
    .padding(10)
    .width("100%")
    .height("100%")
    .onAppear(() => {
      this.extension_area = [];
      this.offset_area = [];
      for (let i = 0; i < this.bunch_of_tabs.Tabs.length; i++) {
        this.extension_area.push(0);
        this.offset_area.push(0);
      }
      // Init extension_area
      setInterval(() => {
        for (let index = 0; index < this.extension_area.length; index++) {
          this.extension_area[index] += (0 - this.extension_area[index]) / 6;
          this.offset_area[index] += (0 - this.offset_area[index]) / 6;
          // Shrink areas
        }
        if (this.count_down_for_switching_back_to_spring > 0) {
          this.count_down_for_switching_back_to_spring -= 1;
        }
      }, 10)
    })
  }

  // Tab controls

  new_tab() {
    this.current_tab_index = this.bunch_of_tabs.newTab()
    this.extension_area.push(0)
    for (let index = 0; index < this.offset_area.length; index++) {
      this.offset_area[index] += this.tab_height_default + 5;
      // Move downward for up going animation
    }
    this.offset_area.push(this.tab_height_default + 400)
    setTimeout(() => {
      this.scroll_controller.scrollBy(0, Number.MAX_VALUE)
    }, 20)
  }

  switch_tab(target: number) {
    this.current_tab_index = this.bunch_of_tabs.switchToTab(target)
    // Switch
    this.update_backward_forward_access()
    // Update history
    this.update_current_info()
    // Set CURRENT variables
    this.update_search_box_text(this.current_url)
    // Update Input Search Box
  }

  close_tab(target: number) {
    if (target != 0) {
      this.extension_area[target-1] += this.tab_height_default + this.extension_area[target];
      // If isn't closing the top most tab
    }
    if (this.offset_area.length == 1) {
      // If closing the last tab
      this.offset_area[0] = this.tab_height_default + 400;
    } else {
      // If not closing the last tab
      this.extension_area.splice(target, 1)
      this.offset_area.splice(target, 1)
    }

    this.count_down_for_switching_back_to_spring += 10;

    // Delete this area length
    this.current_tab_index = this.bunch_of_tabs.closeTab(target, this.home_url())
    //Close
    this.update_backward_forward_access()
    // Update history
    this.sync_list_info()
    // Get synced lists
    this.update_current_info()
    // Set CURRENT variables
    this.update_search_box_text(this.current_url)
    // Update Input Search Box
  }

  // Utils

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

  update_backward_forward_access() {
    this.current_accessBackward = this.bunch_of_tabs.workingTab().controller.accessBackward()
    this.current_accessForward = this.bunch_of_tabs.workingTab().controller.accessForward()
  }

  update_search_box_text(text: string) {
    this.search_input = url_resource_to_meow(text)
    // Update Input Search Box
  }

  // Environment

  is_dark_mode() {
    return this.current_color_mode == 0;
  }

  home_url() {
    return this.is_dark_mode() ? 'meow://home_dark' : 'meow://home_light'
  }
}

export default LinysTabs;