import { fastbuffer } from "@kit.ArkTS";
import { webview } from "@kit.ArkWeb";
import { listFilesUnderDir, readArrayBufferConcurrent, saveHybrid } from "../../../../catstypicalframework/utils/storage";

/**
 * Apply all files of EasyList rules in directory of filesDir/easylist.
 * 
 * @param filesDir The filesDir.
 * @param tempDir The tempDir.
 */
export async function applyEasyListFromDisk(filesDir: string, tempDir: string) {
  const lists = await listFilesUnderDir(filesDir + '/easylist');
  if (!lists) {
    return;
  }

  let combined: string[] = [];
  for (let index = 0; index < lists.length; index++) {
    let paraBuf = await readArrayBufferConcurrent(filesDir + '/easylist/' + lists[index]);
    if (!paraBuf) {
      continue;
    }
    try {
      const para = fastbuffer.from(paraBuf).toString();
      combined.push(para);
    } catch (e) {
      console.error('[applyEasyList] Failed to read ' + lists[index] + ': ' + e);
    }
    console.log(`[applyEasyList] ${lists[index]} loaded.`);
  }

  const filePath = tempDir + '/easylist.txt';
  await saveHybrid(filePath, combined.join('\n'));
  console.warn(`[applyEasyList] Saved easylist to ${filePath}!`);
  try {
    webview.AdsBlockManager.setAdsBlockRules(filePath, true);
  } catch (e) {
    console.error('[applyEasyList] Failed: ' + e);
  }
}
