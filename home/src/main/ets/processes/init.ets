// The initialization of the entire app
import { bundleManager, common } from '@kit.AbilityKit';
import { sandbox_read_text_sync, sandbox_save, sandbox_unlink } from '../utils/storage_tools';
import { fileIo } from '@kit.CoreFileKit';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { bunch_of_history } from '../hosts/bunch_of_history';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';
import { bunch_of_key_shortcuts } from '../hosts/bunch_of_key_shortcuts';
import { kv_store_get } from '../utils/kv_store_tools';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import { bunch_of_search_engines } from '../hosts/bunch_of_search_engines';

/**
 * Initializes all things.
 *
 * Should be executed in HomeAbility.ets on each launch of entire app.
 */
export async function meow_init_main(context: common.UIAbilityContext, storage: LocalStorage) {
  let t0 = Date.now();
  let t = 0;

  // Get and set app version info
  bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
    console.log('[Meow][history] Saving app version: ' + bundleInfo.versionName + "(" + bundleInfo.versionCode.toString() + ")");
    sandbox_save("last_app_versionCode.txt", bundleInfo.versionCode.toString());
    sandbox_save("last_app_versionName.txt", bundleInfo.versionName);
  })

  // File management
  clear_web_drag_image_cache(context);
  clear_profile(context);
  ensure_continue_folder(context);

  // Hosts
  await settings(t0);
  await bookmarks(t0);
  await restore_tabs(t0);
  tabs(t0, storage);
  history(t0);
  downloads(t0);
  user_agents(t0);
  search_engines(t0);

  AppStorage.setOrCreate('bunch_of_key_shortcuts', new bunch_of_key_shortcuts());
  t = Date.now() - t0;
  console.log('[init] bunch_of_init! (' + t + ' ms)')

  t = Date.now() - t0;
  console.log('[Meow][init] MAIN OK. (' + t + ' ms)');
}

/**
 * Initializes things needed for an extra window.
 *
 * Should be executed in HomeAbility.ets on each launch of entire app.
 */
export function meow_init_sub(context: common.UIAbilityContext, storage: LocalStorage) {
  let t0 = Date.now();
  let t = 0;

  tabs(t0, storage);

  t = Date.now() - t0;
  console.log('[Meow][init] SUB OK. (' + t + ' ms)');
}

// Files

/**
 * Checks and ensures there is a /continue directory in sandbox.
 * */
function ensure_continue_folder(context: common.UIAbilityContext) {
  let filesDir = context.filesDir;
  if (!fileIo.accessSync(filesDir + '/continue')) {
    try {
      fileIo.mkdirSync(filesDir + '/continue');
    } catch (e) {
      console.error('[init][ensure_continue_folder] Error: ' + e);
    }
  }
}

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
 * Inits both settings and tabs.
 * @param t0 Start time of the whole initialization process.
 * */
