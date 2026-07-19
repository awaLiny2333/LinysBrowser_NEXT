import { abilityManager } from '@kit.AbilityKit';
import { meow, meowLevel } from './catsLogger';

/**
 * Get the bundle name of the current ability.
 * @returns The bundle name of the current ability, or undefined if failed.
 */
export async function getBundleName() {
  try {
    const info = await abilityManager.getAbilityRunningInfos(); // We don't need this permission, as all we require is the current ability's info. But it will still exist as a warning! :O
    return info[0].ability.bundleName;
  } catch (e) {
    meow(`abilityManager.getAbilityRunningInfos() Failed! ${e}`, 'getBundleName', meowLevel.ERROR);
    return undefined;
  }
}

/**
 * Get the module name of the current ability.
 * @returns The module name of the current ability, or undefined if failed.
 */
export async function getModuleName() {
  try {
    const info = await abilityManager.getAbilityRunningInfos(); // We don't need this permission, as all we require is the current ability's info. But it will still exist as a warning! :O
    return info[0].ability.moduleName;
  } catch (e) {
    meow(`abilityManager.getAbilityRunningInfos() Failed! ${e}`, 'getModuleName', meowLevel.ERROR);
    return undefined;
  }
}

/**
 * Get the ability name of the current ability.
 * @returns The ability name of the current ability, or undefined if failed.
 */
export async function getAbilityName() {
  try {
    const info = await abilityManager.getAbilityRunningInfos(); // We don't need this permission, as all we require is the current ability's info. But it will still exist as a warning! :O
    return info[0].ability.abilityName;
  } catch (e) {
    meow(`abilityManager.getAbilityRunningInfos() Failed! ${e}`, 'getAbilityName', meowLevel.ERROR);
    return undefined;
  }
}
