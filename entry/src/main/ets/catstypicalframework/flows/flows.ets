/**
 * About hosts in multi window environment:
 *
 * ALL WINDOWS SHARE:
 * - meowManagedSettings
 * - meowResources
 * - meowBookmarkStash
 * - meowHistorian
 * - meowAppStatuses
 *
 * Every window is expected to have one of each of the other classes:
 * - meowMisc
 * - meowLayoutModeStatus
 * - meowAvoid
 * - meowFreeWindowModeStatus
 * - meowUiStatuses
 * - meowDialogManager
 */

import { common, Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError, power } from '@kit.BasicServicesKit';
import Want from '@ohos.app.ability.Want';
import { preferRightHandFromSettings } from '../../components/settings';
import { meowBookmarkStash } from '../../hosts/bookmarks/classes/meowBookmarkStash';
import { meowAppStatuses } from '../../hosts/env/classes/meowAppStatuses';
import { meowDialogManager } from '../../hosts/env/classes/meowDialogManager';
import { meowResources } from '../../hosts/env/classes/meowResources';
import { meowUiStatuses } from '../../hosts/env/classes/meowUiStatuses';
import { generateTimeBasedWindowId } from '../../hosts/env/scripts/multiwindows';
import { meowHistorian } from '../../hosts/history/classes/meowHistorian';
import { meowManagedSettings } from '../../hosts/settings/classes/meowManagedSettings';
import { meowLayoutModeStatus } from '../hosts/meowLayoutModeStatus';
import { meowMisc } from '../hosts/meowMisc';
import { meow, meowLevel } from '../utils/catsLogger';
import { ensureDirectoryExist } from '../utils/storage';
import { getUpdateAvoid, getUpdateFreeWindowMode, listenAvoid, listenFocus, listenFreeWindowMode, listenPowerSave, listenSmartReachability, meowPx2vp, shortModeThreshold, wideModeThreshold } from '../utils/ui';

// Flows
/**
 * Called on early on create, before everything.
 * Only put actions that doesn't use any performance here (Highly concurrent functions!)
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
  let myWindowId = generateTimeBasedWindowId();
  let isNewWindow = true;

  const myMeowAppStatuses = AppStorageV2.connect(meowAppStatuses, () => new meowAppStatuses())!;
  if (myMeowAppStatuses.windowNames.length == 0) {
    // Is the first window of this app.
    // Just use the generated timestamp based window name.
    // And push it into the list.
    myMeowAppStatuses.windowNames.push(myWindowId);
  } else {
    // Is a new window of this app.
    // Use the given window name already pushed into the list
    // by an existing window.
    myWindowId = myMeowAppStatuses.windowNames[myMeowAppStatuses.windowNames.length - 1];
    isNewWindow = false;
  }

  // Shared hosts
  if (isNewWindow) {
    AppStorageV2.connect(meowBookmarkStash, () => new meowBookmarkStash(`${filesDir}/html_bookmarks.html`))!; // TODO: multi-window compatibility! Execute ONCE!
    AppStorageV2.connect(meowHistorian, () => new meowHistorian(`${filesDir}`))!; // TODO: multi-window compatibility! Execute ONCE!
    AppStorageV2.connect(meowManagedSettings, () => new meowManagedSettings(`${filesDir}/settings.json.browsercatsettings.txt`))!; // TODO: multi-window compatibility! Execute ONCE!
    const myMeowResources = AppStorageV2.connect(meowResources, () => new meowResources(`${filesDir}/homepage_background_arrayBuffer`))!; // TODO: multi-window compatibility! Execute ONCE!
    myMeowResources.loadBackgroundImage(); // TODO: multi-window compatibility! Execute ONCE!
  }

  // Window private hosts
  AppStorageV2.connect(meowDialogManager, `meowDialogManager_${myWindowId}`, () => new meowDialogManager()); // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!
  AppStorageV2.connect(meowUiStatuses, `meowUiStatuses_${myWindowId}`, () => new meowUiStatuses(myWindowId)); // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!
  AppStorageV2.connect(meowMisc, `meowMisc_${myWindowId}`, () => new meowMisc()); // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!

  // meow(`Finished in ${Date.now() - startTime} ms.`, 'earlyOnCreate', meowLevel.WARN);
}

/**
 * Called on windowStageCreate, before everything.
 * @param context The context.
 * */
