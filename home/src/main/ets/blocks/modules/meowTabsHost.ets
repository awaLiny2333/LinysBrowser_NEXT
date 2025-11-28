import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { url_default_blank } from '../../hosts/bunch_of_defaults';
import { sandbox_read_arrayBuffer_sync, sandbox_read_text_sync } from '../../utils/storage_tools';
import { run_time, storage_of_id, storage_of_index } from '../../utils/ui_tools';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import lazy { check_want } from '../../utils/want_tools';
import lazy {
  determine_extra_background, set_search_box_text, sync_all_tabs_list_info, sync_current_tabs_list_info
} from '../../processes/tabs_actions';
import { mark_zone_opened, stat_of_zone, web_state_dir } from '../../processes/zone_actions';
import { fileIo } from '@kit.CoreFileKit';
import { meowContext } from '../../utils/environment_tools';

@Component
struct meowTabsHost {
  @StorageLink('THE_LORD_OF_THE_WINDOWS') @Watch('on_THE_LORD_OF_THE_WINDOWS_change') THE_LORD_OF_THE_WINDOWS: string = '';
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('is_zone') is_zone: boolean = false;
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // Want
  @LocalStorageLink('want_timestamp') @Watch('on_want') want_timestamp: string = '0';
  /**
   * Hosts and environments */
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // Controls
  @LocalStorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @LocalStorageLink('showing_tabs') showing_tabs: boolean = false;
  @LocalStorageLink('tab_titles') tab_titles: string[] = []
  // Other Info / Statuses
  @LocalStorageLink('tabs_init_ok') tabs_init_ok: boolean = false;
  @LocalStorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @LocalStorageLink('unloading_tabs') unloading_tabs: boolean = false;
  @LocalStorageLink('last_tab_index') last_tab_index: number = -1;
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
  @LocalStorageLink('choose_paralleow_timestamp') @Watch('choose_paralleow') choose_paralleow_timestamp: number = 0;
  @StorageLink('universal_global_custom_ua_gateway') @Watch('on_global_custom_UA_change') global_custom_UA: string = "";

  build() {
    Column() // Tabs Host
      .onAppear(() => {
        console.log(`[Meow][meowTabsHost] onAppear! (${run_time(this.storage)} ms)`);
        setTimeout(() => {
          this.preprocessing(this.storage);
        }, 1)
      })
  }

  // Tab controls

  preprocessing(storage: LocalStorage) {
    let t0 = Date.now();

    // Start
    let start_up_option = bunch_of_tabs.start_up;
    // Want
    let want_uri = storage.get('want_uri') as string;
    let want_source = storage.get('want_source') as string;
    let want_action = storage.get('want_action') as string;
    let want_type = storage.get('want_type') as string;

    let go_want = want_uri.length > 0 && want_source == 'onCreate';

    // Tabs
    let lord = AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string;
    console.log(`[Meow][init][meowTabsVertical] Lord=${lord}, this.my_window_id=${this.my_window_id}`);
    if (lord != this.my_window_id) {
      // Sub windows
      if (this.is_zone) {
        // Restore
        let stat = stat_of_zone(storage);
        this.restore_zone(storage, go_want, t0, stat[0], stat[1]);
      } else if (go_want) {
        // Do nothing if is a wanted new window to a running BrowserCat.
        console.log(`[Meow][init][meowTabsVertical] Is a sub window! And there are wants?`);
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
        console.log(`[Meow][init][meowTabsVertical] Is a sub window!`);
      }

    } else {
      // Main / Lord window; Start Up: generate / recover tabs

      let tabs_list = fileIo.listFileSync(meowContext().filesDir + '/continue');
      let last_zone = AppStorage.get('last_zone') as string;

      if ((tabs_list.length == 0 && last_zone == '') || start_up_option == "new tab") {
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
        // Continue
        console.log(`[Meow][init][meowTabsVertical] about to continue. Found last_zone=${last_zone}, (${(Date.now() - t0)}/${run_time(storage)} ms)`);

        if (last_zone != '') {
          // Need restore Zone
          this.my_window_alias = last_zone;
          this.is_zone = true;
          // Restore
          let stat = stat_of_zone(storage);
          this.restore_zone(storage, go_want, t0, stat[0], stat[1]);
          // Mark restore Zone OK
          mark_zone_opened(this.storage.get('my_window_alias') as string, true);
          // Log
          console.log(`[Meow][init][meowTabsVertical] Is a LORD zone restore!`);
        } else {
          // No Need restore Zone
          this.restore_zone(storage, go_want, t0, AppStorage.get('continue_tabs_main_on') as number, AppStorage.get('continue_tabs_sub_on') as number);
          // Create new tabs of a temp lord
          console.log(`[Meow][init][meowTabsVertical] Is a LORD temp restore!`);
        }
      }
    }

    // Do want
    if (go_want && want_source == 'onCreate') {
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

  restore_zone(storage: LocalStorage, go_want: boolean, t0: number, continue_tabs_main_on: number, continue_tabs_sub_on: number) {
    // Restore zones
    console.log(`[Meow][init][meowTabsVertical][restore_zone] about to restore tabs. (${(Date.now() - t0)}/${run_time(storage)} ms)`);
    let dir = web_state_dir(this.storage);

    let tabs_list = fileIo.listFileSync(meowContext().filesDir + '/' + dir);
    for (let index = 0; index < Math.floor(tabs_list.length / 2); index++) {
      try {
        let label_file = dir + "/continue_tabs_web_state_array_" + index.toString() + '_label';
        let label = sandbox_read_text_sync(label_file); // Name of that tab
        // console.log(`[Meow][init][meowTabsVertical] Tab #${index}! label=${label}`);
        this.new_tab("", false, false, true, label);
      } catch (e) {
        console.error('[TabsVertical][restore_zone][new_tab] ' + e);
      }
    }

    // Switch to *THE* tab if there is no want,
    // and DON'T switch if there IS a want
    // (or that tab would be woken at the same time as the loading of the wanted tab)
    if (!go_want) {
      this.switch_tab(continue_tabs_main_on, false, false);
      this.try_scroll_to(continue_tabs_main_on);
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
      let dir = web_state_dir(this.storage);
      if (dir) {
        console.log('[new_tab][is_from_receive] Save web state!');
        let idx = this.bunch_of_tabs.Tabs.length - 1;
        let r = this.bunch_of_tabs.save_web_state_to_sandbox(idx, dir);
        if (r) {
          this.bunch_of_tabs.save_web_label_to_sandbox(idx, dir);
        }
      }
    } else {
      this.bunch_of_tabs.newTab(this.getUIContext(), target_url, init_state, placeholder_label);
    }

    // Following processing for non init tabs;
    if (!init_state) {
      // Get synced lists
      sync_all_tabs_list_info(this.storage);

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
    this.storage.set('meow_tabs_vertical_scroll_to_idx', idx);
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
      let array_buffer = sandbox_read_arrayBuffer_sync(web_state_dir(this.storage) + "/continue_tabs_web_state_array_" + from_tab_index.toString());
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
      if (!this.is_zone) {
        this.bunch_of_tabs.re_save_web_state(0, 'continue');
        // Save tab continue data
        this.bunch_of_tabs.save_tab_index_stats('[on_THE_LORD_OF_THE_WINDOWS_change]');
      }
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
}

export default meowTabsHost;