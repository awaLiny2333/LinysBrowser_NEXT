import { meow, meowLevel } from "./catsLogger";
import { ColorMetrics } from "@kit.ArkUI";

/**
 * Analyses a ResourceStr and converts it to a string object.
 * @param resourceStr A Resource, indicating the identifier of the ResourceStr.
 * @returns A string, the string content retrieved.
 * @example resource_to_string($r('app.string.Whats_new_content_1'))
 * */
export function resource2String(resourceStr: Resource, context: Context) {
  try {
    return context.resourceManager.getStringSync(resourceStr.id);
  } catch (error) {
    console.error('[resource_to_string] ' + error);
    return 'meow Error!';
  }
}

/**
 * Converts color to color metrics style.
 * @param c The color.
 * @returns The color metrics.
 */
export function resourceColor2Metrics(c: ResourceColor) {
  try {
    return ColorMetrics.resourceColor(c);
  } catch (e) {
    meow(`colorMetrics2Color: ${e}`, 'colorMetrics2Color', meowLevel.ERROR);
    return undefined;
  }
}

/**
 * Converts file type to symbol.
 * @param mimeType 
 * @returns
 */
export function symbolForFileType(mimeType: string) {
  if (mimeType.startsWith('image/')) {
    return $r('sys.symbol.picture');
  } else if (mimeType.startsWith('video/')) {
    return $r('sys.symbol.video');
  } else if (mimeType.startsWith('audio/')) {
    return $r('sys.symbol.music');
  } else if (mimeType.startsWith('text/')) {
    return $r('sys.symbol.doc_text');
  } else if (mimeType.startsWith('application/')) {
    return $r('sys.symbol.square_grid_2x2_checkmark_topleft_filled');
  } else {
    return $r('sys.symbol.doc');
  }
}
