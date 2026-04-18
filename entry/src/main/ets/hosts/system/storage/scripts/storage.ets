import lazy { meow, meowLevel } from '../../../../catstypicalframework/utils/catsLogger';
import lazy { getFolderSizeSync } from '../../../../catstypicalframework/utils/storage';
import lazy { webview } from '@kit.ArkWeb';
import lazy { taskpool } from '@kit.ArkTS';

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

/**
 * Gets the web cache directory path.
 * @param context Typically this.getUIContext().getHostContext().
 * @returns The path.
 */
export function getWebCacheDir(context: Context) {
  // Refresh web cache size.
  const dir = `${context.getApplicationContext().cacheDir}/web`;
  meow(`Cache dir: [${dir}]`, 'web][getWebCacheDir', meowLevel.WARN);
  return dir;
}

/**
 * Gets the web cache size.
 * @param context The context.
 * @returns The size of web cache under [data/storage/el2/base/cache/web].
 */
export async function scanWebCacheSize(context: Context) {
  try {
    return await taskpool.execute(getFolderSizeSyncWrapped, getWebCacheDir(context)) as number;
  } catch (error) {
    return -1;
  }
}

/**
 * Removes ALL web cache.
 */
export function removeWebCache() {
  webview.WebviewController.removeAllCache(true);
}
