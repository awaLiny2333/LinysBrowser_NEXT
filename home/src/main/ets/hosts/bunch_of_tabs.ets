import { webview } from '@kit.ArkWeb';
import { match_domain, url_meow_to_resource, viewable_domains } from '../utils/url_tools';
import { url_default_blank } from './bunch_of_defaults';
import { fileIo as fs } from '@kit.CoreFileKit';
import { sandbox_save } from '../utils/storage_tools';
import { common } from '@kit.AbilityKit';

let context = AppStorage.get("context") as common.UIAbilityContext;

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
  controller: WebviewController;
  title: string;
  url: string;
  is_loading: boolean;
  loading_progress: number;
  // Keyword of in-page search
  searching_keyword: string = '';
  // Index of current viewing result during in-page search
  searching_keyword_stats_current: number = 0;
  // Total number of results of in-page search
  searching_keyword_stats_total: number = 0;
  restore_on_creation: boolean = false;
  web_state_array: Uint8Array = new Uint8Array();

  /**
   * A class holding a controller and statuses of a tab.
   * @param title A string, the initial title when the tab is created.
   * @param url A string, the initial url when the tab is created.
   * @param restore_on_creation A boolean, optional, will restore web state on creation if the index in valid.
   */
  constructor(title: string, url: string, restore_on_creation?: boolean) {
    this.controller = new webview.WebviewController();
    this.title = title;
    this.url = url;
    this.is_loading = true;
    this.loading_progress = 0;

    if (restore_on_creation) {
      this.restore_on_creation = true;
    }
  }

  /**
   * Asks the tab to update its title, usually called when the tab loads something new.
   * */
  update_title() {
    this.title = this.controller.getTitle();
  }

  /**
   * Asks the tab to update its url, usually called when the tab loads something new.
   * */
  update_url() {
    if (!viewable_domains().includes(match_domain(this.controller.getUrl())[0])) {
      return;
    }
    this.url = this.controller.getUrl();
  }

  /**
   * Asks the tab to update its loading state, usually called when the tab starts loading or finishes loading.
   * */
  update_is_loading(is_loading: boolean) {
    this.is_loading = is_loading;
  }

  /**
   * Asks the tab to update its loading progress, usually called in the tab's loading progress.
   * */
  update_loading_progress(progress: number) {
    this.loading_progress = progress;
  }
}

export class bunch_of_tabs {
  Tabs: Array<tab_info_packed> = [];
  Labels: Array<tab_label> = [];
  current_working_tab_index: number = 0;
  current_color_mode: number = AppStorage.get('currentColorMode') as number;
  global_custom_UA: string = "";
  new_tab_url: string | undefined = undefined;
  home_url: string | undefined = undefined;
  start_up: string | undefined = undefined;
  private used_date_ids: number[] = [];

  /**
   * A class holding tabs in a list.
   * Provides methods to operate tabs.
   * @param no_init Will not check for continue folder nor do anything else.
   * Usually set true if this object is only created to sit the place of StorageLink initialization.
   */
  constructor(no_init?: boolean) {
    if (no_init == true) {
      return;
    }

    let filesDir = context.filesDir;
    try {
      fs.mkdirSync(filesDir + '/continue');
    } catch (e) {
      // console.log('[Meow][bunch_of_tabs] constructor: E: /continue folder already exists.')
    }

    // console.log('[Meow][bunch_of_tabs] Init success!')
  }

  // Operations and Actions

  /**
   * Loads a url on the current main tab.
   * @description Will load url_default_blank() if the home_url of this bunch_of_tabs is not set.
   * */
  loadUrl_onWorkingTab(url: string) {
    url = url_meow_to_resource(url);
    this.Tabs[this.current_working_tab_index].controller.loadUrl(url);
  }

  /**
   * Loads home url on the current main tab.
   * @description Will load url_default_blank() if the home_url of this bunch_of_tabs is not set.
   * */
  go_home_onWorkingTab() {
    let going_home_url = "";
    if (this.home_url == undefined || this.home_url == "") {
      going_home_url = url_default_blank();
    } else {
      going_home_url = this.home_url;
    }
    this.loadUrl_onWorkingTab(going_home_url);
  }

  /**
   * Refreshes current main tab.
   * */
  refresh_onWorkingTab() {
    this.Tabs[this.current_working_tab_index].controller.refresh();
  }

  /**
   * Stops the load on current main tab.
   * */
  stop_onWorkingTab() {
    this.Tabs[this.current_working_tab_index].controller.stop();
  }

