import { isModifier, keyDisplay, modifiersToStrings, stringsToModifiers, stringToValue, valueToString } from "../scripts/helpers";

@ObservedV2
export class meowKeyBind {
  @Trace value: string | FunctionKey;
  @Trace keys: ModifierKey[];

  constructor(value: string | FunctionKey, keys: ModifierKey[]) {
    this.value = value;
    this.keys = keys;
  }

  /**
   * To string for pure demonstration.
   * @returns A string representing the keybind.
   */
  toString() {
    if (this.keys.length > 0) {
      return `${modifiersToStrings(this.keys).join(' + ')} [${keyDisplay(valueToString(this.value))}]`;
    }
    return `[${keyDisplay(valueToString(this.value))}]`;
  }

  /**
   * Convert this keybind to an array of strings.
   * @returns An array of strings representing the keybind.
   */
  toArray() {
    return modifiersToStrings(this.keys).concat(valueToString(this.value));
  }

  /**
   * Convert an array of strings to a keybind.
   * @param array The array.
   */
  fromArray(array: string[]) {
    // find value
    // The rest are modifiers.
    const modifiers: string[] = [];
    let value: string | undefined;

    array.forEach(element => {
      if (isModifier(element)) {
        modifiers.push(element);
      } else {
        value = element;
      }
    });

    // Set
    if (value) {
      this.value = stringToValue(value);
    }
    this.keys = stringsToModifiers(modifiers);
  }
}
