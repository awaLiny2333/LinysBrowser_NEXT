// The initialization of the entire app
import { bundleManager, common } from '@kit.AbilityKit';
import { sandbox_read_text_sync, sandbox_save, sandbox_unlink } from '../utils/storage_tools';
import { fileIo } from '@kit.CoreFileKit';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { bunch_of_history } from '../hosts/bunch_of_history';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';
import { bunch_of_key_shortcuts } from '../hosts/bunch_of_key_shortcuts';
import { kv_store_get, kv_store_put } from '../utils/kv_store_tools';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import { bunch_of_search_engines } from '../hosts/bunch_of_search_engines';

/**
 * Executed in async aboutToAppear(): Promise<void> in Index.ets
 */
export async function meow_init(context: common.UIAbilityContext) {
  let t0 = Date.now();
  let t = 0;

  // Get and set app version info
  bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
    console.log('[Meow][history] Saving app version: ' + bundleInfo.versionName + "(" + bundleInfo.versionCode.toString() + ")");
    sandbox_save("last_app_versionCode.txt", bundleInfo.versionCode.toString());
    sandbox_save("last_app_versionName.txt", bundleInfo.versionName);
  })

  await settings_tabs();
  t = Date.now() - t0;
  console.log('[init] Settings OK. (' + t + ' ms)');

  await bookmarks();
  t = Date.now() - t0;
  console.log('[init] Bookmarks OK. (' + t + ' ms)');

  await restore();
  t = Date.now() - t0;
  console.log('[init] Restore OK. (' + t + ' ms)');

  history();
  t = Date.now() - t0;
  console.log('[init] History OK. (' + t + ' ms)');

  AppStorage.setOrCreate('bunch_of_downloads', new bunch_of_downloads());
  AppStorage.setOrCreate('bunch_of_user_agents', new bunch_of_user_agents());
  AppStorage.setOrCreate('bunch_of_search_engines', new bunch_of_search_engines());
  AppStorage.setOrCreate('bunch_of_key_shortcuts', new bunch_of_key_shortcuts());
  t = Date.now() - t0;
  console.log('[init] bunch_of_init! (' + t + ' ms)')

  // File management
  clear_web_drag_image_cache(context);
  clear_profile(context);

  t = Date.now() - t0;
  console.log('[Meow][init] OK. (' + t + ' ms)');
}

// Files

/**
 * Set cache dir of web-dragged image into Scratching Board
 * */
function clear_web_drag_image_cache(context: common.UIAbilityContext) {
  try {
    fileIo.rmdirSync(context.filesDir + '/web-drag-image-cache');
  } catch (e) {
    console.error('[Index] rmdirSync /web-drag-image-cache failed! ' + e);
  }
  try {
    fileIo.mkdirSync(context.filesDir + '/web-drag-image-cache');
  } catch (e) {
    console.error('[Index] mkdirSync /web-drag-image-cache failed! ' + e);
  }
}

/**
 * Delete Profile package
 * */
function clear_profile(context: common.UIAbilityContext) {
  try {
    sandbox_unlink('profile.zip', context.filesDir);
  } catch (e) {
    console.error('[Index] unlink profile.zip! ' + e);
  }
}

// Hosts

/**
 * Inits both settings and tabs
 * */
