import { bunch_of_settings } from './bunch_of_settings';

let function_keys =
  [FunctionKey.ESC, FunctionKey.F1, FunctionKey.F2, FunctionKey.F3, FunctionKey.F4, FunctionKey.F5,
    FunctionKey.F6, FunctionKey.F7, FunctionKey.F8, FunctionKey.F9, FunctionKey.F10, FunctionKey.F11, FunctionKey.F12,
    FunctionKey.TAB, FunctionKey.DPAD_UP, FunctionKey.DPAD_DOWN, FunctionKey.DPAD_LEFT, FunctionKey.DPAD_RIGHT,
  ];
let function_strings =
  ['esc', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12', 'tab', 'dpad_up', 'dpad_down',
    'dpad_left', 'dpad_right'];
let modifier_keys = [ModifierKey.CTRL, ModifierKey.SHIFT, ModifierKey.ALT];
let modifier_strings = ['ctrl', 'shift', 'alt'];

export class bunch_of_key_shortcuts {
  new_tab: key_combination = new key_combination('t', [ModifierKey.CTRL]);
  close_tab: key_combination = new key_combination('w', [ModifierKey.CTRL]);
  show_tabs: key_combination = new key_combination('a', [ModifierKey.SHIFT, ModifierKey.CTRL]);
  focus_address: key_combination = new key_combination('d', [ModifierKey.ALT]);
  in_page_search: key_combination = new key_combination('f', [ModifierKey.CTRL]);
  fullscreen: key_combination = new key_combination(FunctionKey.F11);
  history: key_combination = new key_combination('h', [ModifierKey.CTRL]);
  key_shortcut_labels =
    ['new_tab', 'close_tab', 'show_tabs', 'focus_address', 'in_page_search', 'fullscreen', 'history'];
  key_shortcut_combinations =
    [this.new_tab, this.close_tab, this.show_tabs, this.focus_address, this.in_page_search, this.fullscreen,
      this.history];

  constructor(no_init?: boolean) {
    if (no_init == true) {
      return;
    }
    this.load_from_disk();
  }

  get_shortcut(label: string): string[] {
    let index = this.key_shortcut_labels.indexOf(label);
    if (index > -1) {
      return this.key_shortcut_combinations[index].to_string_array();
    } else {
      return [];
    }
  }

  set_shortcut(label: string, key_com: string[]) {
    let index = this.key_shortcut_labels.indexOf(label);
    if (index > -1) {
      this.key_shortcut_combinations[index].load_string_array(key_com);
      this.save_to_disk();
    }
  }

  /**
   * Load key combination settings from disk
   * */
  async load_from_disk() {
    let sites_got = await (AppStorage.get('bunch_of_settings') as bunch_of_settings).get('key_shortcuts') as string;
    let keys_lines: string[] = []
    if (sites_got != '') {
      keys_lines = sites_got.split('\n');
      for (let index = 0; index < keys_lines.length; index++) {
        if (this.key_shortcut_combinations[index]) {
          this.key_shortcut_combinations[index].load_string(keys_lines[index])
        }
      }
    }
  }

  /**
   * Saves current key combination settings to disk
   * */
  save_to_disk() {
    let list: string[] = [];
    for (let index = 0; index < this.key_shortcut_combinations.length; index++) {
      list.push(this.key_shortcut_combinations[index].toString());
    }
    (AppStorage.get('bunch_of_settings') as bunch_of_settings).set('key_shortcuts', list.join('\n'));
  }
}

class key_combination {
  main_key: string | FunctionKey = '';
  modifier: Array<ModifierKey> = [];

  constructor(main?: string | FunctionKey, mod?: Array<ModifierKey>) {
    if (main) {
      this.main_key = main;
    }
    if (mod) {
      this.modifier = mod;
    }
  }

  to_string_array() {
    let result: string[] = [];
    if (typeof this.main_key == 'string') {
      result.push(this.main_key);
    } else {
      result.push(function_strings[function_keys.indexOf(this.main_key)]);
    }
    for (let index = 0; index < this.modifier.length; index++) {
      result.push(modifier_strings[modifier_keys.indexOf(this.modifier[index])]);
    }
    return result;
  }

  toString() {
    return this.to_string_array().join(' ');
  }

  load_string_array(combination: string[]) {
    if (combination.length == 0) {
      return;
    }
    // clear modifiers
    this.modifier.splice(0, this.modifier.length);
    // determine modifiers
    for (let index = 0; index < combination.length; index++) {
      let key_str = combination[index];
      if (modifier_strings.includes(key_str)) {
        // Is a modifier
        let modifier_index = modifier_strings.indexOf(key_str);
        this.modifier.push(modifier_keys[modifier_index]);
      } else if (function_strings.includes(key_str)) {
        // Is a function key
        let index_of_first_key = function_strings.indexOf(key_str);
        this.main_key = function_keys[index_of_first_key];
      } else {
        // Is a normal letter
        this.main_key = key_str;
      }
    }
  }

  load_string(combination: string) {
    if (combination == '') {
      return;
    }
    let keys_split = combination.split(' ');
    this.load_string_array(keys_split);
  }
}