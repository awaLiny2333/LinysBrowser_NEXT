import linysSymbol from '../../components/texts/linysSymbol';
import { bunch_of_tabs, tab_label } from '../../hosts/bunch_of_tabs';
import { url_resource_to_meow } from '../../utils/url_tools';
import { animation_default, click_effect_default, fontSize_Large, fontSize_Normal, url_default_blank } from '../../hosts/bunch_of_defaults';
import { kv_store_get, kv_store_put } from '../../utils/kv_store_tools';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysText from '../../components/texts/linysText';
import { sandbox_read_arrayBuffer_sync, sandbox_unlink_sync } from '../../utils/storage_tools';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import { allow_drop_types, drop_to_scratching_board } from '../../utils/drag_drop_tools';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import { check_want } from '../../utils/want_tools';

@Component
struct meowTabs {
  // Want
  @StorageLink('want_uri') @Watch('on_want') want_uri: string = 'want';
  @StorageLink('want_action') want_action: string = '';
  @StorageLink('want_type') want_type: string = '';
  // Hosts and environments
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('showing_tabs') showing_tabs: boolean = false;
  @StorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @StorageLink('showing_more_options') showing_more_options: boolean = false;
  @StorageLink('search_input') search_input: string = "*(੭*ˊᵕˋ)੭*ଘ";
  @StorageLink('search_input_source') search_input_update_source: string = "tab_switch";
  @StorageProp('is_search_input_typing') is_search_input_typing: boolean = false;
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  // Surf
  @StorageProp('home_url') home_url: string = '';
  @StorageProp('new_tab_url') new_tab_url: string = '';
  @StorageProp('start_up_option') start_up_option: string = '';
  // Controls
  @StorageLink('tab_titles') tab_titles: string[] = []
  @StorageLink('current_title') current_title: string = "=￣ω￣=";
  @StorageLink('tab_urls') tab_urls: string[] = []
  @StorageLink('current_url') current_url: string = "=￣ω￣=";
  @StorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0]
  @StorageLink('current_loading_progress') current_loading_progress: number = 0
  @StorageLink('tab_is_loading') tab_is_loading: boolean[] = [true]
  @StorageLink('current_is_loading') current_is_loading: boolean = true
  @StorageLink('current_in_page_searching_keyword') current_in_page_searching_keyword: string = ''
  @StorageLink('current_in_page_searching_stats_current') current_in_page_searching_stats_current: number = 0;
  @StorageLink('current_in_page_searching_stats_total') current_in_page_searching_stats_total: number = 0;
  // Web control statuses
  @StorageLink('current_main_tab_index') @Watch('on_did_switch_tab') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') @Watch('on_did_switch_tab') current_sub_tab_index: number = -1;
  @StorageLink('current_accessForward') current_accessForward: boolean = false;
  @StorageLink('current_accessBackward') current_accessBackward: boolean = false;
  // Other Info / Statuses
  @State recover_tabs_finished: boolean = false;
  @StorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @StorageLink('intelligent_tracking_prevention') intelligent_tracking_prevention: boolean = false;
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
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_tabs_panel') preferred_hand_reverse_tabs_panel: boolean = false;
  // Gateways
  @StorageLink('universal_load_url_gateway') @Watch('uni_load_url') load_url_gateway: string = "";
  @StorageLink('universal_new_tab_gateway') @Watch('uni_new_tab') new_tab_gateway: string = "";
  @StorageLink('universal_close_tab_gateway') @Watch('uni_close_tab') close_tab_gateway: number = -1;
  @StorageLink('universal_close_all_tabs_gateway') @Watch('uni_close_all_tabs') close_all_tabs_gateway: number = -1;
  @StorageLink('universal_tab_button_click_gateway') @Watch('uni_tab_button_click') uni_tab_button_clicked: number = -1;
  @StorageLink('universal_global_custom_ua_gateway') @Watch('on_global_custom_UA_change') global_custom_UA: string = "";
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Drop
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  // Pan Gesture
  pan_x: number = 0;

  async aboutToAppear() {
    // Get Data
    let continue_tabs_count_string = await kv_store_get("continue_tabs_count");
    let continue_tabs_main_on_string = await kv_store_get("continue_tabs_main_on");
    let continue_tabs_sub_on_string = await kv_store_get("continue_tabs_sub_on");
    let continue_tabs_count = 0;
    let continue_tabs_main_on = 0;
    let continue_tabs_sub_on = 0;

    this.bunch_of_tabs.start_up = this.start_up_option;
    this.bunch_of_tabs.new_tab_url = this.new_tab_url;
    this.bunch_of_tabs.home_url = this.home_url;

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
    if (this.start_up_option == "new tab") {
      this.new_tab(this.new_tab_url);
      this.switch_tab(0, false);

    } else if (this.start_up_option == "home") {
      this.new_tab((this.home_url == "") ? url_default_blank() : this.home_url);
      this.switch_tab(0, false);

    } else {
      // Restore. Prepare web states.
      let web_state_arrays_to_restore: Uint8Array[] = [];
      for (let index = 0; index < continue_tabs_count; index++) {
        // Read continue tabs data
        let key = "continue/continue_tabs_web_state_array_" + index.toString();
        let array_buffer = sandbox_read_arrayBuffer_sync(key);
        if (array_buffer) {
          web_state_arrays_to_restore.push(new Uint8Array(array_buffer));
        } else {
          // An unexpected error may occur: array_buffer may be empty.
          web_state_arrays_to_restore.push(new Uint8Array());
          this.current_sub_tab_index = -1;
          this.current_main_tab_index = 0;
        }
      }

      // Save to AppStorage for restoration use
      AppStorage.setOrCreate('restore_web_state_arrays', web_state_arrays_to_restore);

      // Create new tabs
      for (let index = 0; index < web_state_arrays_to_restore.length; index++) {
        this.new_tab("", true);
      }

      // Try to switch tab
      this.tab_animation = { duration: 0 };
      this.switch_tab(continue_tabs_main_on, false);
      this.sync_all_list_info();

      // Recover Paralleow
      if (continue_tabs_sub_on < this.tab_titles.length) {
        this.current_sub_tab_index = continue_tabs_sub_on;
      }
    }

    this.recover_tabs_finished = true;

    // Want
    check_want(this.want_uri, this.want_action, this.want_type);
  }

  build() {
    Column({ space: 10 }) {
      Scroll(this.scroll_controller) {
        Column({ space: 5 }) {
          ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
            TabButton({
              Label: Label,
              extension_area: this.extension_area,
              offset_area: this.offset_area,
            })
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
      .height(this.scroll_area_height - (this.choosing_paralleow || this.current_sub_tab_index >= 0 ? this.paralleow_description_height : 0))
      .animation(animation_default())
      .nestedScroll({ scrollForward: NestedScrollMode.SELF_ONLY, scrollBackward: NestedScrollMode.SELF_ONLY })

      Row({ space: 10 }) {
        linysTimeoutButton({
          text: '  󰀁  ',
          onExecution: () => {
            this.close_all_tabs_gateway = Date.now();
          }
        })
          .visibility(this.choosing_paralleow || this.current_sub_tab_index >= 0 ? Visibility.None : Visibility.Visible)
          .animation(animation_default())

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
          .keyboardShortcut(this.bunch_of_key_shortcuts.new_tab.main_key, this.bunch_of_key_shortcuts.new_tab.modifier)
      } // New Tab and Paralleow Button
      .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
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
    // .padding(10)
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
      // console.log("[Meow][meowTabs] Tabs Panel READY")
    })
    .onAreaChange((_o, n) => {
      this.scroll_area_height = n.height as number - 60;
    })
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
    .gesture(
      PanGesture({ direction: PanDirection.Left | PanDirection.Right })
        .onActionStart(() => {
          this.pan_x = 0;
        })
        .onActionUpdate((e) => {
          this.pan_x += e.offsetX;
        })
        .onActionEnd(() => {
          if (this.pan_x < 0) {
            // ← Switch to Bookmarks
            this.showing_bookmarks = true;
            this.showing_tabs = false;
          }
          if (this.pan_x > 0 && this.is_right_align()) {
            // → Right Align Close panel
            this.showing_tabs = false;
          }
        })
    )
  }

  // Tab controls

  /**
   * Creates a new tab.
   * @param target_url A string, if url is "", then load the default new_tab_url set in this object.
   * @param do_recovery A boolean, if set true, then the tab will restore the serialized web state in
   * @description While if new_tab_url is also not set ("" or undefined), then will load the url_default_blank().
   * */
  new_tab(target_url: string, do_recovery?: boolean) {
    AppStorage.set('extra_background', false);

    this.tab_animation = { duration: 0 };

    this.current_main_tab_index = this.bunch_of_tabs.newTab(target_url, do_recovery);

    if (!do_recovery) {
      // Store tabs count
      let store_tabs_count = this.bunch_of_tabs.get_tabs_count().toString();
      console.log("[Meow][meowTabs] Stored Tabs Count: " + store_tabs_count)
      kv_store_put("continue_tabs_count", store_tabs_count);
    }

    // Animation part
    this.extension_area.push(0);

    if (this.scroll_animation_enabled) {
      for (let index = 0; index < this.offset_area.length; index++) {
        this.offset_area[index] += this.tab_height_default + 5;
        // Move downward for up going animation
      }
      // Set offset for the new tab
      this.offset_area.push(this.tab_height_default + 1000)
    } else {
      this.offset_area.push(this.tab_height_default)
    }

    // Scroll to the new tab later
    this.count_down_for_scrolling_to_bottom = 30;
  }

  switch_tab(target: number, close_tabs_panel: boolean = true) {
    if (!this.tablet_mode && close_tabs_panel) {
      // Auto close panel
      if (this.tabs_style_non_tablet_mode == "vertical") {
        this.showing_tabs = false;
      }
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
    this.set_search_box_text(this.current_url)

    this.determine_extra_background();
  }

  close_tab(target: number) {
    if (!this.recover_tabs_finished) {
      return;
    }

    // Some kind of bug, idk why but this is essential when closing tabs quickly
    if (target >= this.offset_area.length) {
      console.error("[Meow][LinysTabs][ERROR] Ran into the weird bug of target >= this.offset_area.length")
      return;
    }

    // Set animation duration
    // this is stupid
    this.tab_animation = { duration: 0 };

    // Turn off Paralleow
    if (target == this.current_sub_tab_index || target == this.current_main_tab_index) {
      console.log('[Meow][LinysTabs] Paralleow off')
      this.current_sub_tab_index = -1;
    }

    // Close
    this.current_main_tab_index = this.bunch_of_tabs.closeTab(target, url_default_blank())
    // Update history
    this.update_backward_forward_access()
    // Get synced lists
    this.sync_all_list_info()
    // Set CURRENT variables
    this.update_current_info()
    // Update Input Search Box
    this.set_search_box_text(this.current_url)

    // Store tabs count
    let store_tabs_count = this.tab_titles.length.toString();
    console.log("[Meow][meowTabs] Store Tabs Count: " + store_tabs_count)
    kv_store_put("continue_tabs_count", store_tabs_count);

    // clear extra continue storage
    let index = this.bunch_of_tabs.Tabs.length;
    while (true) {
      let key = "continue/continue_tabs_web_state_array_" + index.toString();
      // console.log('awa')
      if (!sandbox_unlink_sync(key)) {
        break;
      }
      index += 1;
    }
    // re-save web states
    this.bunch_of_tabs.re_save_web_state(target);

    // Paralleow
    if (this.current_main_tab_index == this.current_sub_tab_index) {
      // if Paralleow crash then turn off
      this.current_sub_tab_index = -1;
    }

    // if only 1 tab left then reset Paralleow stuff
    if (this.tab_titles.length == 1) {
      this.current_sub_tab_index = -1;
      this.choosing_paralleow = false;
    }
    if (target < this.current_sub_tab_index) {
      this.current_sub_tab_index -= 1;
    }

    // Animation part
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

    // Set Scroll spring on edge effect off
    // So that when closing the last tab, it is always stuck at the bottom
    // Or we'll have to wait for the spring animation to finish, bringing the last tab button down.
    this.count_down_for_switching_back_to_spring += 10;

    this.determine_extra_background();
  }

  close_all_tabs() {
    for (let index = this.bunch_of_tabs.Tabs.length - 1; index >= 0; index--) {
      this.close_tab(0);
    }
  }

  choose_paralleow() {
    if (this.choosing_paralleow) {
      // if is choosing, cancel choosing, back to no paralleow
      this.choosing_paralleow = false;
      return;
    }

    if (this.current_sub_tab_index < 0) {
      // if haven't chosen one, then start to choose
      this.choosing_paralleow = true;
    } else {
      // Quit Paralleow
      this.choosing_paralleow = false;
      this.current_sub_tab_index = -1;
    }

    this.determine_extra_background();
  }

  switch_paralleow() {
    let new_sub = this.current_main_tab_index;
    this.switch_tab(this.current_sub_tab_index);
    this.current_sub_tab_index = new_sub;
  }

  // Utils

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

  update_current_info() {
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

  set_search_box_text(text: string) {
    if (!this.is_search_input_typing && text) {
      this.search_input_update_source = 'tab_switch';
      this.search_input = url_resource_to_meow(text);
      // Update Input Search Box
    }
  }

  determine_extra_background() {
    let need_extra_background = true;
    // Determine background
    if (!AppStorage.get('meowWebView_init_OK') as boolean) {
      need_extra_background = false;
    }
    if (this.current_sub_tab_index > -1) {
      // Paralleowing
      if (this.current_url == 'meow://home' && this.tab_urls[this.current_sub_tab_index] == 'meow://home') {
        need_extra_background = false;
      }
    } else {
      // Not Paralleowing
      if (this.current_url == 'meow://home') {
        need_extra_background = false;
      }
    }
    AppStorage.set('extra_background', need_extra_background);
  }

  // Events

  uni_tab_button_click() {
    let clicked = this.uni_tab_button_clicked;
    let sub = this.current_sub_tab_index;
    let main = this.current_main_tab_index;

    if (clicked >= 0) {
      if (this.choosing_paralleow && main != clicked) {
        // if choosing Paralleow
        // and is not selected as main web
        // (this tab is selectable to be a sub view)
        // then set this tab as sub view
        this.choosing_paralleow = false;
        this.current_sub_tab_index = clicked;
      } else if (sub >= 0 && (sub == clicked || main == clicked)) {
        // if Paralleow enabled
        // and this tab clicked is one of main or sub
        // then switch the two tabs
        this.switch_paralleow();
      } else {
        // simply switch tab
        this.tab_animation = { duration: 0 };
        this.switch_tab(clicked);
      }
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

  uni_new_tab() {
    console.log('[meowTabsVertical][uni_new_tab] ' + this.new_tab_gateway);
    // console.log('qwq_new_tab')
    let tab = this.new_tab_gateway;

    if (tab == "") {
      return;
    }

    if (tab == "new_tab") {
      tab = ""
    }

    this.new_tab(tab);
    setTimeout(() => {
      // Avoid opening duplicate tabs, idk why
      this.new_tab_gateway = "";
    }, 20)
  }

  uni_close_tab() {
    if (this.close_tab_gateway >= 0) {
      this.close_tab(this.close_tab_gateway);
      this.close_tab_gateway = -1;
    }
  }

  uni_close_all_tabs() {
    if (this.close_all_tabs_gateway != -1) {
      this.close_all_tabs();
    }
  }

  uni_load_url() {
    if (this.load_url_gateway != "") {
      setTimeout(() => {
        this.bunch_of_tabs.loadUrl_onWorkingTab(this.load_url_gateway);
        this.load_url_gateway = "";
      }, 50)
    }
  }

  /**
   * Respond to wants
   * */
  on_want() {
    check_want(this.want_uri, this.want_action, this.want_type);
  }

  // Data

  is_right_align() {
    return this.preferred_hand_left_or_right == 'right' && !this.preferred_hand_reverse_tabs_panel;
  }
}

export default meowTabs;

@Component
struct TabButton {
  // Sync
  @Link offset_area: number[];
  @Link extension_area: number[];
  @Prop Label: tab_label;
  tab_height_default: number = 42;
  // Public
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @StorageLink('current_main_tab_index') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') current_sub_tab_index: number = -1;
  @StorageLink('tab_titles') tab_titles: string[] = []
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Gateways
  @StorageLink('universal_tab_button_click_gateway') uni_tab_button_clicked: number = -1;
  @StorageLink('universal_close_tab_gateway') close_tab_gateway: number = -1;
  // Colors
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Animation
  @State pressing: boolean = false;

  build() {
    RelativeContainer() {
      Row() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .padding({ right: 5 })
          .fontSize(fontSize_Normal())
          .fontColor([this.color_current_font])
          .fontWeight(FontWeight.Bold)
          .visibility(this.preferred_hand_left_or_right == 'left' ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

        Text("󰇀")
          .padding({ right: 5 })
          .fontSize(fontSize_Large())
          .fontColor(this.color_current_font)
          .fontWeight((this.current_main_tab_index == this.Label.index_key ||
            this.current_sub_tab_index == this.Label.index_key)
            ? FontWeight.Bold : undefined)
          .visibility(this.current_sub_tab_index == this.Label.index_key ? Visibility.Visible : Visibility.None)
          .animation(animation_default())
          .offset({ y: -2 })

        Text(this.tab_titles[this.Label.index_key] == "" ? "Meow" : this.tab_titles[this.Label.index_key])
          .padding({ left: 2 })
          .fontSize(fontSize_Normal())
          .fontColor(this.color_current_font)
          .fontWeight((this.current_main_tab_index == this.Label.index_key ||
            this.current_sub_tab_index == this.Label.index_key)
            ? FontWeight.Bold : undefined)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(fontSize_Normal())
          .fontColor([this.color_current_font])
          .fontWeight(FontWeight.Bold)
          .visibility(this.preferred_hand_left_or_right == 'right' ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

      } // Title and xmark
      .border({
        radius: 10,
        width: 2,
        color: (this.current_main_tab_index == this.Label.index_key || this.current_sub_tab_index == this.Label.index_key) ?
          this.color_current_font : "transparent"
      })
      .backgroundColor(this.color_current_secondary)
      .animation(animation_default())
      .width("100%")
      .height(this.tab_height_default)
      .padding(10)
      .offset({ y: this.offset_area[this.Label.index_key] })
      .alignRules({
        middle: { anchor: "__container__", align: HorizontalAlign.Center },
        top: { anchor: "__container__", align: VerticalAlign.Top }
      })
      .onClick(() => {
        this.uni_tab_button_clicked = this.Label.index_key;
      })

      Column() {
      } // The True Tab Closer
      .width(35)
      .height("100%")
      .alignRules(this.preferred_hand_left_or_right == 'right' ?
        {
          right: { anchor: "__container__", align: HorizontalAlign.End },
          center: { anchor: "__container__", align: VerticalAlign.Center }
        } : {
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          center: { anchor: "__container__", align: VerticalAlign.Center }
        })
      .onClick(() => {
        this.close_tab_gateway = this.Label.index_key;
      })
      .keyboardShortcut(this.current_main_tab_index == this.Label.index_key ? this.bunch_of_key_shortcuts.close_tab.main_key : '',
        this.bunch_of_key_shortcuts.close_tab.modifier)
    }
    .onTouch((event) => {
      if (event.type == TouchType.Up) {
        this.pressing = false;
        // If touch ends
      } else {
        this.pressing = true;
        // If touching
      }
    })
    .width("100%")
    .height(this.tab_height_default + this.extension_area[this.Label.index_key])
    .clickEffect(click_effect_default())
  }
}