  /**
   * Try to go forward on current main tab.
   * @returns true if success.
   * @returns false if failed, perhaps there is no way forward.
   * */
  goForward_onWorkingTab() {
    if (this.Tabs[this.current_working_tab_index].controller.accessForward()) {
      this.Tabs[this.current_working_tab_index].controller.forward();
    }
  }

  /**
   * Try to go backward on current main tab.
   * @returns true if success.
   * @returns false if failed, perhaps there is no way backward.
   * */
  goBackward_onWorkingTab() {
    if (this.Tabs[this.current_working_tab_index].controller.accessBackward()) {
      this.Tabs[this.current_working_tab_index].controller.backward();
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
    this.global_custom_UA = ua;

    if (this.global_custom_UA == "") {
      this.reset_global_custom_UA();
      console.log("[bunch_of_tabs][UA] Reset global_custom_UA to ArkWeb default! ua: " + this.get_global_default_UA())
      return;
      // Reset default if no input
    }

    for (let index = 0; index < this.Tabs.length; index++) {
      this.Tabs[index].controller.setCustomUserAgent(this.global_custom_UA)
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
    this.current_working_tab_index = -1; // Weird way to refresh
    this.current_working_tab_index = target;
    return target;
  }

  /**
   * Creates a new tab.
   * @param target_url A string, if url is "", then load the default new_tab_url set in this object.
   * @param recover_on_creation A boolean, if set true, then the tab will restore the serialized web state in
   * @returns A number, the index of the new tab.
   * @description While if new_tab_url is also not set ("" or undefined), then will load the url_default_blank().
   * */
  newTab(target_url: string, recover_on_creation?: boolean) {
    if (target_url == "") {
      // If newing an empty tab
      if (this.new_tab_url == "" || this.new_tab_url == undefined) {
        // If new tab not specified
        target_url = url_default_blank();
      } else {
        // If new tab is specified
        target_url = this.new_tab_url;
      }
    }

    let new_TabInfo: tab_info_packed = new tab_info_packed("Meow", target_url, recover_on_creation);
    let Date_ID = Date.now();
    while (this.used_date_ids.includes(Date_ID)) {
      // Date_ID crash prevention
      Date_ID += 1;
    }
    let new_TabLabel: tab_label = new tab_label(Date_ID, this.Tabs.length);

    this.used_date_ids.push(Date_ID);
    this.Tabs.push(new_TabInfo);
    this.Labels.push(new_TabLabel);
    this.current_working_tab_index = this.Tabs.length - 1;

    return this.current_working_tab_index as number;
  }

  /**
   * Closes a tab.
   * @param target A number, the index of the tab requested to close.
   * @param home_url A string, will load this url if closed the last tab and opened a new one right after it.
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

    let landing_destination = this.current_working_tab_index;
    // Decide where to go

    if (this.current_working_tab_index == target) {
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

    // Refresh index_keys
    for (let i = target; i < this.Labels.length; ++i) {
      this.Labels[i].index_key -= 1;
    }

    if (this.current_working_tab_index > target) {
      this.current_working_tab_index -= 1;
    }

    return this.current_working_tab_index;
  }

  /**
   * Gets the current main tab.
   * @returns A tab_info_packed object, of the current main tab.
   * */
  workingMainTab() {
    return this.Tabs[this.current_working_tab_index];
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

  // Web states

  /**
   * Asks a tab to restore web state.
   * @param web_state A Uint8Array, the serialized web state to be recovered of the tab.
   * @param index_key A number, the index of the tab which is asked to do a recovery.
   * */
  restore_web_state(web_state: Uint8Array, index_key: number) {
    if (web_state !== undefined) {
      console.log("[Meow][meowWebView] Restore web " + index_key.toString() +
        ", state Length: " + web_state.length.toString())
      this.Tabs[index_key].controller.clearHistory();
      this.Tabs[index_key].controller.restoreWebState(web_state);
    } else {
      console.error("[ERROR][Meow][meowWebView] Restore web state failed for an undefined web_state!")
    }
  }

  /**
   * Re-save all web states, usually used to ensure the correct order of tab indices.
   * @param start A number, all tabs with index greater or equal to start would re-save their web states to disk.
   * */
  re_save_web_state(start: number) {
    for (let index = start; index < this.Tabs.length; index++) {
      let web_state = this.Tabs[index].web_state_array;
      let identifier = "continue/continue_tabs_web_state_array_" + index.toString();
      if (web_state != null) {
        sandbox_save(identifier, web_state.buffer);
      }
    }
  }
}
