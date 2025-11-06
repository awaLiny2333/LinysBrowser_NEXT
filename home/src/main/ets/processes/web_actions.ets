import lazy { fileIo } from '@kit.CoreFileKit';
import lazy { meowContext } from '../utils/environment_tools';
import lazy { add_units_to_size, sandbox_read_text_sync, sandbox_save } from '../utils/storage_tools';
import lazy { webview } from '@kit.ArkWeb';
import lazy { bunch_of_tabs, tab_info_packed } from '../hosts/bunch_of_tabs';
import lazy { determine_extra_background, sync_current_tabs_list_info } from './tabs_actions';
import lazy { window_index_of_id } from '../utils/ui_tools';
import lazy { url_resource_to_meow } from '../utils/url_tools';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';

// Ads Blocker

/**
 * Apply all files of EasyList rules in directory of filesDir/easylist.
 */
export function apply_EasyList() {
  let lists = get_EasyLists();
  let overall_rules = '';
  for (let index = 0; index < lists.length; index++) {
    let new_paragraph = sandbox_read_text_sync('easylist/' + lists[index][0]);
    if (new_paragraph != 'undefined') {
      overall_rules += '\n' + new_paragraph;
    }
  }
  sandbox_save('easylist.txt', overall_rules, meowContext().tempDir);
  try {
    webview.AdsBlockManager.setAdsBlockRules(meowContext().tempDir + '/easylist.txt', true);
  } catch (e) {
    console.error('[submit_EasyList] Failed: ' + e);
  }
}

/**
 * Get all file names of EasyList rules in directory of filesDir/easylist.
 */
export function get_EasyLists() {
  let result: string[][] = [];
  try {
    const files = fileIo.listFileSync(meowContext().filesDir + '/easylist', { recursion: false });
    for (let index = 0; index < files.length; index++) {
      const filename = meowContext().filesDir + '/easylist/' + files[index];
      result.push([files[index], add_units_to_size(fileIo.statSync(filename).size)]);
    }
  } catch (e) {
    console.error('[refresh_easy_list] Failed: ' + e);
  }
  return result;
}

// Web General

/**
 * Initialization of a window's web environment.
 * */
export function init_web(storage: LocalStorage) {
  // Init download delegate
  (AppStorage.get('bunch_of_downloads') as bunch_of_downloads).init_delegate(storage);
  // Enable third party cookies
  webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(AppStorage.get('enable_third_party_cookies') as boolean);
  webview.WebviewController.enablePrivateNetworkAccess(false);
}

// Web UI Events

/**
 * Should be called when a tab receives its title.
 * @param pk The tab_info_packed.
 * */
export function on_title_receive(pk: tab_info_packed) {
  // Ask tab to update its info
  let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;

  try {
    let title = pk.update_title();
    let url = pk.update_url();
    tabs.update_backward_forward_access();
    // sync lists
    // sync_tabs_list_info(tab.storage);
    (pk.storage.get('tab_titles') as string[])[pk.index] = title;
    (pk.storage.get('tab_urls') as string[])[pk.index] = url;

    // tabs.sync_web_settings(tab.index);

    if (pk.index == tabs.main_tab_idx) {
      sync_current_tabs_list_info(pk.storage);
    }
  } catch (e) {
    console.error('[meowWebView][onProgressChange] Update bunch_of_tabs error: ' + e);
  }

  // Save history if title is really updated
  let tab_titles = (pk.storage.get('tab_titles') as string[]);
  if (pk.last_saved_title != tab_titles[pk.index]) {
    console.log('[Tabs][onTitleReceive] New title: ' + tab_titles[pk.index]);
    if (!pk.is_loading) {
      pk.check_save_history('[onTitleReceive]');
    }
  }
}

/**
 * Should be called when a tab begins loading.
 * @param pk The tab_info_packed.
 * */
