import lazy { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';

/**
 * Copy text to clipboard.
 * @param content The content.
 */
export function copyText(content: string) {
  let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
  let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);

  systemPasteboard.setData(pasteData).then(() => {
    console.info('[copyText] Succeeded in setting PasteData. Copied \"' + content + "\"");
  }).catch((err: BusinessError) => {
    console.error('[copyText] Failed to set PasteData. Cause: ' + err.message);
  });
}

/**
 * Copy image to clipboard.
 * @param pixelMap The image.PixelMap.
 * @param mime The mime type. Try using mimeOfFileName() from storage.ets.
 */
export async function copyImage(pixelMap: image.PixelMap): Promise<void> {
  let systemPasteBoard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
  let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_PIXELMAP, pixelMap);
  
  try {
    await systemPasteBoard.setData(pasteData);
    console.log(`[copyImage] Copied arrayBuffer to clipboard!`);
  } catch (e) {
    console.error(`[copyImage] Failed to copy arrayBuffer to clipboard: ${e}`);
  }
}
