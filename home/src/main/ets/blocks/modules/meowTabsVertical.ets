import { bunch_of_tabs, tab_label } from '../../hosts/bunch_of_tabs';
import { animation_default, click_effect_default, fontSize_Icon_Button, fontSize_Large, fontSize_Normal, url_default_blank } from '../../hosts/bunch_of_defaults';
import { sandbox_read_arrayBuffer_sync, sandbox_read_text_sync } from '../../utils/storage_tools';
import { current_tabs_style_is_horizontal, run_time, storage_of_id, storage_of_index } from '../../utils/ui_tools';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import { check_want } from '../../utils/want_tools';
import lazy { bunch_of_settings } from '../../hosts/bunch_of_settings';
import lazy {
  determine_extra_background,
  set_search_box_text,
  sync_all_tabs_list_info,
  sync_current_tabs_list_info,
  unifiedData_drag_tab_from
} from '../../processes/tabs_actions';
import lazy { drop_to_scratching_board } from '../../utils/drag_drop_tools';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysText from '../../components/texts/linysText';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysSymbol from '../../components/texts/linysSymbol';

@Component
struct meowTabsVertical {
  @StorageLink('THE_LORD_OF_THE_WINDOWS') @Watch('on_THE_LORD_OF_THE_WINDOWS_change') THE_LORD_OF_THE_WINDOWS: string = '';
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // Want
  @LocalStorageLink('want_timestamp') @Watch('on_want') want_timestamp: string = '0';
  /**
   * Hosts and environments */
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // Environments
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('screen_width') screen_width: number = 0;
  @StorageLink('tabs_style') tabs_style: string = "";
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  // Controls
  @LocalStorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @LocalStorageLink('showing_tabs') showing_tabs: boolean = false;
  @LocalStorageLink('tab_titles') tab_titles: string[] = []
  // Other Info / Statuses
  @LocalStorageLink('tabs_init_ok') tabs_init_ok: boolean = false;
  @LocalStorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @LocalStorageLink('unloading_tabs') unloading_tabs: boolean = false;
  @LocalStorageLink('last_tab_index') last_tab_index: number = -1;
  // Animation info
  @State my_visibility: Visibility = Visibility.Hidden;
  scroll_controller: Scroller = new Scroller();
  @LocalStorageLink('vertical_tabs_scroll_area_height') scroll_area_height: number = 0;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_tabs_panel') preferred_hand_reverse_tabs_panel: boolean = false;
  // Gateways
  @LocalStorageLink('universal_load_url_gateway') @Watch('uni_load_url') load_url_gateway: string = "";
  @LocalStorageLink('universal_new_tab_gateway') @Watch('uni_new_tab') new_tab_gateway: (string | boolean)[] = ['', false];
  last_tab_gateway_url: string = "";
  last_tab_gateway_reset_timeout_id: number | undefined = undefined;
  @LocalStorageLink('universal_close_tab_gateway') @Watch('uni_close_tab') close_tab_gateway: number = -1;
  @LocalStorageLink('universal_move_tab_gateway') @Watch('uni_move_tab') move_tab_gateway: number = -1; // Source tab index
  @LocalStorageLink('universal_move_tab_gateway_target') move_tab_gateway_target: number = -1; // Target window index
  @LocalStorageLink('universal_close_all_tabs_gateway') @Watch('uni_close_all_tabs') close_all_tabs_gateway: number = -1;
  @LocalStorageLink('universal_tab_button_click_gateway') @Watch('uni_tab_button_click') uni_tab_button_clicked: number = -1;
  @LocalStorageLink('receive_tab') @Watch('on_receive_tab') receive_tab: number = -1;
  @StorageLink('universal_global_custom_ua_gateway') @Watch('on_global_custom_UA_change') global_custom_UA: string = "";
  // Colors
  @StorageLink('effects') effects: boolean = false;
  // Pan Gesture
  pan_x: number = 0;
  // Timeout
  scroll_2_bottom_timeout_handle_id: number | undefined = undefined;

