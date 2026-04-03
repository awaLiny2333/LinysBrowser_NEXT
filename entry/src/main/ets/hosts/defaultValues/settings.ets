/**
 * Default user agents in a specified string format.
 * @returns Firefox, Chrome and Edge.
 * @example 'Firefox Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0'
 * */
export function defaultUserAgents() {
  let result = [
    "Huawei Browser 132\nMozilla/5.0 (PC; OpenHarmony 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 ArkWeb/6.0.0.107 HuaweiBrowser/233.1.9.311",
    "Firefox Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0",
    "Edge Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 Edg/130.0.0.0",
    "Chrome Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36",
    "Chrome Android 132\nMozilla/5.0 (Linux; Android 12; ALN-AL80 Build/5.0.0.107) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Mobile Safari/537.36",
  ];
  return result.join("\n");
}

/**
 * The default name of a window.
 * @returns 'Foxy Meowy Dodgy! Welcome to a new window!'
 * */
export function defaultNewWindowName(): string {
  return 'Meowy Default Name!';
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