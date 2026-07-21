import lazy { print } from '@kit.BasicServicesKit';
import lazy { UIContext } from '@kit.ArkUI';
import lazy { meow, meowLevel } from './catsLogger';
import { fileDocumentPickCopySave, makeFilenameLegal } from './storage';

/**
 * Print web!
 * @param controller The webview controller.
 * */
export function printWeb(controller: WebviewController | undefined) {
  if (!controller) {
    meow('Rejected: controller is undefined', 'printWeb', meowLevel.WARN);
    return;
  }
  try {
    const fileName = makeFilenameLegal(`${controller.getTitle().substring(0, 32)} - ${controller.getUrl().substring(0, 32)}.pdf`);
    let webPrintDocadapter = controller.createWebPrintDocumentAdapter(fileName);
    print.print(`BrowseerCat_${fileName}`, webPrintDocadapter, null, UIContext.getLastFocusedUIContext()?.getHostContext());
  } catch (e) {
    meow(`Failed to print web: ${e}`, 'printWeb', meowLevel.ERROR);
  }
}

/**
 * Archive web! And call a picker to save the file.
 * @param controller The webview controller.
 */
export function archiveWeb(controller: WebviewController | undefined) {
  if (!controller) {
    meow('Rejected: controller is undefined', 'printWeb', meowLevel.WARN);
    return;
  }
  const context = UIContext.getLastFocusedUIContext()?.getHostContext()!;
  const tempName = `archiveWeb_${Date.now().toFixed(16)}.mht`;
  try {
    const overwriteName = makeFilenameLegal(`${controller.getTitle().substring(0, 32)} - ${controller.getUrl().substring(0, 32)}.mht`);
    controller.storeWebArchive(`${context.tempDir}/${tempName}`, false)
      .then(() => {
        fileDocumentPickCopySave(`${context.tempDir}/${tempName}`, overwriteName);
      })
      .catch((error: BusinessError) => {
        meow(`Failed to archive web: ${error.message}`, 'archiveWeb', meowLevel.ERROR);
      });
  } catch (e) {
    meow(`Failed to archive web: ${e}`, 'archiveWeb', meowLevel.ERROR);
  }
}
