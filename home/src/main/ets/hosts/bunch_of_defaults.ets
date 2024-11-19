import Curves from '@ohos.curves';

/**
 * Default fontSize_Extra for texts.
 *
 * Usually used on titles.
 * @returns 26
 * */
export function fontSize_Extra() {
  return 26;
}

/**
 * Default fontSize_Large for texts.
 *
 * Usually used on sub titles.
 * @returns 20
 * */
export function fontSize_Large() {
  return 20;
}

/**
 * Default fontSize_Normal for texts.
 *
 * Usually used on body parts.
 * @returns 16
 * */
export function fontSize_Normal() {
  return 16;
}

/**
 * Default fontSize_Icon_Button for HarmonyOS Symbols.
 *
 * Usually used on buttons, like linysSymbol.
 * @returns 25
 * */
export function fontSize_Icon_Button() {
  return 25;
}

/**
 * Default capsule bar height for capsule-shape components, like a capsule button.
 * @returns 35
 * */
export function capsule_bar_height() {
  return 35;
}

/**
 * Default minimum width for cards in panels, like those in settings and downloads panel.
 * @returns 480
 * */
export function minimum_card_width() {
  return 480;
}

/**
 * Default animation params.
 * @returns An AnimateParam, reading the arguments from app settings.
 * */
export function animation_default() {
  let animation_damping_coefficient = AppStorage.get('animation_damping_coefficient') as number;
  let animation_response = AppStorage.get('animation_response') as number;
  let spring = Curves.springMotion(animation_response / 100, (100 - animation_damping_coefficient) / 100);
  let ap: AnimateParam = { curve: spring };
  return ap;
}

/**
 * Standard popup notice duration for intervals of 1 millisecond, 2 seconds.
 * @returns 2000
 * */
export function animation_popup_duration() {
  return 2000;
}

/**
 * Default Click effect.
 * @returns ClickEffect = { level: ClickEffectLevel.LIGHT }
 * */
export function click_effect_default() {
  let ce: ClickEffect = { level: ClickEffectLevel.LIGHT };
  return ce;
}

/**
 * Default url of blank page.
 * @returns 'meow://home_dark' or 'meow://home_light'
 * */
export function url_default_blank() {
  let is_dark_mode = AppStorage.get('currentColorMode') as number == 0;
  return is_dark_mode ? 'meow://home_dark' : 'meow://home_light'
}

/**
 * Default search engines in a specified string format.
 * @returns Baidu and Google.
 * @example 'Bing\nhttps://www.cn.bing.com/search?q=%s'
 * */
export function default_search_engines() {
  let result = [
    "Baidu\nhttps://www.baidu.com/s?wd=%s",
    "Google\nhttps://www.google.com/search?q=%s",
  ];
  return result.join("\n");
}

/**
 * Default user agents in a specified string format.
 * @returns Firefox, Chrome and Edge.
 * @example 'Firefox Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0'
 * */
export function default_user_agents() {
  let result = [
    "Firefox Windows 132\nMozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0",
    "Chrome Windows 130\nMozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
    "Edge Windows 130\nMozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0",
  ];
  return result.join("\n");
}
