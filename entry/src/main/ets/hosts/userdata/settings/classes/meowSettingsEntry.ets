import lazy { escapeForJson } from "../scripts/helpers";

export enum meowSettingsEntryType {
  UNDEFINED = '',
  NUMBER = 'NUMBER',
  STRING = 'STRING',
  BOOLEAN = 'BOOLEAN',
  STRING_ARRAY = 'STRING_ARRAY',
  STRING_ARRAY_PAIR = 'STRING_ARRAY_PAIR',
}

@ObservedV2
export class meowSettingsEntry {
  // Non volatile ↓ These are set by the system.
  key: string = '';
  type: meowSettingsEntryType = meowSettingsEntryType.UNDEFINED;
  // Volatile ↓
  @Trace value: number | string | boolean | string[] | string[][] | undefined = undefined;

  constructor(key: string, type: meowSettingsEntryType, value: string) {
    this.key = key;
    this.type = type;
    this.setValueFromString(value);
  }

  /**
   * Sets the value of the setting entry based on the provided string.
   * @param newValue The string representation of the value.
   * @param compareMode Use compare mode or not. If set true, then
   * @returns An array containing the key, old value, and new value (if changes are made).
   */
  setValueFromString(newValue: string, compareMode: boolean = false) {
    let thisValue = '';
    let compareNewValue = '';
    if (compareMode) {
      thisValue = this.valueToString();
      compareNewValue = newValue.replaceAll('\n', '\\n');
      if (compareNewValue == thisValue) {
        // meow(`Skipped [${this.key}] - [${newValue}] because target is same as current.`, 'meowSettingsEntry][setValueFromString', meowLevel.INFO);
        return [this.key, thisValue];
      }
    }

    // Convert value according to the type value.
    switch (this.type) {
      case meowSettingsEntryType.NUMBER:
        this.value = Number(newValue);
        break;
      case meowSettingsEntryType.STRING:
        this.value = newValue;
        break;
      case meowSettingsEntryType.BOOLEAN:
        this.value = newValue === 'true';
        break;
      case meowSettingsEntryType.STRING_ARRAY:
        if (newValue) {
          this.value = newValue.split('\n').map(item => item.trim());
        } else {
          this.value = [];
        }
        // console.warn(`${this.key}, ${this.type}, ${this.value}`);
        break;
      case meowSettingsEntryType.STRING_ARRAY_PAIR:
        if (newValue) {
          const seq = newValue.split('\n').map(item => item.trim());
          const result: string[][] = [];
          for (let i = 0; i < seq.length; i += 2) {
            result.push([seq[i], seq[i + 1]]);
          }
          this.value = result;
        } else {
          this.value = [];
        }
        break;
      default:
        this.value = undefined;
    }
    
    // meow(`[${this.key}]: [${thisValue}] → [${compareNewValue}]`, 'meowSettingsEntry][setValueFromString', meowLevel.WARN);
    return [this.key, thisValue, compareNewValue];
  }

  /**
   * Converts the value to a line to be placed as an element in a key:value file.
   * @returns The line element.
   */
  toString(): string {
    return `    "${this.key}": "${this.valueToString()}"`;
  }

  /**
   * Converts the value to a string.
   * @returns The string representation in JSON compatible style of the value. Returns empty if the value is undefined.
   */
  private valueToString() {
    if (this.value === undefined) {
      return '';
    }
    switch (this.type) {
      case meowSettingsEntryType.NUMBER:
        return this.value?.toString() || '0';
      case meowSettingsEntryType.STRING:
        return this.value?.toString() || '';
      case meowSettingsEntryType.BOOLEAN:
        return this.value?.toString() || 'false';
      case meowSettingsEntryType.STRING_ARRAY:
        const escapedLines = (this.value as string[]).map(line => escapeForJson(line));
        return escapedLines.join('\\n');
      case meowSettingsEntryType.STRING_ARRAY_PAIR:
        const escapedLinesOfPairs = (this.value as string[][]).map(pair => escapeForJson(pair[0]) + '\\n' + escapeForJson(pair[1]));
        return escapedLinesOfPairs.join('\\n');
      default:
        return '';
    }
  }
}
