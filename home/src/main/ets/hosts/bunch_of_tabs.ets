import { webview } from '@kit.ArkWeb';
import { match_domain, url_meow_to_resource, url_resource_to_meow } from '../utils/url_tools';
import { url_default_blank } from './bunch_of_defaults';
import lazy { storage_of_id, window_index_of_id } from '../utils/ui_tools';
import lazy {
  document_save_from_path,
  sandbox_access,
  sandbox_mkdir_sync,
  sandbox_read_arrayBuffer_sync,
  sandbox_rename_sync,
  sandbox_rmdir_sync,
  sandbox_save,
  sandbox_unlink_sync
} from '../utils/storage_tools';
import lazy { bunch_of_settings } from './bunch_of_settings';
import lazy { save_history } from '../processes/tabs_actions';
import lazy { createNWeb, TabNodeController } from '../objects/WebNode';

export class bunch_of_tabs {
  // Settings
  static new_tab_url: string = 'meow://home';
  static home_url: string = 'meow://home';
  static start_up: string = 'new tab';
  // Major Data
  Tabs: Array<tab_info_packed> = [];
  Labels: Array<tab_label> = [];
  NodeControllers: Array<TabNodeController | undefined> = [];
  my_id: string;
  // Statuses
  main_tab_idx: number = 0;
  sub_tab_idx: number = -1;
  current_accessForward: boolean = false;
  current_accessBackward: boolean = false;
  // Private / Temp / Meaningless
  status_update_timestamp: number = 0;
  private used_date_ids: number[] = [];

  /**
   * A class holding tabs in a list which provides methods to operate tabs.
   *
   * @param no_init Will not set my_id.
   */
  constructor(no_init: boolean, id?: string) {
    if (no_init) {
      this.my_id = '';
      return;
    }
    this.my_id = id || '';
    console.log('[Meow][bunch_of_tabs] Init success! ID: ' + this.my_id + '!');
  }

  // Operations and Actions

  /**
   * Loads a link on the current main tab.
   * @description Will load url_default_blank() if the home_url of this bunch_of_tabs is not set.
   * */
  loadUrl_onWorkingTab(url: string) {
    url = url_meow_to_resource(url);
    console.log('[bunch_of_tabs][loadUrl_onWorkingTab] ' + url);
    this.Tabs[this.main_tab_idx].controller.loadUrl(url);
  }

  /**
   * Loads home link on the current main tab.
   * @description Will load url_default_blank() if the home_url of this bunch_of_tabs is not set.
   * */
  go_home_onWorkingTab() {
    let going_home_url = "";
    if (bunch_of_tabs.home_url == undefined || bunch_of_tabs.home_url == "") {
      going_home_url = url_default_blank();
    } else {
      going_home_url = bunch_of_tabs.home_url;
    }
    this.loadUrl_onWorkingTab(going_home_url);
  }

  /**
   * Refreshes current main tab.
   * */
  refresh_onWorkingTab() {
    this.Tabs[this.main_tab_idx].controller.refresh();
    this.Tabs[this.main_tab_idx].update_url(true);
  }

  /**
   * Stops the load on current main tab.
   * */
  stop_onWorkingTab() {
    this.Tabs[this.main_tab_idx].controller.stop();
  }

  /**
   * Try to go forward on current main tab.
   * @returns true if success.
   * @returns false if failed, perhaps there is no way forward.
   * */
  goForward_onWorkingTab() {
    if (this.Tabs[this.main_tab_idx].controller.accessForward()) {
      this.Tabs[this.main_tab_idx].controller.forward();
    }
  }

  /**
   * Try to go backward on current main tab.
   * @returns true if success.
   * @returns false if failed, perhaps there is no way backward.
   * */
  goBackward_onWorkingTab() {
    if (this.Tabs[this.main_tab_idx].controller.accessBackward()) {
      this.Tabs[this.main_tab_idx].controller.backward();
      return true;
    }
    return false;
  }

