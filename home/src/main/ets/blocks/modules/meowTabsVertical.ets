import { bunch_of_tabs, tab_label } from '../../hosts/bunch_of_tabs';
import { animation_default, click_effect_default, fontSize_Large, fontSize_Normal, url_default_blank } from '../../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { sandbox_read_arrayBuffer_sync, sandbox_unlink_sync } from '../../utils/storage_tools';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import { check_want } from '../../utils/want_tools';
import { storage_of_id, storage_of_index, window_index_of_id } from '../../utils/ui_tools';
import lazy { drop_to_scratching_board } from '../../utils/drag_drop_tools';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysText from '../../components/texts/linysText';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysSymbol from '../../components/texts/linysSymbol';
import {
  determine_extra_background,
  set_search_box_text,
  sync_all_tabs_list_info,
  sync_current_tabs_list_info,
  unifiedData_drag_tab_from
} from '../../processes/tabs_actions';

@Component
struct meowTabsVertical {
  @StorageLink('THE_LORD_OF_THE_WINDOWS') @Watch('on_THE_LORD_OF_THE_WINDOWS_change') THE_LORD_OF_THE_WINDOWS: string = '';
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // Want
  @LocalStorageLink('want_timestamp') @Watch('on_want') want_timestamp: string = '0';
  @LocalStorageLink('want_source') want_source: string = 'want';
  @LocalStorageLink('want_uri') want_uri: string = 'want';
  @LocalStorageLink('want_action') want_action: string = '';
  @LocalStorageLink('want_type') want_type: string = '';
  // Hosts and environments
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('showing_tabs') showing_tabs: boolean = false;
  @LocalStorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  @LocalStorageLink('search_input') search_input: string = "ଘ*(੭*ˊᵕˋ)੭*";
  @LocalStorageProp('is_search_input_typing') is_search_input_typing: boolean = false;
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  // Surf
  @StorageLink('home_url') home_url: string = '';
  @StorageLink('new_tab_url') new_tab_url: string = '';
  @StorageLink('start_up_option') start_up_option: string = '';
  // Controls
  @LocalStorageLink('tab_titles') tab_titles: string[] = []
  @LocalStorageLink('tab_urls') tab_urls: string[] = [];
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  // Other Info / Statuses
  @State recover_tabs_finished: boolean = false;
  @LocalStorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @StorageLink('intelligent_tracking_prevention') intelligent_tracking_prevention: boolean = false;
  // Delay
  @LocalStorageLink('delayed_load_p1') delayed_load_p1: boolean = false;
  // Animation info
  @State my_visibility: Visibility = Visibility.Hidden;
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
  @LocalStorageLink('universal_load_url_gateway') @Watch('uni_load_url') load_url_gateway: string = "";
  @LocalStorageLink('universal_new_tab_gateway') @Watch('uni_new_tab') new_tab_gateway: string = "";
  @LocalStorageLink('universal_close_tab_gateway') @Watch('uni_close_tab') close_tab_gateway: number = -1;
  @LocalStorageLink('universal_move_tab_gateway') @Watch('uni_move_tab') move_tab_gateway: number = -1; // Source tab index
  @LocalStorageLink('universal_move_tab_gateway_target') move_tab_gateway_target: number = -1; // Target window index
  @LocalStorageLink('universal_close_all_tabs_gateway') @Watch('uni_close_all_tabs') close_all_tabs_gateway: number = -1;
  @LocalStorageLink('universal_tab_button_click_gateway') @Watch('uni_tab_button_click') uni_tab_button_clicked: number = -1;
  @LocalStorageLink('receive_tab') @Watch('on_receive_tab') receive_tab: number = -1;
  @StorageLink('universal_global_custom_ua_gateway') @Watch('on_global_custom_UA_change') global_custom_UA: string = "";
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Drop
  @LocalStorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  // Pan Gesture
  pan_x: number = 0;

