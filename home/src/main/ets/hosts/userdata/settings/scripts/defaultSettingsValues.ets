import { getRandomEmoticon } from "../../../../catstypicalframework/utils/meow";
import { UnifiedButtonsType } from "../../../../components/constants";

/**
 * Default user agents in a specified string format.
 * @returns Firefox, Chrome and Edge.
 * @example 'Firefox Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0'
 * */
export function defaultUserAgents() {
  let result = [
    "HW Browser 132\nMozilla/5.0 (PC; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 ArkWeb/6.0.0.107 HuaweiBrowser/233.1.9.311",
    "Firefox NT 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0",
    "Edge NT 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 Edg/130.0.0.0",
    "Chrome NT 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36",
    "Chrome Android 132\nMozilla/5.0 (Linux; Android 12; ALN-AL80 Build/5.0.0.107) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Mobile Safari/537.36",
  ];
  return result.join("\n");
}

/**
 * The default name of a window.
 * @returns 'Foxy Meowy Dodgy! Welcome to a new window!'
 * */
export function defaultNewWindowName(): string {
  return getRandomEmoticon();
}

/**
 * Preset search engines in a specified string format.
 * @returns Baidu and Google.
 * @example 'Bing\nhttps://www.cn.bing.com/search?q=%s'
 * */
export function presetSearchEngines() {
  let result = [
    "Baidu\nhttps://www.baidu.com/s?wd=%s",
    "Google\nhttps://www.google.com/search?q=%s",
  ];
  return result.join("\n");
}

/**
 * The single default search engine.
 * @returns 'https://bing.com/search?q=%s'
 * */
export function defaultSearchEngine() {
  return 'https://bing.com/search?q=%s';
}

// Defaults for the button system.

export function defaultButtonsControl() {
  return [UnifiedButtonsType.BACKWARD, UnifiedButtonsType.FORWARD, UnifiedButtonsType.REFRESH, UnifiedButtonsType.HOME].join('\n');
}

export function defaultButtonsAddressBarOnFocus() {
  return [UnifiedButtonsType.GO].join('\n');
}

export function defaultButtonsAddressBar() {
  return [UnifiedButtonsType.ADDRESS_KEYWORD_EXPAND, UnifiedButtonsType.ADDRESS_KEYWORD_SWITCH, UnifiedButtonsType.RE_SEARCH].join('\n');
}

export function defaultButtonsTitle() {
  return [UnifiedButtonsType.MORE, UnifiedButtonsType.TABS, UnifiedButtonsType.SIDEBAR, UnifiedButtonsType.SETTINGS].join('\n');
}

/**
 * Returns the default buttons set up for More Panel. Contains no meowButtonsType.EXTENSIONS.
 * @returns The set up array.
 */
export function defaultButtonsMore() {
  return [UnifiedButtonsType.ZONES, UnifiedButtonsType.ORIENTATION, UnifiedButtonsType.SAVE, UnifiedButtonsType.PRINT, UnifiedButtonsType.DARK, UnifiedButtonsType.COOKIES, UnifiedButtonsType.IMAGES, UnifiedButtonsType.JAVASCRIPTS, UnifiedButtonsType.ADBLOCKER, UnifiedButtonsType.HISTORIES, UnifiedButtonsType.USERAGENTS, UnifiedButtonsType.QRCODE, UnifiedButtonsType.FULLSCREEN, UnifiedButtonsType.SEARCH_IN_PAGE, UnifiedButtonsType.BOOKMARKS, UnifiedButtonsType.DOWNLOADS, UnifiedButtonsType.SCRATCHING_BOARD, UnifiedButtonsType.ZOOM_IN, UnifiedButtonsType.ZOOM_OUT].join('\n');
}

/**
 * These buttons are a bit different from the traditional meowButtons. They are used in the sidebar.
 * @returns A series of buttons.
 */
export function defaultButtonsSidebar() {
  return [
    '\n' + UnifiedButtonsType.BOOKMARKS,
    '\n' + UnifiedButtonsType.HISTORIES,
    '\n' + UnifiedButtonsType.SCRATCHING_BOARD,
    '\n' + UnifiedButtonsType.DOWNLOADS
  ].join('\n');
}