async function settings(t0: number) {
  await bunch_of_settings.init();

  // DEV_MODE
  AppStorage.setOrCreate('DEV_MODE', bunch_of_settings.get('DEV_MODE') as boolean);

  // UI Status
  AppStorage.setOrCreate('title_bar_position', bunch_of_settings.get('title_bar_position') as string);
  AppStorage.setOrCreate('tabs_style', bunch_of_settings.get('tabs_style') as string);
  AppStorage.setOrCreate('tabs_style_non_tablet_mode', bunch_of_settings.get('tabs_style_non_tablet_mode') as string);
  // storage.setOrCreate('showing_tabs', bunch_of_settings.get('status_tabs_open') as boolean);

  // Continuation
  AppStorage.setOrCreate('continuation_auto_exit', bunch_of_settings.get('continuation_auto_exit') as boolean);
  AppStorage.setOrCreate('continuation_auto_close_tab', bunch_of_settings.get('continuation_auto_close_tab') as boolean);

  // Experience - Suggestions
  AppStorage.setOrCreate('max_bookmark_advice', bunch_of_settings.get('max_bookmark_suggest') as number);
  AppStorage.setOrCreate('max_history_advice', bunch_of_settings.get('max_history_suggest') as number);

  // History
  AppStorage.setOrCreate('collect_new_history', bunch_of_settings.get('collect_new_history') as boolean);
  AppStorage.setOrCreate('history_index_load_quantity', bunch_of_settings.get('history_index_load_quantity') as boolean);

  // Accessibility
  AppStorage.setOrCreate('sys_back_to_access_backward', bunch_of_settings.get('sys_back_access_backward') as boolean);
  AppStorage.setOrCreate('preferred_hand_left_or_right', bunch_of_settings.get('preferred_hand_left_or_right') as string);
  AppStorage.setOrCreate('preferred_hand_reverse_tabs_panel', bunch_of_settings.get('preferred_hand_reverse_tabs_panel') as boolean);
  AppStorage.setOrCreate('preferred_hand_reverse_settings_menu', bunch_of_settings.get('preferred_hand_reverse_settings_menu') as boolean);
  AppStorage.setOrCreate('preferred_hand_reverse_homepage_shortcuts', bunch_of_settings.get('preferred_hand_reverse_homepage_shortcuts') as boolean);

  // Appearance - Animation
  let animation_response = bunch_of_settings.get('animation_response') as number;
  let animation_damping = bunch_of_settings.get('animation_damping_coefficient') as number;
  console.log('[Meow][init] Animation response: ' + animation_response.toString() + ', damping: ' + animation_damping.toString());
  AppStorage.setOrCreate('animation_response', animation_response);
  AppStorage.setOrCreate('animation_damping_coefficient', animation_damping);

  // Appearance - Colors
  AppStorage.setOrCreate('color_light_primary', bunch_of_settings.get('color_light_primary') as string);
  AppStorage.setOrCreate('color_light_secondary', bunch_of_settings.get('color_light_secondary') as string);
  AppStorage.setOrCreate('color_light_font', bunch_of_settings.get('color_light_font') as string);
  AppStorage.setOrCreate('color_dark_primary', bunch_of_settings.get('color_dark_primary') as string);
  AppStorage.setOrCreate('color_dark_secondary', bunch_of_settings.get('color_dark_secondary') as string);
  AppStorage.setOrCreate('color_dark_font', bunch_of_settings.get('color_dark_font') as string);

  // Appearance - Dark
  AppStorage.setOrCreate('web_force_dark_mode', bunch_of_settings.get('web_force_dark_mode') as boolean);
  let web_force_dark_mode_exemptions = bunch_of_settings.get('web_force_dark_mode_exemptions') as string;
  if (web_force_dark_mode_exemptions.length < 2) {
    // Empty
    let web_force_dark_mode_exemptions_list: string[] = [];
    AppStorage.setOrCreate('web_force_dark_mode_exemptions', web_force_dark_mode_exemptions_list);
  } else {
    AppStorage.setOrCreate('web_force_dark_mode_exemptions', web_force_dark_mode_exemptions.split('\n'));
  }

  // Bottom avoid
  AppStorage.setOrCreate('bottom_avoid', bunch_of_settings.get('bottom_avoid') as boolean);

  // General - Surf
  let home_url: string = bunch_of_settings.get('home_url') as string
  let new_tab_url: string = bunch_of_settings.get('new_tab_url') as string
  let start_up_option: string = bunch_of_settings.get('start_up_option') as string
  AppStorage.setOrCreate('home_url', home_url);
  AppStorage.setOrCreate('new_tab_url', new_tab_url);
  AppStorage.setOrCreate('start_up_option', start_up_option);

  AppStorage.setOrCreate('intelligent_tracking_prevention', bunch_of_settings.get('intelligent_tracking_prevention') as boolean);

  // General - Homepage
  AppStorage.setOrCreate('homepage_shortcuts_init_height', bunch_of_settings.get('homepage_shortcuts_init_height') as number);
  AppStorage.setOrCreate('homepage_shortcuts_bookmarks_dir', bunch_of_settings.get('homepage_shortcuts_bookmarks_dir') as string);

  let sites_got: string;

  // Disable image
  AppStorage.setOrCreate('disable_image', bunch_of_settings.get('disable_image') as boolean);
  AppStorage.setOrCreate('disable_image_all_sites', bunch_of_settings.get('disable_image_all_sites') as boolean);
  sites_got = bunch_of_settings.get('disable_image_these_sites') as string;
  let disable_image_these_sites = (sites_got == '') ? [] : sites_got.split('\n');
  AppStorage.setOrCreate('disable_image_these_sites', disable_image_these_sites);

  // Disable JS
  AppStorage.setOrCreate('disable_js', bunch_of_settings.get('disable_js') as boolean);
  AppStorage.setOrCreate('disable_js_all_sites', bunch_of_settings.get('disable_js_all_sites') as boolean);
  sites_got = bunch_of_settings.get('disable_js_these_sites') as string;
  let disable_js_these_sites = (sites_got == '') ? [] : sites_got.split('\n');
  AppStorage.setOrCreate('disable_js_these_sites', disable_js_these_sites);

  // Ad Blocker
  AppStorage.setOrCreate('use_adblock', bunch_of_settings.get('use_adblock') as boolean);
  sites_got = bunch_of_settings.get('adblock_exceptions') as string;
  let adblock_exceptions = (sites_got == '') ? [] : sites_got.split('\n');
  AppStorage.setOrCreate('adblock_exceptions', adblock_exceptions);

  // UA
  AppStorage.setOrCreate('custom_user_agents', bunch_of_settings.get('custom_user_agents') as string);
  AppStorage.setOrCreate('user_agent_selected', bunch_of_settings.get('custom_user_agents_selected_index') as string);

  // SE
  AppStorage.setOrCreate('custom_search_engines', bunch_of_settings.get('custom_search_engines') as string);
  AppStorage.setOrCreate('search_engine_selected', bunch_of_settings.get('custom_search_engines_selected_index') as string);

  // Downloads
  AppStorage.setOrCreate('direct_download', bunch_of_settings.get('direct_download') as string);
  AppStorage.setOrCreate('direct_download_auto_open', bunch_of_settings.get('direct_download_auto_open') as string);

  // Cardboard Box
  AppStorage.setOrCreate('resource_monitor', bunch_of_settings.get('resource_monitor') as boolean);

  // Timer
  let t = Date.now() - t0;
  console.log('[init] Settings OK. (' + t + ' ms)');
}

