/**
 * All functions about app backup.
 */

import lazy { zlib } from "@kit.BasicServicesKit";
import lazy BuildProfile from "BuildProfile";
import lazy { meow, meowLevel } from "../../../../catstypicalframework/utils/catsLogger";
import lazy { dirCopy, ensureDirectoryExist, fileCopy, fileDocumentPick2Path, fileDocumentPickCopySave, fileDocumentPickSave } from "../../../../catstypicalframework/utils/storage";
import lazy { getMySettings } from "../../../../components/settings";
import lazy { meowManagedSettingsInitResult } from "../../../userdata/settings/classes/meowManagedSettings";

export enum importResult {
  OK,
  PARTIAL_OK,
  PICK_FAIL,
  DECOMPRESS_FAIL,
  DECODE_FAIL
}

const filesToImport = [
  'homepage_background_arrayBuffer',
  'html_bookmarks.html',
  'settings.json.browsercatsettings.txt'
];

const dirsToImport = [
  'continues',
  'easylist',
  'faultlogs',
  'history',
  'history-index',
  'zones'
];

export interface importEverythingResult {
  result: importResult;
  importedFiles: string[];
  importedDirs: string[];
  failedFiles: string[];
  failedDirs: string[];
}

/**
 * Export settings to a file, calling a picker.
 */
export async function exportSettings() {
  const jsonContents = getMySettings().toString();
  await fileDocumentPickSave(`settings.json.${BuildProfile.VERSION_NAME}.browsercatsettings`, jsonContents);
}

/**
 * Import settings from a file, calling a picker.
 * @returns A meowManagedSettingsInitResult.
 */
export async function importSettings(): Promise<meowManagedSettingsInitResult> {
  const mySettings = getMySettings();
  const result = await fileDocumentPick2Path(['browsercatsettings'], 1);
  if (result.succeed) {
    const path = result.sourcePaths![0];
    const r = await mySettings.initFrom(path);
    if (r.result == importResult.OK) {
      // Great success!
    } else {
      await mySettings.initFrom(); // Reset to the original settings.
    }
    mySettings.requestSaveToDisk();
    return r;
  }
  return { result: importResult.PICK_FAIL, changes: [] };
}

/**
 * Export everything to a file, calling a picker.
 * @param context The context.
 * @returns True or false
 */
export async function exportEverything(context: Context): Promise<boolean> {
  const filesDir = context.filesDir;
  const tempDir = context.tempDir;
  const fileName = `profile.zip.${BuildProfile.VERSION_NAME}.browsercatprofile`;
  const zipPath: string = `${tempDir}/${fileName}.zip`;

  // Zip everything in sandbox to tempdir.
  const options: zlib.Options = {
    level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION,
    memLevel: zlib.MemLevel.MEM_LEVEL_DEFAULT,
    strategy: zlib.CompressStrategy.COMPRESS_STRATEGY_DEFAULT_STRATEGY
  };
  try {
    await zlib.compressFile(filesDir, zipPath, options);
    meow(`await zlib.compressFile("${filesDir}", "${zipPath}", options); OK: ${zipPath}`, 'exportEverything');
    try {
      return await fileDocumentPickCopySave(zipPath, fileName);
    } catch (e) {
      meow(`await fileDocumentPickCopySave("${zipPath}"); failed: ${(e as BusinessError).code} - ${(e as BusinessError).message}`, 'exportEverything', meowLevel.ERROR);
      return false;
    }
  } catch (err) {
    meow(`await zlib.compressFile("${filesDir}", "${zipPath}", options); failed: ${(err as BusinessError).code} - ${(err as BusinessError).message}`, 'exportEverything', meowLevel.ERROR);
    return false;
  }
}

/**
 * Import everything from a file, calling a picker.
 * @param context The context.
 * @returns The result.
 */
export async function importEverything(context: Context): Promise<importEverythingResult> {
  const result = await fileDocumentPick2Path(['browsercatprofile'], 1);
  if (!result.succeed) {
    return { result: importResult.PICK_FAIL, importedFiles: [], importedDirs: [], failedFiles: [], failedDirs: [] };
  }

  const filesDir = context.filesDir;
  const zipPath = result.sourcePaths![0];
  const tempDir = context.tempDir;
  const tempExtractionDir = `${tempDir}/import-everything-${Date.now().toString(16)}`;

  // Extract to temp dir
  await ensureDirectoryExist(tempExtractionDir);
  try {
    await zlib.decompressFile(zipPath, tempExtractionDir);

    let succeededFiles: string[] = [];
    let failedFiles: string[] = [];
    let succeededDirectories: string[] = [];
    let failedDirectories: string[] = [];

    // Copy (overwrite) one by one
    for (const file of filesToImport) {
      const r = await fileCopy(`${tempExtractionDir}/${file}`, `${filesDir}/${file}`, true);
      if (r) {
        succeededFiles.push(file);
      } else {
        failedFiles.push(file);
      }
    }
    for (const dir of dirsToImport) {
      const r = await dirCopy(`${tempExtractionDir}/${dir}`, `${filesDir}`, true);
      if (r) {
        succeededDirectories.push(dir);
      } else {
        failedDirectories.push(dir);
      }
    }

    // Summary
    const result = (failedFiles.length + failedDirectories.length > 0) ? importResult.PARTIAL_OK : importResult.OK;
    meow(`await zlib.decompressFile("${zipPath}", "${tempExtractionDir}"); OK. Result ${result}, importedFiles ${succeededFiles.length}, failedFiles ${failedFiles.length}, importedDirs ${succeededDirectories.length}, failedDirs ${failedDirectories.length}`, 'importEverything');
    return { result: result, importedFiles: succeededFiles, failedFiles: failedFiles, importedDirs: succeededDirectories, failedDirs: failedDirectories };

  } catch (e) {
    // Extract error
    meow(`await zlib.decompressFile("${zipPath}", "${tempExtractionDir}"); failed: ${e}`, 'importEverything', meowLevel.ERROR);
    return { result: importResult.DECOMPRESS_FAIL, importedFiles: [], failedFiles: filesToImport, importedDirs: [], failedDirs: dirsToImport };
  }
}