  /**
   * Try to archive current main tab into a mht file.
   *
   * Calls the picker for user to save.
   *
   * @param dir Should be this.getUIContext().getHostContext()?.tempDir
   * */
  archive_onWorkingTab(dir?: string) {
    // let dir = this.getUIContext().getHostContext()?.tempDir;
    if (dir) {
      this.workingMainTab().controller.storeWebArchive(dir + '/meow_save.mht', false, ((e, filename) => {
        if (e) {
          console.error(`[Save Page] Failed: ${e.name}, ${e.message}, ${e.code}`);
        }
        if (filename) {
          console.log('[Save Page] OK: ' + filename);
          document_save_from_path(filename);
        }
      }))
    }
  }

  /**
   * Dispose all nodes.
   *
   * USE THIS ONLY WHEN WINDOW IS ABOUT TO DESTROY!
   * */
  DISPOSE() {
    for (let index = 0; index < this.NodeControllers.length; index++) {
      this.NodeControllers[index]?.detachWeb();
      this.NodeControllers[index]?.dispose();
    }
  }

  // UA Stuff

  /**
   * Sets the custom user agent of all tabs. Resets the custom user agent to ArkWeb default if param is "" (empty).
   * @param ua A string, the user agent params.
   * */
  set_global_custom_UA(ua: string) {
    // Reset default if no input
    if (ua == "") {
      this.reset_global_custom_UA();
      console.log("[bunch_of_tabs][UA] Reset global_custom_UA to ArkWeb default! ua: " + this.get_global_default_UA())
      return;
    }

    for (let index = 0; index < this.Tabs.length; index++) {
      this.Tabs[index].controller.setCustomUserAgent(ua)
    }
    console.log("[bunch_of_tabs][UA] Set global_custom_UA! ua: " + ua)
  }

  /**
   * Resets the custom user agent to ArkWeb default.
   * */
  reset_global_custom_UA() {
    let default_ua = this.get_global_default_UA();
    for (let index = 0; index < this.Tabs.length; index++) {
      this.Tabs[index].controller.setCustomUserAgent(default_ua)
    }
  }

  /**
   * Gets the default user agent of system ArkWeb.
   * @returns A string, the default user agent
   * */
  get_global_default_UA() {
    return this.Tabs[0].controller.getUserAgent();
  }

  // Data and Statuses

  /**
   * Updates the current_accessBackward and current_accessForward statuses.
   * */
  update_backward_forward_access() {
    if (this.workingMainTab()) {
      try {
        this.current_accessBackward = this.workingMainTab().controller.accessBackward()
        this.current_accessForward = this.workingMainTab().controller.accessForward()
      } catch (e) {
        console.error('[bunch_of_tabs][update_backward_forward_access] Error: ' + e);
      }
    }
  }

  /**
   * Calls the specific tab to sync web_state to bunch_of_tabs.
   * @param index The index of tab.
   * @param force Set to true if want to ignore frequency limit.
   * */
  update_web_state(index: number, force: boolean): boolean {
    return this.Tabs[index].update_web_state(force);
  }

  /**
   * Gets the current url of the main tab.
   * @returns The url.
   * */
  get_current_main_url() {
    return this.Tabs[this.main_tab_idx].url;
  }

  /**
   * Gets the current url of the sub tab.
   * @returns The url.
   * */
  get_current_sub_url() {
    return this.Tabs[this.sub_tab_idx].url;
  }

  /**
   * Gets the new tab url.
   * @returns The new_tab_url.
   * */
  get_new_tab_url() {
    return bunch_of_tabs.new_tab_url;
  }

  /**
   * Gets the home url.
   * @returns The home_url.
   * */
  get_home_url() {
    return bunch_of_tabs.home_url;
  }

  // General Tab Controls

  /**
   * Switches to another tab.
   * @param target A number, the index of target tab.
   * @param restore A boolean. Will try to restore the tab if set true.
   * @returns A number, the index of target tab.
   * */
  switchToTab(target: number) {
    // Switch
    if (target >= this.Tabs.length) {
      target = this.Tabs.length - 1;
    }
    this.main_tab_idx = -1; // Weird way to refresh
    this.main_tab_idx = target;

    return target;
  }

