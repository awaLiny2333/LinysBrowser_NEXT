import { meow, meowLevel } from "./catsLogger";
import { ColorMetrics } from "@kit.ArkUI";
import { exactMimeSymbols,prefixRules } from "./resource-ext";

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
 * Converts file type to symbol, with detailed support for common download types.
 * @param mimeType The MIME type (may contain parameters like charset).
 * @returns The HarmonyOS symbol resource.
 */
export function symbolForFileType(mimeType: string): Resource {
  const type = mimeType.split(';')[0].trim().toLowerCase(); // Cleaning: Remove parameters and convert to lowercase.

  const exactHit = exactMimeSymbols.get(type); // Prefer exact hit.
  if (exactHit) {
    return exactHit;
  }

  // Backup rules
  for (const rule of prefixRules) {
    if (type.startsWith(rule.prefix)) {
      return rule.symbol;
    }
  }
  return $r('sys.symbol.doc');
}
