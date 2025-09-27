import lazy { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { url_resource_to_meow } from './url_tools';

/**
 * Constructs a boolean array of a specific length that contains only false values.
 * @param length The length of the array.
 * @returns The boolean array.
 * */
export function all_false(length: number) {
  let result: boolean[] = [];
  for (let index = 0; index < length; index++) {
    result.push(false);
  }
  return result;
}

/**
 * Syncs all tabs data into AppStorage.
 * */
export function sync_tabs_list_info() {
  // This should work
  let tabs = AppStorage.get('bunch_of_tabs') as bunch_of_tabs;
  let tab_titles = tabs.get_all_titles();
  let tab_urls = tabs.get_all_urls();
  let tab_is_loading = tabs.get_all_is_loading();
  let tab_loading_progresses = tabs.get_all_loading_progress();
  let tab_match_domains = tabs.get_all_match_domains();
  AppStorage.set('tab_titles', tab_titles);
  AppStorage.set('tab_urls', tab_urls);
  AppStorage.set('tab_is_loading', tab_is_loading);
  AppStorage.set('tab_loading_progresses', tab_loading_progresses);
  AppStorage.set('tab_match_domains', tab_match_domains);

  // Current
  let current_index = AppStorage.get('current_main_tab_index') as number;
  AppStorage.set('current_title', tab_titles[current_index]);
  AppStorage.set('current_url', url_resource_to_meow(tab_urls[current_index]));
  AppStorage.set('current_loading_progress', tab_loading_progresses[current_index]);
  AppStorage.set('current_is_loading', tab_is_loading[current_index]);
  AppStorage.set('current_match_domain', tab_match_domains[current_index]);
  // Set loading progress
  AppStorage.set('current_in_page_searching_keyword', tabs.workingMainTab().searching_keyword);
  AppStorage.set('current_in_page_searching_stats_current', tabs.workingMainTab().searching_keyword_stats_current);
  AppStorage.set('current_in_page_searching_stats_total', tabs.workingMainTab().searching_keyword_stats_total);
}