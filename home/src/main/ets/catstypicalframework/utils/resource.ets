import { meow, meowLevel } from "./catsLogger";
import { ColorMetrics } from "@kit.ArkUI";
import { exactMimeSymbols, prefixRules } from "./resource-ext";
import { image } from "@kit.ImageKit";

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

/**
 * Converts an ICO file to image.PixelMap.
 * @param icoArrayBuffer The arrayBuffer of ICO.
 * @returns The image.PixelMap.
 * @author Huawei Developers 智能客服 @ Jul 24 2026.s
 */
export async function icoArrayBufferToPixelMap(icoArrayBuffer: ArrayBuffer) {
  // 创建 ImageSource
  const imageSource: image.ImageSource = image.createImageSource(icoArrayBuffer);
  try {
    // 可选的解码选项：指定帧索引（ICO 多帧时使用）
    const decodingOptions: image.DecodingOptions = {
      index: 0, // 使用第一帧，可调整
      // desiredSize: { width: 32, height: 32 } // 可根据需要指定尺寸
    };

    // 创建 PixelMap
    return imageSource.createPixelMap(decodingOptions)
      .then((pixelMap: image.PixelMap) => {
        return pixelMap;
      })
      .catch((error: BusinessError) => {
        console.error(`Failed to create pixelMap, code: ${error.code}, message: ${error.message}`);
        return undefined;
      })
      .finally(() => {
        try {
          imageSource.release();
        } catch (e) {
          // Nothing we can do.
        }
      });
  } catch (error) {
    console.error(`Failed to create imageSource: ${JSON.stringify(error)}`);
    return undefined;
  }
}
