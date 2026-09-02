import { scanBarcode, scanCore } from "@kit.ScanKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

/**
 * Calls the default scan interface to scan and return results.
 * @param uiContext
 * @returns
 */
export async function scanDefault(uiContext: UIContext) {
  let options: scanBarcode.ScanOptions = { scanTypes: [scanCore.ScanType.ALL], enableMultiMode: true, enableAlbum: true };

  if (canIUse("SystemCapability.Multimedia.Scan.ScanBarcode")) {
    return await scanBarcode.startScanForResult(uiContext.getHostContext(), options)
      .then((data: scanBarcode.ScanResult) => {
        hilog.info(0x0001, '[Scan Sample]', `Succeeded in getting ScanResult by promise with options, scanType: ${data.scanType}`);
        return data;
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0001, '[Scan Sample]', `Failed to get ScanResult by promise with options. Code: ${err.code}, message: ${err.message}`);
        return undefined;
      });
  } else {
    // Fallback for unsupported SystemCapability
    return undefined;
  }
}