export function on_page_begin(pk: tab_info_packed) {
  console.log("[ArkWeb] on page begin!");
  let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;

  if (pk.index >= tabs.get_tabs_count()) {
    // If not synced, idk why but o(=•ェ•=)m
    return;
  }

  // Ask tab to update its info
  try {
    let url = pk.update_url();
    let is_loading = false;
    if (url.substring(0, 7) == 'meow://') {
      // Don't show progress bar for meow:// pages
      is_loading = pk.update_is_loading(false);
    } else {
      is_loading = pk.update_is_loading(true);
    }
    let progress = pk.update_loading_progress(0);

    (pk.storage.get('tab_urls') as string[])[pk.index] = url;
    (pk.storage.get('tab_is_loading') as boolean[])[pk.index] = is_loading;
    (pk.storage.get('tab_loading_progresses') as number[])[pk.index] = progress;

    // Get synced lists
    if (pk.index == tabs.main_tab_idx) {
      sync_current_tabs_list_info(pk.storage);
    }

  } catch (e) {
    console.error('[meowWebView][onPageBegin] Update bunch_of_tabs error: ' + e);
  }

  // Update Input Search Box
  // this.update_search_box_text(tab.url);
  if (!(pk.storage.get('is_search_input_typing') as boolean) && pk.index == tabs.main_tab_idx) {
    pk.storage.set('search_input', url_resource_to_meow(pk.url));
    // Update Input Search Box
  }
}

/**
 * Should be called when a tab comes to the end of loading.
 * @param pk The tab_info_packed.
 * */
export function on_page_end(pk: tab_info_packed) {
  console.log(`[Meow][ArkWeb][${pk.index}] tab on page end! `);
  let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;

  // Ask tab to update its info
  try {
    let title = pk.update_title();
    let url = pk.update_url();
    let is_loading = pk.update_is_loading(false);
    tabs.update_backward_forward_access();

    (pk.storage.get('tab_titles') as string[])[pk.index] = title;
    (pk.storage.get('tab_urls') as string[])[pk.index] = url;
    (pk.storage.get('tab_is_loading') as boolean[])[pk.index] = is_loading;

    // Get synced lists
    if (pk.index == tabs.main_tab_idx) {
      sync_current_tabs_list_info(pk.storage);
    }
  } catch (e) {
    console.error('[meowWebView][onPageEnd] Update bunch_of_tabs error: ' + e);
  }

  // Get and save web_state
  tabs.update_web_state(pk.index);
  if (window_index_of_id(tabs.my_id) == 0 && !pk.pre_restoration_stage) {
    tabs.save_web_state_to_sandbox(pk.index);
  }

  // Save history
  if (pk.title != '') {
    pk.check_save_history('[onPageEnd]');
  }

  // Mark End Recovery
  if (pk.pre_restoration_stage) {
    pk.delayed_set_restore_ok(() => {
      console.log('[Tabs] Restore OK for #' + pk.index + ' !');
      (pk.storage.get('tab_restore_on_creations') as boolean[])[pk.index] = false;
    });
  }

  determine_extra_background(pk.storage);
}

/**
 * Should be called when a tab has a change on its progress.
 * @param pk The tab_info_packed.
 * */
