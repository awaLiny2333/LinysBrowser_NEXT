import { kv_store_get, kv_store_put } from '../utils/kv_store_tools';
import { default_search_engines, default_user_agents } from './bunch_of_defaults';

export class bunch_of_settings {
  settings_list: settings_item[] = [];
  // Defaults
  settings_defaults_key: string[] = [];
  settings_defaults_type: string[] = [];
  settings_defaults_value: string[] = [];

  constructor() {
    // Settings
    this.add_setting('settings_title_bar_position', 'string', 'bottom');
    this.add_setting('settings_max_bookmark_suggestions', 'number', '5');
    this.add_setting('settings_max_history_suggestions', 'number', '5');
    this.add_setting('settings_collect_new_history', 'boolean', 'true');
    this.add_setting('settings_tabs_style', 'string', 'vertical');
    this.add_setting('settings_tabs_open', 'boolean', 'false');
    this.add_setting('sys_back_to_access_backward', 'boolean', 'true');

    this.add_setting('home_url', 'string', '');
    this.add_setting('new_tab_url', 'string', '');
    this.add_setting('start_up_option', 'string', 'new tab');
    this.add_setting('animation_response', 'number', '36');
    this.add_setting('animation_damping_coefficient', 'number', '20');

    this.add_setting('custom_user_agents', 'string', default_user_agents());
    this.add_setting('custom_user_agents_selected_index', 'number', '-1');
    this.add_setting('custom_search_engines', 'string', default_search_engines());
    this.add_setting('custom_search_engines_selected_index', 'number', '-1');

    this.add_setting('use_adblock', 'boolean', 'true');
    this.add_setting('adblock_exceptions', 'string', '');
  }

  async get_setting_key(key: string) {
    for (let index = 0; index < this.settings_list.length; index++) {
      if (this.settings_list[index].key == key) {
        return this.settings_list[index].value;
      }
    }
    // if not found
    let key_default_index = this.settings_defaults_key.indexOf(key);
    let key_default_value = this.settings_defaults_value[key_default_index];
    let key_default_type = this.settings_defaults_type[key_default_index];
    let result: string | boolean | number;
    if (key_default_type == 'string') {
      result = await this.get_settings_string(key, key_default_value);
    } else if (key_default_type == 'number') {
      result = await this.get_settings_number(key, key_default_value);
    } else {
      // Boolean
      result = await this.get_settings_boolean(key, key_default_value);
    }
    let item: settings_item = new settings_item(key, result);
    this.settings_list.push(item);
    return result;
  }

  set_setting_value_of_key(key: string, value: string | boolean | number) {
    let key_default_index = this.settings_defaults_key.indexOf(key);
    let key_default_type = this.settings_defaults_type[key_default_index];
    // Sequential search
    for (let index = 0; index < this.settings_list.length; index++) {
      if (this.settings_list[index].key == key) {
        if (this.settings_list[index].value == value) {
          // No change
          return;
        }
        this.settings_list[index].value = value;
        break;
      }
    }
    // Save
    if (key_default_type == 'string') {
      kv_store_put(key, value as string);
    } else if (key_default_type == 'number') {
      kv_store_put(key, value.toString());
    } else if (key_default_type == 'boolean') {
      kv_store_put(key, this.boolean_to_string(value as boolean));
    }
  }

  private add_setting(name: string, type: string, value: string) {
    this.settings_defaults_key.push(name);
    this.settings_defaults_type.push(type);
    this.settings_defaults_value.push(value);
  }

  private async get_settings_string(key: string, default_404_fall_back: string) {
    let value = await kv_store_get(key);
    console.log('[Meow][bunch_of_settings][Uni] Got settings for ' + key + ': ' + value)
    if (value == ('undefined')) {
      // First open
      kv_store_put(key, default_404_fall_back);
      value = default_404_fall_back;
    }
    return value;
  }

  private async get_settings_number(key: string, default_404_fall_back: string) {
    let value = await kv_store_get(key);
    console.log('[Meow][bunch_of_settings][Uni] Got settings for ' + key + ': ' + value)
    if (value == ('undefined')) {
      // First open
      kv_store_put(key, default_404_fall_back);
      value = default_404_fall_back;
    }
    return Number.parseFloat(value);
  }

  private async get_settings_boolean(key: string, default_404_fall_back: string) {
    let value = await kv_store_get(key);
    console.log('[Meow][bunch_of_settings][Uni] Got settings for ' + key + ': ' + value)
    if (value == ('undefined')) {
      // First open
      kv_store_put(key, default_404_fall_back);
      value = default_404_fall_back;
    }
    if (value == 'true') {
      return true;
    }
    return false;
  }

  private boolean_to_string(bool: boolean) {
    if (bool) {
      return 'true';
    } else {
      return 'false';
    }
  }
}

class settings_item {
  key: string;
  value: string | boolean | number;

  constructor(key: string, value: string | boolean | number) {
    this.key = key;
    this.value = value;
  }
}