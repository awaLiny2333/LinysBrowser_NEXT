import LinysSymbol from '../components/LinysSymbol';
import { BunchOfTabs, TabLabel } from '../hosts/BunchOfTabs';
import { url_resource_to_meow } from '../utils/url_tools';
import { fontSize_Normal, home_url } from '../hosts/BunchOfSettings';


@Component
struct LinysTabs {
  @Link bunch_of_tabs: BunchOfTabs;
  @Prop show_webViews: boolean;
  @Prop tablet_mode: boolean;
  @Prop showing_tabs: boolean;
  @Prop animation_default: AnimateParam;
  @Link current_tab_index: number;
  @Link @Watch('universal_new_tab') universal_new_tab_gateway: string | undefined;
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
  @State count_down_for_scrolling_to_bottom: number = 0;
  // Animation info
  tab_height_default: number = 42;
  scroll_controller: Scroller = new Scroller();
  @State scroll_area_height: number = 0;
  @State scroll_animation_enabled: boolean = true;

  build() {
    Column({ space: 10 }) {
      Scroll(this.scroll_controller) {
        Column({ space: 5 }) {
          ForEach(
            this.bunch_of_tabs.Labels,
            (Label: TabLabel) => {
              RelativeContainer() {
                Row() {
                  Text(this.tab_titles[Label.index_key] == "" ? "Meow" : this.tab_titles[Label.index_key])
                    .padding({ left: 2 })
                    .fontSize(fontSize_Normal())
                    .fontColor($r('app.color.font_color_title'))
                    .fontWeight(Label.index_key == this.current_tab_index ? FontWeight.Medium : undefined)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .layoutWeight(1)

                  SymbolGlyph($r('sys.symbol.xmark'))
                    .fontSize(fontSize_Normal())
                    .fontColor([$r('app.color.font_color_title')])
                    .fontWeight(FontWeight.Medium)

                } // Title and xmark
                .border({
                  radius: 10,
                  width: 2,
                  color: this.current_tab_index == Label.index_key ? $r('app.color.font_color_title') : "transparent"
                })
                .animation({ duration: 100 })
                .width("100%")
                .height(this.tab_height_default)
                .padding(10)
                .backgroundColor($r('app.color.block_color'))
                .offset({ y: this.offset_area[Label.index_key] })
                .alignRules({
                  middle: { anchor: "__container__", align: HorizontalAlign.Center },
                  top: { anchor: "__container__", align: VerticalAlign.Top }
                })
                .onClick(() => {
                  this.switch_tab(Label.index_key)
                })

                Column() {
                } // The True Tab Closer
                .width(70)
                .height("100%")
                .alignRules({
                  middle: { anchor: "__container__", align: HorizontalAlign.End },
                  center: { anchor: "__container__", align: VerticalAlign.Center }
                })
                .onClick(() => {
                  this.close_tab(Label.index_key)
                })

              }
              .width("100%")
              .height(this.tab_height_default + this.extension_area[Label.index_key])
            },
            (Label: TabLabel) => Label.timestamp.toString()
          )
        }
        .width("100%")
        .onAreaChange((_o, n) => {
          let my_height = n.height as number;
          if (my_height > this.scroll_area_height) {
            // Scroll Enabled, animation disabled
            this.scroll_animation_enabled = false;
          } else {
            // Scroll Disabled, animation enabled
            this.scroll_animation_enabled = true;
          }
        })

      } // Tab Buttons List
      .direction(Direction.Rtl)
      .align(Alignment.Bottom)
      .edgeEffect(this.count_down_for_switching_back_to_spring == 0 ? EdgeEffect.Spring : EdgeEffect.None)
      .width("100%")
      .height(this.scroll_area_height)

      Row({ space: 10 }) {
        Blank()
        LinysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
          .onClick(() => {
            this.new_tab(home_url())
          })
      } // New Tab Button
      .width("100%")

    } // Tabs Panel
    .justifyContent(FlexAlign.End)
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
        this.on_timer()
      }, 10)
      // Set Task to calculate animation
      console.log("[Meow][LinysTabs] Tabs Panel READY")
    })
    .onAreaChange((_o, n) => {
      this.scroll_area_height = n.height as number - 60;
    })

  }

  // Tab controls

  new_tab(url: string) {
    this.current_tab_index = this.bunch_of_tabs.newTab(url)
    this.extension_area.push(0)

    if (this.scroll_animation_enabled) {
      for (let index = 0; index < this.offset_area.length; index++) {
        this.offset_area[index] += this.tab_height_default + 5;
        // Move downward for up going animation
      }
    }

    this.offset_area.push(this.tab_height_default + 1000)
    // Set offset for the new tab
    this.count_down_for_scrolling_to_bottom = 20;
    // Scroll to the new tab later
  }

  universal_new_tab() {
    if (this.universal_new_tab_gateway !== undefined) {
      this.new_tab(this.universal_new_tab_gateway);
      this.universal_new_tab_gateway = undefined;
    }
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
    console.log(target.toString() + " / " + this.offset_area.length.toString())
    if (target >= this.offset_area.length) {
      // Some kind of bug, idk why but this is essential when closing tabs quickly
      console.log("[Meow][LinysTabs][ERROR] Ran into the weird bug of target >= this.offset_area.length")
      return;
    }

    if (target != 0) {
      this.extension_area[target-1] += this.tab_height_default + this.extension_area[target];
      // If isn't closing the top most tab
    }
    if (this.offset_area.length == 1) {
      // If closing the last tab
      this.offset_area[0] = this.tab_height_default + 1000;
    } else {
      // If not closing the last tab
      this.extension_area.splice(target, 1)
      this.offset_area.splice(target, 1)
    }

    this.count_down_for_switching_back_to_spring += 10;
    // Set Scroll spring on edge effect off
    // So that when closing the last tab, it is always stuck at the bottom
    // Or we'll have to wait for the spring animation to finish, bringing the last tab button down.

    // Delete this area length
    this.current_tab_index = this.bunch_of_tabs.closeTab(target, home_url())
    // Close
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

  on_timer() {
    for (let index = 0; index < this.extension_area.length; index++) {
      this.extension_area[index] += (0 - this.extension_area[index]) / 6;
      this.offset_area[index] += (0 - this.offset_area[index]) / 5;
      // Shrink areas
    }
    if (this.count_down_for_switching_back_to_spring > 0) {
      this.count_down_for_switching_back_to_spring -= 1;
    }
    if (this.count_down_for_scrolling_to_bottom > 0) {
      this.count_down_for_scrolling_to_bottom -= 1;
      if (this.count_down_for_scrolling_to_bottom == 1) {
        this.scroll_controller.scrollEdge(Edge.Bottom)
        // Execute
      }
    }
  }
}

export default LinysTabs;