async function settings_tabs() {
  let settings = new bunch_of_settings();
  AppStorage.setOrCreate('bunch_of_settings', settings);
  let tabs = new bunch_of_tabs();
  AppStorage.setOrCreate('bunch_of_tabs', tabs);

  // DEV_MODE
  AppStorage.setOrCreate('DEV_MODE', await settings.get('DEV_MODE') as boolean);

  // UI Status
  AppStorage.setOrCreate('title_bar_position', await settings.get('title_bar_position') as string);
  AppStorage.setOrCreate('tabs_style', await settings.get('tabs_style') as string);
  AppStorage.setOrCreate('tabs_style_non_tablet_mode', await settings.get('tabs_style_non_tablet_mode') as string);
  AppStorage.setOrCreate('showing_tabs', await settings.get('status_tabs_open') as boolean);
  
  // Experience - Suggestions
  AppStorage.setOrCreate('max_bookmark_advice', await settings.get('max_bookmark_suggest') as number);
  AppStorage.setOrCreate('max_history_advice', await settings.get('max_history_suggest') as number);

  // History
  AppStorage.setOrCreate('collect_new_history', await settings.get('collect_new_history') as boolean);

  // Accessibility
  AppStorage.setOrCreate('sys_back_to_access_backward', await settings.get('sys_back_access_backward') as boolean);
  AppStorage.setOrCreate('preferred_hand_left_or_right', await settings.get('preferred_hand_left_or_right') as string);
  AppStorage.setOrCreate('preferred_hand_reverse_tabs_panel', await settings.get('preferred_hand_reverse_tabs_panel') as boolean);
  AppStorage.setOrCreate('preferred_hand_reverse_settings_menu', await settings.get('preferred_hand_reverse_settings_menu') as boolean);
  AppStorage.setOrCreate('preferred_hand_reverse_homepage_shortcuts', await settings.get('preferred_hand_reverse_homepage_shortcuts') as boolean);

  // Appearance - Animation
  let animation_response = await settings.get('animation_response') as number;
  let animation_damping = await settings.get('animation_damping_coefficient') as number;
  console.log('[Meow][init] Animation response: ' + animation_response.toString() + ', damping: ' + animation_damping.toString());
  AppStorage.setOrCreate('animation_response', animation_response);
  AppStorage.setOrCreate('animation_damping_coefficient', animation_damping);

  // Appearance - Colors
  AppStorage.setOrCreate('color_light_primary', await settings.get('color_light_primary') as string);
  AppStorage.setOrCreate('color_light_secondary', await settings.get('color_light_secondary') as string);
  AppStorage.setOrCreate('color_light_font', await settings.get('color_light_font') as string);
  AppStorage.setOrCreate('color_dark_primary', await settings.get('color_dark_primary') as string);
  AppStorage.setOrCreate('color_dark_secondary', await settings.get('color_dark_secondary') as string);
  AppStorage.setOrCreate('color_dark_font', await settings.get('color_dark_font') as string);

  // Appearance - Dark
  AppStorage.setOrCreate('web_force_dark_mode', await settings.get('web_force_dark_mode') as boolean);
  let web_force_dark_mode_exemptions = await settings.get('web_force_dark_mode_exemptions') as string;
  if (web_force_dark_mode_exemptions.length < 2) {
    // Empty
    let web_force_dark_mode_exemptions_list: string[] = [];
    AppStorage.setOrCreate('web_force_dark_mode_exemptions', web_force_dark_mode_exemptions_list);
  } else {
    AppStorage.setOrCreate('web_force_dark_mode_exemptions', web_force_dark_mode_exemptions.split('\n'));
  }

  // General - Surf
  let home_url: string = await settings.get('home_url') as string
  let new_tab_url: string = await settings.get('new_tab_url') as string
  let start_up_option: string = await settings.get('start_up_option') as string
  AppStorage.setOrCreate('home_url', home_url);
  AppStorage.setOrCreate('new_tab_url', new_tab_url);
  AppStorage.setOrCreate('start_up_option', start_up_option);
  tabs.start_up = start_up_option;
  tabs.new_tab_url = new_tab_url;
  tabs.home_url = home_url;

  AppStorage.setOrCreate('intelligent_tracking_prevention', await settings.get('intelligent_tracking_prevention') as boolean);

  // General - Homepage
  AppStorage.setOrCreate('homepage_shortcuts_init_height', await settings.get('homepage_shortcuts_init_height') as number);
  AppStorage.setOrCreate('homepage_shortcuts_bookmarks_dir', await settings.get('homepage_shortcuts_bookmarks_dir') as string);

  let sites_got: string;

  // Disable image
  AppStorage.setOrCreate('disable_image', await settings.get('disable_image') as boolean);
  AppStorage.setOrCreate('disable_image_all_sites', await settings.get('disable_image_all_sites') as boolean);
  sites_got = await settings.get('disable_image_these_sites') as string;
  let disable_image_these_sites = (sites_got == '') ? [] : sites_got.split('\n');
  AppStorage.setOrCreate('disable_image_these_sites', disable_image_these_sites);

  // Disable JS
  AppStorage.setOrCreate('disable_js', await settings.get('disable_js') as boolean);
  AppStorage.setOrCreate('disable_js_all_sites', await settings.get('disable_js_all_sites') as boolean);
  sites_got = await settings.get('disable_js_these_sites') as string;
  let disable_js_these_sites = (sites_got == '') ? [] : sites_got.split('\n');
  AppStorage.setOrCreate('disable_js_these_sites', disable_js_these_sites);

  // Ad Blocker
  AppStorage.setOrCreate('use_adblock', await settings.get('use_adblock') as boolean);
  sites_got = await settings.get('adblock_exceptions') as string;
  let adblock_exceptions = (sites_got == '') ? [] : sites_got.split('\n');
  AppStorage.setOrCreate('adblock_exceptions', adblock_exceptions);

  // UA
  AppStorage.setOrCreate('custom_user_agents', await settings.get('custom_user_agents') as string);
  AppStorage.setOrCreate('user_agent_selected', await settings.get('custom_user_agents_selected_index') as string);

  // SE
  AppStorage.setOrCreate('custom_search_engines', await settings.get('custom_search_engines') as string);
  AppStorage.setOrCreate('search_engine_selected', await settings.get('custom_search_engines_selected_index') as string);

  // Downloads
  AppStorage.setOrCreate('direct_download', await settings.get('direct_download') as string);
  AppStorage.setOrCreate('direct_download_auto_open', await settings.get('direct_download_auto_open') as string);

  // Cardboard Box
  AppStorage.setOrCreate('resource_monitor', await settings.get('resource_monitor') as boolean);
}

