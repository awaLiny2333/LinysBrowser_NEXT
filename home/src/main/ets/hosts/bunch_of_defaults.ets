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
  let animation_damping_coefficient = AppStorage.get('animation_damping_coefficient') as number;
  let animation_response = AppStorage.get('animation_response') as number;
  let spring = Curves.springMotion(animation_response / 100, (100 - animation_damping_coefficient) / 100);
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
