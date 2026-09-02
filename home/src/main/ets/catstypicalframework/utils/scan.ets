import { scanBarcode, scanCore } from "@kit.ScanKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

export async function scanDefault(uiContext: UIContext) {
  let options: scanBarcode.ScanOptions = { scanTypes: [scanCore.ScanType.ALL], enableMultiMode: true, enableAlbum: true };

  try {
    return await scanBarcode.startScanForResult(uiContext.getHostContext(), options)
      .then((data: scanBarcode.ScanResult) => {
        hilog.info(0x0001, '[Scan Sample]', `Succeeded in getting ScanResult by promise with options, scanType: ${data.scanType}`);
        return data;
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0001, '[Scan Sample]', `Failed to get ScanResult by promise with options. Code: ${err.code}, message: ${err.message}`);
        return undefined;
      });
  } catch (err) {
    hilog.error(0x0001, '[Scan Sample]', `Failed to startScanForResult. Code: ${err.code}, message: ${err.message}`);
    return undefined;
  }
}
