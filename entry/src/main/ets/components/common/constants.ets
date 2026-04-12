/**
 * ALL UI RELATED SETTINGS OPTIONS SHOULD BE CALLED HERE.
 * IN CASE OF A SITUATION IN WHICH I NEED TO CHANGE SOME ORDERS IN defaultSettingsEntries.
 * GATEHREING THEM ALL HERE MAKES IT EASIER.
 * 
 * For other settings (like whether to download directly to Downloads folder), the getters are put in the scripts/xxx.ets files in each host folder under entry/src/main/ets/hosts.
 */
import { AppStorageV2, LengthMetrics } from "@kit.ArkUI";
import Curves from '@ohos.curves';
import { meowLayoutModeStatus } from "../../catstypicalframework/hosts/meowLayoutModeStatus";
import { meowManagedSettings } from "../../hosts/settings/classes/meowManagedSettings";

// Constants
export const fontSizeSymbol = 24;

export const fontSizeMedium = 22;
export const fontSizeSmall = 16;

export const standardSpacing = 8;
export const minimumCardWidth = 480; // Minimum width required for cards (e.g. in a multi-column waterFlow)

export const meowFlexOptions: FlexOptions = {
  wrap: FlexWrap.Wrap,
  space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) },
  alignItems: ItemAlign.Center
};

// Types

export enum meowThemeColorType {
  PRIMARY = 0,
  SECONDARY = 1,
  FONT = 2,
}

export enum mooTextType {
  NORMAL = 0,
  TITLE = 1,
}

// Getters

/**
 * Gets if the app UI is using advanced effects.
 * @returns true if the app UI is using advanced effects, false otherwise.
 */
export function useEffects() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  // const layout = AppStorageV2.connect(meowLayoutModeStatus)!;
  // if (layout.powerSave) {
  //   return false;
  // }
  return settings.settingsData[7].value as boolean;
}

/**
 * Gets the color from the current theme.
 * Returns undefined if advanced effects option is on.
 * @param type The type of color.
 * @returns The color in string.
 */
export function getColor(type: meowThemeColorType): ResourceColor {
  if (useEffects()) {
    switch (type) {
      case meowThemeColorType.PRIMARY:
        return $r('app.color.blur_background');
      case meowThemeColorType.SECONDARY:
        return $r('sys.color.background_tertiary');
      case meowThemeColorType.FONT:
        break; // Use the Normal color.
      default:
        return Color.Transparent;
    }
  }

  // No effects
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const layout = AppStorageV2.connect(meowLayoutModeStatus)!;
  return settings.settingsData[layout.dark ? 65 + type : 62 + type].value as string;
}

/**
 * Gets the position of the title bar.
 * @returns true if the title bar is at the bottom, false otherwise.
 */
export function titleBarPositionBottom() {
  // return true;
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[1].value == 'bottom';
}

/**
 * Gets if the user prefers right hand. This inclused considering the smartReachability's suggestion.
 * @returns true if the user prefers right hand, false otherwise.
 */
export function summarizedPreferRightHand(): boolean {
  if (smartReachability()) {
    const layout = AppStorageV2.connect(meowLayoutModeStatus)!;
    return layout.smartReachabilitySaysWeShouldPreferRightHand;
  }
  return preferRightHandFromSettings();
}

/**
 * Gets if the user prefers right hand. This reads only from the settings.
 * @returns true if the user prefers right hand, false otherwise.
 */
export function preferRightHandFromSettings() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[47].value == 'right';
}

/**
 * Gets if the user enables smart reachability.
 * @returns true if the user enables smart reachability, false otherwise.
 */
export function smartReachability() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[51].value as boolean;
}

/**
 * Gets the default animation param.
 * @returns The default animation param.
 */
export function defaultAnimation() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const animation_damping_coefficient = settings.settingsData[40].value as number;
  const animation_response = settings.settingsData[39].value as number;
  const ap: AnimateParam = { curve: Curves.springMotion(animation_response / 100, (100 - animation_damping_coefficient) / 100) };
  return ap;
}

/**
 * Gets the columns template for the water flow layout.
 * @returns The columns template for the water flow layout.
 */
export function waterFlowColumnsTemplate() {
  const layout = AppStorageV2.connect(meowLayoutModeStatus)!;
  return "1fr ".repeat(Math.ceil(layout.width / minimumCardWidth));
}
