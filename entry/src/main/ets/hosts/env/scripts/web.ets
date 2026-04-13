import lazy { webview } from "@kit.ArkWeb";
import { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import { taskpool } from "@kit.ArkTS";
import { getFolderSizeSyncWrapped } from "./storage";

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
