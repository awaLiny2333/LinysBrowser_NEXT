import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { AppStorageV2 } from "@kit.ArkUI";
import { meowManagedSettings } from "../../settings/classes/meowManagedSettings";
import { defaultSearchEngine } from "../../settings/scripts/defaultSettingsValues";

export enum concatSeStatus {
  SUCCESS = 0,
  NO_PERCENTAGE_S = 1,
  ENCODE_FAIL = 2
}

export interface concatSeResult {
  status: concatSeStatus;
  result: string;
}

/**
 * Concatenate a search query to a search engine URL.
 * 
 * Typical external use cases (outside this file) is to search the current keyword with another search engine.
 * 
 * @param engine The search engine URL template.
 * @param query The search query.
 * @returns A concatSeResult.
 */
export function concatSearchWithEngine(engine: string, query: string): concatSeResult {
  if (!engine.includes('%s')) {
    meow(`Invalid search engine format: ${engine}`, 'searchEngines', meowLevel.ERROR);
    return {
      status: concatSeStatus.NO_PERCENTAGE_S,
      result: engine
    };
  }

  // Has %s
  try {
    const result = engine.replace('%s', encodeURIComponent(query));
    meow(`Successfully encoded query: ${query}`, 'searchEngines', meowLevel.INFO);
    return {
      status: concatSeStatus.SUCCESS,
      result: result
    };
  } catch (e) {
    meow(`Failed to encode query: ${e}`, 'searchEngines', meowLevel.ERROR);
    return {
      status: concatSeStatus.ENCODE_FAIL,
      result: engine.replace('%s', query)
    };
  }
}

/**
 * Concatenate a search query to the default search engine URL.
 * 
 * Typical external use cases (outside this file) is to search in the address bar directly with the default search engine.
 * 
 * @param query The search query.
 * @returns A concatSeResult.
 */
export function concatSearchWithDefaultEngineFromSettings(query: string) {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const seList = settings.settingsData[43].value as string[][];
  const seSelected = settings.settingsData[44].value as number;
  const se = seSelected == -1 ? defaultSearchEngine() : seList[seSelected][1];
  return concatSearchWithEngine(se, query);
}
