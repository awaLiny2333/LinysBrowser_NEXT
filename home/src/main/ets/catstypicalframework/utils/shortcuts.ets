import { UIContext } from "@kit.ArkUI";
import { common, Want } from "@kit.AbilityKit";
import { productViewManager } from "@kit.AppGalleryKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { getAbilityName, getBundleName, getModuleName } from "./environment";

/**
 * Pin a shortcut to the desktop.
 *
 * @param url The url of the shortcut.
 * @param label The label name of the shortcut.
 * @param icon The path of the icon file.
 * @returns True if succeeded, false otherwise.
 * @author awa_Liny adapted from https://developer.huawei.com/consumer/cn/doc/doccenter-capabilities/api/store-productviewmanager, enhanced by DeepSeek Web @ Jul 19 2026.
 */
export async function pinShortcut(url: string, label: string, icon: string): Promise<boolean> {
  // Get UIContext
  const uiContext = UIContext.getCallingScopeUIContext()?.getHostContext() as common.UIAbilityContext;
  if (!uiContext) {
    console.error('pinShortcut failed: uiContext is null, please call in UIAbility context.');
    return false;
  }

  // Assemble key information
  const bundleName = await getBundleName();
  if (!bundleName) {
    console.error(`pinShortcut failed: bundleName [${bundleName}] is empty.`);
    return false;
  }
  const moduleName = await getModuleName();
  const abilityName = await getAbilityName();
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
