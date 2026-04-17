import { getFolderSizeSyncWrapped } from "../../../app/env/scripts/storage";
import { meowHistorian } from "../classes/meowHistorian";
import { taskpool } from "@kit.ArkTS";
import { AppStorageV2 } from "@kit.ArkUI";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";

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
