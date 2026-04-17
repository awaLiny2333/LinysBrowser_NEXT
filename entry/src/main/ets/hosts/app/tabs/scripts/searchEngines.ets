import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { getSearchEngineFromSettings } from "../setings";

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
 * @param engine The search engine URL template. If not provided, the default search engine from settings will be used.
 * @param query The search query.
 * @returns A concatSeResult.
 */
export function concatSearchWithEngine(query: string, engine: string = getSearchEngineFromSettings()): concatSeResult {
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
