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
