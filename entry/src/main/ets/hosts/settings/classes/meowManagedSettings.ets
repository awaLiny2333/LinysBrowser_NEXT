import { readArrayBufferConcurrent, saveHybrid } from "../../../catstypicalframework/utils/storage";
import { fastbuffer } from "@kit.ArkTS";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { meowSettingsEntry } from "./meowSettingsEntry";
import { defaultSettingsEntries } from "../scripts/defaultSettingsEntries";
import { settingsParserJSON, settingsParserV2 } from "../scripts/parser";

@ObservedV2
export class meowManagedSettings {
  settingsFileSavePath: string;
  settingsData: meowSettingsEntry[] = defaultSettingsEntries;
  @Trace timeoutIdSaveToDisk: number | undefined;
  @Trace ready: boolean = false;

  /**
   * Constructor of this managed settings.s
   * @param settingsFileSavePath The path to SAVE the settings file in each this.saveToDisk() call.
   * It is totally not related to the one passed to this.initFrom() function.
   */
  constructor(settingsFileSavePath: string) {
    this.settingsFileSavePath = settingsFileSavePath;
  }

  /**
   * Init from settings file.
   * @param settingsFilePath The path to the settings file. If the file doesn't exist, then nothing would happen.
   * @param useLegacy Whether to use the legacy settings file format. 
   * If true, then the legacy format parser for traditional & standard JSON string would be used.
   * If false, then the V2 format parser would be applied.
   * @returns true if success, false if failed.
   * 
   * meowManagedSettings now only saves in V2 format.
   */
  async initFrom(settingsFilePath: string, useLegacy: boolean) {
    let settingsText: string = '';
    const startTime = Date.now();

    try {
      settingsText = fastbuffer.from(await readArrayBufferConcurrent(settingsFilePath)).toString();
      meow(`Loaded settingsText from ${settingsFilePath} (${Date.now() - startTime} ms)`, 'meowSettings][initFrom', meowLevel.INFO);
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

    // 1. 解析字符串为对象
    const kvObj = useLegacy ? settingsParserJSON(settingsText) : settingsParserV2(settingsText);

    // 2. 遍历默认配置数组
    // 使用标准 for 循环，避免 forEach 闭包开销，性能最高
    for (let i = 0; i < this.settingsData.length; i++) {
      const entry: meowSettingsEntry = this.settingsData[i];
      
      // 3. 直接在 jsonObj 中查找 key
      // 在 Record<string, string> 中通过 string key 索引查找是 O(1) 操作，非常快
      // 使用 !== undefined 来判断 key 是否存在
      const jsonValue: string | undefined = kvObj[entry.key];
      
      if (jsonValue !== undefined) {
        // 只有当 JSON 中确实有这个配置时，才更新
        entry.setValueFromString(jsonValue);
      }
    }

    meow(`Loaded settings from ${settingsFilePath} (${Date.now() - startTime} ms)`, 'meowSettings][initFrom', meowLevel.INFO);
    this.ready = true;
    return settingsText;
  }

  /**
   * Converts the settings data to a JSON string.
   * @returns The JSON string representation of the settings data.
   */
  toString() {
    const lines: string[] = [];
    for (const settingsEntry of this.settingsData) {
      lines.push(`${settingsEntry.toString()}`);
    }
    const jsonResult = lines.join('\n');
    return jsonResult;
  }

  /**
   * Save settings to disk. Has a 500 ms timeout.
   * @returns true if success, false if failed.
   */
  requestSaveToDisk() {
    if (!this.ready) {
      meow(`Rejected. Settings not ready`, 'meowSettings][saveToDiskWrapped', meowLevel.WARN);
      return false;
    }

    clearTimeout(this.timeoutIdSaveToDisk);
    this.timeoutIdSaveToDisk = setTimeout(async () => {
      this.timeoutIdSaveToDisk = undefined;
      await this.saveToDisk();
    }, 500);

    meow(`Called saveToDiskWrapped. It is expected to save settings to disk in 500 ms`, 'meowSettings][saveToDiskWrapped', meowLevel.INFO);
    return true;
  }

  /**
   * Save settings to disk.
   */
  async saveToDisk() {
    const jsonResult = this.toString();
    meow(`Saving lines to [${this.settingsFileSavePath}]: ${jsonResult}`, 'meowSettings][saveToDisk', meowLevel.INFO);
    // Save to disk...
    await saveHybrid(this.settingsFileSavePath, jsonResult, true);
  }
}