/**
 * Inits and loads bookmarks from disk.
 * @param t0 Start time of the whole initialization process.
 * */
async function bookmarks(t0: number) {
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

  // Timer
  let t = Date.now() - t0;
  console.log('[init] Bookmarks OK. (' + t + ' ms)');
}

/**
 * Retrieves the restore tabs indices.
 *
 * MUST BE EXECUTED AFTER INITIALIZATION OF bunch_of_settings!
 * @param t0 Start time of the whole initialization process.
 * */
async function restore_tabs(t0: number) {
  // Get Data
  let continue_tabs_count = bunch_of_settings.get('continue_tabs_count') as number;
  let continue_tabs_main_on = bunch_of_settings.get('continue_tabs_main_on') as number;
  let continue_tabs_sub_on = bunch_of_settings.get('continue_tabs_sub_on') as number;

  // TODO: Investigate this weird bug
  if (continue_tabs_main_on == continue_tabs_sub_on) {
    console.error('[init][restore_tabs] Weird bug of continue_tabs_main_on == continue_tabs_sub_on occurred!!');
    continue_tabs_sub_on = -1;
  }

  AppStorage.setOrCreate('continue_tabs_count', continue_tabs_count);
  AppStorage.setOrCreate('continue_tabs_main_on', continue_tabs_main_on);
  AppStorage.setOrCreate('continue_tabs_sub_on', continue_tabs_sub_on);

  // Log
  console.log("[Meow][init] Got continue_tabs_count: " + continue_tabs_count);
  console.log("[Meow][init] Got continue_tabs_main_on: " + continue_tabs_main_on);
  console.log("[Meow][init] Got continue_tabs_sub_on: " + continue_tabs_sub_on);

  // Timer
  let t = Date.now() - t0;
  console.log('[init] Restore OK. (' + t + ' ms)');
}

