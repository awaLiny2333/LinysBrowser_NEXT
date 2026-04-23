/**
 * Converts a string representation of a value key into `FunctionKey` constant, if applicable.
 * @param key The raw string value.
 * @returns The filtered result of the key value.
 */
export function stringToValue(key: string): string | FunctionKey {
  // Ensure case insensitive
  key = key.toLowerCase();
  // Do it.
  if (key === 'f1') return FunctionKey.F1;
  if (key === 'f2') return FunctionKey.F2;
  if (key === 'f3') return FunctionKey.F3;
  if (key === 'f4') return FunctionKey.F4;
  if (key === 'f5') return FunctionKey.F5;
  if (key === 'f6') return FunctionKey.F6;
  if (key === 'f7') return FunctionKey.F7;
  if (key === 'f8') return FunctionKey.F8;
  if (key === 'f9') return FunctionKey.F9;
  if (key === 'f10') return FunctionKey.F10;
  if (key === 'f11') return FunctionKey.F11;
  if (key === 'f12') return FunctionKey.F12;
  if (key === 'esc') return FunctionKey.ESC;
  if (key === 'dpad_right') return FunctionKey.DPAD_RIGHT;
  if (key === 'dpad_left') return FunctionKey.DPAD_LEFT;
  if (key === 'dpad_up') return FunctionKey.DPAD_UP;
  if (key === 'dpad_down') return FunctionKey.DPAD_DOWN;
  if (key === 'tab') return FunctionKey.TAB;
  return key;
}

/**
 * Converts a value into absolute string.
 * @param value The value to convert.
 * @returns The absolute string representation of the value.
 */
export function valueToString(value: string | FunctionKey) {
  if (typeof value === 'string') return value.toUpperCase();
  switch (value) {
    case FunctionKey.F1: return 'F1';
    case FunctionKey.F2: return 'F2';
    case FunctionKey.F3: return 'F3';
    case FunctionKey.F4: return 'F4';
    case FunctionKey.F5: return 'F5';
    case FunctionKey.F6: return 'F6';
    case FunctionKey.F7: return 'F7';
    case FunctionKey.F8: return 'F8';
    case FunctionKey.F9: return 'F9';
    case FunctionKey.F10: return 'F10';
    case FunctionKey.F11: return 'F11';
    case FunctionKey.F12: return 'F12';
    case FunctionKey.ESC: return 'ESC';
    case FunctionKey.DPAD_RIGHT: return 'DPAD_RIGHT';
    case FunctionKey.DPAD_LEFT: return 'DPAD_LEFT';
    case FunctionKey.DPAD_UP: return 'DPAD_UP';
    case FunctionKey.DPAD_DOWN: return 'DPAD_DOWN';
    case FunctionKey.TAB: return 'TAB';
    default: return value.toString();
  }
}

/**
 * Checks if a given key is a modifier key.
 * @param key The key to check.
 * @returns True if the key is a modifier key, false otherwise.
 */
export function isModifier(key: string) {
  return key.toUpperCase() === 'CTRL' || key.toUpperCase() === 'SHIFT' || key.toUpperCase() === 'ALT';
}

/**
 * Checks if a given key is a function key.
 * @param key The key to check.
 * @returns True if the key is a function key, false otherwise.
 */
export function isFn(key: string) {
  return key.length > 1 && key.toUpperCase().startsWith('F');
}

/**
  * Converts a string representation of a modifier key into the HarmonyOS `ModifierKey` constant.
  *
  * This function is case-insensitive. If an unrecognized string is passed, it safely
  * returns `ModifierKey.NONE` to prevent unexpected side effects during subsequent
  * keyboard event bitwise operations.
  *
  * @param raw - The raw modifier key string (e.g., "ctrl", "shift", "alt").
  * @returns The corresponding `ModifierKey` enum value. Returns `undefined` if no match is found.
  *
  * @example
  * `toModifier(“CTRL”); // Returns ModifierKey.CTRL
  * toModifier(“SHIFT”); // Returns ModifierKey.SHIFT
  * toModifier(“ALT”); // Returns ModifierKey.ALT
  * toModifier(“UNKNOWN”); // Returns undefined`
  */
function stringToModifier(raw: string): ModifierKey | undefined {
  const key = raw.toUpperCase();

  const modifierMap: Record<string, ModifierKey> = {
    'CTRL': ModifierKey.CTRL,
    'SHIFT': ModifierKey.SHIFT,
    'ALT': ModifierKey.ALT,
  };
  // meow(raw, 'toModifier');
  // meow(modifierMap[key].toString(), 'toModifier');
  return modifierMap[key] ?? undefined;
}

/**
 * Converts a string array of modifier keys into an array of HarmonyOS `ModifierKey` constants.
 *
 * @param raws - The array of raw modifier key strings (e.g., ["ctrl", "shift"]).
 * @returns The array of corresponding `ModifierKey` enum values. Returns an empty array if no match is found.
 *
 * @example
 * `toModifiers(["Ctrl", "Shift"]); // Returns [ModifierKey.CTRL, ModifierKey.SHIFT]
 * toModifiers(["ALT"]); // Returns [ModifierKey.ALT]
 * toModifiers(["unknown"]); // Returns []
 */
export function stringsToModifiers(raws: string[]) {
  const result: ModifierKey[] = [];
  for (let index = 0; index < raws.length; index++) {
    const modifier = stringToModifier(raws[index]);
    if (modifier != undefined) {
      result.push(modifier);
    }
  }
  return result;
}

/**
 * Converts a modifier key into absolute string.
 * @param mod The modifier key to convert.
 * @returns The absolute string representation of the modifier key.
 */
function modifierToString(mod: ModifierKey) {
  switch (mod) {
    case ModifierKey.CTRL: return 'CTRL';
    case ModifierKey.SHIFT: return 'SHIFT';
    case ModifierKey.ALT: return 'ALT';
    default: return mod.toString();
  }
}

/**
 * Converts an array of modifier keys into an array of absolute string representations.
 * @param mods The array of modifier keys to convert.
 * @returns The array of absolute string representations of the modifier keys.
 */
export function modifiersToStrings(mods: ModifierKey[]) {
  return mods.map(modifierToString);
}

/**
 * Gets the "face" value of a key, for example "DPAD_UP" => "↑".
 * @param key The raw key.
 */
export function keyDisplay(key: string) {
  key = key.toUpperCase();
  switch (key) {
    case 'DPAD_UP':
      return '↑';
    case 'DPAD_DOWN':
      return '↓';
    case 'DPAD_LEFT':
      return '←';
    case 'DPAD_RIGHT':
      return '→';
    default:
      return key;
  }
}