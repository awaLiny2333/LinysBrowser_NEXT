import lazy { abilityManager, common, Want } from "@kit.AbilityKit";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { getMyApp } from "./helpers";


/**
 * Get the last window id.
 * @returns The id.
 */
export function getLastWindowId() {
  const myApp = getMyApp();
  return myApp.windowIds[myApp.windowIds.length - 1];
}

/**
 * Generate a time-based window id.
 * @returns The id.
 */
export function generateTimeBasedWindowId() {
  return `meow_${Date.now().toString(16)}`;
}

/**
 * Create a new window.
 * @param context The context.
 * @param windowId The window id. Have time based window id generation if left blank. YOU SHOULDN'T SET THIS MANUALLY IN MOST CASES!
 * @returns True if ok, false if failed.
 */
export async function newWindow(context: common.UIAbilityContext, windowId: string = generateTimeBasedWindowId()) {
  let info: abilityManager.AbilityRunningInfo[] = [];

  try {
    info = await abilityManager.getAbilityRunningInfos(); // We don't need this permission, as all we require is the current ability's info. But it will still exist as a warning! :O
  } catch (e) {
    meow(`abilityManager.getAbilityRunningInfos() Failed! ${e}`, 'newWindow', meowLevel.ERROR);
    return false;
  }

  // Build want info
  let wantInfo: Want = {
    deviceId: '', // This device
    bundleName: info[0].ability.bundleName,
    moduleName: info[0].ability.moduleName,
    abilityName: info[0].ability.abilityName,
    parameters: {
      instanceKey: windowId,
    }
  };

  // Call
  try {
    await context.startAbility(wantInfo);
  } catch (e) {
    meow(`context.startAbility(wantInfo) Failed! ${e}`, 'newWindow', meowLevel.ERROR);
    return false;
  }

  meow(`context.startAbility(wantInfo) OK!${'\n '}`, 'newWindow', meowLevel.WARN);
  return true;
}
