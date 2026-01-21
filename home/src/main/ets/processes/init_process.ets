// The initialization of the entire app
import { bundleManager, common } from '@kit.AbilityKit';
import { sandbox_read_text_sync, sandbox_save, sandbox_unlink } from '../utils/storage_tools';
import { fileIo } from '@kit.CoreFileKit';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { bunch_of_history } from '../hosts/bunch_of_history';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';
import { bunch_of_key_shortcuts } from '../hosts/bunch_of_key_shortcuts';
import lazy { kv_store_get } from '../utils/kv_store_tools';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import { bunch_of_search_engines } from '../hosts/bunch_of_search_engines';
import { run_time } from '../utils/ui_tools';
import { MessageEvents, worker } from '@kit.ArkTS';
import lazy { sendableImage } from '@kit.ImageKit';
import lazy { refresh_AppStorage_zones } from './zone_actions';
import lazy { default_new_window_name, default_title_function_buttons_amount } from '../hosts/bunch_of_defaults';
import { refresh_AppStorage_extensions } from './extension_actions';

/**
 * Initializes all things.
 *
 * Should be executed in HomeAbility.ets on each launch of entire app.
 */
export async function meow_init_main(context: common.UIAbilityContext, storage: LocalStorage) {
  // Get and set app version info
  bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
    console.log('[Meow][history] Saving app version: ' + bundleInfo.versionName + "(" + bundleInfo.versionCode.toString() + ")");
    sandbox_save("last_app_versionCode.txt", bundleInfo.versionCode.toString());
    sandbox_save("last_app_versionName.txt", bundleInfo.versionName);
  });

  // File management
  load_homepage_background(context.filesDir, storage);
  clear_profile(context);
  ensure_continue_folder(context);
  ensure_easylist_folder(context);
  ensure_zones_folder(context);
  create_download(context);
  create_web_drag_image_cache(context);
  create_harmony_share_temp(context);
  delete_old_temp_files(context);

  // Hosts
  await settings(storage);
  await bookmarks(storage);

  ensure_extensions_folder(context);

  // Placeholder
  AppStorage.setOrCreate('bunch_of_bookmarks', new bunch_of_bookmarks("Bookmarks~Meow"));

  await restore_tabs(storage);
  tabs(storage);
  history(storage);
  downloads(storage);
  user_agents(storage);
  search_engines(storage);

  AppStorage.setOrCreate('bunch_of_key_shortcuts', new bunch_of_key_shortcuts());

  console.log('[Meow][init] MAIN OK. (' + run_time(storage) + ' ms)');
}

/**
 * Initializes things needed for an extra window.
 *
 * Should be executed in HomeAbility.ets on each launch of entire app.
 */
export function meow_init_sub(_context: common.UIAbilityContext, storage: LocalStorage) {
  let t0 = Date.now();
  let t = 0;

  tabs(storage);

  t = Date.now() - t0;
  console.log('[Meow][init] SUB OK. (' + t + ' ms)');
}

// Files

/**
 * Checks and ensures there is a /continue directory in sandbox.
 * */
function ensure_continue_folder(context: common.UIAbilityContext) {
  let filesDir = context.filesDir;
  try {
    if (!fileIo.accessSync(filesDir + '/continue')) {
      fileIo.mkdirSync(filesDir + '/continue', true);
    }
  } catch (e) {
    console.error('[init][ensure_continue_folder] Error: ' + e);
  }
}

/**
 * Checks and ensures there is a /zones directory in sandbox.
 * */
function ensure_zones_folder(context: common.UIAbilityContext) {
  let filesDir = context.filesDir;
  try {
    if (!fileIo.accessSync(filesDir + '/zones')) {
      fileIo.mkdirSync(filesDir + '/zones', true);
    } else {
      // Zones exist
      refresh_AppStorage_zones();
      console.log('[init][ensure_zones_folder] Found zones: ' + (AppStorage.get('zones') as string[]));
    }
  } catch (e) {
    console.error('[init][ensure_zones_folder] Error: ' + e);
  }
}

/**
 * Checks and ensures there is a /extensions directory in sandbox.
 * */
