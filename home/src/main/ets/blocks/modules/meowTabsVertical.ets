import { bunch_of_tabs, tab_label } from '../../hosts/bunch_of_tabs';
import { animation_default, click_effect_default, fontSize_Large, fontSize_Normal, url_default_blank } from '../../hosts/bunch_of_defaults';
import { sandbox_read_text_sync } from '../../utils/storage_tools';
import { run_time, storage_of_id, storage_of_index } from '../../utils/ui_tools';
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
  @LocalStorageLink('want_source') want_source: string = 'want';
  @LocalStorageLink('want_uri') want_uri: string = 'want';
  @LocalStorageLink('want_action') want_action: string = '';
  @LocalStorageLink('want_type') want_type: string = '';
  // Hosts and environments
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @LocalStorageLink('showing_tabs') showing_tabs: boolean = false;
  @LocalStorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  // Surf
  @StorageLink('home_url') home_url: string = '';
  @StorageLink('new_tab_url') new_tab_url: string = '';
  @StorageLink('start_up_option') start_up_option: string = '';
  // Controls
  @LocalStorageLink('tab_titles') tab_titles: string[] = []
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  // Other Info / Statuses
  pre_recover_tabs_finished: boolean = false;
  @LocalStorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @LocalStorageLink('last_tab_index') last_tab_index: number = -1;
  @StorageLink('intelligent_tracking_prevention') intelligent_tracking_prevention: boolean = false;
  // Delay
  @LocalStorageLink('delayed_load_p1') delayed_load_p1: boolean = false;
  // Animation info
  @State my_visibility: Visibility = Visibility.Hidden;
  scroll_controller: Scroller = new Scroller();
  @State scroll_area_height: number = 0;
  // need_help_scroll: boolean = true;
  @State paralleow_description_height: number = 0;
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
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Drop
  @LocalStorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  // Pan Gesture
  pan_x: number = 0;
  // Timeout
  scroll_2_bottom_timeout_handle_id: number | undefined = undefined;

  // ABANDONED. Logics moved to onAppear to avoid block in UI rendering.
  // aboutToAppear() {
  //   this.preprocessing();
  // }

  build() {
    if (this.delayed_load_p1) {
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

          // .onAreaChange((_o, n) => {
          //   this.need_help_scroll = (n.height as number) > this.scroll_area_height;
          // })
        } // Tab Buttons List
        .direction(Direction.Rtl)
        .align(Alignment.Bottom)
        .edgeEffect(EdgeEffect.Spring)
        .width("100%")
        .borderRadius(10)
        // .height(this.scroll_area_height - (this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 ? this.paralleow_description_height : 0))
        .layoutWeight(1)
        .animation(animation_default())

        // .nestedScroll({ scrollForward: NestedScrollMode.SELF_ONLY, scrollBackward: NestedScrollMode.SELF_ONLY })

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
              this.new_tab("", true, false);
            })
            .keyboardShortcut(this.bunch_of_key_shortcuts.new_tab.main_key, this.bunch_of_key_shortcuts.new_tab.modifier)
        } // New Tab and Paralleow Button
        .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
        .width("100%")

        linysText({ text: $r('app.string.Paralleow_description'), max_lines: 4 })
          .onAreaChange((_o, n) => {
            this.paralleow_description_height = n.height as number + 10;
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
        this.my_visibility = Visibility.Visible;
        console.log(`[Meow][meowTabsvertical] onAppear! (${run_time(this.storage)} ms)`);
        this.preprocessing(this.storage);
      })
      .onAreaChange((_o, n) => {
        this.scroll_area_height = n.height as number - 50;
      })
      .onDrop((e) => {
        try {
          let drop_ok = drop_to_scratching_board(e, this.storage, true);
          if (!drop_ok) {
            this.showing_scratching_board = false;
          }
        } catch (e) {
          console.error('[onDrop] Failed: ' + e);
        }
      })
      .onDragEnter(() => {
        // this.showing_scratching_board = true;
        this.showing_scratching_board = false;
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
            if (this.is_right_align()) {
              if (this.pan_x < 0) {
                // ← Switch to Bookmarks
                this.showing_bookmarks = true;
                // this.showing_tabs = false;
              } else {
                // → Right Align Close panel
                this.showing_tabs = false;
              }
            } else {
              if (this.pan_x < 0) {
                // ← Close panel
                this.showing_tabs = false;
              } else {
                // → Open bookmarks
                this.showing_bookmarks = true;
              }
            }
          })
      )
    }
  }

  // Tab controls

  preprocessing(storage: LocalStorage) {
    let t0 = Date.now();

    // Start
    let continue_tabs_sub_on = AppStorage.get('continue_tabs_sub_on') as number;
    let continue_tabs_main_on = AppStorage.get('continue_tabs_main_on') as number;
    let continue_tabs_count = AppStorage.get('continue_tabs_count') as number;
    let start_up_option = AppStorage.get('start_up_option') as string;
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
          start_tab_url = this.new_tab_url;
        } else {
          start_tab_url = (this.home_url == "") ? url_default_blank() : this.home_url;
        }
        this.new_tab(start_tab_url, false, false);
        this.switch_tab(0, false, false);
      }
    } else {
      // Main window
      // Start Up: generate / recover tabs
      if (start_up_option == "new tab") {
        try {
          this.new_tab(this.new_tab_url, false, false);
          this.switch_tab(0, false, false);
        } catch (e) {
          console.error('[TabsVertical][NEW_TAB] ' + e);
        }
      } else if (start_up_option == "home") {
        try {
          this.new_tab((this.home_url == "") ? url_default_blank() : this.home_url, false, false);
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

    if (want_source == 'onCreate' && go_want) { // TODO: Is this check necessary?
      setTimeout(() => {
        // Don't block first
        console.log(`[Meow][init][meowTabsVertical] check want. (${(Date.now() - t0)}/${run_time(storage)} ms)`);
        check_want(want_uri, want_action, want_type, storage);
      }, 10);
    }

    this.pre_recover_tabs_finished = true;
    this.last_tab_index = this.bunch_of_tabs.main_tab_idx; // Set last_tab_index

    console.log(`[Meow][init][meowTabsVertical] Preprocessing Tabs OK. (${(Date.now() - t0)}/${run_time(storage)} ms)`);
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

    if (is_from_receive) {
      this.bunch_of_tabs.receive_tab(this.storage);
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
      console.error('[Meow][TabsVertical][switch_tab][a] ' + e);
    }
    // Update history
    if (this.pre_recover_tabs_finished) {
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

    // Restore
    this.bunch_of_tabs.callRestore(this.getUIContext());

    if (save_to_settings) {
      this.bunch_of_tabs.save_tab_index_stats('[meowTabsVertical][switch_tab]');
    }
  }

  close_tab(target: number, save_to_settings: boolean, move_target_window: number = -1) {
    if (!this.pre_recover_tabs_finished) {
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
    set_search_box_text(this.current_url, this.storage);

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

  try_scroll_to(idx: number) {
    // Animation part
    clearTimeout(this.scroll_2_bottom_timeout_handle_id); // Cancel existing timeout;
    this.scroll_2_bottom_timeout_handle_id = setTimeout(() => {
      let need_ani = this.bunch_of_tabs.Tabs.length * 42 + (this.bunch_of_tabs.Tabs.length - 1) * 5 > this.scroll_area_height;
      let tar = (idx + 1) * 42 + (idx) * 5;
      console.log(`[try_scroll_to] need_ani=${need_ani}, idx=${idx}, tar=${tar}, scroll_area_height=${this.scroll_area_height}`);
      if (need_ani) {
        this.scroll_controller.scrollTo({
          xOffset: 0,
          yOffset: tar - this.scroll_area_height,
          animation: true,
        });
      }
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

    if (clicked >= 0) {
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
    }
    // Reset
    this.uni_tab_button_clicked = -1;
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
}

export default meowTabsVertical;

// @Reusable // Is this safe? No, this loses the height animation
@Component
struct TabButton {
  // Sync
  @Prop Label: tab_label;
  tab_height_default: number = 42;
  @State tab_height: number = 0;
  // Public
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // Data
  @LocalStorageLink('tab_titles') tab_titles: string[] = [];
  @LocalStorageLink('tab_restore_on_creations') tab_restore_on_creations: boolean[] = [false];
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Gateways
  @LocalStorageLink('universal_tab_button_click_gateway') uni_tab_button_clicked: number = -1;
  @LocalStorageLink('universal_close_tab_gateway') close_tab_gateway: number = -1;
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

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
      // .offset({ y: this.offset_area[this.Label.index_key] })
      .animation(animation_default())
      .width("100%")
      .height(this.tab_height_default)
      .padding(10)
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
    .opacity(this.tab_restore_on_creations[this.Label.index_key] ? 0.5 : 1)
    .height(this.tab_height)
    .animation(animation_default())
    .width("100%")
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
    .onAppear(() => {
      this.tab_height = this.tab_height_default;
      this.tab_restore_on_creations[this.Label.index_key] = this.bunch_of_tabs.Tabs[this.Label.index_key].pre_restoration_stage;
    })
  }
}