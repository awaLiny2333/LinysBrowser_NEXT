import { AppStorageV2, window } from '@kit.ArkUI';
import { meow, meowLevel } from '../utils/catsLogger';
import { getUpdateAvoid, getUpdateFreeWindowMode, listenAvoid, listenFocus, listenFreeWindowMode, meowLayoutModeStatus, meowPx2vp } from '../utils/ui';
import { BusinessError } from '@kit.BasicServicesKit';
import Want from '@ohos.app.ability.Want';
import { meowHistorian } from '../../hosts/history/classes/meowHistorian';
import { Context } from '@ohos.abilityAccessCtrl';
import { meowMisc } from '../hosts/meowMisc';
import { ensureDirectoryExist } from '../utils/storage';
import { meowManagedSettings } from '../../hosts/settings/classes/meowManagedSettings';
import { meowResources } from '../../hosts/resources/classes/meowResources';
import { meowBookmarkStash } from '../../hosts/bookmarks/classes/meowBookmarkStash';

// Flows
/**
 * Called on early on create, before everything.
 * @param context The context.
 *
 * Jobs in this function are executed in the very first place of launch.
 * They should be either sync tasks,
 * or promises that takes long time to run that are NOT NECESSARY to the app's key functions.
 * For example starting to load the homepage wallpaper.
 */
export function earlyOnCreate(context: Context) {
  // const startTime = Date.now();
  const filesDir = context.filesDir;

  // Init hosts
  AppStorageV2.connect(meowMisc, () => new meowMisc());
  let myMeowBookmarkStash = AppStorageV2.connect(meowBookmarkStash, () => new meowBookmarkStash(`${filesDir}/html_bookmarks.html`))!;
  let myMeowResources = AppStorageV2.connect(meowResources, () => new meowResources(`${filesDir}/homepage_background_arrayBuffer`))!;
  AppStorageV2.connect(meowHistorian, () => new meowHistorian(`${filesDir}`))!;
  AppStorageV2.connect(meowManagedSettings, () => new meowManagedSettings(`${filesDir}/settings.json.browsercatsettings.txt`))!;

  // Actions that doesn't use any performance (Concurrent functions!)
  myMeowResources.loadBackgroundImage();
  myMeowBookmarkStash.loadFromDisk();

  // meow(`Finished in ${Date.now() - startTime} ms.`, 'earlyOnCreate', meowLevel.WARN);
}

/**
 * Called on windowStageCreate, before everything.
 * @param context The context.
 * */
export async function earlyOnWindowStageCreate(context: Context) {
  const startTime = Date.now();
  const filesDir = context.filesDir;

  // Ensure directory
  await ensureDirectoryExist(`${filesDir}/history`);
  await ensureDirectoryExist(`${filesDir}/history-index`);

  // Settings
  let myMeowManagedSettings = AppStorageV2.connect(meowManagedSettings);
  await myMeowManagedSettings?.initFrom(`${filesDir}/settings.json.browsercatsettings.txt`);

  meow(`Finished in ${Date.now() - startTime} ms.`, 'earlyOnWindowStageCreate', meowLevel.WARN);
}

/**
 * Called in onWindowStageCreate, before windowStage.LoadContent
 * @param window window.Window
 * */
export async function aboutToLoadContent(windowStage: window.WindowStage, window: window.Window, context: Context) {
  // const startTime = Date.now();

  // Enable window status auto save.
  windowStage.setWindowRectAutoSave(true)
    .then(() => {
      meow('windowStage.setWindowRectAutoSave(true) Success!', 'init', meowLevel.INFO);
    })
    .catch((err: BusinessError) => {
      meow(`windowStage.setWindowRectAutoSave(true) Failed: ${err}`, 'init', meowLevel.ERROR);
    });

  // Immersive
  try {
    window.setImmersiveModeEnabledState(true);
    meow('window.setImmersiveModeEnabledState(true) Success!', 'init', meowLevel.INFO);
  } catch (e) {
    meow(`window.setImmersiveModeEnabledState(true) Failed: ${e}`, 'init', meowLevel.ERROR);
  }

  // meow(`Finished in ${Date.now() - startTime} ms.`, 'aboutToLoadContent', meowLevel.WARN);
}

/**
 * Called immediately after windowStage.LoadContent
 * @param window window.Window
 * */
export function onLoadContent(window: window.Window, context: Context) {
  const startTime = Date.now();

  // Disable title bar (status bar on phones & tablets)
  try {
    window.setWindowDecorVisible(false);
  } catch (e) {
    meow(`window.setWindowDecorVisible(false) Failed: ${e}`, 'init', meowLevel.ERROR);
  }

  // Initialize window status
  try {
    const rect: window.Rect = window.getWindowProperties().windowRect;
    const width = meowPx2vp(rect.width);
    const height = meowPx2vp(rect.height);
    const wideMode = width > 900;
    AppStorageV2.connect(meowLayoutModeStatus, () => new meowLayoutModeStatus(wideMode, width, height));
  } catch (e) {
    meow(`AppStorageV2.connect(meowLayoutModeStatus, () => new meowLayoutModeStatus(wideMode)); Failed: ${e}`, 'init', meowLevel.ERROR);
  }

  getUpdateFreeWindowMode(context, window);
  listenFreeWindowMode(context, window);

  getUpdateAvoid(window);
  listenAvoid(window);

  listenFocus(window);

  // watchLaunch(); // This is chicken rib. >O

  // Init History here to avoid resource competition
  let myMeowHistorian = AppStorageV2.connect(meowHistorian);
  myMeowHistorian?.init();

  meow(`Finished in ${Date.now() - startTime} ms.`, 'onLoadContent', meowLevel.WARN);
}

export enum wantSource {
  ONCREATE = 'ONCREATE',
  RUNTIME = 'RUNTIME'
}

/**
 * Called on want received. Handled by catstypicalframework.
 * @param want The want.
 */
export function onWant(want: Want, source: wantSource) {
  meow(`onWant! want info: ${JSON.stringify(want)}, source: ${source}`, 'init][onWant', meowLevel.INFO);
}