  /**
   * Calls a tab to restore if possible.
   * @param target The target index.
   * */
  callRestore(context: UIContext, target: number = this.main_tab_idx) {
    let t0 = Date.now();
    console.log(`[switchToTab] Call of Restore! target: ${target}, this.Tabs[target].pre_restoration_stage: ${this.Tabs[target]?.pre_restoration_stage}`);
    if (target >= 0 && this.Tabs[target].pre_restoration_stage) {
      // Before Restore create a web first.
      if (this.NodeControllers[target] == undefined) {
        console.log(`[callRestore] of tab #${target}, Creating NWeb!`);
        this.NodeControllers[target] = new TabNodeController(createNWeb(context, this.Tabs[target]));
        this.NodeControllers[target]?.attachWeb();
        this.NodeControllers[target]?.rebuild();
      }
      this.Tabs[target].restore();
      console.log(`[callRestore] Restore of tab #${target} finished! (Used ${(Date.now() - t0)} ms)`);
    }
  }

  /**
   * Creates a new tab.
   * @param target_url A string, if link is "", then load the default new_tab_url set in this object.
   * @param recover_on_creation A boolean, if set true, then the tab will restore the serialized web state in
   * @returns A number, the index of the new tab.
   * @description While if new_tab_url is also not set ("" or undefined), then will load the url_default_blank().
   * */
  newTab(context: UIContext, target_url: string, init_state: boolean, placeholder_label?: string) {
    console.log(`[bunch_of_tabs] newTab: url=${target_url}`);
    if (target_url == "") {
      // If newing an empty tab
      if (bunch_of_tabs.new_tab_url == "" || bunch_of_tabs.new_tab_url == undefined) {
        // If new tab not specified
        target_url = url_default_blank();
      } else {
        // If new tab is specified
        target_url = bunch_of_tabs.new_tab_url;
      }
    }

    let idx = this.Tabs.length;
    let new_TabInfo: tab_info_packed = new tab_info_packed(placeholder_label || 'Meow', target_url, storage_of_id(this.my_id), idx, init_state);
    let Date_ID = Date.now();

    // TODO: IS THIS EFFICIENT ENOUGH?
    while (this.used_date_ids.includes(Date_ID)) {
      // Date_ID crash prevention
      Date_ID += 1;
    }
    let new_TabLabel: tab_label = new tab_label(Date_ID, idx);

    this.used_date_ids.push(Date_ID);
    this.Tabs.push(new_TabInfo);

    // TODO: Create this on demand for restoration, or we will stuck at aboutToAppear in meowTabsView for a long time
    if (init_state) {
      this.NodeControllers.push(undefined);
    } else {
      this.NodeControllers.push(new TabNodeController(createNWeb(context, new_TabInfo)));
    }

    this.Labels.push(new_TabLabel);
    this.main_tab_idx = this.Tabs.length - 1;

    // Turn on auto save web state
    // new_TabInfo.on_regular_save();

    return this.main_tab_idx as number;
  }

  /**
   * Receives a tab from LocalStorage, usually transferred from another window.
   *
   * This acts very like method newTab(...).
   * @param storage The LocalStorage.
   * @returns The new main tab index (idx of the new, received tab).
   * */
  receive_tab(storage: LocalStorage) {
    let move_tab_tab_info_packed = AppStorage.get('move_tab_tab_info_packed') as tab_info_packed;
    let move_tab_TabNodeController = AppStorage.get('move_tab_TabNodeController') as TabNodeController;

    let idx = this.Tabs.length;
    let Date_ID = Date.now();

    // TODO: IS THIS EFFICIENT ENOUGH?
    while (this.used_date_ids.includes(Date_ID)) {
      // Date_ID crash prevention
      Date_ID += 1;
    }
    let new_TabLabel: tab_label = new tab_label(Date_ID, idx);

    // Localize (whar)
    move_tab_tab_info_packed.index = idx;
    move_tab_tab_info_packed.storage = storage;

    this.used_date_ids.push(Date_ID);
    this.Tabs.push(move_tab_tab_info_packed);
    this.NodeControllers.push(move_tab_TabNodeController);
    this.Labels.push(new_TabLabel);
    this.main_tab_idx = this.Tabs.length - 1;

    return this.main_tab_idx as number;
  }

