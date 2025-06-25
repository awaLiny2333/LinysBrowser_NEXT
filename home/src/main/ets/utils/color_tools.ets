/**
 * Converts a hsv color into rgb style.
 * @param h A number, the hue.
 * @param s A number, the saturation.
 * @param v A number, the value (of brightness).
 * @returns A number[] array, [r, g, b].
 * */
export function hsv2rgb(h: number, s: number, v: number): number[] {
  h = Math.max(0, Math.min(360, h));
  s = Math.max(0, Math.min(100, s)) / 100;
  v = Math.max(0, Math.min(100, v)) / 100;

  const i = Math.floor(h / 60);
  const f = (h / 60) - i;
  const p = v * (1 - s);
  const q = v * (1 - f * s);
  const t = v * (1 - (1 - f) * s);

  let r: number = 0, g: number = 0, b: number = 0;

  switch (i % 6) {
    case 0:
      r = v;
      g = t;
      b = p;
      break;
    case 1:
      r = q;
      g = v;
      b = p;
      break;
    case 2:
      r = p;
      g = v;
      b = t;
      break;
    case 3:
      r = p;
      g = q;
      b = v;
      break;
    case 4:
      r = t;
      g = p;
      b = v;
      break;
    case 5:
      r = v;
      g = p;
      b = q;
      break;
  }

  r = Math.round(r * 255);
  g = Math.round(g * 255);
  b = Math.round(b * 255);

  return [r, g, b];
}

/**
 * Converts an rgb style color into hex format.
 * @param r A number, standing for the red value of the original rgb color.
 * @param g A number, standing for the green value of the original rgb color.
 * @param b A number, standing for the blue value of the original rgb color.
 * @returns A string, the hex color. Like #rrggbb.
 * */
export function rgb2hex(r: number, g: number, b: number) {
  let hex = ("#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)).toUpperCase();
  return hex;
}

/**
 * Converts a hsv number style color into hex format.
 * @param hsv A number[] array, [hue, saturation, value] standing for the hsv color in number style.
 * @returns A string, the hex color. Like #rrggbb.
 * */
export function hsv2hex(hsv: number[]) {
  let rgb: number[] = hsv2rgb(hsv[0], hsv[1], hsv[2]);
  let hex: string = rgb2hex(rgb[0], rgb[1], rgb[2]);
  return hex;
}

/**
 * Converts a hex string color to rgb format.
 * @param hex A string, in the format of #______.
 * @returns [r, g, b] if success.
 * */
export function hex2rgb(hex: ResourceColor) {
  hex = (hex as string).toLowerCase();
  let rgb: number[] = [];
  for (let i = 1; i < 7; i += 2) {
    rgb.push(parseInt('0x' + hex.slice(i, i + 2)));
  }
  return rgb;
}

/**
 * Converts an rgb format color to hsv values.
 * @param r A number, standing for the red value of the original rgb color.
 * @param g A number, standing for the green value of the original rgb color.
 * @param b A number, standing for the blue value of the original rgb color.
 * @returns A number[] array, [h, s, v].
 * */
export function rgb2hsv(r: number, g: number, b: number) {
  r = Math.max(0, Math.min(255, r));
  g = Math.max(0, Math.min(255, g));
  b = Math.max(0, Math.min(255, b));

  const rPrime = r / 255;
  const gPrime = g / 255;
  const bPrime = b / 255;

  const max = Math.max(rPrime, gPrime, bPrime);
  const min = Math.min(rPrime, gPrime, bPrime);

  const v = max;

  let s: number;
  if (max !== 0) {
    s = (max - min) / max;
  } else {
    s = 0;
  }

  let h: number;
  const delta = max - min;
  if (delta !== 0) {
    if (rPrime === max) {
      h = (gPrime - bPrime) / delta;
    } else if (gPrime === max) {
      h = 2 + (bPrime - rPrime) / delta;
    } else {
      // bPrime === max
      h = 4 + (rPrime - gPrime) / delta;
    }

    h = Math.round(h * 60);

    if (h < 0) {
      h += 360;
    }
  } else {
    h = 0;
  }

  return [h, Math.round(s * 100), Math.round(v * 100)];
}

/**
 * Converts a hex string color to hsv values.
 * @param hex A string, the hex color.
 * @returns A number[] array, [h, s, v].
 * */
export function hex2hsv(hex: ResourceColor) {
  let rgb: number[] = hex2rgb(hex as string);
  let hsv = rgb2hsv(rgb[0], rgb[1], rgb[2]);
  return hsv;
}

/**
 * Examines a string and check if it is a legal #______ hex color.
 * @param hex A string.
 * */
export function is_legal_hex(hex: ResourceColor) {
  let digits: string[] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];
  hex = (hex as string).toUpperCase();
  if (hex[0] != "#") {
    return false;
  }
  if (hex.length != 7) {
    return false;
  }
  for (let index = 1; index < hex.length; index++) {
    if (!digits.includes(hex[index])) {
      return false;
    }
  }
  return true;
}

/**
 * Adds transparency (0-255) to a ResourceColor
 * */
export function add_transparency(color: ResourceColor, transparency: number) {
  let transparency_hex = (transparency & 0xff).toString(16).padStart(2, '0');
  return '#' + transparency_hex + (color as string).substring(1);
}
