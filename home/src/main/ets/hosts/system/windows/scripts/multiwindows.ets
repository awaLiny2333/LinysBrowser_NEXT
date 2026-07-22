import lazy { common, Want } from "@kit.AbilityKit";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { getAbilityRunningInfos } from "../../../../catstypicalframework/utils/environment";
import lazy { getCreateMyApp } from "./helpers";
import lazy { util } from "@kit.ArkTS";

/**
 * Get the last window id.
 * @returns The id.
 */
export function getLastWindowId() {
  const myApp = getCreateMyApp();
  return myApp.windowIds[myApp.windowIds.length - 1];
}

/**
 * Get ALL the window ids.
 * @returns The ids.
 */
export function getAllWindowIds() {
  const myApp = getCreateMyApp();
  return myApp.windowIds;
}

/**
 * Generate a time-based window id.
 * @returns The id.
 */
export function generateTimeBasedWindowId() {
  return `meow_${Date.now().toString(16)}_${util.generateRandomUUID()}`;
}

/**
 * Create a new window.
 * @param context The context.
 * @param windowId The window id. Have time based window id generation if left blank. YOU SHOULDN'T SET THIS MANUALLY IN MOST CASES!
 * @param zoneAlias The alias of the zone, used to load zone from disk.
 * @returns True if ok, false if failed.
 */
export async function newWindow(context: common.UIAbilityContext, windowId: string = generateTimeBasedWindowId(), zoneAlias: string = '') {
  const info = await getAbilityRunningInfos();

  // Info not successfully got
  if (info == undefined) {
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
      zoneAlias: zoneAlias
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
