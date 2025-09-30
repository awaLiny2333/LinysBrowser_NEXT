import { bunch_of_settings } from './bunch_of_settings';

let function_keys = [FunctionKey.ESC, FunctionKey.F1, FunctionKey.F2, FunctionKey.F3, FunctionKey.F4, FunctionKey.F5,
  FunctionKey.F6, FunctionKey.F7, FunctionKey.F8, FunctionKey.F9, FunctionKey.F10, FunctionKey.F11, FunctionKey.F12,
  FunctionKey.TAB, FunctionKey.DPAD_UP, FunctionKey.DPAD_DOWN, FunctionKey.DPAD_LEFT, FunctionKey.DPAD_RIGHT,
];
let function_strings =
  ['esc', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12', 'tab', 'dpad_up', 'dpad_down', 'dpad_left', 'dpad_right'];
let modifier_keys = [ModifierKey.CTRL, ModifierKey.SHIFT, ModifierKey.ALT];
let modifier_strings = ['ctrl', 'shift', 'alt'];

export class bunch_of_key_shortcuts {
  // Singles
  new_tab: key_combination = new key_combination('t', [ModifierKey.CTRL]);
  close_tab: key_combination = new key_combination('w', [ModifierKey.CTRL]);
  show_tabs: key_combination = new key_combination('a', [ModifierKey.SHIFT, ModifierKey.CTRL]);
  focus_address: key_combination = new key_combination('d', [ModifierKey.ALT]);
  in_page_search: key_combination = new key_combination('f', [ModifierKey.CTRL]);
  fullscreen: key_combination = new key_combination(FunctionKey.F11);
  history: key_combination = new key_combination('h', [ModifierKey.CTRL]);
  refresh: key_combination = new key_combination(FunctionKey.F5);
  print: key_combination = new key_combination('p', [ModifierKey.CTRL]);
  // Lists
  key_shortcut_labels =
    ['new_tab', 'close_tab', 'show_tabs', 'focus_address', 'in_page_search', 'fullscreen', 'history', 'refresh', 'print'];
  key_shortcut_combinations =
    [this.new_tab, this.close_tab, this.show_tabs, this.focus_address, this.in_page_search, this.fullscreen, this.history, this.refresh, this.print];
  last_edit: number = 0;

  /**
   * A class holding key shortcuts.
   * @param no_init Will not load configuration from disk nor do anything else.
   * Usually set true if this object is only created to sit the place of StorageLink initialization.
   */
  constructor(no_init?: boolean) {
    if (no_init == true) {
      return;
    }
    this.load_from_disk();
  }

  /**
   * Gets the string[] of shortcut of a specific action.
   * @param label A string, the label of the action. e.g. 'show_tabs'.
   * @returns A string[], an array containing keys in the shortcut.
   * e.g. ['a', 'ctrl', 'shift']
   * */
  get_shortcut(label: string): string[] {
    let index = this.key_shortcut_labels.indexOf(label);
    if (index > -1) {
      return this.key_shortcut_combinations[index].to_string_array();
    } else {
      return [];
    }
  }

  /**
   * Sets the shortcut of a specific action.
   * @param label A string, the label of the action. e.g. 'show_tabs'.
   * @param key_com A string[], an array containing keys in the shortcut.
   * e.g. ['a', 'ctrl', 'shift']
   * */
  set_shortcut(label: string, key_com: string[]) {
    let index = this.key_shortcut_labels.indexOf(label);
    if (index > -1) {
      this.key_shortcut_combinations[index].load_string_array(key_com);
      this.save_to_disk();
    }
  }

  /**
   * Loads key combination settings from disk
   * */
  load_from_disk() {
    try {
      let combinations = bunch_of_settings.get('key_shortcuts') as string;
      // console.log('[bunch_of_key_shortcuts][load_from_disk] Combinations: ' + combinations);
      let keys_lines: string[] = [];
      if (combinations != '') {
        keys_lines = combinations.split('\n');
        for (let index = 0; index < keys_lines.length; index++) {
          if (this.key_shortcut_combinations[index]) {
            this.key_shortcut_combinations[index].load_string(keys_lines[index]);
          }
        }
      }
    } catch (e) {
      console.error('[bunch_of_key_shortcuts][load_from_disk] ' + e);
    }
    this.last_edit = Date.now();
  }

  /**
   * Saves current key combination settings to disk
   * */
  save_to_disk() {
    let list: string[] = [];
    for (let index = 0; index < this.key_shortcut_combinations.length; index++) {
      list.push(this.key_shortcut_combinations[index].toString());
    }
    bunch_of_settings.set('key_shortcuts', list.join('\n'));
    this.last_edit = Date.now();
  }
}

class key_combination {
  main_key: string | FunctionKey = '';
  modifier: Array<ModifierKey> = [];

  /**
   * An object holding a key combination,
   * which consists of a main key and some modifier keys,
   * if the main key isn't a function key.
   * @param main A string or FunctionKey
   * @param mod A ModifierKey[]
   * */
  constructor(main?: string | FunctionKey, mod?: Array<ModifierKey>) {
    if (main) {
      this.main_key = main;
    }
    if (mod) {
      this.modifier = mod;
    }
  }

  /**
   * @returns A string[], the key combination.
   * e.g. ['a', 'ctrl', 'shift']
   * */
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

  /**
   * @returns A string, the key combination.
   * e.g. 'a ctrl shift'
   * */
  toString() {
    return this.to_string_array().join(' ');
  }

  /**
   * Loads a string array as a key combination, OVERWRITING whatever this combination was.
   * @param combination A string[], containing the keys.
   * e.g. ['a', 'ctrl', 'shift']
   * */
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

  /**
   * Loads a string as a key combination, OVERWRITING whatever this combination was.
   * @param combination A string, containing the keys.
   * e.g. 'a ctrl shift'
   * */
  load_string(combination: string) {
    if (combination == '') {
      return;
    }
    let keys_split = combination.split(' ');
    this.load_string_array(keys_split);
  }
}
