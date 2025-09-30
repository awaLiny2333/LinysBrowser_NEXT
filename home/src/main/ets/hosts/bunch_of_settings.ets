import { string_to_boolean } from '../utils/data_operation_tools';
import { kv_store_get } from '../utils/kv_store_tools';
import { sandbox_read_text_sync, sandbox_save } from '../utils/storage_tools';
import { default_user_agents, preset_search_engines } from './bunch_of_defaults';

export class bunch_of_settings {
  static settings_list: settings_item[] = [];
  // Defaults
  static settings_defaults_key: string[] = [];
  static settings_defaults_type: string[] = [];
  static settings_defaults_value: string[] = [];

  /**
   * Initializes the bunch_of_settings.
   * */
  static async init() {
    // Register the default Settings

    // Customization
    bunch_of_settings.register_setting('title_bar_position', 'string', 'bottom');
    bunch_of_settings.register_setting('tabs_style', 'string', 'vertical');
    bunch_of_settings.register_setting('tabs_style_non_tablet_mode', 'string', 'vertical');

    // Experience
    bunch_of_settings.register_setting('sys_back_access_backward', 'boolean', 'true');
    bunch_of_settings.register_setting('max_bookmark_suggest', 'number', '5');
    bunch_of_settings.register_setting('max_history_suggest', 'number', '5');

    // Statuses
    bunch_of_settings.register_setting('status_tabs_open', 'boolean', 'false');

    // Continuation
    bunch_of_settings.register_setting('continuation_auto_exit', 'boolean', 'false');
    bunch_of_settings.register_setting('continuation_auto_close_tab', 'boolean', 'true');

    // Keyboard shortcuts
    bunch_of_settings.register_setting('key_shortcuts', 'string', '');

    // Surf
    bunch_of_settings.register_setting('home_url', 'string', '');
    bunch_of_settings.register_setting('new_tab_url', 'string', '');
    bunch_of_settings.register_setting('start_up_option', 'string', 'new tab');
    bunch_of_settings.register_setting('intelligent_tracking_prevention', 'boolean', 'false');
    bunch_of_settings.register_setting('continue_tabs_count', 'number', '0');
    bunch_of_settings.register_setting('continue_tabs_main_on', 'number', '0');
    bunch_of_settings.register_setting('continue_tabs_sub_on', 'number', '0');

    // Animation defaults
    bunch_of_settings.register_setting('animation_response', 'number', '36');
    bunch_of_settings.register_setting('animation_damping_coefficient', 'number', '20');

    // UA & Search Engines & Homepage
    bunch_of_settings.register_setting('custom_user_agents', 'string', default_user_agents());
    bunch_of_settings.register_setting('custom_user_agents_selected_index', 'number', '-1');
    bunch_of_settings.register_setting('custom_search_engines', 'string', preset_search_engines());
    bunch_of_settings.register_setting('custom_search_engines_selected_index', 'number', '-1');
    bunch_of_settings.register_setting('homepage_shortcuts_bookmarks_dir', 'string', '');
    bunch_of_settings.register_setting('homepage_shortcuts_init_height', 'number', '50');

    // Single hand accessibility
    bunch_of_settings.register_setting('preferred_hand_left_or_right', 'string', 'right');
    bunch_of_settings.register_setting('preferred_hand_reverse_settings_menu', 'boolean', 'true');
    bunch_of_settings.register_setting('preferred_hand_reverse_tabs_panel', 'boolean', 'true');
    bunch_of_settings.register_setting('preferred_hand_reverse_homepage_shortcuts', 'boolean', 'false');

    // Ad blocker
    bunch_of_settings.register_setting('use_adblock', 'boolean', 'true');
    bunch_of_settings.register_setting('adblock_exceptions', 'string', '');

    // JS blocker
    bunch_of_settings.register_setting('disable_js', 'boolean', 'true');
    bunch_of_settings.register_setting('disable_js_all_sites', 'boolean', 'false');
    bunch_of_settings.register_setting('disable_js_these_sites', 'string', '');

    // Image blocker
    bunch_of_settings.register_setting('disable_image', 'boolean', 'true');
    bunch_of_settings.register_setting('disable_image_all_sites', 'boolean', 'false');
    bunch_of_settings.register_setting('disable_image_these_sites', 'string', '');

    // Dark mode
    bunch_of_settings.register_setting('web_force_dark_mode', 'boolean', 'false');
    bunch_of_settings.register_setting('web_force_dark_mode_exemptions', 'string', '');

    // Colors
    bunch_of_settings.register_setting('color_light_primary', 'string', '#E1E9E3');
    bunch_of_settings.register_setting('color_light_secondary', 'string', '#CDD7CD');
    bunch_of_settings.register_setting('color_light_font', 'string', '#243B24');
    bunch_of_settings.register_setting('color_dark_primary', 'string', '#0F1A0F');
    bunch_of_settings.register_setting('color_dark_secondary', 'string', '#2A392A');
    bunch_of_settings.register_setting('color_dark_font', 'string', '#E1E9E3');

    // Cached size of webview cache
    bunch_of_settings.register_setting('webview_cache_size', 'number', '-1');

    // History
    bunch_of_settings.register_setting('collect_new_history', 'boolean', 'true');
    bunch_of_settings.register_setting('history_index_size', 'number', '-1');
    bunch_of_settings.register_setting('history_index_load_quantity', 'number', '6');

    // Download
    bunch_of_settings.register_setting('direct_download', 'boolean', 'false');
    bunch_of_settings.register_setting('direct_download_auto_open', 'boolean', 'true');

    // Debug
    bunch_of_settings.register_setting('DEV_MODE', 'boolean', 'false');
    bunch_of_settings.register_setting('resource_monitor', 'boolean', 'true');

    // Migrate
    let read = await bunch_of_settings.read_create_and_or_migration();

    if (read) {
      bunch_of_settings.import_json(read);
    }

    console.log('[Meow][bunch_of_settings] Init success!');
  }

