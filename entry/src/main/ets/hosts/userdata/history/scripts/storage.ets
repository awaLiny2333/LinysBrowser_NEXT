import lazy { meowHistorian } from "../classes/meowHistorian";
import lazy { taskpool } from "@kit.ArkTS";
import lazy { AppStorageV2 } from "@kit.ArkUI";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { getFolderSizeSyncWrapped } from "../../../system/resources/scripts/storage";

/**
 * Gets the size of the history index folder.
 * @returns The size!
 */
export async function scanHistoryIndexSize() {
  const history = AppStorageV2.connect(meowHistorian)!;
  meow(`Index dir: [${history.indexBasePath}]`, 'storage][scanHistoryIndexSize', meowLevel.INFO);
  try {
    return await taskpool.execute(getFolderSizeSyncWrapped, history.indexBasePath) as number;
  } catch (error) {
    return -1;
  }
}
