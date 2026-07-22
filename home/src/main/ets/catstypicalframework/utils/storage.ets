import lazy { common, OpenLinkOptions } from '@kit.AbilityKit';
import lazy { taskpool, util } from '@kit.ArkTS';
import lazy { BusinessError } from '@kit.BasicServicesKit';
import lazy { fileIo, fileUri, picker } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import lazy { photoAccessHelper } from '@kit.MediaLibraryKit';
import lazy { http } from '@kit.NetworkKit';
import lazy { detectBarcode } from '@kit.ScanKit';
import lazy { meow, meowLevel } from './catsLogger';
import lazy { MIME_TYPES_MAP_LITE } from './storage-ext';

// Picker
/**
 * Retrieve the download directory.
 * @returns The download directory path.
 */
export async function retrieveDownloadDirectory(context: Context) {
  const documentSaveOptions = new picker.DocumentSaveOptions();
  documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
  const documentViewPicker = new picker.DocumentViewPicker(context);
  return documentViewPicker.save(documentSaveOptions)
    .then((uris: Array<string>) => {
      console.log(`[retrieveDownloadDirectory] DocumentViewPicker.save successfully, uris[0]: ${uris[0]}`);
      return uris[0];
    })
    .catch((e: BusinessError) => {
      console.error(`[retrieveDownloadDirectory] DocumentViewPicker.save failed with err: ${e}`);
      return undefined;
    });
}

/**
 * Save a text file to device storage, pulling up a DocumentViewPicker.
 * @param fileName A string, setting the file's name.
 * @param content A string or an ArrayBuffer, fills the file's content.
 * @returns If succeeded.
 */
export async function fileDocumentPickSave(fileName: string, content: string | ArrayBuffer): Promise<boolean | undefined> {
  try {
    const ext = extensionOfName(fileName);
    return (new picker.DocumentViewPicker())
      .save({
        newFileNames: [fileName],
        fileSuffixChoices: [`.${ext}`]
      })
      .then(async (pickedUris) => {
        const result = await saveHybrid(pickedUris[0], content, true);
        console.info(`[fileDocumentPickSave] DocumentViewPicker.save successfully, uris[0]: ${pickedUris[0]}`);
        return result;
      });
  } catch (e) {
    console.error(`[fileDocumentPickSave] DocumentViewPicker failed: ${e}`);
    return undefined;
  }
}

export interface meowReadPickResult {
  succeed: boolean;
  sourcePaths?: string[];
}

/**
 * Pick a file from device storage, pulling up a DocumentViewPicker.
 * @returns Majorly the path.
 * */
export async function fileDocumentPick2Path(fileSuffixFilters: string[] = [".meow"], maxSelectNumber: number = 1): Promise<meowReadPickResult> {
  if (!canIUse("SystemCapability.FileManagement.UserFileService")) {
    console.error('[fileDocumentPick2Path] DocumentViewPicker.select failed. canIUse("SystemCapability.FileManagement.UserFileService") is false!');
    return { succeed: false } as meowReadPickResult;
  }

  return (new picker.DocumentViewPicker())
    .select({
      maxSelectNumber: maxSelectNumber,
      fileSuffixFilters: fileSuffixFilters
    })
    .then((documentSelectResult) => {
      let sourcePaths: string[] = [];

      if (documentSelectResult.length == 0) {
        console.info(`[fileDocumentPick2Path] DocumentViewPicker.select Selected nothing. documentSelectResult = ${documentSelectResult}`);
        return { succeed: false } as meowReadPickResult;
      }

      for (let index = 0; index < documentSelectResult.length; index++) {
        const sourcePath = uri_2_path(documentSelectResult[index]);
        console.info(`[fileDocumentPick2Path] DocumentViewPicker.select successfully, documentSelectResult sourcePath[${index}]: ${sourcePath}`);
        sourcePaths.push(sourcePath);
      }

      return {
        succeed: true,
        sourcePaths: sourcePaths,
      } as meowReadPickResult;
    })
    .catch((e: BusinessError) => {
      console.error(`[fileDocumentPick2Path] DocumentViewPicker.select failed with err: ${e}`);
      return { succeed: false } as meowReadPickResult;
    });
}

/**
 * Pick a place to save the copy of an existing file, pulling up a DocumentViewPicker.
 * @param sourcePath The source path.
 * @param nameOverwrite Overwrite name.
 * @returns True or false.
 */
export async function fileDocumentPickCopySave(sourcePath: string, nameOverwrite?: string) {
  if (!canIUse("SystemCapability.FileManagement.UserFileService")) {
    console.error('[fileDocumentPickCopySave] DocumentViewPicker.select failed. canIUse("SystemCapability.FileManagement.UserFileService") is false!');
    return true;
  }

  const fileName = nameOverwrite || fileNameOfPath(sourcePath);
  const ext = extensionOfName(fileName);
  try {
    return (new picker.DocumentViewPicker())
      .save({
        newFileNames: [fileName],
        fileSuffixChoices: [`.${ext}`]
      })
      .then(async (pickedUris) => {
        await fileCopy(sourcePath, pickedUris[0], true);
        console.info(`[fileDocumentPickCopySave] DocumentViewPicker.save successfully, uris[0]: ${pickedUris[0]}`);
        return true;
      });
  } catch (e) {
    console.error(`[fileDocumentPickCopySave] DocumentViewPicker failed: ${e}`);
    return false;
  }
}

/**
 * Pick a file from device gallery, pulling up a PhotoViewPicker.
 * @returns Majorly the path.
 * */
