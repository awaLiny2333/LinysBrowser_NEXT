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
export async function fileDocumentPickSave(fileName: string, content: string | ArrayBuffer): Promise<boolean | void | undefined> {
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
    console.error('[fileDocumentPick2Path] DocumentViewPicker.select failed. canIUse("SystemCapability.FileManagement.UserFileService") is false!');
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
 * */
export async function saveHybrid(fullFilePath: string, content: string | ArrayBuffer | undefined, overwrite = false) {
  const startTime = Date.now();
  if (content == undefined) {
    console.error(`[saveHybrid][${fullFilePath}] content is undefined.`);
    return false;
  }

  try {
    if (await fileIo.access(fullFilePath)) {
      if (overwrite) {
        await fileIo.unlink(fullFilePath);
      } else {
        console.warn(`[saveHybrid] file ${fullFilePath} exist! Returned. (${Date.now() - startTime} ms)`);
        return undefined;
      }
    }

    let file = fileIo.openSync(fullFilePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    return fileIo.write(file.fd, content)
      .then((writeLen) => {
        console.info(`[saveHybrid] write to file ${fullFilePath} succeed, size = ${writeLen} (${Date.now() - startTime} ms)`);
        return true;
      })
      .catch((e: BusinessError) => {
        console.error(`[saveHybrid] fileIo.write(file.fd, content) to file ${fullFilePath} failed: ${e} (${Date.now() - startTime} ms)`);
        return false;
      })
      .finally(() => {
        fileIo.close(file)
          .catch((e: BusinessError) => {
            console.error(`[saveHybrid] fileIo.close(file) file ${fullFilePath} failed: ${e} (${Date.now() - startTime} ms)`);
          });
      });
  } catch (e) {
    console.error(`[saveHybrid] write to file ${fullFilePath} failed: ${e} (${Date.now() - startTime} ms)`);
    return false;
  }
}

/**
 * Rename a folder.
 * @param folderPath The source path.
 * @param newPath The destination path.
 */
export async function renameFolder(folderPath: string, newPath: string) {
  await fileIo.rename(folderPath, newPath)
    .catch((e: BusinessError) => {
      console.error(`[renameFolder] rename folder ${folderPath} to ${newPath} failed: ${e}`);
    });
  console.info(`[renameFolder] rename folder ${folderPath} to ${newPath} succeed`);
}

/**
 * Save an image to album.
 * @param context The common.UIAbilityContext.
 * @param srcFilePath The source path.
 */
export async function saveImageToAlbum(srcFilePath: string, context: common.UIAbilityContext): Promise<boolean> {
  // Then save to gallery
  const srcFileUri = path_2_uri(srcFilePath);
  const ext = extensionOfName(srcFilePath);
  console.info('[saveImageToAlbum] Source URI: ' + srcFileUri);

  try {
    // Show dialog to ask for permission and get destination url.
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let desFileUris: string[] = await phAccessHelper.showAssetsCreationDialog([srcFileUri], [{ fileNameExtension: ext, photoType: photoAccessHelper.PhotoType.IMAGE }]);
    console.info(`[saveImageToAlbum] Destination URIs: ${desFileUris}`);

    // Copy there
    let desFile: fileIo.File = await fileIo.open(desFileUris[0], fileIo.OpenMode.WRITE_ONLY);
    let srcFile: fileIo.File = await fileIo.open(srcFileUri, fileIo.OpenMode.READ_ONLY);
    await fileIo.copyFile(srcFile.fd, desFile.fd);
    fileIo.closeSync(srcFile);
    fileIo.closeSync(desFile);
    console.info('[saveImageToAlbum] create asset by dialog successfully');

    unlinkFile(srcFilePath); // Clear
    return true;
  } catch (err) {
    console.error(`[saveImageToAlbum] failed to create asset by dialog, errCode is: ${err.code}, ${err.message}`);
    return false;
  }
};

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
  }

  // Copy
  try {
    await fileIo.copyDir(fullSourcePath, destParentFolderPath);
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
 * Append a string to the end of a file.
 * @param filePath The file path.
 * @param str The string to append.
 * @returns true if succeed, false if failed.
 */
export async function appendTextToEndOfFile(filePath: string, str: string) {
  try {
    let file = await fileIo.open(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.APPEND | fileIo.OpenMode.CREATE); // 设置以追加方式打开文件
    let writeLen = await fileIo.write(file.fd, str); // 向文件内写入内容，返回值为写入内容的长度
    console.log(`[appendTextToEndOfFile] appended content [${str}] to file ${filePath}, length = ${writeLen}`);
    await fileIo.close(file); // 关闭文件
    return true;
  } catch (e) {
    console.error(`[appendTextToEndOfFile] fileIo.write(file.fd, ${str}) of file ${filePath} failed: ${e}`);
    return false;
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
 * @throws Whatever the file apis would throw. Please handle this at usage side / in wrappers.
 * */
export function getFolderSizeSync(path: string) {
  let sum = 0;
  // try {
  let dir_list = fileIo.listFileSync(path);
  for (let index = 0; index < dir_list.length; index++) {
    const fileStat = fileIo.statSync(path + '/' + dir_list[index]);
    if (fileStat.isFile()) {
      sum += fileStat.size;
    } else if (fileStat.isDirectory()) {
      sum += getFolderSizeSync(path + '/' + dir_list[index]);
    }
  }
  return sum;
  // } catch (e) {
  //   // Do nothing and skip that.
  //   meow(`fileIo.listFileSync(${path}) failed: ${e}`, 'storage][getFolderSizeSync', meowLevel.ERROR);
  //   return 0;
  // }
}

/**
 * Read an ArrayBuffer file from storage in an async way.
 * @param fullFilePath the file path
 * @returns An ArrayBuffer, of the requested file's content or undefined if the file doesn't exist.
 * */
@Concurrent
export async function readArrayBuffer(fullFilePath: string, offset?: number, length?: number) {
  const startTime: number = Date.now();

  try {
    if (!(await fileIo.access(fullFilePath))) {
      // file doesn't exist
      console.warn(`[readArrayBuffer][${fullFilePath}] doesn't exist`);
      return undefined;
    }
  } catch (e) {
    console.error(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] fileIo.accessSync(filePath) check failed: ${e}`);
    return undefined;
  }

  try {
    let file = await fileIo.open(fullFilePath, fileIo.OpenMode.READ_WRITE);
    let stat = await fileIo.stat(fullFilePath);

    // Read to ArrayBuffer
    let buf: ArrayBuffer = new ArrayBuffer(length || stat.size);
    let readLen = await fileIo.read(file.fd, buf, { offset: offset, length: length });

    let result = (length || stat.size) == readLen ? buf : buf.slice(0, readLen); // Copy?
    fileIo.close(file)
      .catch((e: BusinessError) => {
        console.error(`[readArrayBuffer] fileIo.close(file) failed: ${e}`);
      });

    // console.info(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] OK. ArrayBuffer size = ${length || stat.size}, readLen = ${readLen}, (length || stat.size) == readLen: ${readLen == (length || stat.size)} (${Date.now() - startTime} ms)`);
    return result;
  } catch (e) {
    console.error(`[readArrayBuffer][${fullFilePath}][${offset}, ${length}] file operation failed: ${e} (${Date.now() - startTime} ms). Return undefined.`);
    return undefined;
  }
}

/**
 * Read an ArrayBuffer file from storage in a task pool way.
 * @param fullFilePath the file path
 * @param context the context
 * @returns An ArrayBuffer, of the requested file's content or undefined if the file doesn't exist.
 * */
export async function readArrayBufferConcurrent(fullFilePath: string, offset?: number, length?: number) {
  // const startTime: number = Date.now();
  let task: taskpool.Task;
  if (offset) {
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

// Operations

/**
 * Creates a directory in sandbox directory
 * @param dirPath The folder path
 * @param context The context
 * @param overwrite Overwrite or not, default false
 * @returns The promise?
 * */
export function sandboxCreateDir(dirPath: string, context: Context, overwrite = false) {
  let filesDir: string = context.filesDir;
  let fullFilePath = filesDir + '/' + dirPath;
  if (fullFilePath.substring(fullFilePath.length - 1) != '/') {
    fullFilePath = fullFilePath + '/';
  }
  console.log(`[sandboxCreateDir] mkdirSync ${fullFilePath} GO.`);

  return fileIo.access(fullFilePath, fileIo.AccessModeType.EXIST)
    .then((r) => {
      if (r) {
        if (overwrite) {
          return fileIo.rmdir(fullFilePath)
            .then(() => {
              return fileIo.mkdir(fullFilePath)
                .then(() => {
                  console.log(`[sandboxCreateDir][r] mkdirSync ${dirPath} OK.`);
                })
                .catch((e: BusinessError) => {
                  console.error(`[sandboxCreateDir][r] mkdirSync ${dirPath} return fileIo.mkdir(fullFilePath) failed: ${e}`);
                });
            })
            .catch((e: BusinessError) => {
              console.error(`[sandboxCreateDir][r] mkdirSync ${dirPath} return fileIo.rmdir(fullFilePath) failed: ${e}`);
            });
        } else {
          console.warn(`[sandboxCreateDir][r] directory ${dirPath} exist! Returned.`);
          return;
        }
      } else {
        return fileIo.mkdir(fullFilePath)
          .then(() => {
            console.log(`[sandboxCreateDir][new] mkdirSync ${dirPath} OK.`);
          })
          .catch((e: BusinessError) => {
            console.error(`[sandboxCreateDir][new] mkdirSync ${dirPath} return fileIo.mkdir(fullFilePath) failed: ${e}`);
          });
      }
    })
    .catch((e: BusinessError) => {
      console.error(`[sandboxCreateDir] mkdirSync ${dirPath} fileIo.access(fullFilePath, fileIo.AccessModeType.EXIST) failed: ${e}`);
    });
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
  // 2. 修剪首尾空格和点号（根据需求可选，建议保留）
  legal = legal.trim().replace(/^\.+/, '').replace(/[.\s]+$/, '');
  // 3. 如果结果为空，给一个默认名
  if (legal.length === 0) {
    legal = 'meow';
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
    return uint8Array.buffer.slice(0, uint8Array.byteLength);
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
 * Adds a unit to a size in bytes.
 * @param size_in_bytes A number or bigint, the size in bytes.
 * @returns A string, the connected result of a number of size and its unit.
 * */
export function addUnitsToSize(size_in_bytes: number | bigint) {
  if (size_in_bytes == undefined || size_in_bytes == null) {
    return 'No Bytes!';
  }
  let units = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  let result = BigInt(size_in_bytes);
  let unit = 0;
  while (result > 1000 * 1000 && unit < units.length - 2) {
    result /= 1000n;
    unit += 1;
  }
  // To keep decimal places
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
  const sp = path.split('/');
  return sp[sp.length - 1];
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
      let pixelMap = pm;
      imageSource.release();
      console.log('[arrayBuffer_2_pixelMap][A] Released imageSource!');
      return pixelMap;
    })
    .catch((e: BusinessError) => {
      console.error(`[arrayBuffer_2_pixelMap][A] createPixelMap failed: ${e}`);
      return undefined;
    });
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

/**
* Download a file from url.
* @param url The url.
* @returns Promise of the ArrayBuffer.
* */
export async function downloadFileHttp(url: string): Promise<ArrayBuffer> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    httpRequest.request(url, {
      method: http.RequestMethod.GET,
      expectDataType: http.HttpDataType.ARRAY_BUFFER
    }, (err, data) => {
      if (err) {
        const e = new Error(`Request failed: ${err.message}`);
        reject(e);
        meow(`Failed: ${e}`, 'downloadFileHttp', meowLevel.ERROR);
        return;
      }
      if (data && data.result) {
        resolve(data.result as ArrayBuffer);
        meow(`RESOLVED!`, 'downloadFileHttp');
      } else {
        const e = new Error('No data received!');
        meow(`Failed: ${e}`, 'downloadFileHttp', meowLevel.ERROR);
        reject(e);
      }
    });
  });
}
