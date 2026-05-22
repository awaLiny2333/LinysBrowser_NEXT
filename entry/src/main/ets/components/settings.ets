/**
 * ALL UI RELATED SETTINGS OPTIONS SHOULD BE SEATED HERE.
 *
 * The range only includes the UI settings options that affect the layout or appearance,
 * i.e. values READ / USED by the UI.
 *
 * For other settings (like whether to download directly to Downloads folder),
 * the getters are put in the settings.ets files in each host folder under entry/src/main/ets/hosts.
 *
 * For settings that doesn't affect the UI (e.g. usages to WRITE / SET the settings),
 * they may not be here but in individual settings UI components.
 * See the component files in entry/src/main/ets/dialogs/parts/WoofSettings/parts.
 *
 * Some usages by the WoofCatsDev (Deveowloper's Panel)
 * are also managed by the panel UI itself, and they don't need to be here as well.
 * See entry/src/main/ets/dialogs/parts/WoofCatsDev/parts/settings/SimpleSettingsExamples.ets.
 *
 * ALL IN ALL, the meowManagedSettings should ONLY be accessed in
 * 1) This [settings.ets] file (UI statuses / values, e.g. whether to use advanced effects or not)
 * 2) Other [settings.ets] files in different host directories under [entry/src/main/ets/hosts] (Other settings, e.g. sites to allow ads on)
 * 3) UI component files in the settings dialog [entry/src/main/ets/dialogs/parts/WoofSettings/parts] (Write / set operations majorly)
 * 4) WoofCatsDev panel in [entry/src/main/ets/dialogs/parts/WoofCatsDev/parts/settings/SimpleSettingsExamples.ets] (They are just, legacy... :P)
 */

import { AppStorageV2 } from "@kit.ArkUI";
import Curves from '@ohos.curves';
import { meowLayout } from "../catstypicalframework/hosts/meowLayout";
import { meowUiHost } from "../hosts/system/windows/classes/meowUiHost";
import { getMyApp } from "../hosts/system/windows/scripts/helpers";
import { meowManagedSettings } from "../hosts/userdata/settings/classes/meowManagedSettings";
import { meowThemeColorType, minimumCardWidth, UnifiedButtonsType } from "./constants";

let settings: meowManagedSettings | undefined = undefined;

/**
 * Guarantee the existence of the settings instance and return it.
 * @returns The meowManagedSettings object!
 */
export function getMySettings() {
  if (!settings) {
    settings = AppStorageV2.connect(meowManagedSettings)!;
  }
  return settings;
}

// ENVIRONMENT

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
  return getMySettings().settingsData[getMyApp().dark ? 65 + type : 62 + type].value as string;
}

/**
 * Gets the default animation param.
 * @returns The default animation param.
 */
