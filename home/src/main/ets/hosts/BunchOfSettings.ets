export function fontSize_Large() {
  return 20;
}

export function fontSize_Normal() {
  return 16;
}

export function fontSize_Icon_Button() {
  return 26;
}

export function animation_default() {
  let ap: AnimateParam = { duration: 250, curve: Curve.ExtremeDeceleration };
  return ap;
}

export function click_effect_default() {
  let ce: ClickEffect = { level: ClickEffectLevel.LIGHT };
  return ce;
}

export function home_url() {
  let is_dark_mode = AppStorage.get('currentColorMode') as number == 0;
  return is_dark_mode ? 'meow://home_dark' : 'meow://home_light'
}
