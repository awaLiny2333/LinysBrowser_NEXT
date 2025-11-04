import { bunch_of_history, history_record } from '../hosts/bunch_of_history';
import { bunch_of_tabs, tab_info_packed } from '../hosts/bunch_of_tabs';
import { url_resource_to_meow } from '../utils/url_tools';
import { unifiedDataChannel } from '@kit.ArkData';
import { window_index_of_id } from '../utils/ui_tools';

// Data and Statuses

/**
 * Syncs ALL tabs data into AppStorage.
 * @param storage The LocalStorage of this window.
 * */
export function sync_all_tabs_list_info(storage: LocalStorage) {
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

  console.log('[Meow][tab_match_domains]: ' + tab_match_domains);
  console.log('[Meow][tab_is_loading]: ' + tab_is_loading);
  console.log('[Meow][tab_loading_progresses]: ' + tab_loading_progresses);

  sync_current_tabs_list_info(storage);

  // Timer
  // t = Date.now() - t0;
  // console.log('[sync_tabs_list_info] Called! (' + t + ' ms)');
}

/**
 * Updates only current tabs status into LocalStorage.
 *
 * Usually used after actions that doesn't modify the data but only changed current index.
 *
 * For example, switching tabs.
 * @param storage The LocalStorage.
 * */
export function sync_current_tabs_list_info(storage: LocalStorage) {
  let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;
  let tab_titles = storage.get('tab_titles') as string[];
  let tab_urls = storage.get('tab_urls') as string[];
  let tab_is_loading = storage.get('tab_is_loading') as boolean[];
  let tab_loading_progresses = storage.get('tab_loading_progresses') as number[];
  let tab_match_domains = storage.get('tab_match_domains') as string[][];

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

// Web and Tabs

/**
 * Returns true if the current tab is doing in-page searching.
 * @param storage The LocalStorage.
 * @returns True if is searching, false otherwise.
 * */
export function is_current_in_page_searching(storage: LocalStorage) {
  return storage.get('current_in_page_searching_stats_total') as number > 0;
}

/**
 * Cancel in-page search for current tab.
 * @param storage The LocalStorage.
 * */
export function cancel_in_page_search(storage: LocalStorage) {
  let tabs = storage.get('bunch_of_tabs') as bunch_of_tabs;
  storage.set('current_in_page_searching_keyword', '');
  storage.set('current_in_page_searching_stats_current', 0);
  storage.set('current_in_page_searching_stats_total', 0);
  tabs.workingMainTab().searching_keyword_stats_current = 0;
  tabs.workingMainTab().searching_keyword_stats_total = 0;
  tabs.workingMainTab().searching_keyword = '';
  try {
    tabs.workingMainTab().controller.clearMatches();
  } catch (e) {
    console.error('[cancel_in_page_search] Failed: ' + e);
  }
}

// Drag

/**
 * Generates the unifiedData object for a drag from a specific tab.
 * @param window_id The id of the source of the tab.
 * @param tab_index The index of that tab.
 * @returns The unifiedData of 'ApplicationDefinedTabDrag' type.
 * */
export function unifiedData_drag_tab_from(window_id: string, tab_index: number) {
  let window_index = window_index_of_id(window_id);
  let record = new unifiedDataChannel.ApplicationDefinedRecord();
  let u8Array = new Uint8Array([window_index, tab_index]);
  record.applicationDefinedType = 'ApplicationDefinedTabDrag';
  record.rawData = u8Array;
  let unifiedData = new unifiedDataChannel.UnifiedData(record);
  return unifiedData;
}
