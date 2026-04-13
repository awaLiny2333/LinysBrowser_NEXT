import { meow, meowLevel } from '../../../catstypicalframework/utils/catsLogger';
import { getFolderSizeSync } from '../../../catstypicalframework/utils/storage';

/**
 * Gets the folder size.
 * @param path The folder path.
 * @returns The size of the folder.
 */
@Concurrent
export function getFolderSizeSyncWrapped(path: string): number {
  try {
    return getFolderSizeSync(path);
  } catch (e) {
    meow(`Error getting folder size: ${e}`, 'storage][getFolderSizeSyncWrapped', meowLevel.ERROR);
    return -1;
  }
}
