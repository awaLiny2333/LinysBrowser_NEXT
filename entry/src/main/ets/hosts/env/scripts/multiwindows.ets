import lazy { meow, meowLevel } from "../../../catstypicalframework/utils/catsLogger";
import lazy { abilityManager, Want, common } from "@kit.AbilityKit";
import { AppStorageV2 } from "@kit.ArkUI";
import { meowAppStatuses } from "../classes/meowAppStatuses";

/**
 * Get the last window id.
 * @returns The id.
 */
export function getLastWindowId() {
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  return myApp.windowNames[myApp.windowNames.length - 1];
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
  };

  let myApp = AppStorageV2.connect(meowAppStatuses)!; // If we want to store something...
  myApp.windowNames.push(windowId); // Then the next window would pick this up onCreate.

  // Call
  try {
    await context.startAbility(wantInfo);
  } catch (e) {
    meow(`context.startAbility(wantInfo) Failed! ${e}`, 'newWindow', meowLevel.ERROR);
    return false;
  }

  meow(`context.startAbility(wantInfo) OK!`, 'newWindow', meowLevel.WARN);
  return true;
}
