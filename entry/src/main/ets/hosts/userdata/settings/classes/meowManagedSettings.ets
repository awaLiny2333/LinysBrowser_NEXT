/**
 * Settings.
 * Use hard-coded indices to access entries in settingsData to boost efficiency.
 *
 * For entries of type STRING, BOOLEAN and NUMBER, they can be directly modified by
 * `this.mySettings.setByIndex(idx, newValue)`.
 * This would do all things needed from verifying to saving to disk.
 *
 * For type STRING_ARRAY, extracting the `meowSettingsEntry.value` out as one variable
 * is a good practice, as they are expected to be used frequently, and in many cases,
 * we need to access a certain element in the array.
 *
 * @see ets/components/developers/settings/SimpleSettingsExample.ets for recommended practices.
 */

import lazy { fastbuffer } from "@kit.ArkTS";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { readArrayBufferConcurrent, saveHybrid } from "../../../../catstypicalframework/utils/storage";
import lazy { defaultSettingsEntries } from "../scripts/defaultSettingsEntries";
import lazy { settingsParserJSON } from "../scripts/helpers";
import { meowSettingsEntry, meowSettingsEntryType } from "./meowSettingsEntry";

@ObservedV2
export class meowManagedSettings {
  settingsFileSavePath: string;
  settingsData: meowSettingsEntry[] = defaultSettingsEntries;
  @Trace timeoutIdSaveToDisk: number | undefined;
  @Trace ready: boolean = false;
  @Trace prebuiltReadOnly: string = ''; // For showcase, READ ONLY.

  /**
   * Constructor of this managed settings.
   * @param settingsFileSavePath The path to SAVE the settings file in each this.saveToDisk() call.
   * It is totally not related to the one passed to this.initFrom() function.
   */
  constructor(settingsFileSavePath: string) {
    this.settingsFileSavePath = settingsFileSavePath;
  }

  /**
   * Init from settings file.
   * @param settingsFilePath The path to the settings file. If the file doesn't exist, then nothing would happen.
   * @returns true if success, false if failed.
   *
   * @author ChatGLM @ Apr 4, modified by awa_Liny.
   */
  async initFrom(settingsFilePath: string) {
    let settingsText: string = '';
    const startTime = Date.now();

    try {
      settingsText = fastbuffer.from(await readArrayBufferConcurrent(settingsFilePath)).toString();
      meow(`Read settingsText from ${settingsFilePath} (${Date.now() - startTime} ms)`, 'meowSettings][initFrom', meowLevel.INFO);
      this.prebuiltReadOnly = settingsText; // Sets prebuiltReadOnly with the directly read settingsText for showcase.
    } catch (e) {
      meow(`Load settings file from ${settingsFilePath} failed: ${e}`, 'meowSettings][initFrom', meowLevel.ERROR);
      this.ready = true;
      return false;
    }

    if (!settingsText) {
      meow(`Returned earlier if settingsText is undefined or empty (no file loaded). Would this ever happen? :O`, 'meowSettings][initFrom', meowLevel.WARN);
      this.ready = true;
      return false;
    }

    // Parse and load

    // 1. Parse the JSON string into a Record<string, string>
    const kvObj = settingsParserJSON(settingsText);

    // 2. Traverse the default configuration array
    for (let i = 0; i < this.settingsData.length; i++) {
      const entry: meowSettingsEntry = this.settingsData[i];

      // 3. Directly search for the key in jsonObj
      // Looking up by string key in Record<string, string> is an O(1) operation, very fast
      let jsonValue: string | undefined = kvObj[entry.key];
      // Use !== undefined to check if the key exists
      if (jsonValue !== undefined) {
        // Only update if this configuration is present in the JSON
        entry.setValueFromString(jsonValue);
      }
    }

    meow(`Loaded settings from ${settingsFilePath} (${Date.now() - startTime} ms)`, 'meowSettings][initFrom', meowLevel.INFO);
    this.ready = true;
    return settingsText;
  }

  /**
   * Set a setting by index in an easier way (get lazy!).
   * Including: Check if the index is out of range, if the value is the same as the current value & if the type is mismatched.
   *
   * Timeout for requestSaveToDisk is by default 250 ms for BOOLEAN and 500 ms for the rest.
   *
   * @tutorial Does NOT accept arrays of strings. You should directly get the .value as string[] and directly modify its contents.
   * @param index The index of the setting to set.
   * @param value The value to set.
   */
  setByIndex(index: number, value: string | number | boolean) {
    if (index < 0 || index >= this.settingsData.length) {
      meow(`Rejected. Index out of range`, 'meowSettings][set', meowLevel.WARN);
      return;
    }
    if (this.settingsData[index].value == value) {
      return;
    } // Reject for a not changing value. Note that this may be not correct for arrays!
    let timeout: number = 500;
    const type = this.settingsData[index].type;
    switch (type) {
      case meowSettingsEntryType.STRING:
        if (typeof value !== 'string') {
          meow(`Rejected. Type mismatch`, 'meowSettings][set', meowLevel.WARN);
          return;
        }
        break;
      case meowSettingsEntryType.NUMBER:
        if (typeof value !== 'number') {
          meow(`Rejected. Type mismatch`, 'meowSettings][set', meowLevel.WARN);
          return;
        }
        break;
      case meowSettingsEntryType.BOOLEAN:
        if (typeof value !== 'boolean') {
          meow(`Rejected. Type mismatch`, 'meowSettings][set', meowLevel.WARN);
          return;
        }
        timeout = 250; // Timeout is designed for continuous changes, like continuously typing STRING and sliding NUMBER. But for boolean, the toggle happens in one instance.
        break;
      default:
        meow(`Rejected. Unknown / wrong type`, 'meowSettings][set', meowLevel.WARN);
        return;
    }
    this.settingsData[index].value = (value);
    this.requestSaveToDisk(timeout);
  }

  // Saving

  /**
   * Converts the settings data to a JSON string.
   * @param sort Whether to sort the entries by key before converting to JSON.
   * @returns The JSON string representation of the settings data.
   */
  toString(sort: boolean = true) {
    const lines: string[] = [];
    for (const settingsEntry of this.settingsData) {
      lines.push(`${settingsEntry.toString()}`);
    }
    if (sort) {
      lines.sort();
    }
    const jsonResult = '{\n' + lines.join(',\n') + '\n}';
    this.prebuiltReadOnly = jsonResult;
    return jsonResult;
  }

  /**
   * Save settings to disk. Has a 500 ms timeout by default.
   * @returns true if success, false if failed.
   */
  requestSaveToDisk(timeout: number = 500) {
    if (!this.ready) {
      meow(`Rejected. Settings not ready`, 'meowSettings][requestSaveToDisk', meowLevel.WARN);
      return false;
    }

    clearTimeout(this.timeoutIdSaveToDisk);
    this.timeoutIdSaveToDisk = setTimeout(async () => {
      this.timeoutIdSaveToDisk = undefined;
      await this.saveToDisk();
    }, timeout);

    meow(`Called requestSaveToDisk. It is expected to save settings to disk in ${timeout} ms`, 'meowSettings][requestSaveToDisk', meowLevel.INFO);
    return true;
  }

  /**
   * Save settings to disk.
   */
  private async saveToDisk() {
    const startTime = Date.now();
    const jsonResult = this.toString(true);
    meow(`Generated JSON lines. (${Date.now() - startTime} ms)`, 'meowSettings][saveToDisk', meowLevel.INFO);
    // Save to disk...
    await saveHybrid(this.settingsFileSavePath, jsonResult, true);
  }
}
