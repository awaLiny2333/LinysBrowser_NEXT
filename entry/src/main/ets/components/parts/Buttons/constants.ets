/**
 * The scripts for the new buttons system!
 */

/**
 * Important buttons providing key features in the app.
 * No matter what, the settings button ('SET') must be in one of the slots.
 */
export enum meowButtons {
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
  ROTATE = 'RTT',
  EXTENSIONS = 'EXT'
}

export const buttonIconMatches: Map<meowButtons, Resource> = new Map();
buttonIconMatches.set(meowButtons.BACKWARD, $r('sys.symbol.arrow_left'));
buttonIconMatches.set(meowButtons.FORWARD, $r('sys.symbol.arrow_right'));
buttonIconMatches.set(meowButtons.REFRESH, $r('sys.symbol.arrow_clockwise'));
buttonIconMatches.set(meowButtons.HOME, $r('sys.symbol.house'));
buttonIconMatches.set(meowButtons.GO, $r('sys.symbol.arrow_up_right'));
buttonIconMatches.set(meowButtons.ADDRESS_KEYWORD_SWITH, $r('sys.symbol.text_and_t'));
buttonIconMatches.set(meowButtons.RE_SEARCH, $r('sys.symbol.magnifyingglass'));
buttonIconMatches.set(meowButtons.MORE, $r('sys.symbol.dot_grid_2x2'));
buttonIconMatches.set(meowButtons.SCRATCHING_BOARD, $r('sys.symbol.doc_rectify'));
buttonIconMatches.set(meowButtons.TABS, $r('sys.symbol.rectangle_stack'));
buttonIconMatches.set(meowButtons.BOOKMARKS, $r('sys.symbol.bookmark'));
buttonIconMatches.set(meowButtons.DOWNLOADS, $r('sys.symbol.download'));
buttonIconMatches.set(meowButtons.SETTINGS, $r('sys.symbol.gearshape'));
buttonIconMatches.set(meowButtons.FULLSCREEN, $r('sys.symbol.arrow_up_left_and_arrow_down_right'));
buttonIconMatches.set(meowButtons.QRCODE, $r('sys.symbol.qrcode'));
buttonIconMatches.set(meowButtons.USERAGENTS, $r('sys.symbol.label'));
buttonIconMatches.set(meowButtons.HISTORY, $r('sys.symbol.arrow_counterclockwise_clock'));
buttonIconMatches.set(meowButtons.ADBLOCKER, $r('sys.symbol.ad_circle_slash'));
buttonIconMatches.set(meowButtons.JAVASCRIPTS, $r('sys.symbol.slider_vertical_3'));
buttonIconMatches.set(meowButtons.IMAGES, $r('sys.symbol.picture_on_square_1'));
buttonIconMatches.set(meowButtons.COOKIES, $r('sys.symbol.tracking_cookie_interception'));
buttonIconMatches.set(meowButtons.DARK, $r('sys.symbol.star_2_moon'));
buttonIconMatches.set(meowButtons.PRINT, $r('sys.symbol.printer'));
buttonIconMatches.set(meowButtons.SAVE, $r('sys.symbol.save'));
buttonIconMatches.set(meowButtons.ROTATE, $r('sys.symbol.rectangle_portrait_rotate'));
buttonIconMatches.set(meowButtons.EXTENSIONS, $r('sys.symbol.root'));

export const buttonIconArray: [meowButtons, Resource][] = Array.from(buttonIconMatches.entries());

/**
 * Gets the icon of a button.
 * @param button The button to get the icon of.
 * @returns The icon of the button.
 */
export function getButtonIcon(button: meowButtons): Resource {
  return buttonIconMatches.get(button) ?? $r('sys.symbol.questionmark_circle');
}

export const generalButtonHeight: number = 31;
