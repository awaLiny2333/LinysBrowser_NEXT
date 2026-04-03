import { AppStorageV2, window } from '@kit.ArkUI';
import { meow, meowLevel } from '../utils/catsLogger';
import { getUpdateAvoid, getUpdateFreeWindowMode, listenAvoid, listenFocus, listenFreeWindowMode, meowLayoutModeStatus, meowPx2vp } from '../utils/ui';
import { BusinessError } from '@kit.BasicServicesKit';
import Want from '@ohos.app.ability.Want';
import { meowHistorian } from '../../hosts/history/classes/meowHistorian';
import { Context } from '@ohos.abilityAccessCtrl';
import { meowMisc } from '../hosts/meowMisc';
import { ensureDirectoryExist, fileExist, unlinkFile } from '../utils/storage';
import { meowManagedSettings } from '../../hosts/settings/classes/meowManagedSettings';

// Flows
/**
 * Called on windowStageCreate, before everything.
 * @param window window.Window.
 * */
export async function earlyOnWindowStageCreate(context: Context) {
  const filesDir = context.filesDir;

  // Ensure directory
  await ensureDirectoryExist(`${filesDir}/history`);
  await ensureDirectoryExist(`${filesDir}/history-index`);

  // Settings
  let myMeowManagedSettings = AppStorageV2.connect(meowManagedSettings, () => new meowManagedSettings(`${filesDir}/settings.json.browsercatsettings.v2.txt`));
  if (await fileExist(`${filesDir}/settings.json.browsercatsettings.v2.txt`)) {
    const resultInit = await myMeowManagedSettings?.initFrom(`${filesDir}/settings.json.browsercatsettings.v2.txt`, false); // load from new file
    if (resultInit) {
      meow(`Loaded settings from [${filesDir}/settings.json.browsercatsettings.v2.txt], unlinking old file [${filesDir}/settings.json.browsercatsettings.txt].`);
      unlinkFile(`${filesDir}/settings.json.browsercatsettings.txt`); // Unlink old file
    }
  } else {
    await myMeowManagedSettings?.initFrom(`${filesDir}/settings.json.browsercatsettings.txt`, true); // load from old file
  }

  // History
  let myMeowHistorian = AppStorageV2.connect(meowHistorian, () => new meowHistorian(`${filesDir}`));
  myMeowHistorian?.init();
}

/**
 * Called in onWindowStageCreate, before windowStage.LoadContent
 * @param window window.Window
 * */
export async function aboutToLoadContent(windowStage: window.WindowStage, window: window.Window, context: Context) {
  AppStorageV2.connect<meowMisc>(meowMisc, 'meowMisc', () => new meowMisc(Date.now()))!;

  // Enable window status auto save.
  windowStage.setWindowRectAutoSave(true)
    .then(() => {
      meow('windowStage.setWindowRectAutoSave(true) Success!', 'init', meowLevel.INFO);
    })
    .catch((err: BusinessError) => {
      meow(`windowStage.setWindowRectAutoSave(true) Failed: ${err}`, 'init', meowLevel.ERROR);
    });

  try {
    window.setImmersiveModeEnabledState(true);
  } catch (e) {
    meow(`window.setImmersiveModeEnabledState(true) Failed: ${e}`, 'init', meowLevel.ERROR);
  } // Immersive
}

/**
 * Called immediately after windowStage.LoadContent
 * @param window window.Window
 * */
export function onLoadContent(window: window.Window, context: Context) {
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
