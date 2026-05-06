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
 * - meowUiHost
 * - meowDialogManager
 */

import { common, Configuration, ConfigurationConstant } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import lazy Want from '@ohos.app.ability.Want';
import { defaultNewWindowAlias, isPreferRightHandFromSettings } from '../../components/settings';
import { meowDialogManager } from '../../hosts/system/dialogs/classes/meowDialogManager';
import { meowResources } from '../../hosts/system/storage/classes/meowResources';
import { meowAppStatuses } from '../../hosts/system/windows/classes/meowAppStatuses';
import { meowUiHost } from '../../hosts/system/windows/classes/meowUiHost';
import { generateTimeBasedWindowId } from '../../hosts/system/windows/scripts/multiwindows';
import { meowBookmarkStash } from '../../hosts/userdata/bookmarks/classes/meowBookmarkStash';
import { meowHistorian } from '../../hosts/userdata/history/classes/meowHistorian';
import { meowKeyboardMan } from '../../hosts/userdata/keyshortcuts/classes/meowKeyboardMan';
import { meowManagedSettings } from '../../hosts/userdata/settings/classes/meowManagedSettings';
import { meowAvoid } from '../hosts/meowAvoid';
import { meowLayout } from '../hosts/meowLayout';
import { meowMisc } from '../hosts/meowMisc';
import { listenCrash, meow, meowLevel } from '../utils/catsLogger';
import { ensureDirectoryExist } from '../utils/storage';
import { updateAvoid, updateFreeWindowMode, listenAvoid, listenFocus, listenFreeWindowMode, listenSmartReachability, listenWindowStatusChange, meowPx2vp, offAvoid, offFocus, offWindowStatusChange, shortModeThreshold, updateNavigationIndicator, wideModeThreshold } from '../utils/ui';

// Enums
/**
 * The sources of wants.
 */
export enum wantSource {
  ONCREATE = 'ONCREATE',
  RUNTIME = 'RUNTIME'
}

// Flows

/**
 * Called on early on create, before everything.
 * Only put actions that doesn't use any performance here (Highly concurrent functions!)
 * @param context The context.
 * @returns the windowId.
 *
 * Jobs in this function are executed in the very first place of launch.
 * They should be either sync tasks,
 * or promises that takes long time to run that are NOT NECESSARY to the app's key functions.
 * For example starting to load the homepage wallpaper.
 */
export function earlyOnCreate(context: Context, launchWant: Want) {
  const paramWindowName = launchWant.parameters?.windowName as string | undefined;

  // Determine window name
  const isNewWindow = paramWindowName == undefined; // ASSERT THAT ALL LEGAL LATER WINDOWS ARE CREATED WITH THIS PARAM IN THE LAUNCHWANT. SO THAT WITHOUT THIS PARAM MUST BE THE FIRST WINDOW OF THIS APP.
  let myWindowId = paramWindowName || generateTimeBasedWindowId();

  // Register window
  const myApp = AppStorageV2.connect(meowAppStatuses, () => new meowAppStatuses())!;
  myApp.windowIds.push(myWindowId);

  // Shared hosts
  if (isNewWindow) {
    // Get filesDir
    const filesDir = context.filesDir;
    // init
    AppStorageV2.connect(meowBookmarkStash, () => new meowBookmarkStash(`${filesDir}/html_bookmarks.html`))!;
    AppStorageV2.connect(meowHistorian, () => new meowHistorian(`${filesDir}`))!;
    AppStorageV2.connect(meowKeyboardMan, () => new meowKeyboardMan())!;
    AppStorageV2.connect(meowManagedSettings, () => new meowManagedSettings(`${filesDir}/settings.json.browsercatsettings.txt`))!;
    const myResources = AppStorageV2.connect(meowResources, () => new meowResources(`${filesDir}/homepage_background_arrayBuffer`))!;
    myResources.loadBackgroundImage();
  }

  // Window private hosts
  AppStorageV2.connect(meowUiHost, `meowUiHost_${myWindowId}`, () => new meowUiHost(myWindowId));
  AppStorageV2.connect(meowDialogManager, `meowDialogManager_${myWindowId}`, () => new meowDialogManager());
  AppStorageV2.connect(meowMisc, `meowMisc_${myWindowId}`, () => new meowMisc());
  AppStorageV2.connect(meowAvoid, `meowAvoid_${myWindowId}`, () => new meowAvoid(0, 0, 0, 0));

  return myWindowId;
}

