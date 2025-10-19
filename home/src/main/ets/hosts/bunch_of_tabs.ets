import { webview } from '@kit.ArkWeb';
import { match_domain, url_meow_to_resource, viewable_domains } from '../utils/url_tools';
import { url_default_blank } from './bunch_of_defaults';
import { sandbox_save } from '../utils/storage_tools';
import { bunch_of_settings } from './bunch_of_settings';
import { storage_of_id, window_index_of_id } from '../utils/ui_tools';
import { save_history } from '../processes/tabs_actions';
import lazy { createNWeb, TabNodeController } from '../objects/WebNode';

export class bunch_of_tabs {
  // Settings
  static new_tab_url: string = 'meow://home';
  static home_url: string = 'meow://home';
  static start_up: string = 'new tab';
  // Major Data
  Tabs: Array<tab_info_packed> = [];
  Labels: Array<tab_label> = [];
  NodeControllers: Array<TabNodeController> = [];
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
   * */
  update_web_state(index: number) {
    try {
      let web_state = this.Tabs[index].controller.serializeWebState();
      this.Tabs[index].web_state_array = web_state;
    } catch (e) {
      console.error('[update_web_state] Failed: ' + e);
    }
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

  get_new_tab_url() {
    return bunch_of_tabs.new_tab_url;
  }

  get_home_url() {
    return bunch_of_tabs.home_url;
  }

  // General Tab Controls

  /**
   * Switches to another tab.
   * @param target A number, the index of target tab.
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
   * Creates a new tab.
   * @param target_url A string, if link is "", then load the default new_tab_url set in this object.
   * @param recover_on_creation A boolean, if set true, then the tab will restore the serialized web state in
   * @returns A number, the index of the new tab.
   * @description While if new_tab_url is also not set ("" or undefined), then will load the url_default_blank().
   * */
  newTab(context: UIContext, target_url: string, recover_on_creation?: boolean) {
    // console.log('[bunch_of_tabs] newTab: [' + target_url + '].');
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
    let new_TabInfo: tab_info_packed = new tab_info_packed("Meow", target_url, storage_of_id(this.my_id), idx, recover_on_creation);
    let Date_ID = Date.now();

    // TODO: IS THIS EFFICIENT ENOUGH?
    while (this.used_date_ids.includes(Date_ID)) {
      // Date_ID crash prevention
      Date_ID += 1;
    }
    let new_TabLabel: tab_label = new tab_label(Date_ID, idx);

    this.used_date_ids.push(Date_ID);
    this.Tabs.push(new_TabInfo);
    this.Labels.push(new_TabLabel);
    this.NodeControllers.push(new TabNodeController(createNWeb(context, new_TabInfo)));
    this.main_tab_idx = this.Tabs.length - 1;

    return this.main_tab_idx as number;
  }

  /**
   * Closes a tab.
   * @param target A number, the index of the tab requested to close.
   * @param home_url A string, will load this link if closed the last tab and opened a new one right after it.
   * @returns A number, the index of current working main tab which eventually switched to.
   * */
  closeTab(target: number, home_url: string) {
    if (this.Tabs.length == 1) {
      // Reset the only tab
      this.Tabs[0].searching_keyword = '';
      this.Tabs[0].searching_keyword_stats_current = 0;
      this.Tabs[0].searching_keyword_stats_total = 0;
      this.Tabs[0].controller.loadUrl(url_meow_to_resource(home_url));
      this.Tabs[0].controller.clearHistory();
      return 0;
    }
    // Now at least 2 items are in the Tabs list

    let landing_destination = this.main_tab_idx;
    // Decide where to go

    if (this.main_tab_idx == target) {
      // If deleting the tab currently viewing
      if (target == 0) {
        landing_destination = 1;
        // If deleting the top tab
      } else if (target == this.Tabs.length - 1) {
        landing_destination = this.Tabs.length - 2;
        // If deleting the last tab
      } else {
        landing_destination = target - 1;
        // If in the middle
      }
    }

    this.switchToTab(-1)
    // Forces LinysTabs to refresh For Each loop to render
    this.switchToTab(landing_destination)

    this.Tabs.splice(target, 1)
    this.Labels.splice(target, 1)

    this.NodeControllers[target].detachWeb();
    this.NodeControllers[target].dispose();

    this.NodeControllers.splice(target, 1)

    // Refresh index_keys
    for (let i = target; i < this.Labels.length; ++i) {
      this.Labels[i].index_key -= 1;
    }

    if (this.main_tab_idx > target) {
      this.main_tab_idx -= 1;
    }

    console.log('[bunch_of_tabs][closeTab] ' + this.main_tab_idx + '!');
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
      r.push(this.Tabs[index].restore_on_creation);
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
   * Re-save all web states, usually used to ensure the correct order of tab indices.
   * @param start A number, all tabs with index greater or equal to start would re-save their web states to disk.
   * */
  re_save_web_state(start: number) {
    console.log('[Meow][bunch_of_tabs] Re_save_web_state! (' + this.my_id + ') (#' + window_index_of_id(this.my_id) + ') From ' + start + '.');
    for (let index = start; index < this.Tabs.length; index++) {
      let web_state = this.Tabs[index].web_state_array;
      let identifier = "continue/continue_tabs_web_state_array_" + index.toString();
      if (web_state != null) {
        sandbox_save(identifier, web_state.buffer);
      }
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
    try {
      let web_state = this.Tabs[index].web_state_array;

      // Save to sandbox
      if (web_state && !this.Tabs[index].restore_on_creation) {
        let file_name = "continue/continue_tabs_web_state_array_" + index.toString();
        sandbox_save(file_name, web_state.buffer);
      }
    } catch (e) {
      console.error('[bunch_of_tabs][save_web_state] Error: ' + e);
    }
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
  restore_on_creation: boolean = false;
  web_state_array: Uint8Array = new Uint8Array();
  // Update records
  last_saved_url: string = '';
  last_saved_title: string = '';

  /**
   * A class holding a controller and statuses of a tab.
   * @param title A string, the initial title when the tab is created.
   * @param link A string, the initial link when the tab is created.
   * @param restore_on_creation A boolean, optional, will restore web state on creation if the index in valid.
   */
  constructor(title: string, url: string, storage: LocalStorage, index: number, restore_on_creation?: boolean) {
    this.storage = storage;
    this.controller = new webview.WebviewController();
    this.index = index;
    this.title = title;
    this.url = url;
    this.is_loading = true;
    this.loading_progress = 0;

    if (restore_on_creation) {
      this.restore_on_creation = true;
    }
  }

  // Data Sync

  /**
   * Asks the tab to update its title, usually called when the tab loads something new.
   * */
  update_title() {
    try {
      this.title = this.controller.getTitle();
    } catch (e) {
      console.error('[update_title] Failed: ' + e);
    }
    return this.title;
  }

  /**
   * Asks the tab to update its link, usually called when the tab loads something new.
   * */
  update_url() {
    if (!viewable_domains().includes(match_domain(this.controller.getUrl())[0])) {
      return this.url;
    }
    try {
      this.url = this.controller.getUrl();
    } catch (e) {
      console.error('[update_url] Failed: ' + e);
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
   * Tag myself as restore finished after 500 ms.
   * */
  delayed_set_restore_ok(action?: () => void) {
    setTimeout(() => {
      this.restore_on_creation = false;
      if (action) {
        try {
          action();
        } catch (e) {
          console.error('[delayed_set_restore_ok] Action Failed: ' + e);
        }
      }
    }, 500);
  }

  // Actions

  /**
   * Checks and saves history record under certain conditions (if is a new, legal history entry).
   * @param source
   * */
  check_save_history(source: string) {
    let saved = false;
    if (!this.restore_on_creation) {
      let is_new_history = (this.last_saved_url != this.url);
      if (is_new_history) {
        if (!this.url.includes("resource://")) {
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
}
