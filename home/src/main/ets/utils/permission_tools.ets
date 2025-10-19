import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { meowContext } from './environment_tools';

// import { webview } from '@kit.ArkWeb';

// webview.WebviewController.setWebDebuggingAccess(true);
let atManager = abilityAccessCtrl.createAtManager();

/**
 * Requests permission from user.
 * @param p Permissions[]
 * */
export function request_user_permission(context:common.UIAbilityContext ,p: Permissions[]) {
  if (p.length == 0) {
    return;
  }
  atManager.requestPermissionsFromUser(context, p);
}

/**
 * Analyzes a list of protected resource types and return their according permissions.
 * @param prt the list of protected resource types.
 * @returns a list of Permissions.
 * */
export function permissions_for_ProtectedResourceTypes(prt: string[]) {
  let permissions: Permissions[] = [];
  for (let index = 0; index < prt.length; index++) {
    const ProtectedResourceType = prt[index];
    if (ProtectedResourceType == 'TYPE_AUDIO_CAPTURE') {
      permissions.push('ohos.permission.MICROPHONE');
    }
    if (ProtectedResourceType == 'TYPE_VIDEO_CAPTURE') {
      permissions.push('ohos.permission.CAMERA');
    }
  }
  return permissions;
}

/**
 * Analyzes a list of protected resource types and return their according descriptions in human language.
 * @param prt the list of protected resource types.
 * @returns list of ResourceStr.
 * */
export function desc_for_ProtectedResourceTypes(prt: string[]) {
  let result: ResourceStr[] = [];
  for (let index = 0; index < prt.length; index++) {
    const r = prt[index];
    if ($r('app.string.protected_resource_'.concat(r))) {
      result.push($r('app.string.protected_resource_'.concat(r)));
    } else {
      result.push('[Error] Unknown Protected Resource Type? ' + r);
    }
  }
  return result;
}