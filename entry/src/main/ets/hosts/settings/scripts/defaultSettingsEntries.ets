import { meowSettingsEntry, meowSettingsEntryType } from "../classes/meowSettingsEntry";
import { defaultNewWindowName, defaultUserAgents, presetSearchEngines } from "./defaultSettingsValues";

/**
 * The default settings entries. ORDER MATTERS! ORDER MATTERS! ORDER MATTERS!
 * 
 * Because in the codes these entries are used with hard-coded indices to boost efficiency. e.g.:
 * @example 
 * `const settingsAdblockExceptions: meowSettingsEntry = this.myMeowManagedSettings.settingsData[53]; // adblock_exceptions`
 */
export let defaultSettingsEntries: meowSettingsEntry[] = [
  new meowSettingsEntry('webview_cache_size', meowSettingsEntryType.NUMBER, '-1'),

  // Customization
  new meowSettingsEntry('title_bar_position', meowSettingsEntryType.STRING, 'bottom'), // 'top' | 'bottom'
  new meowSettingsEntry('status_showing_large_my_window_alias', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('tabs_style', meowSettingsEntryType.STRING, 'vertical'), // 'vertical' | 'horizontal'
  new meowSettingsEntry('tabs_style_non_tablet_mode', meowSettingsEntryType.STRING, 'vertical'), // 'vertical' | 'horizontal'
  new meowSettingsEntry('bottom_avoid', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('navigation_indicator', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('effects', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('title_function_buttons', meowSettingsEntryType.STRING, '01'),
  new meowSettingsEntry('title_function_extensions', meowSettingsEntryType.BOOLEAN, 'false'),

  // Experience
  new meowSettingsEntry('sys_back_access_backward', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('esc_to_access_backward', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('max_bookmark_suggest', meowSettingsEntryType.NUMBER, '5'),
  new meowSettingsEntry('max_history_suggest', meowSettingsEntryType.NUMBER, '5'),
  new meowSettingsEntry('tabs_vertical_auto_hide', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('tabs_vertical_auto_hide_button', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('web_context_menu_enabled', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('web_context_menu_image_preview', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('web_context_menu_web_preview', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('web_context_image_width', meowSettingsEntryType.NUMBER, '300'),
  new meowSettingsEntry('web_context_web_height', meowSettingsEntryType.NUMBER, '500'),
  new meowSettingsEntry('web_context_text_strip', meowSettingsEntryType.BOOLEAN, 'false'),

  // Statuses
  new meowSettingsEntry('status_tabs_open', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('status_showing_my_windows_alias', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('status_showing_my_windows_alias_non_tablet', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('my_window_alias_position', meowSettingsEntryType.STRING, 'center'), // 'left' | 'center' | 'right'
  new meowSettingsEntry('my_window_alias_last', meowSettingsEntryType.STRING, defaultNewWindowName()), // #26

  // Continuation
  new meowSettingsEntry('continuation_auto_exit', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('continuation_auto_close_tab', meowSettingsEntryType.BOOLEAN, 'true'),

  // Keyboard shortcuts
  new meowSettingsEntry('key_shortcuts', meowSettingsEntryType.STRING_ARRAY, ''),

  // Surf
  new meowSettingsEntry('home_url', meowSettingsEntryType.STRING, ''),
  new meowSettingsEntry('new_tab_url', meowSettingsEntryType.STRING, ''),
  new meowSettingsEntry('start_up_option', meowSettingsEntryType.STRING, 'new tab'), // 'new tab' | 'home' | 'continue'
  new meowSettingsEntry('intelligent_tracking_prevention', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('enable_third_party_cookies', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('continue_tabs_count', meowSettingsEntryType.NUMBER, '0'),
  new meowSettingsEntry('continue_tabs_main_on', meowSettingsEntryType.NUMBER, '0'),
  new meowSettingsEntry('continue_tabs_sub_on', meowSettingsEntryType.NUMBER, '-1'),
  new meowSettingsEntry('last_zone', meowSettingsEntryType.STRING, ''),
  // Animation defaults
  new meowSettingsEntry('animation_response', meowSettingsEntryType.NUMBER, '36'),
  new meowSettingsEntry('animation_damping_coefficient', meowSettingsEntryType.NUMBER, '20'), // #40

  // UA & Search Engines & Homepage
  new meowSettingsEntry('custom_user_agents', meowSettingsEntryType.STRING_ARRAY, defaultUserAgents()),
  new meowSettingsEntry('custom_user_agents_selected_index', meowSettingsEntryType.NUMBER, '-1'),
  new meowSettingsEntry('custom_search_engines', meowSettingsEntryType.STRING_ARRAY, presetSearchEngines()),
  new meowSettingsEntry('custom_search_engines_selected_index', meowSettingsEntryType.NUMBER, '-1'),
  new meowSettingsEntry('homepage_shortcuts_bookmarks_dir', meowSettingsEntryType.STRING, ''),
  new meowSettingsEntry('homepage_shortcuts_init_height', meowSettingsEntryType.NUMBER, '50'),

  // Single hand accessibility
  new meowSettingsEntry('preferred_hand_left_or_right', meowSettingsEntryType.STRING, 'right'),
  new meowSettingsEntry('preferred_hand_reverse_settings_menu', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('preferred_hand_reverse_tabs_panel', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('preferred_hand_reverse_homepage_shortcuts', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('preferred_hand_auto', meowSettingsEntryType.BOOLEAN, 'false'),

  // Ad blocker
  new meowSettingsEntry('use_adblock', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('adblock_exceptions', meowSettingsEntryType.STRING_ARRAY, ''), // #53

  // JS blocker
  new meowSettingsEntry('disable_js', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('disable_js_all_sites', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('disable_js_these_sites', meowSettingsEntryType.STRING_ARRAY, ''),

  // Image blocker
  new meowSettingsEntry('disable_image', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('disable_image_all_sites', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('disable_image_these_sites', meowSettingsEntryType.STRING_ARRAY, ''),

  // Dark mode
  new meowSettingsEntry('web_force_dark_mode', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('web_force_dark_mode_exemptions', meowSettingsEntryType.STRING_ARRAY, ''),

  // Colors
  new meowSettingsEntry('color_light_primary', meowSettingsEntryType.STRING, '#E1E9E3'),
  new meowSettingsEntry('color_light_secondary', meowSettingsEntryType.STRING, '#CDD7CD'),
  new meowSettingsEntry('color_light_font', meowSettingsEntryType.STRING, '#243B24'),
  new meowSettingsEntry('color_dark_primary', meowSettingsEntryType.STRING, '#0F1A0F'),
  new meowSettingsEntry('color_dark_secondary', meowSettingsEntryType.STRING, '#2A392A'),
  new meowSettingsEntry('color_dark_font', meowSettingsEntryType.STRING, '#E1E9E3'),

  // Cached size of webview cache
  new meowSettingsEntry('webview_cache_size', meowSettingsEntryType.NUMBER, '-1'),

  // History
  new meowSettingsEntry('collect_new_history', meowSettingsEntryType.BOOLEAN, 'true'),
  new meowSettingsEntry('history_index_size', meowSettingsEntryType.NUMBER, '-1'),
  new meowSettingsEntry('history_index_load_quantity', meowSettingsEntryType.NUMBER, '6'),

  // Download
  new meowSettingsEntry('direct_download', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('direct_download_auto_open', meowSettingsEntryType.BOOLEAN, 'true'),

  // Debug
  new meowSettingsEntry('DEV_MODE', meowSettingsEntryType.BOOLEAN, 'false'), // #74
  new meowSettingsEntry('CONFIG_BUTTONS', meowSettingsEntryType.BOOLEAN, 'false'), // Forgot what this is :3
  new meowSettingsEntry('CONFIG_EXTENSIONS', meowSettingsEntryType.BOOLEAN, 'false'),
  new meowSettingsEntry('resource_monitor', meowSettingsEntryType.BOOLEAN, 'true'),
];