  /**
   * Closes a tab. If isMove is set to true, then the TabNodeController and tab_info_packed is stored to AppStorage.
   * @param target A number, the index of the tab requested to close.
   * @param isMove Is this a moving to another window or just a normal close?
   * @param preferred_destination usually the last tab index.
   * @returns A number, the index of current working main tab which eventually switched to.
   * */
  closeTab(target: number, isMove: boolean, preferred_destination: number) {

    // let landing_destination = preferred_destination;
    // Decide where to go

    // Check if is reset
    if (preferred_destination == -1) {
      preferred_destination = target - 1; // Switch to the last tab of closing
    }
    if (preferred_destination > this.Tabs.length - 1) {
      preferred_destination = this.Tabs.length - 1;
    }
    if (preferred_destination == target) {
      preferred_destination -= 1;
    }
    if (preferred_destination < 0) {
      preferred_destination = 0;
    }
    console.log('[closeTab][preferred_destination] ' + preferred_destination + '!');

    this.switchToTab(-1);
    // Forces LinysTabs to refresh For Each loop to render
    this.switchToTab(preferred_destination);

    // Turn off web state regular save
    // this.Tabs[target].off_regular_save();

    let tab = this.Tabs.splice(target, 1)[0];
    this.Labels.splice(target, 1);

    this.NodeControllers[target]?.detachWeb();
    // Dispose if is not move
    if (isMove) {
      this.NodeControllers[target]?.rebuild();
    } else {
      this.NodeControllers[target]?.dispose();
    }

    let nodeController = this.NodeControllers.splice(target, 1)[0];

    if (isMove) {
      AppStorage.setOrCreate('move_tab_tab_info_packed', tab);
      AppStorage.setOrCreate('move_tab_TabNodeController', nodeController);
    }

    // Refresh index_keys
    for (let i = target; i < this.Labels.length; ++i) {
      this.Labels[i].index_key -= 1;
      this.Tabs[i].index -= 1; // Forgot this and ran into bug. Fixed 20:55 Oct 20 2025.
    }

    if (this.main_tab_idx > target) {
      this.main_tab_idx -= 1;
    }

    console.log('[bunch_of_tabs][closeTab] ' + this.main_tab_idx + '!');

    // Clear used date ids
    if (this.Tabs.length == 1) {
      this.used_date_ids = [this.Labels[0].timestamp];
    }

    return this.main_tab_idx;
  }

  /**
   * Gets the current main tab.
   * @returns A tab_info_packed object, of the current main tab.
   * */
  workingMainTab() {
    return this.Tabs[this.main_tab_idx];
  }

  // Data Syncing

  /**
   * Returns the number of currently opened tabs
   * @returns A number.
   * */
  get_tabs_count() {
    return this.Tabs.length;
  }

  /**
   * Gets a list of all tabs' titles of current viewing pages.
   * @returns A string[] array, the titles.
   * */
  get_all_titles() {
    let titles: string[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      titles.push(this.Tabs[index].title);
    }
    return titles;
  }

  /**
   * Gets a list of all tabs' current viewing urls.
   * @returns A string[] array, the urls.
   * */
  get_all_urls() {
    let urls: string[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      urls.push(this.Tabs[index].url);
    }
    return urls;
  }

  /**
   * Gets a list of all tabs' current restoring state.
   * @returns A boolean[] array, the states.
   * */
  get_all_restore_on_creations() {
    let r: boolean[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      r.push(this.Tabs[index].pre_restoration_stage);
    }
    return r;
  }

  /**
   * Gets a list of all tabs' loading statuses.
   * @returns A boolean[] array, the statuses are either true or false.
   * */
  get_all_is_loading() {
    let is_loading: boolean[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      is_loading.push(this.Tabs[index].is_loading);
    }
    return is_loading;
  }

