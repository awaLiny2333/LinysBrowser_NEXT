import { meow, meowLevel } from "./catsLogger";
import { Permissions, common, abilityAccessCtrl } from "@kit.AbilityKit";

/**
 * Analyzes a list of protected resource types and return their according permissions.
 * @param prts the list of protected resource types.
 * @returns a list of Permissions.
 * */
export function protectedResourceTypes_2_Permissions(prts: string[]) {
  let permissions: Permissions[] = [];
  for (const prt of prts) {
    switch (prt) {
      case ProtectedResourceType.AUDIO_CAPTURE:
        if (!permissions.includes('ohos.permission.MICROPHONE')) {
          permissions.push('ohos.permission.MICROPHONE');
        }
        break;
      case ProtectedResourceType.VIDEO_CAPTURE:
        if (!permissions.includes('ohos.permission.CAMERA')) {
          permissions.push('ohos.permission.CAMERA');
        }
        break;
      case ProtectedResourceType.SENSOR:
        if (!permissions.includes('ohos.permission.ACCELEROMETER')) {
          permissions.push('ohos.permission.ACCELEROMETER');
        }
        if (!permissions.includes('ohos.permission.GYROSCOPE')) {
          permissions.push('ohos.permission.GYROSCOPE');
        }
        break;
      default:
        break;
    }
  }
  return permissions;
}

/**
 * Requests permission from user, for ProtectedResourceTypes.
 * @param context The common.UIAbilityContext.
 * @param prts protected resource types.
 * */
export async function requestUserPermissionFromProtectedResourceTypes(context: common.UIAbilityContext, prts: string[]) {
  const ps = protectedResourceTypes_2_Permissions(prts);
  await requestUserPermission(context, ps);
}

/**
 * Requests permission from user.
 * @param context The common.UIAbilityContext.
 * @param permissions OHOS system permissions.
 */
export async function requestUserPermission(context: common.UIAbilityContext, permissions: Permissions[]) {
  if (permissions.length == 0) {
    meow(`No HarmonyOS @kit.AbilityKit Permission requested`, 'permission][requestUserPermission', meowLevel.WARN);
    return;
  }
  const atManager = abilityAccessCtrl.createAtManager();
  meow(`Requesting HarmonyOS @kit.AbilityKit permission: [${permissions.join(', ')}]`, 'permission][requestUserPermission', meowLevel.WARN);
  await atManager.requestPermissionsFromUser(context, permissions)
    .catch((e: BusinessError) => {
      meow(`Failed to request permission: ${e}`, 'permission][requestUserPermission', meowLevel.ERROR);
    });
}