  build() {
    Column({ space: 10 }) {
      Scroll(this.scroll_controller) {
        Column({ space: 5 }) {
          ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
            TabButton({
              Label: Label,
            })
          }, (Label: tab_label) => Label.timestamp.toString())
        }
        .width("100%")
      } // Tab Buttons List
      .direction(Direction.Rtl)
      .align(Alignment.Bottom)
      .edgeEffect(EdgeEffect.Spring)
      .width("100%")
      .borderRadius(10)
      .layoutWeight(1)
      .animation(animation_default())
      .onAreaChange((_o, n) => {
        this.scroll_area_height = n.height as number;
      })

      Column({ space: 10 }) {
        Row() {
          linysTimeoutButton({
            text: '  󰀁  ',
            onExecution: () => {
              this.close_all_tabs_gateway = Date.now();
            }
          })
            .visibility(this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 || this.unloading_tabs ? Visibility.None : Visibility.Visible)
            .animation(animation_default())

          Blank()
            .onClick(() => {
              this.try_scroll_to(this.bunch_of_tabs.main_tab_idx);
            })

          linysShowButton({
            symbol_glyph_target: 'sys.symbol.moon_z',
            show: this.unloading_tabs,
            text: $r('app.string.Tabs_unload')
          }) // Sleep
            .onClick(() => {
              this.choosing_paralleow = false;
              this.unloading_tabs = !this.unloading_tabs;
            })
            .visibility(this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden)
            .animation(animation_default())

          linysShowButton({
            symbol_glyph_target: 'sys.symbol.map',
            show: this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0,
            text: this.choosing_paralleow ? $r('app.string.Paralleow_choose_a_tab') : $r('app.string.Paralleow')
          }) // Paralleow
            .onClick(() => {
              this.unloading_tabs = false;
              this.choose_paralleow();
            })
            .visibility(this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden)
            .animation(animation_default())

          linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square', can_hover: true }) // New Tab
            .onClick(() => {
              this.new_tab("", true, false);
            })
            .keyboardShortcut(this.bunch_of_key_shortcuts.new_tab.main_key, this.bunch_of_key_shortcuts.new_tab.modifier)
        } // New Tab and Paralleow Button
        .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
        .width("100%")

        linysText({ text: $r('app.string.Paralleow_description'), max_lines: 4 })
          .visibility(this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 ? Visibility.Visible : Visibility.None)
          .animation(animation_default())
          .width('100%')

        linysText({ text: $r('app.string.Tabs_unload_description'), max_lines: 4 })
          .visibility(this.unloading_tabs ? Visibility.Visible : Visibility.None)
          .animation(animation_default())
          .width('100%')
      }
    } // Tabs Panel
    .visibility(this.my_visibility)
    .width(this.showing_tabs ? this.width_of_Tabs() : 0)
    .padding((this.showing_tabs && !current_tabs_style_is_horizontal(this.storage))
      ? {
        top: !this.effects ? 10 : 0,
        left: 10,
        right: this.showing_bookmarks ? 0 : 10,
        bottom: 10,
      } : 0)
    .animation(animation_default())
    .height("100%")
    .justifyContent(FlexAlign.End)
    .clip(true)
    .onAppear(() => {
      this.my_visibility = Visibility.Visible;
      console.log(`[Meow][meowTabsvertical] onAppear! (${run_time(this.storage)} ms)`);
      setTimeout(() => {
        this.preprocessing(this.storage);
      }, 1)
    })
    .onDrop((e) => {
      try {
        let drop_ok = drop_to_scratching_board(e, this.storage, true);
        if (!drop_ok) {
          this.storage.set('showing_scratching_board', false);
        }
      } catch (e) {
        console.error('[onDrop] Failed: ' + e);
      }
    })
    .onDragEnter(() => {
      this.storage.set('showing_scratching_board', false);
      this.storage.set('showing_more_options', false);
    })
    .onDragLeave(() => {
      this.storage.set('showing_scratching_board', false);
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
          if (this.is_right_align()) {
            if (this.pan_x < 0) {
              // ← Switch to Bookmarks
              this.storage.set('showing_bookmarks', true);
              // this.showing_tabs = false;
            } else {
              // → Right Align Close panel
              this.storage.set('showing_tabs', false);
            }
          } else {
            if (this.pan_x < 0) {
              // ← Close panel
              this.storage.set('showing_tabs', false);
            } else {
              // → Open bookmarks
              this.storage.set('showing_bookmarks', true);
            }
          }
        })
    )
  }

  // Tab controls

  preprocessing(storage: LocalStorage) {
    let t0 = Date.now();

    // Start
    let continue_tabs_sub_on = AppStorage.get('continue_tabs_sub_on') as number;
    let continue_tabs_main_on = AppStorage.get('continue_tabs_main_on') as number;
    let continue_tabs_count = AppStorage.get('continue_tabs_count') as number;
    let start_up_option = bunch_of_tabs.start_up;
    // Want
    let want_uri = storage.get('want_uri') as string;
    let want_source = storage.get('want_source') as string;
    let want_action = storage.get('want_action') as string;
    let want_type = storage.get('want_type') as string;

    let go_want = want_uri.length > 0 && want_source == 'onCreate';

    // Tabs
    if ((AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string) != this.my_window_id) {
      // Sub windows
      if (go_want) {
        // Do nothing if is a wanted new window to a running BrowserCat.
      } else {
        // New window without a want
        let start_tab_url = '';
        if (start_up_option == "new tab") {
          start_tab_url = bunch_of_tabs.new_tab_url;
        } else {
          start_tab_url = (bunch_of_tabs.home_url == "") ? url_default_blank() : bunch_of_tabs.home_url;
        }
        this.new_tab(start_tab_url, false, false);
        this.switch_tab(0, false, false);
      }
    } else {
      // Main window
      // Start Up: generate / recover tabs
      if (start_up_option == "new tab") {
        try {
          this.new_tab(bunch_of_tabs.new_tab_url, false, false);
          this.switch_tab(0, false, false);
        } catch (e) {
          console.error('[TabsVertical][NEW_TAB] ' + e);
        }
      } else if (start_up_option == "home") {
        try {
          this.new_tab((bunch_of_tabs.home_url == "") ? url_default_blank() : bunch_of_tabs.home_url, false, false);
          this.switch_tab(0, false, false);
        } catch (e) {
          console.error('[TabsVertical][HOME] ' + e);
        }
      } else {
        console.log(`[Meow][init][meowTabsVertical] about to restore tabs. (${(Date.now() - t0)}/${run_time(storage)} ms)`);

        // Create new tabs
        for (let index = 0; index < continue_tabs_count; index++) {
          try {
            let label_file = "continue/continue_tabs_web_state_array_" + index.toString() + '_label';
            let label = sandbox_read_text_sync(label_file); // Name of that tab
            // console.log(`[Meow][init][meowTabsVertical] Tab #${index}!`);
            this.new_tab("", false, false, true, label);
          } catch (e) {
            console.error('[TabsVertical][CONTINUE][new_tab] ' + e);
          }
        }

        // Switch to *THE* tab if there is no want,
        // and DON'T switch if there IS a want
        // (or that tab would be woken at the same time as the loading of the wanted tab)
        if (!go_want) {
          this.switch_tab(continue_tabs_main_on, false, false);
          this.try_scroll_to(continue_tabs_main_on);
        }
      }

      setTimeout(() => {
        // Retrieve all data, avoid blocks on the main thread
        sync_all_tabs_list_info(this.storage);
        // Recover Paralleow
        if (continue_tabs_sub_on < this.tab_titles.length) {
          this.bunch_of_tabs.sub_tab_idx = continue_tabs_sub_on;
          // Restore sub tab;
          if (continue_tabs_sub_on >= 0) {
            this.bunch_of_tabs.callRestore(this.getUIContext(), continue_tabs_sub_on);
          }
        }
      }, 10);
    }

    if (want_source == 'onCreate' && go_want) {
      setTimeout(() => {
        // Don't block first
        console.log(`[Meow][init][meowTabsVertical] check want. (${(Date.now() - t0)}/${run_time(storage)} ms)`);
        check_want(want_uri, want_action, want_type, storage);
      }, 10);
    }

    this.last_tab_index = this.bunch_of_tabs.main_tab_idx; // Set last_tab_index

    console.log(`[Meow][init][meowTabsVertical] Preprocessing Tabs OK. (${(Date.now() - t0)}/${run_time(storage)} ms)`);
    this.tabs_init_ok = true;
  }

  /**
   * Creates a new tab.
   * @param target_url A string, if link is "", then load the default new_tab_url set in this object.
   * @param save_to_settings if set true, then will save the tabs index status to app settings for next launch to continue.
   * @param is_from_receive if set true, will get tab from AppStorage instead of creating a new one.
   * @param init_state if set value, then the tab will restore the passed serialized web state.
   * @param placeholder_label The display name of the tab when it's not restored.
   * @param is_dialog if set true, then this is considered a dialog. One BrowserCat window can only own one dialog and all new opens of dialogs are loaded on THAT tab.
   * @description While if new_tab_url is also not set ("" or undefined), then will load the url_default_blank().
   * */
  new_tab(target_url: string, save_to_settings: boolean, is_from_receive: boolean, init_state: boolean = false, placeholder_label?: string) {
    let t0 = Date.now();

    // Remember last tab & background stuffs
    if (!init_state) {
      this.last_tab_index = this.bunch_of_tabs.main_tab_idx;
      this.storage.set('extra_background', false);
    }

    // Main process
    if (is_from_receive) {
      this.bunch_of_tabs.receive_tab(this.storage);
      // re-save web states
      let is_lord = (this.storage.get('my_window_id') as string) == (AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string);
      if (is_lord) {
        console.log('[new_tab][is_from_receive] Save web state!');
        let idx = this.bunch_of_tabs.Tabs.length - 1;
        this.bunch_of_tabs.save_web_state_to_sandbox(idx);
        this.bunch_of_tabs.save_web_label_to_sandbox(idx);
      }
    } else {
      this.bunch_of_tabs.newTab(this.getUIContext(), target_url, init_state, placeholder_label);
    }

    // Following processing for non init tabs;
    if (!init_state) {
      // Get synced lists
      sync_all_tabs_list_info(this.storage);

      // Store tabs count
      if (this.my_window_id == this.THE_LORD_OF_THE_WINDOWS) {
        let store_tabs_count = this.bunch_of_tabs.get_tabs_count();
        bunch_of_settings.set("continue_tabs_count", store_tabs_count);
        console.log("[Meow][meowTabs] Stored Tabs Count: " + store_tabs_count);
      }

      this.try_scroll_to(this.bunch_of_tabs.Tabs.length - 1);

      // Save to settings
      if (save_to_settings) {
        this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][new_tab]');
      }
    }

    console.log('[new_tab] ' + (Date.now() - t0) + ' ms!');
  }

  switch_tab(target: number, close_tabs_panel: boolean, save_to_settings: boolean) {
    this.last_tab_index = this.bunch_of_tabs.main_tab_idx; // Remember last tab
    console.log('[switch_tab] Last tab index [' + this.last_tab_index + '][' + this.tab_titles[this.last_tab_index] + ']')

    let tablet_mode = this.storage.get('tablet_mode') as boolean;
    let tabs_style_non_tablet_mode = AppStorage.get('tabs_style_non_tablet_mode') as string;
    if (!tablet_mode && close_tabs_panel) {
      // Auto close panel
      if (tabs_style_non_tablet_mode == "vertical") {
        this.storage.set('showing_tabs', false);
      }
    }

    this.choosing_paralleow = false;
    try {
      // Switch
      this.bunch_of_tabs.switchToTab(target);
      console.log('[Meow][meowTabs] Switch to tab ' + this.bunch_of_tabs.main_tab_idx.toString());
    } catch (e) {
      console.error('[Meow][TabsVertical][switch_tab][a] ' + e);
    }
    // Update history
    if (this.tabs_init_ok) {
      this.bunch_of_tabs.update_backward_forward_access();
    }

    try {
      // Set CURRENT variables
      sync_current_tabs_list_info(this.storage);
    } catch (e) {
      console.error('[TabsVertical][switch_tab][b] ' + e);
    }
    // Update Input Search Box
    let current_url = this.storage.get('current_url') as string;
    set_search_box_text(current_url, this.storage);

    determine_extra_background(this.storage);

    // Restore
    this.bunch_of_tabs.callRestore(this.getUIContext());

    if (save_to_settings) {
      this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][switch_tab]');
    }
  }

  close_tab(target: number, save_to_settings: boolean, move_target_window: number = -1) {
    if (!this.tabs_init_ok) {
      console.error("[Meow][LinysTabs][ERROR] Recover Not OK (" + target + ')!');
      return;
    }
    // Some kind of bug, idk why but this is essential when closing tabs quickly
    if (target >= this.bunch_of_tabs.Tabs.length) {
      console.error("[Meow][LinysTabs][ERROR] Ran into the weird bug of target >= this.offset_area.length");
      return;
    }

    // Reset last tab index
    if (target == this.last_tab_index) {
      this.last_tab_index = -1;
      console.log('[close_tab] Reset last tab index!');
    }

    // Turn off Paralleow
    if (target == this.bunch_of_tabs.sub_tab_idx || target == this.bunch_of_tabs.main_tab_idx) {
      if (this.bunch_of_tabs.sub_tab_idx > -1) {
        console.log('[Meow][LinysTabs] Paralleow off');
        this.bunch_of_tabs.sub_tab_idx = -1;
      }
    }
    // Ensure at least one tab is in the app
    if (this.bunch_of_tabs.Tabs.length == 1) {
      this.new_tab('', true, false);
    }

    let destination = this.bunch_of_tabs.main_tab_idx;
    if (target == this.bunch_of_tabs.main_tab_idx) {
      destination = this.last_tab_index;
    } // Closing current tab, jump back to last tab.

    // Close
    if (move_target_window > -1) {
      this.bunch_of_tabs.closeTab(target, true, destination);
    } else {
      this.bunch_of_tabs.closeTab(target, false, destination);
    }

    // Update history
    this.bunch_of_tabs.update_backward_forward_access();
    // Get synced lists
    sync_all_tabs_list_info(this.storage);
    // Update Input Search Box
    let current_url = this.storage.get('current_url') as string;
    set_search_box_text(current_url, this.storage);

    // Store tabs count
    let store_tabs_count = this.tab_titles.length;
    bunch_of_settings.set("continue_tabs_count", store_tabs_count);

    // re-save web states
    this.bunch_of_tabs.delete_shift_web_state(target);

    // Paralleow
    if (this.bunch_of_tabs.main_tab_idx == this.bunch_of_tabs.sub_tab_idx) {
      // if Paralleow crash then turn off
      this.bunch_of_tabs.sub_tab_idx = -1;
    }
    if (this.tab_titles.length == 1) {
      this.bunch_of_tabs.sub_tab_idx = -1;
      this.choosing_paralleow = false;
    } // if only 1 tab left then reset Paralleow stuff
    if (target < this.bunch_of_tabs.sub_tab_idx) {
      this.bunch_of_tabs.sub_tab_idx -= 1;
    }

    determine_extra_background(this.storage);

    // Restore
    this.bunch_of_tabs.callRestore(this.getUIContext());

    if (save_to_settings) {
      this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][close_tab]');
    }
  }

  /**
   * Unloads a tab.
   * @param target The index of the tab.
   * */
  unload(target: number) {
    let unload_result = this.bunch_of_tabs.callUnload(target);
    if (unload_result) {
      (this.storage.get('tab_restore_on_creations') as boolean[])[target] = true;
      this.bunch_of_tabs.update_my_timestamp(); // Try to call UI refresh;
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

  /**
   * Tries to scroll to a tab of specific index.
   * @param idx The index of the target tab.
   * */
  try_scroll_to(idx: number) {
    let tab_height_default: number = 42;
    clearTimeout(this.scroll_2_bottom_timeout_handle_id); // Cancel existing timeout;
    this.scroll_2_bottom_timeout_handle_id = setTimeout(() => {
      let tar = (idx + 1) * tab_height_default + (idx) * 5;

      // Determine scroll distance
      const max_y = (this.bunch_of_tabs.Tabs.length) * tab_height_default + (this.bunch_of_tabs.Tabs.length - 1) * 5;
      let scroll_y = tar - 0.5 * this.scroll_area_height - (tab_height_default + 5) * 0.5;
      // Limit range
      if (scroll_y > max_y - this.scroll_area_height) {
        scroll_y = max_y - this.scroll_area_height;
      }
      if (scroll_y < 0) {
        scroll_y = 0;
      }

      // Scroll
      console.log(`[try_scroll_to] idx=${idx}, tar=${tar}, scroll_y=${scroll_y}`);
      this.scroll_controller.scrollTo({
        xOffset: 0,
        yOffset: scroll_y,
        animation: true,
      });
    }, 50);
  }

  // Events

  on_global_custom_UA_change() {
    this.bunch_of_tabs.set_global_custom_UA(this.global_custom_UA);
  }

  uni_tab_button_click() {
    let clicked = this.uni_tab_button_clicked;
    let sub = this.bunch_of_tabs.sub_tab_idx;
    let main = this.bunch_of_tabs.main_tab_idx;

    if (clicked < 0) {
      // Reset
      return;
    }

    // Unload
    if (this.unloading_tabs) {
      this.unload(clicked);
      // Reset
      this.uni_tab_button_clicked = -1;
      return;
    }

    console.log('[Meow][uni_tab_button_click] [' + clicked + '] Clicked!');
    if (this.choosing_paralleow && main != clicked) {
      // if choosing Paralleow
      // and is not selected as main web
      // (this tab is selectable to be a sub view)
      // then set this tab as sub view
      this.choosing_paralleow = false;
      this.bunch_of_tabs.sub_tab_idx = clicked;
      this.bunch_of_tabs.callRestore(this.getUIContext(), clicked);
    } else if (sub >= 0 && (sub == clicked || main == clicked)) {
      // if Paralleow enabled
      // and this tab clicked is one of main or sub
      // then switch the two tabs
      this.switch_paralleow(false);
    } else {
      // simply switch tab
      // this.tab_animation = { duration: 0 };
      if (clicked != this.bunch_of_tabs.main_tab_idx) {
        this.switch_tab(clicked, true, false);
      }
    }
    this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][uni_tab_button_click]');

    // Reset
    this.uni_tab_button_clicked = -1;
    return;
  }

  uni_new_tab() {
    let url = this.new_tab_gateway[0] as string;
    let is_popup = this.new_tab_gateway[1] as boolean;

    // Intercept
    if (url == "" || url == this.last_tab_gateway_url) {
      console.warn(`[meowTabsVertical][uni_new_tab] INTERCEPTED url=${url}, last_tab_gateway_url=${this.last_tab_gateway_url}, isAlert=${is_popup}!`);
      return;
    } else {
      console.log(`[meowTabsVertical][uni_new_tab] url=${url}, last_tab_gateway_url=${this.last_tab_gateway_url}, isAlert=${is_popup}!`);
    }

    if (url == "new_tab") {
      url = ""
    }

    this.new_tab(url, true, false, undefined, undefined);

    this.last_tab_gateway_url = url;
    this.new_tab_gateway = ["", false];

    clearTimeout(this.last_tab_gateway_reset_timeout_id);
    this.last_tab_gateway_reset_timeout_id = setTimeout(() => {
      // Avoid opening duplicate tabs, idk why
      this.last_tab_gateway_url = '';
    }, 300);
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
    if (this.bunch_of_tabs.Tabs[from_tab_index].pre_restoration_stage) {
      // Need restore
      let array_buffer = sandbox_read_arrayBuffer_sync("continue/continue_tabs_web_state_array_" + from_tab_index.toString());
      if (array_buffer) {
        this.bunch_of_tabs.Tabs[from_tab_index].web_state_array = new Uint8Array(array_buffer);
      } else {
        console.error("[Meow][uni_move_tab] Restore web state failed! Read NOTHING from disk???");
      }
    }
    this.close_tab(from_tab_index, true, to_window);
    // Notify target window to receive tab.
    storage_of_index(to_window).setOrCreate('receive_tab', Date.now());
    this.move_tab_gateway = -1;
  }

  /**
   * Respond to wants
   * */
  on_want() {
    if ((this.storage.get('want_source') as string) == 'onCreate') {
      // A good BrowserCat never takes the wants needed by other new-born windows!
      console.log('[Meow][meowTabsVertical] Ignored onCreate want!');
      return;
    }

    check_want(this.storage.get('want_uri') as string, this.storage.get('want_action') as string, this.storage.get('want_type') as string, this.storage);
  }

  /**
   * Called when THE_LORD_OF_THE_WINDOWS changes (the #0 is closed).
   * */
  on_THE_LORD_OF_THE_WINDOWS_change() {
    console.warn(`[meowTabsVertical][on_THE_LORD_OF_THE_WINDOWS_change] LORD ${this.THE_LORD_OF_THE_WINDOWS}`);
    console.warn(`[meowTabsVertical][on_THE_LORD_OF_THE_WINDOWS_change] MYID ${this.my_window_id}`);
    if (this.my_window_id == this.THE_LORD_OF_THE_WINDOWS) {
      // Save web states
      this.bunch_of_tabs.clear_all_web_state();
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
    this.new_tab('receive tab', true, true);
    sync_all_tabs_list_info(this.storage); // TODO: this can be optimized
    this.switch_tab(this.bunch_of_tabs.Tabs.length - 1, false, true);
  }

  // Data

  is_right_align() {
    return (this.preferred_hand_left_or_right == 'right' && !this.preferred_hand_reverse_tabs_panel) ||
      (!(this.preferred_hand_left_or_right == 'right') && this.preferred_hand_reverse_tabs_panel);
  }

  width_of_Tabs() {
    if (this.tablet_mode) {
      // Tablet mode
      if (this.tabs_style == 'horizontal') {
        return 0;
      } else {
        return this.storage.get('right_control_width') as number;
      }
    } else {
      // non_tablet_mode
      if (this.tabs_style_non_tablet_mode == 'horizontal') {
        return 0;
      } else {
        return 0.9 * this.screen_width;
      }
    }
  }
}

export default meowTabsVertical;

// @Reusable // Is this safe? No, this loses the height animation
@Component
struct TabButton {
  // Sync
  @Prop Label: tab_label;
  // Public
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @LocalStorageLink('vertical_tabs_scroll_area_height') scroll_area_height: number = 0;
  // Data
  @LocalStorageLink('tab_titles') tab_titles: string[] = [];
  @LocalStorageLink('tab_restore_on_creations') tab_restore_on_creations: boolean[] = [false];
  // Settings
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Gateways
  @LocalStorageLink('universal_tab_button_click_gateway') uni_tab_button_clicked: number = -1;
  @LocalStorageLink('universal_close_tab_gateway') close_tab_gateway: number = -1;
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // UI
  tab_height_default: number = 42;
  @State tab_height: number = (this.bunch_of_tabs.Tabs.length * (this.tab_height_default + 5) - 5 < this.scroll_area_height) ? 0 : this.tab_height_default;
  @State my_vis: Visibility = Visibility.Hidden;
  @State isHov: boolean = false;

  build() {
    Row({ space: 5 }) {
      if (this.preferred_hand_left_or_right == 'left') {
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.xmark',
          can_hover: true,
          font_size: fontSize_Icon_Button() * 0.85,
          radius: 6
        })
          .onClick(() => {
            this.close_tab_gateway = this.Label.index_key;
            // Close tab
          })
          .margin({ right: 4 })
      }

      if (this.bunch_of_tabs.sub_tab_idx > -1 && this.bunch_of_tabs.main_tab_idx == this.Label.index_key) {
        Text(this.tablet_mode ? "󰃊" : "󰃎") // Paralleow icon left
          .fontColor(this.color_current_font)
          .animation(animation_default())
          .fontSize(fontSize_Large())
          .fontWeight(FontWeight.Bold)
      }

      if (this.bunch_of_tabs.sub_tab_idx == this.Label.index_key) {
        Text(this.tablet_mode ? "󰈱" : "󰈮") // Paralleow icon right
          .fontColor(this.color_current_font)
          .animation(animation_default())
          .fontSize(fontSize_Large())
          .fontWeight(FontWeight.Bold)
      }

      Text(this.tab_titles[this.Label.index_key] == "" ? "Meow" : this.tab_titles[this.Label.index_key])
        .fontSize(fontSize_Normal())
        .fontColor(this.color_current_font)
        .fontWeight((this.bunch_of_tabs.main_tab_idx == this.Label.index_key ||
          this.bunch_of_tabs.sub_tab_idx == this.Label.index_key)
          ? FontWeight.Bold : undefined)
        .maxLines(1)
        .layoutWeight(1)
        .keyboardShortcut(this.bunch_of_tabs.main_tab_idx == this.Label.index_key ? this.bunch_of_key_shortcuts.close_tab.main_key : '',
          this.bunch_of_key_shortcuts.close_tab.modifier, () => {
            this.close_tab_gateway = this.Label.index_key;
          })

      if (this.preferred_hand_left_or_right == 'right') {
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.xmark',
          can_hover: true,
          font_size: fontSize_Icon_Button() * 0.85,
          radius: 6
        })
          .onClick(() => {
            this.close_tab_gateway = this.Label.index_key;
            // Close tab
          })
          .margin({ right: 4 })
      }

    } // Title and xmark
    .border({
      radius: 10,
      width: 2,
      color: (this.bunch_of_tabs.main_tab_idx == this.Label.index_key || this.bunch_of_tabs.sub_tab_idx == this.Label.index_key)
        ? this.color_current_font : "transparent"
    })
    .backgroundColor(this.color_current_secondary)
    .visibility(this.my_vis)
    .opacity(this.tab_restore_on_creations[this.Label.index_key] ? 0.5 : 1)
    .height(this.tab_height)
    .padding(this.preferred_hand_left_or_right == 'right' ? { left: 10 } : { right: 10 })
    .brightness(this.isHov ? 1.1 : 1)
    .animation(animation_default())
    .alignItems(VerticalAlign.Center)
    .clickEffect(click_effect_default())
    .width("100%")
    .onClick(() => {
      this.uni_tab_button_clicked = this.Label.index_key;
    })
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
    .onAppear(() => {
      this.my_vis = Visibility.Visible;
      this.tab_height = this.tab_height_default;
      this.tab_restore_on_creations[this.Label.index_key] = this.bunch_of_tabs.Tabs[this.Label.index_key].pre_restoration_stage;
    })
    .onHover((isHv) => {
      this.isHov = isHv;
    })

    // .onMouse((e) => {
    //   if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
    //     // Right click
    //     this.unload_me();
    //   }
    // })
  }
}