function ensure_extensions_folder(context: common.UIAbilityContext) {
  let filesDir = context.filesDir;
  try {
    fileIo.mkdirSync(context.tempDir + '/extensions', true);
  } catch (e) {
    console.error('[Index] mkdirSync temp/extensions failed! ' + e);
  }
  try {
    if (!fileIo.accessSync(filesDir + '/extensions-disabled')) {
      fileIo.mkdirSync(filesDir + '/extensions-disabled', true);
    } else {
      console.log('[init][ensure_extensions_disabled_folder] Found disabled extensions folder! ');
    }
  } catch (e) {
    console.error('[init][ensure_extensions_disabled_folder] Error: ' + e);
  }
  try {
    if (!fileIo.accessSync(filesDir + '/extensions')) {
      fileIo.mkdirSync(filesDir + '/extensions', true);
    } else {
      // extensions exist
      refresh_AppStorage_extensions(context);
      console.log('[init][ensure_extensions_folder] Found extensions: ' + (AppStorage.get('extensions_ids') as string[]));
    }
  } catch (e) {
    console.error('[init][ensure_extensions_folder] Error: ' + e);
  }
}

/**
 * Checks and ensures there is a /easylist directory in sandbox.
 * */
function ensure_easylist_folder(context: common.UIAbilityContext) {
  let filesDir = context.filesDir;
  try {
    if (!fileIo.accessSync(filesDir + '/easylist')) {
      fileIo.mkdirSync(filesDir + '/easylist', true);
    }
  } catch (e) {
    console.error('[init][ensure_easylist_folder] Error: ' + e);
  }
}

/**
 * Set Harmony Share temp folder.
 * @param context The UIAbilityContext.
 * */
function create_harmony_share_temp(context: common.UIAbilityContext) {
  try {
    fileIo.mkdirSync(context.tempDir + '/harmony-share-temp', true);
  } catch (e) {
    console.error('[Index] mkdirSync temp/harmony-share-temp failed! ' + e);
  }
}

/**
 * Set cache dir of web-dragged image into Scratching Board.
 * */
function create_web_drag_image_cache(context: common.UIAbilityContext) {
  try {
    fileIo.mkdirSync(context.tempDir + '/web-drag-image-cache', true);
  } catch (e) {
    console.error('[Index] mkdirSync temp/web-drag-image-cache failed! ' + e);
  }
}

/**
 * Set temp dir for downloads.
 * @param context
 * */
