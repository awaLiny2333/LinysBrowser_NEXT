import linysSymbol from '../components/linysSymbol';
import { bunch_of_tabs, tab_label } from '../hosts/bunch_of_tabs';
import { url_resource_to_meow } from '../utils/url_tools';
import { animation_default, fontSize_Large, fontSize_Normal, url_default_blank } from '../hosts/bunch_of_defaults';
import { kv_store_get, kv_store_put } from '../utils/kv_store_tools';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import linysShowButton from '../components/linysShowButton';
import linysText from '../components/linysText';
import { sandbox_open_array_sync } from '../utils/storage_tools';

@Component
struct meowTabs {
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  @StorageLink('showing_tabs') showing_tabs: boolean = false;
  @StorageLink('current_main_tab_index') @Watch('on_did_switch_tab') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') @Watch('on_did_switch_tab') current_sub_tab_index: number = -1;
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('pathDir') pathDir: string = "";
  // Controls and environments
  @StorageLink('tab_titles') tab_titles: string[] = []
  @StorageLink('current_title') current_title: string = "=￣ω￣=";
  @StorageLink('tab_urls') tab_urls: string[] = []
  @StorageLink('current_url') current_url: string = "=￣ω￣=";
  @StorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0]
  @StorageLink('current_loading_progress') current_loading_progress: number = 0
  @StorageLink('tab_is_loading') tab_is_loading: boolean[] = [true]
  @StorageLink('current_is_loading') current_is_loading: boolean = true
  // Web control statuses
  @StorageLink('current_accessForward') current_accessForward: boolean = false;
  @StorageLink('current_accessBackward') current_accessBackward: boolean = false;
  @Link search_input: string;
  @Link is_search_input_typing: boolean;
  // Other Info / Statuses
  @State recover_tabs_finished: boolean = false;
  @StorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @Link settings_tabs_style: string;
  @Link use_adblock: boolean;
  @Link adblock_exceptions: string[];
  // Animation info
  tab_height_default: number = 42;
  scroll_controller: Scroller = new Scroller();
  @State extension_area: number[] = [];
  @State offset_area: number[] = [];
  @State count_down_for_switching_back_to_spring: number = 0;
  @State count_down_for_scrolling_to_bottom: number = 0;
  @State scroll_area_height: number = 0;
  @State scroll_animation_enabled: boolean = true;
  @State paralleow_description_height: number = 0;
  @StorageLink('tab_animation') tab_animation: AnimateParam = animation_default();
  // Gateways
  @StorageLink('universal_load_url_gateway') @Watch('on_current_load_url') load_url_gateway: string = "";
  @StorageLink('universal_new_tab_gateway') @Watch('on_new_targeted_tab') new_tab_gateway: string = "";
  @StorageLink('universal_close_tab_gateway') @Watch('on_targeted_close_tab') close_tab_gateway: number = -1;
  @StorageLink('universal_tab_button_clicked_gateway') @Watch('on_uni_tab_button_clicked') uni_tab_button_clicked:
    number = -1;
  @StorageLink('universal_global_custom_ua_gateway') @Watch('on_global_custom_UA_change') global_custom_UA: string = "";
  // Colors
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  async aboutToAppear() {
    // Get Data
    let home_url = await this.bunch_of_settings.get('home_url') as string;
    let new_tab_url = await this.bunch_of_settings.get('new_tab_url') as string;
    let start_up_option = await this.bunch_of_settings.get('start_up_option') as string;
    let continue_tabs_count_string = await kv_store_get("continue_tabs_count");
    let continue_tabs_main_on_string = await kv_store_get("continue_tabs_main_on");
    let continue_tabs_sub_on_string = await kv_store_get("continue_tabs_sub_on");
    let continue_tabs_count = 0;
    let continue_tabs_main_on = 0;
    let continue_tabs_sub_on = 0;

    this.bunch_of_tabs.start_up = start_up_option;
    this.bunch_of_tabs.new_tab_url = new_tab_url;
    this.bunch_of_tabs.home_url = home_url;

    if (continue_tabs_count_string == "undefined") {
      kv_store_put("continue_tabs_count", "0");
      continue_tabs_count = 0;
    } else {
      continue_tabs_count = Number.parseInt(continue_tabs_count_string);
    }

    if (continue_tabs_main_on_string == "undefined") {
      kv_store_put("continue_tabs_main_on", "0");
      continue_tabs_main_on = 0;
    } else {
      continue_tabs_main_on = Number.parseInt(continue_tabs_main_on_string);
    }

    if (continue_tabs_sub_on_string == "undefined") {
      kv_store_put("continue_tabs_sub_on", "-1");
      continue_tabs_sub_on = -1;
    } else {
      continue_tabs_sub_on = Number.parseInt(continue_tabs_sub_on_string);
    }

    // Log
    console.log("[Meow][meowTabs] Got continue_tabs_count: " + continue_tabs_count_string);
    console.log("[Meow][meowTabs] Got continue_tabs_main_on: " + continue_tabs_main_on_string);
    console.log("[Meow][meowTabs] Got continue_tabs_sub_on: " + continue_tabs_sub_on_string);

    // Start Up: generate / recover tabs
    if (start_up_option == "new tab") {
      this.new_tab(new_tab_url);
      if (new_tab_url == "") {
        // If is default blank page
      } else {

      }
      this.switch_tab(0);

    } else if (start_up_option == "home") {
      if (home_url == "") {
        this.new_tab(url_default_blank());
      } else {

        this.new_tab(home_url);
      }
      this.switch_tab(0);

    } else {
      // continue
      // Prepare web states
      let web_state_arrays_to_restore: Uint8Array[] = [];
      for (let index = 0; index < continue_tabs_count; index++) {
        // Read continue tabs data
        let key = "continue_tabs_web_state_array_" + index.toString();
        let array_buffer = sandbox_open_array_sync(key);
        if (array_buffer) {
          web_state_arrays_to_restore.push(new Uint8Array(array_buffer));
        }
      }

      // Save to AppStorage for restoration use
      AppStorage.setOrCreate('restore_web_state_arrays', web_state_arrays_to_restore);

      // Create new tabs
      for (let index = 0; index < web_state_arrays_to_restore.length; index++) {
        let web_state_array = web_state_arrays_to_restore[index];
        if (web_state_array.length > 0) {
          this.new_tab("", true);
        } else {
          this.new_tab("", false);
        }
      }

      // Try to switch tab
      this.tab_animation = { duration: 0 };
      this.switch_tab(continue_tabs_main_on);
      this.sync_all_list_info();

      // Recover Paralleow
      if (continue_tabs_sub_on < this.tab_titles.length) {
        this.current_sub_tab_index = continue_tabs_sub_on;
      }
    }

    this.recover_tabs_finished = true;
  }

  build() {
    Column({ space: 10 }) {
      Scroll(this.scroll_controller) {
        Column({ space: 5 }) {
          ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
            RelativeContainer() {
              Row() {
                Text("󰇀")
                  .padding({ right: 5 })
                  .fontSize(fontSize_Large())
                  .fontColor(this.color_current_font)
                  .fontWeight((this.current_main_tab_index == Label.index_key ||
                    this.current_sub_tab_index == Label.index_key)
                    ? FontWeight.Medium : undefined)
                  .visibility(this.current_sub_tab_index == Label.index_key ? Visibility.Visible : Visibility.None)
                  .animation(animation_default())
                  .offset({ y: -2 })

                Text(this.tab_titles[Label.index_key] == "" ? "Meow" : this.tab_titles[Label.index_key])
                  .padding({ left: 2 })
                  .fontSize(fontSize_Normal())
                  .fontColor(this.color_current_font)
                  .fontWeight((this.current_main_tab_index == Label.index_key ||
                    this.current_sub_tab_index == Label.index_key)
                    ? FontWeight.Medium : undefined)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)

                SymbolGlyph($r('sys.symbol.xmark'))
                  .fontSize(fontSize_Normal())
                  .fontColor([this.color_current_font])
                  .fontWeight(FontWeight.Medium)

              } // Title and xmark
              .border({
                radius: 10,
                width: 2,
                color: (this.current_main_tab_index == Label.index_key ||
                  this.current_sub_tab_index == Label.index_key)
                  ? this.color_current_font : "transparent"
              })
              .animation({ duration: 100 })
              .width("100%")
              .height(this.tab_height_default)
              .padding(10)
              .backgroundColor(this.color_current_secondary)
              .offset({ y: this.offset_area[Label.index_key] })
              .alignRules({
                middle: { anchor: "__container__", align: HorizontalAlign.Center },
                top: { anchor: "__container__", align: VerticalAlign.Top }
              })
              .onClick(() => {
                this.click_tab_button(Label.index_key);
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
          }, (Label: tab_label) => Label.timestamp.toString())

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
      .height(this.scroll_area_height -
        (this.choosing_paralleow || this.current_sub_tab_index >= 0 ? this.paralleow_description_height : 0))
      .animation(animation_default())

      Row({ space: 10 }) {
        Blank()

        linysShowButton({
          symbol_glyph_target: 'sys.symbol.map',
          show: this.choosing_paralleow || this.current_sub_tab_index >= 0,
          text: this.choosing_paralleow ? $r('app.string.Paralleow_choose_a_tab') : $r('app.string.Paralleow')
        })
          .onClick(() => {
            this.choose_paralleow();
          })
          .visibility(this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden)
          .animation(animation_default())

        linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
          .onClick(() => {

            this.new_tab("")
          })
      } // New Tab and Paralleow Button
      .width("100%")

      Scroll() {
        linysText({ text: $r('app.string.Paralleow_description'), max_lines: 4 })
          .onAreaChange((_o, n) => {
            this.paralleow_description_height = n.height as number + 16;
          })
      } // Paralleow Introduction
      .align(Alignment.TopStart)
      .width("100%")
      .height(this.choosing_paralleow || this.current_sub_tab_index >= 0 ? this.paralleow_description_height : 0)
      .visibility(this.choosing_paralleow || this.current_sub_tab_index >= 0 ? Visibility.Visible : Visibility.None)
      .animation(animation_default())
      .scrollBar(BarState.Off)
      .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })

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
        this.on_timer();
      }, 10)
      // Set Task to calculate animation
      console.log("[Meow][meowTabs] Tabs Panel READY")
    })
    .onAreaChange((_o, n) => {
      this.scroll_area_height = n.height as number - 60;
    })
  }

  // Tab controls

  /**
   * Creates a new tab.
   * @param target_url A string, if url is "", then load the default new_tab_url set in this object.
   * @param do_recovery A boolean, if set true, then the tab will restore the serialized web state in
   * @description While if new_tab_url is also not set ("" or undefined), then will load the url_default_blank().
   * */
  new_tab(target_url: string, do_recovery?: boolean) {
    this.tab_animation = { duration: 0 };

    this.current_main_tab_index = this.bunch_of_tabs.newTab(target_url, do_recovery);
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

    if (!do_recovery) {
      let store_tabs_count = this.offset_area.length.toString();
      console.log("[Meow][meowTabs] Stored Tabs Count: " + store_tabs_count)
      // Store tabs count
      kv_store_put("continue_tabs_count", store_tabs_count);
    }
  }

  switch_tab(target: number) {
    if (!this.tablet_mode) {
      // Auto close panel
      this.showing_tabs = false;
    }

    this.choosing_paralleow = false;

    // Switch
    this.current_main_tab_index = this.bunch_of_tabs.switchToTab(target);
    console.log('[Meow][meowTabs] Switch to tab ' + this.current_main_tab_index.toString())
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
    this.tab_animation = { duration: 0 };

    // console.log(target.toString() + " / " + this.offset_area.length.toString())
    if (target >= this.offset_area.length) {
      // Some kind of bug, idk why but this is essential when closing tabs quickly
      console.error("[Meow][LinysTabs][ERROR] Ran into the weird bug of target >= this.offset_area.length")
      return;
    }

    if (target == this.current_sub_tab_index || target == this.current_main_tab_index) {
      // Turn paralleow off if closing any of the two
      console.log('[Meow][LinysTabs] Turn Paralleow off')
      this.current_sub_tab_index = -1;
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
    this.current_main_tab_index = this.bunch_of_tabs.closeTab(target, url_default_blank())
    // Update history
    this.update_backward_forward_access()
    // Get synced lists
    this.sync_all_list_info()
    // Set CURRENT variables
    this.update_current_info()
    // Update Input Search Box
    this.update_search_box_text(this.current_url)

    if (this.recover_tabs_finished) {
      let store_tabs_count = this.offset_area.length.toString();
      console.log("[Meow][meowTabs] Store Tabs Count: " + store_tabs_count)
      // Store tabs count
      kv_store_put("continue_tabs_count", store_tabs_count);
    }

    if (this.current_main_tab_index == this.current_sub_tab_index) {
      // if Paralleow crash then turn off
      this.current_sub_tab_index = -1;
    }

    if (this.tab_titles.length == 1) {
      // if only 1 tab left then reset Paralleow stuff
      this.current_sub_tab_index = -1;
      this.choosing_paralleow = false;
    }
  }

  choose_paralleow() {
    if (this.choosing_paralleow) {
      // if is choosing, cancel choosing, back to no paralleow
      this.choosing_paralleow = false;
    } else {
      if (this.current_sub_tab_index < 0) {
        // if haven't chosen one, then start to choose
        this.choosing_paralleow = true;
      } else {
        // Quit Paralleow
        this.choosing_paralleow = false;
        this.current_sub_tab_index = -1;
      }
    }
  }

  switch_paralleow() {
    let new_sub = this.current_main_tab_index;
    this.switch_tab(this.current_sub_tab_index);
    this.current_sub_tab_index = new_sub;
  }

  // Utils

  update_current_info() {
    this.current_title = this.tab_titles[this.current_main_tab_index];
    this.current_url = this.tab_urls[this.current_main_tab_index];
    this.current_url = url_resource_to_meow(this.current_url);
    // translate "resource://" into "meow://"
    this.current_loading_progress = this.tab_loading_progresses[this.current_main_tab_index];
    this.current_is_loading = this.tab_is_loading[this.current_main_tab_index];
    // Set loading progress
  }

  sync_all_list_info() {
    this.tab_titles = this.bunch_of_tabs.get_all_titles()
    this.tab_urls = this.bunch_of_tabs.get_all_urls()
    this.tab_is_loading = this.bunch_of_tabs.get_all_is_loading();
    this.tab_loading_progresses = this.bunch_of_tabs.get_all_loading_progress()
  }

  update_backward_forward_access() {
    try {
      if (this.bunch_of_tabs.workingMainTab()) {
        this.current_accessBackward = this.bunch_of_tabs.workingMainTab().controller.accessBackward()
        this.current_accessForward = this.bunch_of_tabs.workingMainTab().controller.accessForward()
      } else {
        setTimeout(() => {
          this.update_backward_forward_access();
        }, 100)
      }
    } catch (e) {
      setTimeout(() => {
        this.update_backward_forward_access();
      }, 100)
    }
  }

  update_search_box_text(text: string) {
    if (!this.is_search_input_typing && text) {
      this.search_input = url_resource_to_meow(text);
      // Update Input Search Box
    }
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

  click_tab_button(index: number) {
    if (index < 0) {
      return;
    }

    if (this.choosing_paralleow && this.current_main_tab_index != index) {
      // if choosing and is not main web then set as sub view (Paralleow)
      this.choosing_paralleow = false;
      this.current_sub_tab_index = index;
      this.showing_tabs = false;
    } else {
      if (this.current_sub_tab_index >= 0) {
        // Paralleow enabled
        if (this.current_sub_tab_index == index) {
          // if paralleowing this tab
          this.switch_paralleow();
        } else if (this.current_main_tab_index == index) {
          // if is main this tab
          this.switch_paralleow();
        } else {
          this.tab_animation = { duration: 0 };
          this.switch_tab(index)
        }
      } else {
        this.tab_animation = { duration: 0 };
        this.switch_tab(index)
      }
    }
  }

  // Events

  on_uni_tab_button_clicked() {
    if (this.uni_tab_button_clicked >= 0) {
      this.click_tab_button(this.uni_tab_button_clicked);
    }
    // Reset
    this.uni_tab_button_clicked = -1;
  }

  on_did_switch_tab() {
    if (this.recover_tabs_finished) {
      // Store where am I
      let where_main_am_i = this.current_main_tab_index.toString();
      console.log("[Meow][meowTabs] Stored where main am I: " + where_main_am_i)
      kv_store_put("continue_tabs_main_on", where_main_am_i);

      let where_sub_am_i = this.current_sub_tab_index.toString();
      console.log("[Meow][meowTabs] Stored where sub am I: " + where_sub_am_i)
      kv_store_put("continue_tabs_sub_on", where_sub_am_i);
    }
  }

  on_global_custom_UA_change() {
    this.bunch_of_tabs.set_global_custom_UA(this.global_custom_UA);
  }

  on_new_targeted_tab() {
    if (this.new_tab_gateway != "") {
      if (this.new_tab_gateway == "new_tab") {
        this.new_tab_gateway = ""
      }

      this.new_tab(this.new_tab_gateway);
      this.new_tab_gateway = "";
    }
  }

  on_targeted_close_tab() {
    if (this.close_tab_gateway >= 0) {
      this.close_tab(this.close_tab_gateway);
      this.close_tab_gateway = -1;
    }
  }

  on_current_load_url() {
    if (this.load_url_gateway != "") {
      setTimeout(() => {
        this.bunch_of_tabs.loadUrl_onWorkingTab(this.load_url_gateway);
        this.load_url_gateway = "";
      }, 50)
    }
  }
}

export default meowTabs;