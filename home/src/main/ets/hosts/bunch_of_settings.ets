import { kv_store_get, kv_store_put } from '../utils/kv_store_tools';

export class bunch_of_settings {
  settings_list: settings_item[] = [];
  // Defaults
  // These codes are dumb :(((((
  settings_defaults_key: string[] =
    ['settings_title_bar_position', 'settings_max_bookmark_suggestions', 'settings_max_history_suggestions',
      'settings_collect_new_history', 'home_url', 'new_tab_url', 'start_up_option', 'custom_user_agents',
      'custom_user_agents_selected_index', 'animation_response', 'animation_damping_coefficient',
      'custom_search_engines', 'custom_search_engines_selected_index',
      'settings_tabs_style', 'settings_tabs_open'];
  settings_defaults_value: string[] =
    ['bottom', '5', '5', 'true', '', '', 'new tab', '', '-1', '36', '20', '', '-1', 'vertical', 'false'];
  settings_defaults_type: string[] =
    ['string', 'number', 'number', 'boolean', 'string', 'string', 'string', 'string', 'number', 'number', 'number',
      'string', 'number', 'string', 'boolean'];

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
    } else { // Boolean
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