/**
 * The scripts for the new buttons system!
 */

/**
 * Important buttons providing key features in the app.
 * No matter what, the settings button ('SET') must be in one of the slots.
 */
export enum meowButtonsType {
  BACKWARD = 'BAK',
  FORWARD = 'FOR',
  REFRESH = 'REF',
  HOME = 'HOM',
  GO = 'GOO',
  ADDRESS_KEYWORD_SWITH = 'AKS', // Only shows when search mode discovered.
  RE_SEARCH = 'RES', // Only shows when search mode discovered.
  MORE = 'MOR',
  SCRATCHING_BOARD = 'SCB', // Only shows when the Scratching Board is not empty.
  TABS = 'TAB',
  BOOKMARKS = 'BKM',
  DOWNLOADS = 'DNL',
  SETTINGS = 'SET',
  FULLSCREEN = 'FUL',
  QRCODE = 'QRC',
  USERAGENTS = 'UAG',
  HISTORY = 'HIS',
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

export const buttonIconMatches: Map<meowButtonsType, Resource> = new Map();
buttonIconMatches.set(meowButtonsType.BACKWARD, $r('sys.symbol.arrow_left'));
buttonIconMatches.set(meowButtonsType.FORWARD, $r('sys.symbol.arrow_right'));
buttonIconMatches.set(meowButtonsType.REFRESH, $r('sys.symbol.arrow_clockwise'));
buttonIconMatches.set(meowButtonsType.HOME, $r('sys.symbol.house'));
buttonIconMatches.set(meowButtonsType.GO, $r('sys.symbol.arrow_up_right'));
buttonIconMatches.set(meowButtonsType.ADDRESS_KEYWORD_SWITH, $r('sys.symbol.text_and_t'));
buttonIconMatches.set(meowButtonsType.RE_SEARCH, $r('sys.symbol.magnifyingglass'));
buttonIconMatches.set(meowButtonsType.MORE, $r('sys.symbol.dot_grid_2x2'));
buttonIconMatches.set(meowButtonsType.SCRATCHING_BOARD, $r('sys.symbol.doc_rectify'));
buttonIconMatches.set(meowButtonsType.TABS, $r('sys.symbol.rectangle_stack'));
buttonIconMatches.set(meowButtonsType.BOOKMARKS, $r('sys.symbol.bookmark'));
buttonIconMatches.set(meowButtonsType.DOWNLOADS, $r('sys.symbol.download'));
buttonIconMatches.set(meowButtonsType.SETTINGS, $r('sys.symbol.gearshape'));
buttonIconMatches.set(meowButtonsType.FULLSCREEN, $r('sys.symbol.arrow_up_left_and_arrow_down_right'));
buttonIconMatches.set(meowButtonsType.QRCODE, $r('sys.symbol.qrcode'));
buttonIconMatches.set(meowButtonsType.USERAGENTS, $r('sys.symbol.label'));
buttonIconMatches.set(meowButtonsType.HISTORY, $r('sys.symbol.arrow_counterclockwise_clock'));
buttonIconMatches.set(meowButtonsType.ADBLOCKER, $r('sys.symbol.ad_circle_slash'));
buttonIconMatches.set(meowButtonsType.JAVASCRIPTS, $r('sys.symbol.slider_vertical_3'));
buttonIconMatches.set(meowButtonsType.IMAGES, $r('sys.symbol.picture_on_square_1'));
buttonIconMatches.set(meowButtonsType.COOKIES, $r('sys.symbol.tracking_cookie_interception'));
buttonIconMatches.set(meowButtonsType.DARK, $r('sys.symbol.star_2_moon'));
buttonIconMatches.set(meowButtonsType.PRINT, $r('sys.symbol.printer'));
buttonIconMatches.set(meowButtonsType.SAVE, $r('sys.symbol.save'));
buttonIconMatches.set(meowButtonsType.ORIENTATION, $r('sys.symbol.rectangle_portrait_rotate'));
buttonIconMatches.set(meowButtonsType.EXTENSIONS, $r('sys.symbol.root'));

export const buttonIconArray: [meowButtonsType, Resource][] = Array.from(buttonIconMatches.entries());

/**
 * Gets the icon of a button.
 * @param button The button to get the icon of.
 * @returns The icon of the button.
 */
export function getButtonIcon(button: meowButtonsType): Resource {
  return buttonIconMatches.get(button) ?? $r('sys.symbol.questionmark_circle');
}

export const generalButtonHeight: number = 31;