  aboutToAppear() {
    let t0 = Date.now();
    let t = 0;

    let continue_tabs_sub_on = AppStorage.get('continue_tabs_sub_on') as number;
    let continue_tabs_main_on = AppStorage.get('continue_tabs_main_on') as number;
    let continue_tabs_count = AppStorage.get('continue_tabs_count') as number;

    if (window_index_of_id(this.my_window_id) != 0) {
      // Sub windows
      if (this.want_uri == '') {
        // New window without a want
        let start_tab_url = '';
        if (this.start_up_option == "new tab") {
          start_tab_url = this.new_tab_url;
        } else {
          start_tab_url = (this.home_url == "") ? url_default_blank() : this.home_url;
        }
        this.new_tab(start_tab_url, false, false);
        this.switch_tab(0, false, false);
      } else {
        // Do nothing if is a wanted new window to a running BrowserCat.
      }
    } else {
      // Main window
      // Start Up: generate / recover tabs
      if (this.start_up_option == "new tab") {
        try {
          this.new_tab(this.new_tab_url, false, false);
          this.switch_tab(0, false, false);
        } catch (e) {
          console.error('[TabsVertical][NEW_TAB] ' + e);
        }
      } else if (this.start_up_option == "home") {
        try {
          this.new_tab((this.home_url == "") ? url_default_blank() : this.home_url, false, false);
          this.switch_tab(0, false, false);
        } catch (e) {
          console.error('[TabsVertical][HOME] ' + e);
        }
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
            this.bunch_of_tabs.sub_tab_idx = -1;
            this.bunch_of_tabs.main_tab_idx = 0;
          }
        }

        // Save to AppStorage for restoration use
        this.storage.setOrCreate('restore_web_state_arrays', web_state_arrays_to_restore);

        // Create new tabs
        try {
          for (let index = 0; index < web_state_arrays_to_restore.length; index++) {
            this.new_tab("", true, false);
          }
        } catch (e) {
          console.error('[TabsVertical][CONTINUE][new_tab] ' + e);
        }

        // Try to switch tab
        // try {
        this.switch_tab(continue_tabs_main_on, false, false);
        // } catch (e) {
        //   console.error('[TabsVertical][CONTINUE][switch_tab] ' + e);
        // }

        sync_all_tabs_list_info(this.storage);

        // Recover Paralleow
        if (continue_tabs_sub_on < this.tab_titles.length) {
          this.bunch_of_tabs.sub_tab_idx = continue_tabs_sub_on;
        }
      }
    }

    if (this.want_source == 'onCreate') {
      check_want(this.want_uri, this.want_action, this.want_type, this.storage);
    }

    this.recover_tabs_finished = true;

    t = Date.now() - t0;
    console.log('[Meow][init][meowTabsVertical] Tabs OK. (' + t + ' ms)');
  }

  build() {
    if (this.delayed_load_p1) {
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
        .borderRadius(10)
        .height(this.scroll_area_height - (this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 ? this.paralleow_description_height : 0))
        .animation(animation_default())
        .nestedScroll({ scrollForward: NestedScrollMode.SELF_ONLY, scrollBackward: NestedScrollMode.SELF_ONLY })

        Row({ space: 10 }) {
          linysTimeoutButton({
            text: '  󰀁  ',
            onExecution: () => {
              this.close_all_tabs_gateway = Date.now();
            }
          })
            .visibility(this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 ? Visibility.None : Visibility.Visible)
            .animation(animation_default())

          Blank()

          linysShowButton({
            symbol_glyph_target: 'sys.symbol.map',
            show: this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0,
            text: this.choosing_paralleow ? $r('app.string.Paralleow_choose_a_tab') : $r('app.string.Paralleow')
          })
            .onClick(() => {
              this.choose_paralleow();
            })
            .visibility(this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden)
            .animation(animation_default())

          linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
            .onClick(() => {
              this.new_tab("", false, true);
            })
            .keyboardShortcut(this.bunch_of_key_shortcuts.new_tab.main_key, this.bunch_of_key_shortcuts.new_tab.modifier)
        } // New Tab and Paralleow Button
        .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
        .width("100%")

        linysText({ text: $r('app.string.Paralleow_description'), max_lines: 4 })
          .onAreaChange((_o, n) => {
            this.paralleow_description_height = n.height as number + 16;
          })
          .visibility(this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

      } // Tabs Panel
      .visibility(this.my_visibility)
      .animation(animation_default())
      .justifyContent(FlexAlign.End)
      .width("100%")
      .height("100%")
      .onAppear(() => {
        this.extension_area = [];
        this.offset_area = [];
        for (let i = 0; i < this.bunch_of_tabs.Tabs.length; i++) {
          this.extension_area.push(0);
          this.offset_area.push(0);
        }
        this.my_visibility = Visibility.Visible;

        // Init extension_area
        setInterval(() => {
          if (!this.showing_tabs) {
            return;
          }
          this.on_timer();
        }, 10)
        // Set Task to calculate animation
        // console.log("[Meow][meowTabs] Tabs Panel READY")
      })
      .onAreaChange((_o, n) => {
        this.scroll_area_height = n.height as number - 60;
      })
      .onDrop((e) => {
        try {
          let drop_ok = drop_to_scratching_board(e, this.storage);
          if (!drop_ok) {
            this.showing_scratching_board = false;
          }
        } catch (e) {
          console.error('[onDrop] Failed: ' + e);
        }
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
  }

  // Tab controls

  /**
   * Creates a new tab.
   * @param target_url A string, if link is "", then load the default new_tab_url set in this object.
   * @param do_recovery A boolean, if set true, then the tab will restore the serialized web state in
   * @description While if new_tab_url is also not set ("" or undefined), then will load the url_default_blank().
   * */
  new_tab(target_url: string, do_recovery: boolean, save_to_settings: boolean, receive: boolean = false) {
    let t0 = Date.now();

    this.storage.set('extra_background', false);

    if (receive) {
      this.bunch_of_tabs.receive_tab(this.storage);
    } else {
      this.bunch_of_tabs.newTab(this.getUIContext(), target_url, do_recovery);
    }

    // Get synced lists
    sync_all_tabs_list_info(this.storage);

    if (!do_recovery) {
      // Store tabs count
      let store_tabs_count = this.bunch_of_tabs.get_tabs_count();
      bunch_of_settings.set("continue_tabs_count", store_tabs_count);
      console.log("[Meow][meowTabs] Stored Tabs Count: " + store_tabs_count);
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

    if (save_to_settings) {
      this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][new_tab]');
    }

    console.log('[new_tab] ' + (Date.now() - t0) + ' ms!');
  }

  switch_tab(target: number, close_tabs_panel: boolean, save_to_settings: boolean) {
    if (!this.tablet_mode && close_tabs_panel) {
      // Auto close panel
      if (this.tabs_style_non_tablet_mode == "vertical") {
        this.showing_tabs = false;
      }
    }

    this.choosing_paralleow = false;
    try {
      // Switch
      this.bunch_of_tabs.switchToTab(target);
      console.log('[Meow][meowTabs] Switch to tab ' + this.bunch_of_tabs.main_tab_idx.toString());
    } catch (e) {
      console.error('[TabsVertical][switch_tab][a] ' + e);
    }
    // Update history
    if (this.recover_tabs_finished) {
      this.bunch_of_tabs.update_backward_forward_access();
    }

    try {
      // Set CURRENT variables
      sync_current_tabs_list_info(this.storage);
    } catch (e) {
      console.error('[TabsVertical][switch_tab][b] ' + e);
    }
    // Update Input Search Box
    set_search_box_text(this.current_url, this.storage);

    determine_extra_background(this.storage);

    if (save_to_settings) {
      this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][switch_tab]');
    }
  }

  close_tab(target: number, save_to_settings: boolean, move_target_window: number = -1) {
    if (!this.recover_tabs_finished) {
      console.error("[Meow][LinysTabs][ERROR] Recover Not OK (" + target + ')!');
      return;
    }

    // Some kind of bug, idk why but this is essential when closing tabs quickly
    if (target >= this.offset_area.length) {
      console.error("[Meow][LinysTabs][ERROR] Ran into the weird bug of target >= this.offset_area.length");
      return;
    }

    // Turn off Paralleow
    if (target == this.bunch_of_tabs.sub_tab_idx || target == this.bunch_of_tabs.main_tab_idx) {
      if (this.bunch_of_tabs.sub_tab_idx > -1) {
        console.log('[Meow][LinysTabs] Paralleow off');
        this.bunch_of_tabs.sub_tab_idx = -1;
      }
    }

    if (this.bunch_of_tabs.Tabs.length == 1) {
      this.new_tab('', false, true);
    }

    // Close
    if (move_target_window > -1) {
      this.bunch_of_tabs.closeTab(target, true);
    } else {
      this.bunch_of_tabs.closeTab(target, false);
    }

    // Update history
    this.bunch_of_tabs.update_backward_forward_access();
    // Get synced lists
    sync_all_tabs_list_info(this.storage);
    // Update Input Search Box
    set_search_box_text(this.current_url, this.storage);

    // Store tabs count
    let store_tabs_count = this.tab_titles.length;
    // console.log("[Meow][meowTabs] Store Tabs Count: " + store_tabs_count);
    bunch_of_settings.set("continue_tabs_count", store_tabs_count);

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
    if (this.bunch_of_tabs.main_tab_idx == this.bunch_of_tabs.sub_tab_idx) {
      // if Paralleow crash then turn off
      this.bunch_of_tabs.sub_tab_idx = -1;
    }

    // if only 1 tab left then reset Paralleow stuff
    if (this.tab_titles.length == 1) {
      this.bunch_of_tabs.sub_tab_idx = -1;
      this.choosing_paralleow = false;
    }
    if (target < this.bunch_of_tabs.sub_tab_idx) {
      this.bunch_of_tabs.sub_tab_idx -= 1;
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

    determine_extra_background(this.storage);

    if (save_to_settings) {
      this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][close_tab]');
    }
  }

  close_all_tabs() {
    for (let index = this.bunch_of_tabs.Tabs.length - 1; index >= 0; index--) {
      this.close_tab(0, false);
    }
    this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][close_all_tabs]');
  }

  choose_paralleow() {
    if (this.choosing_paralleow) {
      // if is choosing, cancel choosing, back to no paralleow
      this.choosing_paralleow = false;
      return;
    }

    if (this.bunch_of_tabs.sub_tab_idx < 0) {
      // if haven't chosen one, then start to choose
      this.choosing_paralleow = true;
    } else {
      // Quit Paralleow
      this.choosing_paralleow = false;
      this.bunch_of_tabs.sub_tab_idx = -1;
      this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][choose_paralleow]');
    }

    determine_extra_background(this.storage);
  }

  switch_paralleow(save_to_settings: boolean) {
    let old_main = this.bunch_of_tabs.main_tab_idx;
    this.switch_tab(this.bunch_of_tabs.sub_tab_idx, true, save_to_settings);
    this.bunch_of_tabs.sub_tab_idx = old_main;

    if (save_to_settings) {
      this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][switch_paralleow]');
    }
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

  // Events

  on_global_custom_UA_change() {
    this.bunch_of_tabs.set_global_custom_UA(this.global_custom_UA);
  }

  uni_tab_button_click() {
    let clicked = this.uni_tab_button_clicked;
    let sub = this.bunch_of_tabs.sub_tab_idx;
    let main = this.bunch_of_tabs.main_tab_idx;

    if (clicked >= 0) {
      console.log('[Meow][uni_tab_button_click] [' + clicked + '] Clicked!');
      if (this.choosing_paralleow && main != clicked) {
        // if choosing Paralleow
        // and is not selected as main web
        // (this tab is selectable to be a sub view)
        // then set this tab as sub view
        this.choosing_paralleow = false;
        this.bunch_of_tabs.sub_tab_idx = clicked;
      } else if (sub >= 0 && (sub == clicked || main == clicked)) {
        // if Paralleow enabled
        // and this tab clicked is one of main or sub
        // then switch the two tabs
        this.switch_paralleow(false);
      } else {
        // simply switch tab
        // this.tab_animation = { duration: 0 };
        this.switch_tab(clicked, true, false);
      }
      this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][uni_tab_button_click]');
    }
    // Reset
    this.uni_tab_button_clicked = -1;
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

    this.new_tab(tab, false, true);
    setTimeout(() => {
      // Avoid opening duplicate tabs, idk why
      this.new_tab_gateway = "";
    }, 20)
  }

  uni_close_tab() {
    if (this.close_tab_gateway >= 0) {
      this.close_tab(this.close_tab_gateway, true);
    }
    this.close_tab_gateway = -1;
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
   * Send a tab.
   * */
  uni_move_tab() {
    if (this.move_tab_gateway < 0) {
      return;
    }
    let from_tab_index = this.move_tab_gateway;
    let to_window = this.move_tab_gateway_target;
    console.log(`[uni_move_tab][SEND][${this.my_window_id}] From Tab.${from_tab_index} to window #${to_window}!`);
    this.close_tab(from_tab_index, true, to_window);
    // Notify target window to receive tab.
    storage_of_index(to_window).setOrCreate('receive_tab', Date.now());
    this.move_tab_gateway = -1;
  }

  /**
   * Respond to wants
   * */
  on_want() {
    if (this.want_source == 'onCreate') {
      // A good BrowserCat never takes the wants needed by other new-born windows!
      console.log('[Meow][meowTabsVertical] Ignored onCreate want!');
      return;
    }

    check_want(this.want_uri, this.want_action, this.want_type, this.storage);
  }

  /**
   * Called when THE_LORD_OF_THE_WINDOWS changes (the #0 is closed).
   * */
  on_THE_LORD_OF_THE_WINDOWS_change() {
    console.warn(`[meowTabsVertical][on_THE_LORD_OF_THE_WINDOWS_change] LORD ${this.THE_LORD_OF_THE_WINDOWS}`);
    console.warn(`[meowTabsVertical][on_THE_LORD_OF_THE_WINDOWS_change] MYID ${this.my_window_id}`);
    if (this.my_window_id == this.THE_LORD_OF_THE_WINDOWS) {
      // Save web states
      this.bunch_of_tabs.re_save_web_state(0);
      // Save tab continue data
      this.bunch_of_tabs.save_tab_index_stats('[on_THE_LORD_OF_THE_WINDOWS_change]');
      // Store tabs count
      bunch_of_settings.set("continue_tabs_count", this.tab_titles.length);
    }
  }

  /**
   * Receive a tab.
   * */
  on_receive_tab() {
    // Get data from AppStorage.
    console.log(`[on_receive_tab][RECEIVE][${this.my_window_id}]`);
    this.new_tab('receive tab', false, true, true);
    sync_all_tabs_list_info(this.storage); // TODO: this can be optimized
    this.switch_tab(this.bunch_of_tabs.Tabs.length - 1, false, true);
  }

  // Data

  is_right_align() {
    return (this.preferred_hand_left_or_right == 'right' && !this.preferred_hand_reverse_tabs_panel) ||
      (!(this.preferred_hand_left_or_right == 'right') && this.preferred_hand_reverse_tabs_panel);
  }
}

