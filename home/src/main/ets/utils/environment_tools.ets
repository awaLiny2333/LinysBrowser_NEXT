import { common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';

/**
 * Retrieves the context from AppStorage.
 * @returns common.UIAbilityContext
 * */
export function meowContext(): common.UIAbilityContext {
  return AppStorage.get('context') as common.UIAbilityContext;
}

export function meowPx2vp(px: number) {
  try {
    return px / display.getDefaultDisplaySync().densityPixels;
  } catch (e) {
    // This is not good.
    console.error('[px2vp] Error: ' + e);
    return px;
  }
}