  /**
   * Gets a list of all tabs' loading progresses.
   * @returns A number[] array, the progresses are in the range [0, 100].
   * */
  get_all_loading_progress() {
    let progress: number[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      progress.push(this.Tabs[index].loading_progress);
    }
    return progress;
  }

  /**
   * Gets a list of all tabs' timestamps.
   * @returns A number[] array, the timestamps.
   * */
  get_all_time_stamps() {
    let stamps: number[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      stamps.push(this.Labels[index].timestamp);
    }
    return stamps;
  }

  /**
   * Gets a list of all tabs' domains.
   * @returns A string[][] array, the [scheme, domain].
   * */
  get_all_match_domains() {
    let match: string[][] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      match.push(match_domain(this.Tabs[index].url));
    }
    return match;
  }

  // Web states

  /**
   * Clears all web states.
   * */
  clear_all_web_state() {
    // Clear extra files
    try {
      sandbox_rmdir_sync('continue');
      sandbox_mkdir_sync('continue');
      console.info(`[re_save_web_state] Clear web state (continue) directory OK!`);
    } catch (e) {
      console.error(`[re_save_web_state] Clear web state (continue) directory failed!`);
    }
  }

  /**
   * Re-save all web states, usually used to ensure the correct order of tab indices.
   *
   * Clears whatever was in sandbox filesDir/continue directory.
   * @param start A number, all tabs with index greater or equal to start would re-save their web states to disk.
   * */
  re_save_web_state(start: number) {
    console.log('[Meow][bunch_of_tabs] Re_save_web_state! (' + this.my_id + ') (#' + window_index_of_id(this.my_id) + ') From ' + start + '.');
    // Save
    for (let index = start; index < this.Tabs.length; index++) {
      this.Tabs[index].update_web_state(false);
      this.save_web_state_to_sandbox(index);
      this.save_web_label_to_sandbox(index);
    }
  }

  /**
   * Deletes a tab's web state and shifts all after it forward 1 unit.
   *
   * Also checks and delete extra web states.
   * @param del The tab index to be deleted.
   * */
  delete_shift_web_state(del: number) {
    // Delete
    let key_state = "continue/continue_tabs_web_state_array_" + del.toString();
    let key_label = "continue/continue_tabs_web_state_array_" + del.toString() + "_label";
    sandbox_unlink_sync(key_state);
    sandbox_unlink_sync(key_label);
    // Shift
    for (let sft = del + 1; sft < this.Tabs.length + 1; sft++) {
      let old_key_state = "continue/continue_tabs_web_state_array_" + sft.toString();
      let old_key_label = "continue/continue_tabs_web_state_array_" + sft.toString() + "_label";
      let new_key_state = "continue/continue_tabs_web_state_array_" + (sft - 1).toString();
      let new_key_label = "continue/continue_tabs_web_state_array_" + (sft - 1).toString() + "_label";
      sandbox_rename_sync(old_key_state, new_key_state);
      sandbox_rename_sync(old_key_label, new_key_label);
    }
    // Clear extra files. This looks unnecessary but who knows if anything happens and files run into bugs? ¯\_(ツ)_/¯
    try {
      let k = this.Tabs.length;
      while (true) {
        let key_state = "continue/continue_tabs_web_state_array_" + k.toString();
        let key_label = "continue/continue_tabs_web_state_array_" + k.toString() + "_label";
        if (!sandbox_access(key_state) || !sandbox_access(key_label)) {
          break;
        }
        sandbox_unlink_sync(key_state);
        sandbox_unlink_sync(key_label);
        k += 1;
      }
      console.info(`[delete_shift_web_state] Clear extra files OK!`);
    } catch (e) {
      console.error(`[delete_shift_web_state] Clear extra files failed!`);
    }
  }

  /**
   * Saves web state of a specific tab to sandbox. Reads the web_state from bunch_of_tabs properties.
   *
   * So update_web_state() should be called before this function to keep it up-to-date.
   *
   * @param index The index of tab.
   * */
  save_web_state_to_sandbox(index: number) {
    // Save to sandbox
    this.Tabs[index].save_web_state_to_sandbox();
  }

  /**
   * Saves web label (title) of a specific tab to sandbox. Reads the title from bunch_of_tabs properties.
   *
   * So update_title() should be called before this function to keep it up-to-date.
   *
   * @param index The index of tab.
   * */
  save_web_label_to_sandbox(index: number) {
    let label_identifier = "continue/continue_tabs_web_state_array_" + index.toString() + '_label';
    sandbox_save(label_identifier, this.Tabs[index].title);
  }

  // Data statuses

  /**
   * Saves current_main_tab_index and current_sub_tab_index to bunch_of_settings.
   * */
  save_tab_index_stats(identifier: string) {
    // Store where am I
    bunch_of_settings.set("continue_tabs_main_on", this.main_tab_idx);
    bunch_of_settings.set("continue_tabs_sub_on", this.sub_tab_idx);
    console.log('[Meow]' + identifier + "[bunch_of_tabs] Stored index stats. Main: " + this.main_tab_idx + ' Sub: ' + this.sub_tab_idx);
  }

  /**
   * Updates the internal timestamp of this bunch_of_tabs object.
   *
   * So that UI refresh would be triggered.
   * */
  update_my_timestamp() {
    this.status_update_timestamp = Date.now();
  }
}

