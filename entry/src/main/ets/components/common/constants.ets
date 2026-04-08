import { AppStorageV2, LengthMetrics } from "@kit.ArkUI";
import { meowLayoutModeStatus } from "../../catstypicalframework/utils/ui";
import { meowManagedSettings } from "../../hosts/settings/classes/meowManagedSettings";
import Curves from '@ohos.curves';

// Hosts

const settings = AppStorageV2.connect(meowManagedSettings)!;
const layout = AppStorageV2.connect(meowLayoutModeStatus)!;

// Constants

export const fontSizeLarge = 36;
export const fontSizeMedium = 26;
export const fontSizeSmall = 16;

export const standardSpacing = 8;

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
  BACKGROUND = 3,
}

export enum mooTextType {
  NORMAL = 0,
  TITLE = 1,
}

// Getters

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
        return $r('sys.color.comp_background_tertiary');
      case meowThemeColorType.SECONDARY:
        return Color.Transparent;
      case meowThemeColorType.FONT:
        return settings.settingsData[layout.dark ? 65 + type : 62 + type].value as string;
      case meowThemeColorType.BACKGROUND:
        return $r('sys.color.background_tertiary');
      default:
        return Color.Transparent;
    }
  }
  // No effects
  if (type == meowThemeColorType.BACKGROUND) {
    return getColor(meowThemeColorType.SECONDARY);
  }
  return settings.settingsData[layout.dark ? 65 + type : 62 + type].value as string;
}

/**
 * Gets if the app UI is using advanced effects.
 * @returns true if the app UI is using advanced effects, false otherwise.
 */
export function useEffects() {
  return settings.settingsData[7].value as boolean;
}

/**
 * Gets the position of the title bar.
 * @returns true if the title bar is at the bottom, false otherwise.
 */
export function titleBarPositionBottom() {
  return settings.settingsData[1].value == 'bottom';
}

/**
 * Gets the default animation param.
 * @returns The default animation param.
 */
export function defaultAnimation() {
  const animation_damping_coefficient = settings.settingsData[40].value as number;
  const animation_response = settings.settingsData[39].value as number;
  const ap: AnimateParam = { curve: Curves.springMotion(animation_response / 100, (100 - animation_damping_coefficient) / 100) };
  return ap;
}