/**
 * Inits and loads bookmarks from disk.
 * */
async function bookmarks() {
  let bookmarks = new bunch_of_bookmarks("Bookmarks~Meow");
  AppStorage.setOrCreate('bunch_of_bookmarks', bookmarks);

  // Get bookmarks
  let result: string = sandbox_read_text_sync('html_bookmarks.html');
  if (result == "undefined") {
    // Check old kv_store
    result = await kv_store_get("html_bookmarks") as string;
    sandbox_save('html_bookmarks.html', result);
  }
  if (result == "undefined") {
    // First use bookmarks
  } else {
    let html_bookmarks = result;
    bookmarks.import_html(html_bookmarks, true);
  }
}

/**
 * Retrieves the restore tabs indices
 * */
async function restore() {
  // Get Data
  let continue_tabs_count_string = await kv_store_get("continue_tabs_count");
  let continue_tabs_main_on_string = await kv_store_get("continue_tabs_main_on");
  let continue_tabs_sub_on_string = await kv_store_get("continue_tabs_sub_on");
  let continue_tabs_count = 0;
  let continue_tabs_main_on = 0;
  let continue_tabs_sub_on = 0;

  if (continue_tabs_count_string == "undefined") {
    kv_store_put("continue_tabs_count", "0");
    continue_tabs_count = 0;
  } else {
    continue_tabs_count = Number.parseInt(continue_tabs_count_string);
  }

  if (continue_tabs_main_on_string == "undefined") {
    kv_store_put("continue_tabs_main_on", "0");
    continue_tabs_main_on = 0;
  } else {
    continue_tabs_main_on = Number.parseInt(continue_tabs_main_on_string);
  }

  if (continue_tabs_sub_on_string == "undefined") {
    kv_store_put("continue_tabs_sub_on", "-1");
    continue_tabs_sub_on = -1;
  } else {
    continue_tabs_sub_on = Number.parseInt(continue_tabs_sub_on_string);
  }

  AppStorage.setOrCreate('continue_tabs_count', continue_tabs_count);
  AppStorage.setOrCreate('continue_tabs_main_on', continue_tabs_main_on);
  AppStorage.setOrCreate('continue_tabs_sub_on', continue_tabs_sub_on);

  // Log
  console.log("[Meow][init] Got continue_tabs_count: " + continue_tabs_count_string);
  console.log("[Meow][init] Got continue_tabs_main_on: " + continue_tabs_main_on_string);
  console.log("[Meow][init] Got continue_tabs_sub_on: " + continue_tabs_sub_on_string);
}

/**
 * Inits history.
 * */
function history() {
  AppStorage.setOrCreate('bunch_of_history', new bunch_of_history());

  // Initialize statuses
  AppStorage.setOrCreate('reindexing_history', undefined);
  AppStorage.setOrCreate('history_index_loading', undefined);
  AppStorage.setOrCreate('history_index_saving', undefined);
  AppStorage.setOrCreate('reindexing_history_progress', '');
  AppStorage.setOrCreate('history_index_loading_progress', '');
  AppStorage.setOrCreate('history_index_saving_progress', '');
}