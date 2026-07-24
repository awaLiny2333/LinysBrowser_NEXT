import { common, Want } from "@kit.AbilityKit";
import { productViewManager } from "@kit.AppGalleryKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { getAbilityRunningInfos } from "./environment";

/**
 * Pin a shortcut to the desktop.
 *
 * @param url The url of the shortcut.
 * @param label The label name of the shortcut.
 * @param icon The path of the icon file.
 * @returns True if succeeded, false otherwise.
 * @author awa_Liny adapted from https://developer.huawei.com/consumer/cn/doc/doccenter-capabilities/api/store-productviewmanager, enhanced by DeepSeek Web @ Jul 19 2026.
 */
export async function pinShortcut(uiContext: common.UIAbilityContext, url: string, label: string, icon: string): Promise<boolean> {
  // Get UIContext
  if (!uiContext) {
    console.error('pinShortcut failed: uiContext is null, please call in UIAbility context.');
    return false;
  }

  // Assemble key information
  const infos = await getAbilityRunningInfos();
  if (!infos) {
    console.error(`pinShortcut failed: infos [${infos}] is empty.`);
    return false;
  }
  const bundleName = infos[0].ability.bundleName;
  if (!bundleName) {
    console.error(`pinShortcut failed: bundleName [${bundleName}] is empty.`);
    return false;
  }
  const moduleName = infos[0].ability.moduleName;
  const abilityName = infos[0].ability.abilityName;
  if (!abilityName) {
    console.error(`pinShortcut failed: abilityName [${abilityName}] is empty.`);
    return false;
  }
  const shortcutId = `meow_${Date.now().toString(16)}`;
  const want: Want = {
    bundleName: bundleName,
    moduleName: moduleName,
    abilityName: abilityName,
    parameters: {
      url: url,
      meow: 'shortcut'
    }
  };
  const foregroundIcon = icon;
  const backgroundIcon = ''; // Left blank intentionally, see https://developer.huawei.com/consumer/cn/doc/doccenter-capabilities/api/store-productviewmanager#productviewmanagercheckpinshortcutpermitted-1

  try {
    // Check whether pinning shortcut is permitted
    const result = await productViewManager.checkPinShortcutPermitted(uiContext, shortcutId, want, label, foregroundIcon, backgroundIcon);

    // Strictly check if tid exists
    if (!result || result.tid === undefined || result.tid === null) {
      console.error('checkPinShortcutPermitted failed: result or tid is empty.');
      return false;
    }

    // Execute pin operation
    await productViewManager.requestNewPinShortcut(uiContext, result.tid);
    return true;

  } catch (err) {
    const error = err as BusinessError;
    console.error(`Pin shortcut failed. Code: ${error.code}, Message: ${error.message}`);
    return false;
  }
}
