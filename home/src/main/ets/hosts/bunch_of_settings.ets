import { kv_store_get, kv_store_put } from '../utils/kv_store_tools';
import { preset_search_engines, default_user_agents } from './bunch_of_defaults';

export class bunch_of_settings {
  settings_list: settings_item[] = [];
  // Defaults
  settings_defaults_key: string[] = [];
  settings_defaults_type: string[] = [];
  settings_defaults_value: string[] = [];

  /**
   * A class holding a settings_list[] array, in which there stores settings_list objects.
   * Provides get and set functions to access app settings.
   * @param no_init Will not register default settings nor do anything else.
   * Usually set true if this object is only created to sit the place of StorageLink initialization.
   */
  constructor(no_init?: boolean) {
    if (no_init == true) {
      return;
    }
    // Register the default Settings

    // Customization
    this.register_setting('title_bar_position', 'string', 'bottom');
    this.register_setting('collect_new_history', 'boolean', 'true');
    this.register_setting('intelligent_tracking_prevention', 'boolean', 'false');
    this.register_setting('tabs_style', 'string', 'vertical');
    this.register_setting('tabs_style_non_tablet_mode', 'string', 'vertical');
    this.register_setting('sys_back_access_backward', 'boolean', 'true');
    this.register_setting('max_bookmark_suggest', 'number', '5');
    this.register_setting('max_history_suggest', 'number', '5');

    // Statuses
    this.register_setting('status_tabs_open', 'boolean', 'false');

    // Keyboard shortcuts
    this.register_setting('key_shortcuts', 'string', '');

    // General defaults
    this.register_setting('home_url', 'string', '');
    this.register_setting('new_tab_url', 'string', '');
    this.register_setting('start_up_option', 'string', 'new tab');

    // Animation defaults
    this.register_setting('animation_response', 'number', '36');
    this.register_setting('animation_damping_coefficient', 'number', '20');

    // UA and Search Engines and Homepage Shortcuts
    this.register_setting('custom_user_agents', 'string', default_user_agents());
    this.register_setting('custom_user_agents_selected_index', 'number', '-1');
    this.register_setting('custom_search_engines', 'string', preset_search_engines());
    this.register_setting('custom_search_engines_selected_index', 'number', '-1');
    this.register_setting('homepage_shortcuts', 'string', '');
    this.register_setting('homepage_shortcuts_left_or_right', 'string', 'right');

    // Ad blocker
    this.register_setting('use_adblock', 'boolean', 'true');
    this.register_setting('adblock_exceptions', 'string', '');

    // JS blocker
    this.register_setting('disable_js', 'boolean', 'true');
    this.register_setting('disable_js_all_sites', 'boolean', 'false');
    this.register_setting('disable_js_these_sites', 'string', '');

    // Image blocker
    this.register_setting('disable_image', 'boolean', 'true');
    this.register_setting('disable_image_all_sites', 'boolean', 'false');
    this.register_setting('disable_image_these_sites', 'string', '');

    // Dark mode
    this.register_setting('web_force_dark_mode', 'boolean', 'false');

    // Colors
    this.register_setting('color_light_primary', 'string', '#E1E9E3');
    this.register_setting('color_light_secondary', 'string', '#CDD7CD');
    this.register_setting('color_light_font', 'string', '#243B24');
    this.register_setting('color_dark_primary', 'string', '#0F1A0F');
    this.register_setting('color_dark_secondary', 'string', '#2A392A');
    this.register_setting('color_dark_font', 'string', '#E1E9E3');

    // Cached size of webview cache
    this.register_setting('webview_cache_size', 'number', '-1');
    console.log('[Meow][bunch_of_settings] Init success!')
  }

  /**
   * Gets the corresponding value of key.
   *
   * Retrieve from the settings_list cache if this key is already read from KvStore.
   *
   * Otherwise read from KvStore and cache it in the settings_list.
   * @param key A string, the key of the setting.
   * @returns A string | boolean | number, the corresponding value got for requested key.
   * @returns 'unregistered' if the requested key is not registered.
   * */
  async get(key: string) {
    for (let index = 0; index < this.settings_list.length; index++) {
      if (this.settings_list[index].key == key) {
        return this.settings_list[index].value;
      }
    }

    // if not found in read cached results.
    let key_default_index = this.settings_defaults_key.indexOf(key);
    if (key_default_index == -1) {
      // unregistered setting
      console.error('[Error][Meow][bunch_of_settings][get] Unregistered setting key: ' + key);
      return 'unregistered';
    }
    let key_default_value = this.settings_defaults_value[key_default_index];
    let key_default_type = this.settings_defaults_type[key_default_index];

    let result: string | boolean | number;
    if (key_default_type == 'string') {
      result = await this.get_settings_string(key, key_default_value);
    } else if (key_default_type == 'number') {
      result = await this.get_settings_number(key, key_default_value);
    } else { // Boolean
      result = await this.get_settings_boolean(key, key_default_value);
    }

    let item: settings_item = new settings_item(key, result);
    this.settings_list.push(item);
    return result;
  }

