import { display } from '@kit.ArkUI';

/**
 * Retrieves the context from AppStorage (from abilityStage).
 * @returns Context.
 * */
export function meowContext() {
  return AppStorage.get('context') as Context;
}

/**
 * Converts px to vp.
 * @param px The true px.
 * @returns The equivalent vp.
 * */
export function meowPx2vp(px: number) {
  try {
    return px / display.getDefaultDisplaySync().densityPixels;
  } catch (e) {
    // This is not good.
    console.error('[px2vp] Error: ' + e);
    return px;
  }
}