  /**
   * Sets the corresponding value of key, and save it in the sandbox.
   * @param key A string, the key of the setting.
   * @param value A string | boolean | number, the corresponding value of key to be set.
   * */
  static set(key: string, value: string | boolean | number, save: boolean = true) {
    // Sequential search to modify that value.
    for (let index = 0; index < bunch_of_settings.settings_list.length; index++) {
      if (bunch_of_settings.settings_list[index].key == key) {
        bunch_of_settings.settings_list[index].value = value;
        break;
      }
    }

    // Save to sandbox
    if (save) {
      bunch_of_settings.save_to_disk();
    }
  }

  /**
   * Resets a setting to default value.
   * @param key A string, the key of the setting.
   * */
  static reset(key: string) {
    let index = bunch_of_settings.settings_defaults_key.indexOf(key)
    let def_value = bunch_of_settings.settings_defaults_value[index]
    let type = bunch_of_settings.settings_defaults_type[index];
    if (index >= 0) {
      if (type == 'string') {
        bunch_of_settings.set(key, def_value);
      } else if (type == 'boolean') {
        bunch_of_settings.set(key, string_to_boolean(def_value));
      } else {
        // is number
        bunch_of_settings.set(key, Number.parseFloat(def_value));
      }
    }
  }

  /**
   * Gets the corresponding value of key from settings.
   * @param key The key.
   * @returns The value.
   * */
  static get(key: string): string | number | boolean {
    let key_default_index = bunch_of_settings.settings_defaults_key.indexOf(key);
    let key_default_value = bunch_of_settings.settings_defaults_value[key_default_index];
    let type = bunch_of_settings.settings_defaults_type[key_default_index];

    // Sequential search to find that value.
    for (let index = 0; index < bunch_of_settings.settings_list.length; index++) {
      if (bunch_of_settings.settings_list[index].key == key) {
        // found
        return bunch_of_settings.settings_list[index].value;
      }
    }

    // Not found in list.
    if (type == 'string') {
      return key_default_value;
    }
    if (type == 'number') {
      return Number.parseFloat(key_default_value);
    }
    // boolean
    return string_to_boolean(key_default_value);
  }