  /**
   * Sets the corresponding value of key, and save it in the KvStore.
   * @param key A string, the key of the setting.
   * @param value A string | boolean | number, the corresponding value of key to be set.
   * @returns true if success.
   * @returns false if fails, perhaps due to an unregistered setting key.
   * */
  set(key: string, value: string | boolean | number) {
    let key_default_index = this.settings_defaults_key.indexOf(key);
    if (key_default_index == -1) {
      // unregistered setting
      console.error('[Error][Meow][bunch_of_settings][get] Unregistered setting key: ' + key);
      return false;
    }
    let key_default_type = this.settings_defaults_type[key_default_index];

    // Sequential search
    for (let index = 0; index < this.settings_list.length; index++) {
      if (this.settings_list[index].key == key) {
        this.settings_list[index].value = value;
        break;
      }
    }

    // Save to KvStore
    if (key_default_type == 'string') {
      kv_store_put(key, value as string);
    } else if (key_default_type == 'number') {
      kv_store_put(key, value.toString());
    } else if (key_default_type == 'boolean') {
      kv_store_put(key, this.boolean_to_string(value as boolean));
    }
    return true;
  }

  /**
   * Resets a setting to default value.
   * @param key A string, the key of the setting.
   * */
  reset(key: string) {
    let index = this.settings_defaults_key.indexOf(key)
    let def_value = this.settings_defaults_value[index]
    if (index >= 0) {
      this.set(key, def_value);
    }
  }

  /**
   * Registers a setting
   * @param key A string, the key of the setting.
   * @param type A string, indicating the data type of the setting. Allow 'string' | 'number' | 'boolean'.
   * @param value A string, sets the default (initial) value of the setting.
   * @example this.register_setting('sys_back_access_backward', 'boolean', 'true');
   * */
  private register_setting(key: string, type: string, value: string) {
    this.settings_defaults_key.push(key);
    this.settings_defaults_type.push(type);
    this.settings_defaults_value.push(value);
  }

  /**
   * Gets the string value of a setting.
   * @param key A string, the key of the setting.
   * @param default_404_fall_back A string, who will be returned if this key is not found in KvStore.
   * @returns A string, the value of this key.
   * @returns A string, default_404_fall_back, if the key is not found in KvStore.
   * */
  private async get_settings_string(key: string, default_404_fall_back: string) {
    let value = await kv_store_get(key);
    if (value == ('undefined')) {
      value = default_404_fall_back;
    }
    console.log('[Meow][bunch_of_settings][Uni] Got settings for ' + key + ': ' + value)
    return value;
  }

  /**
   * Gets the string value of a setting.
   * @param key A string, the key of the setting.
   * @param default_404_fall_back A string, who will be returned if this key is not found in KvStore.
   * @returns A number, the value of this key.
   * @returns A number, Number.parseFloat(default_404_fall_back), if the key is not found in KvStore.
   * */
  private async get_settings_number(key: string, default_404_fall_back: string) {
    let value = await kv_store_get(key);
    if (value == ('undefined')) {
      value = default_404_fall_back;
    }
    console.log('[Meow][bunch_of_settings][Uni] Got settings for ' + key + ': ' + value)
    return Number.parseFloat(value);
  }

  /**
   * Gets the string value of a setting.
   * @param key A string, the key of the setting.
   * @param default_404_fall_back A string, who will be returned if this key is not found in KvStore.
   * @returns A number, the value of this key.
   * @returns A boolean, string_to_boolean(default_404_fall_back), if the key is not found in KvStore.
   * */
  private async get_settings_boolean(key: string, default_404_fall_back: string): Promise<boolean> {
    let value = await kv_store_get(key);
    if (value == ('undefined')) {
      value = default_404_fall_back;
    }
    console.log('[Meow][bunch_of_settings][Uni] Got settings for ' + key + ': ' + value)
    return this.string_to_boolean(value);
  }

  /**
   * Converts a boolean to string.
   * @param bool A boolean.
   * @returns A string form of the boolean: 'true' | 'false'.
   * */
  private boolean_to_string(bool: boolean) {
    return bool ? 'true' : 'false';
  }

  /**
   * Converts a boolean to string.
   * @param str A string form of the boolean: 'true' | 'false'.
   * @returns A boolean, true if the str is exactly 'true'.
   * @returns A boolean, false if otherwise.
   * */
  private string_to_boolean(str: string) {
    return (str == 'true') ? true : false;
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
