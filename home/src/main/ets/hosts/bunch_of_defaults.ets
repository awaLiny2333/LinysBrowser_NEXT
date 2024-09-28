import Curves from '@ohos.curves';

export function fontSize_Large() {
  return 20;
}

export function fontSize_Normal() {
  return 16;
}

export function fontSize_Icon_Button() {
  return 25;
}

export function capsule_bar_height() {
  return 35;
}

export function minimum_block_width() {
  return 480;
}

export function animation_default() {
  let spring = Curves.springMotion(0.36, 0.8);
  let ap: AnimateParam = { curve: spring };
  return ap;
}

/** @abstract Standard popup notice duration for intervals of 10
 * */
export function animation_popup_duration() {
  return 200;
}

export function click_effect_default() {
  let ce: ClickEffect = { level: ClickEffectLevel.LIGHT };
  return ce;
}

export function home_url_default_blank() {
  let is_dark_mode = AppStorage.get('currentColorMode') as number == 0;
  return is_dark_mode ? 'meow://home_dark' : 'meow://home_light'
}