export function on_progress_change(pk: tab_info_packed, event: OnProgressChangeEvent) {
  if (!event) {
    return;
  }
  let progress: number = event.newProgress;
  if (progress == 0) {
    return;
  }

  let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;

  if (pk.index >= tabs.get_tabs_count()) {
    // If not synced, idk why but o(=•ェ•=)m
    return;
  }

  // Ask tab to update its info
  try {
    let title = pk.update_title();
    let url = pk.update_url();
    pk.update_loading_progress(progress);
    tabs.update_backward_forward_access();

    (pk.storage.get('tab_titles') as string[])[pk.index] = title;
    (pk.storage.get('tab_urls') as string[])[pk.index] = url;
    (pk.storage.get('tab_loading_progresses') as number[])[pk.index] = progress;

    // Get synced lists
    if (pk.index == tabs.main_tab_idx) {
      sync_current_tabs_list_info(pk.storage);
    }
  } catch (e) {
    console.error('[meowWebView][onProgressChange] Update bunch_of_tabs error: ' + e);
  }

  // Update Input Search Box
  // this.update_search_box_text(tab.url);
  if (!(pk.storage.get('is_search_input_typing') as boolean) && pk.index == tabs.main_tab_idx) {
    pk.storage.set('search_input', url_resource_to_meow(pk.url));
    // Update Input Search Box
  }

  // Get and save web_state
  if (!pk.pre_restoration_stage) {
    tabs.update_web_state(pk.index);
    if (window_index_of_id(tabs.my_id) == 0) {
      // TODO: Reduce save web_state to sandbox frequency.
      tabs.save_web_state_to_sandbox(pk.index);
    }
  }

  determine_extra_background(pk.storage);
}

/**
 * Should be called when a tab gets its controller attached.
 * @param pk The tab_info_packed.
 * */
export function on_controller_attached(pk: tab_info_packed) {
  // bind download delegate
  try {
    pk.controller.setDownloadDelegate(pk.storage.get('dl_delegate') as webview.WebDownloadDelegate);
  } catch (e) {
    console.error('[meowWebView] onControllerAttached setDownloadDelegate error: ' + e);
  }

  // Set Default error page
  try {
    pk.controller.setErrorPageEnabled(true);
  } catch (e) {
    console.error(`[Web][setErrorPageEnabled] Failed: ${e}`)
  }

  // Set UA
  let now_global_custom_UA = AppStorage.get('universal_global_custom_ua_gateway') as string;
  if (now_global_custom_UA != "") {
    try {
      pk.controller.setCustomUserAgent(now_global_custom_UA);
    } catch (e) {
      console.error('[meowWebView] onControllerAttached setCustomUserAgent error: ' + e);
    }
  }

  // Set Ads Blocker
  let use_adblock = AppStorage.get('use_adblock') as boolean;
  console.log('[meowWebView] enableAdsBlock: ' + (use_adblock ? 'true' : 'false'));
  try {
    pk.controller.enableAdsBlock(use_adblock);
    console.info('[meowWebView] onControllerAttached enableAdsBlock! [' + pk.url + ']');
  } catch (e) {
    console.error('[meowWebView] onControllerAttached enableAdsBlock error: ' + e);
  }

  // Set Ads Blocker exception list
  try {
    let adblock_exceptions = AppStorage.get('adblock_exceptions') as string[];
    console.log('[init][meowWebView] Trying to add ads blocker exceptions: [' + adblock_exceptions + '] Operated by meowWebView ~');
    // webview.AdsBlockManager.addAdsBlockDisallowedList(adblock_exceptions);
    webview.AdsBlockManager.addAdsBlockDisallowedList(Array.from(adblock_exceptions)); // wtf??? why???
  } catch (e) {
    console.error('[ERROR][Meow][meowWebView] add Ads Blocker Exceptions error: ' + e);
  }
  // TODO: Find out why this doesn't work sometimes for a recovered webpage :O getting crazy

  // Set intelligent tracking prevention
  try {
    let intelligent_tracking_prevention = AppStorage.get('intelligent_tracking_prevention') as boolean;
    pk.controller.enableIntelligentTrackingPrevention(intelligent_tracking_prevention);
    console.log('[meowWebView] ArkWeb Intelligent Tracking Prevention ' + intelligent_tracking_prevention.toString() + '!');
  } catch (e) {
    console.error('[meowWebView] onControllerAttached enableIntelligentTrackingPrevention error: ' + e);
  }

  let tabs = pk.storage.get('bunch_of_tabs') as bunch_of_tabs;

  // Restore Web State
  if (pk.index == tabs.main_tab_idx || pk.index == tabs.sub_tab_idx) {
    pk.restore();
  }
}
