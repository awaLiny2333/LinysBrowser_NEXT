import { common, Want } from "@kit.AbilityKit";
import { BusinessError } from '@kit.BasicServicesKit';

export function new_window(context: common.UIAbilityContext) {
  // Open new window
  let wantInfo: Want = {
    deviceId: '', // This device
    bundleName: 'com.next.liny.linysbrowserNEXT',
    moduleName: 'home',
    abilityName: 'HomeAbility',
  };
  context.startAbility(wantInfo).then(() => {
    console.log('[meowAppSettings] startAbility success.');
  }).catch((error: BusinessError) => {
    console.log('[meowAppSettings] startAbility failed: ' + error);
  });
}