import { webview } from '@kit.ArkWeb';
import { url_meow_to_resource } from '../utils/url_tools';
import { home_url } from './bunch_of_settings';

@Observed
export class tab_label {
  timestamp: number;
  index_key: number;

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

  constructor(title: string, url: string) {
    this.controller = new webview.WebviewController();
    this.title = title;
    this.url = url;
    this.is_loading = true;
    this.loading_progress = 0;
  }

  update_title() {
    this.title = this.controller.getTitle();
  }

  update_url() {
    this.url = this.controller.getUrl();
  }

  update_is_loading(is_loading: boolean) {
    this.is_loading = is_loading;
  }

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

  // Operations and Actions

  loadUrl_onWorkingTab(url: string) {
    url = url_meow_to_resource(url);
    this.Tabs[this.current_working_tab_index].controller.loadUrl(url);
  }

  refresh_onWorkingTab() {
    this.Tabs[this.current_working_tab_index].controller.refresh();
  }

  stop_onWorkingTab() {
    this.Tabs[this.current_working_tab_index].controller.stop();
  }

  goForward_onWorkingTab() {
    if (this.Tabs[this.current_working_tab_index].controller.accessForward()) {
      this.Tabs[this.current_working_tab_index].controller.forward();
    }
  }

  goBackward_onWorkingTab() {
    if (this.Tabs[this.current_working_tab_index].controller.accessBackward()) {
      this.Tabs[this.current_working_tab_index].controller.backward();
    }
  }

  // UA Stuff

  set_global_custom_UA(ua: string) {
    console.log("[bunch_of_tabs][UA] Set global_custom_UA! ua: " + ua)
    this.global_custom_UA = ua;

    if (this.global_custom_UA == "") {
      this.reset_global_custom_UA();
      return;
      // Reset default if no input
    }

    for (let index = 0; index < this.Tabs.length; index++) {
      this.Tabs[index].controller.setCustomUserAgent(this.global_custom_UA)
    }

  }

  reset_global_custom_UA() {
    console.log("[bunch_of_tabs][UA] Reset global_custom_UA!")
    let default_ua = this.get_global_default_UA();

    for (let index = 0; index < this.Tabs.length; index++) {
      this.Tabs[index].controller.setCustomUserAgent(default_ua)
    }
  }

  get_global_custom_UA() {
    return this.Tabs[0].controller.getCustomUserAgent();
  }

  get_global_default_UA() {
    return this.Tabs[0].controller.getUserAgent();
  }

  // General Tab Controls

  switchToTab(target: number) {
    this.current_working_tab_index = target;
    return target;
  }

  /** @param target_url If url is "", then load the default new_tab_url set in this object.
   * @abstract  While if new_tab_url is also not set ("" or undefined), then load default home_url().
   * */
  newTab(target_url: string) {
    if (target_url == "") {
      // If newing an empty tab
      if (this.new_tab_url == "" || this.new_tab_url == undefined) {
        target_url = home_url();
        // If new tab not specified
      } else {
        target_url = this.new_tab_url;
        // If new tab is specified
      }
    }

    let new_TabInfo: tab_info_packed = new tab_info_packed("Meow", target_url);
    let new_TabLabel: tab_label = new tab_label(Date.now(), this.Tabs.length);
    this.Tabs.push(new_TabInfo);
    this.Labels.push(new_TabLabel);
    this.current_working_tab_index = this.Tabs.length - 1;
    return this.current_working_tab_index as number;
  }

  closeTab(target: number, home_url: string) {
    home_url = url_meow_to_resource(home_url);
    if (this.Tabs.length == 1) {
      // Reset the only tab
      this.Tabs[0].controller.loadUrl(home_url);
      this.Tabs[0].controller.clearHistory();
      return 0;
    }
    // Now at least 2 items are in the Tabs list

    let landing_destination = this.current_working_tab_index
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
    } else {

    }

    this.switchToTab(0)
    // Forces LinysTabs to refresh For Each loop to render
    this.switchToTab(landing_destination)

    this.Tabs.splice(target, 1)
    this.Labels.splice(target, 1)

    for (let i = target; i < this.Labels.length; ++i) {
      this.Labels[i].index_key -= 1
    }

    if (this.current_working_tab_index > target) {
      this.current_working_tab_index -= 1;
    }

    return this.current_working_tab_index
  }

  workingTab() {
    return this.Tabs[this.current_working_tab_index];
  }

  // Data Syncing

  get_all_titles() {
    let titles: string[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      titles.push(this.Tabs[index].title);
    }
    return titles;
  }

  get_all_urls() {
    let urls: string[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      urls.push(this.Tabs[index].url);
    }
    return urls;
  }

  get_all_is_loading() {
    let is_loading: boolean[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      is_loading.push(this.Tabs[index].is_loading);
    }
    return is_loading;
  }

  get_all_loading_progress() {
    let progress: number[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      progress.push(this.Tabs[index].loading_progress);
    }
    return progress;
  }

  get_all_time_stamps() {
    let stamps: number[] = [];

    for (let index = 0; index < this.Tabs.length; index++) {
      stamps.push(this.Labels[index].timestamp);
    }
    return stamps;
  }
}