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

  build() {
    Column({ space: 10 }) {
      Scroll() {
        Column({ space: 5 }) {
          Blank()
          ForEach(this.tab_titles, (title: string, key: number) => {
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
                  // Switch Tab
                })

              SymbolGlyph($r('sys.symbol.xmark'))
                .fontSize(20)
                .fontColor([$r('app.color.font_color_title')])
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  this.close_tab(key)
                })
            }
            .border({
              radius: 10,
              width: 2,
              color: this.current_tab_index == key ? $r('app.color.font_color_title') : "transparent"
            })
            .padding(10)
            .backgroundColor($r('app.color.block_color'))
            .width("100%")
            .height(undefined)
          })
        }
        .width("100%")
      } // Tab Buttons List
      .align(Alignment.Bottom)
      .edgeEffect(EdgeEffect.Spring)
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
  }

  // Tab controls

  new_tab() {
    this.current_tab_index = this.bunch_of_tabs.newTab()
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