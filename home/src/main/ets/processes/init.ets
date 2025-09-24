// The initialization of the entire app
import { bundleManager, common } from '@kit.AbilityKit';
import { sandbox_save, sandbox_unlink } from '../utils/storage_tools';
import { fileIo } from '@kit.CoreFileKit';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import { bunch_of_history } from '../hosts/bunch_of_history';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';
import { bunch_of_key_shortcuts } from '../hosts/bunch_of_key_shortcuts';

// executed in async aboutToAppear(): Promise<void> in Index.ets
export async function meow_init(context: common.UIAbilityContext) {
  let t0 = Date.now();

  // Get and set app version info
  bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
    console.log('[Meow][history] Saving app version: ' + bundleInfo.versionName + "(" + bundleInfo.versionCode.toString() + ")");
    sandbox_save("last_app_versionCode.txt", bundleInfo.versionCode.toString());
    sandbox_save("last_app_versionName.txt", bundleInfo.versionName);
  })

  await settings();
  console.log('[init] Settings OK');

  AppStorage.setOrCreate('bunch_of_history', new bunch_of_history());
  AppStorage.setOrCreate('bunch_of_tabs', new bunch_of_tabs());
  AppStorage.setOrCreate('bunch_of_downloads', new bunch_of_downloads());
  AppStorage.setOrCreate('bunch_of_key_shortcuts', new bunch_of_key_shortcuts());
  console.log('[init] bunch_of_init!')

  // File management
  clear_web_drag_image_cache(context);
  clear_profile(context);

  let t = Date.now() - t0;

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

// Settings

async function settings() {
  let settings = new bunch_of_settings();
  AppStorage.setOrCreate('bunch_of_settings', settings);

  // DEV_MODE
  AppStorage.setOrCreate('DEV_MODE', await settings.get('DEV_MODE') as boolean);

  // UI Status
  AppStorage.setOrCreate('showing_tabs', await settings.get('status_tabs_open') as boolean);
  AppStorage.setOrCreate('title_bar_position', await settings.get('title_bar_position') as string);
  AppStorage.setOrCreate('tabs_style', await settings.get('tabs_style') as string);
  AppStorage.setOrCreate('tabs_style_non_tablet_mode', await settings.get('tabs_style_non_tablet_mode') as string);

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

  // General - Surf
  AppStorage.setOrCreate('home_url', await settings.get('home_url') as string);
  AppStorage.setOrCreate('new_tab_url', await settings.get('new_tab_url') as string);
  AppStorage.setOrCreate('start_up_option', await settings.get('start_up_option') as string);
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