  /**
   * Outputs a string as json result
   * @returns a string.
   * */
  static toString() {
    let result_string: string[] = [];
    for (let index = 0; index < bunch_of_settings.settings_list.length; index++) {
      const the_setting = bunch_of_settings.settings_list[index];
      result_string.push('    "' + the_setting.key + '": "' + (the_setting.value.toString()).replaceAll('\n', '\\n') + '"');
    }
    result_string.sort();
    return '{\n' + result_string.join(',\n') + '\n}';
  }

  /**
   * Saves the entire bunch_of_settings to the disk.
   * */
  static save_to_disk() {
    sandbox_save('settings.json.browsercatsettings.txt', bunch_of_settings.toString());
  }

  /**
   * Import settings from json.
   *
   * DOESN'T SAVE TO DISK!
   * @param text the json
   * */
  static import_json(text: string) {
    let jsonObject: Record<string, string> | null = null;
    if (text.length < 2) {
      return false;
    }

    try {
      jsonObject = JSON.parse(text);
    } catch (e) {
      console.log('[Meow][bunch_of_settings] Import settings failed! Json parse failed!');
      return false;
    }

    bunch_of_settings.settings_list = [];

    Object.entries(jsonObject as Record<string, string>).forEach((item) => {
      const key = item[0];
      const val = item[1];
      bunch_of_settings.import_one_kv(key, val);
    });
    console.log('[Meow][bunch_of_settings] Import settings:\n' + text);
    return true;
  }

  /**
   * Sets the corresponding value of key, and save it in settings_list.
   * @param key A string, the key of the setting.
   * @param value A string, the corresponding value of key to be set.
   * */
  static import_one_kv(key: string, value: string) {
    let key_default_index = bunch_of_settings.settings_defaults_key.indexOf(key);
    if (key_default_index == -1) {
      // unregistered setting
      console.error('[Error][Meow][bunch_of_settings][get] Unregistered setting key: ' + key);
    }
    let key_default_type = bunch_of_settings.settings_defaults_type[key_default_index];

    let typed_value: string | boolean | number = -1;
    if (key_default_type == 'number') {
      typed_value = Number.parseFloat(value);
    } else if (key_default_type == 'string') {
      typed_value = value;
    } else {
      // boolean
      typed_value = string_to_boolean(value);
    }

    // Sequential search
    for (let index = 0; index < bunch_of_settings.settings_list.length; index++) {
      if (bunch_of_settings.settings_list[index].key == key) {
        bunch_of_settings.settings_list[index].value = typed_value;
        break;
      }
    }
    bunch_of_settings.settings_list.push(new settings_item(key, typed_value));
  }

  // Private stuffs

  /**
   * Registers a setting
   * @param key A string, the key of the setting.
   * @param type A string, indicating the data type of the setting. Allow 'string' | 'number' | 'boolean'.
   * @param value A string, sets the default (initial) value of the setting.
   * @example bunch_of_settings.register_setting('sys_back_access_backward', 'boolean', 'true');
   * */
  private static register_setting(key: string, type: string, value: string) {
    bunch_of_settings.settings_defaults_key.push(key);
    bunch_of_settings.settings_defaults_type.push(type);
    bunch_of_settings.settings_defaults_value.push(value);
  }

  /**
   * Auto migrates old kv-store settings data into sandbox file.
   *
   * Generates the very first settings.json.browsercatsettings.txt too for the first launch of app.
   *
   * @returns The settings json string if read ok. Undefined if this is first launch of app, because things are already loaded.
   * */
  private static async read_create_and_or_migration() {
    let read = sandbox_read_text_sync('settings.json.browsercatsettings.txt');
    if (read == 'undefined') {
      // Need migration, load all things into bunch_of_settings.

      // Load all things
      for (let index = 0; index < bunch_of_settings.settings_defaults_key.length; index++) {
        await bunch_of_settings.get_from_kv(bunch_of_settings.settings_defaults_key[index]);
      }

      // Save to sandbox. Next time would load from sandbox.
      bunch_of_settings.save_to_disk();
      console.log('[Meow][bunch_of_settings] MIGRATION FROM KVSTORE OK!');
      return undefined;
    }
    return read;
  }

