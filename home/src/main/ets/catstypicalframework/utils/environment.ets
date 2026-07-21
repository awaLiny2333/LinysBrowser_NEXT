import { abilityManager } from '@kit.AbilityKit';
import { meow, meowLevel } from './catsLogger';

/**
 * Get the bundle name of the current ability.
 * @returns The bundle name of the current ability, or undefined if failed.
 */
export async function getBundleName() {
  const info = await getAbilityRunningInfos();
  if (info == undefined) {
    return undefined;
  }
  return info[0].ability.bundleName;
}

/**
 * Get the module name of the current ability.
 * @returns The module name of the current ability, or undefined if failed.
 */
export async function getModuleName() {
  const info = await getAbilityRunningInfos();
  if (info == undefined) {
    return undefined;
  }
  return info[0].ability.moduleName;
}

/**
 * Get the ability name of the current ability.
 * @returns The ability name of the current ability, or undefined if failed.
 */
export async function getAbilityName() {
  const info = await getAbilityRunningInfos();
  if (info == undefined) {
    return undefined;
  }
  return info[0].ability.abilityName;
}

/**
 * Get the ability running infos of the current ability.
 * @returns The ability running infos of the current ability, or undefined if failed.
 */
export async function getAbilityRunningInfos() {
  try {
    const info = await abilityManager.getAbilityRunningInfos(); // We don't need this permission, as all we require is the current ability's info. But it will still exist as a warning! :O
    if (info.length == 0) {
      return undefined;
    }
    return info;
  } catch (e) {
    meow(`abilityManager.getAbilityRunningInfos() Failed! ${e}`, 'getAbilityRunningInfos', meowLevel.ERROR);
    return undefined;
  }
}
