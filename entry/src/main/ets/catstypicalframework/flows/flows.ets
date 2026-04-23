/**
 * About hosts in multi window environment:
 *
 * ALL WINDOWS SHARE:
 * - meowManagedSettings
 * - meowResources
 * - meowBookmarkStash
 * - meowHistorian
 * - meowAppStatuses
 * - meowKeyboardMan
 *
 * Every window is expected to have one of each of the other classes:
 * - meowMisc
 * - meowLayout
 * - meowAvoid
 * - meowUiStatuses
 * - meowDialogManager
 */

import { common, Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import lazy Want from '@ohos.app.ability.Want';
import { isPreferRightHandFromSettings } from '../../components/settings';
import { meowDialogManager } from '../../hosts/system/dialogs/classes/meowDialogManager';
import { meowResources } from '../../hosts/system/storage/classes/meowResources';
import { meowAppStatuses } from '../../hosts/system/windows/classes/meowAppStatuses';
import { meowUiStatuses } from '../../hosts/system/windows/classes/meowUiStatuses';
import { generateTimeBasedWindowId } from '../../hosts/system/windows/scripts/multiwindows';
import { meowBookmarkStash } from '../../hosts/userdata/bookmarks/classes/meowBookmarkStash';
import { meowHistorian } from '../../hosts/userdata/history/classes/meowHistorian';
import { meowKeyboardMan } from '../../hosts/userdata/keyshortcuts/classes/meowKeyboardMan';
import { meowManagedSettings } from '../../hosts/userdata/settings/classes/meowManagedSettings';
import { meowAvoid } from '../hosts/meowAvoid';
import { meowLayout } from '../hosts/meowLayout';
import { meowMisc } from '../hosts/meowMisc';
import { meow, meowLevel } from '../utils/catsLogger';
import { ensureDirectoryExist } from '../utils/storage';
import { getUpdateAvoid, getUpdateFreeWindowMode, listenAvoid, listenFocus, listenFreeWindowMode, listenSmartReachability, meowPx2vp, shortModeThreshold, wideModeThreshold } from '../utils/ui';

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
export function earlyOnCreate(context: Context, launchWant: Want) {
  // const startTime = Date.now();
  const paramWindowName = launchWant.parameters?.windowName as string | undefined;

  // Determine window name
  const isNewWindow = paramWindowName == undefined;
  let myWindowId = paramWindowName || generateTimeBasedWindowId();

  // Register window
  const myApp = AppStorageV2.connect(meowAppStatuses, () => new meowAppStatuses())!;
  myApp.windowNames.push(myWindowId);

  if (isNewWindow) {
    // Is the first window of this app.
    // Just use the generated timestamp based window name.
    // And push it into the list.

  } else {
    // Is a new window of this app.
    // Use the given window name already pushed into the list
    // by an existing window.
  }

  const filesDir = context.filesDir;


  // Shared hosts
  if (isNewWindow) {
    AppStorageV2.connect(meowBookmarkStash, () => new meowBookmarkStash(`${filesDir}/html_bookmarks.html`))!;
    AppStorageV2.connect(meowHistorian, () => new meowHistorian(`${filesDir}`))!;
    AppStorageV2.connect(meowKeyboardMan, () => new meowKeyboardMan())!;
    AppStorageV2.connect(meowManagedSettings, () => new meowManagedSettings(`${filesDir}/settings.json.browsercatsettings.txt`))!;
    const myResources = AppStorageV2.connect(meowResources, () => new meowResources(`${filesDir}/homepage_background_arrayBuffer`))!;
    myResources.loadBackgroundImage();
  }

  // Window private hosts
  AppStorageV2.connect(meowDialogManager, `meowDialogManager_${myWindowId}`, () => new meowDialogManager());
  AppStorageV2.connect(meowUiStatuses, `meowUiStatuses_${myWindowId}`, () => new meowUiStatuses(myWindowId));
  AppStorageV2.connect(meowMisc, `meowMisc_${myWindowId}`, () => new meowMisc());

  // meow(`Finished in ${Date.now() - startTime} ms.`, 'earlyOnCreate', meowLevel.WARN);
}

/**
 * Called on windowStageCreate, before everything.
 * @param context The context.
 * */
export async function earlyOnWindowStageCreate(context: Context) {
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  const isNewWindow = myApp.windowNames.length == 1;

  if (!isNewWindow) {
    // Some other windows had done this already.
    const myWindowId = myApp.windowNames[myApp.windowNames.length - 1];
    meow(`Skipped.`, `earlyOnWindowStageCreate][${myWindowId}`, meowLevel.WARN);
    return;
  }

  const startTime = Date.now();
  const filesDir = context.filesDir;

  // Ensure directory
  await ensureDirectoryExist(`${filesDir}/history`);
  await ensureDirectoryExist(`${filesDir}/history-index`);

  // Settings
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  await mySettings.initFrom(`${filesDir}/settings.json.browsercatsettings.txt`);

  const myKey = AppStorageV2.connect(meowKeyboardMan)!;
  myKey.initFromSettings();

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
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  const isNewWindow = myApp.windowNames.length == 1;
  const myWindowId = myApp.windowNames[myApp.windowNames.length - 1];

  // Disable title bar (status bar on phones & tablets)
  try {
    window.setWindowDecorVisible(false);
  } catch (e) {
    meow(`window.setWindowDecorVisible(false) Failed: ${e}`, 'init', meowLevel.ERROR);
  }

  // Initialize App status
  const dark = context.config.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  const smartReachabilitySaysWeShouldPreferRightHand = isPreferRightHandFromSettings(); // Set the value of myUi.smartReachabilitySaysWeShouldPreferRightHand here as a starting position for smart reachability.
  myApp.dark = dark;
  myApp.smartReachabilitySaysWeShouldPreferRightHand = smartReachabilitySaysWeShouldPreferRightHand;
  // const powerSave = power.getPowerMode() == power.DevicePowerMode.MODE_POWER_SAVE;
  // myApp.powerSave = powerSave;

  // Initialize window status
  try {
    const rect: window.Rect = window.getWindowProperties().windowRect;
    const width = meowPx2vp(rect.width);
    const height = meowPx2vp(rect.height);
    const wideMode = width > wideModeThreshold;
    const shortMode = height < shortModeThreshold;
    AppStorageV2.connect(meowLayout, `meowLayout_${myWindowId}`, () => new meowLayout(wideMode, shortMode, width, height));
  } catch (e) {
    meow(`AppStorageV2.connect(meowLayout, () => new meowLayout(wideMode, shortMode, width, height, dark, powerSave, smartReachabilitySaysWeShouldPreferRightHand)); Failed: ${e}`, 'init', meowLevel.ERROR);
  }
  AppStorageV2.connect(meowAvoid, `meowAvoid_${myWindowId}`, () => new meowAvoid(0, 0, 0, 0));

  getUpdateFreeWindowMode(context, window, myWindowId);
  getUpdateAvoid(window, myWindowId);

  setTimeout(() => {
    listenFocus(window, myWindowId);
    listenAvoid(window, myWindowId);
    listenFreeWindowMode(context, window, myWindowId);
    listenSmartReachability();
  }, 1); // Delayed execution, reduce launch time.

  // listenPowerSave(); // This is useless for now. :P
  // watchLaunch(); // This is chicken rib. >O

  if (isNewWindow) {
    // Init History here to avoid resource competition
    let myMeowHistorian = AppStorageV2.connect(meowHistorian)!;
    myMeowHistorian.init();

    // Load bookmarks
    let myMeowBookmarkStash = AppStorageV2.connect(meowBookmarkStash)!;
    myMeowBookmarkStash.loadFromDisk();
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
    const myApp = AppStorageV2.connect(meowAppStatuses)!;
    const newDark = config.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    if (myApp.dark != newDark) {
      myApp.dark = newDark;
    }
  } catch (e) {
    meow(`const myApp = AppStorageV2.connect(meowAppStatuses); failed: ${e}`, 'onConfigUpdate', meowLevel.WARN);
  }
}
