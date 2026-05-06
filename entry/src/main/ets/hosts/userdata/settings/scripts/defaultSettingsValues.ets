import { getRandomEmoticon } from "../../../../catstypicalframework/utils/meow";
import { meowButtonsType } from "../../../../components/parts/Buttons/constants";

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
 * Default link of blank page.
 * @returns 'meow://home'
 * */
export function urlDefaultBlank() {
  return 'meow://home';
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
  return [meowButtonsType.BACKWARD, meowButtonsType.FORWARD, meowButtonsType.REFRESH, meowButtonsType.HOME].join('\n');
}

export function defaultButtonsAddressBarOnFocus() {
  return [meowButtonsType.GO].join('\n');
}

export function defaultButtonsAddressBar() {
  return [meowButtonsType.ADDRESS_KEYWORD_EXPAND, meowButtonsType.ADDRESS_KEYWORD_SWITCH, meowButtonsType.RE_SEARCH].join('\n');
}

export function defaultButtonsTitle() {
  return [meowButtonsType.MORE, meowButtonsType.SCRATCHING_BOARD, meowButtonsType.TABS, meowButtonsType.BOOKMARKS, meowButtonsType.DOWNLOADS, meowButtonsType.SETTINGS].join('\n');
}

/**
 * Returns the default buttons set up for More Panel. Contains no meowButtonsType.EXTENSIONS.
 * @returns The set up array.
 */
export function defaltButtonsMore() {
  return [meowButtonsType.ORIENTATION, meowButtonsType.SAVE, meowButtonsType.PRINT, meowButtonsType.DARK, meowButtonsType.COOKIES, meowButtonsType.IMAGES, meowButtonsType.JAVASCRIPTS, meowButtonsType.ADBLOCKER, meowButtonsType.HISTORY, meowButtonsType.USERAGENTS, meowButtonsType.QRCODE, meowButtonsType.FULLSCREEN].join('\n');
}
