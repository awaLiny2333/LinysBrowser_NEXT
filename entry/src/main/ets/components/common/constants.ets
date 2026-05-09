/**
 * The scripts for the new buttons system!
 */

/**
 * Important buttons providing key features in the app.
 * No matter what, the settings button ('SET') must be in one of the slots.
 */
export enum UnifiedButtonsType {
  BACKWARD = 'BAK',
  FORWARD = 'FOR',
  REFRESH = 'REF',
  HOME = 'HOM',
  GO = 'GOO',
  ADDRESS_KEYWORD_SWITCH = 'AKS', // Only shows when search mode discovered.
  ADDRESS_KEYWORD_EXPAND = 'AKE',
  RE_SEARCH = 'RES', // Only shows when search mode discovered.
  MORE = 'MOR',
  SCRATCHING_BOARD = 'SCB', // Only shows when the Scratching Board is not empty.
  TABS = 'TAB',
  SIDEBAR = 'SDB',
  BOOKMARKS = 'BKM',
  DOWNLOADS = 'DNL',
  SETTINGS = 'SET',
  FULLSCREEN = 'FUL',
  QRCODE = 'QRC',
  USERAGENTS = 'UAG',
  HISTORIES = 'HIS',
  ADBLOCKER = 'ADB',
  JAVASCRIPTS = 'JVS',
  IMAGES = 'IMG',
  COOKIES = 'CKS',
  DARK = 'DRK',
  PRINT = 'PRT',
  SAVE = 'SAV',
  ORIENTATION = 'ORN',
  EXTENSIONS = 'EXT'
}

/**
 * The matches from button type to their icons.
 */
export const unifiedButtonIconMatches: Map<string, Resource> = new Map();
unifiedButtonIconMatches.set(UnifiedButtonsType.BACKWARD, $r('sys.symbol.arrow_left'));
unifiedButtonIconMatches.set(UnifiedButtonsType.FORWARD, $r('sys.symbol.arrow_right'));
unifiedButtonIconMatches.set(UnifiedButtonsType.REFRESH, $r('sys.symbol.arrow_clockwise'));
unifiedButtonIconMatches.set(UnifiedButtonsType.HOME, $r('sys.symbol.house'));
unifiedButtonIconMatches.set(UnifiedButtonsType.GO, $r('sys.symbol.arrow_up_right'));
unifiedButtonIconMatches.set(UnifiedButtonsType.ADDRESS_KEYWORD_SWITCH, $r('sys.symbol.link'));
unifiedButtonIconMatches.set(UnifiedButtonsType.ADDRESS_KEYWORD_EXPAND, $r('sys.symbol.line_4_horizontal'));
unifiedButtonIconMatches.set(UnifiedButtonsType.RE_SEARCH, $r('sys.symbol.magnifyingglass'));
unifiedButtonIconMatches.set(UnifiedButtonsType.MORE, $r('sys.symbol.dot_grid_2x2'));
unifiedButtonIconMatches.set(UnifiedButtonsType.SCRATCHING_BOARD, $r('sys.symbol.doc_rectify'));
unifiedButtonIconMatches.set(UnifiedButtonsType.TABS, $r('sys.symbol.rectangle_stack'));
unifiedButtonIconMatches.set(UnifiedButtonsType.SIDEBAR, $r('sys.symbol.rectangle_righthalf_inset_filled'));
unifiedButtonIconMatches.set(UnifiedButtonsType.BOOKMARKS, $r('sys.symbol.bookmark'));
unifiedButtonIconMatches.set(UnifiedButtonsType.DOWNLOADS, $r('sys.symbol.download'));
unifiedButtonIconMatches.set(UnifiedButtonsType.SETTINGS, $r('sys.symbol.gearshape'));
unifiedButtonIconMatches.set(UnifiedButtonsType.FULLSCREEN, $r('sys.symbol.arrow_up_left_and_arrow_down_right'));
unifiedButtonIconMatches.set(UnifiedButtonsType.QRCODE, $r('sys.symbol.qrcode'));
unifiedButtonIconMatches.set(UnifiedButtonsType.USERAGENTS, $r('sys.symbol.label'));
unifiedButtonIconMatches.set(UnifiedButtonsType.HISTORIES, $r('sys.symbol.arrow_counterclockwise_clock'));
unifiedButtonIconMatches.set(UnifiedButtonsType.ADBLOCKER, $r('sys.symbol.ad_circle_slash'));
unifiedButtonIconMatches.set(UnifiedButtonsType.JAVASCRIPTS, $r('sys.symbol.slider_vertical_3'));
unifiedButtonIconMatches.set(UnifiedButtonsType.IMAGES, $r('sys.symbol.picture_on_square_1'));
unifiedButtonIconMatches.set(UnifiedButtonsType.COOKIES, $r('sys.symbol.tracking_cookie_interception'));
unifiedButtonIconMatches.set(UnifiedButtonsType.DARK, $r('sys.symbol.star_2_moon'));
unifiedButtonIconMatches.set(UnifiedButtonsType.PRINT, $r('sys.symbol.printer'));
unifiedButtonIconMatches.set(UnifiedButtonsType.SAVE, $r('sys.symbol.save'));
unifiedButtonIconMatches.set(UnifiedButtonsType.ORIENTATION, $r('sys.symbol.rectangle_portrait_rotate'));
unifiedButtonIconMatches.set(UnifiedButtonsType.EXTENSIONS, $r('sys.symbol.root'));

/**
 * Gets the icon of a button.
 * Note that this is also used by the icons in the sidebar.
 *
 * @param button The button to get the icon of.
 * @returns The icon of the button.
 * @see MeowSidebar entry/src/main/ets/components/parts/Sidebar/MeowSidebar.ets and its affiliates.
 */
export function getButtonIcon(button: string, fallback: Resource = $r('sys.symbol.questionmark_circle')): Resource {
  return unifiedButtonIconMatches.get(button) ?? fallback;
}

/**
 * The default side length of MooSymbolButtons / MeowButtons (basically anythiong built around icon Symbols)
 */
export const defaultMooSymbolSize = 31;
