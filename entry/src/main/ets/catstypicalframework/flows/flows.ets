import Want from '@ohos.app.ability.Want';
import { AppStorageV2, window } from '@kit.ArkUI';
import { meow, meowLevel } from '../utils/catsLogger';
import { getUpdateAvoid, getUpdateFreeWindowMode, listenAvoid, listenFocus, listenFreeWindowMode, listenPowerSave, meowLayoutModeStatus, meowPx2vp } from '../utils/ui';
import { BusinessError, power } from '@kit.BasicServicesKit';
import { meowHistorian } from '../../hosts/history/classes/meowHistorian';
import { Context } from '@ohos.abilityAccessCtrl';
import { meowMisc } from '../hosts/meowMisc';
import { ensureDirectoryExist } from '../utils/storage';
import { meowManagedSettings } from '../../hosts/settings/classes/meowManagedSettings';
import { meowResources } from '../../hosts/env/classes/meowResources';
import { meowBookmarkStash } from '../../hosts/bookmarks/classes/meowBookmarkStash';
import { common, ConfigurationConstant, Configuration } from '@kit.AbilityKit';
import { meowDialogManager } from '../../hosts/env/scripts/meowDialogManager';
import { meowUiStatuses } from '../../hosts/env/scripts/meowUiStatuses';

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

  // Declare hosts
  AppStorageV2.connect(meowDialogManager, () => new meowDialogManager()); // TODO: multi-window compatibility!
  AppStorageV2.connect(meowUiStatuses, () => new meowUiStatuses()); // TODO: multi-window compatibility!
  AppStorageV2.connect(meowMisc, () => new meowMisc());
  AppStorageV2.connect(meowBookmarkStash, () => new meowBookmarkStash(`${filesDir}/html_bookmarks.html`))!;
  AppStorageV2.connect(meowHistorian, () => new meowHistorian(`${filesDir}`))!;
  AppStorageV2.connect(meowManagedSettings, () => new meowManagedSettings(`${filesDir}/settings.json.browsercatsettings.txt`))!;
  const myMeowResources = AppStorageV2.connect(meowResources, () => new meowResources(`${filesDir}/homepage_background_arrayBuffer`))!;

  // Actions that doesn't use any performance (Concurrent functions!)
  myMeowResources.loadBackgroundImage();

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
  let myMeowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  await myMeowManagedSettings.initFrom(`${filesDir}/settings.json.browsercatsettings.txt`);

  // setTimeout(() => {
  //   webview.WebviewController.initializeWebEngine();
  // }, 100);
  
  meow(`Finished in ${Date.now() - startTime} ms.`, 'earlyOnWindowStageCreate', meowLevel.WARN);
}

/**
 * Called in onWindowStageCreate, before windowStage.LoadContent
 * @param window window.Window
 * */
export async function aboutToLoadContent(windowStage: window.WindowStage, window: window.Window, context: Context) {
  // const startTime = Date.now();
  console.log(`aboutToLoadContent: context = ${context}`); // Just to USE it so that it won't be an unused param.

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
export function onLoadContent(window: window.Window, context: common.UIAbilityContext) {
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
    const dark = context.config.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    const powerSave = power.getPowerMode() == power.DevicePowerMode.MODE_POWER_SAVE;
    AppStorageV2.connect(meowLayoutModeStatus, () => new meowLayoutModeStatus(wideMode, width, height, dark, powerSave));
  } catch (e) {
    meow(`AppStorageV2.connect(meowLayoutModeStatus, () => new meowLayoutModeStatus(wideMode, width, height, dark, powerSave)); Failed: ${e}`, 'init', meowLevel.ERROR);
  }

  // TODO: multi-window compatibility!

  getUpdateFreeWindowMode(context, window);
  listenFreeWindowMode(context, window);

  getUpdateAvoid(window);
  listenAvoid(window);

  listenFocus(window);
  listenPowerSave();

  // watchLaunch(); // This is chicken rib. >O

  // Init History here to avoid resource competition
  let myMeowHistorian = AppStorageV2.connect(meowHistorian);
  myMeowHistorian?.init();

  // Load bookmarks
  let myMeowBookmarkStash = AppStorageV2.connect(meowBookmarkStash);
  myMeowBookmarkStash?.loadFromDisk();

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

/**
 * Called on configuration update.
 * @param config The new configuration.
 */
export function onConfigUpdate(config: Configuration) {
  // Update colorMode.
  try {
    const myMeowLayoutModeStatus = AppStorageV2.connect(meowLayoutModeStatus);
    if (myMeowLayoutModeStatus) {
      myMeowLayoutModeStatus.dark = config.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    }
  } catch (e) {
    meow(`const myMeowLayoutModeStatus = AppStorageV2.connect(meowLayoutModeStatus); failed: ${e}`, 'onConfigUpdate', meowLevel.WARN);
  }
}
