import { LengthMetrics } from "@kit.ArkUI";

// TEXTS
/**
 * Note tha we don't recommend using any preset / fixed values to represent the size (height / width) of a Text component, as its size also varies by the fonts and many other factors.
 * Use the text measuring methods instead!
 * → measureTextHeight and measureTextWidth in entry/src/main/ets/catstypicalframework/utils/ui.ets
 */
export const typicalTextHeightNormal = 20;

export const fontSizeSymbol = 24;
export const fontSizeMedium = 22;
export const fontSizeSmall = 16;

export enum mooTextType {
  NORMAL = 0,
  TITLE = 1,
}

// Generic UI

export const standardComponentHeight = 40;
export const standardSpacing = 8;
export const minimumCardWidth = 520; // Minimum width required for cards (e.g. in a multi-column waterFlow)
export const textInputSlimHeight = 36;

export const meowFlexOptions: FlexOptions = {
  wrap: FlexWrap.Wrap,
  space: { main: LengthMetrics.vp(standardSpacing), cross: LengthMetrics.vp(standardSpacing) },
  alignItems: ItemAlign.Center
};

export enum meowThemeColorType {
  PRIMARY = 0,
  SECONDARY = 1,
  FONT = 2,
}

// Tabs

/**
 * Default width for vertical tabs.
 */
export const defaultTabsVerticalWidth = 260;

/**
 * Default width for vertical tabs when shrunk.
 */
export const defaultTabsVerticalShrunkWidth = 32;

// Buttons

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
  SEARCH_IN_PAGE = 'SIP',
  EXTENSIONS = 'EXT'
}

/**
 * The matches from button type to their icons.
 * Valid for both MeowButtons and the sidebar buttons.
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
unifiedButtonIconMatches.set(UnifiedButtonsType.SEARCH_IN_PAGE, $r('sys.symbol.doc_text_badge_magnifyingglass'));
unifiedButtonIconMatches.set(UnifiedButtonsType.EXTENSIONS, $r('sys.symbol.root'));

/**
 * Gets the icon of a button.
 * Note that this is used by MeowButtons and the sidebar buttons.
 *
 * @param code The button to get the icon of.
 * @returns The icon of the button.
 * @see MeowSidebar entry/src/main/ets/components/parts/Sidebar/MeowSidebar.ets and its affiliates.
 */
export function getButtonIcon(code: string, fallback: Resource = $r('sys.symbol.questionmark_circle')): Resource {
  return unifiedButtonIconMatches.get(code) ?? fallback;
}

/**
 * The default side length of MooSymbolButtons / MeowButtons (basically anythiong built around icon Symbols)
 */
export const defaultMooSymbolSize = 31;

// MeowButtons

/**
 * All available buttons for MeowButtons.
 * Specially built for meowButtons.
 */
export const meowButtonsIconArray: [string, Resource][] = Array.from(unifiedButtonIconMatches.entries());

// Side bar

/**
 * All available pre-set content / panels for the sidebar.
 */
export const sidebarContentIconArray: string[] = [
  UnifiedButtonsType.BOOKMARKS,
  UnifiedButtonsType.HISTORIES,
  UnifiedButtonsType.SCRATCHING_BOARD,
  UnifiedButtonsType.DOWNLOADS
];

export const sidebarContentIconSet = new Set(sidebarContentIconArray);

/**
 * Default sidebar width.
 */
export const defaultSidebarWidth = 380;

/**
 * Default sidebar width when shrunk.
 */
export const defaultSidebarShrunkWidth = 32;

// Search in page

export const searchInPageInputId = `MeowSearchInPage_input`;
