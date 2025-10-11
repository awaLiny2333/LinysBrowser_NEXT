import { bunch_of_history, history_record } from '../hosts/bunch_of_history';
import { bunch_of_tabs, tab_info_packed } from '../hosts/bunch_of_tabs';
import { url_resource_to_meow } from '../utils/url_tools';

// Data and Statuses

/**
 * Syncs all tabs data into AppStorage.
 * */
export function sync_tabs_list_info(storage: LocalStorage) {
  // let t0 = Date.now();
  // let t = 0;

  // TODO: Efficiency can be further improved. e.g. update only one tab information instead of re-fetching the entire list.
  // This should work
  let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;
  let tab_titles = tabs.get_all_titles();
  let tab_urls = tabs.get_all_urls();
  let tab_is_loading = tabs.get_all_is_loading();
  let tab_loading_progresses = tabs.get_all_loading_progress();
  let tab_match_domains = tabs.get_all_match_domains();
  let tab_restore_on_creations = tabs.get_all_restore_on_creations();
  storage.set('tab_titles', tab_titles);
  storage.set('tab_urls', tab_urls);
  storage.set('tab_is_loading', tab_is_loading);
  storage.set('tab_loading_progresses', tab_loading_progresses);
  storage.set('tab_match_domains', tab_match_domains);
  storage.set('tab_restore_on_creations', tab_restore_on_creations);

  // Web Settings
  let tab_disable_js = tabs.get_all_disable_js();
  let tab_disable_image = tabs.get_all_disable_image();
  let tab_force_dark = tabs.get_all_force_dark();
  storage.set('tab_disable_js', tab_disable_js);
  storage.set('tab_disable_image', tab_disable_image);
  storage.set('tab_force_dark', tab_force_dark);

  // Current
  let current_index = tabs.main_tab_idx;
  storage.set('current_title', tab_titles[current_index]);
  storage.set('current_url', url_resource_to_meow(tab_urls[current_index]));
  storage.set('current_loading_progress', tab_loading_progresses[current_index]);
  storage.set('current_is_loading', tab_is_loading[current_index]);
  storage.set('current_match_domain', tab_match_domains[current_index]);
  // Set loading progress
  storage.set('current_in_page_searching_keyword', tabs.workingMainTab().searching_keyword);
  storage.set('current_in_page_searching_stats_current', tabs.workingMainTab().searching_keyword_stats_current);
  storage.set('current_in_page_searching_stats_total', tabs.workingMainTab().searching_keyword_stats_total);
  // Web Settings
  storage.set('current_disable_js', tab_disable_js[current_index]);
  storage.set('current_disable_image', tab_disable_image[current_index]);
  storage.set('current_force_dark', tab_force_dark[current_index]);

  // Timer
  // t = Date.now() - t0;
  // console.log('[sync_tabs_list_info] Called! (' + t + ' ms)');
}

/**
 * Saves the history.
 * @param tab_info The tab_info_packed item of that tab.
 * */
export function save_history(tab_info: tab_info_packed) {
  let new_record = new history_record(tab_info.title, tab_info.url);

  let history = AppStorage.get('bunch_of_history') as bunch_of_history;
  history.add_history(new_record, true, true);
}

// UI

/**
 * Sets the key 'search_input' in AppStorage with text if is not typing in search box.
 * @param text The new content.
 * */
export function set_search_box_text(text: string, storage: LocalStorage) {
  let is_search_input_typing = storage.get('is_search_input_typing') as boolean;
  if (!is_search_input_typing && text) {
    storage.set('search_input', url_resource_to_meow(text))
    // Update Input Search Box
  }
}

/**
 * Determines if extra background is needed, and saves this to key 'extra_background' in AppStorage.
 *
 * An extra background is for those websites who do not have background colors, so that they would be more readable.
 * */
export function determine_extra_background(storage: LocalStorage) {
  let need_extra_background = true;
  // Determine background
  if (!storage.get('meowWebView_init_OK') as boolean) {
    need_extra_background = false;
  }

  let tab_urls = storage.get('tab_urls') as string[];
  let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;

  let main_tab_url = tab_urls[tabs.main_tab_idx];
  main_tab_url = url_resource_to_meow(main_tab_url);
  let sub_tab_url = tab_urls[tabs.sub_tab_idx];
  sub_tab_url = url_resource_to_meow(sub_tab_url);

  if (tabs.sub_tab_idx > -1) {
    // Paralleowing
    if (main_tab_url == 'meow://home' && sub_tab_url == 'meow://home') {
      console.log('[Meow] Extra background false due to paralleow home!')
      need_extra_background = false;
    }
  } else {
    // Not Paralleowing
    if (main_tab_url == 'meow://home') {
      need_extra_background = false;
    }
  }
  storage.set('extra_background', need_extra_background);
}