/**
 * Called on windowStageCreate, before everything.
 * @param context The context.
 * */
export async function earlyOnWindowStageCreate(context: Context) {
  const startTime = Date.now();
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  const isNewWindow = myApp.windowIds.length == 1;
  const myWindowId = myApp.windowIds[myApp.windowIds.length - 1];

  // Some other windows had done this already.
  if (!isNewWindow) {
    meow(`Skipped. (${Date.now() - startTime} ms)`, `earlyOnWindowStageCreate][${myWindowId}`, meowLevel.WARN);
    return;
  }

  // ONLY FOR NEW WINDOW (NEW LAUNCHES):

  // Environments
  const filesDir = context.filesDir;

  // Settings
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  await mySettings.initFrom(`${filesDir}/settings.json.browsercatsettings.txt`); // This can ONLY be initialized here as it requires async - await processing.

  // Ensure directory
  await ensureDirectoryExist(`${filesDir}/continue`); // Last opened tabs
  await ensureDirectoryExist(`${filesDir}/easylist`); // Ad blocker rules
  await ensureDirectoryExist(`${filesDir}/faultlogs`); // fault logs
  await ensureDirectoryExist(`${filesDir}/history`); // History chunk files
  await ensureDirectoryExist(`${filesDir}/history-index`); // History index files
  await ensureDirectoryExist(`${filesDir}/zones`); // Zones

  meow(`Finished in ${Date.now() - startTime} ms.`, 'earlyOnWindowStageCreate', meowLevel.WARN);
}

/**
 * Called in onWindowStageCreate, before windowStage.LoadContent, for EVERY WINDOW.
 * @param windowStage window.WindowStage
 * @param windowObj window.Window
 * @param context common.UIAbilityContext
 * */
export async function aboutToLoadContent(windowStage: window.WindowStage, windowObj: window.Window, context: Context) {
  console.log(`aboutToLoadContent: windowStage = ${windowStage}, windowObj = ${windowObj}, context = ${context}`); // Just to USE them so that it won't be markded as unused and give me a yellow <!>.
}

/**
 * Called immediately after windowStage.LoadContent, for EVERY WINDOW.
 * @param windowStage window.WindowStage
 * @param windowObj window.Window
 * @param context common.UIAbilityContext
 * */