  // Legacy

  /**
   * THIS IS LEGACY CODE FOR MIGRATION ONLY
   *
   * Gets the corresponding value of key from the kvStore and stores in settings_list.
   * @param key A string, the key of the setting.
   * @returns A string | boolean | number, the corresponding value got for requested key.
   * */
  private static async get_from_kv(key: string) {
    let key_default_index = bunch_of_settings.settings_defaults_key.indexOf(key);
    let key_default_value = bunch_of_settings.settings_defaults_value[key_default_index];
    let type = bunch_of_settings.settings_defaults_type[key_default_index];

    let result: string | boolean | number;
    if (type == 'string') {
      result = await bunch_of_settings.get_settings_string(key, key_default_value);
    } else if (type == 'number') {
      result = await bunch_of_settings.get_settings_number(key, key_default_value);
    } else { // Boolean
      result = await bunch_of_settings.get_settings_boolean(key, key_default_value);
    }

    bunch_of_settings.settings_list.push(new settings_item(key, result));
  }

  /**
   * THIS IS LEGACY CODE FOR MIGRATION ONLY
   *
   * Gets the string value of a setting.
   * @param key A string, the key of the setting.
   * @param default_404_fall_back A string, who will be returned if this key is not found in KvStore.
   * @returns A string, the value of this key.
   * @returns A string, default_404_fall_back, if the key is not found in KvStore.
   * */
  private static async get_settings_string(key: string, default_404_fall_back: string) {
    let value = await kv_store_get(key);
    if (value == ('undefined')) {
      value = default_404_fall_back;
    }
    console.log('[bunch_of_settings][Uni] Got settings for ' + key + ':\n\t' + value.replaceAll('\n', '\n\t'));
    return value;
  }

  /**
   * THIS IS LEGACY CODE FOR MIGRATION ONLY
   *
   * Gets the string value of a setting.
   * @param key A string, the key of the setting.
   * @param default_404_fall_back A string, who will be returned if this key is not found in KvStore.
   * @returns A number, the value of this key.
   * @returns A number, Number.parseFloat(default_404_fall_back), if the key is not found in KvStore.
   * */
  private static async get_settings_number(key: string, default_404_fall_back: string) {
    let value = await kv_store_get(key);
    if (value == ('undefined')) {
      value = default_404_fall_back;
    }
    console.log('[bunch_of_settings][Uni] Got settings for ' + key + ': ' + value)
    return Number.parseFloat(value);
  }

  /**
   * THIS IS LEGACY CODE FOR MIGRATION ONLY
   *
   * Gets the string value of a setting.
   * @param key A string, the key of the setting.
   * @param default_404_fall_back A string, who will be returned if this key is not found in KvStore.
   * @returns A number, the value of this key.
   * @returns A boolean, string_to_boolean(default_404_fall_back), if the key is not found in KvStore.
   * */
  private static async get_settings_boolean(key: string, default_404_fall_back: string): Promise<boolean> {
    let value = await kv_store_get(key);
    if (value == ('undefined')) {
      value = default_404_fall_back;
    }
    console.log('[bunch_of_settings][Uni] Got settings for ' + key + ': ' + value)
    return string_to_boolean(value);
  }
}

class settings_item {
  key: string;
  value: string | boolean | number;

  /**
   * A settings_item item, consists of a key and its value.
   * @param key A string, the key of this setting.
   * @param value A string | boolean | number, the value of this setting.
   * */
  constructor(key: string, value: string | boolean | number) {
    this.key = key;
    this.value = value;
  }
}