@Observed
export class tab_label {
  timestamp: number;
  index_key: number;

  /**
   * A class holding a timestamp and an index_key.
   * @param timestamp A number, usually the creation of the tab.
   * @param index_key A number, indicating the index of this tab in the tabs list.
   */
  constructor(timestamp: number, index: number) {
    this.index_key = index;
    this.timestamp = timestamp;
  }
}

export class tab_info_packed {
  // Environment
  storage: LocalStorage;
  // My Major Data
  controller: WebviewController;
  title: string = '';
  url: string = '';
  index: number = -1;
  // Settings
  tab_force_dark: boolean = false;
  tab_disable_js: boolean = false;
  tab_disable_image: boolean = false;
  // Statuses
  is_loading: boolean;
  loading_progress: number;
  searching_keyword: string = ''; // Keyword of in-page search
  searching_keyword_stats_current: number = 0; // Index of current viewing result during in-page search
  searching_keyword_stats_total: number = 0; // Total number of results of in-page search
  // Restore
  pre_restoration_stage: boolean = false;
  web_state_array: Uint8Array | undefined = undefined;
  // Update records
  last_saved_url: string = '';
  last_saved_title: string = '';
  // Update url change
  last_updated_url: string = '';
  last_update_web_state_time: number = 0;
  // Web sate
  regular_save_interval_id: number | undefined = undefined;

  /**
   * A class holding a controller and statuses of a tab.
   * @param title A string, the initial title when the tab is created.
   * @param link A string, the initial link when the tab is created.
   * @param restore_on_creation A boolean, optional, will restore web state on creation if the index in valid.
   */
  constructor(title: string, url: string, storage: LocalStorage, index: number, init_state: boolean) {
    this.storage = storage;
    this.controller = new webview.WebviewController();
    this.index = index;
    this.title = title;
    this.url = url;
    this.is_loading = url.substring(0, 7) != 'meow://';
    this.loading_progress = 0;
    if (init_state) {
      console.log(`[tab_info_packed] New pack: ${url}, this.pre_restoration_stage = true!`);
      this.pre_restoration_stage = true;
    }
  }

  // Data Sync

  /**
   * Asks the tab to update its title, usually called when the tab loads something new.
   * */
  update_title() {
    try {
      let title = this.controller.getTitle();
      if (this.title != title) { // Update on change;
        this.title = title;
      }
    } catch (e) {
      console.error('[update_title] Failed: ' + e);
    }
    return this.title;
  }