export async function galleryPick2Path(type: photoAccessHelper.PhotoViewMIMETypes = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE, maxSelectionNumber: number = 1) {
  if (!canIUse("SystemCapability.FileManagement.UserFileService")) {
    console.error('[galleryPick2Path] DocumentViewPicker.select failed. canIUse("SystemCapability.FileManagement.UserFileService") is false!');
    return { succeed: false } as meowReadPickResult;
  }

  return (new photoAccessHelper.PhotoViewPicker())
    .select({
      MIMEType: type,
      maxSelectNumber: maxSelectionNumber
    })
    .then((PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      console.info('[galleryPick2Path] PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
      let sourcePaths: string[] = [];

      if (PhotoSelectResult.photoUris.length == 0) {
        console.info(`[galleryPick2Path] PhotoViewPicker.select Selected nothing.`);
        return { succeed: false } as meowReadPickResult;
      }

      for (let index = 0; index < PhotoSelectResult.photoUris.length; index++) {
        const sourcePath = uri_2_path(PhotoSelectResult.photoUris[index]);
        console.info(`[galleryPick2Path] PhotoViewPicker.select successfully, documentSelectResult sourcePath[${index}]: ${sourcePath}`);
        sourcePaths.push(sourcePath);
      }

      return {
        succeed: true,
        sourcePaths: sourcePaths,
      } as meowReadPickResult;
    })
    .catch((err: BusinessError) => {
      console.error('[galleryPick2Path] PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
      return { succeed: false } as meowReadPickResult;
    });
}

/**
 * Picks a directory and returns the path.
 * @returns The path or undefined if ran into errors.
 * */
export async function pickDirectory(): Promise<string | undefined> {
  if (canIUse("SystemCapability.FileManagement.UserFileService.FolderSelection")) {
    let DocumentSelectOptions = new picker.DocumentSelectOptions();
    DocumentSelectOptions.selectMode = picker.DocumentSelectMode.FOLDER;
    let documentPicker = new picker.DocumentViewPicker();
    try {
      let uris = await documentPicker.select(DocumentSelectOptions);
      return uri_2_path(uris[0]);
    } catch (e) {
      console.error(`[pickDirectory] Failed! ${e}`);
      return undefined;
    }
  } else {
    console.error('[pickDirectory] failed. canIUse("SystemCapability.FileManagement.UserFileService.FolderSelection") is false!');
  }
  return undefined;
}

// Save

/**
 * Save a text file or ArrayBuffer to sandbox storage, overwrites whatever that was at that place.
 * @param fullFilePath The destination path or uri.
 * @param content A string or an ArrayBuffer, fills the file's content.
 * @param overwrite overwrite or not. Default is false.
 * @param fsync Call fsync or not. Default is false (as this impacts I/O performance).
 * @author awa_Liny and enhanced by DeepSeek V4 API @ Jul 22 2026.
 * */
export async function saveHybrid(fullFilePath: string, content: string | ArrayBuffer | undefined, overwrite = false, fsync = false) {
  const startTime = Date.now();
  if (content === undefined) {
    console.error(`[saveHybrid][${fullFilePath}] content is undefined.`);
    return false;
  }
  if (!fullFilePath) {
    console.error(`[saveHybrid][${fullFilePath}] fullFilePath is empty.`);
    return false;
  }

  let file: fileIo.File | undefined;
  try {
    // Check if file exists
    if (overwrite) {
      // OVERWRITE
      // await fileIo.unlink(fullFilePath); // We use OpenMode.READ_WRITE | OpenMode.CREATE | OpenMode.TRUNC below to directly overwrite.
    } else {
      // NO OVERWRITE
      // Check if file exist. If exist, stop script.
      if (await fileIo.access(fullFilePath)) {
        console.warn(`[saveHybrid] file ${fullFilePath} exist! Returned. (${Date.now() - startTime} ms)`);
        return undefined;
      }
    }

    file = await fileIo.open(
      fullFilePath,
      fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC // Ensures the files is empty when opened.
    );

    const contentBytes = typeof content === 'string' ? new util.TextEncoder().encodeInto(content) : new Uint8Array(content);
    const total = contentBytes.byteLength;
    let offset = 0;

    while (offset < total) {
      let chunk: ArrayBuffer;
      if (offset === 0 && content instanceof ArrayBuffer) {
        chunk = content; // No copy, pass in directly
      } else if (offset === 0 && contentBytes.byteOffset === 0 && contentBytes.buffer.byteLength === total) {
        chunk = contentBytes.buffer as ArrayBuffer; // offset = 0, is the first try. Avoid copying anything.
      } else {
        chunk = contentBytes.buffer.slice(contentBytes.byteOffset + offset, contentBytes.byteOffset + total);
      }
      const written = await fileIo.write(file.fd, chunk);
      if (written <= 0) {
        throw new Error(`short write: ${written} at byte ${offset}/${total}`);
      }
      offset += written;
    }

    console.info(`[saveHybrid] write to file ${fullFilePath} succeed, size = ${total} (${Date.now() - startTime} ms)`);
    return true;
  } catch (e) {
    console.error(`[saveHybrid] write to file ${fullFilePath} failed: ${e} (${Date.now() - startTime} ms)`);
    return false;
  } finally {
    if (file !== undefined) {
      if (fsync) {
        try {
          await fileIo.fsync(file.fd);
        } catch (fsyncErr) {
          console.error(`[saveHybrid] fileIo.fsync(file.fd) file ${fullFilePath} failed: ${fsyncErr} (${Date.now() - startTime} ms)`);
        }
      }
      try {
        await fileIo.close(file);
      } catch (closeErr) {
        console.error(`[saveHybrid] fileIo.close(file) file ${fullFilePath} failed: ${closeErr} (${Date.now() - startTime} ms)`);
      }
    }
  }
}

/**
 * Save a file atomically using the write-to-temp + rename pattern.
 *
 * Guarantees that the target file is never observed in a corrupted or
 * partially-written state — even if the process crashes mid-write:
 *   1. Content is fully written to a uniquely-named temporary file.
 *   2. On success, the temp file is atomically renamed over the target,
 *      replacing it in a single kernel-level operation.
 *   3. On any failure the temp file is cleaned up.
 *
 * Because rename(2) is atomic on POSIX filesystems (ext4, f2fs, …),
 * the target path always points to a complete, valid file — either the
 * old version or the new one — never to an empty or half-written file.
 *
 * This is the recommended method for persisting state that must survive
 * a crash, such as settings, bookmarks, or history.
 *
 * @param fullFilePath The destination path.
 * @param content      A string or an ArrayBuffer.
 * @param overwrite    Whether to replace an existing file. Default true.
 * @param fsync Call fsync or not. Default is false (as this impacts I/O performance).
 * @returns true if saved, false on failure, undefined if overwrite=false
 *          and the target already exists.
 * @author DeepSeek V4 @ Jul 21 2026s
 */
export async function saveHybridSafe(fullFilePath: string, content: string | ArrayBuffer | undefined, overwrite = true, fsync = false) {
  const startTime = Date.now();
  if (content === undefined) {
    console.error(`[saveHybridSafe][${fullFilePath}] content is undefined.`);
    return false;
  }

  // [前置] 如果不覆盖且目标已存在，提前退出——避免无用的 temp 写入
  if (!overwrite) {
    try {
      if (await fileIo.access(fullFilePath)) {
        console.warn(`[saveHybridSafe] exists & overwrite=false → kept old file (${Date.now() - startTime} ms)`);
        return undefined;
      }
    } catch (_) {
      // Cannot confirm file status, give up.
      console.error(`[saveHybridSafe] access failed, aborting (${Date.now() - startTime} ms)`);
      return false;
    }
  }

  // Unique temp name
  const tmpPath = `${fullFilePath}.tmp.${Date.now().toString(36)}.${util.generateRandomUUID()}`;

  // 1. Write content fully to the temp file
  const writeOk = await saveHybrid(tmpPath, content, true, fsync);
  if (!writeOk) {
    try {
      await fileIo.unlink(tmpPath);
    } catch (_) {
      /* best effort */
    }
    console.error(`[saveHybridSafe] temp write failed (${Date.now() - startTime} ms)`);
    return false;
  }

  // 2. Atomically swap in the new file
  try {
    await fileIo.rename(tmpPath, fullFilePath);
    console.info(`[saveHybridSafe] [${fullFilePath}] OK (${Date.now() - startTime} ms)`);
    return true;
  } catch (e) {
    console.error(`[saveHybridSafe] rename failed: ${e} (${Date.now() - startTime} ms)`);
    try {
      await fileIo.unlink(tmpPath);
    } catch (_) {
      /* best effort */
    }
    return false;
  }
}

/**
 * Rename a folder.
 * @param folderPath The source path.
 * @param newPath The destination path.
 * @returns True if success, false otherwise.
 */
export async function renameFolder(folderPath: string, newPath: string) {
  try {
    await fileIo.rename(folderPath, newPath);
    console.info(`[renameFolder] rename folder ${folderPath} to ${newPath} succeed`);
    return true;
  } catch (e) {
    console.error(`[renameFolder] rename folder ${folderPath} to ${newPath} failed: ${e}`);
    return false;
  }
}

/**
 * Save an image to album.
 * @param context The common.UIAbilityContext.
 * @param srcFilePath The source path.
 * @author awa_Liny and enhanced by DeepSeek V4 API @ Jul 22 2026.
 */
export async function saveImageToAlbum(srcFilePath: string, context: common.UIAbilityContext): Promise<boolean> {
  const srcFileUri = path_2_uri(srcFilePath);
  const ext = extensionOfName(srcFilePath);
  console.info('[saveImageToAlbum] Source URI: ' + srcFileUri);

  let desFile: fileIo.File | undefined;
  let srcFile: fileIo.File | undefined;
  try {
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let desFileUris: string[] = await phAccessHelper.showAssetsCreationDialog(
      [srcFileUri],
      [{ fileNameExtension: ext, photoType: photoAccessHelper.PhotoType.IMAGE }]
    );
    if (!desFileUris || desFileUris.length === 0) {
      console.info('[saveImageToAlbum] User cancelled or no URI returned');
      return false;
    }
    console.info(`[saveImageToAlbum] Destination URIs: ${desFileUris}`);

    desFile = await fileIo.open(desFileUris[0], fileIo.OpenMode.WRITE_ONLY);
    srcFile = await fileIo.open(srcFileUri, fileIo.OpenMode.READ_ONLY);
    await fileIo.copyFile(srcFile.fd, desFile.fd);
    console.info('[saveImageToAlbum] create asset by dialog successfully');
    return true;
  } catch (err) {
    console.error(`[saveImageToAlbum] failed to create asset by dialog, errCode is: ${err.code}, ${err.message}`);
    return false;
  } finally {
    // always attempt close regardless of success/failure
    if (srcFile) {
      try {
        await fileIo.close(srcFile);
      } catch (_) {
        /* best effort */
      }
    }
    if (desFile) {
      try {
        await fileIo.close(desFile);
      } catch (_) {
        /* best effort */
      }
    }
  }
}

/**
 * Copy a file.
 * @param fullSourcePath The source path.
 * @param fullDestUri The destination Uri.
 * @param overwrite Whether to overwrite the destination file if it exists.
 * @returns true if succeed, false if failed, undefined if the file exists but not to overwrite.
 */
export async function fileCopy(fullSourcePath: string, fullDestUri: string, overwrite: boolean) {
  console.log(`[fileCopy] fileIo.copyFile(${fullSourcePath}, ${fullDestUri}, ${overwrite})`);

  // Check source
  try {
    if (!(await fileIo.access(fullSourcePath))) {
      console.error(`[fileCopy] fileIo.copyFile(${fullSourcePath}, ${fullDestUri}, ${overwrite}) test accessSync failed: source file ${fullSourcePath} doesn't exist`);
      return false;
    }
  } catch (e) {
    console.error(`[fileCopy] fileIo.copyFile(${fullSourcePath}, ${fullDestUri}, ${overwrite}) test source accessSync failed: ${e}`);
    return false;
  }

  // Check destination
  try {
    if (await fileIo.access(fullDestUri)) {
      if (!overwrite) {
        return undefined;
      }
    }
  } catch (e) {
    console.error(`[fileCopy] fileIo.copyFile(${fullSourcePath}, ${fullDestUri}, ${overwrite}) test destination accessSync failed: ${e}`);
    return false;
  }

  // Copy
  // TODO: Try to figure out a better way to copy with HarmonyOS APIs.
  const a = await readArrayBuffer(fullSourcePath);
  if (a == undefined) {
    console.error(`[fileCopy] fileIo.copyFile(${fullSourcePath}, ${fullDestUri}, ${overwrite}) failed: arrayBuffer is undefined!`);
    return false;
  }
  return await saveHybrid(fullDestUri, a, true);
}

/**
 * Copy a directory.
 * @param fullSourcePath The source path.
 * @param destParentFolderPath The destination folder path.
 * @param overwrite Whether to overwrite the destination file if it exists.
 * @returns true if succeed, false if failed, undefined if the file exists but not to overwrite.
 */
export async function dirCopy(fullSourcePath: string, destParentFolderPath: string, overwrite: boolean) {
  // Check source
  const sourceName = fileNameOfPath(fullSourcePath);

  try {
    if (!(await fileIo.access(fullSourcePath))) {
      console.error(`[dirCopy] fileIo.copyFile(${fullSourcePath}, ${destParentFolderPath}, ${overwrite}) test accessSync failed: source dir ${fullSourcePath} doesn't exist`);
      return false;
    }
  } catch (e) {
    console.error(`[dirCopy] fileIo.copyFile(${fullSourcePath}, ${destParentFolderPath}, ${overwrite}) test source accessSync failed: ${e}`);
    return false;
  }

  // Check destination
  try {
    if (await fileIo.access(`${destParentFolderPath}/${sourceName}`)) {
      if (!overwrite) {
        return undefined;
      } else {
        // Overwrite
        await fileIo.rmdir(`${destParentFolderPath}/${sourceName}`);
        await fileIo.mkdir(`${destParentFolderPath}/${sourceName}`);
        console.warn(`[dirCopy] dir ${destParentFolderPath}/${sourceName} overwritten`);
      }
    }
  } catch (e) {
    console.error(`[dirCopy] fileIo.copyFile(${fullSourcePath}, ${destParentFolderPath}, ${overwrite}) test destination accessSync failed: ${e}`);
    return false;
  }

  // Copy
  try {
    await fileIo.copyDir(fullSourcePath, destParentFolderPath, 1); // 1 for force overwrite. But in most normal cases, the destDir should be empty. This is only an insurance.
    console.info(`[dirCopy] dir ${fullSourcePath} copied to ${destParentFolderPath}`);
    return true;
  } catch (e) {
    console.error(`[dirCopy] fileIo.copyDir(${fullSourcePath}, ${destParentFolderPath}, ${overwrite}) failed: ${e}`);
    return false;
  }
}

/**
 * Move a directory.
 * @param fullSourcePath The source path.
 * @param destParentFolderPath The destination folder path.
 * @param overwrite Whether to overwrite the destination file if it exists.
 * @returns true if succeed, false if failed, undefined if the file exists but not to overwrite.
 */
export async function dirMove(fullSourcePath: string, destParentFolderPath: string, overwrite: boolean) {
  // Check source
  const sourceName = fileNameOfPath(fullSourcePath);

  try {
    if (!(await fileIo.access(fullSourcePath))) {
      console.error(`[dirMove] dirMove(${fullSourcePath}, ${destParentFolderPath}, ${overwrite}) test access failed: source dir ${fullSourcePath} doesn't exist`);
      return false;
    }
  } catch (e) {
    console.error(`[dirMove] dirMove(${fullSourcePath}, ${destParentFolderPath}, ${overwrite}) test source access failed: ${e}`);
    return false;
  }

  // Check destination
  try {
    if (await fileIo.access(`${destParentFolderPath}/${sourceName}`)) {
      if (!overwrite) {
        return undefined;
      } else {
        // Overwrite
        await fileIo.rmdir(`${destParentFolderPath}/${sourceName}`);
        await fileIo.mkdir(`${destParentFolderPath}/${sourceName}`);
        console.warn(`[dirMove] dir ${destParentFolderPath}/${sourceName} overwritten`);
      }
    }
  } catch (e) {
    console.error(`[dirMove] dirMove(${fullSourcePath}, ${destParentFolderPath}, ${overwrite}) test destination accessSync failed: ${e}`);
    return false;
  }

  // Copy
  try {
    await fileIo.moveDir(fullSourcePath, destParentFolderPath);
    console.info(`[dirMove] dir ${fullSourcePath} moved to ${destParentFolderPath}`);
    return true;
  } catch (e) {
    console.error(`[dirMove] dirMove(${fullSourcePath}, ${destParentFolderPath}, ${overwrite}) failed: ${e}`);
    return false;
  }
}

/**
 * Append a string to the end of a file — absolutely reliable edition.
 *
 * Guarantees:
 *   • Short-write detection and retry (iterates until all bytes land on disk).
 *   • Uses a TextEncoder → ArrayBuffer so byte offsets are always
 *     consistent, even in the presence of multi-byte UTF-8 characters.
 *   • File descriptor is always closed via try / finally, regardless of
 *     whether write or close throws.
 *   • Empty-string writes are a no-op success (no file is opened).
 *
 * @param filePath The file path. Created if it does not exist.
 * @param str      The string to append.
 * @returns true if every byte was written and the file was closed cleanly.
 */
export async function appendTextToEndOfFile(filePath: string, str: string): Promise<boolean> {
  if (!str) {
    console.warn(`[appendTextToEndOfFile] str is empty; nothing to append.`);
    return true;
  }

  let file: fileIo.File | undefined;
  try {
    file = await fileIo.open(
      filePath,
      fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.APPEND | fileIo.OpenMode.CREATE
    );

    // Encode once so byte offsets never drift from character offsets.
    const encoded = new util.TextEncoder().encodeInto(str);
    const total = encoded.byteLength;
    let offset = 0;

    while (offset < total) {
      const written = await fileIo.write(file.fd, encoded.buffer.slice(offset));
      if (written <= 0) {
        throw new Error(`write returned ${written} at byte ${offset} / ${total}`);
      }
      offset += written;
    }

    console.log(`[appendTextToEndOfFile] appended ${total} bytes to ${filePath}`);
    return true;

  } catch (e) {
    console.error(`[appendTextToEndOfFile] failed: ${e}`);
    return false;

  } finally {
    if (file !== undefined) {
      try {
        await fileIo.close(file);
      } catch (closeErr) {
        console.error(`[appendTextToEndOfFile] close failed (data already on disk): ${closeErr}`);
      }
    }
  }
}

/**
 * Ensure a directory exists, RECURSIVELY.
 * @param dirPath The folder path.
 * @returns true if directory already exists, false if not, undefined for errors.
 */
export async function ensureDirectoryExist(dirPath: string) {
  try {
    if (!(await fileIo.access(dirPath))) {
      await fileIo.mkdir(dirPath, true);
      meow(`dir ${dirPath} created`, 'ensureDirectoryExist');
      return false;
    } else {
      return true;
    }
  } catch (e) {
    console.error(`[ensureDirectoryExist] fileIo.mkdir(${dirPath}) failed: ${e}`);
    return undefined;
  }
}

// Delete

/**
 * Clear a directory.
 * @param dirPath The folder path.
 */
export async function clearDirectory(dirPath: string) {
  try {
    if (!(await fileIo.access(dirPath))) {
      // dir doesn't exist
      meow(`dir ${dirPath} doesn't exist`, 'clearDirectory', meowLevel.ERROR);
      return true;
    }
  } catch (e) {
    console.error(`[clearDirectory] await fileIo.access(dirPath) check failed: ${e}`);
    return false;
  }

  try {
    await fileIo.rmdir(dirPath);
    await fileIo.mkdir(dirPath, true);
    meow(`dir ${dirPath} cleared`, 'clearDirectory');
    return true;
  } catch (e) {
    console.error(`[clearDirectory] fileIo.rmdir(dirPath) failed: ${e}`);
    return false;
  }
}

/**
 * Unlink a file.
 * @param filePath The file path.
 * @returns true if succeed (the file just, doesn't exist there :D), false if failed.
 */
export async function unlinkFile(filePath: string) {
  if (!(await fileDirExist(filePath))) {
    console.log(`[unlinkFile] file [${filePath}] doesn't exist at all! Nevertheless your goal is achieved, isn't it?`);
    return true;
  }
  try {
    await fileIo.unlink(filePath);
    console.log(`[unlinkFile] unlinked [${filePath}]`);
    return true;
  } catch (e) {
    console.error(`[unlinkFile] fileIo.unlink(${filePath}) failed: ${e}`);
    return false;
  }
}

/**
 * Remove a directory.
 * @param dirPath The folder path.
 * @returns true if succeed (the folder just, doesn't exist there :D), false if failed.
 */
export async function removeDir(dirPath: string) {
  if (!(await fileDirExist(dirPath))) {
    console.log(`[removeDir] dir [${dirPath}] doesn't exist at all! Nevertheless your goal is achieved, isn't it?`);
    return true;
  }
  try {
    await fileIo.rmdir(dirPath);
    console.log(`[removeDir] removed [${dirPath}]`);
    return true;
  } catch (e) {
    console.error(`[removeDir] fileIo.rmdir(${dirPath}) failed: ${e}`);
    return false;
  }
}

// Read

/**
 * Check if a file exists.
 * @param path The file path.
 * @returns true if the file exists, false if not.
 */
export async function fileDirExist(path: string) {
  try {
    const result = await fileIo.access(path);
    return result;
  } catch (e) {
    console.error(`[fileExist] fileIo.access(${path}) failed: ${e}`);
    return false;
  }
}

/**
 * List all files under a directory.
 * @param dirPath The folder path.
 * @returns A list of filenames.
 */
export async function listFilesUnderDir(dirPath: string) {
  try {
    if (!(await fileIo.access(dirPath))) {
      // dir doesn't exist
      meow(`dir ${dirPath} doesn't exist`, 'listFilesUnderDir', meowLevel.ERROR);
      return undefined;
    }
  } catch (error) {
    meow(`access dir ${dirPath} failed: ${error}`, 'listFilesUnderDir', meowLevel.ERROR);
    return undefined;
  }

  try {
    let files = await fileIo.listFile(dirPath);
    return files;
  } catch (e) {
    meow(`fileIo.listFileSync(${dirPath}) failed: ${e}`, 'listFilesUnderDir', meowLevel.ERROR);
    return undefined;
  }
}

/**
 * Calculate the size of a folder and its containing items recursively in a sync way.
 * @param path A string, the path of the folder.
 * @returns A number, the size of that folder.
 * */
export function getFolderSizeSync(path: string): number {
  return _getFolderSizeSync(path, new Set<bigint>());
}

/**
 * The real function to do the job safely.
 * @author DeepSeek V4 API @ Jul 21 2026.
 */
function _getFolderSizeSync(path: string, visited: Set<bigint>) {
  let dirStat: fileIo.Stat;
  try {
    dirStat = fileIo.statSync(path);
  } catch (_) {
    return 0; // Skip unaccessible dirs.
  }

  if (visited.has(dirStat.ino)) {
    return 0; // Accessed, this is a loop! skip!
  }
  visited.add(dirStat.ino);

  let sum = 0;
  let dir_list: string[];
  try {
    dir_list = fileIo.listFileSync(path);
  } catch (_) {
    return sum; // Skip failed directories.
  }

  for (let i = 0; i < dir_list.length; i++) {
    let fileStat: fileIo.Stat;
    try {
      fileStat = fileIo.statSync(path + '/' + dir_list[i]);
      if (fileStat.isFile()) {
        sum += fileStat.size;
      } else if (fileStat.isDirectory()) {
        sum += _getFolderSizeSync(path + '/' + dir_list[i], visited);
      }
    } catch (_) {
      continue; // Skip single failures.
    }
  }
  return sum;
}

/**
 * Read an ArrayBuffer file from storage in an async way.
 * @param fullFilePath the file path
 * @param offset       The offset from which to start reading. Defaults to 0.
 * @param length       The maximum number of bytes to read. Defaults to
 *                     the remaining bytes from offset to end-of-file.
 * @returns An ArrayBuffer containing the requested data,
 *          or undefined if the file doesn't exist, is too large
 *          (< 2 GB), or was truncated between stat and read (very low odds).
 * @author awa_Liny and enhanced by DeepSeek V4 API @ Jul 22 2026.
 * */
@Concurrent
export async function readArrayBuffer(fullFilePath: string, offset?: number, length?: number) {
  const startTime: number = Date.now();

  // 1. Check file existence.
  let exists: boolean;
  try {
    exists = await fileIo.access(fullFilePath);
  } catch (e) {
    console.error(`[readArrayBuffer][${fullFilePath}] access failed: ${e}`);
    return undefined;
  }
  if (!exists) {
    console.warn(`[readArrayBuffer][${fullFilePath}] doesn't exist`);
    return undefined;
  }

  // 2. Get file size.
  let stat: fileIo.Stat;
  try {
    stat = await fileIo.stat(fullFilePath);
  } catch (e) {
    console.error(`[readArrayBuffer][${fullFilePath}] stat failed: ${e}`);
    return undefined;
  }

  // 3. Compute read parameters (?? instead of || so that 0 is kept as-is).
  const filePos = offset ?? 0;
  const requested = length ?? (stat.size - filePos);

  if (requested <= 0) {
    return new ArrayBuffer(0);
  }

  const MAX_READ = 2147483647; // about 2 GB

  // Block too large files.
  if (requested > MAX_READ) {
    console.error(`[readArrayBuffer][${fullFilePath}] too large: ${requested} > ${MAX_READ}`);
    return undefined;
  }

  // 4. Allocate buffer and read.
  const buf = new ArrayBuffer(requested);
  let file: fileIo.File | undefined;

  try {
    file = await fileIo.open(fullFilePath, fileIo.OpenMode.READ_ONLY);
    const actual = await fileIo.read(file.fd, buf, {
      offset: filePos, // file offset
      length: requested // max bytes to read
    });

    // 5. Tell "request went past EOF" from "file was truncated".
    if (actual < requested) {
      if (filePos + actual >= stat.size) {
        // Reached (or passed) EOF → caller's length exceeded file size, it's OK & accept.
        console.warn(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] read to EOF: ${actual}/${requested} bytes, stat.size=${stat.size} (${Date.now() - startTime} ms)`);
        return buf.slice(0, actual);
      } else {
        // Did not reach EOF → file was truncated between stat and read, abnormal.
        console.error(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] unexpected short read: file truncated? ${actual}/${requested} bytes, stat.size=${stat.size} (${Date.now() - startTime} ms)`);
        return undefined;
      }
    }

    console.log(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] succeed! ${actual} bytes (${Date.now() - startTime} ms)`);
    return buf;
  } catch (e) {
    console.error(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] read failed: ${e}`);
    return undefined;
  } finally {
    if (file !== undefined) {
      await fileIo.close(file).catch((e: BusinessError) => {
        console.error(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] close failed: ${e}`);
      });
    }
  }
}

/**
 * Read an ArrayBuffer file from storage in a task pool way.
 * @param fullFilePath the file path
 * @param offset The offset of where to begin reading. If this is set, then the length must be set.
 * @param length The length of the file to read.
 * @returns An ArrayBuffer, of the requested file's content or undefined if the file doesn't exist.
 * */
export async function readArrayBufferConcurrent(fullFilePath: string, offset?: number, length?: number) {
  // const startTime: number = Date.now();
  let task: taskpool.Task;
  if (offset !== undefined) {
    task = new taskpool.Task(readArrayBuffer, fullFilePath, offset!, length!);
  } else {
    task = new taskpool.Task(readArrayBuffer, fullFilePath);
  }
  try {
    const result = await taskpool.execute(task);
    // console.info(`[readArrayBufferConcurrent][${fullFilePath}][${offset}, ${length}] succeed! (${Date.now() - startTime} ms)`);
    return result as ArrayBuffer;
  } catch (e) {
    console.error(`[readArrayBufferConcurrent][${fullFilePath}][${offset}, ${length}] const result = await taskpool.execute(task); Failed: ${e}`);
    return undefined;
  }
}

// Utils

/**
 * Converts a uri to path.
 * @param uri The uri.
 * @returns Its path.
 * */
export function uri_2_path(uri: string) {
  return new fileUri.FileUri(uri).path;
}

/**
 * Converts a path to uri.
 * @param path The path.
 * @returns Its uri.
 * */
export function path_2_uri(path: string) {
  return fileUri.getUriFromPath(path);
}

/**
 * Filter the string to a valid file name for HarmonyOS / OpenHarmony.
 * - Replace illegal characters: \ / : * ? " < > |
 * - Replace ASCII control characters (including carriage return, line feed, tab, etc.)
 * - Optional: Trim leading and trailing spaces and periods (recommended to keep)
 * - Prevent the final result from being empty
 * @param filename original file name
 * @param rep Replacement character, default '_'
 * @returns valid file name
 */
export function makeFilenameLegal(filename: string, rep: string = '_'): string {
  // 1. 替换非法字符 + 控制字符
  let legal = filename.replace(/[\\/:*?"<>|\x00-\x1F\x7F]/g, rep);
  // 2. 修剪尾部空格和点号
  legal = legal.trim().replace(/[.\s]+$/, ''); // 只去尾部，不去首部
  // 3. 如果结果为空，给一个默认名
  if (legal.length === 0) {
    legal = 'meow';
  }
  // 4. 如果文件名太长，进行限制。保留文件扩展名，从后向前截取。
  if (legal.length > 255) {
    const lastDotIndex = legal.lastIndexOf('.');
    if (lastDotIndex > 0) {
      const extLen = legal.length - lastDotIndex;
      legal = legal.slice(0, 255 - extLen) + legal.slice(lastDotIndex);
    } else {
      legal = legal.slice(0, 255);
    }
  }
  return legal;
}

/**
 * Decodes a base64 string to array buffer.
 * @param base64Str The base64 string.
 * @returns The array buffer.
 * */
export function base64_2_arrayBuffer(base64Str: string): Promise<ArrayBuffer> {
  let base64 = new util.Base64Helper();
  return base64.decode(base64Str).then((uint8Array) => {
    if (uint8Array.byteOffset === 0 && uint8Array.byteLength === uint8Array.buffer.byteLength) {
      return uint8Array.buffer as ArrayBuffer; // Total align, no need to copy.
    }
    return uint8Array.buffer.slice(uint8Array.byteOffset, uint8Array.byteOffset + uint8Array.byteLength);
  });
}

/**
 * Scans QR code from an image file.
 * @param path The path of the file.
 * @returns Array<scanBarcode.ScanResult>.
 * */
export async function scanQrFromPath(path: string, ignoreCanIUse: boolean = false) {
  if (canIUse("SystemCapability.Multimedia.Scan.ScanBarcode") || ignoreCanIUse) {
    const result = await detectBarcode.decode({ uri: path_2_uri(path) })
      .catch((e: BusinessError) => {
        console.error(`[scanQrFromPath] Failed: ${e}`);
        return [];
      });
    return result;
  } else {
    console.error(`[scanQrFromPath] Not supported.`);
    return [];
  }
}

/**
 * Adds a unit to a size in bytes. Note that the smallest unit is KB.
 * @param size_in_bytes A number or bigint, the size in bytes.
 * @returns A string, the connected result of a number of size and its unit.
 * */
export function addUnitsToSize(size_in_bytes: number | bigint) {
  if (size_in_bytes == undefined || size_in_bytes == null) {
    return 'No Bytes!';
  }
  let units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  let result = BigInt(size_in_bytes);
  let unit = 0;
  while (result >= 1000 * 1000 && unit < units.length - 2) {
    result /= 1000n;
    unit += 1;
  }
  // To keep decimal places.
  let numberResult = Number(result);
  numberResult /= 1000;
  unit += 1;
  return numberResult.toFixed(2) + " " + units[unit];
}

/**
 * 根据文件名或路径获取对应的 MIME 类型。
 * @description
 * 1. 自动处理大小写（如 .JPG -> image/jpeg）。
 * 2. 能够正确处理包含路径的字符串（如 /path/to/file.txt）。
 * 3. 排除无后缀或隐藏文件（如 .gitignore）。
 * 4. 匹配失败时默认返回 'application/octet-stream'。
 * @param {string} fileName - 文件名或完整路径 (例如: "image.png" 或 "/home/user/data.json")
 * @returns {string} 对应的 MIME 类型字符串
 * @example
 * mimeOfFileName('vacation.jpg');     // 'image/jpeg'
 * mimeOfFileName('INDEX.HTML');      // 'text/html'
 * mimeOfFileName('config');          // 'application/octet-stream'
 * mimeOfFileName('.hidden-file');    // 'application/octet-stream'
 *
 * @author Gemini web @ Feb 8 2026
 */
export function mimeOfFileName(fileName: string): string {
  if (!fileName) {
    return 'application/octet-stream';
  }

  // 1. 只取文件名部分，防止路径中的点号干扰 (例如 /path.to/my-file)
  const baseName = fileName.split(/[\\/]/).pop() || '';

  // 2. 提取后缀名
  const lastDotIndex = baseName.lastIndexOf('.');

  // 如果点号不存在，或者点号在开头（如 .gitignore），通常视为无后缀
  if (lastDotIndex <= 0) {
    return 'application/octet-stream';
  }

  const ext = baseName.slice(lastDotIndex + 1).toLowerCase();

  return MIME_TYPES_MAP_LITE[ext] || 'application/octet-stream';
}

/**
 * Gets the file name from a path.
 * @param path The path.
 * @returns The file name.
 */
export function fileNameOfPath(path: string) {
  // Skip the slash at the very end.
  let end = path.length;
  while (end > 0 && path[end - 1] === '/') {
    end--;
  }
  if (end === 0) return '';
  const lastSlash = path.lastIndexOf('/', end - 1);
  return lastSlash >= 0 ? path.slice(lastSlash + 1, end) : path.slice(0, end);
}

/**
 * Gets the extension of a file name.
 * @param name The file name.
 * @returns The extension.
 */
export function extensionOfName(name: string) {
  const lastDotIndex = name.lastIndexOf('.');
  return lastDotIndex > 0 ? name.slice(lastDotIndex + 1).toLowerCase() : '';
}

/**
 * Converts an ArrayBuffer to image.PixelMap object.
 * @param buf the ArrayBuffer
 * @returns an image.PixelMap
 * */
export function arrayBuffer_2_pixelMap(buf: ArrayBuffer) {
  // ArrayBuffer => PixelMap
  const imageSource = image.createImageSource(buf);
  console.log('[arrayBuffer_2_pixelMap] imageSource: ' + JSON.stringify(imageSource));
  return imageSource.createPixelMap({})
    .then((pm) => {
      console.log('[arrayBuffer_2_pixelMap][A] Released imageSource!');
      return pm;
    })
    .catch((e: BusinessError) => {
      console.error(`[arrayBuffer_2_pixelMap][A] createPixelMap failed: ${e}`);
      return undefined;
    })
    .finally(() => {
      imageSource.release();
    });
}

/**
 * Packs a PixelMap to a file.
 * @param context The context.
 * @param pixelMap The pixel map.
 * @returns Promise of the path if successful.
 */
export async function packToFileFromPixelMap(context: Context, pixelMap: image.PixelMap) {
  const imagePackerApi = image.createImagePacker();
  let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
  const path: string = context.tempDir + '/shortcut.png';
  let file: fileIo.File | undefined;
  try {
    file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    await imagePackerApi.packToFile(pixelMap, file.fd, packOpts);
    return path;
  } catch (error) {
    console.error('Failed to pack the pixelMap to file. And the error is: ' + error);
  } finally {
    try {
      if (file) fileIo.closeSync(file);
    } catch (e) {
      // No other thing we can do. Give up 1 fd.
    }
    imagePackerApi.release();
  }
  return undefined;
}


// Others

/**
 * Opens a file in the default file manager.
 * @param path The path.
 * @param context The UIAbilityContext.
 */
export function showInFiles(path: string, context: common.UIAbilityContext) {
  // Open folder
  let link: string = 'filemanager://openDirectory';
  let openLinkOptions: OpenLinkOptions = {
    parameters: {
      'fileUri': path_2_uri(path)
    }
  };
  try {
    context.openLink(link, openLinkOptions);
    meow(`Open ${path} in file manager!`, 'showInFiles');
  } catch (e) {
    meow(`Open ${path} in file manager failed: ${e}`, 'showInFiles', meowLevel.ERROR);
  }
}

// Download

export async function downloadFileHttp(url: string): Promise<ArrayBuffer | undefined> {
  if (!/^https?:\/\//i.test(url)) {
    return undefined;
  }

  const httpRequest = http.createHttp(); // Create HTTP request task.

  const promise = new Promise<ArrayBuffer>((resolve, reject) => {
    httpRequest.request(url, {
      method: http.RequestMethod.GET,
      expectDataType: http.HttpDataType.ARRAY_BUFFER,
      connectTimeout: 15000, // 15s
      readTimeout: 30000, // 30s
    }, (err, data) => {
      if (err) {
        const e = new Error(`Request failed: ${err.message}`);
        reject(e);
        meow(`Failed: ${e}`, 'downloadFileHttp', meowLevel.ERROR);
        return;
      }
      // Check status code.
      if (!data || data.responseCode < 200 || data.responseCode >= 300) {
        const e = new Error(`Bad response: ${data?.responseCode ?? 'no response!'}`);
        reject(e);
        meow(`Failed: ${e}`, 'downloadFileHttp', meowLevel.ERROR);
        return;
      }
      // Check result.
      if (data?.result) {
        resolve(data.result as ArrayBuffer);
        meow('RESOLVED!', 'downloadFileHttp');
      } else {
        const e = new Error('No data received!');
        meow(`Failed: ${e}`, 'downloadFileHttp', meowLevel.ERROR);
        reject(e);
      }
    });
  });

  return promise.finally(() => {
    try {
      httpRequest.destroy();
    } catch (e) {
      meow(`httpRequest.destroy() failed: ${e}`, 'downloadFileHttp', meowLevel.WARN); // Is this try-catch necessary? Will httpRequest.destroy(); really throw anything?
    }
  });
}