export function onLoadContent(windowStage: window.WindowStage, windowObj: window.Window, context: common.UIAbilityContext) {
  const startTime = Date.now();
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  const isNewWindow = myApp.windowIds.length == 1;
  const myWindowId = myApp.windowIds[myApp.windowIds.length - 1];

  // UI

  windowStage.setWindowRectAutoSave(true) // Enable window status auto save.
    .then(() => {
      meow('windowStage.setWindowRectAutoSave(true) Success!', 'init', meowLevel.INFO);
    })
    .catch((err: BusinessError) => {
      meow(`windowStage.setWindowRectAutoSave(true) Failed: ${err}`, 'init', meowLevel.ERROR);
    });
  try {
    windowObj.setImmersiveModeEnabledState(true); // Immersive
    meow('window.setImmersiveModeEnabledState(true) Success!', 'init', meowLevel.INFO);
  } catch (e) {
    meow(`window.setImmersiveModeEnabledState(true) Failed: ${e}`, 'init', meowLevel.ERROR);
  }
  try {
    windowObj.setWindowDecorVisible(false); // Disable title bar (status bar on phones & tablets)
  } catch (e) {
    meow(`window.setWindowDecorVisible(false) Failed: ${e}`, 'init', meowLevel.ERROR);
  }
  updateNavigationIndicator(windowObj); // Navigation indicator

  // SHARED HOSTS

  // Init myApp
  if (isNewWindow) {
    const dark = context.config.colorMode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    const smartReachabilitySaysWeShouldPreferRightHand = isPreferRightHandFromSettings(); // Set the value of myUi.smartReachabilitySaysWeShouldPreferRightHand here as a starting position for smart reachability.
    myApp.dark = dark;
    myApp.smartReachabilitySaysWeShouldPreferRightHand = smartReachabilitySaysWeShouldPreferRightHand;
    updateFreeWindowMode(context, windowObj);
  }

  // PRIVATE HOSTS

  // Init myUI
  const myUi: meowUiHost = AppStorageV2.connect(meowUiHost, `meowUiHost_${myWindowId}`)!;
  myUi.windowStage = windowStage;
  myUi.windowObj = windowObj;
  myUi.windowAlias = defaultNewWindowAlias();

  // Init myLayout
  try {
    const rect: window.Rect = windowObj.getWindowProperties().windowRect;
    const width = meowPx2vp(rect.width);
    const height = meowPx2vp(rect.height);
    const wideMode = width > wideModeThreshold;
    const shortMode = height < shortModeThreshold;
    AppStorageV2.connect(meowLayout, `meowLayout_${myWindowId}`, () => new meowLayout(wideMode, shortMode, width, height));
  } catch (e) {
    meow(`AppStorageV2.connect(meowLayout, () => new meowLayout(wideMode, shortMode, width, height, dark, powerSave, smartReachabilitySaysWeShouldPreferRightHand)); Failed: ${e}`, 'init', meowLevel.ERROR);
  }

  // Init myAvoid
  updateAvoid(windowObj, myWindowId);

  // Listen for focus, window status (myUi) and avoid (myAvoid).
  setTimeout(() => {
    listenWindowStatusChange(myWindowId); // Listen window status
    listenFocus(myWindowId);
    listenAvoid(myWindowId);
  }, 100); // Delayed execution, reduce launch time.

  // SHARED USER DATA & LISTENERS

  if (isNewWindow) {
    // Init History
    let myMeowHistorian = AppStorageV2.connect(meowHistorian)!;
    myMeowHistorian.init();

    // Load bookmarks
    let myMeowBookmarkStash = AppStorageV2.connect(meowBookmarkStash)!;
    myMeowBookmarkStash.loadFromDisk();
    
    // Key shortcuts
    const myKey = AppStorageV2.connect(meowKeyboardMan)!;
    myKey.initFromSettings();

    // App level Listen
    setTimeout(() => {
      listenFreeWindowMode(context);
      listenSmartReachability();
      listenCrash(`${context.filesDir}/faultlogs`);
    }, 100);
  }

  meow(`Finished in ${Date.now() - startTime} ms.`, 'onLoadContent', meowLevel.WARN);
}

/**
 * Called on want received. Handled by catstypicalframework.
 * @param want The want.
 */
export function onWant(want: Want, source: wantSource) {
  meow(`onWant! want info: ${JSON.stringify(want)}, source: ${source}`, 'init][onWant', meowLevel.INFO);
}

/**
 * Called on configuration update. Majorly used to update the color mode.
 * @param config The new configuration.
 */
export function onConfigUpdate(config: Configuration) {
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

/**
 * Called on onWindowStageWillDestroy.
 * @param windowStage The windowStage.
 */
export function onWindowStageWillDestroy(windowStage: window.WindowStage) {
  // Find the meowUiHost item.
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  let targetUi: meowUiHost | undefined = undefined;
  for (const windowId of myApp.windowIds) {
    const myUi = AppStorageV2.connect(meowUiHost, `meowUiHost_${windowId}`);
    if (myUi && myUi.windowStage == windowStage) {
      meow(`I think window [${myUi.windowId}] is going to leave us...`, 'onWindowStageWillDestroy', meowLevel.WARN);
      targetUi = myUi;
      break;
    }
  }

  // Remove the targetUi from the windowIds array.
  if (targetUi) {
    myApp.windowIds = myApp.windowIds.filter(id => id != targetUi!.windowId);
    offFocus(targetUi.windowObj!);
    offAvoid(targetUi.windowObj!);
    offWindowStatusChange(targetUi!.windowId);
  }
}