  /**
   * Asks the tab to update its link, usually called when the tab loads something new.
   *
   * This automatically updates the web settings as well!
   *
   * @param force_update_web_settings Set to true if you want to force refresh web settings and trigger UI update.
   * @returns The updated url.
   * */
  update_url(force_update_web_settings: boolean = false) {
    let url_got = this.url;
    try {
      url_got = this.controller.getUrl();
    } catch (e) {
      console.error('[update_url] Failed: ' + e);
    }
    this.url = url_resource_to_meow(url_got);
    if (force_update_web_settings || this.url != this.last_updated_url) {
      this.update_web_settings();
      let tabs = this.storage.get('bunch_of_tabs') as bunch_of_tabs;
      // Update web view
      tabs.NodeControllers[this.index]?.update(tabs.Tabs[this.index]);
      this.last_updated_url = this.url;
      console.log('[update_url] Update webview for a change in url: [' + this.url + ']!');
    }
    return this.url;
  }

  /**
   * Asks the tab to update its loading state, usually called when the tab starts loading or finishes loading.
   * */
  update_is_loading(is_loading: boolean) {
    this.is_loading = is_loading;
    return this.is_loading;
  }

  /**
   * Asks the tab to update its loading progress, usually called in the tab's loading progress.
   * */
  update_loading_progress(progress: number) {
    this.loading_progress = progress;
    return progress;
  }

  /**
   * Asks the tab to update its web_state array, usually called when loading or finished loading.
   *
   * @param force Set to true if want to ignore frequency limit.
   * */
  update_web_state(force: boolean) {
    if (!force && ((Date.now() - this.last_update_web_state_time) < 200)) {
      console.warn('[update_web_state] Intercepted for too frequent update! (' + (Date.now() - this.last_update_web_state_time) + 'ms)');
      return false;
    }
    try {
      this.web_state_array = this.controller.serializeWebState();
      this.last_update_web_state_time = Date.now();
      console.log('[update_web_state] new web state length: ' + this.web_state_array?.length);
      return true;
    } catch (e) {
      console.error('[update_web_state] Failed: ' + e);
      return false;
    }
  }

  /**
   * Tag myself as restore finished after 500 ms.
   * */
  delayed_set_restore_ok(action?: () => void) {
    setTimeout(() => {
      this.pre_restoration_stage = false;
      console.log(`[delayed_set_restore_ok] pack: ${this.url}, this.pre_restoration_stage = false!`);
      if (action) {
        try {
          action();
        } catch (e) {
          console.error('[delayed_set_restore_ok] Action Failed: ' + e);
        }
      }
    }, 10);
  }

  // Actions

  /**
   * Checks and saves history record under certain conditions (if is a new, legal history entry).
   * @param source
   * */
  check_save_history(source: string) {
    let saved = false;
    if (!this.pre_restoration_stage) {
      let is_new_history = (this.last_saved_url != this.url);
      if (is_new_history) {
        if (this.url_save_history(this.url)) {
          console.log('[bunch_of_tabs]' + source + ' Save history for [' + this.title + '](' + this.url + ')!');
          save_history(this);
          saved = true;
        }
      }
    }
    this.last_saved_url = this.url;
    this.last_saved_title = this.title;
    console.log('[bunch_of_tabs][check_save_history]' + source + ' ' + (saved ? 'Saved!' : 'Did nothing!'));
  }

  /**
   * Syncs the Web Settings (js, image, force dark) to the according LocalStorage.
   * @param index The index of tab.
   * */
  update_web_settings() {
    // JS
    let main_switch_js = AppStorage.get('disable_js') as boolean;
    let sub_switch_js = AppStorage.get('disable_js_all_sites') as boolean;
    let disable_js_these_sites = AppStorage.get('disable_js_these_sites') as string[];
    // Image
    let main_switch_image = AppStorage.get('disable_image') as boolean;
    let sub_switch_image = AppStorage.get('disable_image_all_sites') as boolean;
    let disable_image_these_sites = AppStorage.get('disable_image_these_sites') as string[];
    // Dark
    let main_switch_dark = AppStorage.get('web_force_dark_mode') as boolean;
    let exempt_sites = AppStorage.get('web_force_dark_mode_exemptions') as string[];
    // Operation
    let domain = match_domain(this.url)[1];
    if (!main_switch_js) {
      // Entire feature off, return false;
      this.tab_disable_js = false;
    } else if (sub_switch_js) {
      // Disable all js, return true;
      this.tab_disable_js = true;
    } else {
      // Check on case
      this.tab_disable_js = disable_js_these_sites.includes(domain);
    }
    if (!main_switch_image) {
      this.tab_disable_image = false;
    } else if (sub_switch_image) {
      this.tab_disable_image = true;
    } else {
      this.tab_disable_image = disable_image_these_sites.includes(domain);
    }
    if (!main_switch_dark) {
      this.tab_force_dark = false;
    } else if (sub_switch_image) {
      this.tab_force_dark = true;
    } else {
      this.tab_force_dark = !exempt_sites.includes(domain);
    }
  }