/**
 * Inits and fills bunch_of_tabs settings.
 *
 * MUST BE EXECUTED AFTER INITIALIZATION OF bunch_of_settings!
 * @param t0 Start time of the whole initialization process.
 * */
function tabs(t0: number, storage: LocalStorage) {
  let tabs = new bunch_of_tabs(false, storage.get('my_window_id') as string);
  // AppStorage.setOrCreate('bunch_of_tabs', tabs);
  storage.setOrCreate('bunch_of_tabs', tabs);
  storage.setOrCreate('showing_tabs', bunch_of_settings.get('status_tabs_open') as boolean);

  // Store tabs of this window
  let all_bunch_of_tabs: bunch_of_tabs[] | undefined = AppStorage.get('all_bunch_of_tabs');
  if (all_bunch_of_tabs == undefined) {
    AppStorage.setOrCreate('all_bunch_of_tabs', [tabs]);
  } else {
    all_bunch_of_tabs.push(tabs);
    AppStorage.setOrCreate('all_bunch_of_tabs', all_bunch_of_tabs);
  }

  // Fill back settings
  let home_url: string = bunch_of_settings.get('home_url') as string
  let new_tab_url: string = bunch_of_settings.get('new_tab_url') as string
  let start_up_option: string = bunch_of_settings.get('start_up_option') as string
  tabs.start_up = start_up_option;
  tabs.new_tab_url = new_tab_url;
  tabs.home_url = home_url;

  // Timer
  let t = Date.now() - t0;
  console.log('[init] Tabs OK. (' + t + ' ms) id: ' + tabs.my_id);
}

/**
 * Inits history.
 * @param t0 Start time of the whole initialization process.
 * */
function history(t0: number) {
  AppStorage.setOrCreate('bunch_of_history', new bunch_of_history());

  // Initialize statuses
  AppStorage.setOrCreate('reindexing_history', undefined);
  AppStorage.setOrCreate('history_index_loading', undefined);
  AppStorage.setOrCreate('history_index_saving', undefined);
  AppStorage.setOrCreate('reindexing_history_progress', '');
  AppStorage.setOrCreate('history_index_loading_progress', '');
  AppStorage.setOrCreate('history_index_saving_progress', '');

  // Timer
  let t = Date.now() - t0;
  console.log('[init] History OK. (' + t + ' ms)');
}

/**
 * Inits downloads.
 * @param t0 Start time of the whole initialization process.
 * */
function downloads(t0: number) {
  let downloads = new bunch_of_downloads();
  downloads.delete_all_downloaded_files_sync();
  AppStorage.setOrCreate('bunch_of_downloads', downloads);

  // Timer
  let t = Date.now() - t0;
  console.log('[init] Downloads OK. (' + t + ' ms)');
}

/**
 * Inits bunch_of_user_agents.
 *
 * MUST BE EXECUTED AFTER INITIALIZATION OF bunch_of_settings!
 * @param t0 Start time of the whole initialization process.
 * */
function user_agents(t0: number) {
  let custom_user_agents = bunch_of_settings.get('custom_user_agents') as string;
  let user_agent_selected = bunch_of_settings.get('custom_user_agents_selected_index') as number;
  bunch_of_user_agents.import_string(custom_user_agents);
  bunch_of_user_agents.set_global_UA(user_agent_selected);

  // Timer
  let t = Date.now() - t0;
  console.log('[init] UA OK. (' + t + ' ms)');
}

/**
 * Inits bunch_of_search_engines.
 *
 * MUST BE EXECUTED AFTER INITIALIZATION OF bunch_of_settings!
 * @param t0 Start time of the whole initialization process.
 * */
function search_engines(t0: number) {
  let custom_search_engines = bunch_of_settings.get('custom_search_engines') as string;
  let search_engines_selected = bunch_of_settings.get('custom_search_engines_selected_index') as number;
  bunch_of_search_engines.import_string(custom_search_engines);
  bunch_of_search_engines.set_global_SE(search_engines_selected);

  // Timer
  let t = Date.now() - t0;
  console.log('[init] SE OK. (' + t + ' ms)');
}