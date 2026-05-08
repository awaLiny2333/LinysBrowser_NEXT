/**
 * ALL UI RELATED SETTINGS OPTIONS SHOULD BE SEATED HERE.
 * IN CASE OF A SITUATION IN WHICH I NEED TO CHANGE SOME ORDERS IN defaultSettingsEntries.
 * GATEHREING THEM ALL HERE MAKES IT EASIER.
 *
 * For other settings (like whether to download directly to Downloads folder),
 * the getters are put in the settings.ets files in each host folder under entry/src/main/ets/hosts.
 */
import { AppStorageV2, LengthMetrics } from "@kit.ArkUI";
import Curves from '@ohos.curves';
import { meowLayout } from "../catstypicalframework/hosts/meowLayout";
import { meowManagedSettings } from "../hosts/userdata/settings/classes/meowManagedSettings";
import { meowAppStatuses } from "../hosts/system/windows/classes/meowAppStatuses";
import { meowUiHost } from "../hosts/system/windows/classes/meowUiHost";

// Constants
export const fontSizeSymbol = 24;

export const fontSizeMedium = 22;
export const fontSizeSmall = 16;

export const standardSpacing = 8;
export const minimumCardWidth = 520; // Minimum width required for cards (e.g. in a multi-column waterFlow)

export const meowFlexOptions: FlexOptions = {
  wrap: FlexWrap.Wrap,
  space: { main: LengthMetrics.vp(standardSpacing), cross: LengthMetrics.vp(standardSpacing) },
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

// Getters of values

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
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  return settings.settingsData[myApp.dark ? 65 + type : 62 + type].value as string;
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
export function waterFlowColumnsTemplate(layout: meowLayout) {
  return "1fr ".repeat(Math.ceil(layout.width / minimumCardWidth));
}

// Statuses

/**
 * Gets if the app UI is using advanced effects.
 * @returns true if the app UI is using advanced effects, false otherwise.
 */
export function useEffects() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[7].value as boolean;
}

/**
 * Gets if the app is in dark mode.
 * @returns true if the app is in dark mode, false otherwise.
 */
export function inDarkMode() {
  const myApp = AppStorageV2.connect(meowAppStatuses)!;
  return myApp.dark;
}

/**
 * Gets if the user wants to show the window title.
 * @returns true if the user wants to show the window title, false otherwise.
 */
export function showWindowTitle(layout: meowLayout) {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  if (layout.wideMode) {
    return settings.settingsData[23].value as boolean;
  }
  return settings.settingsData[24].value as boolean;
}

/**
 * Gets the position of the window title.
 * @returns The position of the window title.
 */
export function windowTitlePosition() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  const value = settings.settingsData[25].value as string;
  switch (value) {
    case 'left':
      return TextAlign.Start;
    case 'center':
      return TextAlign.Center;
    case 'right':
      return TextAlign.End;
    default:
      return TextAlign.Center;
  }
}

/**
 * Gets if the user wants to show the gigantic window title.
 * This function always returns false if the window is on focus.
 * @returns true if the user wants to show the gigantic window title, false otherwise.
 */
export function showGiganticWindowTitle(myUi: meowUiHost) {
  if (myUi.windowFocused) {
    return false;
  }
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[2].value as boolean;
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
export function isPreferRightHand(): boolean {
  if (isSmartReachabilityOn()) {
    const myApp = AppStorageV2.connect(meowAppStatuses)!;
    return myApp.smartReachabilitySaysWeShouldPreferRightHand;
  }
  return isPreferRightHandFromSettings();
}

/**
 * Gets if the user prefers right hand. This reads only from the settings.
 * @returns true if the user prefers right hand, false otherwise.
 */
export function isPreferRightHandFromSettings() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[47].value == 'right';
}

/**
 * Gets if the user enables smart reachability.
 * @returns true if the user enables smart reachability, false otherwise.
 */
export function isSmartReachabilityOn() {
  const settings = AppStorageV2.connect(meowManagedSettings)!;
  return settings.settingsData[51].value as boolean;
}

/**
 * Check the settings and see if the current tabs style is vertical, taking into consideration the current layout wide mode status.
 * @param myLayout The layout of the current window.
 * @returns True if the current tabs style is vertical, false otherwise.
 */
export function isTabsStyleVertical(myLayout: meowLayout) {
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  return mySettings.settingsData[myLayout.wideMode ? 3 : 4].value as string == 'vertical';
}

/**
 * Check the settings and see if the sidebar should be on the right.
 * @returns True if the sidebar should be on the right, false otherwise.
 */
export function sidebarShouldBeOnTheRight() {
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  const reverseSidebar = mySettings.settingsData[49].value as boolean;
  return isPreferRightHand() && !reverseSidebar;
}

/**
 * Check the settings and see if the shortcuts should be on the right.
 * @returns True if the shortcuts should be on the right, false otherwise.
 */
export function shortcutsShouldBeOnTheRight() {
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  const reverseShortcuts = mySettings.settingsData[50].value as boolean;
  return isPreferRightHand() && !reverseShortcuts;
}

/**
 * Gets the default new window alias.
 * @returns The default new window alias.
 */
export function defaultNewWindowAlias() {
  const mySettings = AppStorageV2.connect(meowManagedSettings)!;
  return mySettings.settingsData[26].value as string;
}
