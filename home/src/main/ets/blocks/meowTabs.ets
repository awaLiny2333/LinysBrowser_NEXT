import linysSymbol from '../components/linysSymbol';
import { bunch_of_tabs, tab_label } from '../hosts/bunch_of_tabs';
import { url_resource_to_meow } from '../utils/url_tools';
import { fontSize_Normal, home_url_default_blank } from '../hosts/bunch_of_defaults';
import {
  kv_store_get,
  kv_store_get_uint_8_array,
  kv_store_put,
  kv_store_put_uint_8_array
} from '../utils/kv_store_tools';
import { bunch_of_settings } from '../hosts/bunch_of_settings';


@Component
struct meowTabs {
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  @Link webViews_ready: boolean;
  @Link showing_tabs: boolean;
  @Link @Watch('on_did_switch_tab') current_tab_index: number;
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
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
  @State recover_tabs_finished: boolean = false;
  // Gateways
  @StorageLink('universal_load_url_gateway') @Watch('on_current_load_url') load_url_gateway: string = "";
  @StorageLink('universal_new_tab_gateway') @Watch('on_new_targeted_tab') new_tab_gateway: string = "";
  @StorageLink('universal_global_custom_ua_gateway') @Watch('on_global_custom_UA_change') global_custom_UA: string = "";

  async aboutToAppear() {

    // Get Data
    let home_url = await this.bunch_of_settings.get_setting_key('home_url') as string;
    let new_tab_url = await this.bunch_of_settings.get_setting_key('new_tab_url') as string;
    let start_up_option = await this.bunch_of_settings.get_setting_key('start_up_option') as string;
    let continue_tabs_count_string = await kv_store_get("continue_tabs_count");
    let continue_tabs_on_string = await kv_store_get("continue_tabs_on");
    let continue_tabs_count = 1;
    let continue_tabs_on = 0;

    this.bunch_of_tabs.start_up = start_up_option;
    this.bunch_of_tabs.new_tab_url = new_tab_url;
    this.bunch_of_tabs.home_url = home_url;

    if (continue_tabs_count_string == "undefined") {
      kv_store_put("continue_tabs_count", "1");
      continue_tabs_count = 1;
    } else {
      continue_tabs_count = Number.parseInt(continue_tabs_count_string);
    }

    if (continue_tabs_on_string == "undefined") {
      kv_store_put("continue_tabs_on", "0");
      continue_tabs_on = 0;
    } else {
      continue_tabs_on = Number.parseInt(continue_tabs_on_string);
    }

    // Log
    console.log("[Meow][meowTabs] Got continue_tabs_count: " + continue_tabs_count_string);
    console.log("[Meow][meowTabs] Got continue_tabs_on: " + continue_tabs_on_string);

    // Start Up
    if (start_up_option == "new tab") {
      this.new_tab(new_tab_url);
      if (new_tab_url != "") {
        this.webViews_ready = true;
      }

    } else if (start_up_option == "home") {
      if (home_url == "") {
        this.new_tab(home_url_default_blank());
      } else {
        this.webViews_ready = true;
        this.new_tab(home_url);
      }

    } else {
      // continue
      this.webViews_ready = true;
      let web_state_arrays: Uint8Array[] = []
      for (let index = 0; index < continue_tabs_count; index++) {
        let key = "continue_tabs_web_state_array_" + index.toString();
        let web_state_array = await kv_store_get_uint_8_array(key);
        web_state_arrays.push(web_state_array);
      }
      // Set to AppStorage
      AppStorage.setOrCreate('web_state_arrays', web_state_arrays);
      // Create new tabs
      for (let index = 0; index < web_state_arrays.length; index++) {
        let web_state_array = web_state_arrays[index];
        if (web_state_array.length > 0) {
          // console.log(web_state_array.length.toString())
          this.new_tab("", true);
        } else {
          this.new_tab("", false);
        }
      }
      // Try switch tab
      this.switch_tab(continue_tabs_on);
    }
    this.recover_tabs_finished = true;
  }