export default meowTabsVertical;

@Component
struct TabButton {
  // Sync
  @Link offset_area: number[];
  @Link extension_area: number[];
  @Prop Label: tab_label;
  tab_height_default: number = 42;
  // Public
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('tab_titles') tab_titles: string[] = []
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Gateways
  @LocalStorageLink('universal_tab_button_click_gateway') uni_tab_button_clicked: number = -1;
  @LocalStorageLink('universal_close_tab_gateway') close_tab_gateway: number = -1;
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
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

        Text(this.tablet_mode ? "󰃊" : "󰃎") // Paralleow icon left
          .visibility((this.bunch_of_tabs.sub_tab_idx > -1 && this.bunch_of_tabs.main_tab_idx == this.Label.index_key) ? Visibility.Visible : Visibility.None)
          .fontColor(this.color_current_font)
          .animation(animation_default())
          .padding({ right: 5 })
          .fontSize(fontSize_Large())
          .fontWeight(FontWeight.Bold)

        Text(this.tablet_mode ? "󰈱" : "󰈮") // Paralleow icon right
          .visibility(this.bunch_of_tabs.sub_tab_idx == this.Label.index_key ? Visibility.Visible : Visibility.None)
          .fontColor(this.color_current_font)
          .animation(animation_default())
          .padding({ right: 5 })
          .fontSize(fontSize_Large())
          .fontWeight(FontWeight.Bold)