  /**
   * Restores my self if possible.
   * */
  restore() {
    // Restore Web State
    console.log(`[restore] pre_restoration_stage: ${this.pre_restoration_stage}, web_state_array.length: ${this.web_state_array?.length}`);
    if (this.pre_restoration_stage) {
      let array_file = "continue/continue_tabs_web_state_array_" + this.index.toString();
      let array_buffer = sandbox_read_arrayBuffer_sync(array_file);
      if (array_buffer) {
        this.web_state_array = new Uint8Array(array_buffer);
      }
    }
    if (this.web_state_array) {
      // Restore
      try {
        this.url = 'uwu';
        this.title = 'uwu';
        this.controller.clearHistory();
        this.controller.restoreWebState(this.web_state_array);
        console.log("[Meow][bunch_of_tabs] Restore web " + this.index.toString() + ", state Length: " + this.web_state_array.length.toString());
      } catch (e) {
        console.error("[Meow][bunch_of_tabs] Restore web state failed! " + e);
      }
    }
  }

  /**
   * Saves my web state to the storage.
   * */
  save_web_state_to_sandbox() {
    try {
      let web_state = this.web_state_array;
      if (web_state) {
        let file_name = "continue/continue_tabs_web_state_array_" + this.index.toString();
        sandbox_save(file_name, web_state.buffer);
      }
    } catch (e) {
      console.error('[tab_info_packed][save_web_state] Error: ' + e);
    }
  }

  /**
   * Regularly saves a tab's web state to storage.
   * @param index The tab index.
   * */
  on_regular_save() {
    // If is already on
    if (this.regular_save_interval_id != undefined) {
      return;
    }
    console.log(`[on_regular_save] Turned on regular save of web_state for tab #${this.index}, [${this.url}]!`);
    this.regular_save_interval_id = setInterval(() => {
      let is_lord = (this.storage.get('my_window_id') as string) == (AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string);
      // Update if is restored, and is the lord of the window.
      if (is_lord && !this.pre_restoration_stage) {
        console.log(`[on_regular_save] Regular save of web_state for tab #${this.index}, url=${this.url}:`);
        this.update_web_state(true);
        this.save_web_state_to_sandbox();
      } else {
        console.warn(`[on_page_end] Didn't save web_state, is_lord=${is_lord}, !pre_restoration_stage=${!this.pre_restoration_stage}, `
          + `my_window_id=${(this.storage.get('my_window_id') as string)}, THE_LORD_OF_THE_WINDOWS=${(AppStorage.get('THE_LORD_OF_THE_WINDOWS') as string)}`);
      }
    }, 5000);
  }

  /**
   * Turn of regular saving of a tab's web state to storage.
   *
   * MUST BE CALLED BEFORE DELETE TAB!
   * @param index The tab index.
   * */
  off_regular_save() {
    // If is already off
    if (this.regular_save_interval_id == undefined) {
      return;
    }
    console.info(`[off_regular_save] Turned off regular save of web_state for tab #${this.index}, url=${this.url}`);
    clearInterval(this.regular_save_interval_id);
    this.regular_save_interval_id = undefined;
  }

  /**
   * Checks if this url can be saved to history. meow:// pages are not allowed.
   * @param url The url.
   * @returns True if can.
   * */
  private url_save_history(url: string) {
    if (url.substring(0, 7) == 'meow://') {
      return false;
    }
    return true;
  }
}