  build() {
    Column({ space: 10 }) {
      Scroll(this.scroll_controller) {
        Column({ space: 5 }) {
          ForEach(
            this.bunch_of_tabs.Labels,
            (Label: tab_label) => {
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
            (Label: tab_label) => Label.timestamp.toString()
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
        linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
          .onClick(() => {
            this.webViews_ready = true;
            this.new_tab("")
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
      console.log("[Meow][meowTabs] Tabs Panel READY")
    })
    .onAreaChange((_o, n) => {
      this.scroll_area_height = n.height as number - 60;
    })

  }

  // Tab controls

  /** @param target_url If url is "", then load the default new_tab_url set in this object.
   * @abstract While if new_tab_url is also not set ("" or undefined), then load default home_url().
   * */
  new_tab(url: string, recover_on_creation?: boolean) {
    this.current_tab_index = this.bunch_of_tabs.newTab(url, recover_on_creation);
    this.extension_area.push(0);

    if (this.scroll_animation_enabled) {
      for (let index = 0; index < this.offset_area.length; index++) {
        this.offset_area[index] += this.tab_height_default + 5;
        // Move downward for up going animation
      }
    }

    // Set offset for the new tab
    this.offset_area.push(this.tab_height_default + 1000)
    // Scroll to the new tab later
    this.count_down_for_scrolling_to_bottom = 20;

    if (this.recover_tabs_finished) {
      let store_tabs_count = this.offset_area.length.toString();
      console.log("[Meow][meowTabs] Stored Tabs Count: " + store_tabs_count)
      // Store tabs count
      kv_store_put("continue_tabs_count", store_tabs_count);
    }
  }

  on_did_switch_tab() {
    if (this.recover_tabs_finished) {
      // Store where am I
      let where_am_i = this.current_tab_index.toString();
      console.log("[Meow][meowTabs] Stored Where Am I: " + where_am_i)
      kv_store_put("continue_tabs_on", where_am_i);
    }
  }

  switch_tab(target: number) {
    console.log('switch tab to ' + target.toString())
    if (this.current_tab_index == target) {
      this.showing_tabs = false;
    }

    // Switch
    this.current_tab_index = this.bunch_of_tabs.switchToTab(target)
    if (this.recover_tabs_finished) {
      // Update history
      this.update_backward_forward_access()
    }
    // Set CURRENT variables
    this.update_current_info()
    // Update Input Search Box
    this.update_search_box_text(this.current_url)
  }

  close_tab(target: number) {
    // console.log(target.toString() + " / " + this.offset_area.length.toString())
    if (target >= this.offset_area.length) {
      // Some kind of bug, idk why but this is essential when closing tabs quickly
      console.error("[Meow][LinysTabs][ERROR] Ran into the weird bug of target >= this.offset_area.length")
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

    // Close
    this.current_tab_index = this.bunch_of_tabs.closeTab(target, home_url_default_blank())
    // Update history
    this.update_backward_forward_access()
    // Get synced lists
    this.sync_list_info()
    // Set CURRENT variables
    this.update_current_info()
    // Update Input Search Box
    this.update_search_box_text(this.current_url)

    if (this.recover_tabs_finished) {
      let store_tabs_count = this.offset_area.length.toString();
      console.log("[Meow][meowTabs] Store Tabs Count: " + store_tabs_count)
      // Store tabs count
      kv_store_put("continue_tabs_count", store_tabs_count);
      this.web_states_set_app_storage_and_put_kv_store();
    }
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
    // Count down
    if (this.count_down_for_scrolling_to_bottom > 0) {
      this.count_down_for_scrolling_to_bottom -= 1;
      if (this.count_down_for_scrolling_to_bottom == 1) {
        this.scroll_controller.scrollEdge(Edge.Bottom)
        // Execute
      }
    }
  }

  web_states_set_app_storage_and_put_kv_store() {
    // Store tabs web states
    let web_state_arrays = this.bunch_of_tabs.get_all_web_states();
    AppStorage.setOrCreate("web_state_arrays", web_state_arrays);
    for (let index = 0; index < web_state_arrays.length; index++) {
      const element = web_state_arrays[index];
      kv_store_put_uint_8_array("continue_tabs_web_state_array_" + index.toString(), element);
    }
  }

  // Events

  on_global_custom_UA_change() {
    this.bunch_of_tabs.set_global_custom_UA(this.global_custom_UA);
  }

  on_new_targeted_tab() {
    if (this.new_tab_gateway != "") {
      this.webViews_ready = true;
      this.new_tab(this.new_tab_gateway);
      this.new_tab_gateway = "";
    }
  }

  on_current_load_url() {
    if (this.load_url_gateway != "") {
      this.webViews_ready = true;
      this.bunch_of_tabs.loadUrl_onWorkingTab(this.load_url_gateway);
      this.load_url_gateway = "";
    }
  }
}

export default meowTabs;