        Text(this.tab_titles[this.Label.index_key] == "" ? "Meow" : this.tab_titles[this.Label.index_key])
          .padding({ left: 2 })
          .fontSize(fontSize_Normal())
          .fontColor(this.color_current_font)
          .fontWeight((this.bunch_of_tabs.main_tab_idx == this.Label.index_key ||
            this.bunch_of_tabs.sub_tab_idx == this.Label.index_key)
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
        color: (this.bunch_of_tabs.main_tab_idx == this.Label.index_key || this.bunch_of_tabs.sub_tab_idx == this.Label.index_key)
          ? this.color_current_font : "transparent"
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
      .keyboardShortcut(this.bunch_of_tabs.main_tab_idx == this.Label.index_key ? this.bunch_of_key_shortcuts.close_tab.main_key : '',
        this.bunch_of_key_shortcuts.close_tab.modifier)
    }
    // .opacity(this.bunch_of_tabs.sub_tab_idx == this.Label.index_key ? 0.7 : 1)
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
    .draggable(true)
    .onDragStart((event) => {
      try {
        // Drag this tab
        let unifiedData = unifiedData_drag_tab_from(this.my_window_id, this.Label.index_key);
        (event as DragEvent).setData(unifiedData);
      } catch (e) {
        console.error('[Meow][Tabs] Set drag data failed: ' + e);
      }
    })
  }
}