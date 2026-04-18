import lazy { escapeForJson } from "../scripts/helpers";

export enum meowSettingsEntryType {
  UNDEFINED = -1,
  NUMBER = 0,
  STRING = 1,
  BOOLEAN = 2,
  STRING_ARRAY = 3,
  STRING_ARRAY_PAIR = 4,
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
   * @param value The string representation of the value.
   */
  setValueFromString(value: string) {
    // Convert value according to the type value.
    switch (this.type) {
      case meowSettingsEntryType.NUMBER:
        this.value = Number(value);
        break;
      case meowSettingsEntryType.STRING:
        this.value = value;
        break;
      case meowSettingsEntryType.BOOLEAN:
        this.value = value === 'true';
        break;
      case meowSettingsEntryType.STRING_ARRAY:
        if (value) {
          this.value = value.split('\n').map(item => item.trim());
        } else {
          this.value = [];
        }
        break;
      case meowSettingsEntryType.STRING_ARRAY_PAIR:
        if (value) {
          const seq = value.split('\n').map(item => item.trim());
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
   * @returns The string representation in JSON compatible style of the value.
   */
  private valueToString() {
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