export function defaultAnimation() {
  const animation_damping_coefficient = getMySettings().settingsData[40].value as number;
  const animation_response = getMySettings().settingsData[39].value as number;
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

/**
 * Gets if the app UI is using advanced effects.
 * @returns true if the app UI is using advanced effects, false otherwise.
 */
export function useEffects() {
  return getMySettings().settingsData[7].value as boolean;
}

/**
 * Gets if the app is in dark mode.
 * @returns true if the app is in dark mode, false otherwise.
 */
export function inDarkMode() {
  return getMyApp().dark;
}

// LAYOUT

/**
 * Gets if the user wants to show the window title.
 * @returns true if the user wants to show the window title, false otherwise.
 */
export function showWindowTitle(layout: meowLayout) {
  if (layout.wideMode) {
    return getMySettings().settingsData[23].value as boolean;
  }
  return getMySettings().settingsData[24].value as boolean;
}

/**
 * Gets the position of the window title.
 * @returns The position of the window title.
 */
export function windowTitlePosition() {
  const value = getMySettings().settingsData[25].value as string;
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
  return getMySettings().settingsData[2].value as boolean;
}

/**
 * Gets the position of the title bar.
 * @returns true if the title bar is at the bottom, false otherwise.
 */
export function titleBarPositionBottom() {
  return getMySettings().settingsData[1].value == 'bottom';
}

/**
 * Gets if the user wants to show the navigation indicator.
 * @returns true if the user wants to show the navigation indicator, false otherwise.
 */
export function showNavigationIndicator() {
  return getMySettings().settingsData[6].value as boolean;
}

/**
 * Gets if the user wants to show the resource monitor.
 * @returns true if the user wants to show the resource monitor, false otherwise.
 */
export function showResourceMonitor() {
  return getMySettings().settingsData[75].value as boolean;
}

/**
 * Gets if the user wants to show the bottom avoid.
 * @returns true if the user wants to show the bottom avoid, false otherwise.
 */
export function showBottomAvoid() {
  return getMySettings().settingsData[5].value as boolean;
}

// HAND PREFERENCES

/**
 * Gets if the user prefers right hand. This inclused considering the smartReachability's suggestion.
 * @returns true if the user prefers right hand, false otherwise.
 */
export function isPreferRightHand(): boolean {
  if (isSmartReachabilityOn()) {
    return getMyApp().smartReachabilitySaysWeShouldPreferRightHand;
  }
  return isPreferRightHandFromSettings();
}

/**
 * Gets if the user prefers right hand. This reads only from the settings.
 * @returns true if the user prefers right hand, false otherwise.
 */
export function isPreferRightHandFromSettings() {
  return getMySettings().settingsData[47].value == 'right';
}

/**
 * Gets if the user enables smart reachability.
 * @returns true if the user enables smart reachability, false otherwise.
 */
export function isSmartReachabilityOn() {
  return getMySettings().settingsData[51].value as boolean;
}

// TABS & SIDE BAR (SIDE AREA)

/**
 * Check the settings and see if the current tabs style is vertical, taking into consideration the current layout wide mode status.
 * @param myLayout The layout of the current window.
 * @returns True if the current tabs style is vertical, false otherwise.
 */
export function isTabsStyleVertical(myLayout: meowLayout) {
  return getMySettings().settingsData[myLayout.wideMode ? 3 : 4].value as string == 'vertical';
}

/**
 * Whether to show the shrink button.
 */
export function sideAreaShrinkButton() {
  return getMySettings().settingsData[15].value as boolean;
}

/**
 * Whether to auto shrink side area.
 */
export function sideAreaShrinkAuto() {
  return getMySettings().settingsData[14].value as boolean;
}

/**
 * If the user wants no push to the web contents when expanding the side area.
 */
export function sideAreaShrinkExpandNoPush() {
  return getMySettings().settingsData[84].value as boolean;
}

/**
 * Check the settings and see if the sidebar should be on the right.
 * @returns True if the sidebar should be on the right, false otherwise.
 */
export function sidebarShouldBeOnTheRight() {
  const reverseSidebar = getMySettings().settingsData[49].value as boolean;
  return isPreferRightHand() && !reverseSidebar;
}

// HOMEPAGE

/**
 * Check the settings and see if the shortcuts should be on the right.
 * @returns True if the shortcuts should be on the right, false otherwise.
 */
export function shortcutsShouldBeOnTheRight() {
  const reverseShortcuts = getMySettings().settingsData[50].value as boolean;
  return isPreferRightHand() && !reverseShortcuts;
}

export function shortcutsHeight() {
  return getMySettings().settingsData[46].value as number;
}

export function shortcutsPath() {
  return getMySettings().settingsData[45].value as string;
}

/**
 * Gets the default new window alias.
 * @returns The default new window alias.
 */
export function defaultNewWindowAlias() {
  return getMySettings().settingsData[26].value as string;
}

// MISC

/**
 * Gets if the user wants to use system back to go back in the web.
 * @returns true if the user enables going back in web by system back, false otherwise.
 */
export function webBackBack() {
  const webBackBack = getMySettings().settingsData[10].value as boolean;
  return webBackBack;
}

/**
 * Gets if the user wants to use esc key shortcuts to go back in the web.
 * @returns true if the user enables going back in web by esc key shortcuts, false otherwise.
 */
export function webBackEsc() {
  const webBackEsc = getMySettings().settingsData[11].value as boolean;
  return webBackEsc;
}

/**
 * Gets the maximum number of suggestions for bookmarks.
 * @returns The maximum number of suggestions for bookmarks.
 */
export function maxSuggestionsBookmark() {
  return getMySettings().settingsData[12].value as number;
}

/**
 * Gets the maximum number of suggestions for history.
 * @returns The maximum number of suggestions for history.
 */
export function maxSuggestionsHistory() {
  return getMySettings().settingsData[13].value as number;
}

// MeowButtons & Side bar buttons

export function meowButtonsControl() {
  return getMySettings().settingsData[76].value as UnifiedButtonsType[];
}

export function meowButtonsAddressBarOnFocus() {
  return getMySettings().settingsData[77].value as UnifiedButtonsType[];
}

export function meowButtonsAddressBarAlways() {
  return getMySettings().settingsData[78].value as UnifiedButtonsType[];
}

export function meowButtonsTitle() {
  return getMySettings().settingsData[79].value as UnifiedButtonsType[];
}

export function meowButtonsMore() {
  return getMySettings().settingsData[80].value as UnifiedButtonsType[];
}

/**
 * Gets the buttons for the specified slot.
 * They are in a format of [<symbolId>, <buttonType / url>][]
 *
 * @param slotId The id of the slot. ([76, 80])
 * @returns The buttons for the specified slot.
 */
export function meowButtonsOfSlot(slotId: number) {
  return getMySettings().settingsData[slotId].value as UnifiedButtonsType[];
}

/**
 * Gets the buttons for the sidebar.
 * They are in a format of [symbolId, buttonType / url][]
 *
 * @returns The buttons for the sidebar.
 */
export function sidebarButtons() {
  return getMySettings().settingsData[81].value as [string, string][];
}