export async function earlyOnWindowStageCreate(context: Context) {
  const myMeowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  if (myMeowAppStatuses.windowNames.length > 1) {
    // Some other windows had done this already.
    const myWindowId = myMeowAppStatuses.windowNames[myMeowAppStatuses.windowNames.length - 1];
    meow(`Skipped.`, `earlyOnWindowStageCreate][${myWindowId}`, meowLevel.WARN);
    return;
  }

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
  const myMeowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  const myWindowId = myMeowAppStatuses.windowNames[myMeowAppStatuses.windowNames.length - 1];

  // Disable title bar (status bar on phones & tablets)
  try {
    window.setWindowDecorVisible(false);
  } catch (e) {
    meow(`window.setWindowDecorVisible(false) Failed: ${e}`, 'init', meowLevel.ERROR);
  }

  // Initialize App status
  const dark = context.config.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  const powerSave = power.getPowerMode() == power.DevicePowerMode.MODE_POWER_SAVE;
  const smartReachabilitySaysWeShouldPreferRightHand = preferRightHandFromSettings(); // Set the value of myMeowUiStatuses.smartReachabilitySaysWeShouldPreferRightHand here as a starting position for smart reachability.
  myMeowAppStatuses.dark = dark;
  myMeowAppStatuses.powerSave = powerSave;
  myMeowAppStatuses.smartReachabilitySaysWeShouldPreferRightHand = smartReachabilitySaysWeShouldPreferRightHand;

  // Initialize window status // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!
  try {
    const rect: window.Rect = window.getWindowProperties().windowRect;
    const width = meowPx2vp(rect.width);
    const height = meowPx2vp(rect.height);
    const wideMode = width > wideModeThreshold;
    const shortMode = height < shortModeThreshold;
    AppStorageV2.connect(meowLayoutModeStatus, `meowLayoutModeStatus_${myWindowId}`, () => new meowLayoutModeStatus(wideMode, shortMode, width, height));
  } catch (e) {
    meow(`AppStorageV2.connect(meowLayoutModeStatus, () => new meowLayoutModeStatus(wideMode, shortMode, width, height, dark, powerSave, smartReachabilitySaysWeShouldPreferRightHand)); Failed: ${e}`, 'init', meowLevel.ERROR);
  }

  listenFocus(window, myWindowId); // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!
  listenPowerSave(); // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!

  getUpdateFreeWindowMode(context, window, myWindowId); // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!
  listenFreeWindowMode(context, window, myWindowId); // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!

  getUpdateAvoid(window, myWindowId); // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!
  listenAvoid(window, myWindowId); // TODO: multi-window compatibility! Execute FOR EVERY WINDOW!

  listenSmartReachability();

  // watchLaunch(); // This is chicken rib. >O

  if (myMeowAppStatuses.windowNames.length == 1) {
    // I am the first window!

    // Init History here to avoid resource competition
    let myMeowHistorian = AppStorageV2.connect(meowHistorian); // TODO: multi-window compatibility! Execute ONCE!
    myMeowHistorian?.init(); // TODO: multi-window compatibility! Execute ONCE!

    // Load bookmarks
    let myMeowBookmarkStash = AppStorageV2.connect(meowBookmarkStash); // TODO: multi-window compatibility! Execute ONCE!
    myMeowBookmarkStash?.loadFromDisk(); // TODO: multi-window compatibility! Execute ONCE!
  }

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
    const myMeowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
    const newDark = config.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    if (myMeowAppStatuses.dark != newDark) {
      myMeowAppStatuses.dark = newDark;
    }
  } catch (e) {
    meow(`const myMeowAppStatuses = AppStorageV2.connect(meowAppStatuses); failed: ${e}`, 'onConfigUpdate', meowLevel.WARN);
  }
}