function create_download(context: common.UIAbilityContext) {
  try {
    fileIo.mkdirSync(context.tempDir + '/downloads', true);
  } catch (e) {
    console.error('[Index] mkdirSync temp/downloads failed! ' + e);
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

/**
 * Read and set image for homepage from disk, using a worker.
 * @param storage The LocalStorage.
 * */
function load_homepage_background(filesDir: string, storage: LocalStorage) {
  let workerInstance = new worker.ThreadWorker("home/ets/workers/Homepage_background_loader.ets");
  workerInstance.onmessage = (e: MessageEvents): void => {
    // Coming back with the pixelMap
    let pm = e.data as sendableImage.PixelMap;
    try {
      AppStorage.setOrCreate('homepage_background', sendableImage.convertToPixelMap(pm));
    } catch (e) {
      console.error(`[Meow][init] load homepage background set AppStorage failed: ` + e);
    }
    console.log(`[Meow][init] Receive load homepage background thread PixelMap. (${run_time(storage)} ms)!`);
    workerInstance.terminate();
  };
  workerInstance.onexit = (() => {
    console.log(`[Meow][init] Load homepage background thread terminated. (${run_time(storage)} ms)`);
  })
  workerInstance.postMessage(filesDir);
}

/**
 * Deletes old temp directories. (They are all moved to tempDir after Nov. 4, 2025)
 * */
function delete_old_temp_files(context: common.UIAbilityContext) {
  try {
    if (fileIo.accessSync(context.filesDir + '/web-drag-image-cache')) {
      fileIo.rmdirSync(context.filesDir + '/web-drag-image-cache');
      fileIo.rmdirSync(context.filesDir + '/downloads');
      fileIo.rmdirSync(context.filesDir + '/harmonyShare_temp');
    }
  } catch (e) {
    console.error('[Index] rmdirSync temp/web-drag-image-cache failed! ' + e);
  }
}

// Hosts

/**
 * Inits both settings and tabs.
 * @param t0 Start time of the whole initialization process.
 * */
async function settings(storage: LocalStorage) {
  await bunch_of_settings.init();

  // DEV_MODE
  AppStorage.setOrCreate('DEV_MODE', bunch_of_settings.get('DEV_MODE') as boolean);

  // UI Status
  AppStorage.setOrCreate('title_bar_position', bunch_of_settings.get('title_bar_position') as string);
  AppStorage.setOrCreate('tabs_style', bunch_of_settings.get('tabs_style') as string);
  AppStorage.setOrCreate('tabs_style_non_tablet_mode', bunch_of_settings.get('tabs_style_non_tablet_mode') as string);
  AppStorage.setOrCreate('showing_my_window_alias', bunch_of_settings.get('status_showing_my_windows_alias') as boolean);
  AppStorage.setOrCreate('showing_my_window_alias_non_tablet', bunch_of_settings.get('status_showing_my_windows_alias_non_tablet') as boolean);
  AppStorage.setOrCreate('tabs_vertical_auto_hide', bunch_of_settings.get('tabs_vertical_auto_hide') as boolean);
  AppStorage.setOrCreate('tabs_vertical_auto_hide_button', bunch_of_settings.get('tabs_vertical_auto_hide_button') as boolean);
  AppStorage.setOrCreate('showing_large_my_window_alias', bunch_of_settings.get('status_showing_large_my_window_alias') as boolean);
  AppStorage.setOrCreate('my_window_alias_position', bunch_of_settings.get('my_window_alias_position') as string);
  AppStorage.setOrCreate('effects', bunch_of_settings.get('effects') as boolean);
  AppStorage.setOrCreate('last_zone', bunch_of_settings.get('last_zone') as string);

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
  AppStorage.setOrCreate('esc_to_access_backward', bunch_of_settings.get('esc_to_access_backward') as boolean);
  AppStorage.setOrCreate('preferred_hand_left_or_right', bunch_of_settings.get('preferred_hand_left_or_right') as string);
  AppStorage.setOrCreate('preferred_hand_reverse_tabs_panel', bunch_of_settings.get('preferred_hand_reverse_tabs_panel') as boolean);
  AppStorage.setOrCreate('preferred_hand_reverse_settings_menu', bunch_of_settings.get('preferred_hand_reverse_settings_menu') as boolean);
  AppStorage.setOrCreate('preferred_hand_reverse_homepage_shortcuts', bunch_of_settings.get('preferred_hand_reverse_homepage_shortcuts') as boolean);
  AppStorage.setOrCreate('preferred_hand_auto', bunch_of_settings.get('preferred_hand_auto') as boolean);

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
  // NO NEED, as these data would be put to bunch_of_tabs

  // let home_url: string = bunch_of_settings.get('home_url') as string
  // let new_tab_url: string = bunch_of_settings.get('new_tab_url') as string
  // let start_up_option: string = bunch_of_settings.get('start_up_option') as string
  // AppStorage.setOrCreate('home_url', home_url);
  // AppStorage.setOrCreate('new_tab_url', new_tab_url);
  // AppStorage.setOrCreate('start_up_option', start_up_option);

  AppStorage.setOrCreate('intelligent_tracking_prevention', bunch_of_settings.get('intelligent_tracking_prevention') as boolean);
  AppStorage.setOrCreate('enable_third_party_cookies', bunch_of_settings.get('enable_third_party_cookies') as boolean);

  // General - Homepage
  AppStorage.setOrCreate('homepage_shortcuts_init_height', bunch_of_settings.get('homepage_shortcuts_init_height') as number);
  AppStorage.setOrCreate('homepage_shortcuts_bookmarks_dir', bunch_of_settings.get('homepage_shortcuts_bookmarks_dir') as string);
  // console.log('[Meow] homepage_shortcuts_bookmarks_dir: ' + bunch_of_settings.get('homepage_shortcuts_bookmarks_dir') as string);

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

  // Title function buttons
  AppStorage.setOrCreate('title_CONFIG_EXTENSIONS', bunch_of_settings.get('title_function_extensions') as boolean);
  let config_buttons_str = bunch_of_settings.get('title_function_buttons') as string;
  let bool_config: boolean[] = []
  for (let index = 0; index < config_buttons_str.length; index++) {
    const element = config_buttons_str[index];
    if (element == '1') {
      bool_config.push(true);
    } else {
      bool_config.push(false);
    }
  }
  while (bool_config.length < default_title_function_buttons_amount()) {
    // Add defaults to the bool_config.
    bool_config.splice(0, 0, false);
  }
  AppStorage.setOrCreate('title_CONFIG_BUTTONS', bool_config);
  console.log(`[init] title_CONFIG_BUTTONS = ${bool_config}`);

  // Timer
  console.log('[init] Settings OK. (' + run_time(storage) + ' ms)');
}

/**
 * Gets bunch_of_bookmarks from AppStorage.
 *
 * Inits and loads bookmarks from disk.
 * @param t0 Start time of the whole initialization process.
 * @returns The time in ms of execution.
 * */
export async function bookmarks(storage: LocalStorage) {
  let t0 = Date.now();

  // Get bookmarks
  let result: string = sandbox_read_text_sync('html_bookmarks.html');
  let tt = Date.now() - t0;
  console.log(`[Meow][init] Bookmarks sandbox_read_text_sync (${tt}/${run_time(storage)} ms)`);

  // Work on retrieved data
  if (result == "undefined") {
    // Check old kv_store
    result = await kv_store_get("html_bookmarks") as string;
    sandbox_save('html_bookmarks.html', result);
  }
  if (result == "undefined") {
    // First use bookmarks
  } else {
    let html_bookmarks = result;
    let workerInstance = new worker.ThreadWorker("home/ets/workers/Bookmarks_loader.ets");
    workerInstance.onmessage = (e: MessageEvents): void => {
      // Coming back with the bookmark
      let bookmarks = e.data as bunch_of_bookmarks;
      console.log(`[Meow][init] Bookmarks load thread message. Root label: ${bookmarks.root.get_label()}, (${run_time(storage)} ms)`);
      AppStorage.set('bunch_of_bookmarks', bookmarks);
      // Process shortcuts
      let shortcuts_dir = AppStorage.get('homepage_shortcuts_bookmarks_dir') as string;
      if (shortcuts_dir) {
        let shortcuts = bookmarks.get_folder(shortcuts_dir)?.get_content();
        if (shortcuts) {
          AppStorage.setOrCreate('homepage_shortcuts', Array.from(shortcuts));
          console.log(`[Meow][init] Bookmarks shortcuts processed! (${run_time(storage)} ms)`);
        }
      }
      workerInstance.terminate();
    };
    workerInstance.onexit = (() => {
      console.log(`[Meow][init] Bookmarks load thread terminated. (${run_time(storage)} ms)`);
    })
    workerInstance.postMessage(html_bookmarks);
    // bookmarks.import_html(html_bookmarks, true);
  }

  // Timer
  tt = Date.now() - t0;
  console.log(`[Meow][init] Bookmarks main thread OK. (${tt}/${run_time(storage)} ms)`);
  return tt;
}

/**
 * Retrieves the restore tabs indices.
 *
 * MUST BE EXECUTED AFTER INITIALIZATION OF bunch_of_settings!
 * @param t0 Start time of the whole initialization process.
 * */
async function restore_tabs(storage: LocalStorage) {
  // Get Data
  let continue_tabs_main_on = bunch_of_settings.get('continue_tabs_main_on') as number;
  let continue_tabs_sub_on = bunch_of_settings.get('continue_tabs_sub_on') as number;

  // TODO: Investigate this weird bug
  if (continue_tabs_main_on == continue_tabs_sub_on) {
    console.error('[init][restore_tabs] Weird bug of continue_tabs_main_on == continue_tabs_sub_on occurred!!');
    continue_tabs_sub_on = -1;
  }

  AppStorage.setOrCreate('continue_tabs_main_on', continue_tabs_main_on);
  AppStorage.setOrCreate('continue_tabs_sub_on', continue_tabs_sub_on);

  // Log
  console.log("[Meow][init] Got continue_tabs_main_on: " + continue_tabs_main_on);
  console.log("[Meow][init] Got continue_tabs_sub_on: " + continue_tabs_sub_on);

  // Timer
  console.log('[init] Restore OK. (' + run_time(storage) + ' ms)');
}

/**
 * Inits and fills bunch_of_tabs settings.
 *
 * MUST BE EXECUTED AFTER INITIALIZATION OF bunch_of_settings!
 * @param t0 Start time of the whole initialization process.
 * */
function tabs(storage: LocalStorage) {
  let tabs = new bunch_of_tabs(false, storage);
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

  // Name
  let name = bunch_of_settings.get('my_window_alias_last') as string;
  if (name == '') {
    name = default_new_window_name();
  } else {
    let is_zone = storage.get('is_zone') as boolean;
    // Avoid duplicated name
    if (is_zone) {
      let zones = AppStorage.get('zones') as string[];
      if (zones.includes(name)) {
        name = default_new_window_name();
      }
    }
  }
  console.log(`[init][tabs] my_window_alias=${name}`);
  storage.setOrCreate('my_window_alias', name);
  storage.setOrCreate('pin_to_top', false);

  // Fill back settings
  let home_url: string = bunch_of_settings.get('home_url') as string
  let new_tab_url: string = bunch_of_settings.get('new_tab_url') as string
  let start_up_option: string = bunch_of_settings.get('start_up_option') as string
  bunch_of_tabs.start_up = start_up_option;
  bunch_of_tabs.new_tab_url = new_tab_url;
  bunch_of_tabs.home_url = home_url;

  // Timer
  console.log('[init] Tabs OK. (' + run_time(storage) + ' ms) id: ' + tabs.my_id);
}

/**
 * Inits history.
 * @param t0 Start time of the whole initialization process.
 * */
function history(storage: LocalStorage) {
  AppStorage.setOrCreate('bunch_of_history', new bunch_of_history());

  // Initialize statuses
  AppStorage.setOrCreate('reindexing_history', undefined);
  AppStorage.setOrCreate('history_index_loading', undefined);
  AppStorage.setOrCreate('history_index_saving', undefined);
  AppStorage.setOrCreate('reindexing_history_progress', '');
  AppStorage.setOrCreate('history_index_loading_progress', '');
  AppStorage.setOrCreate('history_index_saving_progress', '');

  // Timer
  console.log('[init] History OK. (' + run_time(storage) + ' ms)');
}

/**
 * Inits downloads.
 * @param t0 Start time of the whole initialization process.
 * */
function downloads(storage: LocalStorage) {
  let downloads = new bunch_of_downloads();
  AppStorage.setOrCreate('bunch_of_downloads', downloads);

  // Timer
  console.log('[init] Downloads OK. (' + run_time(storage) + ' ms)');
}

/**
 * Inits bunch_of_user_agents.
 *
 * MUST BE EXECUTED AFTER INITIALIZATION OF bunch_of_settings!
 * @param t0 Start time of the whole initialization process.
 * */
function user_agents(storage: LocalStorage) {
  let custom_user_agents = bunch_of_settings.get('custom_user_agents') as string;
  let user_agent_selected = bunch_of_settings.get('custom_user_agents_selected_index') as number;
  bunch_of_user_agents.import_string(custom_user_agents);
  bunch_of_user_agents.set_global_UA(user_agent_selected);

  // Timer
  console.log('[init] UA OK. (' + run_time(storage) + ' ms)');
}

/**
 * Inits bunch_of_search_engines.
 *
 * MUST BE EXECUTED AFTER INITIALIZATION OF bunch_of_settings!
 * @param t0 Start time of the whole initialization process.
 * */
function search_engines(storage: LocalStorage) {
  let custom_search_engines = bunch_of_settings.get('custom_search_engines') as string;
  let search_engines_selected = bunch_of_settings.get('custom_search_engines_selected_index') as number;
  bunch_of_search_engines.import_string(custom_search_engines);
  bunch_of_search_engines.set_global_SE(search_engines_selected);

  // Timer
  console.log('[init] SE OK. (' + run_time(storage) + ' ms)');
}