import { fastbuffer } from "@kit.ArkTS";
import { webview } from "@kit.ArkWeb";
import { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import { listFilesUnderDir, readArrayBufferConcurrent, saveHybrid } from "../../../../catstypicalframework/utils/storage";
import { adBlockExceptions } from "../settings";
import { UIContext } from "@kit.ArkUI";

/**
 * Apply ad blocker exceptions.
 */
export function applyAdBlockerExceptions() {
  try {
    webview.AdsBlockManager.clearAdsBlockDisallowedList();
    const array = Array.from(adBlockExceptions());
    webview.AdsBlockManager.addAdsBlockDisallowedList(array);
    meow(`webview.AdsBlockManager.addAdsBlockDisallowedList(adBlockExceptions()); success: [${array.join(', ')}]`, 'applyAdBlockerExceptions', meowLevel.INFO);
  } catch (e) {
    meow(`webview.AdsBlockManager.addAdsBlockDisallowedList(adBlockExceptions()); failed: ${e}`, 'applyAdBlockerExceptions', meowLevel.ERROR);
  }
}

/**
 * Apply all files of EasyList rules in directory of filesDir/easylist.
 *
 * @param filesDir The filesDir.
 * @param tempDir The tempDir.
 */
export async function applyEasyListFromDisk() {
  const context = UIContext.getLastFocusedUIContext()?.getHostContext();
  if (!context) return;

  const filePath = await combineEasyListToDisk(context.filesDir, context.tempDir);
  try {
    webview.AdsBlockManager.setAdsBlockRules(filePath, true);
  } catch (e) {
    meow(`webview.AdsBlockManager.setAdsBlockRules("${filePath}", true); Failed: ${e}`, 'applyEasyList', meowLevel.ERROR);
  }
}

/**
 * Combine all EasyList rule files into one, deduplicate, and save to disk.
 * Reads files concurrently, sorts filenames, and removes duplicate rules.
 * Finally logs how many lines were kept and how many duplicates were dropped.
 *
 * @param filesDir - base directory for the easylist folder (filesDir + '/easylist')
 * @param tempDir  - temp directory for the output file (tempDir + '/easylist.txt')
 * @returns the path of the combined file
 * @author DeepSeek Web @ May 27 2026
 */
async function combineEasyListToDisk(filesDir: string, tempDir: string) {
  // 1. Get the list of rule files, sorted for a predictable merge order
  const lists = await listFilesUnderDir(filesDir + '/easylist');
  if (!lists || lists.length === 0) return;

  lists.sort(); // consistent ordering

  // 2. Read all files concurrently – much faster than reading one by one
  const contents = await Promise.all(
    lists.map(async (file) => {
      const fullPath = filesDir + '/easylist/' + file;
      try {
        const paraBuf = await readArrayBufferConcurrent(fullPath);
        if (!paraBuf) return '';
        return fastbuffer.from(paraBuf).toString();
      } catch (e) {
        meow(`Failed to read [${file}]: ${e}`, 'applyEasyList', meowLevel.ERROR);
        return '';
      }
    })
  );

  // 3. Split combined content into individual lines
  const allLines = contents.filter(text => text !== '').join('\n').split('\n');

  // 4. Deduplicate lines, preserving metadata (comments/headers)
  const seen = new Set<string>();
  const deduplicatedLines: string[] = [];

  for (const line of allLines) {
    // Always keep comment/header lines and empty lines – they aren't rules
    if (line.startsWith('!') || line.trim() === '') {
      deduplicatedLines.push(line);
      continue;
    }

    // For actual filter rules, keep the first occurrence and skip duplicates
    if (!seen.has(line)) {
      seen.add(line);
      deduplicatedLines.push(line);
    }
  }

  // 5. Save the clean, deduplicated list
  const combined = deduplicatedLines.join('\n');
  const filePath = tempDir + '/easylist.txt';
  await saveHybrid(filePath, combined);

  // 6. Report the grooming results
  const totalLines = allLines.length;
  const savedLines = deduplicatedLines.length;
  const droppedLines = totalLines - savedLines;
  meow(
    `Saved easylist to ${filePath}! ` +
    `Total lines: ${totalLines}, kept: ${savedLines}, duplicates dropped: ${droppedLines} (${(droppedLines / totalLines * 100).toFixed(2)}%).`,
    'applyEasyList'
  );

  return filePath;
}
